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

class PokerBull{
    static func FindWinner(inputCards:[Int], args:[Int], rankRules:[Int], suitRules: [Int]) -> [Int]? {
        

        let json = Python.import("json")
                
        let pythonObject =  json.PokerBullGame.calResult(inputCards, args, rankRules, suitRules)
        // 使用 map() 函数将 PythonList 转换为 Int 数组
        let intArray = Array<Int>(pythonObject)!
        
        return intArray
    }
    
}
