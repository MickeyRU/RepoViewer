import Foundation

protocol GitHubAPIClient {
    func searchRepositories(query: String, page: Int, sortOption: SortOption) async throws -> GitHubResponse
}
