//
//  Category.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let parentId: String?
    let order: Int
    let level: Int  // 1=大,2=中,3=小
}
