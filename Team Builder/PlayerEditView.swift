//
//  PlayerEditView.swift
//  Team Builder
//
//  Created by David Storey on 1/6/25.
//

import SwiftUI

struct PlayerEditView: View {
    private enum Field {
        case name
        case gender
        case overallRating
        case throwRating
        case cutRating
        case defenseRating
        case wins
        case losses
        case ties
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @Binding var player: Player
    @FocusState private var focusedField: Field?
    let frozenPlayer: Player
    
    // A reusable TextField component to reduce redundancy
    private func playerTextField(title: String, value: Binding<Int>) -> some View {
        TextField(title, value: value, format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
        }
        
    var body: some View {
        ZStack {
            Color.secondary.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Edit \(player.name)")
                    .font(.largeTitle)

                // Name Section
                SectionView(title: "Name") {
                    TextField("Player Name", text: $player.name)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                        .focused($focusedField, equals: .name)
                }

                // Gender Match Picker
                SectionView(title: "Gender Match") {
                    Picker("Gender Match", selection: $player.gender) {
                        Text("MMP").tag(GenderMatch.mmp)
                        Text("WMP").tag(GenderMatch.wmp)
                    }
                    .pickerStyle(SegmentedPickerStyle()) // A more user-friendly style
                    .focused($focusedField, equals: .gender)
                }

                // Rating Section
                SectionView(title: "Overall Rating") {
                    TextField("Overall Rating", value: $player.overallRating, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .overallRating)
                }
                SectionView(title: "Throw Rating") {
                    TextField("Throw Rating", value: $player.throwRating, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .throwRating)
                }
                SectionView(title: "Cut Rating") {
                    TextField("Cut Rating", value: $player.cutRating, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .cutRating)
                }
                SectionView(title: "Defense Rating") {
                    TextField("Defense Rating", value: $player.defenseRating, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .defenseRating)
                }
                

                // Wins Section
                SectionView(title: "Wins") {
                    playerTextField(title: "Player Wins", value: $player.wins)
                        .focused($focusedField, equals: .wins)
                }

                // Losses Section
                SectionView(title: "Losses") {
                    playerTextField(title: "Player Losses", value: $player.losses)
                        .focused($focusedField, equals: .losses)
                }
                
                // Ties Section
                SectionView(title: "Ties") {
                    playerTextField(title: "Player Ties", value: $player.ties)
                        .focused($focusedField, equals: .ties)
                }

                // Save Button
                Button(action: {
                    let updated = player.compareTo(frozenPlayer)
                    player.updatePlayer(updated, context: viewContext)
                    dismiss()
                }) {
                    Text("Save Player")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
            .onTapGesture {
                focusedField = nil
            }
        }
    }

    struct SectionView<Content: View>: View {
        var title: String
        var content: () -> Content

        init(title: String, @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.content = content
        }

        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                content()
            }
            .padding(.horizontal)
        }
    }
}
