//
//  SeedDTOs.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

struct SeedData: Codable {
    let categories: [Category]
    let questions: [QuizQuestion]
}
