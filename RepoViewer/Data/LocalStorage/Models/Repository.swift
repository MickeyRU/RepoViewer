import Foundation
import SwiftData

@Model
final class Repository {
    var id: Int
    var name: String
    var repoDescription: String?
    var stars: Int
    var forks: Int
    var updatedAt: Date
    var repoAvatarUrl: String
    var isHighlighted: Bool
    
    init(id: Int,
         name: String,
         repoDescription: String?,
         stars: Int,
         forks: Int,
         updatedAt: Date,
         repoAvatarUrl: String,
         isHighlighted: Bool = false)
    {
        self.id = id
        self.name = name
        self.repoDescription = repoDescription
        self.stars = stars
        self.forks = forks
        self.updatedAt = updatedAt
        self.repoAvatarUrl = repoAvatarUrl
        self.isHighlighted = isHighlighted
    }
}
