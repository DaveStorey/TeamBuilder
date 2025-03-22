//
//  RosterInfoView.swift
//  Team Builder
//
//  Created by David Storey on 3/22/25.
//

import SwiftUI

struct RosterInfoView: View {
    private enum SortedBy: String {
        case percent = "Percentage"
        case wins = "Wins"
        case losses = "Losses"
        case name = "Name"
        
        var next: SortedBy {
            switch self {
            case .percent: return .wins
            case .wins: return .losses
            case .losses: return .name
            case .name: return .percent
            }
        }
    }
    
    let players: [Player]
    @State private var storedSortedBy: SortedBy = .percent
    
    var body: some View {
        List {
            ForEach(players.sorted(by: {
                if storedSortedBy == .percent {
                    if $0.winningPercentage == $1.winningPercentage {
                        return $0.wins > $1.wins
                    } else {
                        return $0.winningPercentage > $1.winningPercentage
                    }
                } else if storedSortedBy == .wins {
                    return $0.wins > $1.wins
                } else if storedSortedBy == .losses {
                    return $0.losses > $1.losses
                } else {
                    return $0.name < $1.name
                }
            })) { player in
                Section(header: HStack {
                    Spacer()
                    Text("\(player.name) (\(String(format: "%.2f", player.winningPercentage)))").font(.headline)
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
        .toolbar {
            ToolbarItem(placement: .automatic, content: {
                Button("Sort", action: {
                    storedSortedBy = storedSortedBy.next
                })
            })
        }
    }
}
