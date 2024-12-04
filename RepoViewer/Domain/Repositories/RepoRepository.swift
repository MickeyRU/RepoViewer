import Foundation

protocol RepoRepository {
    func fetchRepos(query: String, page: Int, sortOption: SortOption) async throws -> [Repo]
    func deleteRepo(_ repo: Repo) async throws
    func updateRepo(_ repo: Repo) async throws
}
