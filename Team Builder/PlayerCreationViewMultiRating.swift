//
//  PlayerCreationViewMultiRating.swift
//  Team Builder
//
//  Created by David Storey on 2/25/25.
//

import SwiftUI

struct PlayerCreationViewMultiRating: View {
    
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
                VStack(spacing: 5) {
                    if let nameIsEmpty {
                        Text(nameIsEmpty)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                        .focused($field, equals: .name)
                    genderPicker
                }
            }
            
            Section(header: Text("Ratings")) {
                VStack(spacing: 5) {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    Text("Overall Rating")
                        .font(.callout)
                    playerRatingField(title: "Overall Rating", rating: $overallRating)
                        .focused($field, equals: .overall)
                    ratingSpacer
                    Text("Throw Rating")
                        .font(.callout)
                    playerRatingField(title: "Throw Rating", rating: $throwRating)
                        .focused($field, equals: .throwing)
                    ratingSpacer
                    Text("Cut Rating")
                        .font(.callout)
                    playerRatingField(title: "Cut Rating", rating: $cutRating)
                        .focused($field, equals: .cutting)
                    ratingSpacer
                    Text("Defense Rating")
                        .font(.callout)
                    playerRatingField(title: "Defense Rating", rating: $defenseRating)
                        .focused($field, equals: .defense)
                }
                .onChange(of: field, perform: { value in
                    if errorMessage != nil && ratingsAreAcceptable {
                        errorMessage = nil
                    }
                    if name.isEmpty {
                        nameIsEmpty = "Name cannot be empty"
                    } else {
                        nameIsEmpty = nil
                    }
                })
            }
            
            Section(header: Text("Record")) {
                Stepper("Wins: \(wins)", value: $wins)
                Stepper("Losses: \(losses)", value: $losses)
                Stepper("Ties: \(ties)", value: $ties)
            }
            
            Button(action: savePlayer) {
                Text("Save Player")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(errorFree ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
            }
            .disabled(errorMessage != nil)
        }
        .navigationTitle("Create Player")
    }
}

extension PlayerCreationViewMultiRating {
    
    private var ratingSpacer: some View {
        Spacer()
            .frame(height: 15)
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
    
    private func playerRatingField(title: String, rating: Binding<Double>) -> some View {
        VStack {
            TextField(title, value: rating, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .onChange(of: rating.wrappedValue) { newValue in
                    checkRating(field: title, rating: newValue)
                }
        }
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
            if !playerList.contains(where: { $0.idString == newPlayer.idString }) {
                playerList.append(newPlayer)
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
