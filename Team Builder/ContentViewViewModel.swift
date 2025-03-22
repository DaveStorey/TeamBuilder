//
//  ContentViewViewModel.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import Foundation
import CoreData

struct RatingsVariance {
    var overall = 10.0
    var throwing = 10.0
    var cutting = 10.0
    var defense = 10.0
    
    func compareTo(_ bestOption: RatingsVariance, useOverall: Bool) -> Bool {
        if useOverall {
            return overall < bestOption.overall
        } else {
            return (throwing + cutting + defense) < (bestOption.throwing + bestOption.cutting + bestOption.defense)
        }
    }
}

class ContentViewViewModel: ObservableObject {
    @Published var playerList: [Player] = []
    @Published var selectedPlayers: [Player: Bool] = [:]
    @Published var teams: [Roster] = []
    public private(set) var bestOptionTeams: (RatingsVariance, [Roster]) = (RatingsVariance(), [])
    private var preliminaryTeams: [Roster] = []
    private var maxRating = 0.0
    private var minRating = 10.0
    @Published var playerName: String = ""
    @Published var playerRating: Double = 0.0
    @Published var numberOfTeams: Int = 2
    @Published var ratingVariance = 0.4
    @Published var throwVariance = 0.4
    @Published var cutVariance = 0.4
    @Published var defenseVariance = 0.4
    @Published var useOverall = false
    @Published var teamDiffError = false
    var teamErrorString = "No teams found with the specified parameters. The best option found has a difference of -0.0"
    private var generationCount = 0
    
    private func createTeams() {
        generateTeams()
        guard !preliminaryTeams.isEmpty else { return }

        var bestThrowDiff = Double.greatestFiniteMagnitude
        var bestCutDiff = Double.greatestFiniteMagnitude
        var bestDefenseDiff = Double.greatestFiniteMagnitude
        var totalDiff = RatingsVariance()
        while ((bestThrowDiff > totalDiff.throwing || bestCutDiff > totalDiff.cutting || bestDefenseDiff > totalDiff.defense) &&
               totalDiff.overall > ratingVariance)
                && generationCount < (useOverall ? 600 : 2000) {
            generateTeams()

            var (maxThrow, minThrow) = (0.0, 10.0)
            var (maxCut, minCut) = (0.0, 10.0)
            var (maxDefense, minDefense) = (0.0, 10.0)
            var (maxRating, minRating) = (0.0, 10.0)
            if useOverall {
                preliminaryTeams.forEach { team in
                    maxRating = max(maxRating, team.averageRating)
                    minRating = min(minRating, team.averageRating)
                }
                totalDiff.overall = maxRating - minRating
            } else {
                preliminaryTeams.forEach { team in
                    maxThrow = max(maxThrow, team.averageThrowRating)
                    minThrow = min(minThrow, team.averageThrowRating)
                    maxCut = max(maxCut, team.averageCutRating)
                    minCut = min(minCut, team.averageCutRating)
                    maxDefense = max(maxDefense, team.averageDefenseRating)
                    minDefense = min(minDefense, team.averageDefenseRating)
                }
                
                bestThrowDiff = maxThrow - minThrow
                bestCutDiff = maxCut - minCut
                bestDefenseDiff = maxDefense - minDefense
                
                totalDiff.throwing = bestThrowDiff
                totalDiff.cutting = bestCutDiff
                totalDiff.defense = bestDefenseDiff
            }
            let currentBestDiff = bestOptionTeams.0

            if totalDiff.compareTo(currentBestDiff, useOverall: useOverall) {
                bestOptionTeams = (totalDiff, preliminaryTeams)
            }
            generationCount += 1
        }
        let teamError: Bool
        if useOverall {
            teamError = bestOptionTeams.0.overall > ratingVariance
            teamErrorString = "No teams found with the specified parameters. The best option found has a difference of \(String(format:"%g", bestOptionTeams.0.overall))"
        } else {
            teamError = bestThrowDiff > throwVariance || bestCutDiff > cutVariance || bestDefenseDiff > defenseVariance
            teamErrorString = "No teams found with the specified parameters. The best option found has a difference of throwing: \(String(format:"%g", bestOptionTeams.0.throwing)) \n cutting: \(String(format:"%g", bestOptionTeams.0.cutting)) \n defense: \(String(format:"%g", bestOptionTeams.0.throwing))"
        }
        if teamError {
            teamDiffError = true
        } else {
            teams = bestOptionTeams.1
            preliminaryTeams.removeAll()
            reset()
        }
    }

    
    private func generateTeams() {
        preliminaryTeams = (1...numberOfTeams).map { Roster(name: "Team \($0)") }
        
        let selectedRoster = selectedPlayers.filter { $0.value }.keys
        var selectedMMP = selectedRoster.filter { $0.gender == .mmp }.shuffled()
        var selectedWMP = selectedRoster.filter { $0.gender == .wmp }.shuffled()
        
        let maxMMPPerTeam = calculateMaxPlayers(for: selectedMMP.count)
        let maxWMPPerTeam = calculateMaxPlayers(for: selectedWMP.count)
        
        var teamNumbers: [Int: (Int, Int)] = [:] // Tracks (MMP count, WMP count) per team
        (1...numberOfTeams).forEach { teamNumbers[$0] = (0, 0) }
        
        // Unified distribution function for MMP and WMP players
        distributePlayers(&selectedMMP, &selectedWMP, maxMMPPerTeam, maxWMPPerTeam, &teamNumbers)
    }

    // Helper function to calculate max number of players per team
    private func calculateMaxPlayers(for totalPlayerCount: Int) -> Int {
        return Int((Double(totalPlayerCount) / Double(numberOfTeams)).rounded(.awayFromZero))
    }

    private func distributePlayers(_ mmpQueue: inout [Player], _ wmpQueue: inout [Player], _ maxMMPPerTeam: Int, _ maxWMPPerTeam: Int, _ teamNumbers: inout [Int: (Int, Int)]) {
        let teamOrder = (1...numberOfTeams).shuffled() // Prevents bias in cases of unequal numbers/gender ratio
        let maxPerTeam = calculateMaxPlayers(for: mmpQueue.count + wmpQueue.count)
        while !mmpQueue.isEmpty || !wmpQueue.isEmpty {
            for teamIndex in teamOrder {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex] {
                    var totalPlayers = mmpCount + wmpCount
                    // Distribute MMP if there's room and we haven't exceeded the max
                    if !mmpQueue.isEmpty, mmpCount < maxMMPPerTeam, totalPlayers < maxPerTeam {
                        let player = mmpQueue.removeFirst()
                        preliminaryTeams[teamIndex - 1].players.append(player)
                        teamNumbers[teamIndex]?.0 = mmpCount + 1
                        totalPlayers += 1
                    }

                    // Distribute WMP similarly
                    if !wmpQueue.isEmpty, wmpCount < maxWMPPerTeam, totalPlayers < maxPerTeam {
                        let player = wmpQueue.removeFirst()
                        preliminaryTeams[teamIndex - 1].players.append(player)
                        teamNumbers[teamIndex]?.1 = wmpCount + 1
                    }
                    
                    // Stop early if queues are empty
                    if mmpQueue.isEmpty && wmpQueue.isEmpty { return }
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
        bestOptionTeams = (RatingsVariance(), [])
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
            player.updatePlayer([.wins(player.wins)], context: context)
        }
    }
    
    func teamLoss(_ roster: Roster, context: NSManagedObjectContext) {
        for player in roster.players {
            player.losses += 1
            player.updatePlayer([.losses(player.losses)], context: context)
        }
    }
    
    func teamTie(_ roster: Roster, context: NSManagedObjectContext) {
        for player in roster.players {
            player.ties += 1
            player.updatePlayer([.ties(player.ties)], context: context)
        }
    }
    
}
