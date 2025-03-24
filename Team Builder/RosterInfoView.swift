//
//  RosterInfoView.swift
//  Team Builder
//
//  Created by David Storey on 3/12/25.
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
    @State private var sortedBy: SortedBy = .percent
    
    var body: some View {
        List {
            ForEach(players.sorted(by: {
                switch sortedBy {
                case .percent:
                    if $0.winningPercentage == $1.winningPercentage {
                        return $0.wins > $1.wins
                    } else {
                        return $0.winningPercentage > $1.winningPercentage
                    }
                case .wins :
                    return $0.wins > $1.wins
                case .losses:
                    return $0.losses > $1.losses
                case .name:
                    return $0.name < $1.name
                }
            })) { player in
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
        .toolbar {
            ToolbarItem(placement: .automatic, content: {
                        Button("Sorted by \(sortedBy.rawValue)", action: {
                            sortedBy = sortedBy.next
                        })
                    })
        }
    }
}
