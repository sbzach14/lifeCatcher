
import Foundation
//import Python
//import PythonKit

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
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
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

    
    

}

//德州扑克
class TexasPoker{
    
    
    

    static func FindWinner(inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int]? {
        
        
        
        let testCardLabelDic : [Int:String] = [
            0: "♠️A ", 1: "♠️2 ", 2: "♠️3 ", 3: "♠️4 ", 4: "♠️5 ", 5: "♠️6 ", 6: "♠️7 ", 7: "♠️8 ", 8: "♠️9 ", 9: "♠️10 ",
            10: "♠️J ", 11: "♠️Q ", 12: "♠️K ", 13: "♥️A ", 14: "♥️2 ", 15: "♥️3 ", 16: "♥️4 ", 17: "♥️5 ", 18: "♥️6 ",
            19: "♥️7 ", 20: "♥️8 ", 21: "♥️9 ", 22: "♥️10 ", 23: "♥️J ", 24: "♥️Q ", 25: "♥️K ", 26: "♣️A ", 27: "♣️2 ",
            28: "♣️3 ", 29: "♣️4 ", 30: "♣️5 ", 31: "♣️6 ", 32: "♣️7 ", 33: "♣️8 ", 34: "♣️9 ", 35: "♣️10 ", 36: "♣️J ",
            37: "♣️Q ", 38: "♣️K ", 39: "♦️A ", 40: "♦️2 ", 41: "♦️3 ", 42: "♦️4 ", 43: "♦️5 ", 44: "♦️6", 45: "♦️7",
            46: "♦️8 ", 47: "♦️9 ", 48: "♦️10 ", 49: "♦️J ", 50: "♦️Q ", 51: "♦️K ", 52: "none", 53: "小王", 54: "大王"
        ]
//        let json = Python.import("json")
//
//        let pythonObject =  json.TexasPokerGame.calResult(inputCards, args, rankRules, suitRules)
//        // 使用 map() 函数将 PythonList 转换为 Int 数组
//        let intArray = Array<Int>(pythonObject)!
        print("Array")
        var inputString : String = ""
        for i in 0..<inputCards.count{
            inputString += testCardLabelDic[inputCards[i]]!
        }
        print(inputString)
        let winnersArray = TexasPokerGame.calResult(cardArray: inputCards, args: args, rankRules: rankRules, suitRules: suitRules)
        print("winner ", winnersArray)
        return winnersArray
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
    
    static func getMinCardNum(playerNum: Int, handNum: Int, communityNum: Int) -> Int{
        return playerNum * handNum + communityNum
    }
}
