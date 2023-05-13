//
//  TexasPoker.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/13/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import PythonKit

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
        
        // 导入 Python 模块
        let texasPokerEval = Python.import("TexasPokerEval")
        
        // 将 Swift 数组转换为 Python 列表
        let playersInput = inputCards.map { PythonObject($0) }
        let communityCardsInput = communityCards.map { PythonObject($0) }
        
        // 调用 Python 函数并获取结果
        let winningPlayers = texasPokerEval.TexasPokerEval(hole_cards: playersInput, community_cards: communityCardsInput)
        
        // 将 Python 列表转换为 Swift 数组
        let swiftWinningPlayers = winningPlayers.map { Int($0)! }
        
        return swiftWinningPlayers
    }

}
