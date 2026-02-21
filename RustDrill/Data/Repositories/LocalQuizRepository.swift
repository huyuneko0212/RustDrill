import Foundation
import SwiftData

final class LocalQuizRepository: QuizRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Seed
    func seedIfNeeded() throws {
        let descriptor = FetchDescriptor<SDQuestion>()
        let count = try context.fetchCount(descriptor)
        if count > 0 { return }

        let seed = try SeedLoader.loadQuestionsJSON()

        // Categories
        for c in seed.categories {
            let model = SDCategory(
                id: c.id,
                name: c.name,
                parentId: c.parentId,
                order: c.order,
                level: c.level
            )
            context.insert(model)
        }

        // Questions + Choices
        for q in seed.questions {
            let sdChoices: [SDChoice] = q.choices.enumerated().map {
                idx,
                choice in
                let globalChoiceId = "\(q.id)::\(choice.id)"
                return SDChoice(
                    id: globalChoiceId,
                    questionId: q.id,
                    text: choice.text,
                    order: idx
                )
            }

            let question = SDQuestion(
                id: q.id,
                categoryId: q.categoryId,
                typeRaw: q.type.rawValue,
                title: q.title,
                body: q.body,
                codeSnippet: q.codeSnippet,
                correctChoiceId: "\(q.id)::\(q.correctChoiceId)",  // ← ここ重要
                explanation: q.explanation,
                difficulty: q.difficulty,
                tags: q.tags,
                choices: sdChoices
            )

            context.insert(question)
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

        return models.map { q in
            let sortedChoices = q.choices.sorted { $0.order < $1.order }
            return QuizQuestion(
                id: q.id,
                categoryId: q.categoryId,
                type: QuestionType(rawValue: q.typeRaw) ?? .basic,
                title: q.title,
                body: q.body,
                codeSnippet: q.codeSnippet,
                choices: sortedChoices.map {
                    QuizChoice(id: $0.id, text: $0.text)
                },
                correctChoiceId: q.correctChoiceId,
                explanation: q.explanation,
                difficulty: q.difficulty,
                tags: q.tags
            )
        }
    }

    // MARK: - Progress
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
    }

    func toggleFavorite(questionId: String) throws {
        let progress = try getOrCreateProgress(questionId: questionId)
        progress.isFavorite.toggle()
        progress.updatedAt = Date()
        try context.save()
    }

    // MARK: - Review
    func fetchReviewQuestions() throws -> [QuizQuestion] {
        let progressDescriptor = FetchDescriptor<SDQuestionProgress>(
            predicate: #Predicate { $0.needsReview == true }
        )
        let reviewProgress = try context.fetch(progressDescriptor)
        let ids = Set(reviewProgress.map(\.questionId))
        guard !ids.isEmpty else { return [] }

        let questionDescriptor = FetchDescriptor<SDQuestion>()
        let allQuestions = try context.fetch(questionDescriptor)

        return
            allQuestions
            .filter { ids.contains($0.id) }
            .map { q in
                let sortedChoices = q.choices.sorted { $0.order < $1.order }
                return QuizQuestion(
                    id: q.id,
                    categoryId: q.categoryId,
                    type: QuestionType(rawValue: q.typeRaw) ?? .basic,
                    title: q.title,
                    body: q.body,
                    codeSnippet: q.codeSnippet,
                    choices: sortedChoices.map {
                        QuizChoice(id: $0.id, text: $0.text)
                    },
                    correctChoiceId: q.correctChoiceId,
                    explanation: q.explanation,
                    difficulty: q.difficulty,
                    tags: q.tags
                )
            }
    }

    // MARK: - Helpers
    private func getOrCreateProgress(questionId: String) throws
        -> SDQuestionProgress
    {
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

    private func mapCategory(_ model: SDCategory) -> Category {
        Category(
            id: model.id,
            name: model.name,
            parentId: model.parentId,
            order: model.order,
            level: model.level
        )
    }
}
