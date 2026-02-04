//
//  Roster.swift
//  Team Builder
//
//  Created by David Storey on 4/18/24.
//

import Foundation
import Accelerate
import CoreData

class Roster: Identifiable, Equatable, Hashable {
    
    var name: String
    var players: [Player]
    var createDate: Date
    var id: UUID
    
    init(name: String, players: [Player]? = nil, uuid: String? = nil) {
        self.name = name
        self.players = players ?? []
        self.createDate = Date()
        if let id = uuid {
            self.id = UUID(uuidString: id) ?? UUID()
        } else {
            self.id = UUID()
        }
    }
    
    static func == (lhs: Roster, rhs: Roster) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var averageRating: Double {
        guard players.count > 0 else { return 0 }
        var avg = 0.0
        for player in players {
            avg += player.overallRating
        }
        return avg / Double(players.count)
    }
    
    var averageThrowRating: Double {
        players.isEmpty ? 0 : players.map { $0.throwRating }.reduce(0, +) / Double(players.count)
    }
        
    var averageCutRating: Double {
        players.isEmpty ? 0 : players.map { $0.cutRating }.reduce(0, +) / Double(players.count)
    }
        
    var averageDefenseRating: Double {
        players.isEmpty ? 0 : players.map { $0.defenseRating }.reduce(0, +) / Double(players.count)
    }
    
    var euclideanDistanceFromCenter: Double {
        euclideanDistance(to: [0,0,0])
    }
    
    func hasReachedGenderLimit(gender: GenderMatch, limit: Int) -> Bool {
        self.players.filter({ $0.gender == gender }).count >= limit
    }
    
    func numberOfPlayers(for gender: GenderMatch) -> Int {
        return self.players.count(where: { $0.gender == gender })
    }
    
}

extension Roster {
    /// Compute the centroid of a list of 3‑component rating vectors.
    func centroid(of team: Roster) -> [Double] {
        let count = Double(team.players.count)
        var sum = [0.0, 0.0, 0.0]
        for player in team.players {
            sum[0] += player.throwRating
            sum[1] += player.cutRating
            sum[2] += player.defenseRating
        }
        return sum.map { $0 / count }
    }

    /// Euclidean distance between two 3D points.
    func euclideanDistance(to a: [Double]) -> Double {
        let b = centroid(of: self)
        precondition(a.count == 3 && b.count == 3)
        let dx = a[0] - b[0]
        let dy = a[1] - b[1]
        let dz = a[2] - b[2]
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
}

extension Roster {
    func upsert(in context: NSManagedObjectContext) throws -> PersistedRoster {
        let request: NSFetchRequest<PersistedRoster> = PersistedRoster.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", self.id as CVarArg)

        let persisted = try context.fetch(request).first ?? PersistedRoster(context: context)
        persisted.name = self.name
        persisted.createDate = self.createDate

        // Map roster.players -> PersistedPlayer objects.
        // Best practice: upsert players too, keyed by idString (or UUID).
        let persistedPlayers = try self.players.map { player in
            try player.upsert(in: context)
        }

        persisted.players = NSSet(array: persistedPlayers)
        return persisted
    }
}

extension PersistedRoster {
    func toModelRoster() -> Roster {
        let roster: Roster = Roster(name: name ?? "Untitled \(Date().ISO8601Format())", players: [], uuid: id)
        roster.createDate = createDate ?? Date()
        if let playerSet = players as? Set<PersistedPlayer> {
            roster.players = playerSet.map { $0.toModelPlayer() }
        }
        return roster
    }
}
