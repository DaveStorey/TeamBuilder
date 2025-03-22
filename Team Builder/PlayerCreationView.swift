//
//  PlayerCreationView.swift
//  Team Builder
//
//  Created by David Storey on 3/22/25.
//

import SwiftUI

struct PlayerCreationView: View {
    
    private enum Field: Hashable {
        case name
        case overall
    }
    
    @State private var name = ""
    @State private var overallRating = 0.1
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
                    .background(errorFree ? .blue : .gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
            }
            .disabled(errorMessage != nil)
        }
        .navigationTitle("Create Player")
    }
}

extension PlayerCreationView {
    
    private var ratingSpacer: some View {
        Spacer()
            .frame(height: 15)
    }
    
    private var ratingsAreAcceptable: Bool {
        return (overallRating >= 0 && overallRating < 10)
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
