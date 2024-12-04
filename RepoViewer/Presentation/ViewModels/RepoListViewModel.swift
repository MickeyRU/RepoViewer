import SwiftUI
import Combine

@MainActor
final class RepoListViewModel: ObservableObject {
    @Published var state: ViewState = .idle
    @Published var repos: [Repo] = []
    @Published var searchQuery: String = ""
    @Published var sortOption: SortOption = .basic
    @Published var showOnlyHighlighted: Bool = false
    
    private let fetchReposUseCase: FetchReposUseCase
    private var currentPage: Int = 1
    private var isLastPage: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchReposUseCase: FetchReposUseCase) {
        self.fetchReposUseCase = fetchReposUseCase
        observeSortOption()
        observeSearchQuery()
        observeShowOnlyHighlighted()
        fetchRepos()
    }
    
    func loadNextPage() {
        guard state != .loading, !isLastPage else { return }
        currentPage += 1
        fetchRepos()
    }
    
    func refresh() {
        resetData()
        fetchRepos()
    }
    
    func delete(at index: Int) {
        guard repos.indices.contains(index) else { return }
        let repoToDelete = repos[index]
        
        Task {
            do {
                try await fetchReposUseCase.deleteRepository(repoToDelete)
                
                repos.remove(at: index)
                
                if repos.isEmpty {
                    state = .empty
                }
            } catch {
                state = .error("Failed to delete repository: \(error.localizedDescription)")
            }
        }
    }
    
    func highlight(at index: Int) {
        guard repos.indices.contains(index) else { return }
        repos[index].isHighlighted.toggle()
        
        let repo = repos[index]
        Task {
            do {
                try await fetchReposUseCase.updateRepository(repo)
            } catch {
                state = .error("Failed to update repository: \(error.localizedDescription)")
            }
        }
    }
    
    /// Наблюдаем за изменениями сортировки
    private func observeSortOption() {
        $sortOption
            .dropFirst()
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }
    
    /// Наблюдаем за изменениями строки поиска
    private func observeSearchQuery() {
        $searchQuery
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }
    
    /// Наблюдаем за Highlighted
    private func observeShowOnlyHighlighted() {
        $showOnlyHighlighted
            .dropFirst()
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }
    
    
    /// Загружаем данные из UseCase
    private func fetchRepos() {
        state = .loading
        
        Task {
            do {
                var fetchedRepos = try await fetchReposUseCase.fetchRepositories(query: searchQuery, page: currentPage, sortOption: sortOption)
                
                if showOnlyHighlighted {
                    fetchedRepos = fetchedRepos.filter { $0.isHighlighted }
                }
                
                if fetchedRepos.isEmpty {
                    state = searchQuery.isEmpty && repos.isEmpty ? .idle : .empty
                } else {
                    repos = fetchedRepos
                    state = .loaded
                }
            } catch {
                state = .error("Failed to fetch repositories: \(error.localizedDescription)")
            }
        }
    }
    
    private func resetData() {
        repos.removeAll()
        currentPage = 1
        isLastPage = false
    }
}
