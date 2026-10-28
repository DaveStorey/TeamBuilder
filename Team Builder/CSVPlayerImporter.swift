//
//  CSVPlayerImporter.swift
//  Team Builder
//
//  Created by David Storey on 10/20/26.
//

import Foundation

enum CSVImportError: LocalizedError {
    case emptyFile
    case fileUnreadable(String)
    case row(Int, String)

    var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "The CSV file is empty."
        case .fileUnreadable(let message):
            return "Could not read the file: \(message)"
        case .row(let number, let message):
            return "Row \(number): \(message)"
        }
    }
}

// Expected column order: Name, Gender Match ("MMP" or "FMP"), Overall Rating, Throw Rating, Cut Rating, Defense Rating.
// The first row is assumed to be a header and is skipped.
enum CSVPlayerImporter {

    static func parse(_ contents: String) -> (players: [Player], errors: [CSVImportError]) {
        let normalized = contents
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        var rows = normalized
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map(parseLine)

        guard !rows.isEmpty else { return ([], [.emptyFile]) }
        rows.removeFirst()

        var players: [Player] = []
        var errors: [CSVImportError] = []

        for (index, fields) in rows.enumerated() {
            let rowNumber = index + 2
            guard fields.contains(where: { !$0.isEmpty }) else { continue }

            guard fields.count >= 6 else {
                errors.append(.row(rowNumber, "Expected 6 columns, found \(fields.count)."))
                continue
            }

            let name = fields[0]
            guard !name.isEmpty else {
                errors.append(.row(rowNumber, "Name cannot be empty."))
                continue
            }

            guard let gender = genderMatch(for: fields[1]) else {
                errors.append(.row(rowNumber, "Gender match must be \"MMP\" or \"FMP\", found \"\(fields[1])\"."))
                continue
            }

            guard let overallRating = rating(fields[2]) else {
                errors.append(.row(rowNumber, "Overall rating must be a number between 0 and 10, found \"\(fields[2])\"."))
                continue
            }

            guard let throwRating = rating(fields[3]) else {
                errors.append(.row(rowNumber, "Throw rating must be a number between 0 and 10, found \"\(fields[3])\"."))
                continue
            }

            guard let cutRating = rating(fields[4]) else {
                errors.append(.row(rowNumber, "Cut rating must be a number between 0 and 10, found \"\(fields[4])\"."))
                continue
            }

            guard let defenseRating = rating(fields[5]) else {
                errors.append(.row(rowNumber, "Defense rating must be a number between 0 and 10, found \"\(fields[5])\"."))
                continue
            }

            players.append(Player(name: name,
                                   overallRating: overallRating,
                                   throwRating: throwRating,
                                   cutRating: cutRating,
                                   defenseRating: defenseRating,
                                   match: gender))
        }

        return (players, errors)
    }

    private static func genderMatch(for value: String) -> GenderMatch? {
        switch value.uppercased() {
        case "MMP": return .mmp
        case "FMP", "WMP": return .wmp
        default: return nil
        }
    }

    private static func rating(_ value: String) -> Double? {
        guard let rating = Double(value), rating >= 0, rating <= 10 else { return nil }
        return rating
    }

    // Splits a single CSV line on commas, respecting double-quoted fields (including escaped "" quotes).
    private static func parseLine(_ line: Substring) -> [String] {
        var fields: [String] = []
        var current = ""
        var insideQuotes = false
        let chars = Array(line)
        var i = 0
        while i < chars.count {
            let char = chars[i]
            if char == "\"" {
                if insideQuotes, i + 1 < chars.count, chars[i + 1] == "\"" {
                    current.append("\"")
                    i += 1
                } else {
                    insideQuotes.toggle()
                }
            } else if char == "," && !insideQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(char)
            }
            i += 1
        }
        fields.append(current)
        return fields.map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
