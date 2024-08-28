//
//  League.swift
//  Team Builder
//
//  Created by David Storey on 4/18/24.
//

import Foundation
import CoreData

class League: Identifiable, Equatable {
    
    var name: String
    var players: [Player]
    var teams: [Roster]
    var id = UUID()
    
    init(name: String, players: [Player]? = nil, teams: [Roster]? = nil) {
        self.name = name
        self.players = players ?? []
        self.teams = teams ?? []
    }
    
    static func == (lhs: League, rhs: League) -> Bool {
        lhs.id == rhs.id
    }
}

class Roster: Identifiable, Equatable {
    
    var name: String
    var players: [Player]
    
    init(name: String, players: [Player]? = nil) {
        self.name = name
        self.players = players ?? []
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
}
