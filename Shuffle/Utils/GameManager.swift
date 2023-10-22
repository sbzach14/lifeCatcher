

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
        let rule0 = TexasPokerRule(ruleIndex: 0, ruleName: "德州")
        let rule1 = PokerBullRule(ruleIndex: 1, ruleName: "牛牛")
        let rule2 = ThreeCardPokerGameRule(ruleIndex: 2, ruleName: "炸金花")
        let rule3 = TinyNineGameRule(ruleIndex: 3, ruleName: "小九")
        let rule4 = ThreeMenGameRule(ruleIndex: 4, ruleName: "三公")
        let rule5 = TwoEightGangGameRule(ruleIndex: 5, ruleName: "二八杠")
        let rule6 = NinePointFiveGameRule(ruleIndex: 6, ruleName: "九点半")
        let rule7 = BaoziGameRule(ruleIndex: 7, ruleName: "宝子")
        
        return [rule0.ruleIndex: rule0, rule1.ruleIndex: rule1, rule2.ruleIndex: rule2, rule3.ruleIndex: rule3, rule4.ruleIndex: rule4, rule5.ruleIndex: rule5, rule6.ruleIndex: rule6, rule7.ruleIndex: rule7]
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
            2: ThreeCardPokerGame.FindWinner,
            3: TinyNineGame.FindWinner,
            4: ThreeMenGame.FindWinner,
            5: TwoEightGangGame.FindWinner,
            6: NinePointFiveGame.FindWinner,
            7: BaoziGame.FindWinner,
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
                        reportResult = cardIndex
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
                        reportResult = cardIndex
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


