import Foundation

struct RepoResponseItem: Decodable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let forks: Int
    let updatedAt: Date
    let owner: OwnerResponse
}
