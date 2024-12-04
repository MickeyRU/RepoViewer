import Foundation

struct GitHubResponse: Decodable {
    let items: [RepoResponseItem]
}
