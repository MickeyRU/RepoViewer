import Foundation

/// Главная модель репозитория для работы внутри приложения
struct Repo: Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String?
    let stars: Int
    let forks: Int
    let updatedAt: Date
    let owner: Owner
    
    var isHighlighted: Bool = false
    
    static func == (lhs: Repo, rhs: Repo) -> Bool {
        lhs.id == rhs.id
    }
}

extension Repo {
    init(apiModel: RepoResponseItem) {
        self.id = apiModel.id
        self.name = apiModel.name
        self.description = apiModel.description
        self.stars = apiModel.stargazersCount
        self.forks = apiModel.forks
        self.updatedAt = apiModel.updatedAt
        self.owner = Owner(avatarUrl: apiModel.owner.avatarUrl)
    }
}

extension Repo {
    init(repository: Repository) {
        self.id = repository.id
        self.name = repository.name
        self.description = repository.repoDescription
        self.stars = repository.stars
        self.forks = repository.forks
        self.updatedAt = repository.updatedAt
        self.owner = Owner(avatarUrl: repository.repoAvatarUrl)
        self.isHighlighted = repository.isHighlighted
    }
}

extension Repo {
    func withHighlighted(from other: Repo) -> Repo {
        var updatedRepo = self
        updatedRepo.isHighlighted = other.isHighlighted
        return updatedRepo
    }
}

/// DateFormatter - Extension
extension DateFormatter {
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
