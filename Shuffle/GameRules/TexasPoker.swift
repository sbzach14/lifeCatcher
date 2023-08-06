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

class TexasPokerRule : Rule{
    let setting: [Int: String] = [
        0: "标准",
        1: "短牌",
        2: "自定义"
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8]
    let isCompareSuit : [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isAceStraight: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let minRank: [Int] = [2,3,4,5,6,7,8,9]
    let handNum: [Int] = [1,2,3,4,5]
    let communityNum: [Int] = [0,3,5]
    let handUseType: [Int: String] = [
        0: "无限制",
        1: "必须用n张",
        2: "最少用n张"
    ]
    let handUseNum: [Int] = [1,2,3,4,5]
    let rankRules: [Int: String] = [
        11: "同花顺",
        10: "四条",
        9: "葫芦",
        8: "同花",
        7: "顺子",
        6: "三条",
        5: "三同花顺",
        4: "三顺子",
        3: "三同花",
        2: "两对",
        1: "一对",
        0: "高牌"
    ]
    
    

}

class TexasPoker{
    
    
    static func FindWinner(inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int]? {
        
        let json = Python.import("json")

                
        let pythonObject =  json.TexasPokerGame.calResult(inputCards, args, rankRules, suitRules)
        // 使用 map() 函数将 PythonList 转换为 Int 数组
        let intArray = Array<Int>(pythonObject)!
        
        return intArray
    }
    
    static func legalCheck(playerNum: Int, minRank: Int, handUseType: Int, handUseNum: Int, handNum: Int, communityNum: Int) -> String
    {
        var errMessage : String = ""
        if(handUseType == 0 && handNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(handUseType != 0 && handNum < handUseNum)
        {
            errMessage = "手牌数小于设置需求，请重新设置！"
        }
        else if(handUseType == 1 && handUseNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(handUseType == 2 && handNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(playerNum * handNum + communityNum > 52 - (minRank - 2) * 4)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex(minRank: Int) -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...12{
                if rank == 0 || rank >= minRank - 1{
                    result.append(rank + i * 13)
                }
            }
        }
        return result
    }
}
