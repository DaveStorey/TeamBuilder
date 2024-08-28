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
        var maxRating = 0.0
        var minRating = 10.0
        for team in preliminaryTeams {
            if team.averageRating > maxRating {
                maxRating = team.averageRating
            }
            if team.averageRating < minRating  {
                minRating = team.averageRating
            }
        }
        let teamDifferential = minRating.distance(to: maxRating)
        if teamDifferential > ratingVariance, ContentViewViewModel.generationCount < 100 {
            if teamDifferential < bestOptionTeams.0 {
                bestOptionTeams = (teamDifferential, preliminaryTeams)
            }
            ContentViewViewModel.generationCount += 1
            randomize()
            return
        } else if ContentViewViewModel.generationCount >= 100 {
            teamDiffError = true
            return
        }
        teams = preliminaryTeams
        preliminaryTeams = []
        ContentViewViewModel.generationCount = 0
    }
    
    func generateTeams() {
        var teamNumbers: [Int: (Bool, Bool)] = [:]
        for element in 1...numberOfTeams {
            preliminaryTeams.append(Roster(name: "Team \(element)"))
            teamNumbers.updateValue((false, false), forKey: element)
        }
        let selectedRoster = selectedPlayers.filter({ $0.value })
        let selectedWMP = selectedRoster.filter({ $0.key.gender == .wmp })
        let selectedMMP = selectedRoster.filter({ $0.key.gender == .mmp })
        let maxMMP = Int((Double(selectedMMP.count) / Double(numberOfTeams)).rounded(.awayFromZero))
        let maxWMP = Int((Double(selectedWMP.count) / Double(numberOfTeams)).rounded(.awayFromZero))
        for selectedPlayer in selectedRoster {
            let player = selectedPlayer.key
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
                if preliminaryTeams[teamIndex].hasReachedGenderLimit(gender: player.gender, limit: limit) {
                    if teamNumbers[team]?.0 == false, teamNumbers[team]?.1 == false {
                        let updatedValue = player.gender == .mmp ? (true, false) : (false, true)
                        teamNumbers.updateValue(updatedValue, forKey: team)
                    } else {
                        teamNumbers.removeValue(forKey: team)
                    }
                }
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
