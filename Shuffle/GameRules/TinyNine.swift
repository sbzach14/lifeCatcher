//
//  TinyNine.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/24/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import Python
import PythonKit

class TinyNine{
    static func FindWinner(inputCards:[Int], playerNum: Int)->[Int]? {
        let tinyNineGame = Python.import("pypoker/TinyNine")
        let pythonObject = tinyNineGame.TinyNineGame.calResult(inputCards, playerNum)
        let intArray = pythonObject.object.map{Int($0)!}
        return intArray
    }
}
