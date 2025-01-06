//
//  PlayerEditView.swift
//  Team Builder
//
//  Created by David Storey on 1/6/25.
//

import SwiftUI

struct PlayerEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @Binding var player: Player
    
    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            VStack {
                Text("Edit \(player.name)")
                    .font(.largeTitle)
                
                Text("Name")
                    .font(.headline)
                TextField("Player Name", text: $player.name)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
                
                Picker(selection: $player.gender, label: Text("Gender Match")) {
                    Text("MMP").tag(GenderMatch.mmp)
                    Text("WMP").tag(GenderMatch.wmp)
                }
                .pickerStyle(.automatic)
                
                Text("Rating")
                    .font(.headline)
                TextField("Player Rating", value: $player.overallRating, format: .number)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                
                Text("Wins")
                    .font(.headline)
                TextField("Player Wins", value: $player.wins, format: .number)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                
                Text("Losses")
                    .font(.headline)
                TextField("Player Losses", value: $player.losses, format: .number)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                
                Button(action: { player.updatePlayer(context: viewContext)
                    self.dismiss.callAsFunction() },
                       label: { Text("Save Player").foregroundStyle(.white) })
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
