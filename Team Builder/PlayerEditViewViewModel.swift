//
//  PlayerEditViewViewModel.swift
//  Team Builder
//
//  Created by David Storey on 3/19/25.
//

import Foundation
import Combine
import CoreData

class PlayerEditViewViewModel: ObservableObject {
    @Published var player: Player
    @Published var errorMessage: String?
    @Published var errorPresent = false
    private let frozenPlayer: Player
    private var cancellables: Set<AnyCancellable> = []
    
    init(player: Player) {
        self.player = player
        self.frozenPlayer = player.valueCopy()
    }
    
    func checkRating(field: String, rating: Double) {
        if rating <= 0 || rating > 10 {
            errorMessage = "\(field) must be between 0.1 and 10"
            errorPresent = true
        } else {
            errorMessage = nil
            errorPresent = false
        }
    }
    
    private func ratingChange() -> (String, Double)? {
        if  player.overallRating != frozenPlayer.overallRating {
            return ("Overall rating", player.overallRating)
        } else if player.throwRating != frozenPlayer.throwRating {
            return ("Throw rating", player.throwRating)
        } else if player.cutRating != frozenPlayer.cutRating {
            return ("Cut rating", player.cutRating)
        } else if player.defenseRating != frozenPlayer.defenseRating {
            return ("Defense rating", player.defenseRating)
        }
        return nil
    }
    
    func updatePlayer(context: NSManagedObjectContext) {
        let updated = player.compareTo(frozenPlayer)
        player.updatePlayer(updated, context: context)
    }
}
