
import Foundation
//import Python
//import PythonKit

//三公

class ThreeMenGameRule : Rule{
    let pointComparision:[Int: String] = [
        0:"0最大，9次大，1最小",
        1:"9最大，0最小"
    ]
    let samePointComparision:[Int: String] = [
        0:"同点比公数，同公比最大牌，王, K...1",
        1:"同点比最大牌",
        2:"同点比公数，同公比最大牌，王，A，K...2",
        3:"同点一样大",
        4:"同点比公数，同公一样大"
    ]
    //算公数是A是否算公
    let isAAsMan:[Int: String] = [
        0:"否",
        1:"是"
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    let threeCardComparision: [Int:String] = [
        0:"KKK>QQQ>JJJ>...222>AAA",
        1:"AAA>KKK>QQQ...333>222",
        2:"333>AAA>KKK>QQQ...>222"
    ]
    let mixManComparision:[Int:String] = [
        0:"混公比最大牌",
        1:"混公一样大"
    ]
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            
            7:"任意三个公，都一样大",
            6:"任意对子+大王或小王+KKK+QQQ+JJJ",
            5:"大小王+任意牌",
            4: "三三",
            3: "三条",
            2: "三公",
            1: "混公",
            0: "散牌"
        ]
        
        self.setting = [
            0: "常规三公[310]",
            1:"三公3-0点大[311]",
            2:"三公2-3同大[312]",
            3:"三公4-3同大无混公[313]",
            4:"三公5-A大于K[314]",
            5:"三公8-单张比花色[315]",
            6:"三公9-3公一样大[316]",
            7:"三公10-333最大[317]",
            8:"三公12-AAA最大[318]",
            9:"三公13-10算公[319]",
            10:"三公7-单张比花色",
            11:"三公11-单张比花色",
            12:"自定义三公"
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:54张，52张，48张三公
    1)最大: 3个公组合:KKK>QQQ>JJJ>
    2)次大:三个混合公(任意JQK王)同是混公比最大牌
    3)无三公混公比点数(点数是指三张牌点数相加的总点数取个位数的值)，0最大，9次大，1最小 (K、Q、J、10为0点)
    4)无三公混公比点数，同点的情况下比公数，例如:双公9点>单公9点
    5)无三公混公比点数，同点同公数的情况下比最大牌。王最大K次大，1最小
    """,
            1:"""
    扑克张数:54张，52张，48张三公
    1) 最大: 3个公组合:KKK>QQQ>JJJ>
    2) 次大:三个混合公(任意JQK王)同是混公比最大牌
    3)无三公混公比点数(点数是指三张牌点数相加的总点数取个位数的值)，0最大，9次大，1最小 (K、Q、J、10为0点)
    4)无三公混公比点数，同点的情况下比公数，例如:双公9点>单公9点
    5)无三公混公比点数，同点同公数的情况下比最大牌。王最大K次大，1最小
    """,
            2:"""
    扑克张数:54张，52张，48张三公
    1) 最大: 三个公组合:
    KKK>QQQ>JJJ>3个10>3个9......>3个1.
    2) 次大:三个混合公(任意JQK王)同是混公比最大牌
    3)无三公混公比点数(点数是指三张牌点数相加的总点数取个位数的值)，9最大，0最小(K、Q、J、10为0点)
    4)无三公混公比点数，同点的情况下比公数，例如:双公9点>单公9点、
    5)无三公混公比点数，同点同公的情况下比最大牌，王最大K次大，1最小
    """,
            3:"""
    扑克张数:54张，52张，48张
    1)最大:3个公组合:KKK>QQQ>JJJ>3个10>3个9...>3个1
    2)无三公比点数(所谓点数是指三张牌点数相加的总点数取个位数的值)，9点最大，0点最小。(王，K，Q，J，10为0点)
    3)无三公同点的情况下比最大牌。王最大 K次大，1最小
    """,
            4:"""
    扑克张数:54张，52张，48张
    1) 最大: 3个公组台:KKK>QQQ >JJJ
    2) 次大:三个混合公(任意JQK王)同是混公比最大牌
    3)无三公混公比点数(点数是指三张牌点数相加的总点数取个位数的值)，9最大，0最小(王,K、Q、J、10为0点)
    4)无三公混公比点数，同点的情况下比公数，例如:双公9点>单公9点。A也算公，但是AKQ又不算混公)
    5)无三公混公比点数，同点同公数的情况下比最大牌。A最大K次大，2最小
    """,
            5:"""
    54张，52张，48张
    1)最大:三个混合公(任意JQK王)同是混公比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,方片>黑桃>红心>梅花3
    2)无混公比点数(所谓点数是指三张牌点数相加的总点数取个位数的值)，0点大，9点次大，1点最小。(王，K，Q， J，10为0点)
    3)无混公比点数，同点情况下比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,方片>黑桃>红心>梅花
    """,
            6:"""
    扑克张数:54张，52张，48张
    1)最大: 大小王+任意一张牌
    2)次大:3个公组合KKK=QQQ=JJJ=任意对子+大王(或小王)
    3)混公KKQ=KQJ=K()王......... ;
    4)无三公混公比点数9点大，0点小。
    """,
            7:"""
    扑克张数:52张
    1)三公3个相同的数字.
    333>AAA>KKK>QQQ>JJJ...>222
    2)混公3个不相同的JQK: JJQ JQK JKK等，同为混公比最大牌K>Q>J
    3)点数WKQJ算0点，其它算自然数9点最大，0点最小，同点双公>单公>无公，同点同公比。最大牌。K>Q>...>A
    """,
            8:"""
    扑克张数:36张
    I) AAA>999。。 >222
    2)点数0点最大,9点次大,1点最小,同点比最大牌.A>9>8...... >2
    3)花色方片>红心>梅花>黑桃
    """,
            9:"""
    52张
    1.最大:3个公(任意JQK10).KKK KQ10一样大
    2.9点最大，0点最小
    3.同点公数多的大
    4.同点同公数，一样大
    """,
            10:"""
    扑克张数:54张，52张，48张
    1) 最大:三个混合公(任意JQK王)同是混公比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,黑桃>红心>梅花>方片
    2) 无混公比点数(所谓点数是指三张牌点数相加的总点数取个位数的值)，0点大，9点次大，1点最小。(王，K，Q， J，10为0点)
    3)无混公比点数，同点情况下比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,黑桃>红心>梅花>方片
    """,
            11:"""
    扑克张数:54张，52张，48张
    1) 最大:三个混合公(任意JQK王)同是混公比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,方片>红心>梅花>黑桃
    2) 无混公比点数(所谓点数是指三张牌点数相加的总点数取个位数的值)，0点大，9点次大，1点最小。(王，K，Q， J，10为0点)
    3) 无混公比点数，同点情况下比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,方片>红心>梅花>黑桃
    """,
            12:"自定义你的规则"
        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class ThreeMenGame{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        print("Rank Rules \(rankRules)")
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards, winnerRanks) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards, winnerRanks)
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 3 > 52)
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
        case 6:
            result = Array(0...51) + [53,54]
            break
        case 7:
            result = Array(0...51)
            break
        case 8:
            result = Array(0...8) + Array(13...21) + Array(26...34) + Array(39...47)
            break
        case 9:
            result = Array(0...51)
            break
        case 10:
            result = Array(0...51) + [53,54]
            break
        case 11:
            result = Array(0...51) + [53,54]
            break
        default:
            result = Array(0...51) + [53,54]
            break
        }
        
        return result
    }
    
    static func getMinCardNum(playerNum: Int,dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
        if dealType == 0 || dealType == 1{
            return playerNum * 3
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
    //3 pointComparision
    //4 samePointComparision
    //5 isAAsMan
    //6 isCompareSuit
    //7 threeCardComparision
    //8 mixManComparision
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        let rule = GameManager.gameRules[4] as! ThreeMenGameRule
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let pointPointComparision = args[3]
        let samePointComparision = args[4]
        let isAAsMan = args[5]
        let isCompareSuit = args[6]
        let threeCardComparision = args[7]
        let mixManComparision = args[8]
        
        var maxRank = 0
        var winners: [Int] = []
        var winnerRanks: [Int] = []
        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < ThreeMenGame.getMinCardNum(playerNum: playerNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([], [],[])
        }
        
        for _ in 0..<playerNum {
            allPlayCards.append(Player())
        }
        
        
        var deck = deck
        // 发牌
        if dealNum == 0{
            for _ in 0..<3{
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
            allPlayCards[i].evaluateFlag = ThreeMenGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, pointComparision: pointPointComparision, samePointComparision: samePointComparision, isAAsMan: isAAsMan, isCompareSuit: isCompareSuit, threeCardComparision: threeCardComparision,mixManComparision: mixManComparision)
        }
        
        var resultList = [ResultStruct]()
        for i in 0..<playerNum {
            let rank = allPlayCards[i].evaluateFlag
            resultList.append(ResultStruct(playerID: i, rank: rank))
        }
        
        let sortedResultList =  resultList.sorted(by: {$0.rank > $1.rank })
        for result in sortedResultList {
            winners.append(result.playerID)
            winnerRanks.append(result.rank)
        }
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        
        if leftCards.count < ThreeMenGame.getMinCardNum(playerNum: playerNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus) {
            leftCards = []
        }
        
        print("winners \(winners)")
        return (winners, leftCards, winnerRanks)
    }
}

class ThreeMenGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var pointComparision = 0
    var samePointComparision = 0
    var isAAsMan = 0
    var isCompareSuit = 0
    var threeCardComparision = 0
    var mixManComparision = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
    }
    
    func evalHand(cards: [Card], pointComparision: Int, samePointComparision: Int, isAAsMan: Int, isCompareSuit: Int, threeCardComparision: Int, mixManComparision: Int)->Int{
        
        var cards = cards
        
        if isCompareSuit == 0{
            for i in 0..<cards.count{
                cards[i].suit[0] = 0
            }
        }
        
        print("手牌花色 \(cards[0].suit[0]) \(cards[1].suit[0]) \(cards[2].suit[0])")
        
        cards.sort(by: { card1, card2 in
            return (card1.rank<<2 | card1.suit[0]) > (card2.rank << 2 | card2.suit[0])
        })
        
    
        
        self.pointComparision = pointComparision
        self.samePointComparision = samePointComparision
        self.isAAsMan = isAAsMan
        self.isCompareSuit = isCompareSuit
        self.threeCardComparision = threeCardComparision
        self.mixManComparision = mixManComparision
        let score = calcHandInfoFlg(sortedCards: cards)
        print("score \(score)")
        return score
    }
    
    func calcHandInfoFlg(sortedCards: [Card]) -> Int {
        var rankResult = 0
        var ruleDict: [Int: ([Card]) -> Int] = [
            0  : self.eval_holecard,
            1  : self.eval_mixMan,
            2  : self.eval_threemen,
            3  : self.eval_threecard,
            4  : self.eval_threethree,
            5  : self.eval_JokerPlusAny,
            6  : self.eval_anyPairPlusJokerPlusThreeKQJ,
            7  : self.eval_anyThreeMan_allSameRank
        ]
        
        var handCardString = ""
        for card in sortedCards{
            handCardString += GameManager.cardLabelDic[card.cardIndex]!
        }
        
        print("手牌 \(handCardString)")
        
        for (index, ruleIndex) in rankRules.enumerated() {
            var rankFlag = 1 << (rankRules.count - index + 12)
            rankResult = ruleDict[ruleIndex]!(sortedCards)
            
            if rankResult != 0 {
                rankResult |= rankFlag
                print("牌型 \(ruleIndex) rank \(rankResult)")
                break
            }
        }

        print("rankResult \(rankResult)")
        return rankResult
    }
    func eval_anyThreeMan_allSameRank(cards: [Card]) -> Int{
        if cards[0].rank >= 10 && cards[1].rank >= 10 && cards[2].rank >= 10 {
            return 1
        }
        
        return 0
    }
    func eval_anyPairPlusJokerPlusThreeKQJ(cards: [Card]) -> Int{
        if (cards[0].rank == 15 || cards[0].rank == 14) && cards[1].rank == cards[2].rank {
            return 1
        } else if (cards[0].rank == cards[1].rank && cards[1].rank == cards[2].rank) && (cards[0].rank > 10 && cards[1].rank > 10 && cards[2].rank > 10){
            return 1
        }
        return 0
            
    }
    
    func eval_JokerPlusAny(cards: [Card]) -> Int{
        if cards[0].rank == 15 && cards[1].rank == 14{
            return 1
        }
        return 0
    }
    
    func eval_mixMan(cards: [Card]) -> Int {
        if cards[0].rank > 10 && cards[1].rank > 10 && cards[2].rank > 10 {
            if self.mixManComparision == 0{
                return cards[0].rank << 2 | cards[0].suit[0]
            } else if self.mixManComparision == 1{
                return 1
            }
        }
        return 0
    }
    
    func eval_threethree(_ cards: [Card]) -> Int {
        var rank = 0
        if cards[0].rank == 3 && cards[1].rank == 3 && cards[2].rank == 3{
            rank = 1
        }
        return rank
    }
    
    func eval_threecard(_ cards: [Card]) -> Int {
        var rank = 0
        if cards[0].rank == cards[1].rank && cards[0].rank == cards[2].rank{
            if self.threeCardComparision == 0 {
                return cards[0].rank
            } else if self.threeCardComparision == 1 {
                if cards[0].rank == 1{
                    return 13
                } else {
                    return cards[0].rank - 1
                }
            } else if self.threeCardComparision == 2 {
                if cards[0].rank == 3 {
                    return 13
                } else if cards[0].rank == 1 {
                    return 12
                } else {
                    return cards[0].rank - 2
                }
            }
        }
        return rank
    }
    
    func eval_threemen(_ cards: [Card]) -> Int {
        var rank = 0
        if cards[0].rank > 10 && cards[1].rank > 10 && cards[2].rank > 10 && cards[1].rank == cards[0].rank && cards[1].rank == cards[2].rank{
            rank = cards[0].rank << 2 | cards[0].suit[0]
        }
        return rank
    }
    
    func eval_holecard(cards: [Card]) -> Int {
        
        var sumRank = 0
        for i in 0..<3 {
            sumRank += min(10, cards[i].rank)
        }
        sumRank = sumRank % 10
        if self.pointComparision == 0{
            sumRank = (sumRank + 10 - 1) % 10
        }
        var rank = 0
        switch self.samePointComparision{
        case 0:
            var menNum = 0
            for card in cards{
                if self.isAAsMan == 1 {
                    if card.rank > 10 || card.rank == 1{
                        menNum += 1
                    }
                } else {
                    if card.rank > 10{
                        menNum += 1
                    }
                }
            }
            rank = sumRank << 8 | menNum << 6 | (cards[0].rank << 2 | cards[0].suit[0])
            break
        case 1:
            rank = sumRank << 6 | (cards[0].rank << 2 | cards[0].suit[0])
            break
        case 2:
            var menNum = 0
            for card in cards{
                if self.isAAsMan == 1 {
                    if card.rank > 10 || card.rank == 1{
                        menNum += 1
                    }
                } else {
                    if card.rank > 10{
                        menNum += 1
                    }
                }
            }
            
            let rank1 = rankConvertor(card: cards[0], convertorFlag: 0)<<2 | cards[0].suit[0]
            let rank2 = rankConvertor(card: cards[1], convertorFlag: 0)<<2 | cards[1].suit[0]
            let rank3 = rankConvertor(card: cards[2], convertorFlag: 0) | cards[2].suit[0]
            
            let maxRank = max(rank1, rank2, rank3)
            
            
            rank = sumRank << 8 | menNum << 6 | maxRank
            break
        case 3:
            rank = sumRank
            break
        case 4:
            var menNum = 0
            for card in cards{
                if self.isAAsMan == 1 {
                    if card.rank > 10 || card.rank == 1{
                        menNum += 1
                    }
                } else {
                    if card.rank > 10{
                        menNum += 1
                    }
                }
            }
            rank = sumRank << 2 | menNum
            break
        default:
            break
        }
        
        return rank
    }
    
    //0, A K ... 2
    
    func rankConvertor(card: Card, convertorFlag: Int) -> Int{
        switch convertorFlag {
        case 0:
            if card.rank == 1{
                return 13
            } else if card.rank < 14 {
                return card.rank - 1
            }
            break
        default:
            break
        }
        return card.rank
    }

}

