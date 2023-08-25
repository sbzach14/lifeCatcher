//
//  Card.swift
//  Shuffle
//
//  Created by Ariel on 2023/8/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
class Card {
    var suit: Any
    var rank: Int
    
    init(suit: Any, rank: Int) {
        self.suit = suit
        self.rank = rank
    }
    
    static func calScore(card: Card) -> Int {
        if let suit = card.suit as? Int {
            return card.rank * 10 + suit
        } else if let suits = card.suit as? [Int] {
            return card.rank * 10 + suits.max()!
        } else {
            return 0 // Handle the case when suit is neither Int nor [Int]
        }
    }
}
