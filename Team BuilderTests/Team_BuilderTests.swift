//
//  Team_BuilderTests.swift
//  Team BuilderTests
//
//  Created by David Storey on 3/27/24.
//

import XCTest
@testable import Team_Builder

final class Team_BuilderTests: XCTestCase {
    
    // MARK: - Player Tests
    
    func testPlayerInitialization() throws {
        let player = Player(name: "Test Player", overallRating: 7.5, match: .mmp)
        
        XCTAssertEqual(player.name, "Test Player")
        XCTAssertEqual(player.overallRating, 7.5)
        XCTAssertEqual(player.gender, .mmp)
        XCTAssertEqual(player.wins, 0)
        XCTAssertEqual(player.losses, 0)
        XCTAssertEqual(player.ties, 0)
        XCTAssertEqual(player.pointDifferential, 0)
    }
    
    func testPlayerOffensiveRating() throws {
        let player = Player(
            name: "Offensive Player",
            overallRating: 8.0,
            throwRating: 7.0,
            cutRating: 9.0,
            match: .mmp
        )
        
        let expectedOffensiveRating = (7.0 + 9.0) / 2.0
        XCTAssertEqual(player.offensiveRating, expectedOffensiveRating, accuracy: 0.01)
    }
    
    func testPlayerWinningPercentage() throws {
        let player = Player(name: "Winner", overallRating: 8.0, wins: 7, losses: 3, ties: 0)
        
        let expectedWinPercentage = 7.0 / 10.0
        XCTAssertEqual(player.winningPercentage, expectedWinPercentage, accuracy: 0.01)
    }
    
    func testPlayerWinningPercentageWithTies() throws {
        let player = Player(name: "Tie Master", overallRating: 7.0, wins: 5, losses: 3, ties: 2)
        
        // Ties count as 0.5 wins: (5 + 2*0.5) / 10 = 6.0 / 10.0 = 0.6
        let expectedWinPercentage = (5.0 + 2.0 * 0.5) / 10.0
        XCTAssertEqual(player.winningPercentage, expectedWinPercentage, accuracy: 0.01)
    }
    
    func testPlayerWinningPercentageWithNoGames() throws {
        let player = Player(name: "Rookie", overallRating: 6.0)
        
        XCTAssertEqual(player.winningPercentage, 0.0)
    }
    
    func testPlayerEquality() throws {
        let id = UUID().uuidString
        let player1 = Player(name: "Player", overallRating: 7.0, idString: id)
        let player2 = Player(name: "Different Name", overallRating: 9.0, idString: id)
        
        XCTAssertEqual(player1, player2, "Players with same idString should be equal")
    }
    
    func testPlayerValueCopy() throws {
        let original = Player(
            name: "Original",
            overallRating: 8.5,
            throwRating: 7.5,
            cutRating: 8.0,
            defenseRating: 9.0,
            match: .wmp,
            wins: 5,
            losses: 2,
            ties: 1,
            pointDifferential: 15
        )
        
        let copy = original.valueCopy()
        
        XCTAssertEqual(copy.name, original.name)
        XCTAssertEqual(copy.overallRating, original.overallRating)
        XCTAssertEqual(copy.throwRating, original.throwRating)
        XCTAssertEqual(copy.cutRating, original.cutRating)
        XCTAssertEqual(copy.defenseRating, original.defenseRating)
        XCTAssertEqual(copy.gender, original.gender)
        XCTAssertEqual(copy.wins, original.wins)
        XCTAssertEqual(copy.losses, original.losses)
        XCTAssertEqual(copy.ties, original.ties)
        XCTAssertEqual(copy.pointDifferential, original.pointDifferential)
        XCTAssertEqual(copy.idString, original.idString)
    }
    
    func testPlayerCompareTo() throws {
        let player1 = Player(name: "Player 1", overallRating: 7.0, throwRating: 6.0)
        let player2 = Player(name: "Player 2", overallRating: 8.0, throwRating: 6.0, idString: player1.idString)
        
        let differences = player2.compareTo(player1)
        
        XCTAssertTrue(differences.contains(where: {
            if case .name("Player 2") = $0 { return true }
            return false
        }))
        XCTAssertTrue(differences.contains(where: {
            if case .overallRating(8.0) = $0 { return true }
            return false
        }))
        XCTAssertFalse(differences.contains(where: {
            if case .throwRating = $0 { return true }
            return false
        }), "Throw rating is the same, should not be in differences")
    }
    
    // MARK: - GenderMatch Tests
    
    func testGenderMatchDisplayText() throws {
        XCTAssertEqual(GenderMatch.mmp.displayText, "MMP")
        XCTAssertEqual(GenderMatch.wmp.displayText, "WMP")
    }
    
    func testGenderMatchRawValue() throws {
        XCTAssertEqual(GenderMatch.mmp.rawValue, "MMP")
        XCTAssertEqual(GenderMatch.wmp.rawValue, "WMP")
    }
    
    // MARK: - Roster Tests
    
    func testRosterInitialization() throws {
        let roster = Roster(name: "Team A")
        
        XCTAssertEqual(roster.name, "Team A")
        XCTAssertEqual(roster.players.count, 0)
    }
    
    func testRosterWithPlayers() throws {
        let players = [
            Player(name: "Player 1", overallRating: 7.0),
            Player(name: "Player 2", overallRating: 8.0)
        ]
        let roster = Roster(name: "Team B", players: players)
        
        XCTAssertEqual(roster.players.count, 2)
    }
    
    func testRosterAverageRating() throws {
        let players = [
            Player(name: "Player 1", overallRating: 6.0),
            Player(name: "Player 2", overallRating: 8.0),
            Player(name: "Player 3", overallRating: 7.0)
        ]
        let roster = Roster(name: "Team C", players: players)
        
        let expectedAverage = (6.0 + 8.0 + 7.0) / 3.0
        XCTAssertEqual(roster.averageRating, expectedAverage, accuracy: 0.01)
    }
    
    func testRosterAverageRatingEmpty() throws {
        let roster = Roster(name: "Empty Team")
        
        XCTAssertEqual(roster.averageRating, 0.0)
    }
    
    func testRosterAverageThrowRating() throws {
        let players = [
            Player(name: "Player 1", overallRating: 7.0, throwRating: 8.0),
            Player(name: "Player 2", overallRating: 7.0, throwRating: 6.0)
        ]
        let roster = Roster(name: "Throwers", players: players)
        
        XCTAssertEqual(roster.averageThrowRating, 7.0, accuracy: 0.01)
    }
    
    func testRosterAverageCutRating() throws {
        let players = [
            Player(name: "Player 1", overallRating: 7.0, cutRating: 9.0),
            Player(name: "Player 2", overallRating: 7.0, cutRating: 7.0)
        ]
        let roster = Roster(name: "Cutters", players: players)
        
        XCTAssertEqual(roster.averageCutRating, 8.0, accuracy: 0.01)
    }
    
    func testRosterAverageDefenseRating() throws {
        let players = [
            Player(name: "Player 1", overallRating: 7.0, defenseRating: 8.5),
            Player(name: "Player 2", overallRating: 7.0, defenseRating: 7.5)
        ]
        let roster = Roster(name: "Defenders", players: players)
        
        XCTAssertEqual(roster.averageDefenseRating, 8.0, accuracy: 0.01)
    }
    
    func testRosterNumberOfPlayersForGender() throws {
        let players = [
            Player(name: "Player 1", overallRating: 7.0, match: .mmp),
            Player(name: "Player 2", overallRating: 7.0, match: .mmp),
            Player(name: "Player 3", overallRating: 7.0, match: .wmp)
        ]
        let roster = Roster(name: "Mixed Team", players: players)
        
        XCTAssertEqual(roster.numberOfPlayers(for: .mmp), 2)
        XCTAssertEqual(roster.numberOfPlayers(for: .wmp), 1)
    }
    
    func testRosterHasReachedGenderLimit() throws {
        let players = [
            Player(name: "Player 1", overallRating: 7.0, match: .mmp),
            Player(name: "Player 2", overallRating: 7.0, match: .mmp),
            Player(name: "Player 3", overallRating: 7.0, match: .wmp)
        ]
        let roster = Roster(name: "Team", players: players)
        
        XCTAssertTrue(roster.hasReachedGenderLimit(gender: .mmp, limit: 2))
        XCTAssertFalse(roster.hasReachedGenderLimit(gender: .mmp, limit: 3))
        XCTAssertFalse(roster.hasReachedGenderLimit(gender: .wmp, limit: 2))
    }
    
    func testRosterEquality() throws {
        let roster1 = Roster(name: "Team Alpha")
        let roster2 = Roster(name: "Team Alpha")
        let roster3 = Roster(name: "Team Beta")
        
        XCTAssertEqual(roster1, roster2, "Rosters with same name should be equal")
        XCTAssertNotEqual(roster1, roster3, "Rosters with different names should not be equal")
    }
    
    func testRosterCentroid() throws {
        let players = [
            Player(name: "Player 1", overallRating: 7.0, throwRating: 6.0, cutRating: 8.0, defenseRating: 7.0),
            Player(name: "Player 2", overallRating: 8.0, throwRating: 8.0, cutRating: 6.0, defenseRating: 9.0)
        ]
        let roster = Roster(name: "Team", players: players)
        
        let centroid = roster.centroid(of: roster)
        
        XCTAssertEqual(centroid.count, 3)
        XCTAssertEqual(centroid[0], 7.0, accuracy: 0.01) // Average throw: (6.0 + 8.0) / 2
        XCTAssertEqual(centroid[1], 7.0, accuracy: 0.01) // Average cut: (8.0 + 6.0) / 2
        XCTAssertEqual(centroid[2], 8.0, accuracy: 0.01) // Average defense: (7.0 + 9.0) / 2
    }
    
    func testRosterEuclideanDistance() throws {
        let players = [
            Player(name: "Player 1", overallRating: 7.0, throwRating: 3.0, cutRating: 4.0, defenseRating: 0.0)
        ]
        let roster = Roster(name: "Team", players: players)
        
        // Distance from origin: sqrt(3^2 + 4^2 + 0^2) = sqrt(9 + 16) = 5.0
        let distance = roster.euclideanDistance(to: [0.0, 0.0, 0.0])
        
        XCTAssertEqual(distance, 5.0, accuracy: 0.01)
    }
    
    // MARK: - ContentViewViewModel Tests
    
    func testViewModelInitialization() throws {
        let viewModel = ContentViewViewModel()
        
        XCTAssertEqual(viewModel.playerList.count, 0)
        XCTAssertEqual(viewModel.selectedPlayers.count, 0)
        XCTAssertEqual(viewModel.teams.count, 0)
        XCTAssertEqual(viewModel.numberOfTeams, 2)
        XCTAssertEqual(viewModel.ratingVariance, 0.4)
        XCTAssertFalse(viewModel.useOverall)
    }
    
    func testViewModelRatingLimitOverall() throws {
        let viewModel = ContentViewViewModel()
        viewModel.useOverall = true
        viewModel.ratingVariance = 0.5
        
        XCTAssertEqual(viewModel.ratingLimit(), 0.5)
    }
    
    func testViewModelRatingLimitWithVariances() throws {
        let viewModel = ContentViewViewModel()
        viewModel.useOverall = false
        viewModel.throwVariance = 0.3
        viewModel.cutVariance = 0.4
        viewModel.defenseVariance = 0.0
        
        // Euclidean distance: sqrt(0.3^2 + 0.4^2 + 0.0^2) = sqrt(0.09 + 0.16) = 0.5
        let expectedLimit = sqrt(0.3*0.3 + 0.4*0.4 + 0.0*0.0)
        XCTAssertEqual(viewModel.ratingLimit(), expectedLimit, accuracy: 0.01)
    }
    
    func testViewModelAddPlayerViewAppear() throws {
        let viewModel = ContentViewViewModel()
        let player = Player(name: "Test", overallRating: 7.0)
        viewModel.selectedPlayers[player] = true
        
        XCTAssertEqual(viewModel.selectedPlayers.count, 1)
        
        viewModel.addPlayerViewAppear()
        
        XCTAssertEqual(viewModel.selectedPlayers.count, 0)
    }
    
    func testViewModelChoseBestOptionTrue() throws {
        let viewModel = ContentViewViewModel()
        viewModel.teamDiffError = true
        
        viewModel.choseBestOption(true)
        
        XCTAssertFalse(viewModel.teamDiffError)
    }
    
    func testViewModelChoseBestOptionFalse() throws {
        let viewModel = ContentViewViewModel()
        viewModel.teamDiffError = true
        
        viewModel.choseBestOption(false)
        
        XCTAssertFalse(viewModel.teamDiffError)
        XCTAssertEqual(viewModel.teams.count, 0, "Teams should not be set when declining best option")
    }
    
    // MARK: - Performance Tests
    
    func testPlayerCreationPerformance() throws {
        measure {
            for i in 0..<1000 {
                _ = Player(name: "Player \(i)", overallRating: Double(i % 10))
            }
        }
    }
    
    func testRosterAverageRatingPerformance() throws {
        let players = (0..<100).map {
            Player(name: "Player \($0)", overallRating: Double($0 % 10))
        }
        let roster = Roster(name: "Large Team", players: players)
        
        measure {
            _ = roster.averageRating
        }
    }
    
    func testRosterEuclideanDistancePerformance() throws {
        var players: [Player] = []
        for i in 0..<100 {
            let player = Player(
                name: "Player \(i)",
                overallRating: Double(i % 10),
                throwRating: Double(i % 8),
                cutRating: Double(i % 9),
                defenseRating: Double(i % 7)
            )
            players.append(player)
        }
        let roster = Roster(name: "Large Team", players: players)
        
        measure {
            _ = roster.euclideanDistanceFromCenter
        }
    }
}
