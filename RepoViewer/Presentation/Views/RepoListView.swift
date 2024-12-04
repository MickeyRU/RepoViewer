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
                        RepoCellView(viewModel: RepoCellViewModel(repo: repo, onHighlight: {
                            print("onHighlight = \(repo.id)")
                            viewModel.highlight(at: index)

                        }, onDelete: {
                            print("Delete = \(repo.id)")
                            viewModel.delete(at: index)
                        }))
                        .onAppear {
                            if repo == viewModel.repos.suffix(10).first {
                                viewModel.loadNextPage()
                            }
                        }
                    }
                    
                    if viewModel.state == .idle {
                        Text("Enter a search query to find repositories.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                    if viewModel.state == .loading {
                        ProgressView()
                            .padding()
                    }
                    
                    if viewModel.state == .empty {
                        Text("No repositories found.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                    if case .error(let error) = viewModel.state {
                        ErrorView(message: error) {
                            viewModel.refresh()
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding()
    }
}
