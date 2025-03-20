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
    @StateObject var viewModel: PlayerEditViewViewModel
    @FocusState private var focusedField: Field?
        
    var body: some View {
        ZStack {
            Color.secondary.opacity(0.2)
                .ignoresSafeArea()
            Form {
                VStack(spacing: 20) {
                    Text("Edit \(viewModel.player.name)")
                        .font(.largeTitle)
                    
                    // Name Section
                    Section(header: Text("Player Information")) {
                        SectionView("Name") {
                            if let errorMessage = viewModel.nameError {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                            TextField("Player Name", text: $viewModel.player.name)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled(true)
                                .focused($focusedField, equals: .name)
                        }
                        
                        // Gender Match Picker
                        SectionView("Gender Match") {
                            Picker("Gender Match", selection: $viewModel.player.gender) {
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
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                            SectionView("Overall Rating") {
                                playerRatingField(rating: $viewModel.player.overallRating, focus: .overallRating)
                            }
                            SectionView("Throw Rating") {
                                playerRatingField(rating: $viewModel.player.throwRating, focus: .throwRating)
                            }
                            SectionView("Cut Rating") {
                                playerRatingField(rating: $viewModel.player.cutRating, focus: .cutRating)
                            }
                            SectionView("Defense Rating") {
                                playerRatingField(rating: $viewModel.player.defenseRating, focus: .defenseRating)
                            }
                        }
                    }
                    
                    // Wins Section
                    Section(header: Text("Record")) {
                        SectionView("Wins") {
                            playerTextField(value: $viewModel.player.wins, field: .wins)
                        }
                        
                        // Losses Section
                        SectionView("Losses") {
                            playerTextField(value: $viewModel.player.losses, field: .losses)
                        }
                        
                        // Ties Section
                        SectionView("Ties") {
                            playerTextField(value: $viewModel.player.ties, field: .ties)
                        }
                    }
                    
                    // Save Button
                    Button(action: {
                        viewModel.updatePlayer(context: viewContext)
                        dismiss()
                    }) {
                        Text("Save Player")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.errorPresent ? .gray : .blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(viewModel.errorPresent)
                }
                .padding()
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
}
