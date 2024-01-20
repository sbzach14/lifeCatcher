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
    var cardIndex: Int
    
    init(suit: [Int], rank: Int, cardIndex: Int) {
        self.suit = suit
        self.rank = rank
        self.cardIndex = cardIndex
    }
    
    static func calScore(card: Card) -> Int {
        return card.rank * 10 + card.suit.max()!
    }
}


class Player {
    var playerCard = [Card]()
    var evaluateFlag = 0
    
    func insertCard(card: Card) {
        playerCard.append(card)
    }
}
