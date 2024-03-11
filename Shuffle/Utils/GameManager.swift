

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
        let rule8 = JiaJiaBaoGameRule(ruleIndex: 8, ruleName: "佳佳宝")
        let rule9 = CardNineGameRule(ruleIndex: 9, ruleName: "牌九")
        let rule10 = NinePointGameRule(ruleIndex: 10, ruleName: "九点")
        let rule11 = FourCardGameRule(ruleIndex: 11, ruleName: "4张")
        let rule12 = TwoCardGameRule(ruleIndex: 12, ruleName: "2张")
        let rule13 = ThreeCardPointGameRule(ruleIndex: 13, ruleName: "3张")
        let rule14 = TenPointFiveGameRule(ruleIndex: 14, ruleName: "10点半")
        return [rule0.ruleIndex: rule0, rule1.ruleIndex: rule1, rule2.ruleIndex: rule2, rule3.ruleIndex: rule3, rule4.ruleIndex: rule4, rule5.ruleIndex: rule5, rule6.ruleIndex: rule6, rule7.ruleIndex: rule7, rule8.ruleIndex: rule8, rule9.ruleIndex: rule9,rule10.ruleIndex:rule10, rule11.ruleIndex: rule11,rule12.ruleIndex:rule12, rule13.ruleIndex:rule13, rule14.ruleIndex: rule14]
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
    
    static func extractWinnerSet(inputWinners: [Int], inputWinnerRanks:[Int], isWinner: Bool) -> [Int]{
        var winners:[Int] = []
        var winnerRanks:[Int] = []
        
        var resultList:[Int] = []
        print("输入数组 \(inputWinners) \(inputWinnerRanks)")

        if isWinner == true{
            winners = inputWinners
            winnerRanks = inputWinnerRanks
        } else {
            winners = inputWinners.reversed()
            winnerRanks = inputWinnerRanks.reversed()
        }
        print("当前的结果数组 \(winners) \(winnerRanks)")
        for index in 0..<winners.count{
            print("当前resultList \(resultList)")
            if index == 0{
                resultList.append(winners[index])
                continue
            } else {
                if winnerRanks[index] == winnerRanks[index - 1] {
                    resultList.append(winners[index])
                } else {
                    break
                }
            }
        }
        print("最终目标玩家 \(resultList)")
        return resultList
    }
    
    static func selectGame(gameIndex: Int, inputCards: [Int], playerNum: Int, args : [Int], rankRules : [Int], suitRules: [Int],dealNum: Int, coloringType: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]], calModeArgs: [Int], cutNumSetting: Int, cutNumRangeSetting: [Int], consecutiveReport: Int, minCardNum: Int) -> [[Int]] {
        var reportResult:[[Int]] = []
        //TODO dealType 0 正发，1 反发 搞清楚ui
        //cutNumSetting 点数设置
        //cutNumRangeSetting 打色范围 [下限，上限]
        //consecutiveReport 连报轮数 1，2，3，不洗牌接着玩
        //calModeArgs [target, targetPos]
        //calmode 0不打色 1去色 2留色
        //target 0max 1min 2生死门
        //targetPos 这里变为0开始
        //dealNum 0 默认每轮发一张，1 自定义
        //coloringType 0，正面打色 1，反面打色
        //dealType 0 正发 1 反发
        //diyDealNum 派牌，公牌，或者去牌的数量
        //diyDealStatus 派牌/公牌/去牌
        let target = calModeArgs[0]
        let targetPos = calModeArgs[1]
        let newArgs = [dealNum + dealType] + [playerNum] + args
        
        //todo 根据target获取不同的calmode和其他属性
        let calMode = target
        
        // 定义一个字典，将游戏索引映射到游戏函数
        // 返回的result包括两个int数组，一个是按牌大小从大到小排序的玩家编号数组，一个是这一轮结束之后牌库里剩下的牌
        let gameFunctions: [Int: ([[Bool]],[Int], [Int], [Int], [Int], [Int]) -> ([Int],[Int],[Int])] = [
            0: TexasPoker.FindWinner,
            1: PokerBull.FindWinner,
            2: ThreeCardPokerGame.FindWinner,
            3: TinyNineGame.FindWinner,
            4: ThreeMenGame.FindWinner,
            5: TwoEightGangGame.FindWinner,
            6: NinePointFiveGame.FindWinner,
            7: BaoziGame.FindWinner,
            8: JiaJiaBaoGame.FindWinner,
            9: CardNineGame.FindWinner,
            10: NinePointGame.FindWinner
        ]

        // 检查 gameIndex 是否存在于字典中
        if let gameFunction = gameFunctions[gameIndex] {
            print("Selected Game: \(gameFunction)")
            var currentCards = inputCards
            switch calMode{
            case 0://不打色
                
                for i in 0...consecutiveReport - 1{
                    let (result, leftCards,winnerRanks) = gameFunction(diyDealStatus,diyDealNum, currentCards, newArgs, rankRules, suitRules)
                    if result.count != 0 {
                        //报最大
                        if target == 0{
                            
                            reportResult.append(extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true))
                        }
                        //报最小
                        else if target == 1{
                            reportResult.append(extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: false))
                        }
                        //剩下的牌组
                        currentCards = leftCards
                        if leftCards.count == 0 {
                            print("剩余的牌不足")
                            break
                        }
                    } else if result.count == 0{
                        print("当前牌不足")
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
                    var totalTimes = 0
                    //遍历打色范围
                    print("下一轮--------")
                    for cardIndex in (cutNumRangeSetting[0] - 1)...(cutNumRangeSetting[1] - 1){
                        let cardRank = cutRankConvert(cutNumSetting: cutNumSetting, cardIndex: currentCards[cardIndex])
                        print("切第\(cardIndex + 1) 张 切到的牌是 \(GameManager.cardLabelDic[currentCards[cardIndex]]) 点数是 \(cardRank)")
                        
                        let newInputCards = Array(currentCards[(cardIndex+1)...])//去掉上面的牌
                        var resultTargetPos:[Int] = []
                        let (result, leftCards, winnerRanks) = gameFunction(diyDealStatus,diyDealNum, newInputCards, newArgs, rankRules, suitRules)
                        if result.count != 0 {
                            //报切几张目标位置最大
                            if target == 0{
                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true)
                            }
                            //报切几张目标位置最小
                            else if target == 1{
                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: false)
                            //报生死门
                            } else if target == 2{
                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true)
                            }
                        } else if (result.isEmpty) {
                            break
                        }
                        var resultPos:[Int] = []
                        for resultTargetPo in resultTargetPos {
                            resultPos.append((cardRank + resultTargetPo) % playerNum)
                        }
//                        let resultPos = (cardRank + resultTargetPos) % playerNum//起始发牌位置+目标输赢发牌位置
                        print("切牌数字 \(cardRank) 计算结果位置 \(resultPos) 目标位置 \(targetPos)")
                        if target == 0 || target == 1{
                            if resultPos.contains(where: {$0 == targetPos}) {//targetPos 0 - playerNum-1
                                print("切第\(cardIndex + 1)张最大/最小")
                                reportResult.append([cardIndex])
                                currentCards = leftCards
                                break
                            }
                        } else {
                            if resultPos.contains(where: {$0 == targetPos}){
                                aliveTimes += 1
                            }
                            totalTimes += 1
                        }
                        
                        if currentCards.count == 0 {
                            break
                        }
                    }
                    //生死门暂时没有连报
                    if target == 2{
                        reportResult.append([100 * aliveTimes / totalTimes])
                    }
                    if reportResult.count != i + 1{
                        reportResult.append([])
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
                    var aliveTimes = 0
                    var totalTimes = 0
                    
                    print("下一轮--------")
                    

                    for cardIndex in (cutNumRangeSetting[0] - 1)...(cutNumRangeSetting[1] - 1){
                        let cardRank = cutRankConvert(cutNumSetting: cutNumSetting, cardIndex: currentCards[cardIndex])
                        
                        print("切第\(cardIndex + 1) 张 切到的牌是 \(GameManager.cardLabelDic[currentCards[cardIndex]]) 点数是 \(cardRank)")
                        
                        var resultTargetPos:[Int] = []
                        let (result, leftCards, winnerRanks) = gameFunction(diyDealStatus, diyDealNum, currentCards, newArgs, rankRules, suitRules)
                        if result.count != 0 {
                            if target == 0{
                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true)
                            }
                            else if target == 1{
                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: false)
                            } else if target == 2{
                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true)
                                
                            }
                        } else if result.isEmpty {
                            break
                        }
                        var resultPos:[Int] = []
                        for resultTargetPo in resultTargetPos {
                            resultPos.append((cardRank + resultTargetPo) % playerNum)
                        }
//                        let resultPos = (cardRank + resultTargetPos) % playerNum//起始发牌位置+目标输赢发牌位置
                        print("切牌数字 \(cardRank) 计算结果位置 \(resultPos) 目标位置 \(targetPos)")
                        if target == 0 || target == 1 {
                            if resultPos.contains(where: {$0 == targetPos}){
                                print("切第\(cardIndex + 1)张最大/最小")
                                reportResult.append([cardIndex])
                                currentCards = leftCards
                                break
                            }
                        } else {
                            if resultPos.contains(where: {$0 == targetPos}){
                                aliveTimes += 1
                            }
                            totalTimes += 1
                        }
                        if currentCards.count == 0 {
                            break
                        }
                    }
                    

                    //生死门暂时没有连报
                    if target == 2{
                        reportResult.append([100 * aliveTimes / totalTimes])
                    }
                    if reportResult.count != i + 1{
                        reportResult.append([])
                    }
                    if currentCards.count == 0 {
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
//                10: "斗牛10张比两次分花色[504]",
                cardsNum = 6
                handNum = 2
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
                rankRules = [1,7,9,10,42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
//                11: "斗牛4条3条[509]",
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
                bullrulelist = [1,1,0,0,0,0,0,0,0]
                args = [cardsNum,handNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,jokerIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackJokerValueRange,redJokerValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1,46, 9, 10, 42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
//                12: "斗牛5大5小[510]",
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
                rankRules = [0,2, 1, 7, 45,44,42]
                rankRuleChecked = [1,1,1,1,1,1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                13: "斗牛-40张同点一样大[511]",
                cardsNum = 3
                handNum = 1
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 1
                secondRankRule = 4
                jokerIsMinZero = 0
                tenValueRange = 0
                JValueRange = 3
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
                rankRules = [1,2,45,44,42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![13]!.append(args)
                allPreSetRules[i]![13]!.append(suitRules)
                allPreSetRules[i]![13]!.append(rankRules)
                allPreSetRules[i]![13]!.append(rankRuleChecked)
//                14: "斗牛-40张第二轮有公牌[512]",
                cardsNum = 3
                handNum = 2
                isCompareSuit = 1
                wayToDeal = 1
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
                rankRules = [1,45,44,42]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![14]!.append(args)
                allPreSetRules[i]![14]!.append(suitRules)
                allPreSetRules[i]![14]!.append(rankRules)
                allPreSetRules[i]![14]!.append(rankRuleChecked)
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
                rankRules = [13,12,11,10,9,8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [0,1,0,0,0,0,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "金花4选3[420]",
                handNum = 1
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
                rankRules = [12, 6, 4, 3, 1, 0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "金花A23[306]",
                handNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 3
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
                rankRules = [12, 6, 4, 3, 1, 0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "金花5选3[560]",
                handNum = 2
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
                rankRules = [12, 6, 4, 3, 1, 0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                7: "金花6选3[610]",
                handNum = 3
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
                rankRules = [12, 6, 4, 3, 1, 0]
                rankRuleChecked = [1,1,1,1,1,1]
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
                rankRules = [3,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4:"三公5-A大于K",
                pointComparision = 1
                samePointComparision = 2
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
                rankRules = [7,0]
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
                isCompareSuit = 1
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
//                6: "28杠28比对子大[244]",
                samePointComparision = 3
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 1
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "28杠28比对子大[245]",
                samePointComparision = 3
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 1
                JValueRange = 1
                pointComparision = 0
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8: "28杠比花色[246]",
                samePointComparision = 2
                isCompareSuit = 1
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
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
//                10:"安徽九点半[226]",
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
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
//                11:"安徽九点半[235]",
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
                rankRules = [2,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
//                12:"江西九点半[237]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 1
                isPairSameRank = 0
                pairRequirement = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                13:"54张九点半[238]",
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
                allPreSetRules[i]![13]!.append(args)
                allPreSetRules[i]![13]!.append(suitRules)
                allPreSetRules[i]![13]!.append(rankRules)
                allPreSetRules[i]![13]!.append(rankRuleChecked)
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
                var AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                pointComparision = 0
                cardRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
                
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
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
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![14]!.append(args)
                allPreSetRules[i]![14]!.append(suitRules)
                allPreSetRules[i]![14]!.append(rankRules)
                allPreSetRules[i]![14]!.append(rankRuleChecked)
                //15: 52张宝子对子算点数不分花色
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                JokerValueRange = 0
                samePointComparision = 0
                pointComparision = 0
                cardRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
                suitRules = [0,0,0,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![15]!.append(args)
                allPreSetRules[i]![15]!.append(suitRules)
                allPreSetRules[i]![15]!.append(rankRules)
                allPreSetRules[i]![15]!.append(rankRuleChecked)
                // 16: "54张宝子15[213]",
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                JokerValueRange = 2
                samePointComparision = 2
                pointComparision = 0
                cardRank = 1
                pairRank = 0
                AvalueRange = 1
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
                suitRules = [0,0,0,0]
                rankRules = [2,5,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![16]!.append(args)
                allPreSetRules[i]![16]!.append(suitRules)
                allPreSetRules[i]![16]!.append(rankRules)
                allPreSetRules[i]![16]!.append(rankRuleChecked)
                // 17: "宝子2张9点大[212]",
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                JokerValueRange = 3
                samePointComparision = 1
                pointComparision = 0
                cardRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [KValueRange,QValueRange,JValueRange,JokerValueRange, samePointComparision, pointComparision, cardRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [2,6,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![17]!.append(args)
                allPreSetRules[i]![17]!.append(suitRules)
                allPreSetRules[i]![17]!.append(rankRules)
                allPreSetRules[i]![17]!.append(rankRuleChecked)
                break
            case 8:
                //通用54张佳佳宝
                let rule = GameManager.gameRules[i] as! JiaJiaBaoGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var samePointComparision = 0
                var CardRankList = 0
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var handNum = 0
                var isCompareSuit = 1
                
                args = [samePointComparision,CardRankList,redJokerValueRange,blackJokerValueRange,KValueRange,QValueRange,JValueRange, handNum, isCompareSuit]
                suitRules = [0,1,0,1]
                rankRules = [4,2,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //通用54张佳佳宝，比四张
                samePointComparision = 0
                CardRankList = 0
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                handNum = 1
                isCompareSuit = 1
                args = [samePointComparision,CardRankList,redJokerValueRange,blackJokerValueRange,KValueRange,QValueRange,JValueRange, handNum, isCompareSuit]
                suitRules = [0,1,0,1]
                rankRules = [4,2,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                
//                2: "通用四张，9点对子算点数",
                samePointComparision = 1
                CardRankList = 1
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                handNum = 0
                isCompareSuit = 0
                args = [samePointComparision,CardRankList,redJokerValueRange,blackJokerValueRange,KValueRange,QValueRange,JValueRange, handNum, isCompareSuit]
                suitRules = [0,1,0,1]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "通用四张，54张佳佳宝1",
                samePointComparision = 1
                CardRankList = 1
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                handNum = 1
                isCompareSuit = 1
                args = [samePointComparision,CardRankList,redJokerValueRange,blackJokerValueRange,KValueRange,QValueRange,JValueRange, handNum, isCompareSuit]
                suitRules = [0,1,0,1]
                rankRules = [4,2,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
                
                break
            case 9:
                //杭州小牌九
                let rule = GameManager.gameRules[i] as! CardNineGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var pointComparision = 0
                var samePointComparision = 0
                var AValueRange = 0
                var pairRank = 0
                var cardRankRule = 0
                var handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [7,5,6,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "温州牌九[260]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 1
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "通用四张-牌九大牌九1[...",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [12,8,9,13,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "52张小牌九[262]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "宁波小牌九[263]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "杭州牌九[264]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "32张牌9[456]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "湖南牌九[265]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8: "通用四张-32张牌九[416]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9: "山西牌九[268]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10: "通用四张-54张大牌九[..",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
//                11: "34张小牌九[457]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
//                12: "通用四张-32张牌九二[...",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                13: "温州牌九黑大3[269]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![13]!.append(args)
                allPreSetRules[i]![13]!.append(suitRules)
                allPreSetRules[i]![13]!.append(rankRules)
                allPreSetRules[i]![13]!.append(rankRuleChecked)
//                14: "南京牌九[261]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![14]!.append(args)
                allPreSetRules[i]![14]!.append(suitRules)
                allPreSetRules[i]![14]!.append(rankRules)
                allPreSetRules[i]![14]!.append(rankRuleChecked)
//                15: "32张牌九[266]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![15]!.append(args)
                allPreSetRules[i]![15]!.append(suitRules)
                allPreSetRules[i]![15]!.append(rankRules)
                allPreSetRules[i]![15]!.append(rankRuleChecked)
//                16: "山西牌九[269]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![16]!.append(args)
                allPreSetRules[i]![16]!.append(suitRules)
                allPreSetRules[i]![16]!.append(rankRules)
                allPreSetRules[i]![16]!.append(rankRuleChecked)
//                17: "通用四张-杭州牌九[420]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                cardRankRule = 0
                handNum = 0
                
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, cardRankRule, handNum]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![17]!.append(args)
                allPreSetRules[i]![17]!.append(suitRules)
                allPreSetRules[i]![17]!.append(rankRules)
                allPreSetRules[i]![17]!.append(rankRuleChecked)
                break
            case 10:
//                0:"福建54张9点[221]",
                let rule = GameManager.gameRules[i] as! NinePointGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var samePointComparision = 0
                var isCompareSuit = 0
                var handNum = 0
                var cardRankRule = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1:"通用四张-四张9点大[4..]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                handNum = 1
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2:"通用四张-54张9点混...",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 1
                isCompareSuit = 0
                handNum = 0
                cardRankRule = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3:"52张9点[226]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                handNum = 0
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4:"9点昆[222]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                samePointComparision = 0
                isCompareSuit = 0
                handNum = 0
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5:"东兴九点[223]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 1
                isCompareSuit = 0
                handNum = 0
                cardRankRule = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6:"潍坊9点 J/Q/K王算1[2...",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                handNum = 0
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7:"9点对K大[225]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                handNum = 0
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [3,2,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8:"52张9点最大[252]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                handNum = 0
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9:"54张9点[228]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 2
                isCompareSuit = 1
                handNum = 0
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10:"通用四张9点 J/Q/K..."
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                handNum = 1
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,handNum,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
                break
            //4张
            case 11:
                let rule = GameManager.gameRules[i] as! FourCardGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//                0: "4张比单张[410]",
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var KValueRange = 1
                var QValueRange = 1
                var JValueRange = 1
                var pointComparision = 0
                var samePointComparision = 0
                var cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "4张9点[411]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                break
            //2张
            case 12:
                let rule = GameManager.gameRules[i] as! TwoCardGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//                0: "A59[250]",
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var pointComparision = 0
                var samePointComparision = 0
                var cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "合合[251]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 1
                cardRankRule = 1
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "梭哈[258]",
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                cardRankRule = 0
                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
                break
            //三张
            case 13:
                let rule = GameManager.gameRules[i] as! ThreeCardPointGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//                0: "三张9点[330]",
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var samePointComparision = 0
                var isCompareSuit = 0
                var pointComparision = 0

                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "三张9点半[331]",
                redJokerValueRange = 1
                blackJokerValueRange = 1
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0

                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "三张10点半[332]",
                redJokerValueRange = 1
                blackJokerValueRange = 1
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0

                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "三张9点[333]",
                redJokerValueRange = 2
                blackJokerValueRange = 2
                KValueRange = 2
                QValueRange = 2
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0

                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "三张9点[334]",
                redJokerValueRange = 3
                blackJokerValueRange = 3
                KValueRange = 3
                QValueRange = 3
                JValueRange = 2
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0

                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "三张10点半[335]"
                redJokerValueRange = 1
                blackJokerValueRange = 1
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 1

                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
                break
            //10点半
            case 14:
                let rule = GameManager.gameRules[i] as! TenPointFiveGameRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                
//                0: "十点半[270]",
                var redJokerValueRange = 0
                var blackJokerValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var samePointComparision = 0
                var isCompareSuit = 0
                var pointComparision = 0
                var cardRankRule = 0

                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision, cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)

//                1: "十点半[271]"
                redJokerValueRange = 0
                blackJokerValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0
                cardRankRule = 0

                args = [redJokerValueRange, blackJokerValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision, cardRankRule]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                
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
    var dealNum: Int = 0
    var coloringType: Int = 0
    var dealType: Int = 0
    var diyDealType: Int = 0
    var diyDealNum: [Int] = []
    var diyDealStatus: [[Bool]] = []
    var playerNum: Int = 0
    var shuffleMode: Int = 0
    var cutMode: Int = 0
    var cardToUse: [Int] = []
    var cutNumSetting: Int = 0
    var reportSetting: Int = 0
    var cutNumRangeSetting: [Int] = []
    var positionSetting: Int = 0
    var consecutiveReport: Int = 0
    var reportNumber: Int = 0
    var voiceReport: Int = 0
    var args: [Int] = []
    var suitRanks: [Int] = []
    var rankRules: [Int] = []
    var rankRuleChecked: [Int] = []
    var minCardNum: Int
    init(RuleName: String, gameType: Int, setting: Int, dealNum: Int, coloringType: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]], playerNum: Int, shuffleMode: Int, cutMode: Int, cardToUse: [Int], cutNumSetting : Int, reportSetting: Int, cutNumRangeSetting: [Int], positionSetting: Int, consecutiveReport: Int, reportNumber: Int, voiceReport: Int, args: [Int], suitRanks: [Int], rankRules: [Int], rankRuleChecked: [Int], minCardNum: Int) {
        self.RuleName = RuleName
        self.gameType = gameType
        self.setting = setting
        self.dealNum = dealNum
        self.coloringType = coloringType
        self.dealType = dealType
        self.diyDealNum = diyDealNum
        self.diyDealStatus = diyDealStatus
        self.playerNum = playerNum
        self.shuffleMode = shuffleMode
        self.cutMode = cutMode
        self.cardToUse = cardToUse
        self.cutNumSetting = cutNumSetting
        self.reportSetting = reportSetting
        self.cutNumRangeSetting = cutNumRangeSetting
        self.positionSetting = positionSetting
        self.consecutiveReport = consecutiveReport
        self.reportNumber = reportNumber
        self.voiceReport = voiceReport
        self.args = args
        self.suitRanks = suitRanks
        self.rankRules = rankRules
        self.rankRuleChecked = rankRuleChecked
        self.minCardNum = minCardNum
    }
}

struct RankRulesSate {
    var index: Int
    var isChecked: Bool
    
}


