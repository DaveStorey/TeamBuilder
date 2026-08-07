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
            case pointDiff = "Point Diff"
            
            var next: SortedBy {
                switch self {
                case .percent: return .wins
                case .wins: return .losses
                case .losses: return .name
                case .name: return .pointDiff
                case .pointDiff: return .percent
                }
            }
        }
    
    let players: [Player]
    @State private var sortedBy: SortedBy = .percent
    @AppStorage("goalValueSum") private var goalValueSum: Double = 0.0
    @AppStorage("goalValueCount") private var goalValueCount: Int = 0

    var body: some View {
        List {
            if goalValueCount > 0 {
                Section {
                    VStack(spacing: 4) {
                        Text("Goals per Rating Point")
                            .font(.headline)
                        Text(String(format: "%.2f", goalValueSum / Double(goalValueCount)))
                            .font(.system(size: 36, weight: .bold))
                        Text("based on \(goalValueCount) game\(goalValueCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
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
                case .pointDiff:
                    return $0.pointDifferential > $1.pointDifferential
                }
            })) { player in
                Section(header: HStack {
                    Spacer()
                    Text(player.name).font(.headline)
                    Spacer()
                }) {
                    VStack {
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
                        Text("Point Diff")
                        Text("\(player.pointDifferential)")
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
