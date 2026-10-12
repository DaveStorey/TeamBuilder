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
        
        var icon: String {
            switch self {
            case .name: return "person.fill"
            case .gender: return "figure.stand"
            case .overallRating: return "star.fill"
            case .throwRating: return "arrow.up.forward.circle.fill"
            case .cutRating: return "bolt.fill"
            case .defenseRating: return "shield.fill"
            case .wins: return "checkmark.circle.fill"
            case .losses: return "xmark.circle.fill"
            case .ties: return "equal.circle.fill"
            }
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel: PlayerEditViewViewModel
    @FocusState private var focusedField: Field?
        
    var body: some View {
        Form {
            Section(header: Text("Player Information")) {
                if let errorMessage = viewModel.nameError {
                    errorBanner(errorMessage)
                }
                TextField("Player Name", text: $viewModel.player.name)
                    .autocorrectionDisabled(true)
                    .focused($focusedField, equals: .name)
                
                Picker("Gender Match", selection: $viewModel.player.gender) {
                    Text("MMP").tag(GenderMatch.mmp)
                    Text("WMP").tag(GenderMatch.wmp)
                }
                .pickerStyle(.segmented)
                .focused($focusedField, equals: .gender)
            }
            
            Section(header: Text("Ratings")) {
                if let errorMessage = viewModel.errorMessage {
                    errorBanner(errorMessage)
                }
                ratingField(rating: $viewModel.player.overallRating, focus: .overallRating)
                ratingField(rating: $viewModel.player.throwRating, focus: .throwRating)
                ratingField(rating: $viewModel.player.cutRating, focus: .cutRating)
                ratingField(rating: $viewModel.player.defenseRating, focus: .defenseRating)
            }
            
            Section(header: Text("Record")) {
                recordField(value: $viewModel.player.wins, field: .wins)
                recordField(value: $viewModel.player.losses, field: .losses)
                recordField(value: $viewModel.player.ties, field: .ties)
            }
            
            Section {
                Button(action: {
                    viewModel.updatePlayer(context: viewContext)
                    dismiss()
                }) {
                    Label("Save Player", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.errorPresent)
            }
        }
        .navigationTitle("Edit \(viewModel.player.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func errorBanner(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote)
            .foregroundStyle(.red)
    }
    
    private func ratingField(rating: Binding<Double>, focus: Field) -> some View {
        HStack {
            Label(focus.fieldTitle, systemImage: focus.icon)
            Spacer()
            TextField(focus.fieldTitle, value: rating, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
                .focused($focusedField, equals: focus)
        }
    }
    
    private func recordField(value: Binding<Int>, field: Field) -> some View {
        HStack {
            Label(field.fieldTitle, systemImage: field.icon)
            Spacer()
            TextField(field.fieldTitle, value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
                .focused($focusedField, equals: field)
        }
    }
}
