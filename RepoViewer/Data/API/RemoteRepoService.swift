import Foundation

final class RemoteRepoService: RemoteRepoRepository {
    private let apiClient: GitHubAPIClient
    
    init(apiClient: GitHubAPIClient) {
        self.apiClient = apiClient
    }
    
    func fetchRemoteRepos(query: String, page: Int, sortOption: SortOption) async throws -> [Repo] {
        let responce = try await apiClient.searchRepositories(query: query, page: page, sortOption: sortOption)
        return responce.items.map { item in
            Repo(apiModel: item)
        }
    }
}
