//
//  HomeViewModel.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var errorMessage: String?

    private let repository: QuizRepository

    init(repository: QuizRepository) {
        self.repository = repository
        load()
    }

    func load() {
        do {
            categories = try repository.fetchRootCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
