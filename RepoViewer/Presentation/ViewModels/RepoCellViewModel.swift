import SwiftUI

final class RepoCellViewModel: ObservableObject {
    @Published var repo: Repo
    let onHighlight: () -> Void
    let onDelete: () -> Void
    
    init(repo: Repo, onHighlight: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.repo = repo
        self.onHighlight = onHighlight
        self.onDelete = onDelete
    }
    
    func highlight() {
        onHighlight()
    }
    
    func delete() {
        onDelete()
    }
}
