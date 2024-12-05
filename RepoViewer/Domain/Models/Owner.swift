import Foundation

/// Владелец репозитория на GitHub
struct Owner: Equatable {
    let avatarUrl: String
    
    static func == (lhs: Owner, rhs: Owner) -> Bool {
        lhs.avatarUrl == rhs.avatarUrl
    }
}
