//
//  League.swift
//  Team Builder
//
//  Created by David Storey on 4/18/24.
//

import Foundation
import Accelerate

class Roster: Identifiable, Equatable, Hashable {
    
    var name: String
    var players: [Player]
    var createDate: Date
    var id: UUID = UUID()
    
    init(name: String, players: [Player]? = nil) {
        self.name = name
        self.players = players ?? []
        self.createDate = Date()
    }
    
    static func == (lhs: Roster, rhs: Roster) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var averageRating: Double {
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
    
    func hasReachedGenderLimit(gender: GenderMatch, limit: Int) -> Bool {
        self.players.filter({ $0.gender == gender }).count >= limit
    }
    
    func numberOfPlayers(for gender: GenderMatch) -> Int {
        return self.players.count(where: { $0.gender == gender })
    }
    
}

extension Roster {
    /// Compute the centroid of a list of 3‑component rating vectors.
    private func centroid(of team: Roster) -> [Double] {
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
    private func euclideanDistance(_ a: [Double], _ b: [Double]) -> Double {
        precondition(a.count == 3 && b.count == 3)
        let dx = a[0] - b[0]
        let dy = a[1] - b[1]
        let dz = a[2] - b[2]
        return sqrt(dx*dx + dy*dy + dz*dz)
    }

    /// Score how “balanced” a proposed split is.
    func balanceScore(teams: [Roster], useOverall: Bool) -> Double {
        var maxMin: (Double, Double) = (0.0, 10.0)
        if useOverall {
            for team in teams {
                if team.averageRating > maxMin.0 {
                    maxMin.0 = team.averageRating
                } else if team.averageRating < maxMin.1 {
                    maxMin.1 = team.averageRating
                }
            }
        } else {
            var teamCentroids: [[Double]] = []
            for team in teams {
                teamCentroids.append(centroid(of: team))
            }
            for centroid in teamCentroids {
                maxMin.1 = euclideanDistance([10, 10, 10], centroid)
            }
        }
        return maxMin.0 - maxMin.1
    }
}
