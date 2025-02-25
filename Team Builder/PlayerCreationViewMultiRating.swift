//
//  PlayerCreationViewMultiRating.swift
//  Team Builder
//
//  Created by David Storey on 2/25/25.
//

import SwiftUI

struct PlayerCreationViewMultiRating: View {
    @State private var name = ""
    @State private var overallRating = 0.0
    @State private var throwRating = 0.0
    @State private var cutRating = 0.0
    @State private var defenseRating = 0.0
    @State private var gender: GenderMatch = .mmp
    @State private var wins = 0
    @State private var losses = 0
    @State private var ties = 0
    @Binding var playerList: [Player]
    @Environment(\.managedObjectContext) var viewContext
        
    var body: some View {
        Form {
            Section(header: Text("Player Information")) {
                TextField("Name", text: $name)
                genderPicker
            }
            
            Section(header: Text("Ratings")) {
                Slider(value: $overallRating, in: 0...10, step: 0.01) {
                    Text("Overall Rating")
                }
                Text("Overall Rating: \(overallRating, specifier: "%.2f")")
                
                Slider(value: $throwRating, in: 0...10, step: 0.01) {
                    Text("Throw Rating")
                }
                Text("Throw Rating: \(throwRating, specifier: "%.2f")")
                
                Slider(value: $cutRating, in: 0...10, step: 0.01) {
                    Text("Cut Rating")
                }
                Text("Cut Rating: \(cutRating, specifier: "%.2f")")
                
                Slider(value: $defenseRating, in: 0...10, step: 0.01) {
                    Text("Defense Rating")
                }
                Text("Defense Rating: \(defenseRating, specifier: "%.2f")")
            }
            
            Section(header: Text("Record")) {
                Stepper("Wins: \(wins)", value: $wins)
                Stepper("Losses: \(losses)", value: $losses)
                Stepper("Ties: \(ties)", value: $ties)
            }
            
            Button(action: savePlayer) {
                Text("Save Player")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .navigationTitle("Create Player")
    }
}

extension PlayerCreationViewMultiRating {
    
    private var genderPicker: some View {
        Picker("Gender Match", selection: $gender) {
            Text("MMP").tag(GenderMatch.mmp)
            Text("WMP").tag(GenderMatch.wmp)
        }
        .pickerStyle(InlinePickerStyle())
    }
    
    private func savePlayer() {
        let newPlayer = Player(name: name,
                               overallRating: overallRating,
                               throwRating: throwRating,
                               cutRating: cutRating,
                               defenseRating: defenseRating,
                               match: gender,
                               wins: wins,
                               losses: losses,
                               ties: ties)
        newPlayer.savePlayer(context: viewContext)
        if !playerList.contains(where: { $0.name == newPlayer.name && $0.overallRating == newPlayer.overallRating }) {
            playerList.append(newPlayer)
        }
        
//        if !selectedPlayers.contains(where: { $0.key.name == newPlayer.name && $0.key.overallRating == newPlayer.overallRating }) {
//            selectedPlayers[newPlayer] = true
//        }
    }
}
