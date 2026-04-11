//
//  SeedLoader.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

enum SeedLoader {
    static func loadQuestionsJSONData() throws -> Data {
        let url = try questionsJSONURL()
        return try Data(contentsOf: url)
    }

    static func loadQuestionsJSON() throws -> SeedData {
        let data = try loadQuestionsJSONData()
        return try JSONDecoder().decode(SeedData.self, from: data)
    }

    private static func questionsJSONURL() throws -> URL {
        let bundle = Bundle.main

        let directURL = bundle.url(forResource: "questions", withExtension: "json")
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

        return url
    }
}
