
import Foundation
//import Python
//import PythonKit

//小九

class TinyNineGameRule : Rule{
    let handNum :[Int] = [2]
    let redJokerValueRange:[Int:String] = [
        0: "1",
        1: "6"
    ]
    let blackJokerValueRange:[Int: String] = [
        0: "1",
        1: "3"
    ]
    let samePointComparision:[Int: String] = [
        0:"同点比最大的牌",
        1:"同点一样大"
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.setting = [
            0: "标准小九",
            1: "湖南小九[255]",
            2: "自定义小九"
        ]
        
        self.rankRules = [2:"对王，对A，A加王",
                          1:"对子",
                          0:"点数"]
        self.ruleInfo = [
            0:"""
    一人发两张牌，一共四十张牌1-10
    对子最大，如果不是对子比较两张牌加起来除以十的余数，如果一样则一样大
    """, 1:"""
扑克张数:54张 不分花色
1) 对王=对A=A+王一样大>对K>.....>对2
2)9点>8点....0点最小
3)王为1点，K为3点,Q为2点，J为1点。同点比最大牌。
4) 最大的牌从大到小，王
>A>K>Q>J>10>9>8>7>6>5>4>3>2

""",
     2:"请自定义你的规则"
        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]    }
}



class TinyNineGame{
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
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
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
    //6 samePointComparision
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let rule  = GameManager.gameRules[3] as! TinyNineGameRule
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let redJokerValueRange = args[5]
        let blackJokerValueRange = args[6]
        let samePointComparision = args[7]
        
        
        var maxRank = 0
        var allPlayCards: [Player] = []
        var community = [Card]()
        var returnPlayerInfos: [GameReturnPlayerInfo] = []
        if deck.count < TinyNineGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
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
        
        //存入手牌和公牌
        for i in 0..<playerNum{
            returnPlayerInfos[i].PlayerCards = allPlayCards[i].playerCard
            returnPlayerInfos[i].communityCard = community
        }
        
        for i in 0..<playerNum {
            (allPlayCards[i].evaluateFlag, allPlayCards[i].cardType, allPlayCards[i].isPair) = TinyNineGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerValueRange: blackJokerValueRange, samePointComparision: samePointComparision)
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
        
        if leftCards.count < self.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus) {
            leftCards = []
        }
        
        return (returnPlayerInfos, leftCards)
    }
}

class TinyNineGameHandEvaluator{
    
    var rankRules: [Int]
    var suitRules: [Int]
    var redJokerValueRange = 0
    var blackJokerValueRange = 0
    var samePointComparision = 0
    var rankRulesDic:[Int:([Card]) -> (Bool, Int, String, Int)] = [:]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [0:self.PointsCalculator,
                             1:self.isPair,
                             2:self.isPairKingPairAKingPlusA
        ]
        
        
    }
    
    func evalHand(cards: [Card], redJokerValueRange: Int, blackJokerValueRange: Int, samePointComparision: Int)->(Int, String, Int){
        self.redJokerValueRange = redJokerValueRange
        self.blackJokerValueRange = blackJokerValueRange
        self.samePointComparision = samePointComparision
        var score = 0
        
        //打印手牌
        print("手牌 \(GameManager.cardLabelDic[cards[0].cardIndex])  \(GameManager.cardLabelDic[cards[1].cardIndex])")
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (flag, rank, cardType, isPair) = self.rankRulesDic[ruleIndex]!(cards)
            i -= 1
            if flag == false{
                continue
            } else {
                score = (1 << (i + 10)) | rank
                print("牌型 \(ruleIndex) 分数 \(score)")
                return (score, cardType, isPair)
            }
        }

        return (score, "", 0)
    }
    
    func isPairKingPairAKingPlusA(cards: [Card]) -> (Bool, Int, String, Int){
        if cards[0].rank > 13 && cards[1].rank > 13 {
            return (true, 1, "对王", 1)
        }
        if cards[0].rank > 13 && cards[1].rank == 1 {
            return (true, 1, "王加A", 0)
        }
        if cards[0].rank == 1 && cards[1].rank > 13 {
            return (true, 1, "王加A", 0)
        }
        if cards[0].rank == 1 && cards[1].rank == 1{
            return (true, 1, "对A", 1)
        }
        
        return (false, 0, "", 0)
        
    }
    
    func isPair(cards: [Card]) -> (Bool, Int, String, Int){
        if cards[0].rank == cards[1].rank {
            let cardType: String = "对" + GameManager.CardNumberReportDic[cards[0].rank]!
            return (true, cards[0].rank, cardType, 1)
        }
        return (false, 0, "", 0)
    }
    
    func PointsCalculator(cards: [Card]) -> (Bool, Int, String, Int){
        let num1 = self.CardPointConvertor(card: cards[0])
        let num2 = self.CardPointConvertor(card: cards[1])
        let points = (num1 + num2) % 10
        let cardType: String = String(points) + "点"
        if self.samePointComparision == 0{
            let rank = RankForMaxCard(cards: cards)
            return (true, points << 6 | rank, cardType, 0)
        } else if self.samePointComparision == 1{
            return (true, points << 6 | 1, cardType, 0)
        }
        return (false, 0, "", 0)
    }
    
    func RankForMaxCard(cards: [Card]) -> Int{
        var rank = 0
        let rank1 = CardRankConvertor(card: cards[0]) << 2 | cards[0].suit[0]
        let rank2 = CardRankConvertor(card: cards[1]) << 2 | cards[1].suit[0]
        if rank1 >= rank2 {
            rank = rank1
        } else {
            rank = rank2
        }
        
        return rank
        
    }
    
    func CardRankConvertor(card: Card) -> Int{
        if card.rank <= 13 && card.rank != 1{
            return card.rank - 1
        }
        if card.rank == 1{
            return 13
        }
        return card.rank
    }
    
    
    func CardPointConvertor(card: Card) -> Int {
        if card.rank == 14 {
            if self.blackJokerValueRange == 0{
                return 1
            } else if self.blackJokerValueRange == 1{
                return 3
            }
        }
        if card.rank == 15 {
            if self.redJokerValueRange == 0{
                return 1
            } else if self.redJokerValueRange == 1{
                return 6
            }
        }
        
        return card.rank
    }
    
    
    
    
}
