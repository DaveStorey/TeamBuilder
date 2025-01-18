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
    private var generationCount = 0
    private var taskCount = 0
    
    @MainActor
    private func testAsyncCreation() async {
        var potentialAsyncTeams: [[Roster]] = []
        var testTeams: [Roster] = []
        while testTeams.isEmpty && generationCount < 600 {
            // Generating teams in batches of 100, checking for a team that fits criteria, then resetting and firing another batch
            for _ in 1...100 {
                async let teams = testGenerateTeams()
                await potentialAsyncTeams.append(teams)
                generationCount += 1
            }
            testTeams = potentialAsyncTeams.first(where: { $0.differential <= ratingVariance }) ?? []
            if let option = potentialAsyncTeams.first(where: { $0.differential <= bestOptionTeams.0 }) {
                bestOptionTeams = (option.differential, option)
            }
            potentialAsyncTeams = []
        }
        teams = testTeams
        if testTeams.isEmpty{
            teamDiffError = true
        } else {
            reset()
        }
    }
    
    private func testGenerateTeams() async -> [Roster] {
        // Initialize teams and gender limits
        var teamNumbers: [Int: (Int, Int)] = [:] // Track team assignments (mmpCount, wmpCount)
        var preliminaryTestTeams = (1...numberOfTeams).map { Roster(name: "Team \($0)") }
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
        await distributePlayersToTeams(mmpQueue: &mmpPlayerQueue, wmpQueue: &wmpPlayerQueue, teamNumbers: &teamNumbers, maxMMPPerTeam: maxMMPPerTeam, maxWMPPerTeam: maxWMPPerTeam, maxPlayersPerTeam: maxPlayersPerTeam, prelims: &preliminaryTestTeams)
        
        // Phase 2: Distribute any leftover players (if there are any left in the queues)
        await distributeLeftoverPlayers(mmpQueue: &mmpPlayerQueue, wmpQueue: &wmpPlayerQueue, teamNumbers: &teamNumbers, maxPlayersPerTeam: maxPlayersPerTeam, prelims: &preliminaryTestTeams)
        return preliminaryTestTeams
    }

    // Helper function to calculate max number of players per team
    private func calculateMaxPlayers(forMMP totalPlayerCount: Int) -> Int {
        return Int((Double(totalPlayerCount) / Double(numberOfTeams)).rounded(.awayFromZero))
    }

    // Phase 1: Distribute players evenly and respect gender balance constraints
    private func distributePlayersToTeams(mmpQueue: inout [Player], wmpQueue: inout [Player], teamNumbers: inout [Int: (Int, Int)], maxMMPPerTeam: Int, maxWMPPerTeam: Int, maxPlayersPerTeam: Int, prelims: inout [Roster]) async {
        // Distribute MMP players first
        while !mmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], mmpCount < maxMMPPerTeam && (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = mmpQueue.removeFirst()
                    prelims[teamIndex - 1].players.append(player)
                    teamNumbers[teamIndex] = (mmpCount + 1, wmpCount)
                    if mmpQueue.isEmpty { break }
                }
            }
        }
        // Distribute WMP players next, ensuring that teams with a lower number of MMP get more WMP
        let updatedTeamNumbers = teamNumbers.sorted(by: { $0.value.0 < $1.value.0 }).map { $0.key }
        while !wmpQueue.isEmpty {
            for teamIndex in updatedTeamNumbers {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], wmpCount < maxWMPPerTeam && (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = wmpQueue.removeFirst()
                    prelims[teamIndex - 1].players.append(player)
                    teamNumbers[teamIndex] = (mmpCount, wmpCount + 1)
                    if wmpQueue.isEmpty { break }
                }
            }
        }
    }

    // Phase 2: Distribute any leftover players across teams
    private func distributeLeftoverPlayers(mmpQueue: inout [Player], wmpQueue: inout [Player], teamNumbers: inout [Int: (Int, Int)], maxPlayersPerTeam: Int, prelims: inout [Roster]) async {
        // Distribute any remaining MMP players across teams
        while !mmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = mmpQueue.removeFirst()
                    prelims[teamIndex - 1].players.append(player)
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
                    prelims[teamIndex - 1].players.append(player)
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
        generationCount = 0
        maxRating = 0.0
        minRating = 10.0
        bestOptionTeams = (10, [])
    }
    
    func addPlayerViewAppear() {
        selectedPlayers.removeAll()
    }
    
    @MainActor
    func randomize() async {
        teams = []
        preliminaryTeams = []
        await testAsyncCreation()
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
