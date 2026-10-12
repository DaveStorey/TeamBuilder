//
//  PlayerCreationViewMultiRating.swift
//  Team Builder
//
//  Created by David Storey on 2/25/25.
//

import SwiftUI

struct PlayerCreationView: View {
    
    private enum Field: Hashable {
        case name
        case overall
        case throwing
        case cutting
        case defense
    }
    
    @State private var name = ""
    @State private var overallRating = 0.1
    @State private var throwRating = 0.1
    @State private var cutRating = 0.1
    @State private var defenseRating = 0.1
    @State private var gender: GenderMatch = .mmp
    @State private var wins = 0
    @State private var losses = 0
    @State private var ties = 0
    @State private var errorMessage: String?
    @State private var nameIsEmpty: String?
    @FocusState private var field: Field?
    @Binding var playerList: [Player]
    @Environment(\.managedObjectContext) var viewContext
        
    var body: some View {
        Form {
            Section(header: Text("Player Information")) {
                if let nameIsEmpty {
                    errorBanner(nameIsEmpty)
                }
                TextField("Name", text: $name)
                    .autocorrectionDisabled()
                    .focused($field, equals: .name)
                genderPicker
            }
            
            Section(header: Text("Ratings")) {
                if let errorMessage {
                    errorBanner(errorMessage)
                }
                ratingRow(title: "Overall Rating", icon: "star.fill", rating: $overallRating)
                    .focused($field, equals: .overall)
                ratingRow(title: "Throw Rating", icon: "arrow.up.forward.circle.fill", rating: $throwRating)
                    .focused($field, equals: .throwing)
                ratingRow(title: "Cut Rating", icon: "bolt.fill", rating: $cutRating)
                    .focused($field, equals: .cutting)
                ratingRow(title: "Defense Rating", icon: "shield.fill", rating: $defenseRating)
                    .focused($field, equals: .defense)
            }
            
            Section(header: Text("Record")) {
                Stepper("Wins: \(wins)", value: $wins)
                Stepper("Losses: \(losses)", value: $losses)
                Stepper("Ties: \(ties)", value: $ties)
            }
            
            Section {
                Button(action: savePlayer) {
                    Label("Save Player", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(errorMessage != nil)
            }
        }
        .onChange(of: field) { _, _ in
            if errorMessage != nil && ratingsAreAcceptable {
                errorMessage = nil
            }
            if name.isEmpty {
                nameIsEmpty = "Name cannot be empty"
            } else {
                nameIsEmpty = nil
            }
        }
        .navigationTitle("Create Player")
    }
}

extension PlayerCreationView {
    
    private func errorBanner(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote)
            .foregroundStyle(.red)
    }
    
    private var ratingsAreAcceptable: Bool {
        return (overallRating >= 0 && overallRating < 10) && (throwRating >= 0 && throwRating < 10) && (cutRating >= 0 && cutRating < 10) && (defenseRating >= 0 && defenseRating < 10)
    }
    
    private var errorFree: Bool {
        errorMessage == nil && nameIsEmpty == nil
    }
    
    private var genderPicker: some View {
        Picker("Gender Match", selection: $gender) {
            Text("MMP").tag(GenderMatch.mmp)
            Text("WMP").tag(GenderMatch.wmp)
        }
        .pickerStyle(.segmented)
    }
    
    private func ratingRow(title: String, icon: String, rating: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField(title, value: rating, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .onChange(of: rating.wrappedValue) { _, newValue in
                    checkRating(field: title, rating: newValue)
                }
        }
        .padding(.vertical, 2)
    }
    
    private func savePlayer() {
        let newPlayer = Player(name: name,
                               overallRating: overallRating,
                               throwRating: throwRating,
                               cutRating: cutRating,
                               defenseRating: defenseRating,
                               match: gender,
                               wins: wins,
                               losses: losses,
                               ties: ties)
        newPlayer.savePlayer(context: viewContext)
        playerList.append(newPlayer)
    }
    
    private func checkRating(field: String, rating: Double) {
        if rating < 0 || rating > 10 {
            errorMessage = "\(field) must be between 0.0 and 10.0"
        } else {
            errorMessage = nil
        }
    }
}
