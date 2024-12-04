import Foundation

/// Фасад для работы с локальным/ удаленным репозиторием данных
final class RepoRepositoryFacade: RepoRepository {
    private let remoteRepository: RemoteRepoRepository
    private let localRepository: LocalRepoRepository
    
    // Кэш для хранения данных
    private var cachedRepos: [Int: Repo] = [:]
    
    init(remoteRepository: RemoteRepoRepository, localRepository: LocalRepoRepository) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
    }
    
    func fetchRepos(query: String, page: Int, sortOption: SortOption) async throws -> [Repo] {
        if query.isEmpty {
            print("Loading from local repository...")
            
            
            // Если кэш пустой, загружаем данные из локального репозитория
            if cachedRepos.isEmpty {
                let localData = try await localRepository.fetchLocalRepos(sortOption: sortOption)
                cachedRepos = Dictionary(uniqueKeysWithValues: localData.map { ($0.id, $0) })
            }
            
            print("Cached data count: \(cachedRepos.count)")
            return Array(cachedRepos.values.sorted(by: sortOption.sortingFunction))
        } else {
            print("Fetching from remote API...")
            
            let remoteData = try await remoteRepository.fetchRemoteRepos(query: query, page: page, sortOption: sortOption)
            
            do {
                try await localRepository.saveReposToLocal(remoteData)
                print("Remote data saved to local storage.")
                for repo in remoteData {
                    cachedRepos[repo.id] = repo
                }
            } catch {
                print("Failed to save remote data to local storage: \(error.localizedDescription)")
                throw LocalRepoStorageError.saveFailed
            }
            
            print("Remote data count: \(remoteData.count)")
            return remoteData
        }
    }
    
    func deleteRepo(_ repo: Repo) async throws {
        print("Deleting repository with id \(repo.id)...")
        do {
            try await localRepository.deleteRepo(repo)
            cachedRepos[repo.id] = nil
            print("Repository deleted successfully.")
        } catch {
            print("Failed to delete repository: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateRepo(_ repo: Repo) async throws {
        print("Updating repository with id \(repo.id)...")
        do {
            try await localRepository.updateRepo(repo)
            cachedRepos[repo.id] = repo
            print("Repository Updating successfully.")
        } catch {
            print("Failed to Updating repository: \(error.localizedDescription)")
            throw error
        }
    }
}
