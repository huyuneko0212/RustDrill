//
//  SeedLoader.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

enum SeedLoader {
    static func loadQuestionsJSON() throws -> SeedData {
        let bundle = Bundle.main
        
        // まず通常検索
        let directURL = bundle.url(forResource: "questions", withExtension: "json")
        
        // 念のため一覧からも検索（デバッグ兼フォールバック）
        let allJSONURLs = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        let fallbackURL = allJSONURLs.first { $0.lastPathComponent == "questions.json" }
        
        guard let url = directURL ?? fallbackURL else {
            throw NSError(
                domain: "SeedLoader",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "questions.json not found",
                    "bundlePath": bundle.bundlePath,
                    "jsonFiles": allJSONURLs.map { $0.path }
                ]
            )
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(SeedData.self, from: data)
    }
}
