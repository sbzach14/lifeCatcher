import Foundation
//import Python
//import PythonKit

//二八杠

class TwoEightGangGameRule : Rule{
    let setting: [Int: String] = [
        0: "标准"
    ]
    let ruleInfo:[Int: String] = [
        0:"""
36张牌，2-10，一人两张
大小：
对子
28
两张牌加起来的点数，点数一样一样大
"""
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8,9,10]
    
}


class TwoEightGangGame{
    static func FindWinner(inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int]? {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let winners = calWinners(deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return winners
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 2 > 36)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex() -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 1...9{//2-10
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
            allPlayCards[i].evaluateFlag = TwoEightGangGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard)
        }
        
        winners = winners.sorted(by: { allPlayCards[$0].evaluateFlag > allPlayCards[$1].evaluateFlag })
        
        return winners
    }
}

class TwoEightGangGameHandEvaluator{
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
        } else if (num1 == 2 && num2 == 8) || (num1 == 8 && num2 == 2) {
            score = 100
        } else {
            score = (num1 + num2) % 10
        }
        
        return score
    }
}
