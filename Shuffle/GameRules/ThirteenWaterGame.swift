//
//  ThirteenWaterGame.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 4/9/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation


class ThirteenWaterGameRule : Rule{
    
    //此处填入需要的参数，因为rulesettingview没有了，主要作用是注释
    let winCondition:[Int:String] = [
        0:"比尾墩",
        1:"比道数",
        2:"比两道"
    ]
    
    let AStraightMin:[Int:String] = [
        0:"A2345最小",
        1:"A2345第二大"
    ]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            9: "三条炸弹",
            8: "清顺",
            7: "炸弹",
            6: "三带二",
            5: "清一色",
            4: "顺子",
            3: "三条",
            2: "两对",
            1: "对子",
            0: "单牌"
        ]
        self.setting = [
            0: "",
        ]
        self.ruleInfo = [
            0: ""
        ]
        
        self.playerNum = [2,3,4]

    }
}


class ThirteenWaterGame{
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 13 > 52)
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
    //5 winCondition
    //6 AStraightMin

    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let winCondition = args[5]
        let AStraightMin = args[6]
        
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
            let (rank1, cardtype1, isPair1, usedCardIndex1) = ThirteenWaterGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                turn: 1
            ).evalHand(cards: allPlayCards[i].playerCard)
            
            allPlayCards[i].evaluateFlag = rank1
            allPlayCards[i].cardType = cardtype1
            allPlayCards[i].isPair = isPair1
                
            var turn2Cards:[Card] = []
            for cardIndex in 0..<allPlayCards[i].playerCard.count {
                if !usedCardIndex1.contains(cardIndex){
                    turn2Cards.append(allPlayCards[i].playerCard[cardIndex])
                }
            }
                
            let (rank2, cardtype2, isPair2, usedCardIndex2) = ThirteenWaterGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                turn: 2
            ).evalHand(cards: turn2Cards)
                
                    
            var turn3Cards:[Card] = []
            for cardIndex in 0..<turn2Cards.count {
                if !usedCardIndex2.contains(cardIndex){
                    turn3Cards.append(turn2Cards[cardIndex])
                }
            }
                    
            let (rank3, cardtype3, isPair3, usedCardIndex3) = ThirteenWaterGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                turn: 3
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
                                allPlayCards[i].evaluateFlag -= 1
                            }
                            else if playerRankList[currentPlayer][turn] < playerRankList[i][turn]{
                                allPlayCards[currentPlayer].evaluateFlag -= 1
                                allPlayCards[i].evaluateFlag += 1
                            }
                        }
                    }
                }
            }
        }
        //两道
        else if winCondition == 2{
            for i in 0..<playerNum {
                allPlayCards[i].evaluateFlag = 0
            }
            for currentPlayer in 0..<playerNum {
                for i in 0..<playerNum{
                    if currentPlayer != i{
                        for turn in 0..<3{
                            var winFlag = 0
                            if playerRankList[currentPlayer][turn] > playerRankList[i][turn]{
                                winFlag += 1
                            }
                            else if playerRankList[currentPlayer][turn] < playerRankList[i][turn]{
                                winFlag -= 1
                            }
                            if winFlag >= 2{
                                allPlayCards[currentPlayer].evaluateFlag += 1
                            }
                        }
                    }
                }
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
        if leftCards.count < ThirteenWaterGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        return (returnPlayerInfos, leftCards)
    }
}

class ThirteenWaterGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([ThirteenWaterCard], Int) -> ([Int], [String], Int, [[Int]])] = [:]
    var AStraightMin: Int
    var turn: Int
    init(rankRules: [Int],
         suitRules: [Int],
         AStraightMin: Int, turn: Int){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.AStraightMin = AStraightMin
        self.turn = turn
        
        self.ruleDict = [
            0:self.eval_holecard(cards:needCardsNum:),
            1:self.eval_onepair(cards:needCardsNum:),
            2:self.eval_twopair(cards:needCardsNum:),
            3:self.eval_threecard(cards:needCardsNum:),
            4:self.eval_straight(cards:needCardsNum:),
            5:self.eval_flush(cards:needCardsNum:),
            6:self.eval_fullhouse(cards:needCardsNum:),
            7:self.eval_fourcard(_:needCardsNum:),
            8:self.eval_straightflush(cards:needCardsNum:),
            9:self.eval_threecard_turn3(cards:needCardsNum:)
        ]
    }
    
    //传入需要的参数
    func evalHand(cards: [Card])->(Int, String, Int, [Int]){
        var cards = cards
        
        var numList:[ThirteenWaterCard] = []
        for card in cards {
            numList.append(ThirteenWaterCard(card: card))
        }
        numList = numList.sorted(by: {$0.rank > $1.rank})
        
        
        var needCardNum = 5
        if turn == 3{
            needCardNum = 3
        }
        
        var rank:Int = 0
        var cardType:String = ""
        var isPair:Int = 0
        var usedCardIndex:[Int] = []
        
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rankList, cardTypeList, isPair, usedCardIndexList) = self.ruleDict[ruleIndex]!(numList, needCardNum)
            i -= 1
            
            if rankList.count == 0{
                continue
            } 
            else {
                let maxIndex = rankList.firstIndex(of: rankList.max() ?? 0)!
                
                rank = (1 << (i + 11)) | rankList[maxIndex]
                cardType = cardTypeList[maxIndex]
                usedCardIndex = usedCardIndexList[maxIndex]
                
                break
            }
        }

        return (rank, cardType, isPair, usedCardIndex)
    }
    //牌型函数
    func eval_straightflush(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        
        let (straightRankList, straightCardTypeList, _, straightUsedCardIndexList) = eval_straight(cards: cards, needCardsNum: needCardsNum)
        
        if straightRankList.count > 0 {
            
            for i in 0..<straightUsedCardIndexList.count{
                let currentStraightUsedCardIndex = straightUsedCardIndexList[i]
                var suit : Int = -1
                var isFlush : Bool = true
                for currentCardIndex in currentStraightUsedCardIndex{
                    let currentCard = cards[currentCardIndex]
                    
                    if currentCard.suit == suit{
                        continue
                    }
                    else if suit == -1{
                        suit = currentCard.suit
                    }
                    else{
                        isFlush = false
                        break
                    }
                }
                if isFlush{
                    usedCardIndexList.append(currentStraightUsedCardIndex)
                    
                    var rank = straightRankList[i] >> 2
                    rank = rank << 2 | suit
                    
                    let cardType = "同花顺" + GameManager.SuitReportDix[suit]!
                    
                    rankList.append(rank)
                    cardTypeList.append(cardType)
                }
            }
        }
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    
    func eval_fourcard(_ cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        if cards.count >= 5{
            if cards[0].rank == 15 && cards[1].rank == 15{
                for i in 2..<cards.count-1{
                    if cards[i].rank == cards[i+1].rank{
                        usedCardIndexList.append([0,1,i,i+1])
                    }
                }
            }
            else if cards[0].rank == 15{
                for i in 1..<cards.count-2{
                    if cards[i].rank == cards[i+1].rank && cards[i].rank == cards[i+2].rank{
                        usedCardIndexList.append([0,i,i+1,i+2])
                    }
                }
            }
            else {
                for i in 0..<cards.count-3{
                    if cards[i].rank == cards[i+1].rank && cards[i].rank == cards[i+2].rank && cards[i].rank == cards[i+3].rank{
                        usedCardIndexList.append([i,i+1,i+2,i+3])
                    }
                }
            }
        }

        if usedCardIndexList.count > 0 {
            
            for currentUsedCardIndex in usedCardIndexList{
                var rank = 0
                
                var fourCardRank = cards[currentUsedCardIndex[2]].rank
                
                var fourcardSuit = cards[currentUsedCardIndex[0]].suit
                if fourcardSuit == -1{
                    fourcardSuit = 0
                }
                
                rank = rank << 4 | fourCardRank
                rank = rank << 2 | fourcardSuit
                
                let cardType = "炸弹" + String(fourCardRank)
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
        }
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    
    func eval_fullhouse(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        if cards.count >= 5{
            let (threecardRankList, threecardCardTypeList, _, threecardUsedCardIndexList) = eval_threecard(cards: cards, needCardsNum: needCardsNum)
            
            if threecardUsedCardIndexList.count > 0 {
                
                for currentThreeCardUsedCardIndex in threecardUsedCardIndexList{
                    
                    var pairCards: [ThirteenWaterCard] = []
                    var pairCardsIndex: [Int] = []
                    for i in 0..<cards.count{
                        if !currentThreeCardUsedCardIndex.contains(i){
                            pairCards.append(cards[i])
                            pairCardsIndex.append(i)
                        }
                    }
                    let (pairRankList, pairCardTypeList, _, pairUsedCardIndexList) = eval_onepair(cards: pairCards, needCardsNum: needCardsNum)
                    
                    if pairUsedCardIndexList.count > 0{
                        for currentPairUsedCardIndex in pairUsedCardIndexList{
                            usedCardIndexList.append([currentThreeCardUsedCardIndex[0],currentThreeCardUsedCardIndex[1], currentThreeCardUsedCardIndex[2], pairCardsIndex[currentPairUsedCardIndex[0]],pairCardsIndex[currentPairUsedCardIndex[1]]])
                        }
                    }
                }
            }
        }
        
        if usedCardIndexList.count > 0 {
            
            for currentUsedCardIndex in usedCardIndexList{
                var rank = 0
                
                var threecardRank = cards[currentUsedCardIndex[3]].rank
                var pairRank = cards[currentUsedCardIndex[4]].rank
                var threecardSuit = cards[currentUsedCardIndex[0]].suit
                var pairSuit = cards[currentUsedCardIndex[3]].suit
                
                if pairRank == 15{
                    pairRank = 14
                }
                if threecardSuit == -1{
                    threecardSuit = 0
                }
                if pairSuit == -1{
                    pairSuit = 0
                }
                
                rank = rank << 4 | threecardRank
                rank = rank << 4 | pairRank
                rank = rank << 2 | threecardSuit
                rank = rank << 2 | pairSuit
                
                let cardType = "三带二" + String(threecardRank) + String(pairRank)
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
            
        }

        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    
    func eval_flush(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        
        for suit in 0..<4{
            var suitCards : [Int] = []
            for i in 0..<cards.count{
                if cards[i].suit == -1 || cards[i].suit == suit{
                    suitCards.append(i)
                }
            }
            
            if suitCards.count >= needCardsNum{
                usedCardIndexList += suitCards.combinations(ofCount: needCardsNum)
            }
        }
        
        if usedCardIndexList.count > 0 {
            
            for currentUsedCardIndex in usedCardIndexList{
                var rank = 0
                
                var suit = 3
                for c in currentUsedCardIndex {
                    if cards[c].suit != -1{
                        suit = cards[c].suit
                        break
                    }
                }
                var flushRank = cards[currentUsedCardIndex[0]].rank
                if flushRank == 15{
                    flushRank = 14
                }
                
                rank = rank << 4 | flushRank
                rank = rank << 2 | suit
                
                let cardType = "同花" + GameManager.SuitReportDix[suit]!
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
        }
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    

    func eval_straight(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        
        var allIndex:[Int] = Array(0...cards.count-1)
        var jokerNum = 0
        var lastNum = cards[0].rank
        var beginIndex = 0
        var length = 0
        for index in allIndex{
            let nowNum = cards[index].rank
            if nowNum == -1{
                jokerNum += 1
            }
            else if lastNum - nowNum - 1 > jokerNum{
                if length < needCardsNum{
                    beginIndex = index + 1
                }
            }
            else{
                length += 1
            }
            
            if length >= needCardsNum{
                break
            }
        }
        allIndex = Array(beginIndex...cards.count-1)
        
        let allCombinations = allIndex.combinations(ofCount: needCardsNum)
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
            
            if needCardsNum == 3 && cntC == 2{
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
                            headRank = 5
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
                
                if gap > 0{
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
                
                rank = rank << 4 | headRank
                rank = rank << 2 | headSuit

                let cardType = "顺子" + String(headRank)
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
        }
        
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    
    func eval_threecard_turn3(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        if needCardsNum == 3{
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
                    
                    let cardType = "三条炸弹" + String(threeCardRank)
                    
                    rankList.append(rank)
                    cardTypeList.append(cardType)
                }
            }
        }
            
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    
    func eval_threecard(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
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
                
                let cardType = "三条" + String(threeCardRank)
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
        }
        
        return (rankList, cardTypeList, 0, usedCardIndexList)
    }
    
    func eval_twopair(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var cardTypeList: [String] = []
        var usedCardIndexList : [[Int]] = []
        
        if cards.count >= 5{
            let (pairRankList, pairCardTypeList, _, pairUsedCardIndexList) = eval_onepair(cards: cards, needCardsNum: needCardsNum)
            
            if pairUsedCardIndexList.count > 0 {
                
                for currentPairUsedCardIndex in pairUsedCardIndexList{
                    
                    var twopairCards: [ThirteenWaterCard] = []
                    var twopairCardsIndex: [Int] = []
                    for i in 0..<cards.count{
                        if !currentPairUsedCardIndex.contains(i){
                            twopairCards.append(cards[i])
                            twopairCardsIndex.append(i)
                        }
                    }
                    let (twopairRankList, twopairCardTypeList, _, twopairUsedCardIndexList) = eval_onepair(cards: twopairCards, needCardsNum: needCardsNum)
                    
                    if twopairUsedCardIndexList.count > 0{
                        for currentTwopairUsedCardIndex in twopairUsedCardIndexList{
                            usedCardIndexList.append([currentPairUsedCardIndex[0],currentPairUsedCardIndex[1],twopairCardsIndex[currentTwopairUsedCardIndex[0]],twopairCardsIndex[currentTwopairUsedCardIndex[1]]])
                        }
                    }
                }
            }
        }
        
        if usedCardIndexList.count > 0 {
            
            for currentUsedCardIndex in usedCardIndexList{
                var rank = 0
                
                var firstPairRank = cards[currentUsedCardIndex[1]].rank
                var firstPairSuit = cards[currentUsedCardIndex[0]].suit
                var secondPairRank = cards[currentUsedCardIndex[3]].rank
                var secondPairSuit = cards[currentUsedCardIndex[2]].suit
                
                if firstPairRank == 15{
                    firstPairRank = 14
                }
                if secondPairRank == 15{
                    secondPairRank = 14
                }
                if firstPairSuit == -1{
                    firstPairSuit = 0
                }
                if secondPairSuit == -1{
                    secondPairSuit = 0
                }
                
                rank = rank << 4 | firstPairRank
                rank = rank << 4 | secondPairRank
                rank = rank << 2 | firstPairSuit
                
                
                let cardType = "两对" + String(firstPairRank) + String(secondPairRank)
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
            
            
        }

        return (rankList, cardTypeList, 1, usedCardIndexList)
    }
    
    func eval_onepair(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
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
                if pairsuit == -1{
                    pairsuit = 0
                }
                                
                rank = rank << 4 | pairRank
                rank = rank << 2 | pairsuit
                
                
                let cardType = "对" + String(pairRank)
                
                rankList.append(rank)
                cardTypeList.append(cardType)
            }
            
            
        }

        return (rankList, cardTypeList, 1, usedCardIndexList)
    }

    func eval_holecard(cards: [ThirteenWaterCard], needCardsNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rank: Int = 0
        var usedCardIndexList : [Int] = []
        
        usedCardIndexList.append(0)
        
        for c in usedCardIndexList {
            if cards[c].rank == 15{
                rank = rank << 4 | 14
                rank = rank << 2 | 3
            }
            else{
                rank = rank << 4 | cards[c].rank
                rank = rank << 2 | cards[c].suit
            }
        }

        return ([rank], ["单牌"], 0, [usedCardIndexList])
    }
    
    class ThirteenWaterCard{
        var rank: Int = 0
        var suit: Int = 0
        var originRank : Int = 0
        
        init(card: Card){
            let rule = GameManager.gameRules[16] as! ThirteenWaterGameRule
            
            self.originRank = card.rank
            
            if card.rank == 14 || card.rank == 15{
                self.rank = 15
                self.suit = -1
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

}

