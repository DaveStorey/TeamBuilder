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

enum PropertyUpdate: Equatable {
    
    case name(String)
    case overallRating(Double)
    case throwRating(Double)
    case cutRating(Double)
    case defenseRating(Double)
    case gender(String)
    case wins(Int)
    case losses(Int)
    case ties(Int)
    
    var updateValue: (String, Any) {
        switch self {
        case .name(let value): ("name", value)
        case .overallRating(let value): ("overallRating", value)
        case .throwRating(let value): ("throwRating", value)
        case .cutRating(let value): ("cutRating", value)
        case .defenseRating(let value): ("defenseRating", value)
        case .gender(let value): ("gender", value)
        case .wins(let value): ("wins", value)
        case .losses(let value): ("losses", value)
        case .ties(let value): ("ties", value)
        }
    }

}

class Player: Identifiable, Equatable, Hashable {
    
    var name: String
    var overallRating: Double
    var throwRating: Double
    var cutRating: Double
    var defenseRating: Double
    var gender: GenderMatch
    var wins: Int
    var losses: Int
    var ties: Int
    let idString: String
    
    init(name: String,
         overallRating: Double,
         throwRating: Double = 0.0,
         cutRating: Double = 0.0,
         defenseRating: Double = 0.0,
         match: GenderMatch = .mmp,
         wins: Int = 0,
         losses: Int = 0,
         ties: Int = 0,
         idString: String = UUID().uuidString) {
        self.name = name
        self.overallRating = overallRating
        self.throwRating = throwRating
        self.cutRating = cutRating
        self.defenseRating = defenseRating
        self.gender = match
        self.wins = wins
        self.losses = losses
        self.ties = ties
        self.idString = idString
    }
    
    var offensiveRating: Double {
        return (throwRating + cutRating) / 2.0
    }
    
    var winningPercentage: Double {
        wins + ties + losses > 0 ? ((Double(wins) + (Double(ties) * 0.5)) / Double(wins + ties + losses)) : 0.0
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.idString == rhs.idString
    }
    
    func valueCopy() -> Player {
        Player(name: name,
               overallRating: overallRating,
               throwRating: throwRating,
               cutRating: cutRating,
               defenseRating: defenseRating,
               wins: wins,
               losses: losses,
               ties: ties,
               idString: idString)
    }
    
    func compareTo(_ other: Player) -> [PropertyUpdate] {
        var updatedProperties: [PropertyUpdate] = []
        if other.name != name {
            updatedProperties.append(.name(name))
        }
        if other.overallRating != overallRating {
            updatedProperties.append(.overallRating(overallRating))
        }
        if other.throwRating != throwRating {
            updatedProperties.append(.throwRating(throwRating))
        }
        if other.cutRating != cutRating {
            updatedProperties.append(.cutRating(cutRating))
        }
        if other.defenseRating != defenseRating {
            updatedProperties.append(.defenseRating(defenseRating))
        }
        if other.gender != gender {
            updatedProperties.append(.gender(gender.rawValue))
        }
        if other.wins != wins {
            updatedProperties.append(.wins(wins))
        }
        if other.losses != losses {
            updatedProperties.append(.losses(losses))
        }
        if other.ties != ties {
            updatedProperties.append(.ties(ties))
        }
        return updatedProperties
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(overallRating)
        hasher.combine(winningPercentage)
    }
    
    func deletePlayers(context: NSManagedObjectContext) {
        let fetch: NSFetchRequest<NSFetchRequestResult>
        fetch = NSFetchRequest(entityName: "PersistedPlayer")
        fetch.predicate = NSPredicate(format: "idString == %@", idString)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        deleteRequest.resultType = .resultTypeStatusOnly
        do {
            let _ = try context.execute(deleteRequest)
        } catch (let error) {
            print("Batch delete error: \(error.localizedDescription)")
        }
    }
    
    func savePlayer(context: NSManagedObjectContext) {
        let savedPlayer = PersistedPlayer(context: context)
        savedPlayer.name = name
        savedPlayer.createDate = Date()
        savedPlayer.gender = gender.rawValue
        savedPlayer.overallRating = overallRating
        savedPlayer.wins = Int16(wins)
        savedPlayer.losses = Int16(losses)
        savedPlayer.ties = Int16(ties)
        savedPlayer.throwRating = throwRating
        savedPlayer.cutRating = cutRating
        savedPlayer.defenseRating = defenseRating
        savedPlayer.idString = idString
        do {
            context.insert(savedPlayer)
            try context.save()
        } catch(let error) {
            print("Persistence context error: \(error.localizedDescription)")
        }
    }
    
    //TODO: Figure out why fetches aren't returning an updated object
    func updatePlayer(_ properties: [PropertyUpdate], context: NSManagedObjectContext) {
        var updateProperties: [String: Any] = [:]
        for property in properties {
            updateProperties.updateValue(property.updateValue.1, forKey: property.updateValue.0)
        }
        let updateRequest = NSBatchUpdateRequest(entityName: "PersistedPlayer")
        updateRequest.predicate = NSPredicate(format: "idString == %@", idString)
        print("Updating: \(idString)")
        updateRequest.propertiesToUpdate = updateProperties
        updateRequest.resultType = .statusOnlyResultType
        do {
            let result = try context.execute(updateRequest)
            print("Persistence result: \(result.description)")
        } catch(let error) {
            print("Persistence update error: \(error.localizedDescription)")
        }
    }
}
