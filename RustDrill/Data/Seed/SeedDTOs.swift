//
//  SeedDTOs.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

struct SeedData: Codable {
    let version: Int
    let categories: [Category]
    let questions: [QuizQuestion]
}

struct VocabularySeedData: Codable {
    let version: Int
    let categories: [VocabularyCategory]
    let terms: [VocabularyTerm]
}
