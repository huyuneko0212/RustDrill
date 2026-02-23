//
//  QuizViewModel.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation
import Combine

@MainActor
final class QuizViewModel: ObservableObject {
    enum Source {
        case category(String)
        case review
    }
    
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var selectedChoiceId: String?
    @Published var submittedResult: QuizResult?
    @Published var errorMessage: String?
    
    private let repository: QuizRepository
    private let source: Source
    
    init(repository: QuizRepository, source: Source) {
        self.repository = repository
        self.source = source
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
        !questions.isEmpty && currentIndex == questions.count - 1
    }
    
    func loadQuestions() {
        do {
            switch source {
            case .category(let categoryId):
                questions = try repository.fetchQuestions(categoryId: categoryId)
            case .review:
                questions = try repository.fetchReviewQuestions()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func selectChoice(_ choiceId: String) {
        guard submittedResult == nil else { return }
        selectedChoiceId = choiceId
    }
    
    func submit() {
        guard let q = currentQuestion, let selected = selectedChoiceId else { return }
        
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
