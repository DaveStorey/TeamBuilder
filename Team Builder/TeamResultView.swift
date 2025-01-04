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
    @State var winLoss: String = "Win"
    let team: String
    
    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            VStack {
                Text("Team Result")
                    .font(.headline)
                    .padding()
                Text(team)
                    .font(.subheadline)
                Picker(selection: $winLoss, label: Text("Win/Loss")) {
                    Text("Win").tag("Win")
                    Text("Loss").tag("Loss")
                }
                Button(action: {
                    if winLoss == "Loss" {
                        viewModel.teamLoss(team, context: viewContext)
                    } else if winLoss == "Win" {
                        viewModel.teamWin(team, context: viewContext)
                    }
                    self.dismiss.callAsFunction()
                }, label: { Text(verbatim: "Save").foregroundStyle(.white) })
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
