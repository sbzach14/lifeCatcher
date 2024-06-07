
import Foundation


class TCGameRule : Rule{
    
    let redJokerValueRange:[Int:String] = [
        0:"1"
    ]
    let blackJokerValueRange: [Int: String] = [
        0:"1"
    ]
    let KValueRange:[Int:String] = [
        0:"3",
    ]
    let QValueRange:[Int:String] = [
        0:"2",
    ]
    let JValueRange:[Int:String] = [
        0:"1",
    ]
    let pointComparision:[Int: String] = [
        0:"9点最大，0点最小",
    ]
    let samePointComparision:[Int: String] = [
        0:"同点一样大",
        1:"同点比最大牌"
    ]
    let cardRankRule:[Int: String] = [
        0:"A最大，2最小",
        1:"A>王>K>Q>J>...>2"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            2: "对子",
            1: "单张",
            0: "点数"
        ]
        self.setting = [
            0: "A59[250]",
            1: "合合[251]",
            2: "梭哈[258]",
        ]
        self.ruleInfo = [
            0:"""
    AA KK ... 22
    A5 K6...
    A4
    """,
            
            1:"""
    扑克张数:54张不分花色
    1)对A最大>对王>对K>.....>对22)9点>8点....0点最小
    3)王为1点，K为3点,Q为2点，J为1点。同点比最大牌。
    4)最大的牌从大到小，A>王
    >K>Q>J>10>9>8>7>6>5>4>3>2
    """,
            2:"""
对A最大对2最小
单张A最大2最小不分花色
"""

        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class TCGame{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
        let deck = initDeck(initialCards: inputCards, suitRules: suitRules)
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
    
    static func getAllCardIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...51)
            break
        case 1:
            result = Array(0...51) + [53,54]
            break
        case 2:
            result = Array(0...51)
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
    //3 redJokerValueRange
    //4 blackJokerValueRange
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 pointComparision
    //9 samePointComparision
    //10 cardRankRule


    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
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
        let pointComparision = args[10]
        let samePointComparision = args[11]
        let cardRankRule = args[12]

        
        var returnPlayerInfos: [GameReturnPlayerInfo] = []

        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < self.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
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
            (allPlayCards[i].evaluateFlag,allPlayCards[i].cardType, allPlayCards[i].isPair) = TCGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerValueRange: blackJokerValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,pointComparision: pointComparision,samePointComparision: samePointComparision,cardRankRule: cardRankRule)
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
        if leftCards.count < TCGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        return (returnPlayerInfos, leftCards)
    }
}

class TCGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([TCCard]) -> (Int, String, Int)] = [:]
    var pointComparision:Int = 0
    var samePointComparision: Int = 0
    var cardRankRule: Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0:self.eval_isPoint(cards:),
            1:self.eval_isHighCard(cards:),
            2:self.eval_isPair(cards:),

        ]
    }
    
    func evalHand(cards: [Card],redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, pointComparision: Int, samePointComparision: Int, cardRankRule: Int)->(Int, String, Int){
        var cards = cards
        self.pointComparision = pointComparision
        self.samePointComparision = samePointComparision
        
        let num1 = TCCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, cardRankRule: cardRankRule)
        
        let num2 = TCCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange,cardRankRule: cardRankRule)
        
        var numList = [num1, num2]
        numList = numList.sorted(by: {$0.rank > $1.rank})
        
        var score = 0
        var maxCardType: String = ""
        var maxIsPair: Int = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rank, cardType, isPair) = self.ruleDict[ruleIndex]!(numList)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 8)) | rank
                maxCardType = cardType
                maxIsPair = isPair
                
                break
            }
        }
        
        return (score, maxCardType, maxIsPair)
    }
    
    func eval_isPair(cards:[TCCard]) -> (Int, String, Int){
        if cards[0].rank == cards[1].rank{
            let cardType: String = "对" + ClassifierSettingArgs.CardNumberReportDic[cards[0].originalRank]!
            return (cards[0].rank, cardType, 1)
        } else if cards[0].originalRank > 13 && cards[1].originalRank > 13{
            return (cards[0].rank, "对王", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isHighCard(cards: [TCCard]) -> (Int, String, Int){
        let cardType: String = "单牌" + ClassifierSettingArgs.CardNumberReportDic[cards[0].originalRank]!
        return (cards[0].rank, cardType, 0)
    }
    
    func eval_isPoint(cards:[TCCard]) -> (Int, String, Int) {
        let point = cards.reduce(0){$0 + $1.point} % 10
        let cardType: String = String(point) + "点"
        if self.samePointComparision == 0{
            return (point + 1, cardType, 0)
        } else if self.samePointComparision == 1{
            return (point + 1 << 4 | cards[0].rank, cardType, 0)

        } else {
            return (0, "", 0)
        }
    }
    
    class TCCard{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var cardIndex: Int = 0
        var originalRank: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, cardRankRule: Int){
            let rule = ClassifierSettingArgs.targetSetting[12] as! TCGameRule
            self.cardIndex = card.cardIndex
            //Rank Initialization
            self.originalRank = card.rank
            if cardRankRule == 0 {
                if card.rank == 1{
                    self.rank = 13
                } else if card.rank < 14 {
                    self.rank = card.rank - 1
                } else {
                    self.rank = card.rank
                }
            } else if cardRankRule == 1{
                if card.rank == 1{
                    self.rank = 15
                } else {
                    self.rank = card.rank - 1
                }
            } else {
                self.rank = card.rank
            }
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
                self.point = card.rank
            }
        }
    }

}

