import Foundation

final class GitHubAPIClientImpl: GitHubAPIClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func searchRepositories(query: String, page: Int, sortOption: SortOption) async throws -> GitHubResponse {
        guard let url = makeURL(query: query, page: page, sortOption: sortOption) else {
            throw GitHubAPIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        try validateResponse(response, data: data)
        
        return try decodeResponse(data)
        
    }
}

extension GitHubAPIClientImpl {
    private func makeURL(query: String, page: Int, sortOption: SortOption) -> URL? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var components = URLComponents(string: "https://api.github.com/search/repositories")
        components?.queryItems = [
            URLQueryItem(name: "q", value: encodedQuery),
            URLQueryItem(name: "sort", value: sortOption.rawValue),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "30")
        ]
        return components?.url
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.badResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw GitHubAPIError.apiError(apiError)
            } else {
                throw GitHubAPIError.custom(message: "HTTP Error \(httpResponse.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
            }
        }
    }
    
    private func decodeResponse(_ data: Data) throws -> GitHubResponse {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(GitHubResponse.self, from: data)
        } catch {
            throw GitHubAPIError.decodingError
        }
    }
}
