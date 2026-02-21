//
//  QuizRepository.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

protocol QuizRepository {
    // Category
    func fetchRootCategories() throws -> [Category]
    func fetchChildren(of parentId: String) throws -> [Category]
    
    // Question
    func fetchQuestions(categoryId: String) throws -> [QuizQuestion]
    
    // Progress
    func fetchProgress(questionId: String) throws -> QuestionProgress?
    func saveAnswer(questionId: String, selectedChoiceId: String, isCorrect: Bool) throws
    func toggleFavorite(questionId: String) throws
    
    // Review
    func fetchReviewQuestions() throws -> [QuizQuestion]
    
    // Seed
    func seedIfNeeded() throws
}
