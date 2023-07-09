//
//  TexasPoker.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/29/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import Python
import PythonKit

class ThreeCardPokerGameRule : Rule{
    let setting: [Int: String] = [
        0: "标准",
        1: "自定义"
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8]
    let handNum: [Int] = [3,4,5,6,7,8,9,10,11,12]
    let minRank: [Int] = [2,3,4,5,6,7,8,9,10]
    let isCompareSuit : [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isAce:[Int: String] = [
        0: "无",
        1: "A最小",
        2: "A最大"
    ]
    let isAceStraight: [Int: String] = [
        0: "无",
        1: "最小顺",
        2: "最大顺",
        3: "第二大顺"
    ]
    let isHeadCard: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isReverseHighCard: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isRedJoker: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let redJokerSuit: [Int: String] = [
        0: "任意",
        1: "红色"
    ]
    let redJokerRank: [Int: String] = [
        14: "任意牌",
        13: "K",
        12: "Q",
        11: "J",
        10: "10",
        9: "9",
        8: "8",
        7: "7",
        6: "6",
        5: "5",
        4: "4",
        3: "3",
        2: "2",
        1: "A",
        0: "0",
    ]
    let isBlackJoker: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let blackJokerSuit: [Int: String] = [
        0: "任意",
        1: "红色"
    ]
    let blackJokerRank: [Int: String] = [
        14: "任意牌",
        13: "K",
        12: "Q",
        11: "J",
        10: "10",
        9: "9",
        8: "8",
        7: "7",
        6: "6",
        5: "5",
        4: "4",
        3: "3",
        2: "2",
        1: "A",
        0: "0"
    ]
    let isMixedSuit: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let rankRules: [Int: String] = [
        14: "对王",
        13: "炸弹",
        12: "三条",
        11: "同花235",
        10: "235",
        9: "同花AKJ",
        8: "AKJ",
        7: "三公",
        6: "同花顺",
        5: "同花对子",
        4: "同花",
        3: "顺子",
        2: "真对子",
        1: "对子",
        0: "散牌"
    ]
    
    

}

class ThreeCardPokerGame{
    
    
    static func FindWinner(inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int]? {
        
        let json = Python.import("json")
                
        let pythonObject =  json.ThreeCardPokerGame.calResult(inputCards, args, rankRules, suitRules)
        // 使用 map() 函数将 PythonList 转换为 Int 数组
        let intArray = Array<Int>(pythonObject)!
        
        return intArray
    }
    
    static func legalCheck(playerNum: Int, minRank: Int, handNum: Int, isHeadCard: Int, isRedJoker: Int, isBlackJoker: Int) -> String
    {
        var errMessage : String = ""
        if(playerNum * handNum > 52 - (minRank - 2) * 4 - isHeadCard * 12 + isRedJoker + isBlackJoker)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
}
