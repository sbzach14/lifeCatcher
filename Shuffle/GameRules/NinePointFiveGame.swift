
import Foundation
//import Python
//import PythonKit

//九点半

class NinePointFiveGameRule : Rule{
    let setting: [Int: String] = [
        0: "标准"
    ]
    let ruleInfo:[Int:String] = [
        0:"""
一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
大小：
九点半，
1-9的对子，
散牌，计算点数之和处以10的余数大小
"""
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8,9,10]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            3: "王对",
            2: "九点半",
            1: "对子",
            0: "散牌"
        ]
    }
}


class NinePointFiveGame{
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
            for rank in 0...12{
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
            allPlayCards[i].evaluateFlag = NinePointFiveGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard)
        }
        
        winners = winners.sorted(by: { allPlayCards[$0].evaluateFlag > allPlayCards[$1].evaluateFlag })
        
        return winners
    }
}

class NinePointFiveGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
    }
    
    func evalHand(cards: [Card])->Int{
        var cards = cards
        
        let score = calcHandInfoFlg(sortedCards: cards)
        
        return score
    }
    
    func calcHandInfoFlg(sortedCards: [Card]) -> Int {
        var rankResult = 0
        
        var ruleDict: [Int: ([Card]) -> Int] = [
            0  : self.eval_holecard,
            1  : self.eval_onepair,
            2  : self.eval_ninepointfive,
            3  : self.eval_kingpair,
        ]
        
        for (index, ruleIndex) in rankRules.enumerated() {
            var rankFlag = 1 << (rankRules.count - index + 18)
            var rankResult = ruleDict[ruleIndex]!(sortedCards)
            
            if rankResult != 0 {
                rankResult |= rankFlag
                break
            }
        }

        
        return rankResult
    }
    
    func eval_kingpair(_ cards: [Card]) -> Int {
        var rank = 0
        if cards[0].rank > 13 && cards[1].rank > 13{
            rank = 1
        }
        return rank
    }
    
    func eval_ninepointfive(_ cards: [Card]) -> Int {
        var rank = 0
        if (cards[0].rank == 9 && cards[1].rank > 10)
            || (cards[1].rank == 9 && cards[0].rank > 10){
            rank = 1
        }
        return rank
    }
    
    func eval_onepair(_ cards: [Card]) -> Int {
        var rank = 0
        if cards[0].rank == cards[1].rank && cards[0].rank < 10{
            rank = cards[0].rank
        }
        return rank
    }
    
    func eval_holecard(cards: [Card]) -> Int {
        var rank = 0
        for card in cards {
            if card.rank > 10{
                rank += 1
            }
            else{
                rank += card.rank * 2
            }
        }
        rank = rank % 20
        
        return rank
    }

}

