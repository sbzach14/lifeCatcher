
import Foundation
//import Python
//import PythonKit

//九点半

class NinePointFiveGameRule : Rule{
    
    let redJokerValueRange: [Int: String] = [
        0: "1",
        1: "2"
    ]
    
    let blackJokerValueRange: [Int: String] = [
        0:"1",
        1:"2"
    ]
    
    let KValueRange: [Int: String] = [
        0:"1",
        1:"6"
    ]
    
    let QValueRange: [Int: String] = [
        0:"1",
        1:"4"
    ]
    let JValueRange: [Int: String] = [
        0:"1",
        1:"2"
    ]
    
    let samePointComparision: [Int: String] = [
        0: "同点同对庄赢",
        1: "同点时 两红>一红一黑>两黑",
    ]
    
    let isPairSameRank: [Int: String] = [
        0:"否",
        1:"是"
    ]
    
    let pairRequirement: [Int: String] = [
        0:"无限制",
        1:"同色才是对子，不同色直接算点数"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            7:"黑8 + 大王",
            6:"黑8 + 小王",
            5:"红8 + 大王",
            4:"红8 + 小王",
            3: "王对",
            2: "九点半",
            1: "对子",
            0: "散牌"
        ]
        self.setting = [
            0: "54张九点半[227]",
            1: "54张9点半1[228]",
            2: "江西九点半[229]",
            3: "安徽九点半[230]",
            4: "江西54张九点半[231]",
            5: "九点半最大[232]",
            6: "江西九点半1[233]",
            7: "临沂九点半，对王最大[234]",
            8: "江西九点半2",
            9: "九点半最大2",
            10:"安徽九点半[226]",
            11:"安徽九点半[235]",
            12:"江西九点半[237]",
            13:"54张九点半[238]",
            14: "自定义九点半",
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:54张 不分花色
    1) 9+王=K+9=Q+9=J+9一样大，最大牌
    2)对子一样大，两黑或者两红才算对子，对子一黑一红算点数。
    3) 9点>8+王>8点...0点最小
    4) 王/K/Q/J算半点，同点同对庄赢
    """,
            1:"""
    扑克张数:52张 不分花色
    1)K+9=Q+9=J+9一样大，最大牌
    2>对子一样大，两黑或者两红才算对子，对子一黑一红算点数。
    3) 9点>8+k>8点...0点最小
    4) K/Q/J算半点，同点同对庄赢
    """,
            2:"""
    扑克张数:54张 不分花色
    1) 9+王>对子，对子一样大不分大小。
    2) 9点>8+王>8点...0点最小
    3) 王/K/Q/J算半点，同点同对庄赢
    """,
            3:"""
    扑克张数:54张 不分花色
    1)9+k>对王>对子，对子一样大，两黑或者两红才算对子，对子一黑一红算点数
    2>黑8+小王>黑8+大王>红8+大王>红8+小王>9点>8点半.....0点最小
    3)大王算1点，k算半点，Q算2点，J算一点，同色才为对子，，不同色算数。
    """,
            4:"""
    扑克张数:54张 不分花色
    1) 九点半最大>对子，同色才为对子，不同色算点数。
    2) 9点>8点半>8点>.....0点最小
    3)大小王，JKQ算半点，对子一样大，同点庄家大。
    """,
            5:"""
    扑克张数:52张不分花色
    1) 9点半>9点>8点半>.....>0点最小
    2) K/Q/J算半点，对子算点数，9点半最大。
    """,
            6:"""
    扑克张数:54张不分花色
    1 9+王>对子，对子一样大不分大小。
    2) 9点>8+王>8点...0点最小
    3)王算半点，K为3点，Q为2点。J为1点，同点同对庄赢
    """,
            7:"""
    扑克张数:54 52不分花色
    1) 对王最大0点最小 对王>对K>
    对Q>对J>对10>对9
    2) 王/K/Q/J算半点 10算0点
    """,

            8:"""
    扑克张数: 54张 不分花色
    1 9+王>对子，对子一样大不分大小。
    2) 9点>8+王>8点...0点最小
    3)王算半点，K为3点，Q为2点。J为1点，同点同对庄赢
    """,
            9:"""
    扑克张数:54张 不分花色
    1) 9点半>9点>8点半>...….>0点最小
    2) 王/K/Q/J算半点，对子算点数，9点半最大。
    """,
            10:"""
            扑克张数:54张不分花色
            1)9+k>对子，对子一样大，两黑或者两红才算对子，对子一黑一红算点数
            2)9点>8点半.....0点最小
            3)大王算1点，k算半点，Q算2点，J算一点，同色才为对子,不同色算点数。
            """,
            11:"""
            扑克张数:54张不分花色
            1)9+k>对子，对子一样大，两黑或者两红才算对子，对子一黑一红算点数
            2)9点>8点半.....0点最小
            3)大王算1点，k算半点，Q算2点，J算一点，同色才为对子，不同色算点数。
            """,
            12:"""
            扑克张数:54张分花色
            1) 9+王>对K>对Q>对J>......>对1
            2)9点>8点半>8点>7点半>...0最小同色才算对子同点时两红>一红一黑>两黑
            王=半点K=3 Q=2 J=1
            """,
            13:"""
            扑克张数:54张不分花色,对子算点数
            1)九点半最大
            2)9点>8点半>8点>.....0点最小大小王，JKQ算半点
            """,
            14:"""
    自定义你的规则
    """,

        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class NinePointFiveGame{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards, winnerRanks) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards, winnerRanks)
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 2 > 52)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...51) + [53,54]
            break
        case 1:
            result = Array(0...51)
            break
        case 2:
            result = Array(0...51) + [53,54]
            break
        case 3:
            result = Array(0...51) + [53,54]
            break
        case 4:
            result = Array(0...51) + [53,54]
            break
        case 5:
            result = Array(0...51)
            break
        case 6:
            result = Array(0...51) + [53,54]
            break
        case 7:
            result = Array(0...51) + [53,54]
            break
        case 8:
            result = Array(0...51) + [53,54]
            break
        case 9:
            result = Array(0...51) + [53,54]
            break
        case 10:
            result = Array(0...51) + [53,54]
            break
        case 11:
            result = Array(0...51) + [53,54]
            break
        case 12:
            result = Array(0...51) + [53,54]
            break
        case 13:
            result = Array(0...51) + [53,54]
            break
        default:
            result = Array(0...51) + [53,54]
            break
        }
        
        return result
    }
    
    static func getMinCardNum(playerNum: Int,dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
        if dealType == 0 || dealType == 1{
            return playerNum * 2
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
    //3 redJokerValueRange
    //4 blackJokerValueRange
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 samePointComparision
    //9 isPairSameRank
    //10 pairRequirement
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let redJokerValueRange = args[3]
        let blackJokerValueRange = args[4]
        let KValueRange = args[5]
        let QValueRange = args[6]
        let JValueRange = args[7]
        let samePointComparision = args[8]
        let isPairSameRank = args[9]
        let pairRequirement = args[10]
        
        var maxRank = 0
        var winners: [Int] = []
        var winnerRanks: [Int] = []
        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < self.getMinCardNum(playerNum: playerNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([], [], [])
        }
        
        for _ in 0..<playerNum {
            allPlayCards.append(Player())
        }
        
        
        var deck = deck
        // 发牌
        if dealNum == 0{
            for _ in 0..<2{
                //正发
                if dealType == 0{
                    for i in 0..<playerNum {
                        allPlayCards[i].insertCard(card: deck.removeFirst())
                    }
                //反发
                } else if dealType == 1 {
                    for i in 0..<playerNum {
                        allPlayCards[i].insertCard(card: deck.removeLast())
                    }
                }
            }
            
        } else {
            for actionIndex in 0...diyDealStatus.count - 1{
                let cardNum = diyDealNum[actionIndex]
                let action = diyDealStatus[actionIndex]
                //派牌
                if action[0] == true{
                    //正发
                    if dealType == 0{
                        for i in 0..<playerNum {
                            for _ in 0..<cardNum{
                                allPlayCards[i].insertCard(card: deck.removeFirst())
                            }
                        }
                    //反发
                    } else if dealType == 1{
                        for i in 0..<playerNum {
                            for _ in 0..<cardNum{
                                allPlayCards[i].insertCard(card: deck.removeLast())
                            }
                        }
                    }
                //公牌
                } else if action[1] == true {
                    if dealType == 0{
                        for _ in 0..<cardNum{
                            community.append(deck.removeFirst())
                        }
                    } else if dealType == 1{
                        for _ in 0..<cardNum{
                            community.append(deck.removeLast())
                        }
                    }
                    
                //去牌
                } else if action[2] == true {
                    if dealType == 0 {
                        for _ in 0..<cardNum{
                            deck.removeFirst()
                        }
                    } else if dealType == 1{
                        for _ in 0..<cardNum{
                            deck.removeLast()
                        }
                    }
                }
            }
        }
        
        
        
        for i in 0..<playerNum {
            allPlayCards[i].evaluateFlag = NinePointFiveGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerRange: blackJokerValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,samePointComparision: samePointComparision,isPairSameRank: isPairSameRank,pairRequirement: pairRequirement)
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
        if leftCards.count < NinePointFiveGame.getMinCardNum(playerNum: playerNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        print("winners \(winners)")
        return (winners, leftCards, winnerRanks)
    }
}

class NinePointFiveGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([NinePointFiveCard]) -> Int] = [:]
    var samePointComparision: Int = 0
    var isPairRank: Int = 0
    var pairRequirement: Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0  : self.eval_holecard,
            1  : self.eval_onepair,
            2  : self.eval_ninepointfive,
            3  : self.eval_kingpair,
            4  : self.eval_red8PlusBlackJoker(cards:),
            5: self.eval_red8PlusRedJoker(cards:),
            6: self.eval_black8PlusBlackJoker(cards:),
            7: self.eval_black8PlusRedJoker(cards:)
            
        ]
    }
    
    func evalHand(cards: [Card], redJokerValueRange: Int, blackJokerRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, isPairSameRank: Int, pairRequirement: Int)->Int{
        var cards = cards
        cards.sort(by: {card1, card2 in return card1.rank > card2.rank})
        self.samePointComparision = samePointComparision
        self.isPairRank = isPairSameRank
        self.pairRequirement = pairRequirement
        
        
        
        let num1 = NinePointFiveCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        let num2 = NinePointFiveCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        print("手牌 \(GameManager.cardLabelDic[cards[0].cardIndex])  \(GameManager.cardLabelDic[cards[1].cardIndex]) rank \(num1.rank) \(num2.rank) point \(num1.point) \(num2.point) suit \(num1.suit) \(num2.suit)")
        
        var score = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let rank = self.ruleDict[ruleIndex]!([num1, num2])
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 8)) | rank
                print("牌型 \(ruleIndex) rank \(score)")

                break
            }
        }
        
        return score
    }
    
    func eval_black8PlusRedJoker(cards: [NinePointFiveCard]) -> Int {
        if (cards[0].rank == 15 && cards[1].rank == 8 && self.blackRedJudger(card: cards[1]) == 1){
            return 1
        }
        return 0
    }
    
    func eval_black8PlusBlackJoker(cards: [NinePointFiveCard]) -> Int{
        if (cards[0].rank == 14 && cards[1].rank == 8 && self.blackRedJudger(card: cards[1]) == 1){
            return 1
        }
        return 0
    }
    
    func eval_red8PlusRedJoker(cards: [NinePointFiveCard]) -> Int {
        if (cards[0].rank == 15 && cards[1].rank == 8 && self.blackRedJudger(card: cards[1]) == 0){
            return 1
        }
        return 0
    }
    
    func eval_red8PlusBlackJoker(cards: [NinePointFiveCard]) -> Int{
        if (cards[0].rank == 14 && cards[1].rank == 8 && self.blackRedJudger(card: cards[1]) == 0){
            return 1
        }
        return 0
    }
    
    func eval_kingpair(_ cards: [NinePointFiveCard]) -> Int {
        var rank = 0
        if cards[0].rank > 13 && cards[1].rank > 13{
            rank = 1
        }
        return rank
    }
    
    func eval_ninepointfive(_ cards: [NinePointFiveCard]) -> Int {
        var rank = 0
        if ((cards[0].point + cards[1].point) % 20 == 19){
            rank = 1
        }
        return rank
    }
    
    func eval_onepair(_ cards: [NinePointFiveCard]) -> Int {
        let rank = 0
        if self.pairRequirement == 0 {
            if cards[0].rank == cards[1].rank {
                if self.isPairRank == 0{
                    return cards[0].rank
                } else if self.isPairRank == 1 {
                    return 1
                }
                
            }
        } else if self.pairRequirement == 1 {
            if cards[0].rank == cards[1].rank && self.blackRedJudger(card: cards[0]) == self.blackRedJudger(card: cards[1]){
                
                if self.isPairRank == 0 {
                    return cards[0].rank
                } else {
                    return 1
                }
            }
        }
        return rank
    }
    
    func eval_holecard(cards: [NinePointFiveCard]) -> Int {
        var rank = 0
        
        rank = cards[0].point + cards[1].point
        rank = rank % 20
        if self.samePointComparision == 1{
            //两红
            if self.blackRedJudger(card: cards[0]) == self.blackRedJudger(card: cards[1]) && self.blackRedJudger(card: cards[0]) == 0{
                return (rank + 1) << 2 | 2
            //混色
            } else if self.blackRedJudger(card: cards[0]) != self.blackRedJudger(card: cards[1]){
                return (rank + 1) << 2 | 1
            //两黑
            } else if self.blackRedJudger(card: cards[0]) == self.blackRedJudger(card: cards[1]) && self.blackRedJudger(card: cards[0]) == 1{
                return (rank + 1) << 2
            }
            
        }
        
        return rank + 1
    }
    
    func blackRedJudger(card: NinePointFiveCard) -> Int{
        //黑色
        if self.suitRules.firstIndex(of: card.suit) == 0 || self.suitRules.firstIndex(of: card.suit) == 2 {
            return 1
        //红色
        } else {
            return 0
        }
    }
    
    class NinePointFiveCard{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int){
            let rule = GameManager.gameRules[6] as! NinePointFiveGameRule
            //Rank Initialization
            self.rank = card.rank
            //suit Initialization
            self.suit = card.suit[0]
            //Point Initialization
            
            if card.rank == 15 {
                self.point =  Int(rule.redJokerValueRange[redJokerValueRange]!)!
            }
            else if card.rank == 14 {
                self.point = Int(rule.blackJokerValueRange[blackJokerValueRange]!)!
            }
            else if card.rank == 13 {
                self.point = Int(rule.KValueRange[KValueRange]!)!
            }
            else if card.rank == 12 {
                self.point = Int(rule.QValueRange[QValueRange]!)!
            }
            else if card.rank == 11 {
                self.point = Int(rule.JValueRange[JValueRange]!)!
            } else {
                self.point = card.rank * 2
            }
            
        }
    }

}

