

import Foundation

class TexasPlayer {
    var playerCard = [Card]()
    var evaluateFlag = 0
    
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
    static func calResult(cardArray: [Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int] {
        var deck = initDeck(initialCards: cardArray, suitRules: suitRules)
            let winners = calWinners(deck: &deck, args: args, rankRules: rankRules)
            return winners
        }
    
    static func calWinners(deck: inout [Card], args: [Int], rankRules: [Int]) -> [Int] {
        let playerNum = args[0]
        let isCompareSuit = args[1] == 1
        let isAceStraight = args[2] == 1
        let minRank = args[3]
        let handNum = args[4]
        let communityNum = args[5]
        let handUseType = args[6]
        let handUseNum = args[7]
        
        var maxRank = 0
        var winners = [Int]()
        var allPlayCards = [TexasPlayer]()
        var community = [Card]()
        
        for _ in 0..<playerNum {
            allPlayCards.append(TexasPlayer())
        }
        
        // 发牌
        for _ in 0..<handNum {
            for i in 0..<playerNum {
                allPlayCards[i].insertCard(card: deck.removeFirst())
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
        
        for i in 0..<playerNum {
            allPlayCards[i].evaluateFlag = TexasHandEvaluator.evalHand(cards: allPlayCards[i].playerCard, community: community, isCompareSuit: isCompareSuit, isAceStraight: isAceStraight, minRank: minRank, handUseType: handUseType, handUseNum: handUseNum, rankRules: rankRules)
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
        
        return winners
    }
}

class TexasHandEvaluator {
    
    static func evalHand(cards: [Card], community: [Card], isCompareSuit: Bool, isAceStraight: Bool, minRank: Int, handUseType: Int, handUseNum: Int, rankRules: [Int]) -> Int {
        let (cardsLength, allSortedCards) = sortCards(cards: cards, community: community, handUseType: handUseType, handUseNum: handUseNum, isAceStraight: isAceStraight, minRank: minRank)
        
        var maxScore = 0
        for sortedCards in allSortedCards {
            let score = calcHandInfoFlg(sortedCards: sortedCards, isCompareSuit: isCompareSuit, rankRules: rankRules, cardsLength: cardsLength)
            if score > maxScore {
                maxScore = score
            }
        }
        return maxScore
    }
    
    static func sortCards(cards: [Card], community: [Card], handUseType: Int, handUseNum: Int, isAceStraight: Bool, minRank: Int) -> (Int, [[Card]]) {
        var allCards = [[Card]]()
        var cardsLength = 0
        
        for card in cards {
            if card.rank == 1 {
                card.rank = 14
            }
        }
        
        for card in community {
            if card.rank == 1 {
                card.rank = 14
            }
        }
        
        if handUseType == 0 {
            allCards.append(cards + community)
            cardsLength = cards.count + community.count
        } else if handUseType == 1 {
            cardsLength = 5
            let communityNum = 5 - handUseNum
            let handCombinations = cards.combinations(ofCount: handUseNum)
            let communityCombinations = community.combinations(ofCount: communityNum)
            
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
                let handCombinations = cards.combinations(ofCount: handNum)
                let communityCombinations = community.combinations(ofCount: communityNum)
                
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
        
        for var cardsList in allCards {
            if isAceStraight {
                var aceCards = [Card]()
                for card in cardsList {
                    if card.rank == 14 {
                        aceCards.append(Card(suit: card.suit, rank: minRank - 1))
                    }
                }
                cardsList += aceCards
            }
            cardsList.sort(by: { card1, card2 in
                return Card.calScore(card: card1) > Card.calScore(card: card2)
            })
        }
        
        return (cardsLength, allCards)
    }
    
    static func calcHandInfoFlg(sortedCards: [Card], isCompareSuit: Bool, rankRules: [Int], cardsLength: Int) -> Int {
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
        for (index, ruleIndex) in rankRules.enumerated() {
            let rankFlag = 1 << (rankRules.count - index + 23)
            rankResult = ruleDict[ruleIndex]!(sortedCards, cardsLength)
            if !isCompareSuit {
                rankResult >>= 2
            }
            if rankResult != 0 {
                rankResult |= rankFlag
                break
            }
        }
        
        return rankResult
    }
    
    static func evalStraightFlush(cards: [Card], cardsLength: Int) -> Int {
        var rank = 0
        for suit in [3, 2, 1, 0] {
            var rankList = [Int]()
            var cnt = 1
            var straightHeadRank = 0
            
            for i in 0..<cards.count {
                if cards[i].suit[0] == suit {
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
                        straightHeadRank = i
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
            for i in 0..<(cards.count - 1) {
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
                        rank = rank << 2 | card.suit[0]
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
                        rank = rank << 2 | card.suit[0]
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
            rank = rank << 2 | cards[0].suit[0]
            return rank
        }
    
    
}

// Helper extension for combinations
extension Array {
    func combinations(ofCount count: Int) -> [[Element]] {
        if count == 0 {
            return [[]]
        }
        guard !isEmpty else {
            return []
        }
        if count >= self.count {
            return [self]
        }
        if count == 1 {
            return self.map { [$0] }
        }
        var result: [[Element]] = []
        for (index, element) in self.enumerated() {
            var reduced = self
            reduced.removeFirst(index + 1)
            let subcombinations = reduced.combinations(ofCount: count - 1)
            for subcombination in subcombinations {
                result.append([element] + subcombination)
            }
        }
        return result
    }
}

