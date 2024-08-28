

import Foundation
import SwiftUI

class ClassifierSettingArgs {
    
    static var deviceID: String = ""
    static var isLoginServer: Bool = false
    
    static let singlefeatureLabelDic : [Int:String] = [
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
    
    static var SingleFeatureNumberReportDic: [Int: String] = [
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
        3: "黑桃",
        2: "红桃",
        1: "梅花",
        0: "方片"
    ]
    
    
    static var targetSetting: [Int: Rule] = {
        let rule0 = TPRule(ruleIndex: 0, ruleName: "德州")
        let rule1 = PBRule(ruleIndex: 1, ruleName: "牛牛")
        let rule2 = ZJHDatasetRule(ruleIndex: 2, ruleName: "炸金花")
        let rule3 = TNDatasetRule(ruleIndex: 3, ruleName: "小九")
        let rule4 = TMDatasetRule(ruleIndex: 4, ruleName: "三公")
        let rule5 = TEGDatasetRule(ruleIndex: 5, ruleName: "二八杠")
        let rule6 = NPFiveDatasetRule(ruleIndex: 6, ruleName: "九点半")
        let rule7 = BZDatasetRule(ruleIndex: 7, ruleName: "宝子")
        let rule8 = JJBDatasetRule(ruleIndex: 8, ruleName: "佳佳宝")
        let rule9 = CNDatasetRule(ruleIndex: 9, ruleName: "牌九")
        let rule10 = NPDatasetRule(ruleIndex: 10, ruleName: "九点")
        let rule11 = FCDatasetRule(ruleIndex: 11, ruleName: "四张")
        let rule12 = TCDatasetRule(ruleIndex: 12, ruleName: "两张")
        let rule13 = TCPDatasetRule(ruleIndex: 13, ruleName: "三张")
        let rule14 = TPFiveDatasetRule(ruleIndex: 14, ruleName: "十点半")
        let rule15 = CBDatasetRule(ruleIndex: 15, ruleName: "比鸡")
        let rule16 = TWDatasetRule(ruleIndex: 16, ruleName: "十三水")
        return [rule0.ruleIndex: rule0, rule1.ruleIndex: rule1, rule2.ruleIndex: rule2, rule3.ruleIndex: rule3, rule4.ruleIndex: rule4, rule5.ruleIndex: rule5, rule6.ruleIndex: rule6, rule7.ruleIndex: rule7, rule8.ruleIndex: rule8, rule9.ruleIndex: rule9,rule10.ruleIndex:rule10, rule11.ruleIndex: rule11,rule12.ruleIndex:rule12, rule13.ruleIndex:rule13, rule14.ruleIndex: rule14, rule15.ruleIndex: rule15, rule16.ruleIndex: rule16]
    }()
    
    static func cutRankConvert(cutNumSetting: Int, singlefeatureIndex: Int)->Int{
        var newSingleFeatureRank:Int = 0
        let singlefeatureRank = singlefeatureIndex % 13
        let singlefeatureSuit = singlefeatureIndex / 13
        switch cutNumSetting{
        //"点数打色, J = 11, Q = 12, K = 13, 王 = 1"
        case 0:
            if singlefeatureIndex == 53 || singlefeatureIndex == 54{
                newSingleFeatureRank = 1
                
            } else {
                newSingleFeatureRank = singlefeatureRank + 1
            }
            break
        //"点数打色, J = 1, Q = 2, K = 3，王 = 1"
        case 1:
            if singlefeatureIndex == 53 || singlefeatureIndex == 54{
                newSingleFeatureRank = 1
            } else if singlefeatureRank >= 10{
                newSingleFeatureRank = singlefeatureRank % 10
            } else {
                newSingleFeatureRank = singlefeatureRank + 1
            }
            break
        //点数打色, J = 1, Q = 1, K = 1, 王 = 1
        case 2:
            if singlefeatureIndex == 53 || singlefeatureIndex == 54{
                newSingleFeatureRank = 1
            } else if singlefeatureRank >= 10{
                newSingleFeatureRank = 1
            } else {
                newSingleFeatureRank = singlefeatureRank + 1
            }
            break
        //点数打色, J = 4, Q = 3, K = 2, 王 = 1
        case 3:
            if singlefeatureIndex == 53 || singlefeatureIndex == 54{
                newSingleFeatureRank = 1
            } else if singlefeatureRank >= 10{
                newSingleFeatureRank = 4 - singlefeatureRank % 10
            } else {
                newSingleFeatureRank = singlefeatureRank + 1
            }
            break
        //花色打色, 黑 = 1，红 = 2，梅 = 3，方 = 4
        case 4:
            newSingleFeatureRank = singlefeatureSuit + 1
            break
        //花色打色, 黑 = 4，红 = 3，梅 = 2，方 = 1
        case 5:
            newSingleFeatureRank = 4 - singlefeatureSuit
            break
        default:
            break
        }
        
        return newSingleFeatureRank
        
    }
    
    static func extractWinnerSet(inputWinners: [Int], inputWinnerRanks:[Int], isWinner: Bool) -> [Int]{
        var winners:[Int] = []
        var winnerRanks:[Int] = []
        
        var resultList:[Int] = []
        
        if isWinner == true{
            winners = inputWinners
            winnerRanks = inputWinnerRanks
        } else {
            winners = inputWinners.reversed()
            winnerRanks = inputWinnerRanks.reversed()
        }
        for index in 0..<winners.count{
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
        return resultList
    }
    
    static func selectDataset(DatasetIndex: Int, inputSingleFeatures: [Int], rcNum: Int, args : [Int], rankRules : [Int], suitRules: [Int],dealNum: Int, coloringType: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]], calModeArgs: [Int], cutNumSetting: Int, cutNumRangeSetting: [Int], consecutiveReport: Int, minSingleFeatureNum: Int, cutSingleFeatureIndexArray: [Int]) -> ReportManager.MultipleReportResultInfo {
        
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
        let newArgs = [dealNum, dealType] + [rcNum] + args
        
        //todo 根据target获取不同的calmode和其他属性
        let calMode = target
        
        // 定义一个字典，将游戏索引映射到游戏函数
        // 返回的result包括两个int数组，一个是按牌大小从大到小排序的玩家编号数组，一个是这一轮结束之后牌库里剩下的牌

        
        let multipleDatasetInfo =  ReportManager.DatasetReporter(DatasetIndex: DatasetIndex, inputSingleFeatures: inputSingleFeatures, cutSingleFeatureIndexList: cutSingleFeatureIndexArray, diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, newArgs: newArgs, rankRules: rankRules, suitRules: suitRules, reportID: calMode, cutNumSetting: cutNumSetting, cutNumRangeSetting: cutNumRangeSetting, targetPos: targetPos, coloringType: coloringType, consecutiveNum: consecutiveReport)
        
        return multipleDatasetInfo
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
    var rcNum:[Int]
    

    init(ruleIndex: Int, ruleName: String) {
        self.ruleIndex = ruleIndex
        self.ruleName = ruleName
        self.rankRules = [:]
        self.setting = [:]
        self.ruleInfo = [:]
        self.rcNum = []
    }
}

public class DetectSettingArgs{
    static let shared = DetectSettingArgs()
    private static var userDefaults = UserDefaults.standard
    
    static var allUsersDatasetRule: [DatasetRule] = []
    //
    //[Dataset:[rule1:[args, suitRule, rankrule, rankRuleChecked]]]
    //
    static var allPreSetRules: [Int:[Int:[[Int]]]] = [:]
    static var allPreSetReportRules: [Int: ReportClass] = [:]

    static func saveDatasetRule(){
        do {
//                DetectSettingArgs.allUsersDatasetRule.append(DatasetRule)
            let encodedData = try JSONEncoder().encode(DetectSettingArgs.allUsersDatasetRule)
                userDefaults.set(encodedData, forKey: "allUsersDatasetRule")
            } catch {
                // print("Error encoding Dataset rule: \(error.localizedDescription)")
            }
        
    }
    
    // 读取游戏规则
    // 返回读取出来的Datasetrule struct
    static func loadDatasetRule() -> [DatasetRule]? {
        if let savedData = userDefaults.data(forKey: "allUsersDatasetRule") {
            do {
                let DatasetRule = try JSONDecoder().decode([DatasetRule].self, from: savedData)
                return DatasetRule
            } catch {
               
            }
        }
        return []
    }
    
    //初始化预设好的报法
    static func LoadAllReportRules(){
        allPreSetReportRules[0] = ReportClass.init(reportName: "[1]报最大", reportID: 0, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[1] = ReportClass.init(reportName: "[2]报最小", reportID: 1, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[2] = ReportClass.init(reportName: "[3]报最大次大", reportID: 2, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[3] = ReportClass.init(reportName: "[4]报最小次小", reportID: 3, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[4] = ReportClass.init(reportName: "[5]报1大2大3大", reportID: 4, rankReport: 2, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[5] = ReportClass.init(reportName: "[6]报活门", reportID: 5, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[6] = ReportClass.init(reportName: "[7]报活门半活门对子", reportID: 6, rankReport: 0, aliveDeathReport: 0, pairReport: 0, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[7] = ReportClass.init(reportName: "[8]报最大次大和生死门", reportID: 7, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[8] = ReportClass.init(reportName: "[8_1]报最大次大活门半活门平点对子", reportID: 8, rankReport: 1, aliveDeathReport: 0, pairReport: 3, drawPointReport: 0, ninePointReport: -1,  reportCutRange: -1, reportTarget: 12, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[9] = ReportClass.init(reportName: "[10]报最大和最大家牌", reportID: 9, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: 1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[10] = ReportClass.init(reportName: "[12]报排名", reportID: 10, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[11] = ReportClass.init(reportName: "[13]报原始排名4432和生死门", reportID: 11, rankReport: 7, aliveDeathReport: 3, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[12] = ReportClass.init(reportName: "[14]报最大次大不打几平点对子", reportID: 12, rankReport: 1, aliveDeathReport: -1, pairReport: 0, drawPointReport: 2, ninePointReport: 1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: -1, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[13] = ReportClass.init(reportName: "[45]上10张打色留色再根据色牌点书去牌位置最大", reportID: 13, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 0, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[14] = ReportClass.init(reportName: "[46]上10张打色留色再根据色牌点书去牌位置最大次大", reportID: 14, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 0, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[15] = ReportClass.init(reportName: "[47]上10张打色去色再根据色牌点书去牌位置最大", reportID: 15, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[16] = ReportClass.init(reportName: "[48]上10张打色去色全部再根据色牌点书去牌位置最大次大", reportID: 16, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[17] = ReportClass.init(reportName: "[49]上10张打色留色保位置最大跑得快专用", reportID: 17, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[18] = ReportClass.init(reportName: "[50]上10张打色留色保位置最大", reportID: 18, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[19] = ReportClass.init(reportName: "[51]上10张打色留色保位置最大次大", reportID: 19, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[20] = ReportClass.init(reportName: "[52]上10张打色留色保位置最小", reportID: 20, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[21] = ReportClass.init(reportName: "[53]上10张打色留色保位置最小次小", reportID: 21, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[22] = ReportClass.init(reportName: "[54]上10张打色去色全部+底为色保位置最大", reportID: 22, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 4, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[23] = ReportClass.init(reportName: "[55]上10张打色去色全部保位置最大", reportID: 23, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[24] = ReportClass.init(reportName: "[56]上10张打色去色全部保位置最大次大", reportID: 24, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[25] = ReportClass.init(reportName: "[57]上10张打色去色全部保位置最小", reportID: 25, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[26] = ReportClass.init(reportName: "[58]上10张打色去色全部保位置最小次小", reportID: 26, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[27] = ReportClass.init(reportName: "[60]上10张打色去色1张保位置最大", reportID: 27, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[28] = ReportClass.init(reportName: "[61]上10张打色去色1张保位置最大次大", reportID: 28, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[29] = ReportClass.init(reportName: "[62]上10张打色去色1张保位置最小", reportID: 29, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[30] = ReportClass.init(reportName: "[63]上10张打色去色1张保位置最小次小", reportID: 30, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[31] = ReportClass.init(reportName: "[64]上10张打色去色1张+提前去掉的牌为色保位置最大", reportID: 31, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 5, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[32] = ReportClass.init(reportName: "[66]上10张打色色牌先发保位置最大", reportID: 32, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[33] = ReportClass.init(reportName: "[67]上10张打色色牌先发保位置最大次大", reportID: 33, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[34] = ReportClass.init(reportName: "[68]上10张打色色牌先发保位置最小", reportID: 34, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[35] = ReportClass.init(reportName: "[69]上10张打色色牌先发保位置最小次小", reportID: 35, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[36] = ReportClass.init(reportName: "[70]上10张去牌报多轮位置最大次大次数最多", reportID: 36, rankReport: 2, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 4, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[37] = ReportClass.init(reportName: "[71]上10张去牌保位置最大", reportID: 37, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[38] = ReportClass.init(reportName: "[71_1]上10张去牌保位置最大对优先", reportID: 38, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[39] = ReportClass.init(reportName: "[72]上10张去牌保位置最大次大", reportID: 39, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[40] = ReportClass.init(reportName: "[73]上10张去牌保位置最小", reportID: 40, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[41] = ReportClass.init(reportName: "[74]上10张去牌保位置最小次小", reportID: 41, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[42] = ReportClass.init(reportName: "[75]上10张去牌保有活门报活门", reportID: 42, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 6, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[43] = ReportClass.init(reportName: "[76]上10张去牌保有活门报最大", reportID: 43, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 6, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[44] = ReportClass.init(reportName: "[77]上10张去牌多轮同点报最大次大生死门", reportID: 44, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: 0, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: 1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[45] = ReportClass.init(reportName: "[78_1]上10张去牌多轮同点且无9点", reportID: 44, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: 0, ninePointReport: 0,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: 2, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[46] = ReportClass.init(reportName: "[78]上10张去牌多轮同点且无对子", reportID: 46, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: 1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: 3, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[47] = ReportClass.init(reportName: "[79]上10张去牌面牌为色去色报位置最大次大次数最多", reportID: 47, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 4, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[48] = ReportClass.init(reportName: "[80]上10张去牌底为色保位置最大次大", reportID: 48, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[49] = ReportClass.init(reportName: "[81]上10张去牌保位置最小无对子", reportID: 49, rankReport: 3, aliveDeathReport: 0, pairReport: 1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 4, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[50] = ReportClass.init(reportName: "[82]上10张去牌保34门有最大报最大", reportID: 50, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 12, reportTarget: 3, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 3, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[51] = ReportClass.init(reportName: "[83]上10张去牌保34门有最大次大报最大", reportID: 51, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 12, reportTarget: 3, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 3, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[52] = ReportClass.init(reportName: "[84]上10张抽面牌保位置最大", reportID: 52, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 24, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[53] = ReportClass.init(reportName: "[84_1]上10张抽面牌保位置最小", reportID: 53, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 24, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[54] = ReportClass.init(reportName: "[85]上10张去牌保多轮位置最大次数最多", reportID: 54, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: 0, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[55] = ReportClass.init(reportName: "[86]上10张去牌面为色色先发保位置最大次大", reportID: 55, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[56] = ReportClass.init(reportName: "[87]上10张去牌面为色色先发保位置最大", reportID: 56, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[57] = ReportClass.init(reportName: "[88]上10张去牌面为色色先发保位置最小", reportID: 57, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[58] = ReportClass.init(reportName: "[91]上10张去牌保无牛或最多一家有牛", reportID: 58, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 7, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[59] = ReportClass.init(reportName: "[92]上10张去牌保至少一家牛牛", reportID: 59, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 11, reportTarget: 8, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[60] = ReportClass.init(reportName: "[94]上下5张去牌保1门最小有两家同点", reportID: 60, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: 0, ninePointReport: -1,  reportCutRange: 1, reportTarget: 11, singlefeaturesTransformation: 7, consecutiveReport: -1, positionToReport: 2, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[61] = ReportClass.init(reportName: "[95]上下5张去牌保4门最大", reportID: 61, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 1, reportTarget: 1, singlefeaturesTransformation: 7, consecutiveReport: -1, positionToReport: 2, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[62] = ReportClass.init(reportName: "[96]上下5张去牌保34门有最大报最大", reportID: 62, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 1, reportTarget: 3, singlefeaturesTransformation: 7, consecutiveReport: -1, positionToReport: 3, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[63] = ReportClass.init(reportName: "[97]上下5张去牌保2门是活门报最大", reportID: 63, rankReport: 0, aliveDeathReport: 0, pairReport: 0, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 1, reportTarget: 5, singlefeaturesTransformation: 7, consecutiveReport: -1, positionToReport: 2, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[64] = ReportClass.init(reportName: "[98]上下5张打色色先发保位置最小", reportID: 64, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 8, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[65] = ReportClass.init(reportName: "[99]上下5张打色色先发保位置最大", reportID: 65, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 8, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[66] = ReportClass.init(reportName: "[100]上下5张打色留色保位置最大", reportID: 66, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 9, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[67] = ReportClass.init(reportName: "[101]上下5张打色留色保位置最大次大", reportID: 67, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 9, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[68] = ReportClass.init(reportName: "[102]上下5张打色留色保位置最小", reportID: 68, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 9, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[69] = ReportClass.init(reportName: "[103]上下5张打色留色保位置最小次小", reportID: 69, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 9, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[70] = ReportClass.init(reportName: "[105]上下5张打色去色1张保位置最大", reportID: 70, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 10, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[71] = ReportClass.init(reportName: "[106]上下5张打色去色1张保位置最大次大", reportID: 71, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 10, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[72] = ReportClass.init(reportName: "[107]上下5张打色去色1张保位置最小", reportID: 72, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 10, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[73] = ReportClass.init(reportName: "[108]上下5张打色去色1张保位置最小次小", reportID: 73, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 5, reportTarget: 1, singlefeaturesTransformation: 10, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[74] = ReportClass.init(reportName: "[110]下10张打色留色保位置最大次大", reportID: 74, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 2, reportTarget: 1, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 15, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[75] = ReportClass.init(reportName: "[111]下10张打色留色保位置最小次小", reportID: 75, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 2, reportTarget: 1, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 15, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[76] = ReportClass.init(reportName: "[112]下10张打色留色面牌移动到色牌下面保位置最大", reportID: 76, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 2, reportTarget: 1, singlefeaturesTransformation: 25, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 15, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[77] = ReportClass.init(reportName: "[120]下10张打色色牌先发保位置最大次大", reportID: 77, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 2, reportTarget: 1, singlefeaturesTransformation: 26, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 15, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[78] = ReportClass.init(reportName: "[121]下10张打色色牌先发保位置最小次小", reportID: 78, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 2, reportTarget: 1, singlefeaturesTransformation: 26, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 15, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[79] = ReportClass.init(reportName: "[130]看手牌报生死门", reportID: 79, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 18, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[80] = ReportClass.init(reportName: "[131]看手牌报最大", reportID: 80, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 18, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[81] = ReportClass.init(reportName: "[132]看手牌报最大次大", reportID: 81, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 18, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[82] = ReportClass.init(reportName: "[133]看手牌报最大次大生死门", reportID: 82, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 18, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[83] = ReportClass.init(reportName: "[134]看手牌比第一张点数从最大牌继续发报最大", reportID: 83, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 19, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[84] = ReportClass.init(reportName: "[135]看手牌比第一张点数从最大牌继续发报最大次大", reportID: 84, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 19, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[85] = ReportClass.init(reportName: "[143]看手牌面为色留色报最大", reportID: 85, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 19, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[86] = ReportClass.init(reportName: "[144]看手牌面为色留色报最大次大", reportID: 86, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 19, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[87] = ReportClass.init(reportName: "[145]看手牌面为色留色报最大次大生死门", reportID: 87, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 19, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[88] = ReportClass.init(reportName: "[147]看手牌面为色去色报最大", reportID: 88, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 20, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[89] = ReportClass.init(reportName: "[148]看手牌面为色去色报最大次大", reportID: 89, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 20, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[90] = ReportClass.init(reportName: "[149]看手牌面为色去色报最大次大生死门", reportID: 90, rankReport: 1, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 6, reportTarget: 0, singlefeaturesTransformation: 20, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 1, reportFormation: -1, cutSingleFeatureProcession: 0)
        allPreSetReportRules[91] = ReportClass.init(reportName: "[200]飞2张保位置最大", reportID: 91, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[92] = ReportClass.init(reportName: "[201]飞2张保位置最小", reportID: 92, rankReport: 3, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[93] = ReportClass.init(reportName: "[202]飞2张打色留色保位置最大", reportID: 93, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: 2)
        
        allPreSetReportRules[94] = ReportClass.init(reportName: "[202]飞2张打色留色保位置最小", reportID: 94, rankReport: 3, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: 2)
        
        allPreSetReportRules[95] =  ReportClass.init(reportName: "[206]飞2张打色去色1张保位置最大", reportID: 95, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: 4)
        
        allPreSetReportRules[96] =  ReportClass.init(reportName: "[207]飞2张打色去色1张保位置最小", reportID: 96, rankReport: 3, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: 4)
        
        allPreSetReportRules[97] =  ReportClass.init(reportName: "[208]:飞2张打色色先发保位置最大", reportID: 97, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: 5)
        
        allPreSetReportRules[98] =  ReportClass.init(reportName: "[209]:飞2张打色色先发保位置最小", reportID: 98, rankReport: 3, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: 5)
        
        allPreSetReportRules[100] =  ReportClass.init(reportName: "[212]:飞2张面为色留色保位置最大", reportID: 100, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[101] =  ReportClass.init(reportName: "[213]:飞张面为色留色保位置最小", reportID: 101, rankReport: 3, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 21, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[102] =  ReportClass.init(reportName: "[214]:飞2张面为色去色保位置最大", reportID: 102, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 29, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[103] =  ReportClass.init(reportName: "[215]:飞2张面为色去色保位置最小", reportID: 103, rankReport: 3, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 14, reportTarget: 1, singlefeaturesTransformation: 29, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 4, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        
        //TODO : 91-107
        allPreSetReportRules[108] = ReportClass.init(reportName: "[284]:固定范围切牌报对子和同点数目", reportID: 108, rankReport: 0, aliveDeathReport: -1, pairReport: 2, drawPointReport: 2, ninePointReport: -1,  reportCutRange: 0, reportTarget: 0, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[109] = ReportClass.init(reportName: "[285]:固定范围切牌报那个位置拿最大最多", reportID: 109, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 2, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[110] = ReportClass.init(reportName: "[286]:固定范围切牌报那个位置拿最大次大最多", reportID: 110, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 2, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[111] = ReportClass.init(reportName: "[289]:范围切牌保指定2家有最大", reportID: 111, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 13, reportTarget: 10, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 3, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //TODO 112-113
        allPreSetReportRules[114] = ReportClass.init(reportName: "[292]:范围切牌保位置活门", reportID: 114, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[115] = ReportClass.init(reportName: "[293]:范围切牌保位置死门", reportID: 115, rankReport: 0, aliveDeathReport: 4, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 1, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[116] = ReportClass.init(reportName: "[296]:范围切牌保位置最小次小", reportID: 116, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[117] = ReportClass.init(reportName: "[297]:范围切牌面为色去色保位置最大次大", reportID: 117, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 22, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 10, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[118] = ReportClass.init(reportName: "[298]:范围切牌面为色色先发保位置最大次大", reportID: 117, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 10, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[119] = ReportClass.init(reportName: "[299_1]:范围切牌保位置最大", reportID: 119, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[120] = ReportClass.init(reportName: "[299]:范围切牌保位置最大次大", reportID: 120, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[121] = ReportClass.init(reportName: "[300]:范围切牌打色留色保位置最大", reportID: 121, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[122] = ReportClass.init(reportName: "[301]:范围切牌打色留色保位置最大次大", reportID: 122, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[123] = ReportClass.init(reportName: "[304]:范围切牌打色去色全部保位置最大", reportID: 123, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[124] = ReportClass.init(reportName: "[305]:范围切牌打色去色全部保位置最大次大", reportID: 124, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[125] = ReportClass.init(reportName: "[310]:范围切牌打色去色1张保位置最大", reportID: 125, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[126] = ReportClass.init(reportName: "[311]:范围切牌打色去色1张保位置最大次大", reportID: 126, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[127] = ReportClass.init(reportName: "[316]:范围切牌打色色先发保位置最大", reportID: 127, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[128] = ReportClass.init(reportName: "[317]:范围切牌打色色先发保位置最大次大", reportID: 128, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[129] = ReportClass.init(reportName: "[330]:范围切牌打色留色保位置最小", reportID: 129, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[130] = ReportClass.init(reportName: "[331]:范围切牌打色留色保位置最小次小", reportID: 130, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[131] = ReportClass.init(reportName: "[334]:范围切牌打色去色保位置最小", reportID: 131, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[132] = ReportClass.init(reportName: "[335]:范围切牌打色去色保位置最小次小", reportID: 132, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[133] = ReportClass.init(reportName: "[338]:范围切牌打色去色1张保位置最小", reportID: 133, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[134] = ReportClass.init(reportName: "[339]:范围切牌打色去色1张保位置最小次小", reportID: 134, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 5, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[135] = ReportClass.init(reportName: "[342]:范围切牌打色色先发保位置最小", reportID: 135, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[136] = ReportClass.init(reportName: "[343]:范围切牌打色色先发保位置最小次小", reportID: 136, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 9, singlefeaturesTransformation: 6, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 0, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //todo 137-147
        allPreSetReportRules[148] = ReportClass.init(reportName: "[450]:指定底牌报最大次大", reportID: 148, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[149] = ReportClass.init(reportName: "[451]:指定底牌报最大", reportID: 148, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[150] = ReportClass.init(reportName: "[452]:指定底牌报最小次小", reportID: 150, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[151] = ReportClass.init(reportName: "[453]:指定底牌报最小", reportID: 151, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[152] = ReportClass.init(reportName: "[454]:指定底牌报生死门", reportID: 152, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 11, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[153] = ReportClass.init(reportName: "[500]:指定顶牌报最大次大", reportID: 153, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[154] = ReportClass.init(reportName: "[501]:指定顶牌报最大", reportID: 154, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[155] = ReportClass.init(reportName: "[502]:指定顶牌报最小次小", reportID: 155, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[156] = ReportClass.init(reportName: "[503]:指定顶牌报最小", reportID: 156, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[157] = ReportClass.init(reportName: "[504]:指定顶牌报生死门", reportID: 157, rankReport: 0, aliveDeathReport: 0, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[158] = ReportClass.init(reportName: "[510]:指定顶牌底牌为色报最大次大", reportID: 158, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 16, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[159] = ReportClass.init(reportName: "[511]:指定顶牌底牌为色报最大", reportID: 159, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 16, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[160] = ReportClass.init(reportName: "[512]:指定顶牌底牌为色报最小次小", reportID: 160, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 16, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[161] = ReportClass.init(reportName: "[513]:指定顶牌底牌为色报最小", reportID: 161, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 12, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 16, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[162] = ReportClass.init(reportName: "[514]:指定牌上一张打色留色报最大次大", reportID: 162, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 6, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[163] = ReportClass.init(reportName: "[515]:指定牌上一张打色去色报最大次大", reportID: 163, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 27, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 6, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[164] = ReportClass.init(reportName: "[516]:指定牌下一张打色留色报最大次大", reportID: 164, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 7, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[165] = ReportClass.init(reportName: "[517]:指定牌下一张打色去色报最大次大", reportID: 165, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 28, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 7, hasSpecialSingleFeature: 0, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //TODO 166-167
        allPreSetReportRules[168] = ReportClass.init(reportName: "[520]:底为色报位置最大次大", reportID: 168, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[169] = ReportClass.init(reportName: "[521]:底为色报位置最大", reportID: 169, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[170] = ReportClass.init(reportName: "[522]:底为色报位置最小次小", reportID: 170, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[171] = ReportClass.init(reportName: "[523]:底为色报位置最小", reportID: 171, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[172] = ReportClass.init(reportName: "[524]:底为色报位置排名", reportID: 172, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //todo 173
        allPreSetReportRules[174] = ReportClass.init(reportName: "[526]:底2张相加为色报位置最大次大", reportID: 174, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 3, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //todo 175-176
        allPreSetReportRules[177] = ReportClass.init(reportName: "[530]:面为色报位置最大次大", reportID: 177, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[178] = ReportClass.init(reportName: "[531]:面为色报位置最大", reportID: 178, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[179] = ReportClass.init(reportName: "[532]:面为色报位置最小次小", reportID: 179, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[180] = ReportClass.init(reportName: "[533]:面为色报位置最小", reportID: 180, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[181] = ReportClass.init(reportName: "[534]:面为色报位置排名", reportID: 181, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[182] = ReportClass.init(reportName: "[540]:面为色去色报位置最大次大", reportID: 182, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[183] = ReportClass.init(reportName: "[541]:面为色去色报位置最大", reportID: 183, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[184] = ReportClass.init(reportName: "[542]:面为色去色报位置最小次小", reportID: 182, rankReport: 2, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[185] = ReportClass.init(reportName: "[543]:面为色去色报位置最小", reportID: 185, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[186] = ReportClass.init(reportName: "[544]:面为色去色报排名", reportID: 186, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 9, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //todo 187-192
        allPreSetReportRules[193] = ReportClass.init(reportName: "[700]:去掉14张面牌报哪家最大", reportID: 193, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[194] = ReportClass.init(reportName: "[701]:去掉14张面牌报哪家最小", reportID: 194, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[195] = ReportClass.init(reportName: "[702]:去掉14张面牌报哪家最大次大", reportID: 195, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[196] = ReportClass.init(reportName: "[703]:去掉14张面牌报哪家最大2大3大", reportID: 196, rankReport: 2, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[197] = ReportClass.init(reportName: "[704]:去掉14张面牌报哪家最小次小", reportID: 197, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[198] = ReportClass.init(reportName: "[705]:去掉14张面牌再根据第14张牌点书再去牌报哪家最大", reportID: 198, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 14, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[199] = ReportClass.init(reportName: "[706]:去掉14张面牌再根据第14张牌点书再去牌报哪家最小", reportID: 199, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 14, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[200] = ReportClass.init(reportName: "[707]:去掉面牌底牌再根据面牌底牌点数和再去牌报最大次大", reportID: 200, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 15, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[201] = ReportClass.init(reportName: "[708]:固定去掉6、7、8、9张牌，以去牌数为色报位置最大", reportID: 200, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 8, reportTarget: 0, singlefeaturesTransformation: 3, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 11, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //TODO 202
        allPreSetReportRules[203] = ReportClass.init(reportName: "[719]:比第一张牌从最大牌继续发报最大次大", reportID: 203, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 16, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[204] = ReportClass.init(reportName: "[720]:比第一张牌从最大牌继续发报最大", reportID: 204, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 16, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[205] = ReportClass.init(reportName: "[721]:比第一张牌从最小牌继续发报最大", reportID: 205, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 17, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[206] = ReportClass.init(reportName: "[722]:比第一张牌从最小牌继续发报最大次大", reportID: 206, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: -1, singlefeaturesTransformation: 17, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //todo 207-208
        allPreSetReportRules[209] = ReportClass.init(reportName: "[725]:比第一张牌从最大牌继续发报各家点数", reportID: 209, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 15, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: -1, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        //todo 210-212
        allPreSetReportRules[213] = ReportClass.init(reportName: "[755]:看色留色上10 张去牌保位置最大", reportID: 212, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 12, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 2)
        
        allPreSetReportRules[251] = ReportClass.init(reportName: "[756]:看色留色上10张去牌保位置最大次大", reportID: 212, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 12, reportTarget: 1, singlefeaturesTransformation: 23, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 2)
        allPreSetReportRules[214] = ReportClass.init(reportName: "[758]:看色留色+色牌上X张为色报最大次大", reportID: 214, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 11, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 2)
        
        allPreSetReportRules[215] = ReportClass.init(reportName: "[759]:看色留色2次打色保位置最大", reportID: 216, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 18, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 1)
        
        allPreSetReportRules[216] = ReportClass.init(reportName: "[760]:看色留色报最大", reportID: 216, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 2)
        
        allPreSetReportRules[217] = ReportClass.init(reportName: "[761]:看色留色报最大次大", reportID: 217, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 2)
        allPreSetReportRules[218] = ReportClass.init(reportName: "[762]:看色留色报最小", reportID: 218, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 2)
        allPreSetReportRules[219] = ReportClass.init(reportName: "[763]:看色留色报最小次小", reportID: 219, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 2)
        
        allPreSetReportRules[220] = ReportClass.init(reportName: "[764]:看色留色报排名", reportID: 220, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 2)
        
        allPreSetReportRules[221] = ReportClass.init(reportName: "[766]:看色去色全部报最大", reportID: 221, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 3)
        allPreSetReportRules[222] = ReportClass.init(reportName: "[767]:看色去色全部报最大次大", reportID: 222, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 3)
        allPreSetReportRules[223] = ReportClass.init(reportName: "[768]:看色去色全部报最小", reportID: 223, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 3)
        allPreSetReportRules[224] = ReportClass.init(reportName: "[769]:看色去色全部报最小次小", reportID: 224, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 3)
        allPreSetReportRules[225] = ReportClass.init(reportName: "[770]:看色去色全部报排名", reportID: 225, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: -1, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 17, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: 3)
        
        allPreSetReportRules[226] = ReportClass.init(reportName: "[790]:固定第10张牌作色留色报最大", reportID: 226, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[227] = ReportClass.init(reportName: "[791]:固定第10张牌作色留色报最大次大", reportID: 227, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[252] = ReportClass.init(reportName: "[792]:固定第10张牌作色留色报最小", reportID: 252, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[228] = ReportClass.init(reportName: "[793]:固定第10张牌作色留色报最小次小", reportID: 228, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[229] = ReportClass.init(reportName: "[794]:固定第10张牌作色留色报排名", reportID: 229, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        
        allPreSetReportRules[230] = ReportClass.init(reportName: "[795]:固定第10张牌作色留色4种发牌方式报最大", reportID: 230, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 14, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 0, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[231] = ReportClass.init(reportName: "[796]:固定第10张牌作色留色4种发牌方式报最小", reportID: 231, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: -1, reportTarget: 0, singlefeaturesTransformation: 2, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 14, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 0, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[232] = ReportClass.init(reportName: "[800]:固定第10张牌作色去色全部报最大", reportID: 232, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 9, reportTarget: 0, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[233] = ReportClass.init(reportName: "[801]:固定第10张牌作色去色全部报最大次大", reportID: 233, rankReport: 1, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 9, reportTarget: 0, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[234] = ReportClass.init(reportName: "[802]:固定第10张牌作色去色全部报最小", reportID: 234, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 9, reportTarget: 0, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[235] = ReportClass.init(reportName: "[803]:固定第10张牌作色去色全部报最小次小", reportID: 235, rankReport: 4, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 9, reportTarget: 0, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[236] = ReportClass.init(reportName: "[804]:固定第10张牌作色去色全部报排名", reportID: 236, rankReport: 5, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 9, reportTarget: 0, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: -1, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[237] = ReportClass.init(reportName: "[805]:固定第10张牌作色去色全部四种发牌方式报最大", reportID: 237, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 9, reportTarget: 0, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 0, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[238] = ReportClass.init(reportName: "[806]:固定第10张牌作色去色全部四种发牌方式报最小", reportID: 238, rankReport: 3, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 9, reportTarget: 0, singlefeaturesTransformation: 4, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 0, reportFormation: -1, cutSingleFeatureProcession: -1)
        allPreSetReportRules[239] = ReportClass.init(reportName: "[810]:固定去面上Y张牌,从X-Y张选择色牌，保1大2大", reportID: 239, rankReport: 0, aliveDeathReport: -1, pairReport: -1, drawPointReport: -1, ninePointReport: -1,  reportCutRange: 0, reportTarget: 0, singlefeaturesTransformation: 13, consecutiveReport: -1, positionToReport: 0, colorSingleFeaturePos: 8, hasSpecialSingleFeature: -1, specifiedRCHand: -1, differentDeal: 0, reportFormation: -1, cutSingleFeatureProcession: -1)
        //TODO240-250
        
    }
    //存储所有预设好的报法
    
    //存储所有预设好的规则
    static func LoadAllPresetRules(){
        for i in 0...generalRuleSetting.allDatasetType.count - 1{
            allPreSetRules[i] = [:]
            var args: [Int] = []
            var suitRules: [Int] = []
            var rankRules: [Int] = []
            var rankRuleChecked: [Int] = []
            switch i{
            //德州预设规则
            case 0:
                //德州扑克[701]
//                handNum = 2
//                communityNum = 5
//                isCompareSuit = 0
//                isAceStraight = 1
//                minRank = 0
//                handUseType = 0
//                handUseNum = 0
                let rule = ClassifierSettingArgs.targetSetting[i] as! TPRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                args = [2,5,0,1,0,0,0]
                suitRules = [3,2,1,0]
                rankRules = [11,10,9,8,7,6,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                handNum = 1
//                communityNum = 2
//                短牌
//                isCompareSuit = 0
//                isAceStraight = 1
//                minRank = 4
//                handUseType = 0
//                handUseNum = 0
//                suitRules = [3,2,1,0]
                args = [2,5,0,1,4,0,0]
                rankRules = [11,10,8,9,7,6,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                
                //德州扑克清比葫芦大[702]
//                handNum = 2
//                communityNum = 5
//                isCompareSuit = 0
//                isAceStraight = 1
//                minRank = 0
//                handUseType = 0
//                handUseNum = 0
                args = [2,5,0,1,0,0,0]
                suitRules = [3,2,1,0]
                rankRules = [11,10,8,9,7,6,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                德州扑克[550]
//                handNum = 5
//                communityNum = 0
//                isCompareSuit = 0
//                isAceStraight = 1
//                minRank = 0
//                handUseType = 0
//                handUseNum = 0

                args = [5,0,0,1,0,0,0]
                suitRules = [3,2,1,0]
                rankRules = [11,10,9,8,7,6,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
                
//                德州扑克10选5[1020]
//                handNum = 5
//                communityNum = 5
//                isCompareSuit = 0
//                isAceStraight = 1
//                minRank = 0
//                handUseType = 0
//                handUseNum = 0

                args = [5,5,0,1,0,0,0]
                suitRules = [3,2,1,0]
                rankRules = [11,10,9,8,7,6,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
                
                break
            //牛牛预设规则
            case 1:
                //斗牛-分花色
                let rule = ClassifierSettingArgs.targetSetting[i] as! PBRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                
                var handNum: Int = 5
                var singlefeaturesNum: Int = 0
                var isCompareSuit: Int = 1
                var wayToDeal:Int = 0
                var fiveLittleRank:Int = 0
                var secondRankRule:Int = 0
                var specialfeatureIsMinZero:Int = 0
                var tenValueRange:Int = 0
                var JValueRange:Int = 0
                var QValueRange:Int = 0
                var KValueRange:Int = 0
                var blackspecialfeatureValueRange:Int = 0
                var redspecialfeatureValueRange:Int = 0
                var threeValueRange:Int = 0
                var sixValueRange:Int = 0
                var spadeAValueRange:Int = 0
                var bullrulelist:[Int] = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [9, 10, 42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //斗牛-不分花色
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 3
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [9, 10, 42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)


//              斗牛-不分花色2
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [9, 10, 42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
                //斗牛-36张炸弹最大
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 3
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1, 0, 2, 7, 8, 9, 43, 42]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
                //斗牛-顺算牛
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,1,0,1,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [9,10,42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                斗牛-4带1
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 3
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1, 32, 9, 10, 42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
                //斗牛-对子
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [24,9, 10, 42]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
                //斗牛-40张炸弹最大
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1, 7, 8, 9, 10, 42]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
                //斗牛-54张炸弹最大
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1, 7, 9, 10, 42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
                //斗牛3条算牛
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,1,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [45, 44, 42]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10: "斗牛10张比两次分花色[504]",
                singlefeaturesNum = 0
                handNum = 10
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,0,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1,7,9,10,42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
//                11: "斗牛4条3条[509]",
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,1,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1,46, 9, 10, 42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
//                12: "斗牛5大5小[510]",
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 1
                wayToDeal = 0
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,1,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [0,2, 1, 7, 45,44,42]
                rankRuleChecked = [1,1,1,1,1,1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                13: "斗牛-40张同点一样大[511]",
                singlefeaturesNum = 0
                handNum = 5
                isCompareSuit = 0
                wayToDeal = 0
                fiveLittleRank = 1
                secondRankRule = 4
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 3
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,1,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
                suitRules = [3,2,1,0]
                rankRules = [1,2,45,44,42]
                rankRuleChecked = [1,1,1,1,1]
                allPreSetRules[i]![13]!.append(args)
                allPreSetRules[i]![13]!.append(suitRules)
                allPreSetRules[i]![13]!.append(rankRules)
                allPreSetRules[i]![13]!.append(rankRuleChecked)
//                14: "斗牛-40张第二轮有公牌[512]",
                singlefeaturesNum = 3
                handNum = 5
                isCompareSuit = 1
                wayToDeal = 1
                fiveLittleRank = 0
                secondRankRule = 0
                specialfeatureIsMinZero = 0
                tenValueRange = 0
                JValueRange = 0
                QValueRange = 0
                KValueRange = 0
                blackspecialfeatureValueRange = 0
                redspecialfeatureValueRange = 0
                threeValueRange = 0
                sixValueRange = 0
                spadeAValueRange = 0
                bullrulelist = [1,1,0,0,0,0,0,0,0]
                args = [handNum,singlefeaturesNum,isCompareSuit,wayToDeal,fiveLittleRank,secondRankRule,specialfeatureIsMinZero,tenValueRange,JValueRange,QValueRange,KValueRange,blackspecialfeatureValueRange,redspecialfeatureValueRange,threeValueRange,sixValueRange,spadeAValueRange] + bullrulelist
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! ZJHDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 3
                var communityNum = 0
                var isCompareSuit = 1
                var minRank = 0
                var isAce = 2
                var isAceStraight = 1
                var isHeadSingleFeature = 1
                var isRedspecialfeature = 0
                var redspecialfeatureSuit = 0
                var redspecialfeatureRank = 0
                var isBlackspecialfeature = 0
                var blackspecialfeatureSuit = 0
                var blackspecialfeatureRank = 0
                var isReverseHighSingleFeature = 0
                
                args = [handNum,communityNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadSingleFeature, isRedspecialfeature, redspecialfeatureSuit, redspecialfeatureRank, isBlackspecialfeature, blackspecialfeatureSuit, blackspecialfeatureRank, isReverseHighSingleFeature]
                suitRules = [3,2,1,0]
                rankRules = [13,12,11,10,9,8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [0,1,0,0,0,0,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //金花顺大
                handNum = 3
                communityNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadSingleFeature = 1
                isRedspecialfeature = 0
                redspecialfeatureSuit = 0
                redspecialfeatureRank = 0
                isBlackspecialfeature = 0
                blackspecialfeatureSuit = 0
                blackspecialfeatureRank = 0
                isReverseHighSingleFeature = 0
                
                args = [handNum,communityNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadSingleFeature, isRedspecialfeature, redspecialfeatureSuit, redspecialfeatureRank, isBlackspecialfeature, blackspecialfeatureSuit, blackspecialfeatureRank, isReverseHighSingleFeature]
                suitRules = [3,2,1,0]
                rankRules = [13,12,11,10,9,8,7,6,5,3,4,2,1,0]
                rankRuleChecked = [0,1,0,0,0,0,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                //金花AKJ
                handNum = 3
                communityNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadSingleFeature = 1
                isRedspecialfeature = 0
                redspecialfeatureSuit = 0
                redspecialfeatureRank = 0
                isBlackspecialfeature = 0
                blackspecialfeatureSuit = 0
                blackspecialfeatureRank = 0
                isReverseHighSingleFeature = 0
                
                args = [handNum,communityNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadSingleFeature, isRedspecialfeature, redspecialfeatureSuit, redspecialfeatureRank, isBlackspecialfeature, blackspecialfeatureSuit, blackspecialfeatureRank, isReverseHighSingleFeature]
                suitRules = [3,2,1,0]
                rankRules = [13,12,9,11,8,10,7,6,5,3,4,2,1,0]
                rankRuleChecked = [0,1,1,1,1,1,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
                //百变金花
                handNum = 3
                communityNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadSingleFeature = 1
                isRedspecialfeature = 1
                redspecialfeatureSuit = 0
                redspecialfeatureRank = 14
                isBlackspecialfeature = 1
                blackspecialfeatureSuit = 0
                blackspecialfeatureRank = 14
                isReverseHighSingleFeature = 0
                
                args = [handNum,communityNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadSingleFeature, isRedspecialfeature, redspecialfeatureSuit, redspecialfeatureRank, isBlackspecialfeature, blackspecialfeatureSuit, blackspecialfeatureRank, isReverseHighSingleFeature]
                suitRules = [3,2,1,0]
                rankRules = [13,12,11,10,9,8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [0,1,0,0,0,0,0,1,0,1,1,0,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "金花4选3[420]",
                handNum = 4
                communityNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadSingleFeature = 1
                isRedspecialfeature = 0
                redspecialfeatureSuit = 0
                redspecialfeatureRank = 0
                isBlackspecialfeature = 0
                blackspecialfeatureSuit = 0
                blackspecialfeatureRank = 0
                isReverseHighSingleFeature = 0
                
                args = [handNum,communityNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadSingleFeature, isRedspecialfeature, redspecialfeatureSuit, redspecialfeatureRank, isBlackspecialfeature, blackspecialfeatureSuit, blackspecialfeatureRank, isReverseHighSingleFeature]
                suitRules = [3,2,1,0]
                rankRules = [12, 6, 4, 3, 1, 0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "金花A23[306]",
                handNum = 3
                communityNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 3
                isHeadSingleFeature = 1
                isRedspecialfeature = 0
                redspecialfeatureSuit = 0
                redspecialfeatureRank = 0
                isBlackspecialfeature = 0
                blackspecialfeatureSuit = 0
                blackspecialfeatureRank = 0
                isReverseHighSingleFeature = 0
                
                args = [handNum,communityNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadSingleFeature, isRedspecialfeature, redspecialfeatureSuit, redspecialfeatureRank, isBlackspecialfeature, blackspecialfeatureSuit, blackspecialfeatureRank, isReverseHighSingleFeature]
                suitRules = [3,2,1,0]
                rankRules = [12, 6, 4, 3, 1, 0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "金花5选3[560]",
                handNum = 5
                communityNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadSingleFeature = 1
                isRedspecialfeature = 0
                redspecialfeatureSuit = 0
                redspecialfeatureRank = 0
                isBlackspecialfeature = 0
                blackspecialfeatureSuit = 0
                blackspecialfeatureRank = 0
                isReverseHighSingleFeature = 0
                
                args = [handNum,communityNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadSingleFeature, isRedspecialfeature, redspecialfeatureSuit, redspecialfeatureRank, isBlackspecialfeature, blackspecialfeatureSuit, blackspecialfeatureRank, isReverseHighSingleFeature]
                suitRules = [3,2,1,0]
                rankRules = [12, 6, 4, 3, 1, 0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "金花6选3[610]",
                handNum = 6
                communityNum = 0
                isCompareSuit = 1
                minRank = 0
                isAce = 2
                isAceStraight = 1
                isHeadSingleFeature = 1
                isRedspecialfeature = 0
                redspecialfeatureSuit = 0
                redspecialfeatureRank = 0
                isBlackspecialfeature = 0
                blackspecialfeatureSuit = 0
                blackspecialfeatureRank = 0
                isReverseHighSingleFeature = 0
                
                args = [handNum,communityNum, isCompareSuit, minRank, isAce, isAceStraight, isHeadSingleFeature, isRedspecialfeature, redspecialfeatureSuit, redspecialfeatureRank, isBlackspecialfeature, blackspecialfeatureSuit, blackspecialfeatureRank, isReverseHighSingleFeature]
                suitRules = [3,2,1,0]
                rankRules = [12, 6, 4, 3, 1, 0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
                break
            //小九
            case 3:
                //标准
                let rule = ClassifierSettingArgs.targetSetting[i] as! TNDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 2
                var communityNum = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var samePointComparision = 1
                var isCompareSuit = 0
                args = [handNum,communityNum, redspecialfeatureValueRange, blackspecialfeatureValueRange, samePointComparision, isCompareSuit]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [0,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //湖南小九
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                args = [handNum,communityNum, redspecialfeatureValueRange, blackspecialfeatureValueRange, samePointComparision, isCompareSuit]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! TMDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 3
                var communityNum = 0
                var pointComparision = 0
                var samePointComparision = 0
                var isAAsMan = 0
                var isCompareSuit = 0
                var threeSingleFeatureComparision = 0
                var mixManComparision = 0
                args = [handNum, communityNum, pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //三公3-0点大
                handNum = 3
                communityNum = 0
                pointComparision = 0
                samePointComparision = 0
                isAAsMan = 0
                isCompareSuit = 0
                threeSingleFeatureComparision = 0
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision, mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//              三公2-3同大
                handNum = 3
                communityNum = 0
                pointComparision = 1
                samePointComparision = 0
                isAAsMan = 0
                isCompareSuit = 0
                threeSingleFeatureComparision = 0
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [3,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3:"三公4-3同大无混公",
                handNum = 3
                communityNum = 0
                pointComparision = 1
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 0
                threeSingleFeatureComparision = 0
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [3,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4:"三公5-A大于K",
                handNum = 3
                communityNum = 0
                pointComparision = 1
                samePointComparision = 2
                isAAsMan = 1
                isCompareSuit = 0
                threeSingleFeatureComparision = 0
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5:"三公8-单张比花色",
                handNum = 3
                communityNum = 0
                pointComparision = 0
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 1
                threeSingleFeatureComparision = 0
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [2,1,0,3]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6:"三公9-3公一样大",
                handNum = 3
                communityNum = 0
                pointComparision = 2
                samePointComparision = 3
                isAAsMan = 0
                isCompareSuit = 0
                threeSingleFeatureComparision = 0
                mixManComparision = 1
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [5,6,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7:"三公10-333最大",
                handNum = 3
                communityNum = 0
                pointComparision = 1
                samePointComparision = 0
                isAAsMan = 0
                isCompareSuit = 0
                threeSingleFeatureComparision = 2
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [3,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8:"三公12-AAA最大",
                handNum = 3
                communityNum = 0
                pointComparision = 0
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 1
                threeSingleFeatureComparision = 1
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [0,2,1,3]
                rankRules = [3,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9:"三公13-10算公",
                handNum = 3
                communityNum = 0
                pointComparision = 1
                samePointComparision = 4
                isAAsMan = 0
                isCompareSuit = 0
                threeSingleFeatureComparision = 0
                mixManComparision = 1
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [7,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10:"三公7-单张比花色",
                handNum = 3
                communityNum = 0
                pointComparision = 0
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 1
                threeSingleFeatureComparision = 0
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
//                11:"三公11-单张比花色",
                handNum = 3
                communityNum = 0
                pointComparision = 0
                samePointComparision = 1
                isAAsMan = 0
                isCompareSuit = 1
                threeSingleFeatureComparision = 0
                mixManComparision = 0
                args = [handNum, communityNum,pointComparision, samePointComparision, isAAsMan, isCompareSuit, threeSingleFeatureComparision,mixManComparision]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! TEGDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 2
                var communityNum = 0
                var samePointComparision = 0
                var isCompareSuit = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var pointComparision = 0
                args = [handNum, communityNum, samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "二八杠28比对子大",
                handNum = 2
                communityNum = 0
                samePointComparision = 0
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [handNum, communityNum,samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "二八分黑红",
                handNum = 2
                communityNum = 0
                samePointComparision = 1
                isCompareSuit = 1
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [handNum, communityNum,samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "二八最大对k次大",
                handNum = 2
                communityNum = 0
                samePointComparision = 0
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [handNum, communityNum,samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "二八杠10点大",
                handNum = 2
                communityNum = 0
                samePointComparision = 0
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 1
                args = [handNum, communityNum,samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "江苏52张二八"
                handNum = 2
                communityNum = 0
                samePointComparision = 0
                isCompareSuit = 0
                KValueRange = 1
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [handNum, communityNum,samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "28杠28比对子大[244]",
                handNum = 2
                communityNum = 0
                samePointComparision = 3
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 1
                args = [handNum, communityNum,samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "28杠28比对子大[245]",
                handNum = 2
                communityNum = 0
                samePointComparision = 3
                isCompareSuit = 0
                KValueRange = 0
                QValueRange = 1
                JValueRange = 1
                pointComparision = 0
                args = [handNum, communityNum,samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8: "28杠比花色[246]",
                handNum = 2
                communityNum = 0
                samePointComparision = 2
                isCompareSuit = 1
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                args = [handNum, communityNum,samePointComparision, isCompareSuit, KValueRange,QValueRange, JValueRange, pointComparision]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! NPFiveDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 2
                var communityNum = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var samePointComparision = 0
                var isPairSameRank = 1
                var pairRequirement = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "54张9点半1",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "江西九点半",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "安徽九点半",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 1
                blackspecialfeatureValueRange = 1
                KValueRange = 0
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,3,1,6,7,5,4,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "江西54张九点半",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "九点半最大",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 0
                pairRequirement = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "江西九点半1",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "临沂九点半，对王最大",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 0
                pairRequirement = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [3,1,2,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8: "江西九点半2",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9: "九点半最大2",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 0
                pairRequirement = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10:"安徽九点半[226]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 1
                blackspecialfeatureValueRange = 1
                KValueRange = 0
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
//                11:"安徽九点半[235]",
                redspecialfeatureValueRange = 1
                blackspecialfeatureValueRange = 1
                KValueRange = 0
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isPairSameRank = 1
                pairRequirement = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
//                12:"江西九点半[237]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 1
                isPairSameRank = 0
                pairRequirement = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                13:"54张九点半[238]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isPairSameRank = 0
                pairRequirement = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange,QValueRange, JValueRange, samePointComparision, isPairSameRank, pairRequirement]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! BZDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//              0: "宝子2张9点大",
                var handNum = 2
                var communityNum = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var specialfeatureValueRange = 0
                var samePointComparision = 0
                var pointComparision = 0
                var singlefeatureRank = 0
                var pairRank = 0
                var AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "宝子2张10点大",
                handNum = 2
                communityNum = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                specialfeatureValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "宝子P对大",
                handNum = 2
                communityNum = 0
                KValueRange = 0
                QValueRange = 3
                JValueRange = 0
                specialfeatureValueRange = 0
                samePointComparision = 0
                pointComparision = 0
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "52张宝子",
                handNum = 2
                communityNum = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                specialfeatureValueRange = 0
                samePointComparision = 1
                pointComparision = 0
                singlefeatureRank = 2
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "52张上海宝子",
                handNum = 2
                communityNum = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                specialfeatureValueRange = 0
                samePointComparision = 0
                pointComparision = 0
                singlefeatureRank = 1
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "54张宝子12",
                handNum = 2
                communityNum = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                specialfeatureValueRange = 1
                samePointComparision = 0
                pointComparision = 1
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [4,3,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "唐山54张宝子",
                handNum = 2
                communityNum = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                specialfeatureValueRange = 1
                samePointComparision = 2
                pointComparision = 0
                singlefeatureRank = 1
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [2,5,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "40张宝子分花色",
                handNum = 2
                communityNum = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                specialfeatureValueRange = 0
                samePointComparision = 3
                pointComparision = 0
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8: "54张宝子13",
                handNum = 2
                communityNum = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                specialfeatureValueRange = 1
                samePointComparision = 2
                pointComparision = 0
                singlefeatureRank = 1
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [2,1,5,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9: "54张比宝子14",
                handNum = 2
                communityNum = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                specialfeatureValueRange = 1
                samePointComparision = 0
                pointComparision = 0
                singlefeatureRank = 0
                pairRank = 1
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10: "52张新疆宝子",
                handNum = 2
                communityNum = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                specialfeatureValueRange = 0
                samePointComparision = 0
                pointComparision = 0
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
                
//                11: "宝子J",
                handNum = 2
                communityNum = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                specialfeatureValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
//                12: "宝子Q",
                handNum = 2
                communityNum = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                specialfeatureValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                13: "宝子K",
                handNum = 2
                communityNum = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                specialfeatureValueRange = 0
                samePointComparision = 0
                pointComparision = 1
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![13]!.append(args)
                allPreSetRules[i]![13]!.append(suitRules)
                allPreSetRules[i]![13]!.append(rankRules)
                allPreSetRules[i]![13]!.append(rankRuleChecked)
//                14: "江苏52张二八",
                handNum = 2
                communityNum = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                specialfeatureValueRange = 0
                samePointComparision = 1
                pointComparision = 0
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [3,2,1,0]
                rankRules = [5,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![14]!.append(args)
                allPreSetRules[i]![14]!.append(suitRules)
                allPreSetRules[i]![14]!.append(rankRules)
                allPreSetRules[i]![14]!.append(rankRuleChecked)
                //15: 52张宝子对子算点数不分花色
                handNum = 2
                communityNum = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                specialfeatureValueRange = 0
                samePointComparision = 0
                pointComparision = 0
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [0,0,0,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![15]!.append(args)
                allPreSetRules[i]![15]!.append(suitRules)
                allPreSetRules[i]![15]!.append(rankRules)
                allPreSetRules[i]![15]!.append(rankRuleChecked)
                // 16: "54张宝子15[213]",
                handNum = 2
                communityNum = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                specialfeatureValueRange = 2
                samePointComparision = 2
                pointComparision = 0
                singlefeatureRank = 1
                pairRank = 0
                AvalueRange = 1
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
                suitRules = [0,0,0,0]
                rankRules = [2,5,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![16]!.append(args)
                allPreSetRules[i]![16]!.append(suitRules)
                allPreSetRules[i]![16]!.append(rankRules)
                allPreSetRules[i]![16]!.append(rankRuleChecked)
                // 17: "宝子2张9点大[212]",
                handNum = 2
                communityNum = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                specialfeatureValueRange = 3
                samePointComparision = 1
                pointComparision = 0
                singlefeatureRank = 0
                pairRank = 0
                AvalueRange = 0
                args = [handNum, communityNum,KValueRange,QValueRange,JValueRange,specialfeatureValueRange, samePointComparision, pointComparision, singlefeatureRank, pairRank, AvalueRange]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! JJBDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 2
                var communityNum = 0
                var samePointComparision = 0
                var SingleFeatureRankList = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var isCompareSuit = 1
                
                args = [handNum, communityNum,samePointComparision,SingleFeatureRankList,redspecialfeatureValueRange,blackspecialfeatureValueRange,KValueRange,QValueRange,JValueRange, isCompareSuit]
                suitRules = [0,1,0,1]
                rankRules = [4,2,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                //通用54张佳佳宝，比四张
                handNum = 2
                communityNum = 0
                samePointComparision = 0
                SingleFeatureRankList = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                isCompareSuit = 1
                args = [handNum, communityNum,samePointComparision,SingleFeatureRankList,redspecialfeatureValueRange,blackspecialfeatureValueRange,KValueRange,QValueRange,JValueRange, isCompareSuit]
                suitRules = [0,1,0,1]
                rankRules = [4,2,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                
//                2: "通用四张，9点对子算点数",
                handNum = 2
                communityNum = 0
                samePointComparision = 1
                SingleFeatureRankList = 1
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                isCompareSuit = 0
                args = [handNum, communityNum,samePointComparision,SingleFeatureRankList,redspecialfeatureValueRange,blackspecialfeatureValueRange,KValueRange,QValueRange,JValueRange, isCompareSuit]
                suitRules = [0,1,0,1]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "通用四张，54张佳佳宝1",
                handNum = 2
                communityNum = 0
                samePointComparision = 1
                SingleFeatureRankList = 1
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                isCompareSuit = 1
                args = [handNum, communityNum,samePointComparision,SingleFeatureRankList,redspecialfeatureValueRange,blackspecialfeatureValueRange,KValueRange,QValueRange,JValueRange, isCompareSuit]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! CNDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 2
                var communityNum = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var pointComparision = 0
                var samePointComparision = 0
                var AValueRange = 0
                var pairRank = 0
                var singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [7,5,6,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "温州牌九[260]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 1
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "通用四张-牌九大牌九1[...",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [12,8,9,13,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "52张小牌九[262]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 1
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [14,15,4,11,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "宁波小牌九[263]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "杭州牌九[264]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6: "32张牌9[456]",
                handNum = 4
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "湖南牌九[265]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8: "通用四张-32张牌九[416]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 1
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 3
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [16,8,3,15,17,18,19,20,21,22,23,24,25,26,27,28,13,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9: "山西牌九[268]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 1
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [10, 8, 9, 17, 18,29,30, 31,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10: "通用四张-54张大牌九[..",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 1
                blackspecialfeatureValueRange = 2
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                pointComparision = 1
                samePointComparision = 0
                AValueRange = 0
                pairRank = 1
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [16, 41, 40, 0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)
//                11: "34张小牌九[457]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 1
                pairRank = 0
                singlefeatureRankRule = 4
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [8,9,12,17,32,33,34,29,30,35,3,36,2,1,37,38,39,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![11]!.append(args)
                allPreSetRules[i]![11]!.append(suitRules)
                allPreSetRules[i]![11]!.append(rankRules)
                allPreSetRules[i]![11]!.append(rankRuleChecked)
//                12: "通用四张-32张牌九二[...",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 1
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 5
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [16, 9, 3, 17, 18,19,20,21,42,23,24,25,26,27,28, 13, 2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![12]!.append(args)
                allPreSetRules[i]![12]!.append(suitRules)
                allPreSetRules[i]![12]!.append(rankRules)
                allPreSetRules[i]![12]!.append(rankRuleChecked)
//                13: "温州牌九黑大3[269]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 1
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 3
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![13]!.append(args)
                allPreSetRules[i]![13]!.append(suitRules)
                allPreSetRules[i]![13]!.append(rankRules)
                allPreSetRules[i]![13]!.append(rankRuleChecked)
//                14: "南京牌九[261]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [8,9,10,11,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1]
                allPreSetRules[i]![14]!.append(args)
                allPreSetRules[i]![14]!.append(suitRules)
                allPreSetRules[i]![14]!.append(rankRules)
                allPreSetRules[i]![14]!.append(rankRuleChecked)
//                15: "32张牌九[266]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [16,8,3,15,17,18,19,20,21,22,23,24,25,26,27,28,13,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![15]!.append(args)
                allPreSetRules[i]![15]!.append(suitRules)
                allPreSetRules[i]![15]!.append(rankRules)
                allPreSetRules[i]![15]!.append(rankRuleChecked)
//                16: "山西牌九[269]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 1
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [10, 8, 9, 17, 18,29,30, 31,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![16]!.append(args)
                allPreSetRules[i]![16]!.append(suitRules)
                allPreSetRules[i]![16]!.append(rankRules)
                allPreSetRules[i]![16]!.append(rankRuleChecked)
//                17: "通用四张-杭州牌九[420]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                AValueRange = 0
                pairRank = 0
                singlefeatureRankRule = 0
                
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision, AValueRange, pairRank, singlefeatureRankRule]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! NPDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                var handNum = 2
                var communityNum = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var samePointComparision = 0
                var isCompareSuit = 0
                var singlefeatureRankRule = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1:"通用四张-四张9点大[4..]",
                handNum = 4
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2:"通用四张-54张9点混...",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 1
                isCompareSuit = 0
                singlefeatureRankRule = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3:"52张9点[226]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4:"9点昆[222]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 2
                QValueRange = 2
                JValueRange = 1
                samePointComparision = 0
                isCompareSuit = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5:"东兴九点[223]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 1
                isCompareSuit = 0
                singlefeatureRankRule = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
//                6:"潍坊9点 J/Q/K王算1[2...",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7:"9点对K大[225]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [3,2,1,0]
                rankRuleChecked = [1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
//                8:"52张9点最大[252]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9:"54张9点[228]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 2
                isCompareSuit = 1
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10:"通用四张9点 J/Q/K..."
                handNum = 4
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 1
                QValueRange = 1
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit,singlefeatureRankRule]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! FCDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//                0: "4张比单张[410]",
                var handNum = 4
                var communityNum = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var KValueRange = 1
                var QValueRange = 1
                var JValueRange = 1
                var pointComparision = 0
                var samePointComparision = 0
                var singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "4张9点[411]",
                handNum = 4
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange,pointComparision, samePointComparision,singlefeatureRankRule]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! TCDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//                0: "A59[250]",
                var handNum = 2
                var communityNum = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var pointComparision = 0
                var samePointComparision = 0
                var singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, pointComparision, samePointComparision,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,1,0]
                rankRuleChecked = [1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "合合[251]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 1
                singlefeatureRankRule = 1
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange,pointComparision, samePointComparision,singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "梭哈[258]",
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                pointComparision = 0
                samePointComparision = 0
                singlefeatureRankRule = 0
                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange,pointComparision, samePointComparision,singlefeatureRankRule]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! TCPDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//                0: "三张9点[330]",
                var handNum = 3
                var communityNum = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var samePointComparision = 0
                var isCompareSuit = 0
                var pointComparision = 0

                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "三张9点半[331]",
                handNum = 3
                communityNum = 0
                redspecialfeatureValueRange = 1
                blackspecialfeatureValueRange = 1
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0

                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [2,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
//                2: "三张10点半[332]",
                handNum = 3
                communityNum = 0
                redspecialfeatureValueRange = 1
                blackspecialfeatureValueRange = 1
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0

                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "三张9点[333]",
                handNum = 3
                communityNum = 0
                redspecialfeatureValueRange = 2
                blackspecialfeatureValueRange = 2
                KValueRange = 2
                QValueRange = 2
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0

                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "三张9点[334]",
                handNum = 3
                communityNum = 0
                redspecialfeatureValueRange = 3
                blackspecialfeatureValueRange = 3
                KValueRange = 3
                QValueRange = 3
                JValueRange = 2
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0

                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
                suitRules = [3,2,1,0]
                rankRules = [0]
                rankRuleChecked = [1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "三张10点半[335]"
                handNum = 3
                communityNum = 0
                redspecialfeatureValueRange = 1
                blackspecialfeatureValueRange = 1
                KValueRange = 1
                QValueRange = 1
                JValueRange = 1
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 1

                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision]
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
                let rule = ClassifierSettingArgs.targetSetting[i] as! TPFiveDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                
//                0: "十点半[270]",
                var handNum = 2
                var communityNum = 0
                var redspecialfeatureValueRange = 0
                var blackspecialfeatureValueRange = 0
                var KValueRange = 0
                var QValueRange = 0
                var JValueRange = 0
                var samePointComparision = 0
                var isCompareSuit = 0
                var pointComparision = 0
                var singlefeatureRankRule = 0

                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)

//                1: "十点半[271]"
                handNum = 2
                communityNum = 0
                redspecialfeatureValueRange = 0
                blackspecialfeatureValueRange = 0
                KValueRange = 0
                QValueRange = 0
                JValueRange = 0
                samePointComparision = 0
                isCompareSuit = 0
                pointComparision = 0
                singlefeatureRankRule = 0

                args = [handNum, communityNum,redspecialfeatureValueRange, blackspecialfeatureValueRange, KValueRange, QValueRange, JValueRange, samePointComparision,isCompareSuit, pointComparision, singlefeatureRankRule]
                suitRules = [3,2,1,0]
                rankRules = [1,0]
                rankRuleChecked = [1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                
                break
            
//            比鸡
            case 15:
                let rule = ClassifierSettingArgs.targetSetting[i] as! CBDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
//                0: "比鸡比道数[902]",
                var handNum = 9
                var communityNum = 0
                var winCondition = 1
                var AStraightMin = 1
                var specialfeatureChangeSetting = 0
                var specialfeatureThreeSingleFeatureSetting = 0

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
                
//                1: "比鸡百变尾墩大[903]",

                handNum = 9
                communityNum = 0
                winCondition = 0
                AStraightMin = 1
                specialfeatureChangeSetting = 1
                specialfeatureThreeSingleFeatureSetting = 0

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                
//                2: "比鸡百变尾墩大4[904]",
                
                handNum = 9
                communityNum = 0
                winCondition = 0
                AStraightMin = 1
                specialfeatureChangeSetting = 0
                specialfeatureThreeSingleFeatureSetting = 0

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
//                3: "比鸡百变尾墩大5[905]",
                handNum = 9
                communityNum = 0
                winCondition = 0
                AStraightMin = 1
                specialfeatureChangeSetting = 0
                specialfeatureThreeSingleFeatureSetting = 1

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)
//                4: "比鸡百变尾墩大2[906]",
                handNum = 9
                communityNum = 0
                winCondition = 0
                AStraightMin = 1
                specialfeatureChangeSetting = 1
                specialfeatureThreeSingleFeatureSetting = 1

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "比鸡9张金花[907]",
                
                handNum = 9
                communityNum = 0
                winCondition = 2
                AStraightMin = 1
                specialfeatureChangeSetting = 0
                specialfeatureThreeSingleFeatureSetting = 0

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
                
//                6: "比鸡比道数A23[908]",
                handNum = 9
                communityNum = 0
                winCondition = 1
                AStraightMin = 0
                specialfeatureChangeSetting = 0
                specialfeatureThreeSingleFeatureSetting = 0

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "比鸡9张金花A23[909",
                handNum = 9
                communityNum = 0
                winCondition = 2
                AStraightMin = 0
                specialfeatureChangeSetting = 0
                specialfeatureThreeSingleFeatureSetting = 0

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)

//                8: "比鸡9张百变金花[910]",
                handNum = 9
                communityNum = 0
                winCondition = 2
                AStraightMin = 1
                specialfeatureChangeSetting = 1
                specialfeatureThreeSingleFeatureSetting = 1

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![8]!.append(args)
                allPreSetRules[i]![8]!.append(suitRules)
                allPreSetRules[i]![8]!.append(rankRules)
                allPreSetRules[i]![8]!.append(rankRuleChecked)
//                9: "比鸡9张百变金花A23[...",
                
                handNum = 9
                communityNum = 0
                winCondition = 2
                AStraightMin = 1
                specialfeatureChangeSetting = 1
                specialfeatureThreeSingleFeatureSetting = 1

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![9]!.append(args)
                allPreSetRules[i]![9]!.append(suitRules)
                allPreSetRules[i]![9]!.append(rankRules)
                allPreSetRules[i]![9]!.append(rankRuleChecked)
//                10: "比鸡百变尾墩大[912]",
                handNum = 9
                communityNum = 0
                winCondition = 0
                AStraightMin = 1
                specialfeatureChangeSetting = 2
                specialfeatureThreeSingleFeatureSetting = 1

                args = [handNum, communityNum, winCondition, AStraightMin, specialfeatureChangeSetting, specialfeatureThreeSingleFeatureSetting]
                suitRules = [3,2,1,0]
                rankRules = [5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1]
                allPreSetRules[i]![10]!.append(args)
                allPreSetRules[i]![10]!.append(suitRules)
                allPreSetRules[i]![10]!.append(rankRules)
                allPreSetRules[i]![10]!.append(rankRuleChecked)

                break
                
            //十三水
            case 16:
                let rule = ClassifierSettingArgs.targetSetting[i] as! TWDatasetRule
                for j in 0...rule.setting.count - 1{
                    allPreSetRules[i]![j] = []
                }
                
//                0: "尾墩大13张[1302]",
                var handNum = 13
                var communityNum = 0
                var winCondition = 0
                var AStraightMin = 1
                var isDouble = 0
                
                args = [handNum, communityNum, winCondition, AStraightMin, isDouble]
                suitRules = [3,2,1,0]
                rankRules = [8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![0]!.append(args)
                allPreSetRules[i]![0]!.append(suitRules)
                allPreSetRules[i]![0]!.append(rankRules)
                allPreSetRules[i]![0]!.append(rankRuleChecked)
//                1: "道数13张翻倍[1301]",
                handNum = 13
                communityNum = 0
                winCondition = 1
                AStraightMin = 1
                isDouble = 1

                args = [handNum, communityNum, winCondition, AStraightMin, isDouble]
                suitRules = [3,2,1,0]
                rankRules = [8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![1]!.append(args)
                allPreSetRules[i]![1]!.append(suitRules)
                allPreSetRules[i]![1]!.append(rankRules)
                allPreSetRules[i]![1]!.append(rankRuleChecked)
                
//                2: "54张百变13张[1303]",
                handNum = 13
                communityNum = 0
                winCondition = 0
                AStraightMin = 1
                isDouble = 0

                args = [handNum, communityNum, winCondition, AStraightMin, isDouble]
                suitRules = [3,2,1,0]
                rankRules = [8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![2]!.append(args)
                allPreSetRules[i]![2]!.append(suitRules)
                allPreSetRules[i]![2]!.append(rankRules)
                allPreSetRules[i]![2]!.append(rankRuleChecked)
                
//                3: "道数13张不翻倍[1300]",
                
                handNum = 13
                communityNum = 0
                winCondition = 1
                AStraightMin = 1
                isDouble = 0

                args = [handNum, communityNum, winCondition, AStraightMin, isDouble]
                suitRules = [3,2,1,0]
                rankRules = [8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![3]!.append(args)
                allPreSetRules[i]![3]!.append(suitRules)
                allPreSetRules[i]![3]!.append(rankRules)
                allPreSetRules[i]![3]!.append(rankRuleChecked)

//                4: "道数13张不翻倍[1304]",

                handNum = 13
                communityNum = 0
                winCondition = 1
                AStraightMin = 1
                isDouble = 0
                
                args = [handNum, communityNum, winCondition, AStraightMin, isDouble]
                suitRules = [3,2,1,0]
                rankRules = [8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![4]!.append(args)
                allPreSetRules[i]![4]!.append(suitRules)
                allPreSetRules[i]![4]!.append(rankRules)
                allPreSetRules[i]![4]!.append(rankRuleChecked)
//                5: "道数13张比两道[1305]",
                
                handNum = 13
                communityNum = 0
                winCondition = 2
                AStraightMin = 1
                isDouble = 0
                
                args = [handNum, communityNum, winCondition, AStraightMin,isDouble]
                suitRules = [3,2,1,0]
                rankRules = [8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![5]!.append(args)
                allPreSetRules[i]![5]!.append(suitRules)
                allPreSetRules[i]![5]!.append(rankRules)
                allPreSetRules[i]![5]!.append(rankRuleChecked)
                
//                6: "道数13张不翻倍A2345二大[1306]",
                handNum = 13
                communityNum = 0
                winCondition = 1
                AStraightMin = 0
                isDouble = 0
                
                args = [handNum, communityNum, winCondition, AStraightMin, isDouble]
                suitRules = [3,2,1,0]
                rankRules = [8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![6]!.append(args)
                allPreSetRules[i]![6]!.append(suitRules)
                allPreSetRules[i]![6]!.append(rankRules)
                allPreSetRules[i]![6]!.append(rankRuleChecked)
//                7: "道数13张比两道A2345二大[1307]",
                handNum = 13
                communityNum = 0
                winCondition = 2
                AStraightMin = 0
                isDouble = 0
                
                args = [handNum, communityNum, winCondition, AStraightMin, isDouble]
                suitRules = [3,2,1,0]
                rankRules = [8,7,6,5,4,3,2,1,0]
                rankRuleChecked = [1,1,1,1,1,1,1,1,1]
                allPreSetRules[i]![7]!.append(args)
                allPreSetRules[i]![7]!.append(suitRules)
                allPreSetRules[i]![7]!.append(rankRules)
                allPreSetRules[i]![7]!.append(rankRuleChecked)
                
            default:
                break
            }
        }
        
    }
}

struct DatasetRule: Codable{
    var RuleName: String
    var DatasetType: Int = 0
    var setting: Int = 0
    var dealNum: Int = 0
    var coloringType: Int = 0
    var dealType: Int = 0
    var diyDealType: Int = 0
    var diyDealNum: [Int] = []
    var diyDealStatus: [[Bool]] = []
    var rcNum: Int = 0
    var shuffleMode: Int = 0
    var cutMode: Int = 0
    var singlefeatureToUse: [Int] = []
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
    var minSingleFeatureNum: Int
    var resultReportType: Int
    init(RuleName: String, DatasetType: Int, setting: Int, dealNum: Int, coloringType: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]], rcNum: Int, shuffleMode: Int, cutMode: Int, singlefeatureToUse: [Int], cutNumSetting : Int, reportSetting: Int, cutNumRangeSetting: [Int], positionSetting: Int, consecutiveReport: Int, reportNumber: Int, voiceReport: Int, args: [Int], suitRanks: [Int], rankRules: [Int], rankRuleChecked: [Int], minSingleFeatureNum: Int, resultReportType: Int) {
        self.RuleName = RuleName
        self.DatasetType = DatasetType
        self.setting = setting
        self.dealNum = dealNum
        self.coloringType = coloringType
        self.dealType = dealType
        self.diyDealNum = diyDealNum
        self.diyDealStatus = diyDealStatus
        self.rcNum = rcNum
        self.shuffleMode = shuffleMode
        self.cutMode = cutMode
        self.singlefeatureToUse = singlefeatureToUse
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
        self.minSingleFeatureNum = minSingleFeatureNum
        self.resultReportType = resultReportType
    }
}

struct RankRulesSate {
    var index: Int
    var isChecked: Bool
    
}


