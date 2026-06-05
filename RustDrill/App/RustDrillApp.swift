import SwiftUI
import SwiftData

@main
struct RustDrillApp: App {
    private let launchState: AppLaunchState
    
    init() {
        do {
            let modelContainer = try ModelContainer(for:
                                                        SDCategory.self,
                                                    SDQuestion.self,
                                                    SDChoice.self,
                                                    SDQuestionProgress.self,
                                                    SDAnswerHistory.self
            )
            
            let context = ModelContext(modelContainer)
            let repo = LocalQuizRepository(context: context)
            try repo.seedIfNeeded()
            
            launchState = .ready(
                modelContainer: modelContainer,
                appContainer: AppContainer(repository: repo)
            )
        } catch {
            launchState = .failed(message: error.localizedDescription)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            switch launchState {
            case .ready(let modelContainer, let appContainer):
                RootTabView()
                    .environmentObject(appContainer)
                    .modelContainer(modelContainer)
                    .task {
                        await appContainer.startAdsIfNeeded()
                    }

            case .failed(let message):
                AppLaunchErrorView(message: message)
            }
        }
    }
}

private enum AppLaunchState {
    case ready(modelContainer: ModelContainer, appContainer: AppContainer)
    case failed(message: String)
}

private struct AppLaunchErrorView: View {
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("アプリを起動できません", systemImage: "exclamationmark.triangle")
        } description: {
            Text("学習データの読み込み中に問題が発生しました。アプリを再起動しても直らない場合は、アプリを再インストールしてください。")
        } actions: {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
