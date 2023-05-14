//
//  TexasPoker.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/13/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import PythonKit
import Python

class TexasPoker {
    static func findWinningPlayer(inputCards: [Int], playerNum: Int) -> [Int]? {
        guard inputCards.count == 52 && playerNum > 0 && playerNum <= inputCards.count else {
            return nil
        }
        
        var cards = inputCards
        
        // 按规则分配底牌给每个玩家
        var players = [[Int]]()
        let holeCardsPerPlayer = 2
        
        for _ in 0..<playerNum {
            players.append([])
        }
        
        // 按顺序给每个玩家发一张牌，再发第二张牌
        for i in 0..<holeCardsPerPlayer {
            for j in 0..<playerNum {
                let index = i * playerNum + j
                let card = cards[index]
                players[j].append(card)
            }
        }
        
        // 翻牌
        var communityCards = [Int]()
        

        
        // 转牌，一次性翻开3张牌
        cards.removeFirst()
        for _ in 0..<3 {
            if let topCard = cards.first {
                communityCards.append(topCard)
                cards.removeFirst()
            }
        }
        
        // 转牌，再翻开一张牌
        cards.removeFirst()
        if let transferCard = cards.first {
            communityCards.append(transferCard)
            cards.removeFirst()
        }
        
        // 河牌，再翻开一张牌
        cards.removeFirst()
        if let riverCard = cards.first {
            communityCards.append(riverCard)
            cards.removeFirst()
        }
        
        let winner = texasPokerEval(holeCards:players, communityCards: communityCards)
        return winner
    }
    
    
    static func texasPokerEval(holeCards: [[Int]], communityCards: [Int]) -> [Int] {
        var maxHandRank = -1
        var winningPlayers: [Int] = []
        
        // 将数字转换为形如 "As", "Ks" 的字符串表示形式
        var holeCardsStr: [[String]] = []
        for cards in holeCards {
            var cardsStr: [String] = []
            for card in cards {
                cardsStr.append(intToStr(card: card))
            }
            holeCardsStr.append(cardsStr)
        }
        
        var communityCardsStr: [String] = []
        for card in communityCards {
            communityCardsStr.append(intToStr(card: card))
        }
        
        let texasPokerEval = Python.import("pypokerengine")
        //TODO: fix cal rank
        

        return winningPlayers
    }

    
    static func intToStr(card: Int) -> String {
        let suits: [String] = ["s", "h", "c", "d"]
        let ranks: [String] = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        let suit = suits[card / 13]
        let rank = ranks[card % 13]
        return rank + suit
    }
}



