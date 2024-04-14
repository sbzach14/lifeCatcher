
import Foundation
//import Python
//import PythonKit

//小九

class ThreeCardPointGameRule : Rule{
    let handNum :[Int] = [2]
    let redJokerValueRange:[Int:String] = [
        0: "20",
        1: "1",
        2: "2",
        3: "0"
    ]
    let blackJokerValueRange:[Int: String] = [
        0: "20",
        1: "1",
        2: "2",
        3: "0"
    ]
    let KValueRange: [Int: String] = [
        0:"6",
        1:"1",
        2:"2",
        3:"0"
    ]
    let QValueRange: [Int: String] = [
        0:"4",
        1:"1",
        2:"2",
        3:"0"
    ]
    let JValueRange: [Int: String] = [
        0:"2",
        1:"1",
        2:"0"
    ]
    let samePointComparision:[Int: String] = [
        0:"同点庄大",
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    let pointComparision: [Int: String] = [
        0:"9点最大，0点最小",
        1:"10点最大，1点最小"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.setting = [
            0: "三张9点[330]",
            1: "三张9点半[331]",
            2: "三张10点半[332]",
            3: "三张9点[333]",
            4: "三张9点[334]",
            5: "三张10点半[335]"
        ]
        
        self.rankRules = [2:"9点半",
                          1:"10点半",
                          0:"点数"]
        self.ruleInfo = [
            0:"""
    扑克张数:54张，52张
    1.3张牌点数相加.9点最大
    2.王=10点、K=3点、Q=2点、J=1点
    """, 1:"""
扑克张数:54张，52张
1.3张牌点数相加.9点半最大,0点最小
2.王JQK=半点，同点庄大
""",
     2:"""
扑克张数:54张，52张
1.3张牌点数相加，10点半最大，0点最小。王JQK=半点
2.同点庄大
""",
            3:"""
扑克张数:54张，52张
1.3张牌点数相加，9点最大。0点最小。王=1点，J=1点，Q=1点，K=1点
""",
            4:"""
扑克张数:54张，52张
1.3张牌点数相加，9点最大。0点最小。王=0点，J=0点，Q=0点，K=0点
""",
            5:"""
扑克张数:54张，52张
1.3张牌点数相加，10点半最大，10点次大， 1点最小。王JQK=半点
2.同点庄大
"""
    
            ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]    }
}



class ThreeCardPointGame{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        print("Rank rules \(rankRules)")
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 3 > 40)
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
    //3 handNum
    //4 redJokerValueRange
    //5 blackJokerValueRange
    //6 KValueRange
    //7 QValueRange
    //8 JValueRange
    //9 samePointComparision
    //10 isCompareSuit
    //11 pointComparision
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {

        let rule  = GameManager.gameRules[13] as! ThreeCardPointGameRule

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
        
        
        var maxRank = 0
        var returnPlayerInfos: [GameReturnPlayerInfo] = []

        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < ThreeCardPointGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
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
            (allPlayCards[i].evaluateFlag,allPlayCards[i].cardType, allPlayCards[i].isPair) = ThreeCardPointGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, samePointComparision: samePointComparision,pointComparision: pointComparision)
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

class ThreeCardPointGameHandEvaluator{
    
    var rankRules: [Int]
    var suitRules: [Int]
    var samePointComparision = 0
    var pointComparision = 0
    var rankRulesDic:[Int:([ThreeCardPointCard]) -> (Bool, Int, String, Int)] = [:]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [0:self.eval_Points,
                             1:self.eval_TenPointFive,
                             2:self.eval_NinePointFive
        ]
        
        
    }
    
    func evalHand(cards: [Card], redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, pointComparision: Int)->(Int, String, Int){
        
        self.samePointComparision = samePointComparision
        var score = 0
        var maxCardType: String = ""
        var maxIsPair: Int = 0
        
        var num1 = ThreeCardPointCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        var num2 = ThreeCardPointCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        var num3 = ThreeCardPointCard(card: cards[2], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (flag, rank, cardType, isPair) = self.rankRulesDic[ruleIndex]!([num1, num2, num3])
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
    
    func eval_NinePointFive(cards: [ThreeCardPointCard]) -> (Bool, Int, String, Int) {
        if (cards[0].point + cards[1].point + cards[2].point) % 20 == 19 {
            return (true, 1, "9点半", 0)
        }
        return (false, 0, "", 0)
    }
    
    func eval_TenPointFive(cards: [ThreeCardPointCard]) -> (Bool, Int, String, Int) {
        if cards[0].point + cards[1].point + cards[2].point == 21 {
            return(true, 1, "10点半", 0)
        }
        return (false, 0, "", 0)
    }
    
    func eval_Points(cards: [ThreeCardPointCard]) -> (Bool, Int, String, Int){
        //9点最大
        var cardType: String = ""
        let originpoint = cards[0].point + cards[1].point + cards[2].point
        cardType = String(originpoint % 20 / 2) + "点"
        if originpoint % 2 == 1{
            cardType += "半"
        }
        if self.pointComparision == 0{
            return(true, (cards[0].point + cards[1].point + cards[2].point) % 20, cardType, 0)
            
        //10点最大
        } else if pointComparision == 1{
            return (true, (cards[0].point + cards[1].point + cards[2].point - 1) % 20, cardType, 0)
        }
        return (false, 0, "", 0)
    }
    
    class ThreeCardPointCard{
        var rank: Int = 0
        var originalRank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var cardIndex: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int) {
            let rule = GameManager.gameRules[13] as! ThreeCardPointGameRule
            self.cardIndex = card.cardIndex
            //initial suit
            self.suit = card.suit[0]
            //initial rank
            self.originalRank = card.rank
            self.rank = card.rank
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
                self.point = card.rank
            }
        }
        
    }
    
    
}
