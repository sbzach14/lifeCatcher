
import Foundation
//import Python
//import PythonKit

//小九

class TinyNineGameRule : Rule{
    let handNum :[Int] = [2, 4]
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
            0: "标准",
            1: "湖南小九",
            2: "32张牌九(未完成，4张牌如何比较和发牌)",
            3: "自定义"
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
            2:"""
        32张大牌九 每人四张牌、头两张牌尾两张牌
        大小王/红Q两个/红2两个/黑J两个/黑9两个/黑5两个/4个10/4个8/4个7/4个6/4个4.共32张大小排名

        1》对子:两个王>对红Q>红Q+黑9>对红2>对红8>对红4>对红10>对红6>对黑4>对黑J>对黑10 >对红7>对黑6>对黑9>对黑8>对黑7>对黑
        5>Q和8>2和8对子要分红黑 一红一黑不算对子只算点数
        2》点数:9点最大0点最小。J为1点Q为2点小王算3点大王算6点同点时比最大的牌，
        同点同牌庄家大最大的牌从大到小:红 Q>红2>红8>红4>红10>红6>黑4>黑J>黑10>红7>黑6>黑9>黑8>黑7>黑5>大王>小王
""", 3:"请自定义你的规则"
        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]    }
}



class TinyNineGame{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int]) {
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
    
    static func getAllCardIndex() -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...9{//a-10
                result.append(rank + i * 13)
            }
        }
        return result
    }
    
    static func getMinCardNum(playerNum: Int) -> Int{
        return playerNum * 2
    }
    
    //args
    //0 dealType
    //1 diyDealType
    //2 playerNum
    //3 handNum
    //4 redJokerValueRange
    //5 blackJokerValueRange
    //6 samePointComparision
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int]) {
        let rule  = GameManager.gameRules[3] as! TinyNineGameRule
        let dealType = args[0]
        let diyDealType = args[1]
        let playerNum = args[2]
        let handNum = rule.handNum[args[3]]
        let redJokerValueRange = args[4]
        let blackJokerValueRange = args[5]
        let samePointComparision = args[6]
        
        
        var maxRank = 0
        var winners: [Int] = []
        var allPlayCards: [Player] = []
        var community = [Card]()
        
        for _ in 0..<playerNum {
            allPlayCards.append(Player())
        }
        
        
        var deck = deck
        // 发牌
        if dealType == 0 || dealType == 1{
            for _ in 0..<handNum {
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
        }
        else {
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
            allPlayCards[i].evaluateFlag = TinyNineGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerValueRange: blackJokerValueRange, samePointComparision: samePointComparision)
        }
        
        for i in 0..<playerNum {
            let rank = allPlayCards[i].evaluateFlag
            if rank > maxRank {
                maxRank = rank
                winners.removeAll()
                winners.append(i)
            } else if rank == maxRank {
                winners.append(i)
            }
        }
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        
        return (winners, leftCards)
    }
}

class TinyNineGameHandEvaluator{
    
    var rankRules: [Int]
    var suitRules: [Int]
    var redJokerValueRange = 0
    var blackJokerValueRange = 0
    var samePointComparision = 0
    var rankRulesDic:[Int:([Card]) -> (Bool, Int)] = [:]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [0:self.PointsCalculator,
                             1:self.isPair,
                             2:self.isPairKingPairAKingPlusA
        ]
        
        
    }
    
    func evalHand(cards: [Card], redJokerValueRange: Int, blackJokerValueRange: Int, samePointComparision: Int)->Int{
        self.redJokerValueRange = redJokerValueRange
        self.blackJokerValueRange = blackJokerValueRange
        self.samePointComparision = samePointComparision
        var score = 0
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (flag, rank) = self.rankRulesDic[ruleIndex]!(cards)
            i -= 1
            if flag == false{
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
//        } else {
//            score = (num1 + num2) % 10
//        }
        return score
    }
    
    func isPairKingPairAKingPlusA(cards: [Card]) -> (Bool, Int){
        if cards[0].rank > 13 && cards[1].rank > 13 {
            return (true, 0)
        }
        if cards[0].rank > 13 && cards[1].rank == 1 {
            return (true, 0)
        }
        if cards[0].rank == 1 && cards[1].rank > 13 {
            return (true, 0)
        }
        if cards[0].rank == 1 && cards[1].rank == 1{
            return (true, 0)
        }
        
        return (false, 0)
        
    }
    
    func isPair(cards: [Card]) -> (Bool, Int){
        if cards[0].rank == cards[1].rank {
            return (true, cards[0].rank)
        }
        return (false, 0)
    }
    
    func PointsCalculator(cards: [Card]) -> (Bool, Int){
        let num1 = self.CardPointConvertor(card: cards[0])
        let num2 = self.CardPointConvertor(card: cards[1])
        let points = (num1 + num2) % 10
        if self.samePointComparision == 0{
            let rank = RankForMaxCard(cards: cards)
            return (true, points << 6 | rank)
        } else if self.samePointComparision == 1{
            return (true, 0)
        }
        return (false, 0)
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
