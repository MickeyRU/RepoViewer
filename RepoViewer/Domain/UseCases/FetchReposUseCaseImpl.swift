import Foundation

final class FetchReposUseCaseImpl: FetchReposUseCase {
    private let repository: RepoRepository
    
    init(repository: RepoRepository) {
        self.repository = repository
    }
    
    func fetchRepositories(query: String, page: Int, sortOption: SortOption) async throws -> [Repo] {
        try await repository.fetchRepos(query: query, page: page, sortOption: sortOption)
    }
    
    func deleteRepository(_ repo: Repo) async throws {
        try await repository.deleteRepo(repo)
    }
    
    func updateRepository(_ repo: Repo) async throws {
        try await repository.updateRepo(repo)
    }
}
