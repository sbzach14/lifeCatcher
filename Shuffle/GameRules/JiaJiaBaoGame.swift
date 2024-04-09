
import Foundation
//import Python
//import PythonKit

//九点半

class JiaJiaBaoGameRule : Rule{
    
    let samePointComparision: [Int: String] = [
        0:"同点比最大牌",
        1:"同点庄家大"
    ]
    
    let CardRankList: [Int:String] = [
        0:"王>红A>红K....红2>黑 A>黑K>....黑2最小",
        1:"王>A>K>...2"
    ]
    
    let redJokerValueRange: [Int:String] = [
        0:"1"
    ]
    let blackJokerValueRange: [Int:String] = [
        0:"1"
    ]
    let KValueRange: [Int:String] = [
        0:"3",
        1:"1"
    ]
    let QValueRange: [Int: String] = [
        0:"2",
        1:"1"
    ]
    let JValueRange: [Int: String] = [
        0:"1"
    ]
    let handNum: [Int: String] = [
        0:"2",
        1:"4"
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            0:"点数",
            1:"黑对子",
            2:"红对子",
            3:"混队子",
            4:"对王",
            5:"对子"
        ]
        self.setting = [
            0: "通用54张佳佳宝[401]",
            1: "通用54张佳佳宝，比四张（todo）[402]",
            2: "通用四张，9点对子算点数（todo）",
            3: "通用四张，54张佳佳宝1（todo）",
            4: "自定义佳佳宝",
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:54张 分花色
    1) 对王最大>对红A>对红K...对红2>对黑A>对黑K>....>对黑2
    2)9点>8点>....0点最小
    3) 王为1点，K为3点,Q为2点，J为1点。
    4) 最大牌从大到小:王>红A>红K....红2>黑 A>黑K>....黑2最小
    """, 
            1:"""
    和通用佳佳宝规则一样, 发四张比两轮，比前两张和后两张
    """,
            2:"""
    扑克张数:54 52不分花色
    1)9点最大0点最小，对子算点数
    2) J/Q/K王算1点，同点庄大
    """,
            3:"""
    54张佳佳宝，不分花色
    对王最大>对A>对K...对2
    9点>8点>....0点最小
    3)王为1点，K为3点,Q为2点，J为1点。
    """,
            
            4:"""
    自定义你的规则
    """,

        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class JiaJiaBaoGame{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
    }
    
    static func legalCheck(playerNum: Int, handNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * handNum > 54)
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
            result = Array(0...51) + [53,54]
        case 2:
            result = Array(0...51) + [53,54]
        case 3:
            result = Array(0...51) + [53,54]
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
    //3 samePointComparision
    //4 CardRankList
    //5 redJokerValueRange
    //6 blackJokerValueRange
    //7 KValueRange
    //8 QValueRange
    //9 JValueRange
    //10 handNum
    //11 isCompareSuit

    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let rule = GameManager.gameRules[8] as! JiaJiaBaoGameRule
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let samePointComparision = args[5]
        let CardRankList = args[6]
        let redJokerValueRange = args[7]
        let blackJokerValueRange = args[8]
        let KValueRange = args[9]
        let QValueRange = args[10]
        let JValueRange = args[11]
        let isCompareSuit = args[12]
        

        
        var maxRank = 0

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
        
        if handNum == 2{
            
        }
        
        
        

        for i in 0..<playerNum {
            allPlayCards[i].evaluateFlag = JiaJiaBaoGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerRange: blackJokerValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,samePointComparision: samePointComparision, cardRankList: CardRankList, isCompareSuit: isCompareSuit)
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
        if leftCards.count < JiaJiaBaoGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        return (returnPlayerInfos, leftCards)
    }
}

class JiaJiaBaoGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([JiaJiaBaoCard]) -> Int] = [:]
    var samePointComparision: Int = 0

    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0: eval_Points(cards:),
            1: eval_IsBlackPair(cards:),
            2: eval_IsRedPair(cards:),
            3: eval_IsMixPair(cards:),
            4: eval_IsPairJoker(cards:)
        ]
    }
    
    func evalHand(cards: [Card], redJokerValueRange: Int, blackJokerRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, cardRankList: Int, isCompareSuit: Int)->Int{
        var cards = cards
        self.samePointComparision = samePointComparision
        
        
        
        
        let num1 = JiaJiaBaoCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange,CardRankList: cardRankList, isCompareSuit: isCompareSuit)
        
        let num2 = JiaJiaBaoCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, CardRankList: cardRankList, isCompareSuit: isCompareSuit)
        
        var numList = [num1, num2]
        numList = numList.sorted(by: {$0.rank > $1.rank})
        
        print("手牌 \(GameManager.cardLabelDic[numList[0].cardIndex])  \(GameManager.cardLabelDic[numList[1].cardIndex]) rank \(numList[0].rank) \(numList[1].rank) point \(numList[0].point) \(numList[1].point) suit \(numList[0].suit) \(numList[1].suit)")
        
        var score = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let rank = self.ruleDict[ruleIndex]!(numList)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 12)) | rank
                print("牌型 \(ruleIndex) rank \(score)")
                break
            }
        }
        
        return score
    }
    
    func eval_IsPairJoker(cards: [JiaJiaBaoCard]) -> Int {
        if cards[0].rank == 28 && cards[1].rank == 28 {
            return 1
        }
        return 0
    }
    func eval_IsRedPair(cards: [JiaJiaBaoCard]) -> Int {
        if cards[0].rank == cards[1].rank && cards[0].suit == 1{
            return cards[0].rank
        }
        return 0
    }
    func eval_IsBlackPair(cards: [JiaJiaBaoCard]) -> Int {
        if cards[0].rank == cards[1].rank && cards[0].suit == 0{
            return cards[0].rank
        }
        return 0
    } 
    func eval_IsMixPair(cards: [JiaJiaBaoCard]) -> Int {
        if cards[0].rank == cards[1].rank + 13 && cards[0].suit != cards[1].suit{
            return cards[0].rank
        }
        return 0
    }
    func eval_Points(cards: [JiaJiaBaoCard]) -> Int {
        let point = (cards[0].point + cards[1].point) % 10
        switch self.samePointComparision {
        case 0:
            return point << 6 | cards[0].rank
            break
        default:
            return point
            break
        }
    }
    
    
    class JiaJiaBaoCard{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var cardIndex: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, CardRankList: Int, isCompareSuit: Int){
            let rule = GameManager.gameRules[8] as! JiaJiaBaoGameRule
            //cardIndex Initialization
            self.cardIndex = card.cardIndex
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
            //rank Initialization
            if CardRankList == 0{
                //王 28
                if card.rank == 15 || card.rank == 14 {
                    self.rank = 28
                // A 14 27
                } else if card.rank == 1 {
                    self.rank = 14 + self.suit * 13
                //黑色 2 - 13
                } else if self.suit == 0{
                    self.rank = card.rank
                //红色 15 - 26
                } else if self.suit == 1{
                    self.rank = card.rank + 13
                }
                
            }
        }
    }

}

