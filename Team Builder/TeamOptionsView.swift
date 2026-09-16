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
        ZStack {
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("How many teams?")
                        .padding(.leading)
                    TextField("How many teams?", value: $viewModel.numberOfTeams, format: .number)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
                Divider().padding(.horizontal)
                Toggle(isOn: $viewModel.useOverall, label: { Text("Use overall ratings") })
                    .padding(.horizontal)
                if !viewModel.useOverall {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("What is the maximum throw rating variance between teams?")
                            .lineLimit(2)
                            .padding(.leading)
                        TextField("What is the maximum throw rating variance between teams?", value: $viewModel.throwVariance, format: .number)
                            .padding(.horizontal)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        
                        Text("What is the maximum cutting rating variance between teams?")
                            .lineLimit(2)
                            .padding(.leading)
                        TextField("What is the maximum cutting rating variance between teams?", value: $viewModel.cutVariance, format: .number)
                            .padding(.horizontal)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        
                        Text("What is the maximum defense rating variance between teams?")
                            .lineLimit(2)
                            .padding(.leading)
                        TextField("What is the maximum defense rating variance between teams?", value: $viewModel.defenseVariance, format: .number)
                            .padding(.horizontal)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("What is the maximum overall rating variance between teams?")
                            .lineLimit(2)
                            .padding(.leading)
                        TextField("What is the maximum rating variance between teams?", value: $viewModel.ratingVariance, format: .number)
                            .padding(.horizontal)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                    }
                }
                Divider().padding(.horizontal)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Maximum Iterations")
                        .padding(.leading)
                    TextField("Maximum Iterations", value: $viewModel.iterations, format: .number)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }

                Divider().padding(.horizontal)
                VStack(alignment: .leading, spacing: 6) {
                    Toggle(isOn: $viewModel.autoAdjustRatings, label: { Text("Auto-adjust ratings after games") })
                        .padding(.horizontal)
                    if viewModel.autoAdjustRatings {
                        Text("Points per rating unit")
                            .padding(.leading)
                        TextField("Points per rating unit", value: $viewModel.pointsPerRatingUnit, format: .number)
                            .padding(.horizontal)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)

                        Text("Adjustment curve")
                            .padding(.leading)
                        Picker("Adjustment curve", selection: $viewModel.adjustmentCurve) {
                            Text("Linear (1)").tag(1)
                            Text("Quadratic (2)").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        Text("1 = linear proximity to the rating cap. 2 = steeper curve — low-rated players are shielded from penalties for longer, and high-rated players receive smaller rewards until further from the cap.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                }

                Button(action: {
                    self.dismiss.callAsFunction()
                }, label: { Text("Save").foregroundStyle(.white) })
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.vertical)
            }
        }
    }
}
