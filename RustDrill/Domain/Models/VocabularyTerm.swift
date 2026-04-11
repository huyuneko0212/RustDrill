//
//  VocabularyTerm.swift
//  Rust Drill
//
//  Created by Codex on 2026/04/12.
//

import Foundation

struct VocabularyTerm: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let reading: String
    let description: String
    let example: String?
}
