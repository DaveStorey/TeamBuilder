//
//  Persistence.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import CoreData

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    // Create a persistent container as a lazy variable to defer instantiation until its first use.
    lazy var persistentContainer: NSPersistentContainer = {
        
        // Pass the data model filename to the container’s initializer.
        let container = NSPersistentContainer(name: "PersistedPlayer")
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
                // Handle the error appropriately. However, it's useful to use
                // `fatalError(_:file:line:)` during development.
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
        
    private init() { }
}

extension CoreDataStack {
    
    func save() {
        // Verify that the context has uncommitted changes.
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            // Attempt to save changes.
            try persistentContainer.viewContext.save()
        } catch {
            // Handle the error appropriately.
            print("Failed to save the context:", error.localizedDescription)
        }
    }
    
    func save(player: PersistedPlayer) {
        persistentContainer.viewContext.insert(player)
    }
    
    func delete(item: PersistedPlayer) {
        persistentContainer.viewContext.delete(item)
        save()
    }
    
    func save(roster: Roster) {
        let context = persistentContainer.viewContext
        context.perform {
            do {
                _ = try roster.upsert(in: context)
                try context.save()
            } catch {
                print("Failed to save roster:", error.localizedDescription)
            }
        }
    }

    func fetchRosters() -> [Roster] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<PersistedRoster> = PersistedRoster.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]

        do {
            return try context.fetch(request).map { $0.toModelRoster() }
        } catch {
            print("Failed to fetch rosters:", error.localizedDescription)
            return []
        }
    }

    func deleteRoster(id: UUID) {
        let context = persistentContainer.viewContext
        context.perform {
            do {
                let request: NSFetchRequest<PersistedRoster> = PersistedRoster.fetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                if let roster = try context.fetch(request).first {
                    context.delete(roster)
                    try context.save()
                }
            } catch {
                print("Failed to delete roster:", error.localizedDescription)
            }
        }
    }
    
    func replaceSavedTeams(with rosters: [Roster]) {
        let context = persistentContainer.viewContext
        context.perform {
            do {
                // Delete all existing persisted rosters
                let fetch: NSFetchRequest<PersistedRoster> = PersistedRoster.fetchRequest()
                let existing = try context.fetch(fetch)
                existing.forEach { context.delete($0) }

                // Upsert the new rosters
                for roster in rosters {
                    _ = try roster.upsert(in: context)
                }

                try context.save()
            } catch {
                print("Failed to replace saved teams:", error.localizedDescription)
            }
        }
    }
}
