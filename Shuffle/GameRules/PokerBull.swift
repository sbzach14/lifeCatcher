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
    static func FindWinner(inputCards:[Int], playerNum: Int) -> [Int]? {
        
        let sys = Python.import("sys")
        sys.path.append("/Users/naldochen/shuffle/python-stdlib/")
        let json = Python.import("json")

        print("import successfully")
        let pythonList = Python.list(inputCards)
        let pythonInt = PythonObject(playerNum)
        print("var conversion")
        
        let pyobj =  Int(json.TestClass.TestFunc(playerNum))!
        
        print(pyobj)
        print("////////////////////")
        
        let pythonObject =  json.PokerBullGame.calResult(pythonList, pythonInt)
        print("Return Winner")
        // 使用 map() 函数将 PythonList 转换为 Int 数组
        let intArray = Array<Int>(pythonObject)!
        print("Convert winner from python to swift")
        
        return intArray
    }
    
}
