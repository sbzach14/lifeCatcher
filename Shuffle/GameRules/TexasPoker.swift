
import Foundation

class TexasPokerRule : Rule{
    //Test to be deleted
    let isCompareSuit : [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isAceStraight: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let minRank: [Int] = [2,3,4,5,6,7,8,9]
    let handNum: [Int] = [1,2,3,4,5]
    let communityNum: [Int] = [0,3,5]
    let handUseType: [Int: String] = [
        0: "无限制",
        1: "必须用n张",
        2: "最少用n张"
    ]
    let handUseNum: [Int] = [1,2,3,4,5]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            11: "同花顺",
            10: "四条",
            9: "葫芦",
            8: "同花",
            7: "顺子",
            6: "三条",
            5: "三同花顺",
            4: "三顺子",
            3: "三同花",
            2: "两对",
            1: "一对",
            0: "高牌"
        ]
        self.playerNum = [2,3,4,5,6,7,8]
        self.setting = [
            0: "德州扑克[701]",
            1: "短牌德州",
            2: "德州扑克清比葫芦大[702]",
            3: "德州扑克[550]",
            4: "德州扑克10选5[1020]",
        ]
        self.ruleInfo = [
            0:"""
    5张德州扑克:
    52张牌，不要大小王，每人先发2张牌，再一次发3张1张1张公共牌，然后每次发公共牌之前都要烧一张牌。
    先比牌型，再比主要部分牌大小，不分花色。
    同花顺
    四条
    葫芦，三条带一对
    同花
    顺子
    三条
    两对
    一对
    高牌
    """,
            1:"""
    使用一副去掉 2、3、4和5的牌，共36张牌。
    短牌皇家同花顺：A-6-7-8-9 的同花顺。
    短牌同花顺：任意五张同花的连续牌。
    四条：四张相同的牌。
    满堂红：三张相同的牌加上一对。
    短牌同花：五张同花但非连续的牌。
    短牌顺子：A-6-7-8-9 或更高的五张连续牌。
    三条：三张相同的牌。
    两对：两对不同的牌。
    一对：两张相同的牌。
    高牌：没有其他组合时，最大的牌。
    """,
            2:"""
            和标准德州相同，同花比葫芦大
            """,
            3:"""
            没有公牌，其他和标准德州规则相同，需要在选择规则后在发牌设置里选择自定义发牌然后设置成一人发五张
            """,
            4:"""
            规则和常规德州相同，需要在自定义发牌里设置成每人先发五张牌，然后选出5张，再发5张公牌，选出3张牌，进行比较
            """,
        ]
    }
}

//德州扑克
class TexasPoker{
    

    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo], [Int]) {
        
        
//        let json = Python.import("json")
//
//        let pythonObject =  json.TexasPokerGame.calResult(inputCards, args, rankRules, suitRules)
//        // 使用 map() 函数将 PythonList 转换为 Int 数组
//        let intArray = Array<Int>(pythonObject)!
        print("Array")
        var inputString : String = ""
        for i in 0..<inputCards.count{
            inputString += GameManager.cardLabelDic[inputCards[i]]!
        }
        print(inputString)
        let (resultInfoList,leftCards) = TexasPokerGame.calResult(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, cardArray: inputCards, args: args, rankRules: rankRules, suitRules: suitRules)
        return (resultInfoList, leftCards)
    }
    
    static func legalCheck(playerNum: Int, minRank: Int, handUseType: Int, handUseNum: Int, handNum: Int, communityNum: Int) -> String
    {
        var errMessage : String = ""
        if(handUseType == 0 && handNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(handUseType != 0 && handNum < handUseNum)
        {
            errMessage = "手牌数小于设置需求，请重新设置！"
        }
        else if(handUseType == 1 && handUseNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(handUseType == 2 && handNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(playerNum * handNum + communityNum > 52 - (minRank - 2) * 4)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex(minRank: Int) -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...12{
                if rank == 0 || rank >= minRank - 1{
                    result.append(rank + i * 13)
                }
            }
        }
        return result
    }
    
    static func getMinCardNum(playerNum: Int, handNum: Int, communityNum: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
        if dealType == 0 || dealType == 1{
            return playerNum * handNum + communityNum + 3
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
}


class TexasPlayer {
    var playerCard = [Card]()
    var evaluateFlag = 0
    var cardsType: String = ""
    var cardsSuit: String = ""
    var isPair: String = ""
    
    func insertCard(card: Card) {
        playerCard.append(card)
    }
}

class TexasPokerGame {
//    #args
//    #0 playerNum
//    #1 isCompareSuit 0/1
//    #2 isAceStraight 0/1
//    #3 minRank 2-9
//    #4 handNum 1-5
//    #5 communityNum 0/3/5
//    #6 handUseType 0无限制/1必须/2至少
//    #7 handUseNum 1-5
    static func calResult(diyDealStatus:[[Bool]], diyDealNum:[Int], cardArray: [Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        var deck = initDeck(initialCards: cardArray, suitRules: suitRules)
            let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: &deck, args: args, rankRules: rankRules)
            return (winners, leftCards)
        }
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: inout [Card], args: [Int], rankRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let rule = GameManager.gameRules[0] as! TexasPokerRule
        let dealType = args[0]
        let diyDealType = args[1]
        let playerNum = args[2]
        
        //TODO 按照rulesettingview里的内容修改
        let isCompareSuit = args[3] == 1
        let isAceStraight = args[4] == 1
        let minRank = rule.minRank[args[5]]
        let handNum = rule.handNum[args[6]]
        let communityNum = rule.communityNum[args[7]]
        let handUseType = args[8]
        let handUseNum = rule.handUseNum[args[9]]
        
        var maxRank = 0
        var returnPlayerInfos: [GameReturnPlayerInfo] = []

        var allPlayCards = [TexasPlayer]()
        var community = [Card]()
        if deck.count < TexasPoker.getMinCardNum(playerNum: playerNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            return ([],[])
        }
        
        
        for _ in 0..<playerNum {
            allPlayCards.append(TexasPlayer())
        }
        
        // 发牌
        // 正发
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
            if communityNum == 3 {
                deck.removeFirst()
                for _ in 0..<3 {
                    community.append(deck.removeFirst())
                }
            } else if communityNum == 5 {
                deck.removeFirst()
                for _ in 0..<3 {
                    community.append(deck.removeFirst())
                }
                for _ in 0..<2 {
                    deck.removeFirst()
                    community.append(deck.removeFirst())
                }
            }
        }
        // 自定义发牌 dealType = 2
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
            
            (allPlayCards[i].evaluateFlag, allPlayCards[i].cardsType) = HandEvaluator.evalHand(cards: allPlayCards[i].playerCard, community: community, isCompareSuit: isCompareSuit, isAceStraight: isAceStraight, minRank: minRank, handUseType: handUseType, handUseNum: handUseNum, rankRules: rankRules)
        }
        
        var resultList = [ResultStruct]()
        for i in 0..<playerNum {
            let rank = allPlayCards[i].evaluateFlag
            resultList.append(ResultStruct(playerID: i, rank: rank))
        }
        let sortedResultList =  resultList.sorted(by: {$0.rank > $1.rank })
        for result in sortedResultList {
            var currentPlayerReturnInfo: GameReturnPlayerInfo = GameReturnPlayerInfo()
            currentPlayerReturnInfo.playerID = result.playerID
            currentPlayerReturnInfo.playerRank = result.rank
            currentPlayerReturnInfo.playerCardsType = allPlayCards[result.playerID].cardsType
            //存入手牌和公牌
            currentPlayerReturnInfo.PlayerCards = allPlayCards[result.playerID].playerCard
            currentPlayerReturnInfo.communityCard = community
            returnPlayerInfos.append(currentPlayerReturnInfo)
        }
        var leftCards:[Int] = []
        for card in deck{
            leftCards.append(card.cardIndex)
        }
        
        if leftCards.count < TexasPoker.getMinCardNum(playerNum: playerNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        
        return (returnPlayerInfos, leftCards)
    }
}

class HandEvaluator {
    
    static func evalHand(cards: [Card], community: [Card], isCompareSuit: Bool, isAceStraight: Bool, minRank: Int, handUseType: Int, handUseNum: Int, rankRules: [Int]) -> (Int, String) {
        let suitRules :[Int] = [3,2,1,0]

        var handCardsString:String = ""
        for handCard in cards{
            handCardsString += GameManager.cardLabelDic[handCard.rank
                                                               - 1 + suitRules[handCard.suit[0]]*13]!
        }
        print("手牌：", handCardsString, "A顺子：", isAceStraight)
        var communityCardsString: String = ""
        for communityCard in community{
            communityCardsString += GameManager.cardLabelDic[communityCard.rank - 1 + suitRules[communityCard.suit[0]] * 13]!
        }
        print("公共牌：", communityCardsString)
        
        let (cardsLength, allSortedCards) = sortCards(cards: cards, community: community, handUseType: handUseType, handUseNum: handUseNum, isAceStraight: isAceStraight, minRank: minRank)
        var sortedString:String = ""
        for sortedcard in allSortedCards[0]{
            sortedString += GameManager.cardLabelDic[sortedcard.cardIndex]!
        }
        
        print("排序后的牌 ", sortedString," length: ", cardsLength)
        
        var maxScore = 0
        var maxCardType: String = ""
        for sortedCards in allSortedCards {
            let (score, cardType) = calcHandInfoFlg(sortedCards: sortedCards, isCompareSuit: isCompareSuit, rankRules: rankRules, cardsLength: cardsLength)
            if score > maxScore {
                maxScore = score
                maxCardType = cardType
            }
        }
        return (maxScore, maxCardType)
    }
    
    static func sortCards(cards: [Card], community: [Card], handUseType: Int, handUseNum: Int, isAceStraight: Bool, minRank: Int) -> (Int, [[Card]]) {
        var allCards = [[Card]]()
        var cardsLength = 0
        var cardCopy:[Card] = []
        var communityCopy:[Card] = []
        for card in cards {
            var copy:Card = Card(suit: card.suit, rank: card.rank, cardIndex: card.cardIndex)
            if copy.rank == 1 {
                copy.rank = 14
            }
            cardCopy.append(copy)
        }
        
        for card in community {
            var copy:Card = Card(suit: card.suit, rank: card.rank, cardIndex: card.cardIndex)

            if copy.rank == 1 {
                copy.rank = 14
            }
            communityCopy.append(copy)
        }
        
        if handUseType == 0 {
            allCards.append(cardCopy + communityCopy)
            cardsLength = cardCopy.count + communityCopy.count
        } else if handUseType == 1 {
            cardsLength = 5
            let communityNum = 5 - handUseNum
            let handCombinations = cardCopy.combinations(ofCount: handUseNum)
            let communityCombinations = communityCopy.combinations(ofCount: communityNum)
            
            for handCombination in handCombinations {
                if communityNum != 0 {
                    for communityCombination in communityCombinations {
                        allCards.append(handCombination + communityCombination)
                    }
                } else {
                    allCards.append(handCombination)
                }
            }
        } else if handUseType == 2 {
            cardsLength = 5
            for handNum in 1...handUseNum {
                let communityNum = 5 - handNum
                let handCombinations = cardCopy.combinations(ofCount: handNum)
                let communityCombinations = communityCopy.combinations(ofCount: communityNum)
                
                for handCombination in handCombinations {
                    if communityNum != 0 {
                        for communityCombination in communityCombinations {
                            allCards.append(handCombination + communityCombination)
                        }
                    } else {
                        allCards.append(handCombination)
                    }
                }
            }
        }
        var returnAllCards = [[Card]]()
        
        for var cardsList in allCards {
            if isAceStraight {
                var aceCards = [Card]()
                for card in cardsList {
                    if card.rank == 14 {
                        aceCards.append(Card(suit: card.suit, rank: minRank - 1, cardIndex: card.cardIndex))
                    }
                }
                cardsList += aceCards
            }
            cardsList.sort(by: { card1, card2 in
                return Card.calScore(card: card1) > Card.calScore(card: card2)
            })
            returnAllCards.append(cardsList)
        }
        
        return (cardsLength, returnAllCards)
    }
    
    static func calcHandInfoFlg(sortedCards: [Card], isCompareSuit: Bool, rankRules: [Int], cardsLength: Int) -> (Int, String) {
        let ruleDict: [Int: ([Card], Int) -> Int] = [
            0: evalHoleCard,
            1: evalOnePair,
            2: evalTwoPair,
            3: evalThreeFlush,
            4: evalThreeStraight,
            5: evalThreeStraightFlush,
            6: evalThreeCard,
            7: evalStraight,
            8: evalFlush,
            9: evalFullHouse,
            10: evalFourCard,
            11: evalStraightFlush
        ]
        
        var rankResult = 0
        var cardType: String = ""
        let rule = GameManager.gameRules[0] as! TexasPokerRule
        for (index, ruleIndex) in rankRules.enumerated() {
            let rankFlag = 1 << (rankRules.count - index + 23)
            rankResult = ruleDict[ruleIndex]!(sortedCards, cardsLength)
            if !isCompareSuit {
                rankResult >>= 2
            }
            if rankResult != 0 {
                rankResult |= rankFlag
                print("判断结果 ", rule.rankRules[ruleIndex] as Any)
                cardType = rule.rankRules[ruleIndex]!
                break
            }
        }
        return (rankResult, cardType)
    }
    
    
    static func evalStraightFlush(cards: [Card], cardsLength: Int) -> Int {
        var rank = 0
        for suit in [3, 2, 1, 0] {
            var rankList = [Int]()
            var cnt = 1
            var straightHeadRank = 0
            
            for i in 0..<cards.count {
                if cards[i].suit[0]  == suit {
                    rankList.append(cards[i].rank)
                }
            }
            
            if rankList.count == 0{
                continue
            }
            
            for i in 0..<rankList.count - 1 {
                if rankList[i] - rankList[i+1] == 1 {
                    cnt += 1
                    if straightHeadRank == 0 {
                        straightHeadRank = rankList[i]
                    }
                    if cnt == 5 {
                        rank = straightHeadRank
                        break
                    }
                } else {
                    cnt = 1
                    straightHeadRank = 0
                }
            }
            
            if rank != 0 {
                rank = rank << 2 | suit
                break
            }
        }
        
        return rank
    }
        
    static func evalFourCard(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            for i in 0...(cardsLength - 4) {
                var isFourCard = true
                for j in 1...3 {
                    if cards[i + j].rank != cards[i].rank {
                        isFourCard = false
                        break
                    }
                }
                if isFourCard {
                    rank = cards[i].rank << 4
                    if i == 0 {
                        rank = rank | cards[4].rank
                    } else {
                        rank = rank | cards[0].rank
                    }
                    rank = rank << 2
                    break
                }
            }
            return rank
        }
        
        static func evalFullHouse(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            var threeCardRank = 0
            var pairRank = 0
            for i in 0...(cardsLength - 3) {
                if cards[i].rank == cards[i+1].rank && cards[i].rank == cards[i+2].rank {
                    threeCardRank = cards[i].rank
                    break
                }
            }
            if threeCardRank != 0 {
                for i in 0...(cardsLength - 2) {
                    if cards[i].rank == cards[i+1].rank && cards[i].rank != threeCardRank {
                        pairRank = cards[i].rank
                        break
                    }
                }
            }
            if threeCardRank != 0 && pairRank != 0 {
                rank = threeCardRank << 4 | pairRank
                rank = rank << 2
            }
            return rank
        }
    
    
    static func evalFlush(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            for suit in [3, 2, 1, 0] {
                var cnt = 0
                for i in 0..<cardsLength {
                    if cards[i].suit[0] == suit && cnt < 5 {
                        cnt += 1
                        rank = rank << 4 | cards[i].rank
                    }
                }
                if cnt == 5 {
                    rank = rank << 2 | suit
                    break
                } else {
                    rank = 0
                }
            }
            return rank
        }
        
        static func evalStraight(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            var cnt = 1
            var straightHeadRank = 0
            
            
            
            for i in 0..<(cards.count - 1)  {
//                print("比较 \(cards[i].rank)，\(cards[i + 1].rank)")
                if cards[i].rank - cards[i+1].rank == 1 {
                    cnt += 1
                    if straightHeadRank == 0 {
                        straightHeadRank = cards[i].rank
                    }
                    if cnt == 5 {
                        rank = straightHeadRank
                        break
                    }
                } else if cards[i].rank != cards[i+1].rank {
                    cnt = 1
                    straightHeadRank = 0
                }
            }
            if rank != 0 {
                for card in cards {
                    if card.rank == rank {
                        rank = rank << 2 | (card.suit[0])
                        break
                    }
                }
            }
            return rank
        }
        
        static func evalThreeCard(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            var threeCardRank = 0
            var highCardRank1 = 0
            var highCardRank2 = 0
            var threeCardSuit = 0
            for i in 0..<(cardsLength - 2) {
                if cards[i].rank == cards[i+1].rank && cards[i].rank == cards[i+2].rank {
                    threeCardRank = cards[i].rank
                    threeCardSuit = cards[i].suit[0]
                    break
                }
            }
            if threeCardRank != 0 {
                for i in 0..<cardsLength {
                    if cards[i].rank != threeCardRank {
                        highCardRank1 = cards[i].rank
                        break
                    }
                }
                for i in 0..<cardsLength {
                    if cards[i].rank != threeCardRank && cards[i].rank != highCardRank1 {
                        highCardRank2 = cards[i].rank
                        break
                    }
                }
                rank = threeCardRank << 8 | highCardRank1 << 4 | highCardRank2
                rank = rank << 2 | threeCardSuit
            }
            return rank
        }
    
    static func evalThreeStraightFlush(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            for suit in [3, 2, 1, 0] {
                var cardList: [Card] = []
                var cnt = 1
                var straightHeadRank = 0
                for card in cards {
                    if card.suit[0] == suit {
                        cardList.append(card)
                    }
                }
                if cardList.count < 3{
                    continue
                }
                for i in 0..<(cardList.count - 1) {
                    if cardList[i].rank - cardList[i+1].rank == 1 {
                        cnt += 1
                        if straightHeadRank == 0 {
                            straightHeadRank = cardList[i].rank
                        }
                        if cnt == 3 {
                            rank = straightHeadRank
                            cardList = Array(cardList[i - 1...i + 2])
                            break
                        }
                    } else {
                        cnt = 1
                        straightHeadRank = 0
                    }
                }
                if rank != 0 {
                    var highCardCnt = 0
                    for card in cards {
                        if !cardList.contains(where: { $0 as! AnyHashable == card as! AnyHashable }){
                            rank = rank << 4 | card.rank
                            highCardCnt += 1
                        }
                        if highCardCnt == 2 {
                            break
                        }
                    }
                    rank = rank << 2 | suit
                    break
                }
            }
            return rank
        }
        
        static func evalThreeStraight(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            var cnt = 1
            var straightHeadRank = 0
            var cardList: [Card] = [cards[0]]
            for i in 0..<(cards.count - 1) {
                if cards[i].rank - cards[i+1].rank == 1 {
                    cnt += 1
                    cardList.append(cards[i + 1])
                    if straightHeadRank == 0 {
                        straightHeadRank = cards[i].rank
                    }
                    if cnt == 3 {
                        rank = straightHeadRank
                        break
                    }
                } else if cards[i].rank != cards[i+1].rank {
                    cnt = 1
                    cardList = [cards[i]]
                    straightHeadRank = 0
                }
            }
            if rank != 0 {
                var highCardCnt = 0
                for card in cards {
                    if !cardList.contains(where: { $0 as! AnyHashable == card as! AnyHashable }) {
                        rank = rank << 4 | card.rank
                        highCardCnt += 1
                    }
                    if highCardCnt == 2 {
                        break
                    }
                }
                for card in cards {
                    if card.rank == rank {
                        rank = rank << 2 | (card.suit[0])
                        break
                    }
                }
            }
            return rank
        }
        
        static func evalThreeFlush(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            var cardList: [Card] = []
            for suit in [3, 2, 1, 0] {
                var cnt = 0
                for i in 0..<cardsLength {
                    if cards[i].suit[0] == suit && cnt < 3 {
                        cnt += 1
                        cardList.append(cards[i])
                        rank = rank << 4 | cards[i].rank
                    }
                }
                if cnt == 3 {
                    var highCardCnt = 0
                    for card in cards {
                        if !cardList.contains(where: { $0 as! AnyHashable == card as! AnyHashable }) {
                            rank = rank << 4 | card.rank
                            highCardCnt += 1
                        }
                        if highCardCnt == 2 {
                            break
                        }
                    }
                    rank = rank << 2 | suit
                    break
                } else {
                    rank = 0
                    cardList = []
                }
            }
            return rank
        }
        
        static func evalTwoPair(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            var firstPairRank = 0
            var secondPairRank = 0
            var highCardRank = 0
            var firstPairSuit = 0
            for i in 0..<(cardsLength - 1) {
                if cards[i].rank == cards[i+1].rank {
                    if firstPairRank == 0 {
                        firstPairRank = cards[i].rank
                        firstPairSuit = cards[i].suit[0]
                    } else {
                        secondPairRank = cards[i].rank
                        break
                    }
                }
            }
            if firstPairRank != 0 && secondPairRank != 0 {
                for i in 0..<cardsLength {
                    if cards[i].rank != firstPairRank && cards[i].rank != secondPairRank {
                        highCardRank = cards[i].rank
                        break
                    }
                }
                rank = firstPairRank << 8 | secondPairRank << 4 | highCardRank
                rank = rank << 2 | firstPairSuit
            }
            return rank
        }
    
    static func evalOnePair(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            var pairRank = 0
            var pairSuit = 0
            var rankList: [Int] = []
            for i in 0..<(cardsLength - 1) {
                if cards[i].rank == cards[i + 1].rank {
                    pairRank = cards[i].rank
                    pairSuit = cards[i].suit[0]
                    rankList.append(pairRank)
                    break
                }
            }
            if pairRank != 0 {
                for _ in 0..<3 {
                    for i in 0..<cardsLength {
                        if !rankList.contains(cards[i].rank) {
                            rankList.append(cards[i].rank)
                            break
                        }
                    }
                }
                for rank_ in rankList {
                    rank = rank << 4 | rank_
                }
                rank = rank << 2 | pairSuit
            }
            return rank
        }
        
        static func evalHoleCard(cards: [Card], cardsLength: Int) -> Int {
            var rank = 0
            for i in 0..<5 {
                rank = rank << 4 | cards[i].rank
            }
            rank = rank << 2 | (cards[0].suit[0])
            return rank
        }
}
