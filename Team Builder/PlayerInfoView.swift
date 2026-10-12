//
//  PlayerInfoView.swift
//  Team Builder
//
//  Created by David Storey on 1/3/25.
//

import SwiftUI

struct PlayerInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var player: Player

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(player.gender == .mmp ? .blue : .green)
                        Text(player.name)
                            .font(.largeTitle.bold())
                        Text(player.gender.displayText)
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill((player.gender == .mmp ? Color.blue : Color.green).opacity(0.15)))
                            .foregroundStyle(player.gender == .mmp ? .blue : .green)
                    }
                    .padding(.top)

                    LazyVGrid(columns: columns, spacing: 14) {
                        PlayerStatView(label: "Overall", icon: "star.fill", value: String(format: "%g", player.overallRating))
                        PlayerStatView(label: "Throw", icon: "arrow.up.forward.circle.fill", value: String(format: "%g", player.throwRating))
                        PlayerStatView(label: "Cut", icon: "bolt.fill", value: String(format: "%g", player.cutRating))
                        PlayerStatView(label: "Defense", icon: "shield.fill", value: String(format: "%g", player.defenseRating))
                        PlayerStatView(label: "Wins", icon: "checkmark.circle.fill", value: "\(player.wins)", tint: .green)
                        PlayerStatView(label: "Losses", icon: "xmark.circle.fill", value: "\(player.losses)", tint: .red)
                        PlayerStatView(label: "Ties", icon: "equal.circle.fill", value: "\(player.ties)", tint: .orange)
                        PlayerStatView(label: "Win %", icon: "percent", value: String(format: "%.0f%%", player.winningPercentage * 100))
                        PlayerStatView(label: "Point Diff", icon: "plusminus.circle.fill", value: (player.pointDifferential >= 0 ? "+" : "") + "\(player.pointDifferential)", tint: player.pointDifferential >= 0 ? .green : .red)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: PlayerEditView(viewModel: PlayerEditViewViewModel(player: player))) {
                        Label("Edit Player", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Reusable Player Stat Card
struct PlayerStatView: View {
    var label: String
    var icon: String
    var value: String
    var tint: Color = .indigo
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .font(.title3)
            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
    }
}
