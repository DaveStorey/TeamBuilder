//
//  ContentViewViewModel.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import Foundation
import CoreData

class ContentViewViewModel: ObservableObject {
    @Published var playerList: [Player] = []
    @Published var selectedPlayers: [Player: Bool] = [:]
    @Published var teams: [Roster] = []
    public private(set) var bestOptionTeams: (Double, [Roster]) = (10, [])
    private var preliminaryTeams: [Roster] = []
    private var maxRating = 0.0
    private var minRating = 10.0
    @Published var playerName: String = ""
    @Published var playerRating: Double = 0.0
    @Published var numberOfTeams: Int = 2
    @Published var ratingVariance = 0.4
    @Published var teamDiffError = false
    static public private(set) var generationCount = 0
    
    private func createTeams() {
        generateTeams()
        guard !preliminaryTeams.isEmpty else { return }
        var teamDifferential = maxRating.distance(to: minRating)
        while teamDifferential > ratingVariance && ContentViewViewModel.generationCount < 600 {
            generateTeams()
            (maxRating, minRating) = preliminaryTeams.reduce(into: (0, 10)) { result, team in
                result.0 = max(result.0, team.averageRating)
                result.1 = min(result.1, team.averageRating)
            }
            teamDifferential = minRating.distance(to: maxRating)
            if teamDifferential < bestOptionTeams.0 {
                bestOptionTeams = (teamDifferential, preliminaryTeams)
            }
            ContentViewViewModel.generationCount += 1
        }
        if bestOptionTeams.0 > ratingVariance {
            teamDiffError = true
        } else {
            teams = bestOptionTeams.1
            preliminaryTeams.removeAll()
            reset()
        }
    }
    
    func generateTeams() {
        // Initialize teams and gender limits
        var teamNumbers: [Int: (Int, Int)] = [:] // Track team assignments (mmpCount, wmpCount)
        preliminaryTeams = (1...numberOfTeams).map { Roster(name: "Team \($0)") }
        (1...numberOfTeams).forEach { teamNumbers[$0] = (0, 0) }
        
        let selectedRoster = selectedPlayers.filter { $0.value }.keys
        let selectedMMP = selectedRoster.filter { $0.gender == .mmp }
        let selectedWMP = selectedRoster.filter { $0.gender == .wmp }
        
        // Calculate the maximum number of players per team, ensuring no more than 1 difference
        let maxPlayersPerTeam = calculateMaxPlayers(forMMP: selectedRoster.count)
        let maxMMPPerTeam = calculateMaxPlayers(forMMP: selectedMMP.count)
        let maxWMPPerTeam = calculateMaxPlayers(forMMP: selectedWMP.count)

        // Phase 1: Distribute MMP and WMP players evenly across teams, ensuring no team is missing a gender
        var mmpPlayerQueue = selectedMMP.shuffled()
        var wmpPlayerQueue = selectedWMP.shuffled()
        
        // First, distribute players to ensure each team gets at least 1 player of each gender if possible
        distributePlayersToTeams(mmpQueue: &mmpPlayerQueue, wmpQueue: &wmpPlayerQueue, teamNumbers: &teamNumbers, maxMMPPerTeam: maxMMPPerTeam, maxWMPPerTeam: maxWMPPerTeam, maxPlayersPerTeam: maxPlayersPerTeam)
        
        // Phase 2: Distribute any leftover players (if there are any left in the queues)
        distributeLeftoverPlayers(mmpQueue: &mmpPlayerQueue, wmpQueue: &wmpPlayerQueue, teamNumbers: &teamNumbers, maxPlayersPerTeam: maxPlayersPerTeam)
    }

    // Helper function to calculate max number of players per team
    private func calculateMaxPlayers(forMMP totalPlayerCount: Int) -> Int {
        return Int((Double(totalPlayerCount) / Double(numberOfTeams)).rounded(.awayFromZero))
    }

    // Phase 1: Distribute players evenly and respect gender balance constraints
    private func distributePlayersToTeams(mmpQueue: inout [Player], wmpQueue: inout [Player], teamNumbers: inout [Int: (Int, Int)], maxMMPPerTeam: Int, maxWMPPerTeam: Int, maxPlayersPerTeam: Int) {
        // Distribute MMP players first
        while !mmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], mmpCount < maxMMPPerTeam && (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = mmpQueue.removeFirst()
                    preliminaryTeams[teamIndex - 1].players.append(player)
                    teamNumbers[teamIndex] = (mmpCount + 1, wmpCount)
                    if mmpQueue.isEmpty { break }
                }
            }
        }

        // Distribute WMP players next
        while !wmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], wmpCount < maxWMPPerTeam && (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = wmpQueue.removeFirst()
                    preliminaryTeams[teamIndex - 1].players.append(player)
                    teamNumbers[teamIndex] = (mmpCount, wmpCount + 1)
                    if wmpQueue.isEmpty { break }
                }
            }
        }
    }

    // Phase 2: Distribute any leftover players across teams
    private func distributeLeftoverPlayers(mmpQueue: inout [Player], wmpQueue: inout [Player], teamNumbers: inout [Int: (Int, Int)], maxPlayersPerTeam: Int) {
        // Distribute any remaining MMP players across teams
        while !mmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = mmpQueue.removeFirst()
                    preliminaryTeams[teamIndex - 1].players.append(player)
                    teamNumbers[teamIndex] = (mmpCount + 1, wmpCount)
                    if mmpQueue.isEmpty { break }
                }
            }
        }

        // Distribute any remaining WMP players across teams
        while !wmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = wmpQueue.removeFirst()
                    preliminaryTeams[teamIndex - 1].players.append(player)
                    teamNumbers[teamIndex] = (mmpCount, wmpCount + 1)
                    if wmpQueue.isEmpty { break }
                }
            }
        }
    }

    
    func choseBestOption(_ choseBestOption: Bool) {
        teamDiffError = false
        if choseBestOption {
            teams = bestOptionTeams.1
        }
        reset()
    }
    
    private func reset() {
        ContentViewViewModel.generationCount = 0
        maxRating = 0.0
        minRating = 10.0
        bestOptionTeams = (10, [])
    }
    
    func addPlayerViewAppear() {
        selectedPlayers.removeAll()
    }
    
    func randomize() {
        teams = []
        preliminaryTeams = []
        createTeams()
    }
    
    func teamResult(_ result: String, team: String, context: NSManagedObjectContext) {
        let roster = teams.first { $0.name == team }!
        if result == "Win" {
            teamWin(roster, context: context)
        } else if result == "Loss" {
            teamLoss(roster, context: context)
        } else if result == "Tie" {
            teamTie(roster, context: context)
        }
    }
    
    func teamWin(_ roster: Roster, context: NSManagedObjectContext) {
        for player in roster.players {
            player.wins += 1
            player.updatePlayer(context: context)
        }
    }
    
    func teamLoss(_ roster: Roster, context: NSManagedObjectContext) {
        for player in roster.players {
            player.losses += 1
            player.updatePlayer(context: context)
        }
    }
    
    func teamTie(_ roster: Roster, context: NSManagedObjectContext) {
        for player in roster.players {
            player.ties += 1
            player.updatePlayer(context: context)
        }
    }
    
}
