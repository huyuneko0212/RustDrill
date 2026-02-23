//
//  AdGateCounterStore.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import Foundation

protocol AdGateCounterStore {
    func incrementAndGetExplanationTapCount() -> Int
    func resetExplanationTapCount()
    func currentExplanationTapCount() -> Int
}

final class UserDefaultsAdGateCounterStore: AdGateCounterStore {
    private let defaults: UserDefaults
    private let key = "ad_gate_explanation_tap_count"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func incrementAndGetExplanationTapCount() -> Int {
        let next = currentExplanationTapCount() + 1
        defaults.set(next, forKey: key)
        return next
    }
    
    func resetExplanationTapCount() {
        defaults.set(0, forKey: key)
    }
    
    func currentExplanationTapCount() -> Int {
        defaults.integer(forKey: key)
    }
}
