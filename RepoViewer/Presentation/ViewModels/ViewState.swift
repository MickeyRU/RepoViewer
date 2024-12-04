import Foundation

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded), (.empty, .empty), (.error, .error):
            return true
        default:
            return false
        }
    }
}
