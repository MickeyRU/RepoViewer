import Foundation

/// Фасад для работы с локальным/ удаленным репозиторием данных
final class RepoRepositoryFacade: RepoRepository {
    private let remoteRepository: RemoteRepoRepository
    private let localRepository: LocalRepoRepository
    
    private var cachedRepos: [Int: Repo] = [:]
    
    init(remoteRepository: RemoteRepoRepository, localRepository: LocalRepoRepository) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
    }
    
    func fetchRepos(query: String, page: Int, sortOption: SortOption) async throws -> [Repo] {
        if query.isEmpty {
            if cachedRepos.isEmpty {
                let localData = try await localRepository.fetchLocalRepos(sortOption: sortOption)
                cachedRepos = Dictionary(uniqueKeysWithValues: localData.map { ($0.id, $0) })
            }
            
            return Array(cachedRepos.values.sorted(by: sortOption.sortingFunction))
        } else {
            let remoteData = try await remoteRepository.fetchRemoteRepos(query: query, page: page, sortOption: sortOption)
            
            do {
                for remoteRepo in remoteData {
                    if let cachedRepo = cachedRepos[remoteRepo.id] {
                        let updatedRepo = remoteRepo.withHighlighted(from: cachedRepo)
                        cachedRepos[remoteRepo.id] = updatedRepo
                    } else {
                        cachedRepos[remoteRepo.id] = remoteRepo
                    }
                }
                
                let syncedData = remoteData.map { repo in
                    cachedRepos[repo.id] ?? repo
                }
                try await localRepository.saveReposToLocal(syncedData)
            } catch {
                throw LocalRepoStorageError.saveFailed
            }
            
            return remoteData
        }
    }
    
    func deleteRepo(_ repo: Repo) async throws {
        do {
            try await localRepository.deleteRepo(repo)
            cachedRepos[repo.id] = nil
        } catch {
            throw error
        }
    }
    
    func updateRepo(_ repo: Repo) async throws {
        do {
            try await localRepository.updateRepo(repo)
            cachedRepos[repo.id] = repo
        } catch {
            throw error
        }
    }
}
