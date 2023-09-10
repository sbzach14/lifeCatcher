
import Foundation
//import Python
//import PythonKit

//三公

class ThreeMenGameRule : Rule{
    let setting: [Int: String] = [
        0: "标准"
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8,9,10]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            3: "三三",
            2: "三条",
            1: "三公",
            0: "散牌"
        ]
    }
}


class ThreeMenGame{
    static func FindWinner(inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int]? {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let winners = calWinners(deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return winners
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 3 > 52)
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
        return playerNum * 3
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
        for _ in 0..<3 {
            for i in 0..<playerNum {
                allPlayCards[i].insertCard(card: deck.removeFirst())
            }
        }
        
        for i in 0..<playerNum {
            allPlayCards[i].evaluateFlag = ThreeMenGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard)
        }
        
        winners = winners.sorted(by: { allPlayCards[$0].evaluateFlag > allPlayCards[$1].evaluateFlag })
        
        return winners
    }
}

class ThreeMenGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
    }
    
    func evalHand(cards: [Card])->Int{
        var cards = cards
        cards.sort(by: { card1, card2 in
            return Card.calScore(card: card1) > Card.calScore(card: card2)
        })
        
        let score = calcHandInfoFlg(sortedCards: cards)
        
        return score
    }
    
    func calcHandInfoFlg(sortedCards: [Card]) -> Int {
        var rankResult = 0
        
        var ruleDict: [Int: ([Card]) -> Int] = [
            0  : self.eval_holecard,
            1  : self.eval_threemen,
            2  : self.eval_threecard,
            3  : self.eval_threethree,
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
    
    func eval_threethree(_ cards: [Card]) -> Int {
        var rank = 0
        if cards[0].rank == 3 && cards[1].rank == 3 && cards[2].rank == 3{
            rank = 1
        }
        return rank
    }
    
    func eval_threecard(_ cards: [Card]) -> Int {
        var rank = 0
        if cards[0].rank == cards[1].rank && cards[0].rank == cards[2].rank{
            rank = 1
        }
        return rank
    }
    
    func eval_threemen(_ cards: [Card]) -> Int {
        var rank = 0
        if cards[0].rank > 10 && cards[1].rank > 10 && cards[2].rank > 10{
            rank = 1
        }
        return rank
    }
    
    func eval_holecard(cards: [Card]) -> Int {
        var sumRank = 0
        for i in 0..<3 {
            sumRank += min(10, cards[i].rank)
        }
        sumRank = sumRank % 10
        
        let rank = (sumRank << 14) | (cards[0].rank << 10) | (cards[1].rank << 6) | (cards[2].rank << 2) | cards[0].suit[0]
        
        return rank
    }

}

