import Foundation

protocol LocalRepoRepository {
    func fetchLocalRepos(sortOption: SortOption) async throws -> [Repo]
    func saveReposToLocal(_ repos: [Repo]) async throws
    func deleteRepo(_ repo: Repo) async throws
    func updateRepo(_ repo: Repo) async throws
}
