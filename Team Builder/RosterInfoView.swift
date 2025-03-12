//
//  RosterInfoView.swift
//  Team Builder
//
//  Created by David Storey on 3/12/25.
//

import SwiftUI

struct RosterInfoView: View {
    let players: [Player]
    
    var body: some View {
        List {
            ForEach(players) { player in
                Section(header: HStack {
                    Spacer()
                    Text(player.name).font(.headline)
                    Spacer()
                }) {
                    HStack {
                        VStack {
                            Text("Wins")
                            Text("\(player.wins)")
                        }
                        Spacer()
                        VStack {
                            Text("Losses")
                            Text("\(player.losses)")
                        }
                        Spacer()
                        VStack {
                            Text("Ties")
                            Text("\(player.ties)")
                        }
                    }
                }
            }
        }
    }
}
