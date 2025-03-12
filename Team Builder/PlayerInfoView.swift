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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.secondary.opacity(0.2)
                    .ignoresSafeArea()

                VStack(spacing: 15) {
                    // Player Info Header
                    Text(player.name)
                        .font(.largeTitle)
                        .padding()

                    // Player Stats Section
                    PlayerStatView(label: "Overall Rating", value: String(format: "%g", player.overallRating))
                    PlayerStatView(label: "Throw Rating", value: String(format: "%g", player.throwRating))
                    PlayerStatView(label: "Cut Rating", value: String(format: "%g", player.cutRating))
                    PlayerStatView(label: "Defense Rating", value: String(format: "%g", player.defenseRating))
                    PlayerStatView(label: "Wins", value: "\(player.wins)")
                    PlayerStatView(label: "Losses", value: "\(player.losses)")
                    PlayerStatView(label: "Ties", value: "\(player.ties)")
                    PlayerStatView(label: "Winning Percentage", value: String(format: "%g", player.winningPercentage))
                    
                    Spacer()
                        .frame(height: 50)
                    
                    // Edit Button
                    NavigationLink(destination: PlayerEditView(player: $player, frozenPlayer: player.valueCopy())) {
                        Text("Edit")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
        }
    }
}

// Reusable Player Stat View
struct PlayerStatView: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack() {
            Text(label)
                .font(.headline)
            Text(value)
                .font(.body)
        }
        .padding(.horizontal)
    }
}
