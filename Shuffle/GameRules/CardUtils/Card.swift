//
//  Card.swift
//  Shuffle
//
//  Created by Ariel on 2023/8/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
class Card {
    var suit: [Int]
    var rank: Int
    
    init(suit: [Int], rank: Int) {
        self.suit = suit
        self.rank = rank
    }
    
    static func calScore(card: Card) -> Int {
        return card.rank * 10 + card.suit.max()!
    }
}
