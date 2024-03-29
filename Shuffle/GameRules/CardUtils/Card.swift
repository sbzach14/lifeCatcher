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
    let originalRank: Int
    
    init(suit: [Int], rank: Int, cardIndex: Int) {
        self.suit = suit
        self.rank = rank
        self.originalRank = rank
        self.cardIndex = cardIndex
    }
    
    static func calScore(card: Card) -> Int {
        return card.rank * 10 + card.suit.max()!
    }
}


class Player {
    var playerCard = [Card]()
    var evaluateFlag = 0
    var cardType: String = ""
    var cardSuit: String = ""
    var isPair: Int = 0
    
    func insertCard(card: Card) {
        playerCard.append(card)
    }
}
