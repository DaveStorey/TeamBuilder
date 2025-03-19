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
    private let frozenPlayer: Player
    private var cancellables: Set<AnyCancellable> = []
    
    init(player: Player) {
        self.player = player
        self.frozenPlayer = player.valueCopy()
        
//        $player.sink { [weak self] newValue in
//            guard let self else { return }
//            if let field = self.ratingChange() {
//                self.checkRating(field: field.0, rating: field.1)
//            }
//        }.store(in: &cancellables)
    }
    
    func checkRating(field: String, rating: Double) {
        if rating <= 0 || rating > 10 {
            errorMessage = "\(field) must be between 0.1 and 10"
        } else {
            errorMessage = nil
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
