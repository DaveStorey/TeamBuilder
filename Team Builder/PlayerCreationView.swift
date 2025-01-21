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
    @State private var playerName: String = ""
    @State private var playerRating: Double = 0.0
    @State private var playerMatch: GenderMatch = .mmp
    @State private var displayPlayerInfo = false
    @State private var rosterClearAlert = false
    @State private var playerInfo: Player = Player(name: "", overallRating: 0.0, match: .mmp, wins: 0, losses: 0)
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                rosterHeader
                playerListView
                playerBuilder
                saveButton
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction, content: {
                Button("Clear Roster", action: { rosterClearAlert = true })
            })
            ToolbarItem(placement: .primaryAction, content: {
                Button("Select All", action: { selectAllPlayers() })
             })
        }
        .onAppear { getPlayers() }
        .popover(isPresented: $displayPlayerInfo, content: {
            PlayerInfoView(player: $playerInfo)
                .onDisappear {
                    // Reset displayPlayerInfo to false when the popover disappears
                    displayPlayerInfo = false
                }
        })
        .alert(isPresented: $rosterClearAlert) {
            Alert(
                title: Text("Clear Roster"),
                message: Text("Are you sure you want to clear your roster?"),
                primaryButton: .destructive(Text("Yes"), action: rosterDelete),
                secondaryButton: .cancel { rosterClearAlert = false }
            )
        }
    }
}

private extension PlayerCreationView {
    
    // MARK: - Header
    var rosterHeader: some View {
        Text("Roster")
            .font(.headline)
    }
    
    // MARK: - Player List View
    var playerListView: some View {
        List($playerList.sorted(by: {
            let lhs = $0.wrappedValue
            let rhs = $1.wrappedValue
            // Order players by winning percentage, then games played, then name
            if lhs.winningPercentage > rhs.winningPercentage {
                return true
            } else if lhs.wins > rhs.wins {
                return true
            } else {
                return lhs.name < rhs.name
            }
        } )) { $player in
            playerRow(player: player)
        }
    }
    
    @ViewBuilder
    private func playerRow(player: Player) -> some View {
        HStack {
            Text(player.name)
            Text(player.gender.displayText)
            Text("\(String(format: "%.2f", player.winningPercentage))")
            
            if let isSelected = selectedPlayers[player], isSelected {
                Image(systemName: "checkmark")
            }
        }
        .swipeActions(edge: .trailing) {
            deletePlayerAction(player)
        }
        .onTapGesture {
            togglePlayerSelection(player)
        }
        .swipeActions(edge: .leading) {
            Button(action: {
                displayPlayerInfo = true
                playerInfo = player
            }, label: { Label("Info", systemImage: "info")})
        }
    }

    private func deletePlayerAction(_ player: Player) -> some View {
        Button(role: .destructive) {
            playerDelete(player)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func togglePlayerSelection(_ player: Player) {
        withAnimation {
            let currentSelection = selectedPlayers[player] ?? false
            selectedPlayers[player] = !currentSelection
        }
    }
    
    private func selectAllPlayers() {
        withAnimation {
            selectedPlayers = playerList.reduce(into: [Player: Bool]()) {
                $0[$1] = true
            }
        }
    }

    // MARK: - Player Builder
    var playerBuilder: some View {
        VStack(spacing: 5) {
            playerNameField
            genderPicker
            playerRatingField
        }
        .frame(height: 175)
    }
    
    private var playerNameField: some View {
        TextField("Player Name", text: $playerName)
            .padding([.horizontal])
            .textFieldStyle(.roundedBorder)
            .focused($isFocused)
            .autocorrectionDisabled(true)
    }
    
    private var genderPicker: some View {
        Picker("Gender Match", selection: $playerMatch) {
            Text("MMP").tag(GenderMatch.mmp)
            Text("WMP").tag(GenderMatch.wmp)
        }
        .pickerStyle(InlinePickerStyle())
    }

    private var playerRatingField: some View {
        TextField("Player Rating", value: $playerRating, format: .number)
            .padding([.horizontal])
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button("Save") {
            withAnimation { savePlayer() }
        }
        .padding()
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .foregroundColor(.white)
        .onSubmit { isFocused = false }
    }
    
    // MARK: - Player Management
    private func savePlayer() {
        let newPlayer = Player(name: playerName, overallRating: playerRating, match: playerMatch)
        newPlayer.savePlayer(context: viewContext)
        
        if !playerList.contains(where: { $0.name == newPlayer.name && $0.rating == newPlayer.rating }) {
            playerList.append(newPlayer)
        }
        
        if !selectedPlayers.contains(where: { $0.key.name == newPlayer.name && $0.key.rating == newPlayer.rating }) {
            selectedPlayers[newPlayer] = true
        }
        
        clearPlayerFields()
    }
    
    private func playerDelete(_ player: Player) {
        playerList.removeAll { $0.name == player.name }
        player.deletePlayers(context: viewContext)
    }
    
    private func rosterDelete() {
        playerList.removeAll()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PersistedPlayer")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeStatusOnly
        
        do {
            let _ = try viewContext.execute(deleteRequest)
        } catch {
            print("Failed to delete players: \(error.localizedDescription)")
        }
    }

    private func clearPlayerFields() {
        playerName = ""
        playerRating = 0.0
        isFocused = true
    }

    // MARK: - Fetching Players
    private func getPlayers() {
        let fetchRequest: NSFetchRequest<PersistedPlayer> = PersistedPlayer.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PersistedPlayer.name), ascending: true)]
        
        do {
            let persistedPlayers = try viewContext.fetch(fetchRequest)
            persistedPlayers.forEach { persistedPlayer in
                // Printing player info on load in console for easy stat checking/compiling
                #if DEBUG
                print("\(persistedPlayer.name ?? "No Name")(\(persistedPlayer.overallRating)): wins: \(persistedPlayer.wins)\n losses: \(persistedPlayer.losses)\n ties: \(persistedPlayer.ties)")
                #endif
                if let match = GenderMatch(rawValue: persistedPlayer.gender ?? "MMP"),
                   !playerList.contains(where: { $0.name == persistedPlayer.name && $0.rating == persistedPlayer.overallRating }) {
                    playerList.append(Player(name: persistedPlayer.name ?? "",
                                              overallRating: persistedPlayer.overallRating,
                                              match: match,
                                              wins: Int(persistedPlayer.wins),
                                              losses: Int(persistedPlayer.losses)))
                }
            }
        } catch {
            print("Failed to fetch players: \(error.localizedDescription)")
        }
    }
}
