import Foundation
//import Python
//import PythonKit

//二八杠

class TwoEightGangGameRule : Rule{
    let samePointComparision:[Int:String] = [
        0:"同点比最大牌",
        1:"同点比最大牌，最大牌相同时红红>黑红>黑黑，同点同色庄大",
    ]
    
    let isCompareSuit:[Int:String] = [
        0:"否",
        1:"是"
    ]
    
    let KValueRange:[Int:String] = [
        0:"0",
        1:"3"
    ]
    
    let QValueRange:[Int:String] = [
        0:"2"
    ]
    let JValueRange:[Int:String] = [
        0:"1"
    ]
    let pointComparision:[Int:String] = [
        0:"9点最大，0点最小",
        1:"10点最大，1点最小"
    ]

        
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            0:"点数",
            1:"2+8",
            2:"对子",
        ]
        self.setting = [
            0: "二八杠对子大",
            1: "二八杠28比对子大",
            2: "二八分黑红",
            3: "二八最大对k次大",
            4: "二八杠10点大",
            5: "江苏52张二八"
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:40张 1到10
    1) 对10>对 9>对8>....对A
    2）2+8>10+9>8+1>7+2>.....0点
    3)2+8大于9点，同点比最大牌
    4)最大牌从大到小，
    10>9>8>7>6>5>4>3>2>1
    """,
            1:"""
    扑克张数:40张 1到10
    1) 28>对10>对9>对8>....>对A
    2) 10+9>8+1>7+2>.....0点
    3) 2和8最大，同点比最大牌
    4) 最大牌从大到小，10>9>8>7>6>5>4>3>2>1
    """,
            2:"""
    扑克张数:40张分花色
    1) 用1到10的牌
    2>对红 10>对混 10>对黑 10>对红9>...对黑A，两个红的大于1黑1红大于两黑
    3)红2+红8>红2+黑8=黑2+红8>黑2+黑8>红10+红9>红8+红A.....>0点最小
    4)同点时两个红的大于1黑1红大于两黑，同点同色庄大
    """,
            3:"""
    扑克张数:40张 1到9 4个K
    1) 28>对K>对9>对8>....>对A
    2) 9点>8点>7点>.....0点
    3) 2和8最大，K算0点，同点同对庄赢
    """,
            4:"""
    扑克张数:40张 1到10
    1) 对10>对9>对8>....对A
    2)2+8>1+9>3+7>4+6>.....1点(10点最大，1点最小)
    3)同点比最大牌
    4) 最大牌从大到小，
    10>9>8>7>6>5>4>3>2>1
    """,
            5:"""
    KK最大...AA最小，K算3点、Q算2点、 J算1点，28最大，0点最小，同点比单张大小!
    """
        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]
    }
    
}


class TwoEightGangGame{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum: [Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 2 > 36)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex(setting:Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 1:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 2:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 3:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 4:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 5:
            result = Array(0...51)
            break
        default:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
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
    //3 samePointComparision
    //4 isCompareSuit
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 pointComparision
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int], [Int]) {
        let dealType = args[0]
        let diyDealType = args[1]
        let playerNum = args[2]
        let samePointComparision = args[3]
        let isCompareSuit = args[4]
        let KValueRange = args[5]
        let QValueRange = args[6]
        let JValueRange = args[7]
        let pointComparision = args[8]
        
        
        var maxRank = 0
        var winners: [Int] = []
        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < TwoEightGangGame.getMinCardNum(playerNum: playerNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            return ([],[])
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
            allPlayCards[i].evaluateFlag = TwoEightGangGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, samePointComparision: samePointComparision, isCompareSuit: isCompareSuit, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, pointComparision: pointComparision)
        }
        
        var resultList = [ResultStruct]()
        for i in 0..<playerNum {
            let rank = allPlayCards[i].evaluateFlag
            resultList.append(ResultStruct(playerID: i, rank: rank))
        }
        
        let sortedResultList =  resultList.sorted(by: {$0.rank > $1.rank })
        for result in sortedResultList {
            winners.append(result.playerID)
        }
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        
        if leftCards.count < TwoEightGangGame.getMinCardNum(playerNum: playerNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        
        print("winners \(winners)")
        return (winners, leftCards)
    }
}

class TwoEightGangGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var samePointComparision = 0
    var isCompareSuit = 0
    var KValueRange = 0
    var QValueRange = 0
    var JValueRange = 0
    var pointComparision = 0
    var rankRulesDic:[Int: ([Card]) -> Int] = [:]
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [
            0:self.eval_Points,
            1:self.eval_is28,
            2:self.eval_isPair
        ]
    }
    
    func evalHand(cards: [Card], samePointComparision: Int, isCompareSuit: Int, KValueRange:Int, QValueRange:Int, JValueRange:Int, pointComparision: Int)->Int{
        
        self.samePointComparision = samePointComparision
        self.isCompareSuit = isCompareSuit
        self.KValueRange = KValueRange
        self.QValueRange = QValueRange
        self.JValueRange = JValueRange
        self.pointComparision = pointComparision
        var cards = cards
        cards.sort(by: { card1, card2 in
            return Card.calScore(card: card1) > Card.calScore(card: card2)
        })
        var score = 0
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let rank = self.rankRulesDic[ruleIndex]!(cards)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 10)) | rank
                return score
            }
        }
        
//        let num1 = cards[0].rank
//        let num2 = cards[1].rank
//
//        if num1 == num2 {
//            score = num1 + 100
//        } else if (num1 == 2 && num2 == 8) || (num1 == 8 && num2 == 2) {
//            score = 100
//        } else {
//            score = (num1 + num2) % 10
//        }
        
        return score
    }
    
    func eval_isPair(cards: [Card]) -> Int{
        if cards[0].rank == cards[1].rank {
            if self.samePointComparision == 1{
                return cards[0].rank << 2 | (self.blackRedJudger(card: cards[0]) + self.blackRedJudger(card: cards[1]))
            } else {
                return cards[0].rank
            }
        }
        return 0
    }
    
    func eval_is28(cards:[Card]) -> Int {
        if cards[0].rank == 8 && cards[1].rank == 2{
            if self.samePointComparision == 1 {
                return self.blackRedJudger(card: cards[0]) + self.blackRedJudger(card: cards[1]) + 1
            } else {
                return 1
            }
        }
        return 0
    }
    
    func eval_Points(cards: [Card]) -> Int{
        var num1 = self.PointsConvertor(card: cards[0]) % 10
        var num2 = self.PointsConvertor(card: cards[1]) % 10
        //0 最大 1 最小
        if self.pointComparision == 1 {
            num1 = (num1 + 10 - 1) % 10
            num2 = (num2 + 10 - 1) % 10
        }
        
        if self.samePointComparision == 0 {
            return num1 << 6 | Card.calScore(card: cards[0])
        } else {
            return num1 << 8 | Card.calScore(card: cards[0]) | (self.blackRedJudger(card: cards[0]) + self.blackRedJudger(card: cards[1]))
        }
    }
    
    func blackRedJudger(card: Card) -> Int{
        //红
        if card.suit[0] == 1 || card.suit[0] == 3 {
            return 1
        //黑
        } else{
            return 0
            
        }
    }
    func PointsConvertor(card: Card) -> Int{
        let rule = GameManager.gameRules[5] as! TwoEightGangGameRule
        if card.rank == 13 {
            return Int(rule.KValueRange[self.KValueRange]!)!
        }
        if card.rank == 12 {
            return Int(rule.QValueRange[self.QValueRange]!)!
        }
        if card.rank == 11 {
            return Int(rule.JValueRange[self.JValueRange]!)!
        }
        
        return card.rank
    }
}
