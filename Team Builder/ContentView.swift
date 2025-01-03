//
//  ContentView.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @StateObject var viewModel = ContentViewViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @State var popupRosterOptions = false
    @State var playerList: [Player] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.teams) { roster in
                    ZStack {
                        Color.indigo
                            .opacity(0.5)
                            .ignoresSafeArea()
                        HStack {
                            NavigationLink(destination : {
                                TeamResultView(viewModel: viewModel, team: roster.name)},
                                           label: {
                                Text(roster.name)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            })
                            Text("(\(roster.numberOfPlayers(for: .mmp)) : \(roster.numberOfPlayers(for: .wmp)))")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            Text("\(String(format:"%g", roster.averageRating))")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    ForEach(roster.players) { player in
                        HStack {
                            Text("\(player.name)")
                            Spacer()
                            Text("\(player.gender.displayText)")
                                .foregroundStyle(player.gender == .mmp ? .blue : .green)
                        }
                        
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: { PlayerCreationView(playerList: $viewModel.playerList, selectedPlayers: $viewModel.selectedPlayers) },
                                   label: { Text("Add Players") })
                    .navigationBarTitleDisplayMode(.inline)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { popupRosterOptions = true }, label: {
                        Text("Team Options")
                    })
                }
                if !viewModel.selectedPlayers.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Build Teams", action: randomize)
                    }
                }
            }
        }
        .alert("Team Differential Error", isPresented: $viewModel.teamDiffError, actions: {
            Button("Use best option", action: { viewModel.choseBestOption() })
            Button("Change team differential", action: {
                viewModel.teamDiffError = false
                popupRosterOptions = true
            })
        }, message: {
            Text("No teams found with the specified parameters. The best option found has a difference of \(String(format:"%g", viewModel.bestOptionTeams.0))")
        })
        .popover(isPresented: $popupRosterOptions) {
            TeamOptionsView(viewModel: viewModel)
                .presentationDetents([.height(250)])
        }
    }
    
    private func randomize() {
        withAnimation {
            viewModel.randomize()
        }
    }
    
}
