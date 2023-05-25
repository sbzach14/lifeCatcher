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
        let jsonString = """
        {
            "name": "John",
            "age": 30,
            "city": "New York"
        }
        """
        
        let sys = Python.import("sys")
        sys.path.append("/Users/naldochen/shuffle/python-stdlib/")
        let json = Python.import("json")
        let jsonObj = json.loads(jsonString)
        print(jsonObj["name"])

        print("Start the function")
        let pokerBull =  Python.import("pypoker.PokerBull")
        print("import successfully")
        let pythonList = Python.list(inputCards)
        let pythonInt = PythonObject(playerNum)
        print("var conversion")
        print(pokerBull)
        
        let pyobj =  Int(json.TestClass.TestFunc(playerNum))!
        
        print(pyobj)
        print("////////////////////")
        
        let pythonObject =  pokerBull.PorkerBullGame.calResult(pythonList, pythonInt)
        print("Return Winner")
        // 使用 map() 函数将 PythonList 转换为 Int 数组
        let intArray = pythonObject.object.map { Int($0)! }
        print("Convert winner from python to swift")
        
        return intArray
    }
    
}
