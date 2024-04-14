
import Foundation
//import Python
//import PythonKit

class TenPointFiveGameRule : Rule{
    let handNum :[Int] = [2]
    let redJokerValueRange:[Int:String] = [
        0: "1",
    ]
    let blackJokerValueRange:[Int: String] = [
        0: "1",
    ]
    let KValueRange: [Int: String] = [
        0:"1",

    ]
    let QValueRange: [Int: String] = [
        0:"1",
    ]
    let JValueRange: [Int: String] = [
        0:"1",
    ]
    let samePointComparision:[Int: String] = [
        0:"同点庄大",
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    let pointComparision: [Int: String] = [
        0:"10点最大，1点最小"
    ]
    
    let cardRankRule: [Int: String] = [
        0:"王>K>Q>J,其他一样大"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.setting = [
            0: "十点半[270]",
            1: "十点半[271]"
        ]
        
        self.rankRules = [
            1:"10点半",
            0:"点数"
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:54张
    1) 10+王>10+K>10+Q>10+J>...1点最小
    2)大小王和KQJ都算半点，同点庄家大
    3)同点王>K>Q>J其他同点庄大
    """,
            1:"""
扑克张数:54张
1)10+王>10+K>10+Q>10+J>...1点最小
2)大小王和KQJ都算半点，同点庄家大
3) 同点王>K>Q>J其他同点庄大
""",
     ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]    }
}



class TenPointFiveGame{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        print("Rank rules \(rankRules)")
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 2 > 40)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting{
        case 0:
            result = Array(0...51) + [53,54]
            break
        case 1:
            result = Array(0...51) + [53,54]
            break
        default:
            result = Array(0...51) + [53,54]
            break
            
        }
        return result
    }
    
    static func getMinCardNum(playerNum: Int,handNum: Int, communityNum: Int,dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
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
    //3 handNum
    //4 redJokerValueRange
    //5 blackJokerValueRange
    //6 KValueRange
    //7 QValueRange
    //8 JValueRange
    //9 samePointComparision
    //10 isCompareSuit
    //11 pointComparision
    //12 cardRankRule
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let rule  = GameManager.gameRules[14] as! TenPointFiveGameRule
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let redJokerValueRange = args[5]
        let blackJokerValueRange = args[6]
        let KValueRange = args[7]
        let QValueRange = args[8]
        let JValueRange = args[9]
        let samePointComparision = args[10]
        let isCompareSuit = args[11]
        let pointComparision = args[12]
        let cardRankRule = args[13]
        
        
        var maxRank = 0
        var returnPlayerInfos: [GameReturnPlayerInfo] = []

        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < TenPointFiveGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([],[])
        }
        
        for _ in 0..<playerNum {
            allPlayCards.append(Player())
        }
        
        
        var deck = deck
        // 发牌
        if dealNum == 0{
            for _ in 0..<handNum{
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
            (allPlayCards[i].evaluateFlag,allPlayCards[i].cardType, allPlayCards[i].isPair) = TenPointFiveGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, samePointComparision: samePointComparision,pointComparision: pointComparision, cardRankRule: cardRankRule)
        }
        
        for playerID in 0..<allPlayCards.count {
            var currentReturnPlayerInfo = GameReturnPlayerInfo()
            currentReturnPlayerInfo.playerID = playerID
            currentReturnPlayerInfo.playerRank = allPlayCards[playerID].evaluateFlag
            currentReturnPlayerInfo.playerCardsType = allPlayCards[playerID].cardType
            currentReturnPlayerInfo.isPair = allPlayCards[playerID].isPair
            currentReturnPlayerInfo.PlayerCards = allPlayCards[playerID].playerCard
            currentReturnPlayerInfo.communityCard = community
            returnPlayerInfos.append(currentReturnPlayerInfo)
        }
        
        //从大到小排序
        returnPlayerInfos = returnPlayerInfos.sorted(by: {$0.playerRank > $1.playerRank})
        
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        
        if leftCards.count < self.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus) {
            leftCards = []
        }
        
        return (returnPlayerInfos, leftCards)
    }
}

class TenPointFiveGameHandEvaluator{
    
    var rankRules: [Int]
    var suitRules: [Int]
    var samePointComparision = 0
    var pointComparision = 0
    var rankRulesDic:[Int:([TenPointFiveCard]) -> (Bool, Int, String, Int)] = [:]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [0:self.eval_Points,
                             1:self.eval_TenPointFive,
        ]
        
        
    }
    
    func evalHand(cards: [Card], redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, pointComparision: Int, cardRankRule: Int)->(Int, String, Int){
        
        self.samePointComparision = samePointComparision
        var score = 0
        var maxCardType: String = ""
        var maxIsPair: Int = 0
        
        //打印手牌
        print("手牌 \(GameManager.cardLabelDic[cards[0].cardIndex])  \(GameManager.cardLabelDic[cards[1].cardIndex])")
        
        var num1 = TenPointFiveCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, cardRankRule: cardRankRule)
        var num2 = TenPointFiveCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, cardRankRule: cardRankRule)
        
        var inputCards = [num1, num2]
        inputCards = inputCards.sorted(by: {$0.rank >= $1.rank})
        
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (flag, rank, cardType, isPair) = self.rankRulesDic[ruleIndex]!(inputCards)
            i -= 1
            if flag == false{
                continue
            } else {
                score = (1 << (i + 10)) | rank
                maxCardType = cardType
                maxIsPair = isPair
                print("牌型 \(ruleIndex) 分数 \(score)")
                return (score, maxCardType, maxIsPair)
            }
        }

        return (score, maxCardType, maxIsPair)
    }
    
    func eval_TenPointFive(cards: [TenPointFiveCard]) -> (Bool, Int, String, Int) {
        if cards[0].point + cards[1].point == 21 {
            return(true, cards[0].rank, "10点半", 0)
        }
        return (false, 0, "", 0)
    }
    
    
    func eval_Points(cards: [TenPointFiveCard]) -> (Bool, Int, String, Int){
        if pointComparision == 0{
            var point = (cards[0].point + cards[1].point) % 20
            
            if point == 0 {
                point = 20
            }
            
            var cardType: String = String(point / 2) + "点"
            
            if point % 2 == 1{
                cardType += "半"
            }
            return (true, point << 4 | cards[0].rank, cardType, 0)
        }
        return (false, 0, "", 0)
    }
    
    class TenPointFiveCard{
        var rank: Int = 0
        var originalRank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var cardIndex: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, cardRankRule: Int) {
            let rule = GameManager.gameRules[14] as! TenPointFiveGameRule
            self.cardIndex = card.cardIndex
            //initial suit
            self.suit = card.suit[0]
            //initial rank
            self.originalRank = card.rank
            if cardRankRule == 0 {
                if card.rank < 11 {
                    self.rank = 1
                
                } else if card.rank == 15 {
                    self.rank = 14
                } else {
                    self.rank = card.rank
                }
            } else {
                self.rank = card.rank

            }
            
            //initial point
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
            }else {
                self.point = card.rank * 2
            }
        }
        
    }
    
    
}
