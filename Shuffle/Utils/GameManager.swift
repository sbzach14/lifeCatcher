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
        let rule1 = TexasPokerRule(ruleIndex: 0, ruleName: "TexasPoker")
        let rule2 = Rule(ruleIndex: 1, ruleName: "PokerBullRule")
        
        return [rule1.ruleIndex: rule1, rule2.ruleIndex: rule2]
    }()
    
    
    static func selectGame(gameIndex: Int, inputCards: [Int], args : [Int], rankRules : [Int]) -> [Int] {
        var winner: [Int] = []
        
        switch gameIndex {
        case 0:
            print("Texas")
            if let result = TexasPoker.FindWinner(inputCards: inputCards, args: args, rankRules: rankRules) {
                winner = result
            }
        case 1:
            print("Bull")
            if let result = PokerBull.FindWinner(inputCards: inputCards, args: args, rankRules: rankRules){
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

    init(ruleIndex: Int, ruleName: String) {
        self.ruleIndex = ruleIndex
        self.ruleName = ruleName
    }
}

struct RankRulesSate {
    var index: Int
    var isChecked: Bool
}


