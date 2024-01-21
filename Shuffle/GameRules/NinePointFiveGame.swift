
import Foundation
//import Python
//import PythonKit

//九点半

class NinePointFiveGameRule : Rule{
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            3: "王对",
            2: "九点半",
            1: "对子",
            0: "散牌"
        ]
        self.setting = [
            0: "宝子2张9点大",
            1: "宝子2张10点大",
            2: "宝子P对大",
            3: "52张宝子",
            4: "52张上海宝子",
            5: "54张宝子12",
            6: "唐山54张宝子",
            7: "40张宝子分花色",
            8: "54张宝子13",
            9: "54张比宝子14",
            10: "52张新疆宝子",
            11: "宝子J",
            12: "宝子Q",
            13: "宝子K",
            14: "江苏52张二八",
            15: "52张宝子2",
        ]
        self.ruleInfo = [
            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,
            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,
            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,
            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,
            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,

            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,
            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,

            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,
            0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,0:"""
    一共52张牌，A-K，每人发两张比大小，J，Q，K算半点
    大小：
    九点半，
    1-9的对子，
    散牌，计算点数之和处以10的余数大小
    """,

        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class NinePointFiveGame{
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
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
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int]) {
        let dealType = args[0]
        let diyDealType = args[1]
        let playerNum = args[2]
        
        var maxRank = 0
        var winners: [Int] = []
        var allPlayCards: [Player] = []
        var community = [Card]()
        
        for _ in 0..<playerNum {
            allPlayCards.append(Player())
        }
        
        
        var deck = deck
        // 发牌
        if dealType == 0 || dealType == 1{
            for _ in 0..<2 {
                if dealType == 0{
                    for i in 0..<playerNum {
                        allPlayCards[i].insertCard(card: deck.removeFirst())
                    }
                } else if dealType == 1 {
                    allPlayCards[0].insertCard(card: deck.removeFirst())
                    for i in stride(from: playerNum - 1, to: 0, by: -1) {
                        allPlayCards[i].insertCard(card: deck.removeFirst())
                    }
                }
            }
        } else {
            for actionIndex in 0...diyDealStatus.count - 1{
                let cardNum = diyDealNum[actionIndex]
                let action = diyDealStatus[actionIndex]
                //派牌
                if action[0] == true{
                    if diyDealType == 0{
                        for i in 0..<playerNum {
                            for _ in 0..<cardNum{
                                allPlayCards[i].insertCard(card: deck.removeFirst())
                            }
                        }
                    } else if diyDealType == 1{
                        for _ in 0..<cardNum{
                            allPlayCards[0].insertCard(card: deck.removeFirst())
                        }
                        for i in stride(from: playerNum - 1, to: 0, by: -1) {
                            for _ in 0..<cardNum{
                                allPlayCards[i].insertCard(card: deck.removeFirst())
                            }
                        }
                    }
                //公牌
                } else if action[1] == true {
                    for _ in 0..<cardNum{
                        community.append(deck.removeFirst())
                    }
                //去牌
                } else if action[2] == true {
                    for _ in 0..<cardNum{
                        deck.removeFirst()
                    }
                }
            }
        }
        
        
        
        for i in 0..<playerNum {
            allPlayCards[i].evaluateFlag = NinePointFiveGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard)
        }
        
        for i in 0..<playerNum {
            let rank = allPlayCards[i].evaluateFlag
            if rank > maxRank {
                maxRank = rank
                winners.removeAll()
                winners.append(i)
            } else if rank == maxRank {
                winners.append(i)
            }
        }
        
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        
        return (winners, leftCards)
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

