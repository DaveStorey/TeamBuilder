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
        ScrollView {
            VStack(spacing: 24) {
                Label("Game Result", systemImage: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.indigo)
                    .padding(.top)

                if otherTeams.count > 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select \(team)'s opponent")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Picker("Opponent", selection: $selectedOpponent) {
                            ForEach(otherTeams, id: \.name) { roster in
                                Text(roster.name).tag(roster.name)
                            }
                        }
                        .pickerStyle(.automatic)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
                    .padding(.horizontal)
                }

                HStack(spacing: 24) {
                    scoreColumn(label: team, score: $teamScore)
                    Text("vs")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                    scoreColumn(label: selectedOpponent.isEmpty ? "Opponent" : selectedOpponent, score: $opponentScore)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
                .padding(.horizontal)

                Button(action: {
                    viewModel.gameResult(team: team, teamScore: teamScore, opponent: selectedOpponent, opponentScore: opponentScore, context: viewContext)
                    dismiss()
                }) {
                    Label("Save", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
                .disabled(selectedOpponent.isEmpty)
            }
            .padding(.bottom)
        }
        .background(Color(.systemGroupedBackground))
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
        .frame(maxWidth: .infinity)
    }
}
