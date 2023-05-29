//
//  GameManager.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/13/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

class GameManager {
    static var gameRules: [Int: Rule] = {
        let rule1 = TexasPokerRule(ruleIndex: 0, ruleName: "TexasPoker", minPlayerNum: 3, maxPlayerNum: 8)
        let rule2 = Rule(ruleIndex: 1, ruleName: "PokerBullRule", minPlayerNum: 2, maxPlayerNum: 6)
        
        return [rule1.ruleIndex: rule1, rule2.ruleIndex: rule2]
    }()
    
    
    static func selectGame(gameIndex: Int, inputCards: [Int], playerNum: Int, args : [Int]) -> [Int] {
        var winner: [Int] = []
        
        switch gameIndex {
        case 0:
            print("Texas")
            if let result = TexasPoker.FindWinner(inputCards: inputCards, playerNum: playerNum, args: args) {
                winner = result
            }
        case 1:
            print("Bull")
            if let result = PokerBull.FindWinner(inputCards: inputCards, playerNum: playerNum){
                winner = result
            }
        case 2:
            print(gameIndex)
            
        default:
            print(gameIndex)
        }
        
        return winner
    }
}


class Rule {
    let ruleIndex: Int
    let ruleName: String
    let minPlayerNum: Int
    let maxPlayerNum: Int

    init(ruleIndex: Int, ruleName: String, minPlayerNum: Int, maxPlayerNum: Int) {
        self.ruleIndex = ruleIndex
        self.ruleName = ruleName
        self.minPlayerNum = minPlayerNum
        self.maxPlayerNum = maxPlayerNum
    }
}


