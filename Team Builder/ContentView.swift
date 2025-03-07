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
            List {
                ForEach(viewModel.teams) { roster in
                    TeamSectionView(roster: roster, viewModel: viewModel)
                    PlayerListView(players: roster.players)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(
                        destination: PlayerCreationView(playerList: $viewModel.playerList, selectedPlayers: $viewModel.selectedPlayers),
                        label: { Text("Add Players") }
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Team Options") { popupRosterOptions = true }
                }
                if !viewModel.selectedPlayers.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Build Teams", action: {
                            withAnimation {
                                viewModel.randomize()
                            }
                        })
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
            TeamOptionsView(viewModel: viewModel)
                .presentationDetents([.height(viewModel.useOverall ? 250 : 450)])
        }
    }
}

struct TeamSectionView: View {
    let roster: Roster
    @ObservedObject var viewModel: ContentViewViewModel

    var body: some View {
        ZStack {
            Color.indigo
                .opacity(0.5)
                .ignoresSafeArea()
            HStack {
                NavigationLink(
                    destination: TeamResultView(viewModel: viewModel, team: roster.name),
                    label: { Text(roster.name).font(.headline).foregroundStyle(.white) }
                )
                TeamInfoView(roster: roster)
            }
        }
    }
}

struct TeamInfoView: View {
    let roster: Roster

    var body: some View {
        HStack {
            Text("(\(roster.numberOfPlayers(for: .mmp)) : \(roster.numberOfPlayers(for: .wmp)))")
                .font(.subheadline)
                .foregroundStyle(.white)
            Text("\(String(format: "%.2f", roster.averageRating))")
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding([.trailing])
        }
    }
}

struct PlayerListView: View {
    let players: [Player]

    var body: some View {
        ForEach(players) { player in
            HStack {
                Text(player.name)
                    .lineLimit(1, reservesSpace: true)
                Spacer()
                Text(player.gender.displayText)
                    .foregroundStyle(player.gender == .mmp ? .blue : .green)
            }
        }
    }
}
