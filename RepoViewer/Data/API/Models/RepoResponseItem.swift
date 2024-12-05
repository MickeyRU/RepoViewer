import Foundation

/// Объект, который прилетает с Json - репозиторий с GitHub
struct RepoResponseItem: Decodable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let forks: Int
    let updatedAt: Date
    let owner: OwnerResponse
}
