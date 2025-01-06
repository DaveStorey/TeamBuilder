//
//  Player.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import Foundation
import CoreData

enum GenderMatch: String, Codable, Equatable, CaseIterable {
    case mmp = "MMP"
    case wmp = "WMP"
    
    var displayText: String {
        switch self {
        case .mmp: return "MMP"
        case .wmp: return "WMP"
        }
    }
}

class Player: Identifiable, Equatable, Hashable, Codable {
    
    var name: String
    var overallRating: Double
    var gender: GenderMatch
    var createDate = Date()
    var wins: Int
    var losses: Int
    
    init(name: String, overallRating: Double, match: GenderMatch = .mmp, wins: Int = 0, losses: Int = 0) {
        self.name = name
        self.overallRating = overallRating
        self.gender = match
        self.wins = wins
        self.losses = losses
    }
    
    var rating: Double {
        return overallRating
    }
    
    var winningPercentage: Double {
        return (Double(wins) / Double(wins + losses))
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.name == rhs.name && lhs.rating == rhs.rating
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(overallRating)
        hasher.combine(createDate)
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
        updateRequest.propertiesToUpdate = ["wins": Int16(wins), "losses": Int16(losses)]
        updateRequest.resultType = .updatedObjectIDsResultType
        do {
            let _ = try context.execute(updateRequest)
        } catch(let error) {
            print("Persistence update error: \(error.localizedDescription)")
        }
    }
}
