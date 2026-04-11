import Foundation
import Combine
import CryptoKit
import SwiftData

@MainActor
final class LocalQuizRepository: QuizRepository {
    private static let seedVersionKey = "RustDrill.seed.questionsJSON.sha256"

    private let context: ModelContext
    private let progressSubject = PassthroughSubject<Void, Never>()

    var progressDidChange: AnyPublisher<Void, Never> {
        progressSubject.eraseToAnyPublisher()
    }

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Seed
    func seedIfNeeded() throws {
        let seedData = try SeedLoader.loadQuestionsJSONData()
        let seedVersion = Self.sha256Hex(seedData)
        let storedVersion = UserDefaults.standard.string(forKey: Self.seedVersionKey)
        let questionCount = try context.fetchCount(FetchDescriptor<SDQuestion>())

        guard storedVersion != seedVersion || questionCount == 0 else { return }

        let seed = try JSONDecoder().decode(SeedData.self, from: seedData)
        try syncCatalog(with: seed)
        UserDefaults.standard.set(seedVersion, forKey: Self.seedVersionKey)
    }

    private func syncCatalog(with seed: SeedData) throws {
        let existingCategories = try context.fetch(FetchDescriptor<SDCategory>())
        var categoriesById = Dictionary(uniqueKeysWithValues: existingCategories.map { ($0.id, $0) })
        let seedCategoryIds = Set(seed.categories.map(\.id))

        for c in seed.categories {
            if let model = categoriesById[c.id] {
                model.name = c.name
                model.parentId = c.parentId
                model.order = c.order
                model.level = c.level
            } else {
                let model = SDCategory(
                    id: c.id,
                    name: c.name,
                    parentId: c.parentId,
                    order: c.order,
                    level: c.level
                )
                context.insert(model)
                categoriesById[c.id] = model
            }
        }

        for category in existingCategories where !seedCategoryIds.contains(category.id) {
            context.delete(category)
        }

        let existingQuestions = try context.fetch(FetchDescriptor<SDQuestion>())
        var questionsById = Dictionary(uniqueKeysWithValues: existingQuestions.map { ($0.id, $0) })
        let seedQuestionIds = Set(seed.questions.map(\.id))

        for q in seed.questions {
            let sdChoices = makeChoices(for: q)

            let explanationContentRaw = (
                try? JSONEncoder().encode(q.explanationContent)
            )
                .flatMap { String(data: $0, encoding: .utf8) } ?? ""

            if let question = questionsById[q.id] {
                question.categoryId = q.categoryId
                question.typeRaw = q.type.rawValue
                question.title = q.title
                question.body = q.body
                question.codeSnippet = q.codeSnippet
                question.correctChoiceId = "\(q.id)::\(q.correctChoiceId)"
                question.explanation = q.explanation
                question.explanationContentRaw = explanationContentRaw
                question.difficulty = q.difficulty
                question.tags = q.tags
                syncChoices(for: question, with: q)
            } else {
                let question = SDQuestion(
                    id: q.id,
                    categoryId: q.categoryId,
                    typeRaw: q.type.rawValue,
                    title: q.title,
                    body: q.body,
                    codeSnippet: q.codeSnippet,
                    correctChoiceId: "\(q.id)::\(q.correctChoiceId)",
                    explanation: q.explanation,
                    explanationContentRaw: explanationContentRaw,
                    difficulty: q.difficulty,
                    tags: q.tags,
                    choices: sdChoices
                )
                context.insert(question)
                questionsById[q.id] = question
            }
        }

        for question in existingQuestions where !seedQuestionIds.contains(question.id) {
            context.delete(question)
        }

        try context.save()
    }

    // MARK: - Category
    func fetchRootCategories() throws -> [Category] {
        let descriptor = FetchDescriptor<SDCategory>(
            predicate: #Predicate { $0.parentId == nil },
            sortBy: [SortDescriptor(\.order)]
        )
        let models = try context.fetch(descriptor)
        return models.map(mapCategory)
    }

    func fetchCategoryNodeState(categoryId: String) throws -> CategoryNodeState {
        let children = try fetchChildren(of: categoryId)
        let ownQuestionCount = try countQuestions(categoryId: categoryId)
        return CategoryNodeState(children: children, ownQuestionCount: ownQuestionCount)
    }

    func fetchCategoryNodeStates(categoryIds: [String]) throws -> [String: CategoryNodeState] {
        guard !categoryIds.isEmpty else { return [:] }

        let allChildren = try context.fetch(FetchDescriptor<SDCategory>())
            .map(mapCategory)
            .reduce(into: [String: [Category]]()) { result, category in
                guard let parentId = category.parentId else { return }
                result[parentId, default: []].append(category)
            }
            .mapValues { $0.sorted { $0.order < $1.order } }

        let questionCounts = try questionCountsByCategory()

        return Dictionary(uniqueKeysWithValues: categoryIds.map { categoryId in
            (
                categoryId,
                CategoryNodeState(
                    children: allChildren[categoryId] ?? [],
                    ownQuestionCount: questionCounts[categoryId, default: 0]
                )
            )
        })
    }
    
    func fetchChildren(of parentId: String) throws -> [Category] {
        let descriptor = FetchDescriptor<SDCategory>(
            predicate: #Predicate { $0.parentId == parentId },
            sortBy: [SortDescriptor(\.order)]
        )
        let models = try context.fetch(descriptor)
        return models.map(mapCategory)
    }
    
    // MARK: - Question
    func fetchQuestions(categoryId: String) throws -> [QuizQuestion] {
        let descriptor = FetchDescriptor<SDQuestion>(
            predicate: #Predicate { $0.categoryId == categoryId }
        )
        let models = try context.fetch(descriptor)
        return models.map(mapQuestion)
    }

    // MARK: - Category Progress
    func fetchProgressByCategory(categoryIds: [String]) throws -> [String: CategoryProgress] {
        guard !categoryIds.isEmpty else { return [:] }

        let categoryChildren = try childrenByCategory()
        let questions = try context.fetch(FetchDescriptor<SDQuestion>())
        let questionIdsByCategory = questions.reduce(into: [String: Set<String>]()) { result, question in
            result[question.categoryId, default: []].insert(question.id)
        }

        var questionIdsByRequestedCategory: [String: Set<String>] = [:]
        var allQuestionIds = Set<String>()

        for categoryId in categoryIds {
            let descendantIds = collectCategoryIdsRecursively(
                categoryId: categoryId,
                childrenByCategory: categoryChildren
            )
            let questionIds = descendantIds.reduce(into: Set<String>()) { result, descendantId in
                result.formUnion(questionIdsByCategory[descendantId, default: []])
            }
            questionIdsByRequestedCategory[categoryId] = questionIds
            allQuestionIds.formUnion(questionIds)
        }

        let solvedQuestionIds = try fetchSolvedQuestionIds(in: allQuestionIds)

        return Dictionary(uniqueKeysWithValues: categoryIds.map { categoryId in
            let questionIds = questionIdsByRequestedCategory[categoryId, default: []]
            let solvedCount = questionIds.intersection(solvedQuestionIds).count
            return (
                categoryId,
                CategoryProgress(solvedCount: solvedCount, totalCount: questionIds.count)
            )
        })
    }

    // MARK: - Progress
    func fetchSolvedQuestionIds(categoryId: String) throws -> Set<String> {
        let questions = try fetchQuestions(categoryId: categoryId)
        return try fetchSolvedQuestionIds(in: Set(questions.map(\.id)))
    }

    func fetchProgress(questionId: String) throws -> QuestionProgress? {
        let descriptor = FetchDescriptor<SDQuestionProgress>(
            predicate: #Predicate { $0.questionId == questionId }
        )
        guard let p = try context.fetch(descriptor).first else { return nil }
        
        return QuestionProgress(
            questionId: p.questionId,
            correctCount: p.correctCount,
            wrongCount: p.wrongCount,
            lastAnsweredAt: p.lastAnsweredAt,
            isFavorite: p.isFavorite,
            needsReview: p.needsReview
        )
    }
    
    func saveAnswer(
        questionId: String,
        selectedChoiceId: String,
        isCorrect: Bool
    ) throws {
        let progress = try getOrCreateProgress(questionId: questionId)
        
        if isCorrect {
            progress.correctCount += 1
            progress.needsReview = false
        } else {
            progress.wrongCount += 1
            progress.needsReview = true
        }
        progress.lastAnsweredAt = Date()
        progress.updatedAt = Date()
        
        let history = SDAnswerHistory(
            questionId: questionId,
            selectedChoiceId: selectedChoiceId,
            isCorrect: isCorrect
        )
        context.insert(history)
        
        try context.save()
        progressSubject.send()
    }
    
    func toggleFavorite(questionId: String) throws {
        let progress = try getOrCreateProgress(questionId: questionId)
        progress.isFavorite.toggle()
        progress.updatedAt = Date()
        try context.save()
        progressSubject.send()
    }
    
    // MARK: - Review
    func fetchReviewQuestions() throws -> [QuizQuestion] {
        let progressDescriptor = FetchDescriptor<SDQuestionProgress>(
            predicate: #Predicate { $0.needsReview == true }
        )
        let reviewProgress = try context.fetch(progressDescriptor)
        let ids = Set(reviewProgress.map(\.questionId))
        guard !ids.isEmpty else { return [] }
        
        let questionIds = Array(ids)
        let questionDescriptor = FetchDescriptor<SDQuestion>(
            predicate: #Predicate { questionIds.contains($0.id) }
        )
        let questions = try context.fetch(questionDescriptor)
        
        return questions.map(mapQuestion)
    }
    
    // MARK: - Helpers
    private func getOrCreateProgress(questionId: String) throws -> SDQuestionProgress {
        let descriptor = FetchDescriptor<SDQuestionProgress>(
            predicate: #Predicate { $0.questionId == questionId }
        )
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        
        let new = SDQuestionProgress(questionId: questionId)
        context.insert(new)
        return new
    }

    private func countQuestions(categoryId: String) throws -> Int {
        try context.fetchCount(
            FetchDescriptor<SDQuestion>(
                predicate: #Predicate { $0.categoryId == categoryId }
            )
        )
    }

    private func questionCountsByCategory() throws -> [String: Int] {
        try context.fetch(FetchDescriptor<SDQuestion>())
            .reduce(into: [String: Int]()) { result, question in
                result[question.categoryId, default: 0] += 1
            }
    }

    private func childrenByCategory() throws -> [String: [String]] {
        try context.fetch(FetchDescriptor<SDCategory>())
            .reduce(into: [String: [String]]()) { result, category in
                guard let parentId = category.parentId else { return }
                result[parentId, default: []].append(category.id)
            }
    }

    private func collectCategoryIdsRecursively(
        categoryId: String,
        childrenByCategory: [String: [String]]
    ) -> Set<String> {
        var result: Set<String> = [categoryId]
        var stack = childrenByCategory[categoryId, default: []]

        while let next = stack.popLast() {
            guard result.insert(next).inserted else { continue }
            stack.append(contentsOf: childrenByCategory[next, default: []])
        }

        return result
    }

    private func fetchSolvedQuestionIds(in questionIds: Set<String>) throws -> Set<String> {
        guard !questionIds.isEmpty else { return [] }

        let ids = Array(questionIds)
        let descriptor = FetchDescriptor<SDQuestionProgress>(
            predicate: #Predicate {
                ids.contains($0.questionId) && $0.correctCount > 0
            }
        )
        let solvedProgress = try context.fetch(descriptor)

        return Set(solvedProgress.map(\.questionId))
    }

    private func makeChoices(for question: QuizQuestion) -> [SDChoice] {
        question.choices.enumerated().map { idx, choice in
            SDChoice(
                id: "\(question.id)::\(choice.id)",
                questionId: question.id,
                text: choice.text,
                order: idx
            )
        }
    }

    private func syncChoices(for model: SDQuestion, with seedQuestion: QuizQuestion) {
        var choicesById = Dictionary(uniqueKeysWithValues: model.choices.map { ($0.id, $0) })
        let seedChoiceIds = Set(seedQuestion.choices.map { "\(seedQuestion.id)::\($0.id)" })

        for (idx, choice) in seedQuestion.choices.enumerated() {
            let globalChoiceId = "\(seedQuestion.id)::\(choice.id)"

            if let existing = choicesById[globalChoiceId] {
                existing.questionId = seedQuestion.id
                existing.text = choice.text
                existing.order = idx
            } else {
                let newChoice = SDChoice(
                    id: globalChoiceId,
                    questionId: seedQuestion.id,
                    text: choice.text,
                    order: idx
                )
                model.choices.append(newChoice)
                choicesById[globalChoiceId] = newChoice
            }
        }

        let removedChoices = model.choices.filter { !seedChoiceIds.contains($0.id) }
        model.choices.removeAll { !seedChoiceIds.contains($0.id) }

        for choice in removedChoices {
            context.delete(choice)
        }
    }

    private static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }
    
    private func mapCategory(_ model: SDCategory) -> Category {
        Category(
            id: model.id,
            name: model.name,
            parentId: model.parentId,
            order: model.order,
            level: model.level
        )
    }
    
    private func mapQuestion(_ q: SDQuestion) -> QuizQuestion {
        let sortedChoices = q.choices.sorted { $0.order < $1.order }
        
        return QuizQuestion(
            id: q.id,
            categoryId: q.categoryId,
            type: QuestionType(rawValue: q.typeRaw) ?? .basic,
            title: q.title,
            body: q.body,
            codeSnippet: q.codeSnippet,
            choices: sortedChoices.map {
                QuizChoice(id: $0.id, text: $0.text) // グローバルIDで返す
            },
            correctChoiceId: q.correctChoiceId, // グローバルID
            explanation: q.explanation,
            explanationContent: q.explanationContent,
            difficulty: q.difficulty,
            tags: q.tags
        )
    }
}
