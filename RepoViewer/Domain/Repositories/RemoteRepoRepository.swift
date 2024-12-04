import Foundation

protocol RemoteRepoRepository{
    func fetchRemoteRepos(query: String, page: Int, sortOption: SortOption) async throws -> [Repo]
}
