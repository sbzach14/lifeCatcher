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
    let mode : [Int] = [0,1]
}

class TexasPoker{
    static func FindWinner(inputCards:[Int], playerNum: Int, args: [Int], rankRules: [Int]) -> [Int]? {
        

        let json = Python.import("json")

        //let pythonList = Python.list(inputCards)
        //let pythonInt = PythonObject(playerNum)
                
        let pythonObject =  json.TexasPokerGame.calResult(inputCards, playerNum, args, rankRules)
        // 使用 map() 函数将 PythonList 转换为 Int 数组
        let intArray = Array<Int>(pythonObject)!
        
        return intArray
    }
    
}
