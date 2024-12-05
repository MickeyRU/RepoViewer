import Foundation
import SwiftData

/// Главная модель репозитория для локального хранения в SwiftData
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

extension Repository {
    convenience init(repo: Repo) {
        self.init(
            id: repo.id,
            name: repo.name,
            repoDescription: repo.description,
            stars: repo.stars,
            forks: repo.forks,
            updatedAt: repo.updatedAt,
            repoAvatarUrl: repo.owner.avatarUrl,
            isHighlighted: repo.isHighlighted
        )
    }
}
