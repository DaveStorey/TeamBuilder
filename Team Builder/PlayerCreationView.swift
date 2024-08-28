//
//  PlayerCreationView.swift
//  Team Builder
//
//  Created by David Storey on 3/28/24.
//

import Foundation
import SwiftUI
import CoreData

struct PlayerCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var playerList: [Player]
    @Binding var selectedPlayers: [Player: Bool]
    @State var playerName: String = ""
    @State var playerRating: Double = 0.0
    @State var playerMatch: GenderMatch = .mmp
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            VStack() {
                Text("Roster")
                    .font(.headline)
                List($playerList) { player in
                    HStack {
                        Text(player.wrappedValue.name)
                        Text(player.wrappedValue.gender.displayText)
                        Text("\(String(format:"%g", player.wrappedValue.rating))")
                        if selectedPlayers.first(where: { $0.key == player.wrappedValue })?.value == true { Image(systemName: "checkmark") }
                    }
                    .swipeActions {
                        withAnimation {
                            Button(role: .destructive) { playerDelete(player.wrappedValue.name, rating: player.wrappedValue.rating) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onTapGesture {
                        let keyValue = selectedPlayers.first(where: { $0.key == player.wrappedValue})?.value ?? true
                        selectedPlayers.updateValue(!keyValue, forKey: player.wrappedValue)
                    }
                }
                if !playerList.isEmpty {
                    VStack(spacing: 15) {
                        Button(action: { withAnimation {
                            rosterDelete()
                        }
                        }, label: { Text("Clear Roster").foregroundStyle(.white)})
                        .padding()
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                playerBuilder()
                
                Button(action: {
                    withAnimation {
                        savePlayer(playerName: playerName, playerRating: playerRating)
                    }
                }, label: { Text("Save").foregroundStyle(.white) })
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .onAppear { getPlayers() }
    }
    
    private func rosterDelete() {
        playerList.removeAll()
        let fetch: NSFetchRequest<NSFetchRequestResult>
        fetch = NSFetchRequest(entityName: "PersistedPlayer")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        deleteRequest.resultType = .resultTypeStatusOnly
        do {
            let result = try viewContext.execute(deleteRequest)
        } catch (let error) {
            print("Batch delete error: \(error.localizedDescription)")
        }
    }
    
    private func playerDelete(_ name: String, rating: Double) {
        playerList.removeAll(where: { $0.name == name })
    }
    
    private func playerBuilder() -> some View {
        VStack(spacing: 5) {
            TextField("Player Name", text: $playerName)
                .padding()
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
            
            Picker(selection: $playerMatch, label: Text("Gender Match")) {
                Text("MMP").tag(GenderMatch.mmp)
                Text("WMP").tag(GenderMatch.wmp)
            }
            .pickerStyle(.automatic)
            
            TextField("Player Rating", value: $playerRating, format: .number)
                .padding()
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private func savePlayer(playerName: String, playerRating: Double) {
        let player = Player(name: playerName, overallRating: playerRating, match: self.playerMatch)
        let testPlayer = PersistedPlayer(context: viewContext)
        testPlayer.name = player.name
        testPlayer.createDate = Date()
        testPlayer.gender = player.gender.rawValue
        testPlayer.overallRating = player.overallRating
        do {
            viewContext.insert(testPlayer)
            try viewContext.save()
        } catch(let error) {
            print("Persistence context error: \(error.localizedDescription)")
        }
        if !playerList.contains(where: { $0.name == player.name && $0.rating == player.rating }) {
            playerList.append(player)
        }
        if !selectedPlayers.contains(where: { $0.key.name == player.name && $0.key.rating == player.rating }) {
            selectedPlayers.updateValue(true, forKey: player)
        }
        self.playerName = ""
        self.playerRating = 0.0
        self.isFocused = true
    }
    
    private func getPlayers() {
        let playerFetch: NSFetchRequest<PersistedPlayer> = PersistedPlayer.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(PersistedPlayer.name), ascending: true)
        playerFetch.sortDescriptors = [sortByName]
        do {
            let players = try viewContext.fetch(playerFetch)
            for player in players where !player.name.isNilOrEmpty {
                let match = GenderMatch(rawValue: player.gender ?? "MMP") ?? .mmp
                if !playerList.contains(where: { $0.name == player.name && $0.overallRating == player.overallRating}) {
                    playerList.append(Player(name: player.name ?? "", overallRating: player.overallRating, match: match))
                }
            }
        } catch(let error) {
            print("Fetching error: \(error.localizedDescription)")
        }
    }
}
    
