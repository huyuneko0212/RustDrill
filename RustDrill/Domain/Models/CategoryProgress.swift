//
//  CategoryProgress.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import Foundation

struct CategoryProgress: Hashable {
    let solvedCount: Int
    let totalCount: Int
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(solvedCount) / Double(totalCount)
    }
}
