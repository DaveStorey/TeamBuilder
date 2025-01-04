//
//  PlayerInfoView.swift
//  Team Builder
//
//  Created by David Storey on 1/3/25.
//

import SwiftUI

struct PlayerInfoView: View {
    @Environment(\.dismiss) private var dismiss
    let player: Player
    
    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 15) {
                Text("\(player.name)")
                    .font(.headline)
                    .padding()
                Text("\(player.wins) wins")
                    .font(.subheadline)
                Text("\(player.losses) losses")
                    .font(.subheadline)
                Text("\(String(format:"%g", player.winningPercentage))")
                    .font(.subheadline)
            }
        }
    }
}
