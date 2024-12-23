//
//  ContentViewViewModel.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import Foundation
import CoreData
import Combine


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
    private var disposeBag: [AnyCancellable] = []
    
    private func createTeams() {
        generateTeams()
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
        if ContentViewViewModel.generationCount < 100 {
            if teamDifferential < bestOptionTeams.0 {
                bestOptionTeams = (teamDifferential, preliminaryTeams)
            }
            ContentViewViewModel.generationCount += 1
            randomize()
        } else {
            teamDiffError = true
        }
    }
    
    func generateTeams() {
        // teamNumbers keeps track of whether gender matches for that team are full
        var teamNumbers: [Int: (Bool, Bool)] = [:]
        for element in 1...numberOfTeams {
            preliminaryTeams.append(Roster(name: "Team \(element)"))
            teamNumbers.updateValue((false, false), forKey: element)
        }
        let selectedRoster = selectedPlayers.filter({ $0.value }).keys
        let selectedWMP = selectedRoster.filter({ $0.gender == .wmp })
        let selectedMMP = selectedRoster.filter({ $0.gender == .mmp })
        let maxMMP = Int((Double(selectedMMP.count) / Double(numberOfTeams)).rounded(.awayFromZero))
        let maxWMP = Int((Double(selectedWMP.count) / Double(numberOfTeams)).rounded(.awayFromZero))
        let maxPlayers = Int((Double(selectedRoster.count) / Double(numberOfTeams)).rounded(.awayFromZero))
        for selectedPlayer in selectedRoster {
            findTeamForPlayer(player: selectedPlayer,
                              teamNumbers: &teamNumbers,
                              maxMMP: maxMMP,
                              maxWMP: maxWMP,
                              maxPlayers: maxPlayers)
        }
    }
    
    private func findTeamForPlayer(player: Player, teamNumbers: inout [Int: (Bool, Bool)], maxMMP: Int, maxWMP: Int, maxPlayers: Int) {
        var team: Int?
        if player.gender == .mmp {
            team = teamNumbers.filter({ !$0.value.0 }).keys.randomElement()
        } else {
            team = teamNumbers.filter({ !$0.value.1 }).keys.randomElement()
        }
        if let team {
            let teamIndex = team - 1
            let limit = player.gender == .mmp ? maxMMP : maxWMP
            preliminaryTeams[teamIndex].players.append(player)
            // Checks if team has reached limit on one gender match or the other. If both reached, team is removed from pool of options.
            if preliminaryTeams[teamIndex].hasReachedGenderLimit(gender: player.gender, limit: limit) {
                if teamNumbers[team]?.0 == false, teamNumbers[team]?.1 == false {
                    let updatedValue = player.gender == .mmp ? (true, false) : (false, true)
                    teamNumbers.updateValue(updatedValue, forKey: team)
                } else {
                    teamNumbers.removeValue(forKey: team)
                }
            }
            // Checks if team has reached max number of players.
            if preliminaryTeams[teamIndex].players.count >= maxPlayers {
                teamNumbers.removeValue(forKey: team)
            }
        }
    }
    
    func choseBestOption() {
        teamDiffError = false
        teams = bestOptionTeams.1
    }
    
    func addPlayerViewAppear() {
        selectedPlayers.removeAll()
    }
    
    func randomize() {
        teams = []
        preliminaryTeams = []
        createTeams()
    }
    
    func savePlayer() {
        let player = Player(name: playerName, overallRating: playerRating)
        playerList.append(player)
    }
}
