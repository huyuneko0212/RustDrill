//
//  AppContainer.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import Foundation
import Combine

@MainActor
final class AppContainer: ObservableObject {
    let repository: QuizRepository
    
    init(repository: QuizRepository) {
        self.repository = repository
    }
}
