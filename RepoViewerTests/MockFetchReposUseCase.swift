@testable import RepoViewer

final class MockFetchReposUseCase: FetchReposUseCase {
    var mockRepositories: [Repo] = []
    var fetchCallCount = 0
    var deleteCallCount = 0
    var updateCallCount = 0

    func fetchRepositories(query: String, page: Int, sortOption: SortOption) async throws -> [Repo] {
        fetchCallCount += 1
        return mockRepositories
    }

    func deleteRepository(_ repo: Repo) async throws {
        deleteCallCount += 1
    }

    func updateRepository(_ repo: Repo) async throws {
        updateCallCount += 1
    }

    func resetFlags() {
        fetchCallCount = 0
        deleteCallCount = 0
        updateCallCount = 0
    }
}
