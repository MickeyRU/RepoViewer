import SwiftUI
import SwiftData

@MainActor
final class AppDependencies {
    let modelContainer: ModelContainer
    let fetchReposUseCase: FetchReposUseCase
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Repository.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        
        let localRepoStorage = LocalRepoStorage(context: modelContainer.mainContext)
        let remoteRepoRepository = RemoteRepoService(apiClient: GitHubAPIClientImpl())
        
        let repoRepositoryFacade = RepoRepositoryFacade(
            remoteRepository: remoteRepoRepository,
            localRepository: localRepoStorage
        )
        
        fetchReposUseCase = FetchReposUseCaseImpl(repository: repoRepositoryFacade)
    }
}
