//
//  League.swift
//  Team Builder
//
//  Created by David Storey on 4/18/24.
//

import Foundation
import CoreData

class Roster: Identifiable, Equatable, Codable {
    
    var name: String
    var players: [Player]
    var createDate: Date
    
    init(name: String, players: [Player]? = nil) {
        self.name = name
        self.players = players ?? []
        self.createDate = Date()
    }
    
    static func == (lhs: Roster, rhs: Roster) -> Bool {
        lhs.name == rhs.name
    }
    
    var averageRating: Double {
        var avg = 0.0
        for player in players {
            avg += player.overallRating
        }
        return avg / Double(players.count)
    }
    
    func hasReachedGenderLimit(gender: GenderMatch, limit: Int) -> Bool {
        self.players.filter({ $0.gender == gender }).count >= limit
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    func numberOfPlayers(for gender: GenderMatch) -> Int {
        return self.players.count(where: { $0.gender == gender })
    }
    
}
