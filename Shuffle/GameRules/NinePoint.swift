
import Foundation
//import Python
//import PythonKit

//九点半

class NinePointGameRule : Rule{
    
    let redJokerValueRange: [Int: String] = [
        0: "1",
    ]
    
    let blackJokerValueRange: [Int: String] = [
        0:"1",
    ]
    
    let KValueRange: [Int: String] = [
        0:"3",
        1:"1",
        2:"0"
    ]
    
    let QValueRange: [Int: String] = [
        0:"2",
        1:"1",
        2:"0"
    ]
    let JValueRange: [Int: String] = [
        0:"1",
        1:"0",
    ]
    
    let samePointComparision: [Int: String] = [
        0: "同点同对庄赢",
        1: "同点比最大牌",
        2:"同点比花色，两红>一红一黑>两黑"
    ]
    let isCompareSuit: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let handNum: [Int] = [2,4]
    let cardRankRule:[Int: String] = [
        0:"K>Q>J..>2>A",
        1:"A>K>Q>J..>3>2"
    ]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            0:"点数",
            1:"对子",
            2:"对王",
            3:"对K",
        ]
        self.setting = [
            0:"福建54张9点[221]",
            1:"通用四张-四张9点大[4..]",
            2:"通用四张-54张9点混...",
            3:"52张9点[226]",
            4:"9点昆[222]",
            5:"东兴九点[223]",
            6:"潍坊9点 J/Q/K王算1[2...",
            7:"9点对K大[225]",
            8:"52张9点最大[252]",
            9:"54张9点[228]",
            10:"通用四张9点 J/Q/K..."
        ]
        self.ruleInfo = [
            0:"""
扑克张数 54张 不分花色
1）对王最大>对A>对K>...>对2
2）9点>8点>...>0点
3）王算1点K算3点Q算2点J算1点，同点同对庄家大
""",
            1:"""
扑克张数:52张不分花色
1)10+9=K+8=Q+8=J+8>10+8....>0点最小
2)9点最大0点最小，对子算点数。
3) K/Q/J算1点，同点庄大
4)四张自由组合比两次，两次点数大于其他家才算最大家
""",
            2:"""
扑克牌数:54张
1:对王最大>对A>对K.....>对2
2.9点>8点…...0点最小
3王JkQ为1点
4，最大的牌从大到小王
>A>k>Q>j>10>9>8>7>6>5>4>3>2
""",
            3:"""
用牌52张
对k最大对a最小
9点最大, 0点最小
JQK算1点
""",
            4:"""
扑克张数:52张不分花色
1)10+9=K+9=Q+9=J+9>10+8....>0点
2)9点最大0点最小，对子算点数。
3) K/Q/J算0点，同点庄大
""",
            5:"""
扑克张数:52张不分花色
1)对A最大>对A>对K....>对2
2)>A+8>K+6>Q+7>J+8>..>0点最小
3)K算3点，Q算2点,J算1点。同点比最大张牌，同牌同点庄家大
4)牌从大到小，A>K>Q>J>10>9>8>7>6>5>4>3>2
""",
            6:"""
扑克张数：54 52 不分花色
1）9点最大0点最小，对子算点数
2）J/Q/K 王算1点，同点庄大
""",
            7:"""
对K最大，同点庄大
""",
            8:"""
用牌52张
1: 9点最大，0点最小，对子算点数
2: KQJ算1点，同点庄赢
""",
            9:"""
用牌54张
9点最大，0点最小，对子算点数
J=1，Q=2，K=3 王=0
同点比花色
两红>一红一黑>两黑
""",
            10:"""
扑克张数:54 52张不分花色
1)9点最大0点最小，对子算点数。
3) K/Q/J，王算1点，同点庄大
4)四张自由组合比两次，两次点数大于其他家才算最大家
""",
            
            

        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class NinePointGame{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
    }
    
    static func legalCheck(playerNum: Int, handNum: Int) -> String{
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
            result = Array(0...51)
            break
        case 4:
            result = Array(0...51)
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
            result = Array(0...51)
            break
        case 9:
            result = Array(0...51) + [53,54]
        case 10:
            result = Array(0...51) + [53,54]
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
    //9 isCompareSuit
    //10 handNum
    //11 cardRankRule
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let rule = GameManager.gameRules[10] as! NinePointGameRule
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let redJokerValueRange = args[3]
        let blackJokerValueRange = args[4]
        let KValueRange = args[5]
        let QValueRange = args[6]
        let JValueRange = args[7]
        let samePointComparision = args[8]
        let isCompareSuit = args[9]
        let handNum = rule.handNum[args[10]]
        let cardRankRule = args[11]
        
        var maxRank = 0
        var returnPlayerInfos: [GameReturnPlayerInfo] = []

        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < self.getMinCardNum(playerNum: playerNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([], [])
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
            (allPlayCards[i].evaluateFlag, allPlayCards[i].cardType, allPlayCards[i].isPair) = NinePointGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerRange: blackJokerValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,samePointComparision: samePointComparision,isCompareSuit: isCompareSuit,cardRankRule: cardRankRule)
        }
        
        
        var resultList = [ResultStruct]()
        for i in 0..<playerNum {
            let rank = allPlayCards[i].evaluateFlag
            resultList.append(ResultStruct(playerID: i, rank: rank))
        }
        
        let sortedResultList =  resultList.sorted(by: {$0.rank > $1.rank })
        for result in sortedResultList {
            var currentReturnPlayerInfo = GameReturnPlayerInfo()
            currentReturnPlayerInfo.playerID = result.playerID
            currentReturnPlayerInfo.playerRank = result.rank
            currentReturnPlayerInfo.playerCardsType = allPlayCards[result.playerID].cardType
            currentReturnPlayerInfo.isPair = allPlayCards[result.playerID].isPair
            returnPlayerInfos.append(currentReturnPlayerInfo)
        }
        
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        if leftCards.count < NinePointGame.getMinCardNum(playerNum: playerNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        return (returnPlayerInfos, leftCards)
    }
}

class NinePointGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([NinePointCard]) -> (Int, String, Int)] = [:]
    var samePointComparision: Int = 0
    var cardRankRule: Int = 0
    

    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0:self.eval_Point(cards:),
            1:self.eval_isPair(cards:),
            2:self.eval_isPairJoker(cards:),
            3:self.eval_isPairK(cards:)
        ]
    }
    
    func evalHand(cards: [Card], redJokerValueRange: Int, blackJokerRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, isCompareSuit: Int, cardRankRule: Int)->(Int, String, Int){
        var cards = cards
        cards.sort(by: {card1, card2 in return card1.rank > card2.rank})
        self.samePointComparision = samePointComparision
        self.cardRankRule = cardRankRule
        let num1 = NinePointCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange,isCompareSuit: isCompareSuit,cardRankRule: cardRankRule)
        
        let num2 = NinePointCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange,isCompareSuit: isCompareSuit,cardRankRule: cardRankRule)
        var nums = [num1,num2]
        nums.sort(by: {num1, num2 in return num1.rank > num2.rank})
        print("手牌 \(GameManager.cardLabelDic[cards[0].cardIndex])  \(GameManager.cardLabelDic[cards[1].cardIndex]) rank \(num1.rank) \(num2.rank) point \(num1.point) \(num2.point) suit \(num1.suit) \(num2.suit)")
        
        var score = 0
        var maxCardType: String = ""
        var maxIsPair: Int = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rank, cardType, isPair) = self.ruleDict[ruleIndex]!(nums)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 8)) | rank
                maxCardType = cardType
                maxIsPair = isPair
                print("牌型 \(ruleIndex) rank \(score)")

                break
            }
        }
        
        return (score, maxCardType, maxIsPair)
    }
    func eval_isPairK(cards:[NinePointCard]) -> (Int, String, Int){
        if cards[0].rank == 13 && cards[1].rank == 13{
            return (1, "对K", 1)
        }
        return (0, "", 0)
    }
    func eval_isPairJoker(cards:[NinePointCard]) -> (Int, String, Int){
        if cards[0].originalRank > 13 && cards[1].originalRank > 13 {
            return (1, "对王", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isPair(cards: [NinePointCard]) -> (Int, String, Int){
        if cards[0].rank == cards[1].rank{
            let cardType: String = "对" + GameManager.CardNumberReportDic[cards[0].originalRank]!
            return (cards[0].rank, cardType, 1)
        }
        return (0, "", 0)
    }
    
    func eval_Point(cards: [NinePointCard]) -> (Int, String, Int){
        var num1 = cards[0].point
        var num2 = cards[1].point
        var cardType: String = String((num1 + num2) % 10) + "点"
        if self.samePointComparision == 0{
            return ((num1 + num2) % 10, cardType, 0)
        } else if self.samePointComparision == 1{
            return (((num1 + num2) % 10) << 4 | cards[0].rank, cardType, 0)
        } else if self.samePointComparision == 2{
            return (((num1 + num2) % 10) << 2 | (self.blackRedJudger(card: cards[0]) + self.blackRedJudger(card: cards[1])), cardType, 0)
        }
        return (0, cardType, 0)
    }
    
    func blackRedJudger(card: NinePointCard) -> Int{
        //红
        if self.suitRules.firstIndex(of: card.suit) == 1 || self.suitRules.firstIndex(of: card.suit) == 3 {
            return 1
        //黑
        } else{
            return 0
            
        }
    }
    
    
    class NinePointCard{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
                    var originalRank: Int = 0
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, isCompareSuit: Int, cardRankRule: Int){
            let rule = GameManager.gameRules[10] as! NinePointGameRule
            //Rank Initialization
            self.originalRank = card.rank
            if cardRankRule == 0{
                self.rank = card.rank
            }
            else if cardRankRule == 1{
                if card.rank > 13 {
                    self.rank = card.rank + 1
                }
                if card.rank == 1{
                    self.rank = 14
                }
            }
            //suit Initialization
            if isCompareSuit == 0{
                self.suit = 0
            } else {
                self.suit = card.suit[0]
            }
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
                self.point = card.rank
            }
            
        }
    }

}

