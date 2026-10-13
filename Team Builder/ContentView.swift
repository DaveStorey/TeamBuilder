//
//  ContentView.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var popupRosterOptions = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.teams.isEmpty {
                    ContentUnavailableView {
                        Label("No Teams Yet", systemImage: "person.3.fill")
                    } description: {
                        Text("Add players to your roster, then build teams to get started.")
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.teams) { roster in
                                VStack(spacing: 0) {
                                    TeamSectionHeader(roster: roster, viewModel: viewModel)
                                        .padding(.horizontal)
                                        .padding(.top, 12)
                                        .padding(.bottom, 8)
                                    Divider()
                                    PlayerListView(roster: roster)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                }
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
                                .padding(.horizontal)
                                .dropDestination(for: String.self) { idStrings, _ in
                                    for idString in idStrings {
                                        viewModel.movePlayer(withID: idString, to: roster)
                                    }
                                    return true
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Team Builder")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(
                        destination: RosterView(playerList: $viewModel.playerList, selectedPlayers: $viewModel.selectedPlayers),
                        label: { Label("Add Players", systemImage: "person.badge.plus") }
                    )
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { popupRosterOptions = true }) {
                        Label("Team Options", systemImage: "slider.horizontal.3")
                    }
                }
                if !viewModel.selectedPlayers.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            withAnimation {
                                viewModel.randomize()
                            }
                        }) {
                            Label("Build Teams", systemImage: "shuffle")
                        }
                    }
                }
                if !viewModel.teams.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { viewModel.saveCurrentTeams() }) {
                            Label("Save Teams", systemImage: "square.and.arrow.down")
                        }
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.teamDiffError) {
            Alert(
                title: Text("Team Differential Error"),
                message: Text(viewModel.teamErrorString),
                primaryButton: .default(Text("Use best option")) { viewModel.choseBestOption(true) },
                secondaryButton: .cancel {
                    viewModel.choseBestOption(false)
                    popupRosterOptions = true
                }
            )
        }
        .popover(isPresented: $popupRosterOptions) {
            let baseHeight: CGFloat = viewModel.useOverall ? 300 : 500
            let extraHeight: CGFloat = viewModel.autoAdjustRatings ? 260 : 60
            TeamOptionsView(viewModel: viewModel)
                .presentationDetents([.height(baseHeight + extraHeight), .large])
        }
        .onAppear {
            viewModel.loadSavedTeams()
        }
    }
}

struct TeamSectionHeader: View {
    @ObservedObject var roster: Roster
    @ObservedObject var viewModel: ContentViewViewModel

    var body: some View {
        NavigationLink(destination: TeamResultView(viewModel: viewModel, team: roster.name)) {
            HStack {
                Label(roster.name, systemImage: "flag.fill")
                    .font(.headline)
                    .foregroundStyle(.indigo)
                Spacer()
                TeamInfoView(roster: roster)
            }
            .padding(.vertical, 4)
        }
    }
}

struct TeamInfoView: View {
    @ObservedObject var roster: Roster

    var body: some View {
        HStack(spacing: 6) {
            genderBadge(count: roster.numberOfPlayers(for: .mmp), color: .blue)
            genderBadge(count: roster.numberOfPlayers(for: .wmp), color: .green)
            Text(String(format: "%.2f", roster.averageRating))
                .font(.caption.bold())
                .monospacedDigit()
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.indigo.opacity(0.18)))
                .foregroundStyle(.indigo)
        }
    }

    private func genderBadge(count: Int, color: Color) -> some View {
        Text("\(count)")
            .font(.caption.bold())
            .monospacedDigit()
            .frame(minWidth: 20)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.18)))
            .foregroundStyle(color)
    }
}

struct PlayerListView: View {
    @ObservedObject var roster: Roster

    var body: some View {
        if roster.players.isEmpty {
            Text("Drag a player here")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        } else {
            ForEach(roster.players) { player in
                HStack(spacing: 10) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(player.gender == .mmp ? .blue : .green)
                    Text(player.name)
                        .lineLimit(1, reservesSpace: true)
                    Spacer()
                    Text(player.gender.displayText)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill((player.gender == .mmp ? Color.blue : Color.green).opacity(0.15)))
                        .foregroundStyle(player.gender == .mmp ? .blue : .green)
                }
                .padding(.vertical, 10)
                .contentShape(Rectangle())
                .draggable(player.idString)
            }
        }
    }
}
