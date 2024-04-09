
import Foundation


class ChickenBattleGameRule : Rule{
    
    //此处填入需要的参数，因为rulesettingview没有了，主要作用是注释
    let redJokerValueRange:[Int:String] = [
        0:"0"
    ]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            2: "对子",
            1: "单张",
            0: "四张点数"
        ]
        self.setting = [
            0: "4张比单张[410]",
        ]
        self.ruleInfo = [
            0:"""
    52张牌，每人4张，分为2组牌
    1.最大 对A > 对K > ... 对2
    2.单张 A最大 2最小
    3.2组牌总点数最大为最大
    """,
        ]
        
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class ChickenBattleGame{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
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
    
    //加入每个规则需要的用牌
    static func getAllCardIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...51)
            break
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
    //3 handNum
    //4 communityNum
    //5 redJokerValueRange
    //6 blackJokerValueRange
    //7 KValueRange
    //8 QValueRange
    //9 JValueRange
    //10 pointComparision
    //11 samePointComparision
    //10 cardRankRule


    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let redJokerValueRange = args[5]


        
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
        
        
        for i in 0..<playerNum {
            (allPlayCards[i].evaluateFlag,allPlayCards[i].cardType, allPlayCards[i].isPair) = ChickenBattleGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange)
        }
        //
        
        
        //这里后面都不用改，最后按照牌的大小（evaluateflag）排序返回
        
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
        if leftCards.count < ChickenBattleGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        return (returnPlayerInfos, leftCards)
    }
}

class ChickenBattleGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([ChickenBattleCard]) -> (Int, String, Int)] = [:]
    
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
    
    //传入需要的参数
    func evalHand(cards: [Card],redJokerValueRange: Int)->(Int, String, Int){
        var cards = cards
        
        var numList:[ChickenBattleCard] = []
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
                score = (1 << (i + 5)) | rank
                maxCardType = cardType
                maxIsPair = isPair
                print("牌型 \(ruleIndex) rank \(score) i \(i)")

                break
            }
        }
        
        return (score, maxCardType, maxIsPair)
    }
    //牌型函数
    // return (rank, 牌型, 是否是对子（十三水比鸡没有就全部0））
    //下面是例子
    func eval_isPair(cards:[ChickenBattleCard]) -> (Int, String, Int){
        if cards[0].rank == cards[1].rank{
            let cardType: String = "对" + GameManager.CardNumberReportDic[cards[0].originalRank]!
            return (cards[0].rank, cardType, 1)
        }
        return (0, "", 0)
    }
    
    func eval_isHighCard(cards: [ChickenBattleCard]) -> (Int, String, Int) {
        let cardType: String = "高牌" + GameManager.CardNumberReportDic[cards[0].originalRank]!
        return (cards[0].rank, cardType, 0)
    }
    
    func eval_isPoint(cards:[ChickenBattleCard]) -> (Int, String, Int) {
        let point = cards.reduce(0){$0 + $1.point} % 10
        let cardType: String = String(point) + "点"
        return (point + 1, cardType, 0)
    }
    
    class ChickenBattleCard{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var cardIndex: Int = 0
        var originalRank: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, cardRankRule: Int){
            let rule = GameManager.gameRules[15] as! ChickenBattleGameRule
            
            //....定义牌的大小点数花色
        }
    }

}

