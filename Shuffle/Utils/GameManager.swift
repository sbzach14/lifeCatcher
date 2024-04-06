

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
    
    static var CardNumberReportDic: [Int: String] = [
        1: "A",
        2: "2",
        3: "3",
        4: "4",
        5: "5",
        6: "6",
        7: "7",
        8: "8",
        9: "9",
        10: "10",
        11: "J",
        12: "Q",
        13: "K",
        14: "小王",
        15: "大王"
    ]
    
    static var SuitReportDix: [Int: String] = [
        0: "黑桃",
        1: "红桃",
        2: "梅花",
        3: "方片"
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
    
    static func selectGame(gameIndex: Int, inputCards: [Int], playerNum: Int, args : [Int], rankRules : [Int], suitRules: [Int],dealNum: Int, coloringType: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]], calModeArgs: [Int], cutNumSetting: Int, cutNumRangeSetting: [Int], consecutiveReport: Int, minCardNum: Int, cutCardIndexArray: [Int]) -> ([[Int]], ReportManager.MultipleReportResultInfo) {
        var reportResult:[[Int]] = []
        //TODO dealType 0 正发，1 反发 搞清楚ui
        //cutNumSetting 点数设置
        //cutNumRangeSetting 打色范围 [下限，上限]
        //consecutiveReport 连报轮数 1，2，3，不洗牌接着玩
        //calModeArgs [target, targetPos]
        //calmode 报法ID
        //target 0max 1min 2生死门
        //targetPos 这里变为0开始
        //dealNum 0 默认每轮发一张，1 自定义
        //coloringType 0，正面打色 1，反面打色
        //dealType 0 正发 1 反发
        //diyDealNum 派牌，公牌，或者去牌的数量
        //diyDealStatus 派牌/公牌/去牌
        let target = calModeArgs[0]
        let targetPos = calModeArgs[1]
        let newArgs = [dealNum, dealType] + [playerNum] + args
        
        //todo 根据target获取不同的calmode和其他属性
        let calMode = target
        
        // 定义一个字典，将游戏索引映射到游戏函数
        // 返回的result包括两个int数组，一个是按牌大小从大到小排序的玩家编号数组，一个是这一轮结束之后牌库里剩下的牌
        let gameFunctions: [Int: ([[Bool]],[Int], [Int], [Int], [Int], [Int]) -> ([Int],[Int],[Int])] = [:
//            0: TexasPoker.FindWinner,
//            1: PokerBull.FindWinner,
//            2: ThreeCardPokerGame.FindWinner,
//            3: TinyNineGame.FindWinner,
//            4: ThreeMenGame.FindWinner,
//            5: TwoEightGangGame.FindWinner,
//            6: NinePointFiveGame.FindWinner,
//            7: BaoziGame.FindWinner,
//            8: JiaJiaBaoGame.FindWinner,
//            9: CardNineGame.FindWinner,
//            10: NinePointGame.FindWinner,
//            11: FourCardGame.FindWinner(diyDealStatus:diyDealNum:inputCards:args:rankRules:suitRules:),
//            12: TwoCardGame.FindWinner(diyDealStatus:diyDealNum:inputCards:args:rankRules:suitRules:),
//            13: ThreeCardPointGame.FindWinner(diyDealStatus:diyDealNum:inputCards:args:rankRules:suitRules:),
//            14: TenPointFiveGame.FindWinner(diyDealStatus:diyDealNum:inputCards:args:rankRules:suitRules:)
        ]
        
        let (reportResultString, multipleGameInfo) =  ReportManager.GameReporter(gameIndex: gameIndex, inputCards: inputCards, cutCardIndexList: cutCardIndexArray, diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, newArgs: newArgs, rankRules: rankRules, suitRules: suitRules, reportID: calMode, cutNumSetting: cutNumSetting, cutNumRangeSetting: cutNumRangeSetting, targetPos: targetPos, coloringType: coloringType, consecutiveNum: consecutiveReport)
        
        print("播报结果: \(reportResultString)")
        
        

//        // 检查 gameIndex 是否存在于字典中
//        if let gameFunction = gameFunctions[gameIndex] {
//            print("Selected Game: \(gameFunction)")
//            var currentCards = inputCards
//            switch calMode{
//            case 0://不打色
//
//                for i in 0...consecutiveReport - 1{
//                    let (result, leftCards,winnerRanks) = gameFunction(diyDealStatus,diyDealNum, currentCards, newArgs, rankRules, suitRules)
//                    if result.count != 0 {
//                        //报最大
//                        if target == 0{
//
//                            reportResult.append(extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true))
//                        }
//                        //报最小
//                        else if target == 1{
//                            reportResult.append(extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: false))
//                        }
//                        //剩下的牌组
//                        currentCards = leftCards
//                        if leftCards.count == 0 {
//                            print("剩余的牌不足")
//                            break
//                        }
//                    } else if result.count == 0{
//                        print("当前牌不足")
//                        break
//                    }
//                }
//
//            case 1://去色
//                var currentConsecutiveReport = consecutiveReport
//                // 如果是生死门没有连报
//                if consecutiveReport > 1 && target == 2{
//                    currentConsecutiveReport = 1
//                }
//                for i in 0..<currentConsecutiveReport{
//                    var aliveTimes = 0
//                    var totalTimes = 0
//                    //遍历打色范围
//                    print("下一轮--------")
//                    for cardIndex in (cutNumRangeSetting[0] - 1)...(cutNumRangeSetting[1] - 1){
//                        let cardRank = cutRankConvert(cutNumSetting: cutNumSetting, cardIndex: currentCards[cardIndex])
//                        print("切第\(cardIndex + 1) 张 切到的牌是 \(GameManager.cardLabelDic[currentCards[cardIndex]]) 点数是 \(cardRank)")
//
//                        let newInputCards = Array(currentCards[(cardIndex+1)...])//去掉上面的牌
//                        var resultTargetPos:[Int] = []
//                        let (result, leftCards, winnerRanks) = gameFunction(diyDealStatus,diyDealNum, newInputCards, newArgs, rankRules, suitRules)
//                        if result.count != 0 {
//                            //报切几张目标位置最大
//                            if target == 0{
//                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true)
//                            }
//                            //报切几张目标位置最小
//                            else if target == 1{
//                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: false)
//                            //报生死门
//                            } else if target == 2{
//                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true)
//                            }
//                        } else if (result.isEmpty) {
//                            break
//                        }
//                        var resultPos:[Int] = []
//                        for resultTargetPo in resultTargetPos {
//                            resultPos.append((cardRank + resultTargetPo) % playerNum)
//                        }
//                        print("切牌数字 \(cardRank) 计算结果位置 \(resultPos) 目标位置 \(targetPos)")
//                        if target == 0 || target == 1{
//                            if resultPos.contains(where: {$0 == targetPos}) {//targetPos 0 - playerNum-1
//                                print("切第\(cardIndex + 1)张最大/最小")
//                                reportResult.append([cardIndex])
//                                currentCards = leftCards
//                                break
//                            }
//                        } else {
//                            if resultPos.contains(where: {$0 == targetPos}){
//                                aliveTimes += 1
//                            }
//                            totalTimes += 1
//                        }
//
//                        if currentCards.count == 0 {
//                            break
//                        }
//                    }
//                    //生死门暂时没有连报
//                    if target == 2{
//                        reportResult.append([100 * aliveTimes / totalTimes])
//                    }
//                    if reportResult.count != i + 1{
//                        reportResult.append([])
//                    }
//                    if currentCards.count == 0{
//                        break
//                    }
//                }
//
//
//            case 2://留色
//                var currentConsecutiveReport = consecutiveReport
//                // 如果是生死门没有连报
//
//                if consecutiveReport > 1 && target == 2{
//                    currentConsecutiveReport = 1
//                }
//                for i in 0..<currentConsecutiveReport{
//                    var aliveTimes = 0
//                    var totalTimes = 0
//
//                    print("下一轮--------")
//
//
//                    for cardIndex in (cutNumRangeSetting[0] - 1)...(cutNumRangeSetting[1] - 1){
//                        let cardRank = cutRankConvert(cutNumSetting: cutNumSetting, cardIndex: currentCards[cardIndex])
//
//                        print("切第\(cardIndex + 1) 张 切到的牌是 \(GameManager.cardLabelDic[currentCards[cardIndex]]) 点数是 \(cardRank)")
//
//                        var resultTargetPos:[Int] = []
//                        let (result, leftCards, winnerRanks) = gameFunction(diyDealStatus, diyDealNum, currentCards, newArgs, rankRules, suitRules)
//                        if result.count != 0 {
//                            if target == 0{
//                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true)
//                            }
//                            else if target == 1{
//                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: false)
//                            } else if target == 2{
//                                resultTargetPos = extractWinnerSet(inputWinners: result, inputWinnerRanks: winnerRanks, isWinner: true)
//
//                            }
//                        } else if result.isEmpty {
//                            break
//                        }
//                        var resultPos:[Int] = []
//                        for resultTargetPo in resultTargetPos {
//                            resultPos.append((cardRank + resultTargetPo) % playerNum)
//                        }
//                        print("切牌数字 \(cardRank) 计算结果位置 \(resultPos) 目标位置 \(targetPos)")
//                        if target == 0 || target == 1 {
//                            if resultPos.contains(where: {$0 == targetPos}){
//                                print("切第\(cardIndex + 1)张最大/最小")
//                                reportResult.append([cardIndex])
//                                currentCards = leftCards
//                                break
//                            }
//                        } else {
//                            if resultPos.contains(where: {$0 == targetPos}){
//                                aliveTimes += 1
//                            }
//                            totalTimes += 1
//                        }
//                        if currentCards.count == 0 {
//                            break
//                        }
//                    }
//
//
//                    //生死门暂时没有连报
//                    if target == 2{
//                        reportResult.append([100 * aliveTimes / totalTimes])
//                    }
//                    if reportResult.count != i + 1{
//                        reportResult.append([])
//                    }
//                    if currentCards.count == 0 {
//                        break
//                    }
//                }
//            default:
//                print("calModeArgs 0 error")
//            }
//        } else {
//            print("Invalid gameIndex: \(gameIndex)")
//        }
        
        return (reportResult, multipleGameInfo)
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
    static var allPreSetReportRules: [Int: ReportClass] = [:]

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
    //初始化预设好的报法
    static func LoadAllReportRules(){
        print("报法初始化成功")
        allPreSetReportRules[0] = ReportClass.init(reportName: "[1]报最大", reportID: 0, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[1] = ReportClass.init(reportName: "[2]报最小", reportID: 1, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[2] = ReportClass.init(reportName: "[3]报最大次大", reportID: 2, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[3] = ReportClass.init(reportName: "[4]报最小次小", reportID: 3, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[4] = ReportClass.init(reportName: "[5]报1大2大3大", reportID: 4, rankReport: 2, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[5] = ReportClass.init(reportName: "[6]报活门", reportID: 5, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[6] = ReportClass.init(reportName: "[7]报活门半活门对子", reportID: 6, rankReport: 0, aliveDeathReport: 0, pairReport: 0, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[7] = ReportClass.init(reportName: "[8]报最大次大和生死门", reportID: 7, rankReport: 1, aliveDeathReport: 2, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[8] = ReportClass.init(reportName: "[8_1]报最大次大活门半活门平点对子", reportID: 8, rankReport: 1, aliveDeathReport: 1, pairReport: 0, drawPointReport: 0, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[9] = ReportClass.init(reportName: "[10]报最大和最大家牌", reportID: 9, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: 1, differentDeal: -1)
        allPreSetReportRules[10] = ReportClass.init(reportName: "[12]报排名", reportID: 10, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[11] = ReportClass.init(reportName: "[13]报原始排名4432和生死门", reportID: 11, rankReport: 7, aliveDeathReport: 3, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[12] = ReportClass.init(reportName: "[14]报最大次大不打几平点对子", reportID: 12, rankReport: 1, aliveDeathReport: -1, pairReport: 0, drawPointReport: 3, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[13] = ReportClass.init(reportName: "[45]上10张打色留色再根据色牌点书去牌位置最大", reportID: 13, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 0, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[14] = ReportClass.init(reportName: "[46]上10张打色留色再根据色牌点书去牌位置最大次大", reportID: 14, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 0, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[15] = ReportClass.init(reportName: "[47]上10张打色去色再根据色牌点书去牌位置最大", reportID: 15, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[16] = ReportClass.init(reportName: "[48]上10张打色去色全部再根据色牌点书去牌位置最大次大", reportID: 16, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[17] = ReportClass.init(reportName: "[49]上10张打色留色保位置最大跑得快专用", reportID: 17, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[18] = ReportClass.init(reportName: "[50]上10张打色留色保位置最大", reportID: 18, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[19] = ReportClass.init(reportName: "[51]上10张打色留色保位置最大次大", reportID: 19, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[20] = ReportClass.init(reportName: "[52]上10张打色留色保位置最小", reportID: 20, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[21] = ReportClass.init(reportName: "[53]上10张打色留色保位置最小次小", reportID: 21, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[22] = ReportClass.init(reportName: "[54]上10张打色去色全部+底为色保位置最大", reportID: 22, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 4, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[23] = ReportClass.init(reportName: "[55]上10张打色去色全部保位置最大", reportID: 23, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[24] = ReportClass.init(reportName: "[56]上10张打色去色全部保位置最大次大", reportID: 24, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[25] = ReportClass.init(reportName: "[57]上10张打色去色全部保位置最小", reportID: 25, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[26] = ReportClass.init(reportName: "[58]上10张打色去色全部保位置最小次小", reportID: 26, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[27] = ReportClass.init(reportName: "[60]上10张打色去色1张保位置最大", reportID: 27, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[28] = ReportClass.init(reportName: "[61]上10张打色去色1张保位置最大次大", reportID: 28, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[29] = ReportClass.init(reportName: "[62]上10张打色去色1张保位置最小", reportID: 29, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[30] = ReportClass.init(reportName: "[63]上10张打色去色1张保位置最小次小", reportID: 30, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[31] = ReportClass.init(reportName: "[64]上10张打色去色1张+提前去掉的牌为色保位置最大", reportID: 31, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 5, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[32] = ReportClass.init(reportName: "[66]上10张打色色牌先发保位置最大", reportID: 32, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[33] = ReportClass.init(reportName: "[67]上10张打色色牌先发保位置最大次大", reportID: 33, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[34] = ReportClass.init(reportName: "[68]上10张打色色牌先发保位置最小", reportID: 34, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[35] = ReportClass.init(reportName: "[69]上10张打色色牌先发保位置最小次小", reportID: 35, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[36] = ReportClass.init(reportName: "[70]上10张去牌报多轮位置最大次大次数最多", reportID: 36, rankReport: 2, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 4, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[37] = ReportClass.init(reportName: "[71]上10张去牌保位置最大", reportID: 37, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[38] = ReportClass.init(reportName: "[71_1]上10张去牌保位置最大对优先", reportID: 38, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[39] = ReportClass.init(reportName: "[72]上10张去牌保位置最大次大", reportID: 39, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[40] = ReportClass.init(reportName: "[73]上10张去牌保位置最小", reportID: 40, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[41] = ReportClass.init(reportName: "[74]上10张去牌保位置最小次小", reportID: 41, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[42] = ReportClass.init(reportName: "[75]上10张去牌保有活门报活门", reportID: 42, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[43] = ReportClass.init(reportName: "[76]上10张去牌保有活门报最大", reportID: 43, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[44] = ReportClass.init(reportName: "[77]上10张去牌多轮同点报最大次大生死门", reportID: 44, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: 0, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: 1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[45] = ReportClass.init(reportName: "[78_1]上10张去牌多轮同点且无9点", reportID: 44, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: 0, ninePointReport: 0, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: 2, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[46] = ReportClass.init(reportName: "[78]上10张去牌多轮同点且无对子", reportID: 46, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: 1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: 3, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[47] = ReportClass.init(reportName: "[79]上10张去牌面牌为色去色报位置最大次大次数最多", reportID: 47, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 4, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[48] = ReportClass.init(reportName: "[80]上10张去牌底为色保位置最大次大", reportID: 48, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: 1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[49] = ReportClass.init(reportName: "[81]上10张去牌保位置最小无对子", reportID: 49, rankReport: 3, aliveDeathReport: 0, pairReport: 1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 4, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[50] = ReportClass.init(reportName: "[82]上10张去牌保34门有最大报最大", reportID: 50, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 12, reportTarget: 3, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 3, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[51] = ReportClass.init(reportName: "[83]上10张去牌保34门有最大次大报最大", reportID: 51, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 12, reportTarget: 3, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 3, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[52] = ReportClass.init(reportName: "[84]上10张抽面牌保位置最大", reportID: 52, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 24, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[53] = ReportClass.init(reportName: "[84_1]上10张抽面牌保位置最小", reportID: 53, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 24, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[54] = ReportClass.init(reportName: "[85]上10张去牌保多轮位置最大次数最多", reportID: 54, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: 0, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[55] = ReportClass.init(reportName: "[86]上10张去牌面为色色先发保位置最大次大", reportID: 55, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[56] = ReportClass.init(reportName: "[87]上10张去牌面为色色先发保位置最大", reportID: 56, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[57] = ReportClass.init(reportName: "[88]上10张去牌面为色色先发保位置最小", reportID: 57, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 11, reportTarget: 1, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[58] = ReportClass.init(reportName: "[91]上10张去牌保无牛或最多一家有牛", reportID: 58, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: 0, reportCutRange: 11, reportTarget: 7, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[59] = ReportClass.init(reportName: "[92]上10张去牌保至少一家牛牛", reportID: 59, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: 1, reportCutRange: 11, reportTarget: 8, cardsTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[60] = ReportClass.init(reportName: "[94]上下5张去牌保1门最小有两家同点", reportID: 60, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: 2, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 1, reportTarget: 1, cardsTransformation: 7, consecutiveReport: -1, positionToReport: 2, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[61] = ReportClass.init(reportName: "[95]上下5张去牌保4门最大", reportID: 61, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 1, reportTarget: 1, cardsTransformation: 7, consecutiveReport: -1, positionToReport: 2, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[62] = ReportClass.init(reportName: "[96]上下5张去牌保34门有最大报最大", reportID: 62, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 1, reportTarget: 1, cardsTransformation: 7, consecutiveReport: -1, positionToReport: 3, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[63] = ReportClass.init(reportName: "[97]上下5张去牌保2门是活门报最大", reportID: 63, rankReport: 0, aliveDeathReport: -1, pairReport: 0, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 1, reportTarget: 5, cardsTransformation: 7, consecutiveReport: -1, positionToReport: 2, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[64] = ReportClass.init(reportName: "[98]上下5张打色色先发保位置最小", reportID: 64, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 8, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[65] = ReportClass.init(reportName: "[99]上下5张打色色先发保位置最大", reportID: 65, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 8, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[66] = ReportClass.init(reportName: "[100]上下5张打色留色保位置最大", reportID: 66, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 9, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[67] = ReportClass.init(reportName: "[101]上下5张打色留色保位置最大次大", reportID: 67, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 9, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[68] = ReportClass.init(reportName: "[102]上下5张打色留色保位置最小", reportID: 68, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 9, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[69] = ReportClass.init(reportName: "[103]上下5张打色留色保位置最小次小", reportID: 69, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 9, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[70] = ReportClass.init(reportName: "[105]上下5张打色去色1张保位置最大", reportID: 70, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 10, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[71] = ReportClass.init(reportName: "[106]上下5张打色去色1张保位置最大次大", reportID: 71, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 10, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[72] = ReportClass.init(reportName: "[107]上下5张打色去色1张保位置最小", reportID: 72, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 10, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[73] = ReportClass.init(reportName: "[108]上下5张打色去色1张保位置最小次小", reportID: 73, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 5, reportTarget: 1, cardsTransformation: 10, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[74] = ReportClass.init(reportName: "[110]下10张打色留色保位置最大次大", reportID: 74, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 2, reportTarget: 1, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 15, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[75] = ReportClass.init(reportName: "[111]下10张打色留色保位置最小次小", reportID: 75, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 2, reportTarget: 1, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 15, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[76] = ReportClass.init(reportName: "[112]下10张打色留色面牌移动到色牌下面保位置最大", reportID: 76, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 2, reportTarget: 1, cardsTransformation: 25, consecutiveReport: -1, positionToReport: 0, colorCardPos: 15, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[77] = ReportClass.init(reportName: "[120]下10张打色色牌先发保位置最大次大", reportID: 77, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 2, reportTarget: 1, cardsTransformation: 26, consecutiveReport: -1, positionToReport: 0, colorCardPos: 15, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[78] = ReportClass.init(reportName: "[121]下10张打色色牌先发保位置最小次小", reportID: 78, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 2, reportTarget: 1, cardsTransformation: 26, consecutiveReport: -1, positionToReport: 0, colorCardPos: 15, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[79] = ReportClass.init(reportName: "[130]看手牌报生死门", reportID: 79, rankReport: 0, aliveDeathReport: 1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 0, cardsTransformation: 18, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[80] = ReportClass.init(reportName: "[131]看手牌报最大", reportID: 80, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 0, cardsTransformation: 18, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[81] = ReportClass.init(reportName: "[132]看手牌报最大次大", reportID: 81, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 0, cardsTransformation: 18, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[82] = ReportClass.init(reportName: "[133]看手牌报最大次大生死门", reportID: 82, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 0, cardsTransformation: 18, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[83] = ReportClass.init(reportName: "[134]看手牌比第一张点数从最大牌继续发报最大", reportID: 83, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 0, cardsTransformation: 19, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[84] = ReportClass.init(reportName: "[135]看手牌比第一张点数从最大牌继续发报最大次大", reportID: 84, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 0, cardsTransformation: 19, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[85] = ReportClass.init(reportName: "[143]看手牌面为色留色报最大", reportID: 85, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 1, cardsTransformation: 20, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[86] = ReportClass.init(reportName: "[144]看手牌面为色留色报最大次大", reportID: 86, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 1, cardsTransformation: 20, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[87] = ReportClass.init(reportName: "[145]看手牌面为色留色报最大次大生死门", reportID: 87, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 1, cardsTransformation: 20, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[88] = ReportClass.init(reportName: "[147]看手牌面为色去色报最大", reportID: 88, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 1, cardsTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[89] = ReportClass.init(reportName: "[148]看手牌面为色去色报最大次大", reportID: 89, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 1, cardsTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[90] = ReportClass.init(reportName: "[149]看手牌面为色去色报最大次大生死门", reportID: 90, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 6, reportTarget: 1, cardsTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //TODO : 91-107
        allPreSetReportRules[108] = ReportClass.init(reportName: "[284]:固定范围切牌报对子和同点数目", reportID: 108, rankReport: 0, aliveDeathReport: -1, pairReport: 2, drawPointReport: 2, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 0, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[109] = ReportClass.init(reportName: "[285]:固定范围切牌报那个位置拿最大最多", reportID: 109, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 2, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[110] = ReportClass.init(reportName: "[286]:固定范围切牌报那个位置拿最大次大最多", reportID: 110, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 2, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[111] = ReportClass.init(reportName: "[289]:范围切牌保指定2家有最大", reportID: 111, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 13, reportTarget: 10, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 3, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //TODO 112-113
        allPreSetReportRules[114] = ReportClass.init(reportName: "[292]:范围切牌保位置活门", reportID: 114, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[115] = ReportClass.init(reportName: "[293]:范围切牌保位置死门", reportID: 115, rankReport: 0, aliveDeathReport: 4, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 1, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[116] = ReportClass.init(reportName: "[296]:范围切牌保位置最小次小", reportID: 116, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[117] = ReportClass.init(reportName: "[297]:范围切牌面为色去色保位置最大次大", reportID: 117, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 22, consecutiveReport: -1, positionToReport: 0, colorCardPos: 10, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[118] = ReportClass.init(reportName: "[298]:范围切牌面为色色先发保位置最大次大", reportID: 117, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 10, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[119] = ReportClass.init(reportName: "[299_1]:范围切牌保位置最大", reportID: 119, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[120] = ReportClass.init(reportName: "[299]:范围切牌保位置最大次大", reportID: 120, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[121] = ReportClass.init(reportName: "[300]:范围切牌打色留色保位置最大", reportID: 121, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[122] = ReportClass.init(reportName: "[301]:范围切牌打色留色保位置最大次大", reportID: 122, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[123] = ReportClass.init(reportName: "[304]:范围切牌打色去色全部保位置最大", reportID: 123, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[124] = ReportClass.init(reportName: "[305]:范围切牌打色去色全部保位置最大次大", reportID: 124, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[125] = ReportClass.init(reportName: "[310]:范围切牌打色去色1张保位置最大", reportID: 125, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[126] = ReportClass.init(reportName: "[311]:范围切牌打色去色1张保位置最大次大", reportID: 126, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[127] = ReportClass.init(reportName: "[316]:范围切牌打色色先发保位置最大", reportID: 127, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[128] = ReportClass.init(reportName: "[317]:范围切牌打色色先发保位置最大次大", reportID: 128, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[129] = ReportClass.init(reportName: "[330]:范围切牌打色留色保位置最小", reportID: 129, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[130] = ReportClass.init(reportName: "[331]:范围切牌打色留色保位置最小次小", reportID: 130, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[131] = ReportClass.init(reportName: "[334]:范围切牌打色去色保位置最小", reportID: 131, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[132] = ReportClass.init(reportName: "[335]:范围切牌打色去色保位置最小次小", reportID: 132, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[133] = ReportClass.init(reportName: "[338]:范围切牌打色去色1张保位置最小", reportID: 133, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[134] = ReportClass.init(reportName: "[339]:范围切牌打色去色1张保位置最小次小", reportID: 134, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[135] = ReportClass.init(reportName: "[342]:范围切牌打色色先发保位置最小", reportID: 135, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[136] = ReportClass.init(reportName: "[343]:范围切牌打色色先发保位置最小次小", reportID: 136, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 9, cardsTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //todo 137-147
        allPreSetReportRules[148] = ReportClass.init(reportName: "[450]:指定底牌报最大次大", reportID: 148, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[149] = ReportClass.init(reportName: "[451]:指定底牌报最大", reportID: 148, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[150] = ReportClass.init(reportName: "[452]:指定底牌报最小次小", reportID: 150, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[151] = ReportClass.init(reportName: "[453]:指定底牌报最小", reportID: 151, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[152] = ReportClass.init(reportName: "[454]:指定底牌报生死门", reportID: 152, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[153] = ReportClass.init(reportName: "[500]:指定顶牌报最大次大", reportID: 153, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[154] = ReportClass.init(reportName: "[501]:指定顶牌报最大", reportID: 154, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[155] = ReportClass.init(reportName: "[502]:指定顶牌报最小次小", reportID: 155, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[156] = ReportClass.init(reportName: "[503]:指定顶牌报最小", reportID: 156, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[157] = ReportClass.init(reportName: "[504]:指定顶牌报生死门", reportID: 157, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[158] = ReportClass.init(reportName: "[510]:指定顶牌底牌为色报最大次大", reportID: 158, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: 16, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[159] = ReportClass.init(reportName: "[511]:指定顶牌底牌为色报最大", reportID: 159, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: 16, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[160] = ReportClass.init(reportName: "[512]:指定顶牌底牌为色报最小次小", reportID: 160, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: 16, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[161] = ReportClass.init(reportName: "[513]:指定顶牌底牌为色报最小", reportID: 161, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorCardPos: 16, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[162] = ReportClass.init(reportName: "[514]:指定牌上一张打色留色报最大次大", reportID: 162, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 6, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[163] = ReportClass.init(reportName: "[515]:指定牌上一张打色去色报最大次大", reportID: 163, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 27, consecutiveReport: -1, positionToReport: 0, colorCardPos: 6, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[164] = ReportClass.init(reportName: "[516]:指定牌下一张打色留色报最大次大", reportID: 164, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 7, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[165] = ReportClass.init(reportName: "[517]:指定牌下一张打色去色报最大次大", reportID: 165, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 28, consecutiveReport: -1, positionToReport: 0, colorCardPos: 7, hasSpecialCard: 0, specifiedPlayerHand: -1, differentDeal: -1)
        //TODO 166-167
        allPreSetReportRules[168] = ReportClass.init(reportName: "[520]:底为色报位置最大次大", reportID: 168, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[169] = ReportClass.init(reportName: "[521]:底为色报位置最大", reportID: 169, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[170] = ReportClass.init(reportName: "[522]:底为色报位置最小次小", reportID: 170, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[171] = ReportClass.init(reportName: "[523]:底为色报位置最小", reportID: 171, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[172] = ReportClass.init(reportName: "[524]:底为色报位置排名", reportID: 172, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //todo 173
        allPreSetReportRules[174] = ReportClass.init(reportName: "[526]:底2张相加为色报位置最大次大", reportID: 174, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 3, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //todo 175-176
        allPreSetReportRules[177] = ReportClass.init(reportName: "[530]:面为色报位置最大次大", reportID: 177, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[178] = ReportClass.init(reportName: "[531]:面为色报位置最大", reportID: 178, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[179] = ReportClass.init(reportName: "[532]:面为色报位置最小次小", reportID: 179, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[180] = ReportClass.init(reportName: "[533]:面为色报位置最小", reportID: 180, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[181] = ReportClass.init(reportName: "[534]:面为色报位置排名", reportID: 181, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[182] = ReportClass.init(reportName: "[540]:面为色去色报位置最大次大", reportID: 182, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[183] = ReportClass.init(reportName: "[541]:面为色去色报位置最大", reportID: 183, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[184] = ReportClass.init(reportName: "[542]:面为色去色报位置最小次小", reportID: 182, rankReport: 2, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[185] = ReportClass.init(reportName: "[543]:面为色去色报位置最小", reportID: 185, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[186] = ReportClass.init(reportName: "[544]:面为色去色报排名", reportID: 186, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 9, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //todo 187-192
        allPreSetReportRules[193] = ReportClass.init(reportName: "[700]:去掉14张面牌报哪家最大", reportID: 193, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[194] = ReportClass.init(reportName: "[701]:去掉14张面牌报哪家最小", reportID: 194, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[195] = ReportClass.init(reportName: "[702]:去掉14张面牌报哪家最大次大", reportID: 195, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[196] = ReportClass.init(reportName: "[703]:去掉14张面牌报哪家最大2大3大", reportID: 196, rankReport: 2, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[197] = ReportClass.init(reportName: "[704]:去掉14张面牌报哪家最小次小", reportID: 197, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[198] = ReportClass.init(reportName: "[705]:去掉14张面牌再根据第14张牌点书再去牌报哪家最大", reportID: 198, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 14, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[199] = ReportClass.init(reportName: "[706]:去掉14张面牌再根据第14张牌点书再去牌报哪家最小", reportID: 199, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 14, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[200] = ReportClass.init(reportName: "[707]:去掉面牌底牌再根据面牌底牌点数和再去牌报最大次大", reportID: 200, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 15, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[201] = ReportClass.init(reportName: "[708]:固定去掉6、7、8、9张牌，以去牌数为色报位置最大", reportID: 200, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 8, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 11, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //TODO 202
        allPreSetReportRules[203] = ReportClass.init(reportName: "[719]:比第一张牌从最大牌继续发报最大次大", reportID: 203, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 16, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[204] = ReportClass.init(reportName: "[720]:比第一张牌从最大牌继续发报最大", reportID: 204, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 16, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[205] = ReportClass.init(reportName: "[721]:比第一张牌从最小牌继续发报最大", reportID: 205, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 17, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[206] = ReportClass.init(reportName: "[722]:比第一张牌从最小牌继续发报最大次大", reportID: 206, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: -1, cardsTransformation: 17, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //todo 207-208
        allPreSetReportRules[209] = ReportClass.init(reportName: "[725]:比第一张牌从最大牌继续发报各家点数", reportID: 209, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 15, consecutiveReport: -1, positionToReport: 0, colorCardPos: -1, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //todo 210-212
        allPreSetReportRules[213] = ReportClass.init(reportName: "[755]:看色留色上10 张去牌保位置最大", reportID: 212, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 3, reportTarget: 1, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[251] = ReportClass.init(reportName: "[756]:看色留色上10 张去牌保位置最大次大", reportID: 251, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 3, reportTarget: 1, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[214] = ReportClass.init(reportName: "[758]:看色留色+色牌上X张为色报最大次大", reportID: 214, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 11, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        //todo 215
        allPreSetReportRules[216] = ReportClass.init(reportName: "[760]:看色留色报最大", reportID: 216, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[217] = ReportClass.init(reportName: "[761]:看色留色报最大次大", reportID: 217, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[218] = ReportClass.init(reportName: "[762]:看色留色报最小", reportID: 218, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[219] = ReportClass.init(reportName: "[763]:看色留色报最小次小", reportID: 219, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[220] = ReportClass.init(reportName: "[764]:看色留色报排名", reportID: 220, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[221] = ReportClass.init(reportName: "[766]:看色去色全部报最大", reportID: 221, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[222] = ReportClass.init(reportName: "[767]:看色去色全部报最大次大", reportID: 222, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[223] = ReportClass.init(reportName: "[768]:看色去色全部报最小", reportID: 223, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[224] = ReportClass.init(reportName: "[769]:看色去色全部报最小次小", reportID: 224, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[225] = ReportClass.init(reportName: "[770]:看色去色全部报排名", reportID: 225, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: 0, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[226] = ReportClass.init(reportName: "[790]:固定第10张牌作色留色报最大", reportID: 226, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[227] = ReportClass.init(reportName: "[791]:固定第10张牌作色留色报最大次大", reportID: 227, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[252] = ReportClass.init(reportName: "[792]:固定第10张牌作色留色报最小", reportID: 252, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[228] = ReportClass.init(reportName: "[793]:固定第10张牌作色留色报最小次小", reportID: 228, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[229] = ReportClass.init(reportName: "[794]:固定第10张牌作色留色报排名", reportID: 229, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        
        allPreSetReportRules[230] = ReportClass.init(reportName: "[795]:固定第10张牌作色留色4种发牌方式报最大", reportID: 230, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 14, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: 0)
        allPreSetReportRules[231] = ReportClass.init(reportName: "[796]:固定第10张牌作色留色4种发牌方式报最小", reportID: 231, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: -1, reportTarget: 0, cardsTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorCardPos: 14, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: 0)
        allPreSetReportRules[232] = ReportClass.init(reportName: "[800]:固定第10张牌作色去色全部报最大", reportID: 232, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 9, reportTarget: 0, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[233] = ReportClass.init(reportName: "[801]:固定第10张牌作色去色全部报最大次大", reportID: 233, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 9, reportTarget: 0, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[234] = ReportClass.init(reportName: "[802]:固定第10张牌作色去色全部报最小", reportID: 234, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 9, reportTarget: 0, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[235] = ReportClass.init(reportName: "[803]:固定第10张牌作色去色全部报最小次小", reportID: 235, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 9, reportTarget: 0, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[236] = ReportClass.init(reportName: "[804]:固定第10张牌作色去色全部报排名", reportID: 236, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 9, reportTarget: 0, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: -1)
        allPreSetReportRules[237] = ReportClass.init(reportName: "[805]:固定第10张牌作色去色全部四种发牌方式报最大", reportID: 237, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 9, reportTarget: 0, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: 0)
        allPreSetReportRules[238] = ReportClass.init(reportName: "[806]:固定第10张牌作色去色全部四种发牌方式报最小", reportID: 238, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 9, reportTarget: 0, cardsTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: 0)
        allPreSetReportRules[239] = ReportClass.init(reportName: "[810]:固定去面上Y张牌,从X-Y张选择色牌，保1大2大", reportID: 239, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1, pokerBullReport: -1, reportCutRange: 0, reportTarget: 0, cardsTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorCardPos: 8, hasSpecialCard: -1, specifiedPlayerHand: -1, differentDeal: 0)
        //TODO240-250
        
    }
    //存储所有预设好的报法
    
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
                //德州扑克[701]
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
                rankRules = [11,10,9,8,7,6,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
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


