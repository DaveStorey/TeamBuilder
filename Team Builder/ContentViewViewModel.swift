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
    @Published var playerName: String = ""
    @Published var playerRating: Double = 0.0
    @Published var numberOfTeams: Int = 2
    @Published var ratingVariance = 0.4
    @Published var teamDiffError = false
    static public private(set) var generationCount = 0
    private let teamLock = DispatchQueue(label: "teamLock")

    
    @MainActor
    private func createTeams() async {
        await generateTeams()
        guard !preliminaryTeams.isEmpty else { return }

        let (maxRating, minRating) = preliminaryTeams.reduce(into: (0.0, 10.0)) { result, team in
            result.0 = max(result.0, team.averageRating)
            result.1 = min(result.1, team.averageRating)
        }
        
        let teamDifferential = minRating.distance(to: maxRating)
        
        guard teamDifferential > ratingVariance else {
            teams = preliminaryTeams
            preliminaryTeams.removeAll()
            ContentViewViewModel.generationCount = 0
            return
        }

        if ContentViewViewModel.generationCount < 200 {
            if teamDifferential < bestOptionTeams.0 {
                bestOptionTeams = (teamDifferential, preliminaryTeams)
            }
            ContentViewViewModel.generationCount += 1
            await randomize() // Async randomization
        } else {
            teamDiffError = true
        }
    }

    private func generateTeams() async {
        var teamNumbers: [Int: (Int, Int)] = [:]
        preliminaryTeams = (1...numberOfTeams).map { Roster(name: "Team \($0)") }
        (1...numberOfTeams).forEach { teamNumbers[$0] = (0, 0) }

        let selectedRoster = selectedPlayers.filter { $0.value }.keys
        let selectedMMP = selectedRoster.filter { $0.gender == .mmp }
        let selectedWMP = selectedRoster.filter { $0.gender == .wmp }

        // Calculate max players per team
        let maxPlayersPerTeam = calculateMaxPlayers(forMMP: selectedRoster.count)
        let maxMMPPerTeam = calculateMaxPlayers(forMMP: selectedMMP.count)
        let maxWMPPerTeam = calculateMaxPlayers(forMMP: selectedWMP.count)

        // Phase 1: Distribute MMP and WMP players evenly across teams
        let mmpPlayerQueue = selectedMMP.shuffled()
        let wmpPlayerQueue = selectedWMP.shuffled()

        // First, distribute players to ensure each team gets at least one player of each gender if possible
        let (updatedTeamNumbers, updatedPreliminaryTeams) = await distributePlayersToTeams(
            mmpQueue: mmpPlayerQueue,
            wmpQueue: wmpPlayerQueue,
            teamNumbers: teamNumbers,
            maxMMPPerTeam: maxMMPPerTeam,
            maxWMPPerTeam: maxWMPPerTeam,
            maxPlayersPerTeam: maxPlayersPerTeam
        )
        
        preliminaryTeams = updatedPreliminaryTeams
        teamNumbers = updatedTeamNumbers

        // Phase 2: Distribute any leftover players
        let finalTeams = await distributeLeftoverPlayers(
            mmpQueue: mmpPlayerQueue,
            wmpQueue: wmpPlayerQueue,
            teamNumbers: teamNumbers,
            maxPlayersPerTeam: maxPlayersPerTeam
        )
        
        preliminaryTeams = finalTeams
    }

    private func calculateMaxPlayers(forMMP totalPlayerCount: Int) -> Int {
        return Int((Double(totalPlayerCount) / Double(numberOfTeams)).rounded(.awayFromZero))
    }

    private func distributePlayersToTeams(
        mmpQueue: [Player],
        wmpQueue: [Player],
        teamNumbers: [Int: (Int, Int)],
        maxMMPPerTeam: Int,
        maxWMPPerTeam: Int,
        maxPlayersPerTeam: Int
    ) async -> ([Int: (Int, Int)], [Roster]) {
        var teamNumbers = teamNumbers
        let preliminaryTeams = preliminaryTeams
        
        await withTaskGroup(of: Void.self) { [weak self] group in
            guard let self else { return }
            _ = group.addTaskUnlessCancelled {
                await self.distributeMMPPlayers(mmpQueue: mmpQueue, teamNumbers: &teamNumbers, maxMMPPerTeam: maxMMPPerTeam, maxPlayersPerTeam: maxPlayersPerTeam)
            }
            _ = group.addTaskUnlessCancelled {
                await self.distributeWMPPlayers(wmpQueue: wmpQueue, teamNumbers: &teamNumbers, maxWMPPerTeam: maxWMPPerTeam, maxPlayersPerTeam: maxPlayersPerTeam)
            }
        }

        return (teamNumbers, preliminaryTeams)
    }

    private func distributeMMPPlayers(
        mmpQueue: [Player],
        teamNumbers: inout [Int: (Int, Int)],
        maxMMPPerTeam: Int,
        maxPlayersPerTeam: Int
    ) async {
        var mutableMmpQueue = mmpQueue
        var teamNumbers = teamNumbers

        while !mutableMmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], mmpCount < maxMMPPerTeam && (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = mutableMmpQueue.removeFirst()
                    teamLock.sync {
                        preliminaryTeams[teamIndex - 1].players.append(player)
                    }
                    teamNumbers[teamIndex] = (mmpCount + 1, wmpCount)
                    if mutableMmpQueue.isEmpty { break }
                }
            }
        }
    }

    private func distributeWMPPlayers(
        wmpQueue: [Player],
        teamNumbers: inout [Int: (Int, Int)],
        maxWMPPerTeam: Int,
        maxPlayersPerTeam: Int
    ) async {
        var mutableWmpQueue = wmpQueue
        var teamNumbers = teamNumbers

        while !mutableWmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], wmpCount < maxWMPPerTeam && (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = mutableWmpQueue.removeFirst()
                    teamLock.sync {
                        preliminaryTeams[teamIndex - 1].players.append(player)
                    }

                    teamNumbers[teamIndex] = (mmpCount, wmpCount + 1)
                    if mutableWmpQueue.isEmpty { break }
                }
            }
        }
    }

    private func distributeLeftoverPlayers(
        mmpQueue: [Player],
        wmpQueue: [Player],
        teamNumbers: [Int: (Int, Int)],
        maxPlayersPerTeam: Int
    ) async -> [Roster] {
        var mutableMmpQueue = mmpQueue
        var mutableWmpQueue = wmpQueue
        var teamNumbers = teamNumbers

        while !mutableMmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = mutableMmpQueue.removeFirst()
                    teamLock.sync {
                        preliminaryTeams[teamIndex - 1].players.append(player)
                    }
                    teamNumbers[teamIndex] = (mmpCount + 1, wmpCount)
                    if mutableMmpQueue.isEmpty { break }
                }
            }
        }

        while !mutableWmpQueue.isEmpty {
            for teamIndex in teamNumbers.keys.sorted() {
                if let (mmpCount, wmpCount) = teamNumbers[teamIndex], (mmpCount + wmpCount) < maxPlayersPerTeam {
                    let player = mutableWmpQueue.removeFirst()
                    teamLock.sync {
                        preliminaryTeams[teamIndex - 1].players.append(player)
                    }
                    teamNumbers[teamIndex] = (mmpCount, wmpCount + 1)
                    if mutableWmpQueue.isEmpty { break }
                }
            }
        }

        return preliminaryTeams
    }

    @MainActor
    func randomize() async {
        teams = []
        preliminaryTeams = []
        bestOptionTeams = (10, [])
        await createTeams()
    }
    
    func choseBestOption(_ choseBestOption: Bool) {
        teamDiffError = false
        ContentViewViewModel.generationCount = 0
        if choseBestOption {
            teams = bestOptionTeams.1
        }
    }
    
    func addPlayerViewAppear() {
        selectedPlayers.removeAll()
    }
    
    func teamWin(_ team: String, context: NSManagedObjectContext) {
        let roster = teams.first { $0.name == team }!
        for player in roster.players {
            player.wins += 1
            player.updatePlayer(context: context)
        }
    }
    
    func teamLoss(_ team: String, context: NSManagedObjectContext) {
        let roster = teams.first { $0.name == team }!
        for player in roster.players {
            player.losses += 1
            player.updatePlayer(context: context)
        }
    }
    
}
