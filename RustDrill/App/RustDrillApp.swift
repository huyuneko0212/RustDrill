//
//  RustDrillApp.swift
//  Rust Drill
//
//  Created by huyuneko on 2026/02/21.
//

import SwiftData
import SwiftUI

@main
struct RustDrillApp: App {
    let container: ModelContainer
    let dependency: AppDependency

    init() {
        do {
            container = try ModelContainer(
                for:
                    SDCategory.self,
                SDQuestion.self,
                SDChoice.self,
                SDQuestionProgress.self,
                SDAnswerHistory.self
            )

            let context = ModelContext(container)
            let repo = LocalQuizRepository(context: context)
            print("Bundle path:", Bundle.main.bundlePath)
            print("All json:", Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil))
            print("Seed json:", Bundle.main.paths(forResourcesOfType: "json", inDirectory: "Seed"))
            try repo.seedIfNeeded()

            dependency = AppDependency(repository: repo)
        } catch {
            fatalError("Failed to initialize app: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: HomeViewModel(repository: dependency.repository)
            )
        }
        .modelContainer(container)
    }
}
