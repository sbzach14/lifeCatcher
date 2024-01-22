

import Foundation
import SwiftUI

class GameManager {
    
    static let cardLabelDic : [Int:String] = [
        0: "♠️A ", 1: "♠️2", 2: "♠️3", 3: "♠️4", 4: "♠️5 ", 5: "♠️6 ", 6: "♠️7 ", 7: "♠️8 ", 8: "♠️9 ", 9: "♠️10 ",
        10: "♠️J ", 11: "♠️Q ", 12: "♠️K ", 13: "♥️A ", 14: "♥️2 ", 15: "♥️3 ", 16: "♥️4 ", 17: "♥️5 ", 18: "♥️6 ",
        19: "♥️7 ", 20: "♥️8 ", 21: "♥️9 ", 22: "♥️10 ", 23: "♥️J ", 24: "♥️Q ", 25: "♥️K ", 26: "♣️A ", 27: "♣️2 ",
        28: "♣️3 ", 29: "♣️4 ", 30: "♣️5 ", 31: "♣️6 ", 32: "♣️7 ", 33: "♣️8 ", 34: "♣️9 ", 35: "♣️10 ", 36: "♣️J ",
        37: "♣️Q ", 38: "♣️K ", 39: "♦️A ", 40: "♦️2 ", 41: "♦️3 ", 42: "♦️4 ", 43: "♦️5 ", 44: "♦️6", 45: "♦️7",
        46: "♦️8 ", 47: "♦️9 ", 48: "♦️10 ", 49: "♦️J ", 50: "♦️Q ", 51: "♦️K ", 52: "none", 53: "小王", 54: "大王"
    ]
    
    
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
    
    static func cutRankConvert(cutNumSetting: Int, cardIndex: Int)->Int{
        var newCardRank:Int = 0
        let cardRank = cardIndex % 13
        let cardSuit = cardIndex / 13
        switch cutNumSetting{
        //"点数打色, J = 11, Q = 12, K = 13, 王 = 1"
        case 0:
            if cardIndex == 53 || cardIndex == 54{
                newCardRank = 1
                
            } else {
                newCardRank = cardRank + 1
            }
            break
        //"点数打色, J = 1, Q = 2, K = 3，王 = 1"
        case 1:
            if cardIndex == 53 || cardIndex == 54{
                newCardRank = 1
            } else if cardRank >= 10{
                newCardRank = cardRank % 10
            } else {
                newCardRank = cardRank + 1
            }
            break
        //点数打色, J = 1, Q = 1, K = 1, 王 = 1
        case 2:
            if cardIndex == 53 || cardIndex == 54{
                newCardRank = 1
            } else if cardRank >= 10{
                newCardRank = 1
            } else {
                newCardRank = cardRank + 1
            }
            break
        //点数打色, J = 4, Q = 3, K = 2, 王 = 1
        case 3:
            if cardIndex == 53 || cardIndex == 54{
                newCardRank = 1
            } else if cardRank >= 10{
                newCardRank = 4 - cardRank % 10
            } else {
                newCardRank = cardRank + 1
            }
            break
        //花色打色, 黑 = 1，红 = 2，梅 = 3，方 = 4
        case 4:
            newCardRank = cardSuit + 1
            break
        //花色打色, 黑 = 4，红 = 3，梅 = 2，方 = 1
        case 5:
            newCardRank = 4 - cardSuit
            break
        default:
            break
        }
        
        return newCardRank
        
    }
    
    static func selectGame(gameIndex: Int, inputCards: [Int], playerNum: Int, args : [Int], rankRules : [Int], suitRules: [Int],dealType: Int, diyDealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]], calModeArgs: [Int], cutNumSetting: Int, cutNumRangeSetting: [Int], consecutiveReport: Int, cutSetting: Int,  minCardNum: Int) -> [Int] {
        var reportResult:[Int] = []
        //TODO dealType 0 正发，1 反发 搞清楚ui
        //cutNumSetting 点数设置
        //cutNumRangeSetting 打色范围 [下限，上限]
        //consecutiveReport 连报轮数 1，2，3，不洗牌接着玩
        //TODO cutSetting 0, 不切牌， 1，切牌
        //calModeArgs [calMode, target, targetPos]
        //calmode 0不打色 1去色 2留色
        //target 0max 1min 2生死门
        //targetPos 这里变为0开始
        //dealType 0 正发，1 反发，2 自定义
        //diyDealType 0 正发，1反发
        //diyDealNum 派牌，公牌，或者去牌的数量
        //diyDealStatus 派牌/公牌/去牌
        let calMode = calModeArgs[0]
        let target = calModeArgs[1]
        let targetPos = calModeArgs[2]
        let newArgs = [dealType, diyDealType] + [playerNum] + args
        
        
        // 定义一个字典，将游戏索引映射到游戏函数
        // 返回的result包括两个int数组，一个是按牌大小从大到小排序的玩家编号数组，一个是这一轮结束之后牌库里剩下的牌
        let gameFunctions: [Int: ([[Bool]],[Int], [Int], [Int], [Int], [Int]) -> ([Int],[Int])] = [
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
            var currentCards = inputCards
            switch calMode{
            case 0://不打色
                
                for i in 0...consecutiveReport - 1{
                    let (result, leftCards) = gameFunction(diyDealStatus,diyDealNum, currentCards, newArgs, rankRules, suitRules)
                    if result.count != 0 {
                        //报最大
                        if target == 0{
                            reportResult.append(result[0])
                        }
                        //报最小
                        else if target == 1{
                            reportResult.append(result[result.count - 1])
                        }
                        //剩下的牌组
                        currentCards = leftCards
                        if leftCards.count == 0 {
                            break
                        }
                    } else if result.count == 0{
                        break
                    }
                }
            
            case 1://去色
                var currentConsecutiveReport = consecutiveReport
                // 如果是生死门没有连报
                if consecutiveReport > 1 && target == 2{
                    currentConsecutiveReport = 1
                }
                for i in 0..<currentConsecutiveReport{
                    var aliveTimes = 0
                    //遍历打色范围
                    for cardIndex in (cutNumRangeSetting[0] - 1)...(cutNumRangeSetting[1] - 1){
                        let cardRank = cutRankConvert(cutNumSetting: cutNumSetting, cardIndex: currentCards[cardIndex])
                        let newInputCards = Array(currentCards[(cardIndex+1)...])//去掉上面的牌
                        var resultTargetPos = 0
                        let (result, leftCards) = gameFunction(diyDealStatus,diyDealNum, newInputCards, newArgs, rankRules, suitRules)
                        if result.count != 0 {
                            //报切几张目标位置最大
                            if target == 0{
                                resultTargetPos = result[0]
                            }
                            //报切几张目标位置最小
                            else if target == 1{
                                resultTargetPos = result[result.count - 1]
                            //报生死门
                            } else if target == 2{
                                resultTargetPos = result[0]
                            }
                        } else if (result.isEmpty) {
                            break
                        }
                        let resultPos = (cardRank + resultTargetPos) % playerNum//起始发牌位置+目标输赢发牌位置
                        print("切牌数字 \(cardRank) 计算结果位置 \(resultPos) 目标位置 \(targetPos)")
                        if target == 0 || target == 1{
                            if resultPos == targetPos{//targetPos 0 - playerNum-1
                                print("切第\(cardIndex + 1)张最大/最小")
                                reportResult.append(cardIndex)
                                currentCards = leftCards
                                break
                            }
                        } else {
                            if resultPos == targetPos{
                                aliveTimes += 1
                            }
                        }
                        
                        if currentCards.count == 0 {
                            break
                        }
                    }
                    //生死门暂时没有连报
                    if target == 2{
                        reportResult.append(100 * aliveTimes / (cutNumRangeSetting[1] - cutNumRangeSetting[0] + 1))
                    }
                    if currentCards.count == 0{
                        break
                    }
                }
                
                
            case 2://留色
                var currentConsecutiveReport = consecutiveReport
                // 如果是生死门没有连报

                if consecutiveReport > 1 && target == 2{
                    currentConsecutiveReport = 1
                }
                for i in 0..<currentConsecutiveReport{
                    var aliveProb = 0

                    for cardIndex in (cutNumRangeSetting[0] - 1)...(cutNumRangeSetting[1] - 1){
                        let cardRank = inputCards[cardIndex] % 13
                        var resultTargetPos = 0
                        let (result, leftCards) = gameFunction(diyDealStatus, diyDealNum, inputCards, newArgs, rankRules, suitRules)
                        if result.count != 0 {
                            if target == 0{
                                resultTargetPos = result[0]
                            }
                            else if target == 1{
                                resultTargetPos = result[result.count - 1]
                            } else if target == 2{
                                resultTargetPos = result[0]
                                
                            }
                        } else if result.isEmpty {
                            break
                        }
                        let resultPos = (cardRank + resultTargetPos) % playerNum//起始发牌位置+目标输赢发牌位置
                        if target == 0 || target == 1 {
                            if resultPos == targetPos{
                                print("切第\(cardIndex + 1)张最大")
                                reportResult.append(cardIndex)
                                currentCards = leftCards
                                break
                            }
                        } else {
                            if resultPos == targetPos{
                                aliveProb += 1
                            }
                        }
                        if currentCards.count == 0 {
                            break
                        }
                    }
                    
                    if currentCards.count == 0 {
                        break
                    }
                    //生死门暂时没有连报
                    if target == 2{
                        reportResult.append(100 * aliveProb / (cutNumRangeSetting[1] - cutNumRangeSetting[0] + 1))
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
    var setting:[Int:String]
    var ruleInfo:[Int:String]
    var playerNum:[Int]
    

    init(ruleIndex: Int, ruleName: String) {
        self.ruleIndex = ruleIndex
        self.ruleName = ruleName
        self.rankRules = [:]
        self.setting = [:]
        self.ruleInfo = [:]
        self.playerNum = []
    }
}

public class RuleManager{
    static let shared = RuleManager()
    private static var userDefaults = UserDefaults.standard
    
    static var allUsersGameRule: [GameRule] = []
    //
    //[game:[rule1:[args, suitRule, rankrule, rankRuleChecked]]]
    //
    static var allPreSetRules: [Int:[Int:[[Int]]]] = [:]

    static func saveGameRule(){
        do {
//                RuleManager.allUsersGameRule.append(gameRule)
            let encodedData = try JSONEncoder().encode(RuleManager.allUsersGameRule)
                userDefaults.set(encodedData, forKey: "allUsersGameRule")
            } catch {
                print("Error encoding game rule: \(error.localizedDescription)")
            }
        
    }
    
    // 读取游戏规则
    // 返回读取出来的gamerule struct
    static func loadGameRule() -> [GameRule]? {
        print("开始读取规则")
        if let savedData = userDefaults.data(forKey: "allUsersGameRule") {
            do {
                let gameRule = try JSONDecoder().decode([GameRule].self, from: savedData)
                return gameRule
            } catch {
                print("Error decoding game rule: \(error.localizedDescription)")
            }
        }
        return []
    }
    
    //存储所有预设好的规则
    static func LoadAllPresetRules(){
        print("读取预设的规则")
        for i in 0...generalRuleSetting.allGameType.count - 1{
            allPreSetRules[i] = [:]
            var args: [Int] = []
            var suitRules: [Int] = []
            var rankRules: [Int] = []
            var rankRuleChecked: [Int] = []
            switch i{
            //德州预设规则
            case 0:
//                标准
//                isCompareSuit = 0
//                isAceStraight = 1
//                minRank = 0
//                handNum = 1
//                communityNum = 2
//                handUseType = 0
//                handUseNum = 0
                let rule = GameManager.gameRules[i] as! TexasPokerRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                args = [0,1,0,1,2,0,0]
                suitRules = [3,2,1,0]
                rankRules = [11,10,9,8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,0,0,0,1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                短牌
//                isCompareSuit = 0
//                isAceStraight = 1
//                minRank = 4
//                handNum = 1
//                communityNum = 2
//                handUseType = 0
//                handUseNum = 0
//                suitRules = [3,2,1,0]
                args = [0,1,4,1,2,0,0]
                rankRuleChecked = [1,1,1,1,1,1,0,0,0,1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                break
            //牛牛预设规则
            case 1:
                //斗牛-分花色
                let rule = GameManager.gameRules[i] as! PokerBullRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var cardsNum: Int = 6
                var handNum: Int = 1
                var isCompareSuit: Int = 1
                var wayToDeal:Int = 0
                var fiveLittleRank:Int = 0
                var secondRankRule:Int = 0
                var jokerIsMinZero:Int = 0
                var tenValueRange:Int = 0
                var JValueRange:Int = 0
                var QValueRange:Int = 0
                var KValueRange:Int = 0
                var blackJokerValueRange:Int = 0
                var redJokerValueRange:Int = 0
                var threeValueRange:Int = 0
                var sixValueRange:Int = 0
                var spadeAValueRange:Int = 0
                var bullrulelist:[Int] = [1,0,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [9, 10, 42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //斗牛-不分花色
                cardsNum = 6
                handNum = 1
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 3
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [9, 10, 42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)


//              斗牛-不分花色2
                cardsNum = 6
                handNum = 1
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [9, 10, 42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
                //斗牛-36张炸弹最大
                cardsNum = 2
                handNum = 1
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 3
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1, 0, 2, 7, 8, 9, 43, 42]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
                //斗牛-顺算牛
                cardsNum = 6
                handNum = 1
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,1,0,1,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [9,10,42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                斗牛-4带1
                cardsNum = 6
                handNum = 1
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 3
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1, 32, 9, 10, 42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
                //斗牛-对子
                cardsNum = 5
                handNum = 1
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [24,9, 10, 42]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
                //斗牛-40张炸弹最大
                cardsNum = 3
                handNum = 1
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1, 7, 8, 9, 10, 42]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
                //斗牛-54张炸弹最大
                cardsNum = 6
                handNum = 1
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1, 7, 9, 10, 42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
                //斗牛3条算牛
                cardsNum = 5
                handNum = 1
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackJokerValueRange = 0
                redJokerValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,1,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [45, 44, 42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
                break
            //炸金花
            case 2:
                //金花
                let rule = GameManager.gameRules[i] as! ThreeCardPokerGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 0
                var isCompareSuit = 1
                var minRank = 0
                var isAce = 2
                var isAceStraight = 1
                var isHeadCard = 1
                var isRedJoker = 0
                var redJokerSuit = 0
                var redJokerRank = 0
                var isBlackJoker = 0
                var blackJokerSuit = 0
                var blackJokerRank = 0
                var isReverseHighCard = 0
                
                args = [handNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadCard, isRedJoker, redJokerSuit, redJokerRank, isBlackJoker, blackJokerSuit, blackJokerRank, isReverseHighCard]
                suitRules = [3,2,1,0]
                rankRules = [13,12,11,10,9,8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [0,1,0,0,0,0,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //金花顺大
                handNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadCard = 1
                isRedJoker = 0
                redJokerSuit = 0
                redJokerRank = 0
                isBlackJoker = 0
                blackJokerSuit = 0
                blackJokerRank = 0
                isReverseHighCard = 0
                
                args = [handNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadCard, isRedJoker, redJokerSuit, redJokerRank, isBlackJoker, blackJokerSuit, blackJokerRank, isReverseHighCard]
                suitRules = [3,2,1,0]
                rankRules = [13,12,11,10,9,8,7,6,5,3,4,2,1,0]
                rankRuleChecked = [0,1,0,0,0,0,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                //金花AKJ
                handNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadCard = 1
                isRedJoker = 0
                redJokerSuit = 0
                redJokerRank = 0
                isBlackJoker = 0
                blackJokerSuit = 0
                blackJokerRank = 0
                isReverseHighCard = 0
                
                args = [handNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadCard, isRedJoker, redJokerSuit, redJokerRank, isBlackJoker, blackJokerSuit, blackJokerRank, isReverseHighCard]
                suitRules = [3,2,1,0]
                rankRules = [13,12,9,11,8,10,7,6,5,3,4,2,1,0]
                rankRuleChecked = [0,1,1,1,1,1,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
                //金花4选3
                handNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadCard = 1
                isRedJoker = 0
                redJokerSuit = 0
                redJokerRank = 0
                isBlackJoker = 0
                blackJokerSuit = 0
                blackJokerRank = 0
                isReverseHighCard = 0
                
                args = [handNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadCard, isRedJoker, redJokerSuit, redJokerRank, isBlackJoker, blackJokerSuit, blackJokerRank, isReverseHighCard]
                suitRules = [3,2,1,0]
                rankRules = [13,12,11,10,9,8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [0,1,0,0,0,0,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
                //百变金花
                handNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadCard = 1
                isRedJoker = 1
                redJokerSuit = 0
                redJokerRank = 14
                isBlackJoker = 1
                blackJokerSuit = 0
                blackJokerRank = 14
                isReverseHighCard = 0
                
                args = [handNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadCard, isRedJoker, redJokerSuit, redJokerRank, isBlackJoker, blackJokerSuit, blackJokerRank, isReverseHighCard]
                suitRules = [3,2,1,0]
                rankRules = [13,12,11,10,9,8,7,6,5,3,4,2,1,0]
                rankRuleChecked = [0,1,0,0,0,0,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
                break
            //小九
            case 3:
                //标准
                let rule = GameManager.gameRules[i] as! TinyNineGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 0
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var samePointComparision = 1
                var isCompareSuit = 0
                args = [handNum, redJokerValueRange, blackJokerValueRange, samePointComparision, isCompareSuit]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [0,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //湖南小九
                handNum = 0
                redJokerValueRange = 0
                blackJokerValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                args = [handNum, redJokerValueRange, blackJokerValueRange, samePointComparision, isCompareSuit]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                break
            //三公
            case 4:
                //常规三公
                let rule = GameManager.gameRules[i] as! ThreeMenGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var pointComparision = 0
                var samePointComparision = 0
                var isAAsMan = 0
                var isCompareSuit = 0
                var threeCardComparision = 0
                var mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //三公3-0点大
                pointComparision = 0
                samePointComparision = 0
                isAAsMan = 0
                isCompareSuit = 0
                threeCardComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision]
                suitRules = [2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//              三公2-3同大
                pointComparision = 1
                samePointComparision = 0
                isAAsMan = 0
                isCompareSuit = 0
                threeCardComparision = 0
                mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [3,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3:"三公4-3同大无混公",
                pointComparision = 1
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 0
                threeCardComparision = 0
                mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [3,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4:"三公5-A大于K",
                pointComparision = 1
                samePointComparision = 3
                isAAsMan = 1
                isCompareSuit = 0
                threeCardComparision = 0
                mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5:"三公8-单张比花色",
                pointComparision = 0
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 1
                threeCardComparision = 0
                mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [2,1,0,3]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6:"三公9-3公一样大",
                pointComparision = 2
                samePointComparision = 3
                isAAsMan = 0
                isCompareSuit = 0
                threeCardComparision = 0
                mixManComparision = 1
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [5,6,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7:"三公10-333最大",
                pointComparision = 1
                samePointComparision = 0
                isAAsMan = 0
                isCompareSuit = 0
                threeCardComparision = 2
                mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [3,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8:"三公12-AAA最大",
                pointComparision = 0
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 1
                threeCardComparision = 1
                mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [0,2,1,3]
                rankRules = [3,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9:"三公13-10算公",
                pointComparision = 1
                samePointComparision = 4
                isAAsMan = 0
                isCompareSuit = 0
                threeCardComparision = 0
                mixManComparision = 1
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10:"三公7-单张比花色",
                pointComparision = 0
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 1
                threeCardComparision = 0
                mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
//                11:"三公11-单张比花色",
                pointComparision = 0
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 1
                threeCardComparision = 0
                mixManComparision = 0
                args = [pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeCardComparision,mixManComparision]
                suitRules = [0,2,1,3]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
                
                break
            //二八杠
            case 5:
                // 二八杠对子大
                let rule = GameManager.gameRules[i] as! TwoEightGangGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var samePointComparision = 0
                var isCompareSuit = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var pointComparision = 0
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "二八杠28比对子大",
                samePointComparision = 0
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "二八分黑红",
                samePointComparision = 1
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "二八最大对k次大",
                samePointComparision = 0
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "二八杠10点大",
                samePointComparision = 0
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 1
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "江苏52张二八"
                samePointComparision = 0
                isCompareSuit = 0
                KValueRange = 1
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
                break
            //九点半
            case 6:
//                0: "54张九点半",
                let rule = GameManager.gameRules[i] as! NinePointFiveGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var samePointComparision = 0
                var isPairSameRank = 1
                var pairRequirement = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "54张9点半1",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "江西九点半",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "安徽九点半",
                redJokerValueRange = 1
                blackJokerValueRange = 1
                KValueRange = 0
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,3,1,6,7,5,4,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "江西54张九点半",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "九点半最大",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 0
                pairRequirement = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "江西九点半1",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "临沂九点半，对王最大",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 0
                pairRequirement = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [3,1,2,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8: "江西九点半2",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9: "九点半最大2",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 0
                pairRequirement = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
                break
            //宝子
            case 7:
                let rule = GameManager.gameRules[i] as! BaoziGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//              0: "宝子2张9点大",
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var JokerValueRange = 0
                var samePointComparision = 0
                var pointComparision = 0
                var cardRank = 0
                var pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "宝子2张10点大",
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                JokerValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "宝子P对大",
                KValueRange = 0
                QValueRange = 3
                JValueRange = 0
                JokerValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "52张宝子",
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                JokerValueRange = 0
                samePointComparision = 1
                pointComparision = 0
                cardRank = 2
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "52张上海宝子",
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                JokerValueRange = 0
                samePointComparision = 0
                pointComparision = 0
                cardRank = 1
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "54张宝子12",
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                JokerValueRange = 1
                samePointComparision = 0
                pointComparision = 1
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [4,3,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "唐山54张宝子",
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                JokerValueRange = 1
                samePointComparision = 2
                pointComparision = 0
                cardRank = 1
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [2,5,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "40张宝子分花色",
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                JokerValueRange = 0
                samePointComparision = 3
                pointComparision = 0
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8: "54张宝子13",
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                JokerValueRange = 1
                samePointComparision = 2
                pointComparision = 0
                cardRank = 1
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [2,1,5,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9: "54张比宝子14",
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                JokerValueRange = 1
                samePointComparision = 0
                pointComparision = 0
                cardRank = 0
                pairRank = 1
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10: "52张新疆宝子",
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                JokerValueRange = 0
                samePointComparision = 0
                pointComparision = 0
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
                
//                11: "宝子J",
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                JokerValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
//                12: "宝子Q",
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                JokerValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                13: "宝子K",
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                JokerValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                14: "江苏52张二八",
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                JokerValueRange = 0
                samePointComparision = 1
                pointComparision = 0
                cardRank = 0
                pairRank = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![14]!.append(args)
                allPreSetRules[i]![14]!.append(suitRules)
                allPreSetRules[i]![14]!.append(rankRules)
                allPreSetRules[i]![14]!.append(rankRuleChecked)
                break
            default:
                print("There is no preset rule for this game!!!!!")
                break
                }
            
        }
        
    }
}

struct GameRule: Codable{
    var RuleName: String
    var gameType: Int = 0
    var setting: Int = 0
    var calMode: Int = 0
    var dealType: Int = 0
    var diyDealType: Int = 0
    var diyDealNum: [Int] = []
    var diyDealStatus: [[Bool]] = []
    var playerNum: Int = 0
    var shuffleMode: Int = 0
    var cardToUse: [Int] = []
    var cutNumSetting: Int = 0
    var reportSetting: Int = 0
    var cutNumRangeSetting: [Int] = []
    var positionSetting: Int = 0
    var consecutiveReport: Int = 0
    var cutSetting: Int = 0
    var reportNumber: Int = 0
    var voiceReport: Int = 0
    var args: [Int] = []
    var suitRanks: [Int] = []
    var rankRules: [Int] = []
    var rankRuleChecked: [Int] = []
    init(RuleName: String, gameType: Int, setting: Int, calMode: Int, dealType: Int, diyDealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]], playerNum: Int, shuffleMode: Int, cardToUse: [Int], cutNumSetting: Int, reportSetting: Int, cutNumRangeSetting: [Int], positionSetting: Int, consecutiveReport: Int, cutSetting: Int, reportNumber: Int, voiceReport: Int, args: [Int], suitRanks: [Int], rankRules: [Int], rankRuleChecked: [Int]) {
        self.RuleName = RuleName
        self.gameType = gameType
        self.setting = setting
        self.calMode = calMode
        self.dealType = dealType
        self.diyDealType = diyDealType
        self.diyDealNum = diyDealNum
        self.diyDealStatus = diyDealStatus
        self.playerNum = playerNum
        self.shuffleMode = shuffleMode
        self.cardToUse = cardToUse
        self.cutNumSetting = cutNumSetting
        self.reportSetting = reportSetting
        self.cutNumRangeSetting = cutNumRangeSetting
        self.positionSetting = positionSetting
        self.consecutiveReport = consecutiveReport
        self.cutSetting = cutSetting
        self.reportNumber = reportNumber
        self.voiceReport = voiceReport
        self.args = args
        self.suitRanks = suitRanks
        self.rankRules = rankRules
        self.rankRuleChecked = rankRuleChecked
    }
}

struct RankRulesSate {
    var index: Int
    var isChecked: Bool
    
    
}


