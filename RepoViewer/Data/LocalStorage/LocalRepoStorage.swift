import SwiftUI
import SwiftData

@MainActor
final class LocalRepoStorage: LocalRepoRepository {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func saveReposToLocal(_ repos: [Repo]) async throws {
        for repo in repos {
            try saveOrUpdateRepository(repo)
        }
        try context.save()
    }
    
    func fetchLocalRepos(sortOption: SortOption) async throws -> [Repo] {
        print("Fetching local repositories sorted by: \(sortOption)")
        
        let fetchDescriptor = FetchDescriptor(sortBy: [makeSortDescriptor(for: sortOption)])
        let localRepos = try context.fetch(fetchDescriptor)
        return localRepos.map { Repo(repository: $0) }
    }
    
    func deleteRepo(_ repo: Repo) async throws {
        guard let existingRepo = try fetchRepository(by: repo.id) else {
            throw LocalRepoStorageError.repositoryNotFound
        }
        context.delete(existingRepo)
        try saveContext()
    }
    
    func updateRepo(_ repo: Repo) async throws {
        guard let existingRepo = try fetchRepository(by: repo.id) else {
            throw LocalRepoStorageError.repositoryNotFound
        }
        existingRepo.isHighlighted = repo.isHighlighted
        try saveContext()
    }
    
    private func saveOrUpdateRepository(_ repo: Repo) throws {
        do {
            if let existingRepo = try fetchRepository(by: repo.id) {
                update(existingRepo, with: repo)
            } else {
                context.insert(Repository(repo: repo))
            }
        } catch {
            throw LocalRepoStorageError.custom(message: "Unexpected error while saving or updating repository: \(error.localizedDescription)")
        }
    }
    
    private func update(_ existingRepo: Repository, with repo: Repo) {
        existingRepo.name = repo.name
        existingRepo.repoDescription = repo.description
        existingRepo.stars = repo.stars
        existingRepo.forks = repo.forks
        existingRepo.updatedAt = repo.updatedAt
        existingRepo.repoAvatarUrl = repo.owner.avatarUrl
        existingRepo.isHighlighted = repo.isHighlighted
    }
    
    private func makeSortDescriptor(for sortOption: SortOption) -> SortDescriptor<Repository> {
        switch sortOption {
        case .basic:
            return SortDescriptor(\.name, order: .forward)
        case .stars:
            return SortDescriptor(\.stars, order: .reverse)
        case .forks:
            return SortDescriptor(\.forks, order: .reverse)
        case .updated:
            return SortDescriptor(\.updatedAt, order: .reverse)
        }
    }
    
    private func fetchRepository(by id: Int) throws -> Repository? {
        let fetchDescriptor = FetchDescriptor<Repository>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(fetchDescriptor).first
    }
    
    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            throw LocalRepoStorageError.saveFailed
        }
    }
}