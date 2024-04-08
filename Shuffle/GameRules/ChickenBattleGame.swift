
import Foundation
//import Python
//import PythonKit

//九点半

class ChickenBattleGameRule : Rule{
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [:]
        self.setting = [:]
        self.ruleInfo = [
            0:"""
    扑克张数:54张 不分花色
    1) 9+王=K+9=Q+9=J+9一样大，最大牌
    2)对子一样大，两黑或者两红才算对子，对子一黑一红算点数。
    3) 9点>8+王>8点...0点最小
    4) 王/K/Q/J算半点，同点同对庄赢
    """,
            
            1:"""
    自定义你的规则
    """,

        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class ChickenBattleGame{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards, winnerRanks) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards, winnerRanks)
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 9 > 52)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        default:
            result = Array(0...51) + [53,54]
            break
        }
        
        return result
    }
    
    static func getMinCardNum(playerNum: Int, handNum: Int, communityNum: Int,dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
        if dealType == 0 || dealType == 1{
            return playerNum * handNum + communityNum
        } else {
            var minNum = 0
            for i in 0..<diyDealNum.count {
                let num = diyDealNum[i]
                //派牌
                if diyDealStatus[i][0] == true {
                    minNum += playerNum * num
                //公牌
                } else if diyDealStatus[i][1] == true {
                    minNum += num
                //去牌
                } else {
                    minNum += num
                }
            }
            return minNum
        }
    }
    
    //args
    //0 dealType
    //1 diyDealType
    //2 playerNum

    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        let dealType = args[0]
        let diyDealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]

        
        var maxRank = 0
        var winners: [Int] = []
        var winnerRanks: [Int] = []
        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < self.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([], [], [])
        }
        
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
            allPlayCards[i].evaluateFlag = ChickenBattleGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard)
        }
        
        
        var resultList = [ResultStruct]()
        for i in 0..<playerNum {
            let rank = allPlayCards[i].evaluateFlag
            resultList.append(ResultStruct(playerID: i, rank: rank))
        }
        
        let sortedResultList =  resultList.sorted(by: {$0.rank > $1.rank })
        for result in sortedResultList {
            winners.append(result.playerID)
            winnerRanks.append(result.rank)
        }
        
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        if leftCards.count < NinePointFiveGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        print("winners \(winners)")
        return (winners, leftCards, winnerRanks)
    }
}

class ChickenBattleGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([Card]) -> Int] = [:]

    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            :
        ]
    }
    
    func evalHand(cards: [Card])->Int{
        var cards = cards
        cards.sort(by: {card1, card2 in return card1.rank > card2.rank})
        
        var score = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let rank = self.ruleDict[ruleIndex]!(cards)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 6)) | rank
                print("牌型 \(ruleIndex) rank \(score)")

                break
            }
        }
        
        return score
    }
}

