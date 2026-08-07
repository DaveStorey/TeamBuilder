//
//  TeamResultView.swift
//  Team Builder
//
//  Created by David Storey on 1/3/25.
//

import SwiftUI

struct TeamResultView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    var viewModel: ContentViewViewModel
    @State private var teamScore: Int = 0
    @State private var opponentScore: Int = 0
    @State private var selectedOpponent: String = ""
    let team: String

    private var otherTeams: [Roster] {
        viewModel.teams.filter { $0.name != team }
    }

    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Game Result")
                    .font(.largeTitle)
                    .padding(.top)

                if otherTeams.count > 1 {
                    Text("Select \(team)'s opponent")
                    Picker("Opponent", selection: $selectedOpponent) {
                        ForEach(otherTeams, id: \.name) { roster in
                            Text(roster.name).tag(roster.name)
                        }
                    }
                    .pickerStyle(.automatic)
                    .padding(.horizontal)
                }

                HStack(spacing: 40) {
                    scoreColumn(label: team, score: $teamScore)
                    Text("vs")
                        .font(.title2)
                    scoreColumn(label: selectedOpponent.isEmpty ? "Opponent" : selectedOpponent, score: $opponentScore)
                }
                .padding()

                Button(action: {
                    viewModel.gameResult(team: team, teamScore: teamScore, opponent: selectedOpponent, opponentScore: opponentScore, context: viewContext)
                    dismiss()
                }, label: {
                    Text("Save")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(minWidth: 120)
                        .background(selectedOpponent.isEmpty ? Color.gray : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                })
                .disabled(selectedOpponent.isEmpty)
            }
        }
        .onAppear {
            selectedOpponent = otherTeams.first?.name ?? ""
        }
    }

    @ViewBuilder
    private func scoreColumn(label: String, score: Binding<Int>) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.headline)
                .lineLimit(1)
            Stepper("\(score.wrappedValue)", value: score, in: 0...99)
                .labelsHidden()
            Text("\(score.wrappedValue)")
                .font(.system(size: 44, weight: .bold))
                .monospacedDigit()
        }
    }
}
