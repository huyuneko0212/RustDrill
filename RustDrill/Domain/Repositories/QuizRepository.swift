//
//  QuizRepository.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation
import Combine

struct CategoryNodeState {
    let children: [Category]
    let ownQuestionCount: Int

    var isLeaf: Bool {
        children.isEmpty
    }
}

@MainActor
protocol QuestionCatalogRepository {
    func fetchRootCategories() throws -> [Category]
    func fetchCategory(categoryId: String) throws -> Category?
    func fetchChildren(of parentId: String) throws -> [Category]
    func fetchCategoryNodeState(categoryId: String) throws -> CategoryNodeState
    func fetchCategoryNodeStates(categoryIds: [String]) throws -> [String: CategoryNodeState]
    func fetchQuestions(categoryId: String) throws -> [QuizQuestion]
}

@MainActor
protocol ProgressRepository {
    var progressDidChange: AnyPublisher<Void, Never> { get }

    func fetchProgress(questionId: String) throws -> QuestionProgress?
    func fetchProgressByCategory(categoryIds: [String]) throws -> [String: CategoryProgress]
    func fetchResumeQuestion() throws -> QuizQuestion?
    func recordLastPresentedQuestion(questionId: String) throws
    func saveAnswer(questionId: String, selectedChoiceId: String, isCorrect: Bool) throws
    func toggleFavorite(questionId: String) throws
    func fetchSolvedQuestionIds(categoryId: String) throws -> Set<String>
}

@MainActor
protocol ReviewRepository {
    func fetchReviewQuestions() throws -> [QuizQuestion]
}

@MainActor
protocol SeedService {
    func seedIfNeeded() throws
}

typealias QuizRepository = QuestionCatalogRepository & ProgressRepository & ReviewRepository & SeedService
