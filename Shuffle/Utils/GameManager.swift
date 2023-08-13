

import Foundation
import SwiftUI

class GameManager {
    static var suitNames: [Int: String] = [
        0: "♦️方片",
        1: "♣️梅花",
        2: "♥️红桃",
        3: "♠️黑桃"
    ]
    static var gameRules: [Int: Rule] = {
        let rule1 = TexasPokerRule(ruleIndex: 0, ruleName: "TexasPoker")
        let rule2 = Rule(ruleIndex: 1, ruleName: "PokerBullRule")
        let rule3 = ThreeCardPokerGameRule(ruleIndex: 2, ruleName: "ThreeCardPokerGame")
        
        return [rule1.ruleIndex: rule1, rule2.ruleIndex: rule2, rule3.ruleIndex: rule3]
    }()
    
    
    static func selectGame(gameIndex: Int, inputCards: [Int], args : [Int], rankRules : [Int], suitRules: [Int]) -> [Int] {
        var winner: [Int] = []

        switch gameIndex {
        case 0:
            print("Texas")
            if let result = TexasPoker.FindWinner(inputCards: inputCards, args: args, rankRules: rankRules, suitRules: suitRules) {
                winner = result
            }
        case 1:
            print("Bull")
            if let result = PokerBull.FindWinner(inputCards: inputCards, args: args, rankRules: rankRules, suitRules: suitRules){
                winner = result
            }
        case 2:
            print("ThreePokerGame")
            if let result = ThreeCardPokerGame.FindWinner(inputCards: inputCards, args: args, rankRules: rankRules, suitRules: suitRules){
                winner = result
            }
            
        default:
            print(gameIndex)
        }
        
        return winner
    }
    
    static func getCheckedIndexes(rankRules: [RankRulesSate]) -> [Int] {
        var checkedIndexes: [Int] = []
        
        for state in rankRules {
            if state.isChecked {
                checkedIndexes.append(state.index)
            }
        }
        
        return checkedIndexes
    }
}


class Rule {
    let ruleIndex: Int
    let ruleName: String
    var rankRules: [Int: String]

    init(ruleIndex: Int, ruleName: String) {
        self.ruleIndex = ruleIndex
        self.ruleName = ruleName
        self.rankRules = [:]
    }
}

struct RankRulesSate {
    var index: Int
    var isChecked: Bool
    
    
}


