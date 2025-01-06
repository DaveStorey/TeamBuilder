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
                Color.secondary
                    .opacity(0.2)
                    .ignoresSafeArea()
                VStack(alignment: .center, spacing: 15) {
                    Text("\(player.name)")
                        .font(.largeTitle)
                        .padding()
                    Text("\(player.wins) wins")
                        .font(.headline)
                    Text("\(player.losses) losses")
                        .font(.headline)
                    Text("\(String(format:"%g", player.winningPercentage))")
                        .font(.headline)
                    Spacer()
                        .frame(height: 50)
                    NavigationLink(destination: { PlayerEditView(player: $player)},
                                   label: { Text("Edit").foregroundStyle(.white)})
                    .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}
