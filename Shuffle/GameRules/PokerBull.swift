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
    static func findWinner(inputCards:[Int], playerNum: Int) -> [Int]? {
        
        let pokerBullGame =  Python.import("pypoker/PokerBull")
        
        let pythonObject =  pokerBullGame.PorkerBullGame.calResult(inputCards, playerNum)
        
        // 使用 map() 函数将 PythonList 转换为 Int 数组
        let intArray = pythonObject.object.map { Int($0)! }

        return intArray
    }
    
}
