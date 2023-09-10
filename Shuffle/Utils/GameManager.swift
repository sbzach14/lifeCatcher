

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
        let rule2 = PokerBullRule(ruleIndex: 1, ruleName: "PokerBullRule")
        let rule3 = ThreeCardPokerGameRule(ruleIndex: 2, ruleName: "ThreeCardPokerGame")
        
        return [rule1.ruleIndex: rule1, rule2.ruleIndex: rule2, rule3.ruleIndex: rule3]
    }()
    
    
    static func selectGame(gameIndex: Int, inputCards: [Int], args : [Int], rankRules : [Int], suitRules: [Int], calModeArgs: [Int], minCardNum: Int) -> Int {
        var reportResult = 0
        
        //calModeArgs [calMode, target, targetPos]
        //calmode 0不打色 1去色 2留色
        //target 0max 1min
        //targetPos 这里变为0开始
        let calMode = calModeArgs[0]
        let target = calModeArgs[1]
        let targetPos = calModeArgs[2] - 1
        
        let playerNum = args[0]
        
        // 定义一个字典，将游戏索引映射到游戏函数
        let gameFunctions: [Int: ([Int], [Int], [Int], [Int]) -> [Int]?] = [
            0: TexasPoker.FindWinner,
            1: PokerBull.FindWinner,
            2: ThreeCardPokerGame.FindWinner
        ]

        // 检查 gameIndex 是否存在于字典中
        if let gameFunction = gameFunctions[gameIndex] {
            print("Selected Game: \(gameFunction)")
            
            switch calMode{
                
            case 0://不打色
                if let result = gameFunction(inputCards, args, rankRules, suitRules) {
                    if target == 0{
                        reportResult = result[0]
                    }
                    else if target == 1{
                        reportResult = result[result.count - 1]
                    }
                }
            
            case 1://去色
                for cardIndex in 0..<inputCards.count - minCardNum{
                    let cardRank = inputCards[cardIndex] % 13
                    let newInputCards = Array(inputCards[(cardIndex+1)...])//去掉上面的牌
                    var resultTargetPos = 0
                    if let result = gameFunction(newInputCards, args, rankRules, suitRules) {
                        if target == 0{
                            resultTargetPos = result[0]
                        }
                        else if target == 1{
                            resultTargetPos = result[result.count - 1]
                        }
                    }
                    let resultPos = (cardRank + resultTargetPos) % playerNum//起始发牌位置+目标输赢发牌位置
                    if resultPos == targetPos{//targetPos 0 - playerNum-1
                        reportResult = cardIndex + 1
                        break
                    }
                }
                
            case 2://留色
                for cardIndex in 0..<inputCards.count{
                    let cardRank = inputCards[cardIndex] % 13
                    var resultTargetPos = 0
                    if let result = gameFunction(inputCards, args, rankRules, suitRules) {
                        if target == 0{
                            resultTargetPos = result[0]
                        }
                        else if target == 1{
                            resultTargetPos = result[result.count - 1]
                        }
                    }
                    let resultPos = (cardRank + resultTargetPos) % playerNum//起始发牌位置+目标输赢发牌位置
                    if resultPos == targetPos{
                        reportResult = cardIndex + 1
                        break
                    }
                }
                
            default:
                print("calModeArgs 0 error")
            }
        } else {
            print("Invalid gameIndex: \(gameIndex)")
        }
        
        return reportResult
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


