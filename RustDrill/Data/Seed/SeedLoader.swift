//
//  SeedLoader.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import Foundation

enum SeedLoader {
    static func loadQuestionsJSONData() throws -> Data {
        let url = try jsonURL(named: "questions")
        return try Data(contentsOf: url)
    }

    static func loadQuestionsJSON() throws -> SeedData {
        let data = try loadQuestionsJSONData()
        return try JSONDecoder().decode(SeedData.self, from: data)
    }

    static func loadVocabularyJSONData() throws -> Data {
        let url = try jsonURL(named: "vocabulary")
        return try Data(contentsOf: url)
    }

    static func loadVocabularyJSON() throws -> VocabularySeedData {
        let data = try loadVocabularyJSONData()
        return try JSONDecoder().decode(VocabularySeedData.self, from: data)
    }

    private static func jsonURL(named name: String) throws -> URL {
        let bundle = Bundle.main

        let fileName = "\(name).json"
        let directURL = bundle.url(forResource: name, withExtension: "json")
        let allJSONURLs = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        let fallbackURL = allJSONURLs.first { $0.lastPathComponent == fileName }

        guard let url = directURL ?? fallbackURL else {
            throw NSError(
                domain: "SeedLoader",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "\(fileName) not found",
                    "bundlePath": bundle.bundlePath,
                    "jsonFiles": allJSONURLs.map { $0.path }
                ]
            )
        }

        return url
    }
}
