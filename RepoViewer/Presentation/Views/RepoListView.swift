import SwiftUI

struct RepoListView: View {
    @ObservedObject var viewModel: RepoListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            SearchBarWithToggle(searchQuery: $viewModel.searchQuery, isHighlightedOnly: $viewModel.showOnlyHighlighted)
            
            SortPicker(selectedSortOption: $viewModel.sortOption)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.repos.indices, id: \.self) { index in
                        let repo = viewModel.repos[index]
                        RepoCellView(
                            viewModel: RepoCellViewModel(
                                repo: repo,
                                onHighlight: { viewModel.handleHighlight(at: index) },
                                onDelete: { viewModel.handleDelete(at: index) }
                            )
                        )
                        .onAppear {
                            if index == viewModel.repos.count - 10 {
                                viewModel.handleLoadNextPage()
                            }
                        }
                    }
                    StateContentView(state: viewModel.state) {
                        viewModel.handleRefresh()
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding()
    }
}

struct StateContentView: View {
    let state: ViewState
    let onRetry: () -> Void 
    
    var body: some View {
        switch state {
        case .idle:
            Text("Enter a search query to find repositories.")
                .foregroundColor(.secondary)
                .padding()
        case .loading:
            ProgressView()
                .padding()
        case .empty:
            Text("No repositories found.")
                .foregroundColor(.secondary)
                .padding()
        case .error(let message):
            ErrorView(message: message, retryAction: onRetry)
        default:
            EmptyView()
        }
    }
}
