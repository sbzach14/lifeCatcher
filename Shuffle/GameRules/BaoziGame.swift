
import Foundation
//import Python
//import PythonKit

//宝子

class BaoziGameRule : Rule{
    let setting: [Int: String] = [
        0: "标准"
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8,9,10]
}


class BaoziGame{
    static func FindWinner(inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int]? {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let winners = calWinners(deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return winners
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 2 > 52)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex() -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...12{//a-k
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

class BaoziGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
    }
    
    func evalHand(cards: [Card])->Int{
        var score = 0
        var num1 = BaoziCard(cardRank:cards[0].rank)
        var num2 = BaoziCard(cardRank:cards[1].rank)
        
        if num1.rank == num2.rank {
            score = num1.rank << 8
        }
        else {
            score = ((num1.point + num2.point) % 10) << 4 | max(num1.rank, num2.rank)
        }
        
        return score
    }
}

class BaoziCard{
    var rank:Int
    var point:Int
    
    init(cardRank: Int){
        if cardRank == 1{
            rank = 14
        }
        else{
            rank = cardRank
        }
        
        if cardRank == 11{
            point = 1
        }
        else if cardRank == 12{
            point = 2
        }
        else if cardRank == 13{
            point = 3
        }
        else{
            point = cardRank
        }
    }
}
