@testable import RepoViewer

final class MockRepoRepository: RepoRepository {
    var mockRepos: [Repo] = []
    var fetchWasCalled = false
    var deleteWasCalled = false
    var updateWasCalled = false

    func fetchRepos(query: String, page: Int, sortOption: SortOption) async throws -> [Repo] {
        fetchWasCalled = true
        return mockRepos
    }

    func deleteRepo(_ repo: Repo) async throws {
        deleteWasCalled = true
        mockRepos.removeAll { $0.id == repo.id }
    }

    func updateRepo(_ repo: Repo) async throws {
        updateWasCalled = true
        if let index = mockRepos.firstIndex(where: { $0.id == repo.id }) {
            mockRepos[index] = repo
        }
    }

    func resetFlags() {
        fetchWasCalled = false
        deleteWasCalled = false
        updateWasCalled = false
    }
}
