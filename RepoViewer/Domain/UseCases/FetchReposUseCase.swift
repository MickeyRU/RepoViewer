import Foundation

protocol FetchReposUseCase {
    func fetchRepositories(query: String, page: Int, sortOption: SortOption) async throws -> [Repo]
    func deleteRepository(_ repo: Repo) async throws
    func updateRepository(_ repo: Repo) async throws
}
