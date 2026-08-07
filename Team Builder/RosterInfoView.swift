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
    @State private var showCombinedDetail = false
    @AppStorage("goalCrossProduct") private var goalCrossProduct: Double = 0.0
    @AppStorage("goalSumSquaredDiffs") private var goalSumSquaredDiffs: Double = 0.0
    @AppStorage("goalCount") private var goalCount: Int = 0
    @AppStorage("throwCrossProduct") private var throwCrossProduct: Double = 0.0
    @AppStorage("throwSumSquaredDiffs") private var throwSumSquaredDiffs: Double = 0.0
    @AppStorage("throwCount") private var throwCount: Int = 0
    @AppStorage("cutCrossProduct") private var cutCrossProduct: Double = 0.0
    @AppStorage("cutSumSquaredDiffs") private var cutSumSquaredDiffs: Double = 0.0
    @AppStorage("cutCount") private var cutCount: Int = 0
    @AppStorage("defenseCrossProduct") private var defenseCrossProduct: Double = 0.0
    @AppStorage("defenseSumSquaredDiffs") private var defenseSumSquaredDiffs: Double = 0.0
    @AppStorage("defenseCount") private var defenseCount: Int = 0

    private var hasSpecificMetrics: Bool {
        throwCount > 0 || cutCount > 0 || defenseCount > 0
    }

    var body: some View {
        List {
            if goalCount > 0 {
                Section {
                    VStack(spacing: 4) {
                        Text("Goals per Rating Point")
                            .font(.headline)
                        Text(String(format: "%.2f", goalCrossProduct / goalSumSquaredDiffs))
                            .font(.system(size: 36, weight: .bold))
                        Text("overall avg · \(goalCount) game\(goalCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if hasSpecificMetrics {
                            Image(systemName: showCombinedDetail ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard hasSpecificMetrics else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showCombinedDetail.toggle()
                        }
                    }

                    if showCombinedDetail {
                        specificMetricRow(label: "Throw", crossProduct: throwCrossProduct, sumSquaredDiffs: throwSumSquaredDiffs, count: throwCount)
                        specificMetricRow(label: "Cut", crossProduct: cutCrossProduct, sumSquaredDiffs: cutSumSquaredDiffs, count: cutCount)
                        specificMetricRow(label: "Defense", crossProduct: defenseCrossProduct, sumSquaredDiffs: defenseSumSquaredDiffs, count: defenseCount)
                    }
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

    @ViewBuilder
    private func specificMetricRow(label: String, crossProduct: Double, sumSquaredDiffs: Double, count: Int) -> some View {
        if count > 0 {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.2f", crossProduct / sumSquaredDiffs))
                        .font(.system(size: 20, weight: .semibold))
                    Text("\(count) game\(count == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
            .transition(.opacity)
        }
    }
}
