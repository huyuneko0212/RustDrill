//
//  QuizViewModel.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Combine
import Foundation

@MainActor
final class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var selectedChoiceId: String?
    @Published var submittedResult: QuizResult?
    @Published var errorMessage: String?

    private let repository: QuizRepository
    private let categoryId: String

    init(repository: QuizRepository, categoryId: String) {
        self.repository = repository
        self.categoryId = categoryId
        loadQuestions()
    }

    var currentQuestion: QuizQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var canSubmit: Bool {
        selectedChoiceId != nil && submittedResult == nil
    }

    var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }

    func loadQuestions() {
        do {
            questions = try repository.fetchQuestions(categoryId: categoryId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectChoice(_ choiceId: String) {
        guard submittedResult == nil else { return }
        selectedChoiceId = choiceId
    }

    func submit() {
        guard let q = currentQuestion, let selected = selectedChoiceId else {
            return
        }

        let isCorrect = (selected == q.correctChoiceId)

        do {
            try repository.saveAnswer(
                questionId: q.id,
                selectedChoiceId: selected,
                isCorrect: isCorrect
            )
            submittedResult = QuizResult(
                question: q,
                selectedChoiceId: selected,
                isCorrect: isCorrect
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func nextQuestion() {
        guard !isLastQuestion else { return }
        currentIndex += 1
        selectedChoiceId = nil
        submittedResult = nil
    }
}
