import XCTest
import SwiftData
@testable import RepoViewer

final class RepoListViewModelTests: XCTestCase {
    private var viewModel: RepoListViewModel!
    private var mockUseCase: MockFetchReposUseCase!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockUseCase = MockFetchReposUseCase()
        
        await MainActor.run {
            viewModel = RepoListViewModel(fetchReposUseCase: mockUseCase)
        }
    }
    
    override func tearDown() async throws {
        await MainActor.run {
            viewModel = nil
        }
        mockUseCase = nil
        try await super.tearDown()
    }
}

// MARK: - Helper Functions
@MainActor
func createMockContext() throws -> ModelContext {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try ModelContainer(for: Repository.self, configurations: configuration)
    return modelContainer.mainContext
}


// MARK: - ViewState Tests
extension RepoListViewModelTests {
    func testInitialStateWithEmptyReposAndEmptyQuery() async {
        // Arrange
        mockUseCase.mockRepositories = []
        await MainActor.run {
            viewModel.searchQuery = ""
        }
        
        // Act
        await viewModel.refresh()
        
        // Assert
        await MainActor.run {
            XCTAssertEqual(viewModel?.state, .idle, "State should be empty when no repositories are fetched.")
            XCTAssertEqual(viewModel?.repos.count, 0, "Repos should be empty.")
        }
    }
    
    func testEmptyReposWithNonEmptyQuery() async {
        // Arrange
        mockUseCase.mockRepositories = []
        await MainActor.run {
            viewModel.searchQuery = "test"
        }
        
        // Act
        await viewModel.refresh()
        
        // Assert
        await MainActor.run {
            XCTAssertEqual(viewModel.state, .empty, "State should be empty when no repositories are fetched but searchQuery is not empty.")
            XCTAssertEqual(viewModel.repos.count, 0, "Repos should still be empty.")
        }
    }
    
    func testStateChangesToLoadedWhenDataFetched() async {
        // Arrange
        let mockRepos = [
            Repo(id: 1, name: "Repo 1", description: nil, stars: 10, forks: 5, updatedAt: Date(), owner: Owner(avatarUrl: "url1")),
            Repo(id: 2, name: "Repo 2", description: "Description", stars: 20, forks: 10, updatedAt: Date(), owner: Owner(avatarUrl: "url2"))
        ]
        mockUseCase.mockRepositories = mockRepos
        
        // Act
        await viewModel.refresh()
        
        // Assert
        await MainActor.run {
            XCTAssertEqual(viewModel.state, .loaded, "State should be loaded when data is successfully fetched.")
            XCTAssertEqual(viewModel.repos.count, 2, "Repos count should match the fetched data.")
        }
    }
    //
    func testStateWithHighlightedRepos() async {
        // Arrange
        let mockRepos = [
            Repo(id: 1, name: "Repo 1", description: nil, stars: 10, forks: 5, updatedAt: Date(), owner: Owner(avatarUrl: "url1"), isHighlighted: true),
            Repo(id: 2, name: "Repo 2", description: nil, stars: 15, forks: 8, updatedAt: Date(), owner: Owner(avatarUrl: "url2"), isHighlighted: false),
            Repo(id: 3, name: "Repo 3", description: nil, stars: 5, forks: 2, updatedAt: Date(), owner: Owner(avatarUrl: "url3"), isHighlighted: true)
        ]
        mockUseCase.mockRepositories = mockRepos
        await MainActor.run {
            viewModel.showOnlyHighlighted = true
        }
        
        // Act
        await viewModel.refresh()
        
        // Assert
        await MainActor.run {
            XCTAssertEqual(viewModel.state, .loaded, "State should be loaded when highlighted repositories are present.")
            XCTAssertEqual(viewModel.repos.count, 2, "Repos should contain only the highlighted repositories.")
            XCTAssertTrue(viewModel.repos.allSatisfy { $0.isHighlighted }, "All repositories should be highlighted.")
        }
    }
}

// MARK: - Delete REPO Tests
extension RepoListViewModelTests {
    func testDeleteRepository() async {
        // Arrange
        let mockRepos = [
            Repo(id: 1, name: "Repo 1", description: nil, stars: 10, forks: 5, updatedAt: Date(), owner: Owner(avatarUrl: "url1")),
            Repo(id: 2, name: "Repo 2", description: "Description", stars: 20, forks: 10, updatedAt: Date(), owner: Owner(avatarUrl: "url2"))
        ]
        mockUseCase.mockRepositories = mockRepos
        
        await MainActor.run {
            viewModel.repos = mockRepos
        }
        
        // Act
        await viewModel.delete(at: 0)
        
        // Assert
        await MainActor.run {
            XCTAssertEqual(viewModel.repos.count, 1, "There should be one repository left after deletion.")
            XCTAssertEqual(viewModel.repos.first?.name, "Repo 2", "Remaining repository should be 'Repo 2'.")
        }
    }
}

// MARK: - UPDATE REPO Tests
extension RepoListViewModelTests {
    func testUpdateRepository() async {
        // Arrange
        let initialRepo = Repo(id: 1, name: "Repo 1", description: nil, stars: 10, forks: 5, updatedAt: Date(), owner: Owner(avatarUrl: "url1"))
        
        mockUseCase.mockRepositories = [initialRepo]
        
        await MainActor.run {
            viewModel.repos = [initialRepo]
        }
        
        // Act
        await viewModel.highlight(at: 0)
        
        // Assert
        await MainActor.run {
            XCTAssertEqual(viewModel.repos.first?.isHighlighted, true, "The repository should be highlighted after toggle.")
        }
    }
}
