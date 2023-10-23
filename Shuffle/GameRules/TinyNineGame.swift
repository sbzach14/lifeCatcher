
import Foundation
//import Python
//import PythonKit

//小九

class TinyNineGameRule : Rule{
    let setting: [Int: String] = [
        0: "标准"
    ]
    let ruleInfo: [Int: String] = [
        0:"""
一人发两张牌，一共四十张牌1-10
对子最大，如果不是对子比较两张牌加起来除以十的余数，如果一样则一样大
"""
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8,9,10]
}


class TinyNineGame{
    static func FindWinner(inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int]? {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let winners = calWinners(deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return winners
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 2 > 40)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex() -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...9{//a-10
                result.append(rank + i * 13)
            }
        }
        return result
    }
    
    static func getMinCardNum(playerNum: Int) -> Int{
        return playerNum * 2
    }
    
    static func calWinners(deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int] {
        let playerNum = args[0]
        
        var maxRank = 0
        var winners: [Int] = []
        var allPlayCards: [Player] = []
        
        for _ in 0..<playerNum {
            allPlayCards.append(Player())
        }
        
        
        var deck = deck
        // 发牌
        for _ in 0..<2 {
            for i in 0..<playerNum {
                allPlayCards[i].insertCard(card: deck.removeFirst())
            }
        }
        
        for i in 0..<playerNum {
            allPlayCards[i].evaluateFlag = TinyNineGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard)
        }
        
        winners = winners.sorted(by: { allPlayCards[$0].evaluateFlag > allPlayCards[$1].evaluateFlag })
        
        return winners
    }
}

class TinyNineGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
    }
    
    func evalHand(cards: [Card])->Int{
        var score = 0
        let num1 = cards[0].rank
        let num2 = cards[1].rank
        
        if num1 == num2 {
            score = num1 + 100
        } else {
            score = (num1 + num2) % 10
        }
        
        return score
    }
}
