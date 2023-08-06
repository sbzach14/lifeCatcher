//
//  PokerBull.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/16/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import Python
import PythonKit

class PokerBullRule : Rule{
    let setting: [Int: String] = [
        0: "标准五张牛牛",
        1: "标准四张牛牛",
        2: "标准三张牛牛",
        3: "自定义"
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8]
    //TODO: 加入总牌数量来限制规则的选择，当前为所有规则都能选择
    let handNum :[Int] = [3,4,5,10]
    let isCompareSuit : [Int: String] = [
        0: "否",
        1: "是"
    ]
    let fiveLittleRank : [Int:String] = [
        0:"五小一样大",
        1:"五小谁小谁大",
        2:"五小谁大谁大",
        3:"比较最大牌"
    ]
    
    let secondRankRule:[Int:String] = [
        0:"同牛同点比最大的牌，无牛也比最大的牌",
        1:"同牛同点比牛架后两张，无牛比最大的牌",
        2:"同牛同点一样大，无牛一样大",
    ]
    
    let jokerIsMinZero:[Int:String] = [
        0:"否",
    ]
    
    let BullRules: [Int:String] = [
        0:"任意三张牌点数之和是10的倍数",
        1:"三条",
        2:"所有的牌点数之和是10的倍数",
        3:"三张牌组成的顺子",
        4:"只有jkq大小王（牛牛）",
        5:"三张牌点数相加是1",
        6:"五张牌点数相加小于10，相加是几就是牛几",
        7:"五张牌相加小于等于9",
        8:"任意三张牌点数之和是10的倍数并且大于20点",
    ]
    let tenValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"1/0（计算点数时还是10）",
        3:"1/0（计算点数时是0/1）"
    ]
    
    let JValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"11",
    ]
    let QValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"2",
        3:"12",
    ]
    
    let KValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"6",
        3:"13"
    ]
    let blackJokerValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"3",
    ]
    let redJokerValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"6",
    ]
    let threeValueRange:[Int:String] = [
        0:"3",
    ]
    let sixValueRange:[Int:String] = [
        0:"6",
    ]
    let spadeAValueRange:[Int:String] = [
        0:"1",
        1:"0",
    ]
    
    let threeCardsRankRules:[Int: String] = [
        0:"三条",
        1:"jqk",
        2:"qj10",
        3:"点数之和等于10",
        4:"同花顺",
        5:"顺子",
    ]
    static let fiveCardsRankRules: [Int: String] = [
        0:"牌的点数之和大于等于40",
        1:"炸弹（四条）",
        2:"牌的点数之和小于等于10",
        3:"牌的点数之和等于20并且有牛",
        4:"牌的点数之和等于30并且有牛",
        5:"三条并且剩下的两张牌点数之和是10的倍数",
        6:"牌的点数之和等于20或者30",
        7:"葫芦",
        8:"顺子",
        9:"牛牛",
        10:"有牛",
        11:"黄金牛，五张牌都是公牌",
        12:"银牛，五张牌都是公牌和10",
        13:"两对",
        14:"牛九",
        15:"对子",
        16:"同花",
        17:"五小（所有的牌都比五小）",
        18:"钻石牛牛（五花牛且有一张王）",
        19:"牛+一对9",
        20:"牛+JQ",
        21:"牛+10J",
        22:"牛+a10",
        23:"235加一个对子",
        24:"牛加对子",
        25:"五张牌点数之和为40",
        26:"铁板牛牛（三条+剩下的牌是10的倍数）",
        27:"同色（同红或者同黑）",
        28:"顺斗，有一组三张顺子+两张牌",
        29:"硬斗，235加一组牌",
        30:"同花顺",
        31:"五个1",
        32:"五张牌点数等于10",
        33:"五张牌点数等于20",
        34:"五张牌点数等于30",
        35:"五张牌点数等于40",
        36:"五张牌点数等于5",
        37:"♠️a，剩下的牌都是jqk",
        38:"牛+对a",
        39:"带♠️a的牛",
        40:"带♠️a的五花牛（有大小王）",
        41:"五小牛，五张牌的每一张牌都小于等于5并且总和小于10",
    ]
    
}

class PokerBull{
    static func FindWinner(inputCards:[Int], args:[Int], rankRules:[Int], suitRules: [Int]) -> [Int]? {
        

        let json = Python.import("json")
                
        let pythonObject =  json.PokerBullGame.calResult(inputCards, args, rankRules, suitRules)
        // 使用 map() 函数将 PythonList 转换为 Int 数组
        let intArray = Array<Int>(pythonObject)!
        
        return intArray
    }
    
    static func legalCheck(playerNum: Int){
        
    }
    
}
