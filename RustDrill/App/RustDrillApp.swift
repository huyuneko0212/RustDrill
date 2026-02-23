import SwiftUI
import SwiftData

@main
struct RustDrillApp: App {
    let container: ModelContainer
    @StateObject private var appContainer: AppContainer
    
    init() {
        do {
            let modelContainer = try ModelContainer(for:
                                                        SDCategory.self,
                                                    SDQuestion.self,
                                                    SDChoice.self,
                                                    SDQuestionProgress.self,
                                                    SDAnswerHistory.self
            )
            self.container = modelContainer
            
            let context = ModelContext(modelContainer)
            let repo = LocalQuizRepository(context: context)
            try repo.seedIfNeeded()
            
            _appContainer = StateObject(wrappedValue: AppContainer(repository: repo))
        } catch {
            fatalError("Failed to initialize app: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appContainer)
        }
        .modelContainer(container)
    }
}
