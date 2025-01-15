//
//  Extensions.swift
//  Team Builder
//
//  Created by David Storey on 8/27/24.
//

import Foundation

extension Optional where Wrapped == String {
    
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension Collection where Element == Roster {
    var differential: Double {
        let max = self.max(by: { $0.averageRating < $1.averageRating })?.averageRating ?? 0.0
        let min = self.min(by: { $0.averageRating < $1.averageRating})?.averageRating ?? 10.0
        return min.distance(to: max)
    }
}
