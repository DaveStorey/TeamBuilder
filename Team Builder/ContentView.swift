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
                    List {
                        ForEach(viewModel.teams) { roster in
                            Section {
                                PlayerListView(players: roster.players)
                            } header: {
                                TeamSectionHeader(roster: roster, viewModel: viewModel)
                                    .textCase(nil)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
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
    let roster: Roster
    @ObservedObject var viewModel: ContentViewViewModel

    var body: some View {
        NavigationLink(destination: TeamResultView(viewModel: viewModel, team: roster.name)) {
            HStack {
                Label(roster.name, systemImage: "shield.fill")
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
    let roster: Roster

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
    let players: [Player]

    var body: some View {
        ForEach(players) { player in
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
            .padding(.vertical, 2)
        }
    }
}
