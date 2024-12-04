import Foundation

enum LocalRepoStorageError: Error, LocalizedError {
    case repositoryNotFound
    case saveFailed
    case deleteFailed
    case updateFailed
    case custom(message: String)
    
    var errorDescription: String? {
        switch self {
        case .repositoryNotFound:
            return "The requested repository was not found."
        case .saveFailed:
            return "Failed to save repository."
        case .deleteFailed:
            return "Failed to delete repository."
        case .updateFailed:
            return "Failed to update repository."
        case .custom(let message):
            return message
        }
    }
}
