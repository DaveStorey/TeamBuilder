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
