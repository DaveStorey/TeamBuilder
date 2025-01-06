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
    @Environment(\.managedObjectContext) var viewContext
    @Binding var playerList: [Player]
    @Binding var selectedPlayers: [Player: Bool]
    @State var playerName: String = ""
    @State var playerRating: Double = 0.0
    @State var playerMatch: GenderMatch = .mmp
    @State var displayPlayerInfo = false
    @State private var playerInfo: Player = Player(name: "", overallRating: 0.0, match: .mmp, wins: 0, losses: 0)
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack() {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            VStack() {
                Text("Roster")
                    .font(.headline)
                VStack() {
                    List($playerList) { player in
                        HStack {
                            Text(player.wrappedValue.name)
                            Text(player.wrappedValue.gender.displayText)
                            Text("\(String(format:"%g", player.wrappedValue.rating))")
                            if selectedPlayers.first(where: { $0.key == player.wrappedValue })?.value == true { Image(systemName: "checkmark") }
                        }
                        .swipeActions(edge: .trailing) {
                            withAnimation {
                                Button(role: .destructive) { playerDelete(Player(name: player.wrappedValue.name, overallRating: player.wrappedValue.rating)) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                let keyValue = selectedPlayers.first(where: { $0.key == player.wrappedValue})?.value ?? true
                                selectedPlayers.updateValue(!keyValue, forKey: player.wrappedValue)
                            }
                        }
                        .onLongPressGesture(perform: {
                            displayPlayerInfo = true
                            playerInfo = player.wrappedValue })
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
                        savePlayer(Player(name: playerName, overallRating: playerRating, match: playerMatch) )
                    }
                }, label: { Text("Save").foregroundStyle(.white) })
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onSubmit {
                    isFocused = false
                }
            }
        }
        .onAppear { getPlayers() }
        .popover(isPresented: $displayPlayerInfo, content: {
            PlayerInfoView(player: $playerInfo)
        })
    }
    
    private func rosterDelete() {
        playerList.removeAll()
        let fetch: NSFetchRequest<NSFetchRequestResult>
        fetch = NSFetchRequest(entityName: "PersistedPlayer")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        deleteRequest.resultType = .resultTypeStatusOnly
        do {
            let _ = try viewContext.execute(deleteRequest)
        } catch (let error) {
            print("Player delete error: \(error.localizedDescription)")
        }
    }
    
    private func playerDelete(_ player: Player) {
        playerList.removeAll(where: { $0.name == player.name })
        player.deletePlayers(context: viewContext)
    }
    
    private func playerBuilder() -> some View {
        VStack(spacing: 5) {
            TextField("Player Name", text: $playerName)
                .padding()
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .autocorrectionDisabled(true)
            
            Picker(selection: $playerMatch, label: Text("Gender Match")) {
                Text("MMP").tag(GenderMatch.mmp)
                Text("WMP").tag(GenderMatch.wmp)
            }
            .pickerStyle(.automatic)
            
            TextField("Player Rating", value: $playerRating, format: .number)
                .padding()
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
        }
    }
    
    private func savePlayer(_ player: Player) {
        player.savePlayer(context: viewContext)
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
                    playerList.append(Player(name: player.name ?? "",
                                             overallRating: player.overallRating,
                                             match: match,
                                             wins: Int(player.wins),
                                             losses: Int(player.losses)
                                            ))
                }
            }
        } catch(let error) {
            print("Player fetching error: \(error.localizedDescription)")
        }
    }
}
