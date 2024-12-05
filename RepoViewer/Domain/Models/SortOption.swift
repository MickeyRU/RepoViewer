import Foundation

/// Сортировка репозиториев - каждый кейс является кнопкой в Picker на экране
enum SortOption: String, CaseIterable {
    case basic = ""
    case stars
    case forks
    case updated
    
    var sortingFunction: (Repo, Repo) -> Bool {
        switch self {
        case .basic:
            return { $0.name < $1.name }
        case .stars:
            return { $0.stars > $1.stars }
        case .forks:
            return { $0.forks > $1.forks }
        case .updated:
            return { $0.updatedAt > $1.updatedAt }
        }
    }
    
    var displayName: String {
        switch self {
        case .basic:
            return "Default"
        case .stars:
            return "Stars"
        case .forks:
            return "Forks"
        case .updated:
            return "Updated"
        }
    }
}
