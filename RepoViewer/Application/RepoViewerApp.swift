import SwiftUI
import SwiftData

@main
struct RepoViewerApp: App {
    private let dependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            RepoListView(viewModel: RepoListViewModel(fetchReposUseCase: dependencies.fetchReposUseCase))
                .modelContainer(dependencies.modelContainer)
        }
    }
}
