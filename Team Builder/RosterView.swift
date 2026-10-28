//
//  RosterView.swift
//  Team Builder
//
//  Created by David Storey on 3/28/24.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct RosterView: View {
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
    @State private var showFileImporter = false
    @State private var importResultMessage: String?
    @State private var showImportResult = false
    @State private var importQueue: [Player] = []
    @State private var currentDuplicate: Player?
    @State private var duplicateRenameText: String = ""
    @State private var importedCount = 0
    @State private var skippedDuplicateCount = 0
    @State private var pendingImportErrors: [CSVImportError] = []
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            playerListView
            playerBuilder
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Roster")
        .toolbar {
            ToolbarItem(placement: .destructiveAction, content: {
                Button(role: .destructive, action: { rosterClearAlert = true }) {
                    Label("Clear Roster", systemImage: "trash")
                }
            })
            ToolbarItem(placement: .automatic, content: {
                Button(action: { selectAllPlayers() }) {
                    Label("Select All", systemImage: "checkmark.circle")
                }
             })
            ToolbarItem(placement: .automatic, content: {
                Button(action: { showFileImporter = true }) {
                    Label("Import CSV", systemImage: "square.and.arrow.down.on.square")
                }
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
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.commaSeparatedText, .plainText], allowsMultipleSelection: false) { result in
            importCSV(from: result)
        }
        .alert("Import Roster", isPresented: $showImportResult, presenting: importResultMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
        .sheet(item: $currentDuplicate) { player in
            DuplicatePlayerPrompt(
                existingName: player.name,
                proposedName: $duplicateRenameText,
                isNameTaken: { isDuplicateName($0) },
                onSkip: skipCurrentDuplicate,
                onRename: confirmDuplicateRename
            )
            .presentationDetents([.height(280)])
        }
    }
}

private extension RosterView {
    
    // MARK: - Player List View
    var playerListView: some View {
        Group {
            if playerList.isEmpty {
                ContentUnavailableView {
                    Label("No Players", systemImage: "person.3")
                } description: {
                    Text("Create a player to add them to your roster.")
                }
            } else {
                List($playerList.sorted {
                    let lhs = $0.wrappedValue
                    let rhs = $1.wrappedValue
                    // Order players by winning percentage, then total wins, then alphabetically. Note switch of lhs/rhs for name, otherwise
                    // it sorts in reverse alphabetic order.
                    return (lhs.winningPercentage, lhs.wins, rhs.name) > (rhs.winningPercentage, rhs.wins, lhs.name)
                } ) { $player in
                    playerRow(player: player)
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    @ViewBuilder
    private func playerRow(player: Player) -> some View {
        let isSelected = selectedPlayers[player] ?? false
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.4))

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.body)
                Text(String(format: "%.0f%% win rate", player.winningPercentage * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(player.gender.displayText)
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill((player.gender == .mmp ? Color.blue : Color.green).opacity(0.15)))
                .foregroundStyle(player.gender == .mmp ? .blue : .green)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
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
            }, label: { Label("Info", systemImage: "info.circle") })
            .tint(.indigo)
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
        HStack(spacing: 12) {
            NavigationLink(destination: { PlayerCreationView(playerList: $playerList) }) {
                Label("Create Player", systemImage: "person.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            NavigationLink(destination: { RosterInfoView(players: playerList)}) {
                Label("Records", systemImage: "chart.bar.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .controlSize(.large)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
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

    // MARK: - CSV Import
    private func importCSV(from result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer { if didStartAccessing { url.stopAccessingSecurityScopedResource() } }
            do {
                let contents = try String(contentsOf: url, encoding: .utf8)
                let (parsedPlayers, errors) = CSVPlayerImporter.parse(contents)
                importedCount = 0
                skippedDuplicateCount = 0
                pendingImportErrors = errors
                importQueue = parsedPlayers
                processImportQueue()
            } catch {
                importResultMessage = CSVImportError.fileUnreadable(error.localizedDescription).errorDescription
                showImportResult = true
            }
        case .failure(let error):
            importResultMessage = CSVImportError.fileUnreadable(error.localizedDescription).errorDescription
            showImportResult = true
        }
    }

    // Adds players until a duplicate name is hit, then pauses to prompt the user.
    private func processImportQueue() {
        while !importQueue.isEmpty {
            let player = importQueue.removeFirst()
            if isDuplicateName(player.name) {
                duplicateRenameText = player.name
                currentDuplicate = player
                return
            }
            addPlayer(player)
        }
        finishImport()
    }

    private func isDuplicateName(_ name: String) -> Bool {
        playerList.contains { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    private func addPlayer(_ player: Player) {
        player.savePlayer(context: viewContext)
        playerList.append(player)
        importedCount += 1
    }

    private func skipCurrentDuplicate() {
        skippedDuplicateCount += 1
        currentDuplicate = nil
        processImportQueue()
    }

    private func confirmDuplicateRename() {
        guard let player = currentDuplicate else { return }
        let trimmedName = duplicateRenameText.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, !isDuplicateName(trimmedName) else { return }
        player.name = trimmedName
        currentDuplicate = nil
        addPlayer(player)
        processImportQueue()
    }

    private func finishImport() {
        importResultMessage = importSummary(importedCount: importedCount, skippedDuplicateCount: skippedDuplicateCount, errors: pendingImportErrors)
        showImportResult = true
        importedCount = 0
        skippedDuplicateCount = 0
        pendingImportErrors = []
    }

    private func importSummary(importedCount: Int, skippedDuplicateCount: Int, errors: [CSVImportError]) -> String {
        var lines = ["Imported \(importedCount) player\(importedCount == 1 ? "" : "s")."]
        if skippedDuplicateCount > 0 {
            lines.append("Skipped \(skippedDuplicateCount) duplicate player\(skippedDuplicateCount == 1 ? "" : "s").")
        }
        if !errors.isEmpty {
            lines.append("\(errors.count) row\(errors.count == 1 ? "" : "s") skipped:")
            lines.append(contentsOf: errors.compactMap { $0.errorDescription })
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Fetching Players
    private func getPlayers() {
        let fetchRequest: NSFetchRequest<PersistedPlayer> = PersistedPlayer.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PersistedPlayer.name), ascending: true)]
        do {
            let persistedPlayers = try viewContext.fetch(fetchRequest)
            persistedPlayers.forEach { persistedPlayer in
                if let match = GenderMatch(rawValue: persistedPlayer.gender ?? "MMP"),
                   !playerList.contains(where: { $0.idString == persistedPlayer.idString }) {
                    playerList.append(Player(name: persistedPlayer.name ?? "",
                                            overallRating: persistedPlayer.overallRating,
                                            throwRating: persistedPlayer.throwRating,
                                            cutRating: persistedPlayer.cutRating,
                                            defenseRating: persistedPlayer.defenseRating,
                                            match: match,
                                            wins: Int(persistedPlayer.wins),
                                            losses: Int(persistedPlayer.losses),
                                            ties: Int(persistedPlayer.ties),
                                            pointDifferential: Int(persistedPlayer.pointDifferential),
                                            idString: persistedPlayer.idString ?? UUID().uuidString))
                }
            }
        } catch {
            print("Failed to fetch players: \(error.localizedDescription)")
        }
    }
}

private struct DuplicatePlayerPrompt: View {
    let existingName: String
    @Binding var proposedName: String
    let isNameTaken: (String) -> Bool
    let onSkip: () -> Void
    let onRename: () -> Void
    @FocusState private var isFocused: Bool

    private var trimmedName: String {
        proposedName.trimmingCharacters(in: .whitespaces)
    }

    private var canRename: Bool {
        !trimmedName.isEmpty && !isNameTaken(trimmedName)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("A player named \"\(existingName)\" is already in your roster.")
                        .foregroundStyle(.secondary)
                }
                Section(header: Text("New Name")) {
                    TextField("Name", text: $proposedName)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                    if trimmedName.isEmpty {
                        Text("Name cannot be empty.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else if isNameTaken(trimmedName) {
                        Text("That name is also already in your roster.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Duplicate Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip Player", role: .destructive, action: onSkip)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Rename & Import", action: onRename)
                        .disabled(!canRename)
                }
            }
            .onAppear { isFocused = true }
        }
    }
}
