import SwiftUI
import Combine

@MainActor
final class RepoListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var state: ViewState = .idle
    @Published var repos: [Repo] = []
    @Published var searchQuery: String = ""
    @Published var sortOption: SortOption = .basic
    @Published var showOnlyHighlighted: Bool = false
    
    // MARK: - Dependencies
    private let fetchReposUseCase: FetchReposUseCase
    
    // MARK: - Private Properties
    private var currentPage: Int = 1
    private var isLastPage: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(fetchReposUseCase: FetchReposUseCase) {
        self.fetchReposUseCase = fetchReposUseCase
        setupBindings()
        Task { await loadInitialData() }
    }
    
    // MARK: - Public Methods
    func loadNextPage() async {
        guard state != .loading, !isLastPage else { return }
        currentPage += 1
        await fetchRepos()
    }
    
    func refresh() async {
        resetData()
        await fetchRepos()
    }
    
    func delete(at index: Int) async {
        guard repos.indices.contains(index) else { return }
        let repoToDelete = repos[index]
        
        do {
            try await fetchReposUseCase.deleteRepository(repoToDelete)
            repos.remove(at: index)
            state = repos.isEmpty ? .empty : .loaded
        } catch {
            state = .error("Failed to delete repository: \(error.localizedDescription)")
        }
        
    }
    
    func highlight(at index: Int) async {
        guard repos.indices.contains(index) else { return }
        repos[index].isHighlighted.toggle()
        
        let repo = repos[index]
        do {
            try await fetchReposUseCase.updateRepository(repo)
        } catch {
            state = .error("Failed to update repository: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        $sortOption
            .dropFirst()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
            .store(in: &cancellables)
        
        $searchQuery
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
            .store(in: &cancellables)
        
        $showOnlyHighlighted
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    self?.searchQuery = ""
                    await self?.refresh()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() async {
        await fetchRepos()
    }
    
    private func fetchRepos() async {
        state = .loading
        
        do {
            let fetchedRepos = try await fetchReposUseCase.fetchRepositories(query: searchQuery,
                                                                             page: currentPage,
                                                                             sortOption: sortOption)
            
            let filteredRepos = showOnlyHighlighted ? fetchedRepos.filter { $0.isHighlighted } : fetchedRepos
            
            
            if filteredRepos.isEmpty {
                state = searchQuery.isEmpty && repos.isEmpty ? .idle : .empty
                isLastPage = true
            } else {
                if currentPage == 1 {
                    repos = filteredRepos
                } else {
                    repos.append(contentsOf: filteredRepos)
                }
                state = .loaded
            }
        } catch {
            state = .error("Failed to fetch repositories: \(error.localizedDescription)")
        }
    }
    
    private func resetData() {
        repos.removeAll()
        currentPage = 1
        isLastPage = false
    }
}



// MARK: - Extension
extension RepoListViewModel {
    func handleHighlight(at index: Int) {
        Task { await highlight(at: index) }
    }
    
    func handleDelete(at index: Int) {
        Task { await delete(at: index) }
    }
    
    func handleLoadNextPage() {
        Task { await loadNextPage() }
    }
    
    func handleRefresh() {
        Task { await refresh() }
    }
}
