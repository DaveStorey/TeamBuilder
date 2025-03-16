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
        
        var fieldTitle: String {
            switch self {
            case .name, .gender: return ""
            case .overallRating: return "Overall Rating"
            case .throwRating: return "Throw Rating"
            case .cutRating: return "Cut Rating"
            case .defenseRating: return "Defense Rating"
            case .wins, .losses, .ties: return String(describing: self).capitalized
            }
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @Binding var player: Player
    @State var overallRating: Double = 0.0
    @State var errorMessage: String? = nil
    @FocusState private var focusedField: Field?
    let frozenPlayer: Player
        
    var body: some View {
        ZStack {
            Color.secondary.opacity(0.2)
                .ignoresSafeArea()
            Form {
                VStack(spacing: 20) {
                    Text("Edit \(player.name)")
                        .font(.largeTitle)
                    
                    // Name Section
                    Section(header: Text("Player Information")) {
                        SectionView("Name") {
                            TextField("Player Name", text: $player.name)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled(true)
                                .focused($focusedField, equals: .name)
                        }
                        
                        // Gender Match Picker
                        SectionView("Gender Match") {
                            Picker("Gender Match", selection: $player.gender) {
                                Text("MMP").tag(GenderMatch.mmp)
                                Text("WMP").tag(GenderMatch.wmp)
                            }
                            .pickerStyle(SegmentedPickerStyle()) // A more user-friendly style
                            .focused($focusedField, equals: .gender)
                        }
                    }
                    
                    // Rating Section
                    Section(header: Text("Ratings")) {
                        VStack {
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                            SectionView("Overall Rating") {
                                //TODO: Deal with onChange requiring the values to be state vars, not fields on a binding. Maybe use this with tracking changes to update both local and persistence?
                                TextField("Overall Rating", value: $overallRating, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .overallRating)
                                    .onChange(of: $overallRating.wrappedValue) { newValue in
                                        print("\(newValue)")
                                        checkRating(field: "Overall rating", rating: newValue)
                                    }
                            }
                            SectionView("Throw Rating") {
                                playerRatingField(rating: $player.throwRating, focus: .throwRating)
                            }
                            SectionView("Cut Rating") {
                                playerRatingField(rating: $player.cutRating, focus: .cutRating)
                            }
                            SectionView("Defense Rating") {
                                playerRatingField(rating: $player.defenseRating, focus: .defenseRating)
                            }
                        }
                    }
                    
                    // Wins Section
                    Section(header: Text("Record")) {
                        SectionView("Wins") {
                            playerTextField(value: $player.wins, field: .wins)
                        }
                        
                        // Losses Section
                        SectionView("Losses") {
                            playerTextField(value: $player.losses, field: .losses)
                        }
                        
                        // Ties Section
                        SectionView("Ties") {
                            playerTextField(value: $player.ties, field: .ties)
                        }
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
                            .background(errorMessage != nil ? .blue : .gray)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(errorMessage != nil)
                }
                .padding()
                .onTapGesture {
                    focusedField = nil
                }
            }
        }
    }
    
    // A reusable TextField component to reduce redundancy
    private func playerTextField(value: Binding<Int>, field: Field) -> some View {
        TextField(field.fieldTitle, value: value, format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .focused($focusedField, equals: field)
    }
    
    private func playerRatingField(rating: Binding<Double>, focus: Field) -> some View {
        VStack {
            TextField(focus.fieldTitle, value: rating, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: focus)
                .onChange(of: rating.wrappedValue) { newValue in
                    print("\(newValue)")
                    checkRating(field: focus.fieldTitle, rating: newValue)
                }
        }
    }

    struct SectionView<Content: View>: View {
        var title: String
        var content: () -> Content

        init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
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
    
    private func checkRating(field: String, rating: Double) {
        if rating <= 0 || rating > 10 {
            errorMessage = "\(field) must be between 0.1 and 10"
        } else {
            errorMessage = nil
        }
    }
}
