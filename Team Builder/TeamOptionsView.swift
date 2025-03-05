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
            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("How many teams?")
                        .padding(.leading)
                    TextField("How many teams?", value: $viewModel.numberOfTeams, format: .number)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    
                    Toggle(isOn: $viewModel.useOverall, label: { Text("Use overall ratings") })
                }
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
                    VStack {
                        Text("What is the maximum overall rating variance between teams?")
                            .lineLimit(2)
                            .padding(.leading)
                        TextField("What is the maximum rating variance between teams?", value: $viewModel.ratingVariance, format: .number)
                            .padding(.horizontal)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                    }
                }
                Button(action: {
                    self.dismiss.callAsFunction()
                }, label: { Text("Save").foregroundStyle(.white) })
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
