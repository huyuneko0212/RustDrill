//
//  SDCategory.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation
import SwiftData

@Model
final class SDCategory {
    @Attribute(.unique) var id: String
    var name: String
    var parentId: String?
    var order: Int
    var level: Int

    init(
        id: String,
        name: String,
        parentId: String?,
        order: Int,
        level: Int
    ) {
        self.id = id
        self.name = name
        self.parentId = parentId
        self.order = order
        self.level = level
    }
}
