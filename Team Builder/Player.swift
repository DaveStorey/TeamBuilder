//
//  Player.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import Foundation
import CoreData

enum GenderMatch: String, Equatable, CaseIterable {
    case mmp = "MMP"
    case wmp = "WMP"
    
    var displayText: String {
        switch self {
        case .mmp: return "MMP"
        case .wmp: return "WMP"
        }
    }
}

class Player: Identifiable, Equatable, Hashable {
    
    var name: String
    var overallRating: Double
    var gender: GenderMatch
    var wins: Int
    var losses: Int
    var ties: Int
    
    init(name: String, overallRating: Double, match: GenderMatch = .mmp, wins: Int = 0, losses: Int = 0, ties: Int = 0) {
        self.name = name
        self.overallRating = overallRating
        self.gender = match
        self.wins = wins
        self.losses = losses
        self.ties = ties
    }
    
    var rating: Double {
        return overallRating
    }
    
    var winningPercentage: Double {
        wins + ties + losses > 0 ? ((Double(wins) + (Double(ties) * 0.5)) / Double(wins + ties + losses)) : 0.0
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.name == rhs.name && lhs.rating == rhs.rating
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(overallRating)
        hasher.combine(winningPercentage)
    }
    
    func deletePlayers(context: NSManagedObjectContext) {
        let fetch: NSFetchRequest<NSFetchRequestResult>
        fetch = NSFetchRequest(entityName: "PersistedPlayer")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        deleteRequest.resultType = .resultTypeStatusOnly
        do {
            let _ = try context.execute(deleteRequest)
        } catch (let error) {
            print("Batch delete error: \(error.localizedDescription)")
        }
    }
    
    func savePlayer(context: NSManagedObjectContext) {
        let testPlayer = PersistedPlayer(context: context)
        testPlayer.name = name
        testPlayer.createDate = Date()
        testPlayer.gender = gender.rawValue
        testPlayer.overallRating = overallRating
        testPlayer.wins = Int16(wins)
        testPlayer.losses = Int16(losses)
        testPlayer.ties = Int16(ties)
        do {
            context.insert(testPlayer)
            try context.save()
        } catch(let error) {
            print("Persistence context error: \(error.localizedDescription)")
        }
    }
    
    func updatePlayer(context: NSManagedObjectContext) {
        let updateRequest = NSBatchUpdateRequest(entityName: "PersistedPlayer")
        updateRequest.predicate = NSPredicate(format: "name == %@", name)
        updateRequest.propertiesToUpdate = ["wins": Int16(wins), "losses": Int16(losses), "ties": Int16(ties)]
        updateRequest.resultType = .updatedObjectIDsResultType
        do {
            let _ = try context.execute(updateRequest)
        } catch(let error) {
            print("Persistence update error: \(error.localizedDescription)")
        }
    }
}
