import Foundation

enum GitHubAPIError: Error, LocalizedError {
    case apiError(APIError)
    case invalidURL
    case badResponse
    case decodingError
    case custom(message: String)
    
    var errorDescription: String? {
        switch self {
        case .apiError(let apiError):
            return apiError.message
        case .invalidURL:
            return "Invalid URL provided."
        case .badResponse:
            return "The server response was not valid."
        case .decodingError:
            return "Failed to decode the response."
        case .custom(let message):
            return message
        }
    }
}
