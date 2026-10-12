//
//  TeamOptionsView.swift
//  Team Builder
//
//  Created by David Storey on 4/18/24.
//

import Foundation
import SwiftUI

struct TeamOptionsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ContentViewViewModel
    
    var body: some View {
        Form {
            Section("Teams") {
                numberField(title: "Number of Teams", icon: "person.3.fill", value: $viewModel.numberOfTeams)
            }
            
            Section {
                Toggle(isOn: $viewModel.useOverall) {
                    Label("Use overall ratings", systemImage: "star.fill")
                }
                if viewModel.useOverall {
                    doubleField(title: "Maximum overall rating variance", icon: "arrow.left.and.right", value: $viewModel.ratingVariance)
                } else {
                    doubleField(title: "Maximum throw rating variance", icon: "arrow.up.forward.circle.fill", value: $viewModel.throwVariance)
                    doubleField(title: "Maximum cutting rating variance", icon: "bolt.fill", value: $viewModel.cutVariance)
                    doubleField(title: "Maximum defense rating variance", icon: "shield.fill", value: $viewModel.defenseVariance)
                }
            } header: {
                Text("Balance")
            } footer: {
                Text("The maximum rating difference allowed between teams when they're built.")
            }
            
            Section("Generation") {
                numberField(title: "Maximum Iterations", icon: "arrow.triangle.2.circlepath", value: $viewModel.iterations)
            }
            
            Section {
                Toggle(isOn: $viewModel.autoAdjustRatings) {
                    Label("Auto-adjust ratings after games", systemImage: "chart.line.uptrend.xyaxis")
                }
                if viewModel.autoAdjustRatings {
                    doubleField(title: "Points per rating unit", icon: "number", value: $viewModel.pointsPerRatingUnit)
                    Picker("Adjustment curve", selection: $viewModel.adjustmentCurve) {
                        Text("Linear").tag(1)
                        Text("Quadratic").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
            } header: {
                Text("Rating Adjustment")
            } footer: {
                if viewModel.autoAdjustRatings {
                    Text("1 = linear proximity to the rating cap. 2 = steeper curve — low-rated players are shielded from penalties for longer, and high-rated players receive smaller rewards until further from the cap.")
                }
            }
            
            Section {
                Button(action: { dismiss() }) {
                    Label("Save", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }
}

private extension TeamOptionsView {
    func numberField(title: String, icon: String, value: Binding<Int>) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            TextField(title, value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
        }
    }
    
    func doubleField(title: String, icon: String, value: Binding<Double>) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            TextField(title, value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
        }
    }
}
