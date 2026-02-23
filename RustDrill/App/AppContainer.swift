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
    let adGateService: AdGateService
    
    init(repository: QuizRepository, adGateService: AdGateService? = nil) {
        self.repository = repository
        self.adGateService = adGateService ?? FrequencyControlledAdGateService(frequency: 3)
    }
}
