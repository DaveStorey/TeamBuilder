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

class Player: Identifiable, Equatable, Hashable {
    
    var name: String
    var overallRating: Double
    var gender: GenderMatch
    let createDate = Date()
    
    init(name: String, overallRating: Double, match: GenderMatch = .mmp) {
        self.name = name
        self.overallRating = overallRating
        self.gender = match
    }
    
    var rating: Double {
        return overallRating
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.name == rhs.name && lhs.rating == rhs.rating
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(overallRating)
        hasher.combine(createDate)
    }
}
