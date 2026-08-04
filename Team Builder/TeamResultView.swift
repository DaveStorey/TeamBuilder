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
    let team: String

    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Team Result")
                    .font(.largeTitle)
                    .padding()
                Text(team)
                    .font(.title)

                HStack(spacing: 40) {
                    VStack {
                        Text(team)
                            .font(.headline)
                        Stepper("\(teamScore)", value: $teamScore, in: 0...99)
                            .labelsHidden()
                        Text("\(teamScore)")
                            .font(.system(size: 44, weight: .bold))
                    }

                    Text("vs")
                        .font(.title2)

                    VStack {
                        Text("Opponent")
                            .font(.headline)
                        Stepper("\(opponentScore)", value: $opponentScore, in: 0...99)
                            .labelsHidden()
                        Text("\(opponentScore)")
                            .font(.system(size: 44, weight: .bold))
                    }
                }
                .padding()

                Button(action: {
                    viewModel.teamResult(teamScore: teamScore, opponentScore: opponentScore, team: team, context: viewContext)
                    self.dismiss.callAsFunction()
                }, label: { Text(verbatim: "Save").foregroundStyle(.white) })
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
