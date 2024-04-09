
import Foundation
//import Python
//import PythonKit

//宝子

class BaoziGameRule : Rule{
    
    let KValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"3"
    ]
    let QValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"2",
        3:"0.5"
    ]
    let JValueRange:[Int:String] = [
        0:"0",
        1:"1",
    ]
    let JokerValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"5",
        3:"6"
    ]
    let samePointComparision:[Int:String] = [
        0:"同点同对庄家大",
        1:"同点比最大牌",
        2:"同点比最大牌，同牌同点庄家大",
        3:"同点比最大牌，最大牌相同时红红>黑红>黑黑"
    ]
    let pointComparision :[Int:String] = [
        0:"9点最大，0点最小",
        1:"0点最大，1点最小"
    ]
    
    let cardRank :[Int: String] = [
        0:"K最大",
        1:"A最大",
        2:"K，Q，J，10一样大, 都为最大"
    ]
    let pairRank :[Int:String] = [
        0:"对子按照牌大小分大小",
        1:"对子不分大小"
    ]
    let AValueRange :[Int:String] = [
        0: "1",
        1: "4"
    ]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        
        self.setting = [
            0: "宝子2张9点大[201]",
            1: "宝子2张10点大[202]",
            2: "宝子P对大[203]",
            3: "52张宝子[204]",
            4: "52张上海宝子[205]",
            5: "54张宝子12[206]",
            6: "唐山54张宝子[207]",
            7: "40张宝子分花色[208]",
            8: "54张宝子13[209]",
            9: "54张比宝子14[210]",
            10: "52张新疆宝子[211]",
            11: "宝子J",
            12: "宝子Q",
            13: "宝子K",
            14: "江苏52张二八",
            15: "52张宝子对子算点数[216]",
            16: "54张宝子15[213]",
            17: "宝子2张9点大[212]",
            18: "自定义宝子"
        ]
        self.rankRules = [6:"同色对子",
                          5:"对子",
                          4:"对10",
                          3:"对5",
                          2:"对王",
                          1:"王+A",
                          0:"点数",]
        self.ruleInfo = [
            0:"""
    扑克张数:40张 不分花色
    1) 用1到10的牌
    2) 对10最大>对 9>...>对1
    3) 9点>8点>....0点最小
    4)同点同对庄家大
    """,
            1:"""
    扑克张数:40张 不分花色
    1) 用1到10的牌
    2)对10最大>对9>...>对1
    3)10点>9点>....1点最小
    4)同点同对庄家大
    """,
            2:"""
    扑克张数:40张 不分花色
    1) 用1到9和四个Q的牌
    2) 对Q最大>对9>...>对1
    3) 9+Q>9点>....0点最小
    4)Q算半点，同点同对庄家大
    """,
            3:"""
    扑克张数:52张 不分花色
    1) 对K对Q对J对10一样大>对9>对8>...>对1
    2)K+9/Q+9+J+9+10+9一样大>8+1>7+2...>0点最小
    3)K/Q/J算10点，同点比单张大小，最大的牌从大到小K=Q=J=10>9>8....>1
    """,
            4:"""
    扑克张数:52张 不分花色
    1) 对A最大>对K>对Q>....对2
    2) 9点>8点>....0点
    3) K算3点,Q算2点，J算1点，同点同对庄大
    """,
            5:"""
    扑克张数:54张 不分花色
    1) 对10最大对5次大
    2)10点>9点>8点>....>1点
    3)大小王/J/Q/K算1点，对10最大，对5次大，其他的不算对子。
    """,
            6:"""
    扑克张数:54张 不分花色
    1) 对王最大>对A>对K>....>对2
    2) 王+8>A+8>K+6>Q+7>J+8>..>0点
    3)王算1点，K算3点，Q算2点,J算1点。同点比最大张牌，同牌同点庄家大
    4) 最大的牌从大到小，王
    >A>K>Q>J>10>9>8>7>6>5>4>3>2
    """,
            7:"""
    扑克张数:40张分 色
    1) 用1到10的牌
    2>对红 10>对混 10>对黑 10>对红9>...对黑A，两个红的大于1黑1红大于两黑
    3)红10+红9>红10+黑 9=黑10+红9..>黑两张为0点最小
    4) 9点最大，同点时两个红的大于1黑1红大于两黑，同点同色庄大
    """,

            8:"""
    扑克张数:54张 不分花色
    1) 对王最大>王+A>对A>对K....>对2
    2) 王+8>A+8>K+6>Q+7>J+8>..>0点最小
    3) 王+A算对子，王算1点，K算3点， Q算2点,J算1点。同点比最大张牌，同牌同点庄家大
    4) 最大的牌从大到小，王>A>K>Q>J>10>9>8>7>6>5>4>3>2
    """,
            9:"""
    扑克张数:54张 不分花色
    1) 对子不分大小
    2>9点最大，0点最小
    4) 王/K/Q/J算1点，同点同对庄赢
    """,
            10:"""
    扑克张数:52 不分花色
    1) 对K>对Q>...对1
    2) 9点>8点>...0点
    K=3 Q=2 J=1
    3)同点同对庄家大
    """,
            11:"""
    1-10 四个J
    JJ最大...AA最小，J算0点，10点最大...1点最小，同点庄家大。
    """,
            12:"""
    1-10 四个Q
    QQ最大...AA最小，Q算0点。10点最大...1点最小，同点庄家大!
    """,
            13:"""
    1-10 四个K
    KK最大...AA最小，K算0点，10点最大...1点最小，同点庄家大!
    """,
            14:"""
    KK最大...AA最小，K算3点、Q算2点、 J算1点，九点最大，0点最小，同点比单张大小!
    """,
            15:"""
            扑克张数 52张不分花色
            1. K Q J 算0点
            2. 9点最大,
            3. 0点最小, 同点庄大
            4. 对子算点数
            """,
            16:"""
            扑克张数：54张，不分花色
            W=5，K=3，Q=2，J=1，A=4
            1）对子 WW > AA > KK > QQ...22
            2) 9点最大，0点最小，同点比最大牌不分花色，同点同最大牌庄家大，0点一样大，W>K>Q>J>.....2
            """,
            17:"""
            扑克张数：54张
            1）对王>对k>对Q>...对A，2张牌全黑或者全红才算对子，对黑>对红
            2）9点最大，0点最小，王=6点，K=3点，Q=2点，J=1点。
            3）同点比最大牌点数，点数一样比最大牌花色黑桃>红桃>梅花>方片，K最大A最小
            """,
            
            18:"""
    自定义你的规则
    """,
        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class BaoziGame{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
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
    
    static func getAllCardIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 1:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 2:
            result = Array(0...8) + Array(13...21) + Array(26...34) + Array(39...47) + [11,24,37,50]
            break
        case 3:
            result = Array(0...51)
            break
        case 4:
            result = Array(0...51)
            break
        case 5:
            result = Array(0...51) + [53,54]
            break
        case 6:
            result = Array(0...51) + [53,54]
            break
        case 7:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 8:
            result = Array(0...51) + [53,54]
            break
        case 9:
            result = Array(0...51) + [53,54]
            break
        case 10:
            result = Array(0...51)
            break
        case 11:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48) + [10,23,36,49]
            break
        case 12:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48) + [11,24,37,50]
            break
        case 13:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48) + [12,25,38,51]
            break
        case 14:
            result = Array(0...51)
            break
        case 15:
            result = Array(0...51)
            break
        case 16:
            result = Array(0...51) + [53,54]
            break
        case 17:
            result = Array(0...51) + [53,54]
            break
        
        default:
            result = Array(0...51) + [53,54]
            break
        }
        return result
    }
    
    static func getMinCardNum(playerNum: Int, handNum: Int, communityNum: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
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
    //3 KValueRange
    //4 QValueRange
    //5 JValueRange
    //6 JokerValueRange
    //7 samePointComparision
    //8 pointComparision
    //9 cardRank
    //10 pairRank
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let KValueRange = args[5]
        let QValueRange = args[6]
        let JValueRange = args[7]
        let JokerValueRange = args[8]
        let samePointComparision = args[9]
        let pointComparision = args[10]
        let cardRank = args[11]
        let pairRank = args[12]
        let AValueRange = args[13]
        
        var maxRank = 0
        var returnPlayerInfos: [GameReturnPlayerInfo] = []

        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < self.getMinCardNum(playerNum: playerNum, handNum: handNum, communityNum: communityNum, dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([], [])
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
        
        //存入手牌和公牌
        for i in 0..<playerNum{
            returnPlayerInfos[i].PlayerCards = allPlayCards[i].playerCard
            returnPlayerInfos[i].communityCard = community
        }
        
        
        for i in 0..<playerNum {
            (allPlayCards[i].evaluateFlag, allPlayCards[i].cardType, allPlayCards[i].isPair) = BaoziGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,JokerValueRange: JokerValueRange,samePointComparision: samePointComparision,pointComparision: pointComparision,cardRank: cardRank,pairRank: pairRank, AValueRange: AValueRange)
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
            //存入手牌和公牌
            currentReturnPlayerInfo.PlayerCards = allPlayCards[result.playerID].playerCard
            currentReturnPlayerInfo.communityCard = community
            returnPlayerInfos.append(currentReturnPlayerInfo)
           
        }
        
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        if leftCards.count < self.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            leftCards = []
        }
        
        return (returnPlayerInfos, leftCards)
    }
}

class BaoziGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var rankRulesDic: [Int: ([BaoziCard]) -> (Int, String, Int)] = [:]
    var samePointComparision: Int = 0
    var pointComparision: Int = 0
    var QValueRange: Int = 0
    var PairRank :Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [
            0:eval_Points(cards:),
            1:eval_isJokerPlusA(cards:),
            2:eval_isPairJoker(cards:),
            3:eval_isPairFive(cards:),
            4:eval_isPairTen(cards:),
            5:eval_isPair(cards:),
            6:eval_isSameColorPair(cards:)
        ]
        
    }
    
    func evalHand(cards: [Card], KValueRange: Int, QValueRange: Int, JValueRange: Int, JokerValueRange: Int, samePointComparision: Int, pointComparision: Int, cardRank: Int, pairRank: Int, AValueRange: Int)->(Int, String, Int){
        
        self.samePointComparision = samePointComparision
        self.pointComparision = pointComparision
        self.QValueRange = QValueRange
        self.PairRank = pairRank
        var score = 0
        let num1 = BaoziCard(card: cards[0], KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, JokerValueRange: JokerValueRange, cardRank: cardRank, AValueRange: AValueRange)
        let num2 = BaoziCard(card: cards[1], KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, JokerValueRange: JokerValueRange, cardRank: cardRank, AValueRange: AValueRange)
        print("手牌 \(GameManager.cardLabelDic[cards[0].cardIndex])  \(GameManager.cardLabelDic[cards[1].cardIndex]) rank \(num1.rank) \(num2.rank) point \(num1.point) \(num2.point) suit \(num1.suit) \(num2.suit)")
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (rank, cardType, isPair) = self.rankRulesDic[ruleIndex]!([num1, num2])
            i -= 1
            if rank == 0 {
                continue
            } else {
                score = (1<<(i + 12)) | rank
                print("牌型 \(ruleIndex) score \(score)")
                return (score, cardType, isPair)
            }
        }
        return (score, "", 0)
    }
    
    func eval_isSameColorPair(cards:[BaoziCard]) -> (Int, String, Int){
        if self.blackRedJudger(card: cards[0]) == self.blackRedJudger(card: cards[1]) && cards[0].originalRank == cards[1].originalRank {
            var colorRank = 1
            var cardType: String = "黑对"
            if self.blackRedJudger(card: cards[0]) == 1{
                cardType = "红对"
                colorRank = 0
            }
            
            cardType += String(cards[0].originalRank)
            return (cards[0].rank << 2 | colorRank, cardType, 1)
        }
        
        return (0, "", 0)
    }
    
    func eval_isPair(cards:[BaoziCard]) -> (Int, String, Int){
        if cards[0].originalRank == cards[1].originalRank {
            
            let cardType: String = "对" + String(cards[0].originalRank)
            
            if self.PairRank == 0 {
                if self.samePointComparision == 3{
                    return (cards[0].rank << 2 | (self.blackRedJudger(card: cards[0]) + self.blackRedJudger(card: cards[1])), cardType, 1)
                    
                } else {
                    return (cards[0].rank, cardType, 1)
                }
            } else {
                return (1, cardType, 1)
            }
        }
        return (0,"", 0)
        
    }
    func eval_isPairTen(cards:[BaoziCard]) -> (Int, String, Int) {
        if cards[0].originalRank == cards[1].originalRank && cards[0].originalRank == 10{
            return (1, "对十", 1)
        }
        return (0, "", 0)
    }
    func eval_isPairFive(cards:[BaoziCard]) -> (Int, String, Int){
        if cards[0].originalRank == cards[1].originalRank && cards[0].originalRank == 5 {
            return (1, "对五", 1)
        }
        return (0, "", 0)
        
    }
    func eval_isPairJoker(cards:[BaoziCard]) -> (Int, String, Int){
        if cards[0].originalRank > 13 && cards[1].originalRank > 13 {
            return (1, "对王", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isJokerPlusA(cards:[BaoziCard]) -> (Int, String, Int){
        if max(cards[0].originalRank, cards[1].originalRank) > 13 && min(cards[0].originalRank, cards[1].originalRank) == 1 {
            return (1, "王加A", 0)
        }
        return (0, "", 0)
    }
    func eval_Points(cards:[BaoziCard]) -> (Int, String, Int){
        var point = 0
        var mod = 0
        if self.QValueRange == 3 {
            mod = 20
            point = (cards[0].point + cards[1].point) % mod
        } else {
            mod = 10
            point = (cards[0].point + cards[1].point) % mod
        }
        
        var cardType: String = String(point) + "点"
        
        if self.pointComparision == 1 {
            point = (point + mod - 1) % mod
        }
        if self.samePointComparision == 0 {
            return (point + 1, cardType, 0)
        } else if self.samePointComparision == 1 {
            return (point << 4 | max(cards[0].rank, cards[1].rank) + 1, cardType, 0)
        } else if self.samePointComparision == 2 {
            return (point << 4 | max(cards[0].rank, cards[1].rank) + 1, cardType, 0)
        } else if self.samePointComparision == 3 {
            
            return (point << 6 | max(cards[0].rank, cards[1].rank) << 2 | (self.blackRedJudger(card: cards[0]) + self.blackRedJudger(card: cards[1])), cardType, 0)
        }
        return (0, "", 0)
    }
    
    func blackRedJudger(card: BaoziCard) -> Int{
        //红
        if self.suitRules.firstIndex(of: card.suit) == 1 || self.suitRules.firstIndex(of: card.suit) == 3 {
            return 1
        //黑
        } else{
            return 0
            
        }
    }
    
}

class BaoziCard{
    var originalRank:Int
    var rank:Int
    var point:Int
    var suit:Int
    
    init(card: Card, KValueRange:Int, QValueRange: Int, JValueRange: Int, JokerValueRange: Int, cardRank:Int, AValueRange: Int){
        //rank initialization
        let rule = GameManager.gameRules[7] as! BaoziGameRule
        if card.rank > 13{
            self.rank = card.rank + 1
        }
        else if card.rank == 1 && cardRank == 1{
            self.rank = 14
        }
        else if card.rank >= 10 && card.rank <= 13 && cardRank == 2 {
            self.rank = 10
        } else {
            self.rank = card.rank
        }
        
        //point initialization
        if card.rank == 11{
            self.point = Int(rule.JValueRange[JValueRange]!)!
        }
        else if card.rank == 12{
            if QValueRange < 3{
                self.point = Int(rule.QValueRange[QValueRange]!)!
            } else {
                self.point = 1
            }
        }
        else if card.rank == 13{
            self.point = Int(rule.KValueRange[KValueRange]!)!
        } else if card.rank > 13 {
            self.point = Int(rule.JokerValueRange[JokerValueRange]!)!
        } else if card.rank == 1{
            self.point = Int(rule.AValueRange[AValueRange]!)!
        }
        else{
            self.point = card.rank
        }
        
        //如果Q算半点大家全部*2
        if QValueRange == 3 && card.rank != 12 {
            self.point = self.point * 2
        }
        // suit initialization
        self.suit = card.suit[0]
        self.originalRank = card.rank
    }
}
