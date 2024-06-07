
import Foundation


class CBGameRule : Rule{
    
    //此处填入需要的参数，因为rulesettingview没有了，主要作用是注释
    let winCondition:[Int:String] = [
        0:"比尾墩",
        1:"比道数",
        2:"比积分"
    ]
    
    let AStraightMin:[Int:String] = [
        0:"A23第二大",
        1:"A23最小",
    ]
    
    let jokerChangeSetting:[Int:String] = [
        0:"王百变",
        1:"大王红牌 小王黑牌",
        2:"大王红6 小王黑3",
    ]
    
    let jokerThreeCardSetting:[Int:String] = [
        0:"王不能当三头",
        1:"王能当三头"
    ]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            5: "豹子",
            4: "顺金",
            3: "金花",
            2: "顺子",
            1: "对子",
            0: "单牌"
        ]
        self.setting = [
            0: "比鸡比道数[902]",
            1: "比鸡百变尾墩大[903]",
            2: "比鸡百变尾墩大4[904]",
            3: "比鸡百变尾墩大5[905]",
            4: "比鸡百变尾墩大2[906]",
            5: "比鸡9张金花[907]",
            6: "比鸡比道数A23[908]",
            7: "比鸡9张金花A23[909]",
            8: "比鸡9张百变金花[910]",
            9: "比鸡9张百变金花A23[911]",
            10: "比鸡百变尾墩大[912]",
        ]
        self.ruleInfo = [
            0: """
牌数:52张，不包括大小王
每人9张牌，分为3组，每组3张。3组分别比大小。
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌.花色不全相同的相连3张牌.AKQ>JQK>...>234 > A23
5)对子:
6)散牌:A最大2最小
""",
            1:"""
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大王代替红桃和方片，小王代替黑头和梅花，大小王不能当四个头三个头，只能当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            2: """
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大小王任意变，大小王不能当四个头三个头，只能当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            3:"""
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大小王任意变4花色，大小王能当四个头三个头，当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6) 散牌:A最大2最小
""",
            4: """
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大王代替红桃和方片，小王代替黑头和梅花，大小王能当四个头三个头，能当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            5:"""
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大王代替红桃和方片，小王代替黑头和梅花，大小王能当四个头三个头，能当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            6: """
牌数:52张，不包括大小王
每人9张牌，分为3组，每组3张。3组分别比大小。
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌. AKQ > A23>JQK>...>234
5)对子:
6)散牌:A最大2最小
""",
            7:"""
牌数:52，不包括大小王
每人9张，分为三组，每组3张。3组分别比大小。单组最大为1分，单组不是最大为0分，三组积分最多为最大。
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:QKA> A23>JQK...>234
5)对子:
6)散牌:A最大2最小
""",
            8: """
牌数:54
每人9张，分为三组，每组3张。3组分别比大小。单组最大为1分，单组不是最大为0分，三组积分最多为最大。大王可变任意红牌。小王可变任意黑牌
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            9:"""
牌数:54
每人9张，分为三组，每组3张。3组分别比大小。单组最大为1分，单组不是最大为0分，三组积分最多为最大。大王可变任意红牌。小王可变任意黑牌
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:QKA > A23>JQK...>234
5)对子:
6)散牌:A最大2最小
""",
            10: """
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大王代替红桃6和方片6，小王代替黑桃3和梅花3
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小

(
""",
        ]
        self.playerNum = [2,3,4,5,6]

    }
}


class CBGame{
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
        let deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
    }
    
    static func legalCheck(playerNum: Int, setting: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 9 > getAllCardIndex(setting: setting).count)
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
            result = Array(0...51)
            break
        case 7:
            result = Array(0...51)
            break
        case 8:
            result = Array(0...51) + [53,54]
            break
        case 9:
            result = Array(0...51) + [53,54]
            break
        case 10:
            result = Array(0...51) + [53,54]
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
    //5 winCondition
    //6 AStraightMin
    //7 jokerChangeSetting
    //8 jokerThreeCardSetting

    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let winCondition = args[5]
        let AStraightMin = args[6]
        let jokerChangeSetting = args[7]
        let jokerThreeCardSetting = args[8]
        
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
        
        
        var playerRankList : [[Int]] = []
        
        for i in 0..<playerNum {
            
            var turn1Cards:[CBGameCard] = []
            for card in allPlayCards[i].playerCard {
                turn1Cards.append(CBGameCard(card: card, jokerChangeSetting: jokerChangeSetting))
            }
            turn1Cards = turn1Cards.sorted(by: {$0.rank > $1.rank})
            
            let (rank1, cardtype1, isPair1, usedCardIndex1) = CBGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                jokerThreeCardSetting: jokerThreeCardSetting
            ).evalHand(cards: turn1Cards)
            
            allPlayCards[i].evaluateFlag = rank1
            allPlayCards[i].cardType = cardtype1
            allPlayCards[i].isPair = isPair1
                
            var turn2Cards:[CBGameCard] = []
            for cardIndex in 0..<turn1Cards.count {
                if !usedCardIndex1.contains(cardIndex){
                    turn2Cards.append(turn1Cards[cardIndex])
                }
            }
            
            let (rank2, cardtype2, isPair2, usedCardIndex2) = CBGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                jokerThreeCardSetting: jokerThreeCardSetting
            ).evalHand(cards: turn2Cards)
            
            var turn3Cards:[CBGameCard] = []
            for cardIndex in 0..<turn2Cards.count {
                if !usedCardIndex2.contains(cardIndex){
                    turn3Cards.append(turn2Cards[cardIndex])
                }
            }
                    
            let (rank3, cardtype3, isPair3, usedCardIndex3) = CBGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                jokerThreeCardSetting: jokerThreeCardSetting
            ).evalHand(cards: turn3Cards)
            
            playerRankList.append([rank1, rank2, rank3])
        }
        
        //尾墩
        if winCondition == 0{
            
        }
        //道数
        else if winCondition == 1{
            for i in 0..<playerNum {
                allPlayCards[i].evaluateFlag = 0
            }
            for currentPlayer in 0..<playerNum {
                for i in 0..<playerNum{
                    if currentPlayer != i{
                        for turn in 0..<3{
                            if playerRankList[currentPlayer][turn] > playerRankList[i][turn]{
                                allPlayCards[currentPlayer].evaluateFlag += 1
                            }
                            else if playerRankList[currentPlayer][turn] < playerRankList[i][turn]{
                                allPlayCards[currentPlayer].evaluateFlag -= 1
                            }
                        }
                    }
                }
            }
        }
        //积分
        else if winCondition == 2{
            
            for i in 0..<playerNum {
                allPlayCards[i].evaluateFlag = 0
            }
            
            for turn in 0..<3{
                
                var maxPlayer = 0
                var maxRank = 0
                
                for i in 0..<playerNum {
                    let currentRank = playerRankList[i][turn]
                    if currentRank > maxRank{
                        maxRank = currentRank
                        maxPlayer = i
                    }
                }
                
                allPlayCards[maxPlayer].evaluateFlag += 1
            }
        }
        
        
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
        if leftCards.count < CBGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        return (returnPlayerInfos, leftCards)
    }
}

class CBGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([CBGameCard]) -> ([Int], [String], Int, [[Int]])] = [:]
    var AStraightMin: Int
    var jokerThreeCardSetting: Int
        
    init(rankRules: [Int],
         suitRules: [Int],
         AStraightMin: Int,
         jokerThreeCardSetting: Int){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.AStraightMin = AStraightMin
        self.jokerThreeCardSetting = jokerThreeCardSetting
        
        self.ruleDict = [
            0:self.eval_holecard(cards:),
            1:self.eval_onepair(cards:),
            2:self.eval_straight(cards:),
            3:self.eval_flush(cards:),
            4:self.eval_straightflush(cards:),
            5:self.eval_threecard(cards:)
        ]
    }
    
    //传入需要的参数
    func evalHand(cards: [CBGameCard])->(Int, String, Int, [Int]){
        
        var rank:Int = 0
        var cardType:String = ""
        var isPair:Int = 0
        var usedCardIndex:[Int] = []
        
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rankList, cardTypeList, isPair, usedCardIndexList) = self.ruleDict[ruleIndex]!(cards)
            i -= 1
            
            if rankList.count == 0{
                continue
            }
            else {
                let maxIndex = rankList.firstIndex(of: rankList.max() ?? 0)!
                
                rank = (1 << (i + 15)) | rankList[maxIndex]
                cardType = cardTypeList[maxIndex]
                usedCardIndex = usedCardIndexList[maxIndex]
                
                break
            }
        }

        return (rank, cardType, isPair, usedCardIndex)
    }
    
    //牌型函数
    
    func eval_threecard(cards: [CBGameCard]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        if self.jokerThreeCardSetting == 1{
            if cards[0].rank == 15 && cards[1].rank == 15{
                for i in 2..<cards.count{
                    usedCardIndexList.append([0,1,i])
                }
            }
            else if cards[0].rank == 15{
                for i in 1..<cards.count-1{
                    if cards[i].rank == cards[i+1].rank{
                        usedCardIndexList.append([0,i,i+1])
                    }
                }
            }
            else {
                for i in 0..<cards.count-2{
                    if cards[i].rank == cards[i+1].rank && cards[i].rank == cards[i+2].rank{
                        usedCardIndexList.append([i,i+1,i+2])
                    }
                }
            }
        }
        else{
            for i in 0..<cards.count-2{
                if cards[i].originRank == cards[i+1].originRank && cards[i].originRank == cards[i+2].originRank{
                    usedCardIndexList.append([i,i+1,i+2])
                }
            }
        }

        if usedCardIndexList.count > 0 {
            
            for currentUsedCardIndex in usedCardIndexList{
                var rank = 0
                
                var threeCardRank = cards[currentUsedCardIndex[2]].rank
                var threeCardSuit = cards[currentUsedCardIndex[0]].rank
                
                if threeCardSuit == -1{
                    threeCardSuit = 0
                }
                
                rank = rank << 4 | threeCardRank
                rank = rank << 2 | threeCardSuit
                
                let cardType = "豹子" + ClassifierSettingArgs.CardNumberReportDic[cards[currentUsedCardIndex[2]].originRank]!
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
        }
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    
    func eval_straightflush(cards: [CBGameCard]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        let (straightRankList, straightCardTypeList, _, straightUsedCardIndexList) = eval_straight(cards: cards)
        
        if straightRankList.count > 0 {
            
            for i in 0..<straightUsedCardIndexList.count{
                let currentStraightUsedCardIndex = straightUsedCardIndexList[i]
                
                var suit = 3
                for c in currentStraightUsedCardIndex {
                    if cards[c].suit >= 0{
                        suit = cards[c].suit
                        break
                    }
                }
                
                var isFlush : Bool = true
                for currentCardIndex in currentStraightUsedCardIndex{
                    let currentCardSuit = cards[currentCardIndex].suit
                    
                    if currentCardSuit == -1
                        || currentCardSuit == suit
                        || (currentCardSuit == -2 && (suit == 0 || suit == 2))
                        || (currentCardSuit == -3 && (suit == 1 || suit == 3)){
                        continue
                    }
                    else{
                        isFlush = false
                        break
                    }
                }
                
                if isFlush{
                    usedCardIndexList.append(currentStraightUsedCardIndex)
                    
                    var rank = straightRankList[i] >> 2
                    
                    let cardType = "顺金" + String(rank)
                    rank = rank << 2 | suit
                    
                    rankList.append(rank)
                    cardTypeList.append(cardType)
                }
            }
        }
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    
    func eval_flush(cards: [CBGameCard]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        
        for suit in 0..<4{
            var suitCards : [Int] = []
            for i in 0..<cards.count{
                if cards[i].suit == -1
                    || cards[i].suit == suit
                    || (cards[i].suit == -2 && (suit == 0 || suit == 2))
                    || (cards[i].suit == -3 && (suit == 1 || suit == 3)){
                    suitCards.append(i)
                }
            }
            
            if suitCards.count >= 3{
                usedCardIndexList += suitCards.combinations(ofCount: 3)
            }
        }
        
        if usedCardIndexList.count > 0 {
            
            for currentUsedCardIndex in usedCardIndexList{
                var rank = 0
                
                var suit = 3
                for c in currentUsedCardIndex {
                    if cards[c].suit >= 0{
                        suit = cards[c].suit
                        break
                    }
                }
                
                for c in currentUsedCardIndex {
                    if cards[c].rank == 15{
                        rank = rank << 4 | 0
                    }
                    else{
                        rank = rank << 4 | cards[c].rank
                    }
                }
                rank = rank << 2 | suit
                
                let cardType = "金花" + String(cards[currentUsedCardIndex[0]].rank)
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
        }
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    

    func eval_straight(cards: [CBGameCard]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        
        var allIndex:[Int] = Array(0...cards.count-1)
       
        let allCombinations = allIndex.combinations(ofCount: 3)
        for combination in allCombinations {
            var currentCombination = combination
            currentCombination.sort(by: { index1, index2 in
                return cards[index1].rank > cards[index2].rank
            })
            
            var cntC = 0
            if cards[currentCombination[0]].rank == 15{
                cntC = 1
            }
            if cards[currentCombination[1]].rank == 15{
                cntC = 2
            }
            
            var headRank = -1
            var headSuit = -1
            
            if cntC == 2{
                let nowRank = cards[currentCombination[2]].rank
                if nowRank == 14{
                    headRank = 15 //AQK rank 15
                    headSuit = cards[currentCombination[2]].suit
                }
                else if nowRank == 13{
                    headRank = 15 //AQK rank 15
                    headSuit = 0
                }
                else if self.AStraightMin == 0 && (nowRank == 3 || nowRank == 2){
                    headRank = 14 //A23 rank 14
                    headSuit = 0
                }
                else{
                    headRank = nowRank + 2
                    headSuit = 0
                }
            }
            else{
                var gap = cntC
                
                if cards[currentCombination[cntC]].rank == 14{
                    cards[currentCombination[cntC]].rank = 1
                    currentCombination.sort(by: { index1, index2 in
                        return cards[index1].rank > cards[index2].rank
                    })
                    for i in cntC..<currentCombination.count-1{
                        let nowRank = cards[currentCombination[i]].rank
                        let nextRank = cards[currentCombination[i+1]].rank
                        if nowRank == nextRank {
                            gap = -1
                            break
                        }
                        else{
                            gap -= nowRank - nextRank - 1
                        }
                    }
                    
                    cards[currentCombination[currentCombination.count-1]].rank = 14
                    currentCombination.sort(by: { index1, index2 in
                        return cards[index1].rank > cards[index2].rank
                    })
                    
                    if gap > 0{
                        if self.AStraightMin == 0{
                            headRank = 14
                            headSuit = cards[currentCombination[cntC]].suit
                        }
                        else{
                            headRank = 3
                            headSuit = cards[currentCombination[cntC]].suit
                        }
                    }
                }
                
                gap = cntC
                for i in cntC..<currentCombination.count-1{
                    let nowRank = cards[currentCombination[i]].rank
                    let nextRank = cards[currentCombination[i+1]].rank
                    if nowRank == nextRank {
                        gap = -1
                        break
                    }
                    else{
                        gap -= nowRank - nextRank - 1
                    }
                }
                
                if gap >= 0{
                    let nowRank = cards[currentCombination[cntC]].rank
                    if nowRank == 14{
                        headRank = 15
                        headSuit = cards[currentCombination[cntC]].suit
                    }
                    else if nowRank + gap > 13{
                        headRank = 14
                        headSuit = 0
                    }
                    else if gap > 0{
                        headRank = nowRank + gap
                        headSuit = 0
                    }
                    else{
                        headRank = nowRank
                        headSuit = cards[currentCombination[cntC]].suit
                    }
                }
            }
            
            if headRank != -1{
                usedCardIndexList.append(currentCombination)
                var rank = 0
                if headSuit < 0{
                    headSuit = 0
                }
                
                rank = rank << 4 | headRank
                rank = rank << 2 | headSuit

                let cardType = "顺子" + String(headRank)
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
        }
        
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }

    
    func eval_onepair(cards: [CBGameCard]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        for i in 0..<cards.count-1{
            if cards[i].rank != 15 && cards[i].rank == cards[i+1].rank{
                usedCardIndexList.append([i, i+1])
            }
        }
        
        if cards[0].rank == 15{
            for i in 1..<cards.count{
                usedCardIndexList.append([0, i])
            }
        }

        if usedCardIndexList.count > 0 {
            
            for currentUsedCardIndex in usedCardIndexList{
                var rank = 0
                
                var pairRank = cards[currentUsedCardIndex[1]].rank
                var pairsuit = cards[currentUsedCardIndex[0]].suit
                
                if pairRank == 15{
                    pairRank = 14
                }
                if pairsuit < 0{
                    pairsuit = 0
                }
                                
                rank = rank << 4 | pairRank
                rank = rank << 2 | pairsuit
                
                
                let cardType = "对子" + ClassifierSettingArgs.CardNumberReportDic[cards[currentUsedCardIndex[1]].originRank]!
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
            
            
        }

        return (rankList, cardTypeList, 1, usedCardIndexList)
    }

    func eval_holecard(cards: [CBGameCard]) -> ([Int], [String], Int, [[Int]]) {
        var rank: Int = 0
        var usedCardIndexList : [Int] = []
        
        for i in 0..<cards.count-1{
            if cards[i].rank != 15{
                usedCardIndexList.append(i)
                break
            }
        }
        
        for c in usedCardIndexList {
            
            var suit = cards[c].suit
            if suit == -1{
                suit = 3
            }
            else if suit == -2{
                suit = 2
            }
            else if suit == -3{
                suit = 3
            }
            
            rank = rank << 4 | cards[c].rank
            rank = rank << 2 | suit
        }

        return ([rank], ["单牌"], 0, [usedCardIndexList])
    }
}

class CBGameCard{
    var rank: Int = 0
    var suit: Int = 0
    var originRank : Int = 0
    
    init(card: Card, jokerChangeSetting: Int){
        self.originRank = card.rank
        
        if card.rank == 14 {
            if jokerChangeSetting == 0{
                self.rank = 15
                self.suit = -1
            }
            else if jokerChangeSetting == 1{
                self.rank = 15
                self.suit = -3
            }
            else if jokerChangeSetting == 2{
                self.rank = 3
                self.suit = -3
            }
        }
        else if card.rank == 15 {
            if jokerChangeSetting == 0{
                self.rank = 15
                self.suit = -1
            }
            else if jokerChangeSetting == 1{
                self.rank = 15
                self.suit = -2
            }
            else if jokerChangeSetting == 2{
                self.rank = 6
                self.suit = -2
            }
        }
        else if card.rank == 1{
            self.rank = 14
            self.suit = card.suit[0]
        }
        else{
            self.rank = card.rank
            self.suit = card.suit[0]
        }
    }
}
