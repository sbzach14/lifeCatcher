
import Foundation
//import Python
//import PythonKit

class ThreeCardPokerGameRule : Rule{
    let setting: [Int: String] = [
        0: "标准",
        1: "自定义"
    ]
    let ruleInfo:[Int: String] = [
        0:"""
共52张牌，A-K，A最大，一人发三张
大小比较：
10: "235",
6: "同花顺",
4: "同花",
3: "顺子",
2: "真对子",
1: "对子",
0: "散牌"
同牌型比最大牌，同点数比较花色
""",
        1:"""
自定义你的规则
"""
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8]
    let handNum: [Int] = [3,4,5,6,7,8,9,10,11,12]
    let minRank: [Int] = [2,3,4,5,6,7,8,9,10]
    let isCompareSuit : [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isAce:[Int: String] = [
        0: "无",
        1: "A最小",
        2: "A最大"
    ]
    let isAceStraight: [Int: String] = [
        0: "无",
        1: "最小顺",
        2: "最大顺",
        3: "第二大顺"
    ]
    let isHeadCard: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isReverseHighCard: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isRedJoker: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let redJokerSuit: [Int: String] = [
        0: "任意",
        1: "红色"
    ]
    let redJokerRank: [Int: String] = [
        14: "任意牌",
        13: "K",
        12: "Q",
        11: "J",
        10: "10",
        9: "9",
        8: "8",
        7: "7",
        6: "6",
        5: "5",
        4: "4",
        3: "3",
        2: "2",
        1: "A",
        0: "0",
    ]
    let isBlackJoker: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let blackJokerSuit: [Int: String] = [
        0: "任意",
        1: "红色"
    ]
    let blackJokerRank: [Int: String] = [
        14: "任意牌",
        13: "K",
        12: "Q",
        11: "J",
        10: "10",
        9: "9",
        8: "8",
        7: "7",
        6: "6",
        5: "5",
        4: "4",
        3: "3",
        2: "2",
        1: "A",
        0: "0"
    ]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            13: "对王",
            12: "三条",
            11: "同花235",
            10: "235",
            9: "同花AKJ",
            8: "AKJ",
            7: "三公",
            6: "同花顺",
            5: "同花对子",
            4: "同花",
            3: "顺子",
            2: "真对子",
            1: "对子",
            0: "散牌"
        ]
    }
}




//炸金花
class ThreeCardPokerGame{
    
    
    static func FindWinner(inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int]? {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let winners = calWinners(deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return winners
    }
    
    static func legalCheck(playerNum: Int, minRank: Int, handNum: Int, isHeadCard: Int, isRedJoker: Int, isBlackJoker: Int) -> String{
        var errMessage : String = ""
        if(playerNum * handNum > 52 - (minRank - 2) * 4 - isHeadCard * 12 + isRedJoker + isBlackJoker)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex(minRank: Int, isAce: Int, isHeadCard: Int, isRedJoker: Int, isBlackJoker: Int) -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...12{
                if rank == 0 && isAce != 0{
                    result.append(rank + i * 13)
                }
                else if (rank >= 10 || rank <= 12) && isHeadCard == 1{
                    result.append(rank + i * 13)
                }
                else if rank >= minRank - 1{
                    result.append(rank + i * 13)
                }
            }
        }
        if isBlackJoker == 1{
            result.append(53)
        }
        if isRedJoker == 1{
            result.append(54)
        }
        return result
    }
    
    static func getMinCardNum(playerNum: Int, handNum: Int) -> Int{
        return playerNum * handNum
    }
    
    
    static func calWinners(deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int] {
        let playerNum = args[0]
        let handNum = args[1]
        let isCompareSuit = args[2]
        let minRank = args[3]
        let isAce = args[4]
        let isAceStraight = args[5]
        let isHeadCard = args[6]
        let isRedJoker = args[7]
        let redJokerSuit = args[8]
        let redJokerRank = args[9]
        let isBlackJoker = args[10]
        let blackJokerSuit = args[11]
        let blackJokerRank = args[12]
        let isReverseHighCard = args[13]
        
        var maxRank = 0
        var winners: [Int] = []
        var allPlayCards: [Player] = []
        
        for _ in 0..<playerNum {
            allPlayCards.append(Player())
        }
        
        
        var deck = deck
        // 发牌
        for _ in 0..<handNum {
            for i in 0..<playerNum {
                allPlayCards[i].insertCard(card: deck.removeFirst())
            }
        }
        
        for i in 0..<playerNum {
            allPlayCards[i].evaluateFlag = ThreeCardPokerGameHandEvaluator(
                isCompareSuit: isCompareSuit,
                minRank: minRank,
                isAce: isAce,
                isAceStraight: isAceStraight,
                isHeadCard: isHeadCard,
                isRedJoker: isRedJoker,
                redJokerSuit: redJokerSuit,
                redJokerRank: redJokerRank,
                isBlackJoker: isBlackJoker,
                blackJokerSuit: blackJokerSuit,
                blackJokerRank: blackJokerRank,
                isReverseHighCard: isReverseHighCard,
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard)
        }
        
        winners = winners.sorted(by: { allPlayCards[$0].evaluateFlag > allPlayCards[$1].evaluateFlag })
        
        return winners
    }
}


class ThreeCardPokerGameHandEvaluator {
    
    var isCompareSuit: Int
    var minRank: Int
    var isAce: Int
    var isAceStraight: Int
    var isHeadCard: Int
    var isRedJoker: Int
    var redJokerSuit: Int
    var redJokerRank: Int
    var isBlackJoker: Int
    var blackJokerSuit: Int
    var blackJokerRank: Int
    var isReverseHighCard: Int
    var rankRules: [Int]
    var suitRules: [Int]
    var maxRank: Int
    
    init(isCompareSuit: Int,
          minRank: Int,
          isAce: Int,
          isAceStraight: Int,
          isHeadCard: Int,
          isRedJoker: Int,
          redJokerSuit: Int,
          redJokerRank: Int,
          isBlackJoker: Int,
          blackJokerSuit: Int,
          blackJokerRank: Int,
          isReverseHighCard: Int,
          rankRules: [Int],
          suitRules: [Int]){
        
        self.isCompareSuit = isCompareSuit
        self.minRank = minRank
        self.isAce = isAce
        self.isAceStraight = isAceStraight
        self.isHeadCard = isHeadCard
        self.isRedJoker = isRedJoker
        self.redJokerSuit = redJokerSuit
        self.redJokerRank = redJokerRank
        self.isBlackJoker = isBlackJoker
        self.blackJokerSuit = blackJokerSuit
        self.blackJokerRank = blackJokerRank
        self.isReverseHighCard = isReverseHighCard
        self.rankRules = rankRules
        self.suitRules = suitRules
        
        if isHeadCard == 1 {
            if isAce == 2 {
                self.maxRank = 14
            } else {
                self.maxRank = 13
            }
        } else {
            if isAce == 2 {
                self.maxRank = 11
            } else {
                self.maxRank = 10
            }
        }
        
        if minRank != 2 {
            if rankRules.contains(10) {
                self.rankRules.removeAll { $0 == 10 }
            }
            if rankRules.contains(11) {
                self.rankRules.removeAll { $0 == 11 }
            }
        }
        
        if isAce == 0 {
            if rankRules.contains(8) {
                self.rankRules.removeAll { $0 == 8 }
            }
            if rankRules.contains(9) {
                self.rankRules.removeAll { $0 == 9 }
            }
        }
        
        if isHeadCard == 0 {
            if rankRules.contains(7) {
                self.rankRules.removeAll { $0 == 7 }
            }
        }
    }
    
    func evalHand(cards: [Card])->Int{
        
        var sortedCards = sortCards(cards: cards)
        var maxScore = 0
        
        for sortedCards in sortedCards {
            let score = calcHandInfoFlg(sortedCards: sortedCards)
            if score > maxScore {
                maxScore = score
            }
        }
        
        return maxScore
    }
    
    func sortCards(cards: [Card]) -> [[Card]] {
        var cards = cards
        var allCards = [[Card]]()
        
        for i in 0..<3 {
            if cards[i].rank == 14 && isBlackJoker == 1 {
                if blackJokerRank == 14 {
                    cards[i].rank = -1
                } else {
                    cards[i].rank = blackJokerRank
                }
                if blackJokerSuit == 0 {
                    cards[i].suit = [3, 2, 1, 0]
                } else if blackJokerSuit == 1 {
                    cards[i].suit = [suitRules[0], suitRules[2]].sorted()
                }
            } else if cards[i].rank == 15 && isRedJoker == 1 {
                if redJokerRank == 14 {
                    cards[i].rank = -1
                } else {
                    cards[i].rank = redJokerRank
                }
                if redJokerSuit == 0 {
                    cards[i].suit = [3, 2, 1, 0]
                } else if redJokerSuit == 1 {
                    cards[i].suit = [suitRules[1], suitRules[3]].sorted()
                }
            } else if cards[i].rank == 1 {
                if isAce == 1 {
                    cards[i].rank = minRank - 1
                } else if isAce == 2 {
                    cards[i].rank = maxRank
                }
            }
        }
        
        var handCombinations = cards.combinations(ofCount: 3)
        for handCombination in handCombinations{
            allCards.append(handCombination)
            var aceList = Array(handCombination)
            if self.isAceStraight != 0 && self.isAce == 2{
                var isAdd = false
                for card in aceList{
                    if card.rank == self.maxRank{
                        card.rank = self.minRank - 1
                        isAdd = true
                    }
                }
                if isAdd{
                    allCards.append(aceList)
                }
            }
        }
        
        for var cards in allCards{
            cards.sort(by: { card1, card2 in
                return Card.calScore(card: card1) > Card.calScore(card: card2)
            })
        }
        
        return allCards
    }
    
    func calcHandInfoFlg(sortedCards: [Card]) -> Int {
        var rankResult = 0
        
        var ruleDict: [Int: ([Card]) -> Int] = [
            0  : self.eval_holecard,
            1  : self.eval_onepair,
            2  : self.eval_truepair,
            3  : self.eval_straight,
            4  : self.eval_flush,
            5  : self.eval_pairflush,
            6  : self.eval_straightflush,
            7  : self.eval_threehead,
            8  : self.eval_akj,
            9  : self.eval_akjflush,
            10 : self.eval_235,
            11 : self.eval_235flush,
            12 : self.eval_threecard,
            13 : self.eval_doubleJoker
        ]
        
        for (index, ruleIndex) in rankRules.enumerated() {
            var rankFlag = 1 << (rankRules.count - index + 18)
            var rankResult = ruleDict[ruleIndex]!(sortedCards) // 假设 ruleDict 是一个规则函数的字典
            
            if (isCompareSuit == 0) {
                rankResult >>= 6
            }
            
            if rankResult != 0 {
                rankResult |= rankFlag
                break
            }
        }

        
        return rankResult
    }
    
    func eval_doubleJoker(_ cards: [Card]) -> Int {
        var rank: Int = 0
        var cnt: Int = 0
        
        for i in 0..<3 {
            if cards[i].rank == -1 {
                cnt += 1
            }
        }
        
        if cnt == 2 {
            for _ in 1..<3 {
                rank = rank << 4 | maxRank
            }
            rank = rank << 4 | cards[0].rank
            for i in 1..<3 {
                rank = rank << 2 | cards[i].suit[0]
            }
            rank = rank << 4 | cards[0].suit[0]
        }
        else if cnt == 3 {
            for _ in 0..<3 {
                rank = rank << 4 | maxRank
            }
            for i in 0..<3 {
                rank = rank << 4 | cards[i].suit[0]
            }
        }
        
        return rank
    }
        
    func eval_threecard(_ cards: [Card]) -> Int {
        var rank: Int = 0
        var cnt: Int = 0
        
        var targetRank = cards[0].rank
        if targetRank == -1 {
            targetRank = maxRank
        }
        
        for i in 0..<3 {
            if cards[i].rank == targetRank || cards[i].rank == -1 {
                cnt += 1
            }
        }
        
        if cnt == 3 && targetRank != 0 {
            for _ in 0..<3 {
                rank = rank << 4 | targetRank
            }
            for i in 0..<3 {
                rank = rank << 2 | cards[i].suit[0]
            }
        }
        
        return rank
    }

    func eval_235flush(cards: [Card]) -> Int {
        var rank: Int = 0
        var cnt5: Int = 0
        var cnt3: Int = 0
        var cnt2: Int = 0
        var cntC: Int = 0

        for i in 0..<3 {
            if cards[i].rank == 5 {
                cnt5 = 1
            } else if cards[i].rank == 3 {
                cnt3 = 1
            } else if cards[i].rank == 2 {
                cnt2 = 1
            } else if cards[i].rank == -1 {
                cntC += 1
            }
        }

        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]

        for i in 0..<3 {
            for suit in cards[i].suit {
                    cntSuit[suit] += 1
            }
        }

        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if cnt5 + cnt3 + cnt2 + cntC == 3 && targetSuit != -1 {
            rank = rank << 4 | 5
            rank = rank << 4 | 3
            rank = rank << 4 | 2
            for _ in 0..<3 {
                rank = rank << 2 | targetSuit
            }
        }
        return rank
    }

    func eval_235(cards: [Card]) -> Int {
        var rank: Int = 0
        var cnt5: Int = 0
        var cnt3: Int = 0
        var cnt2: Int = 0
        var cntC: Int = 0

        for i in 0..<3 {
            if cards[i].rank == 5 {
                cnt5 = 1
            } else if cards[i].rank == 3 {
                cnt3 = 1
            } else if cards[i].rank == 2 {
                cnt2 = 1
            } else if cards[i].rank == -1 {
                cntC += 1
            }
        }

        if cnt5 + cnt3 + cnt2 + cntC == 3 {
            rank = rank << 4 | 5
            rank = rank << 4 | 3
            rank = rank << 4 | 2
            for i in 0..<3 {
                rank = rank << 2 | cards[i].suit[0]
            }
        }
        return rank
    }
    
    func eval_akjflush(cards: [Card]) -> Int {
        var rank: Int = 0
        var cntA: Int = 0
        var cntK: Int = 0
        var cntJ: Int = 0
        var cntC: Int = 0

        for i in 0..<3 {
            if cards[i].rank == maxRank || cards[i].rank == minRank - 1 {
                cntA = 1
            } else if cards[i].rank == 13 {
                cntK = 1
            } else if cards[i].rank == 11 {
                cntJ = 1
            } else if cards[i].rank == -1 {
                cntC += 1
            }
        }

        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]
        for i in 0..<3 {
            for suit in cards[i].suit {
                    cntSuit[suit] += 1
            }
        }
        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if cntA + cntK + cntJ + cntC == 3 && targetSuit != -1 {
            rank = rank << 4 | 14
            rank = rank << 4 | 13
            rank = rank << 4 | 11
            for _ in 0..<3 {
                rank = rank << 2 | targetSuit
            }
        }
        return rank
    }
    
    func eval_akj(cards: [Card]) -> Int {
        var rank: Int = 0
        var cntA: Int = 0
        var cntK: Int = 0
        var cntJ: Int = 0
        var cntC: Int = 0

        for i in 0..<3 {
            if cards[i].rank == maxRank || cards[i].rank == minRank - 1 {
                cntA = 1
            } else if cards[i].rank == 13 {
                cntK = 1
            } else if cards[i].rank == 11 {
                cntJ = 1
            } else if cards[i].rank == -1 {
                cntC += 1
            }
        }

        if cntA + cntK + cntJ + cntC == 3 {
            rank = rank << 4 | 14
            rank = rank << 4 | 13
            rank = rank << 4 | 11
            for i in 0..<3 {
                rank = rank << 2 | cards[i].suit[0]
            }
        }
        return rank
    }
    
    func eval_threehead(cards: [Card]) -> Int {
        var rank: Int = 0
        var cnt: Int = 0

        for i in 0..<3 {
            if cards[i].rank == 13 ||
               cards[i].rank == 12 ||
               cards[i].rank == 11 ||
               cards[i].rank == -1 {
                cnt += 1
            }
        }

        if cnt == 3 {
            for i in 0..<3 {
                if cards[i].rank == -1 {
                    rank = rank << 4 | 13
                } else {
                    rank = rank << 4 | cards[i].rank
                }
            }
            for i in 0..<3 {
                rank = rank << 2 | cards[i].suit[0]
            }
        }
        return rank
    }
    
    func eval_straightflush(cards: [Card]) -> Int {
        var rank: Int = 0
        var cntC: Int = 0
        var straightHead: Int = -1

        var rankList: [Int] = []
        for i in 0..<3 {
            if cards[i].rank == -1 {
                cntC += 1
            } else {
                rankList.append(cards[i].rank)
            }
        }

        if cntC == 3 {
            straightHead = 15
        } else if cntC == 2 {
            straightHead = min(self.maxRank, rankList[0] + 2)
        } else if cntC == 1 {
            if rankList[0] - rankList[1] == 1 {
                straightHead = min(self.maxRank, rankList[0] + 1)
            } else if rankList[0] - rankList[1] == 2 {
                straightHead = rankList[0]
            }
        } else {
            if rankList[0] - rankList[1] == 1 &&
               rankList[0] - rankList[2] == 2 &&
               rankList[2] != 0 {
                straightHead = rankList[0]
            }
        }

        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]
        for i in 0..<3 {
            for suit in cards[i].suit {
                cntSuit[suit] += 1
            }
        }
        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if targetSuit != -1 {
            if straightHead == self.minRank + 1 {
                if self.isAceStraight == 2 {
                    rank = rank << 4 | (self.maxRank + 1)
                    for i in 1..<3 {
                        rank = rank << 4 | (straightHead - i)
                    }
                    for _ in 0..<3 {
                        rank = rank << 2 | targetSuit
                    }
                } else if self.isAceStraight == 3 {
                    rank = rank << 4 | self.maxRank
                    for i in 1..<3 {
                        rank = rank << 4 | (straightHead - i)
                    }
                    for _ in 0..<3 {
                        rank = rank << 2 | targetSuit
                    }
                }
            }
            if straightHead != -1 {
                for i in 0..<3 {
                    rank = rank << 4 | (straightHead - i)
                }
                for _ in 0..<3 {
                    rank = rank << 2 | targetSuit
                }
            }
        }
        return rank
    }
    
    func eval_pairflush(cards: [Card]) -> Int {
        var rank: Int = 0

        var pairRank: Int = -1
        var singleRank: Int = -1
        var cntC: Int = 0
        var rankList: [Int] = []
        
        for i in 0..<3 {
            if cards[i].rank == -1 {
                cntC += 1
            } else {
                rankList.append(cards[i].rank)
            }
        }

        if cntC == 3 {
            pairRank = self.maxRank
            singleRank = self.maxRank
        } else if cntC == 2 {
            pairRank = self.maxRank
            singleRank = rankList[0]
        } else if cntC == 1 {
            pairRank = rankList[0]
            singleRank = rankList[1]
        } else {
            if rankList[0] == rankList[1] {
                pairRank = rankList[0]
                singleRank = rankList[2]
            } else if rankList[1] == rankList[2] {
                pairRank = rankList[1]
                singleRank = rankList[0]
            }
        }

        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]

        for i in 0..<3 {
            for suit in cards[i].suit {
                cntSuit[suit] += 1
            }
        }
        
        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if targetSuit != -1 && pairRank != -1 {
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for _ in 0..<3 {
                rank = rank << 2 | targetSuit
            }
        }
        return rank
    }
    
    func eval_flush(cards: [Card]) -> Int {
        var rank: Int = 0
        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]

        for i in 0..<3 {
            for suit in cards[i].suit {
                cntSuit[suit] += 1
            }
        }
        
        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if targetSuit != -1 {
            var jokerList: [Int] = []
            var normalList: [Int] = []
            
            for i in 0..<3 {
                if cards[i].rank == -1 {
                    jokerList.append(self.maxRank)
                } else {
                    normalList.append(cards[i].rank)
                }
            }

            for c in jokerList {
                rank = rank << 4 | c
            }
            
            for c in normalList {
                rank = rank << 4 | c
            }

            for _ in 0..<3 {
                rank = rank << 2 | targetSuit
            }
        }
        return rank
    }

    func eval_straight(cards: [Card]) -> Int {
        var rank: Int = 0
        var cntC: Int = 0
        var straightHead: Int = -1
        var rankList: [Int] = []
        var suitList: [Int] = []

        for i in 0..<3 {
            if cards[i].rank == -1 {
                cntC += 1
            } else {
                rankList.append(cards[i].rank)
            }
        }

        if cntC == 3 {
            straightHead = 15
            for i in 0..<3 {
                suitList.append(cards[i].suit[0])
            }
        }
        else if cntC == 2 {
            straightHead = min(self.maxRank, rankList[0] + 2)
            suitList.append(cards[0].suit[0])
            suitList.append(cards[1].suit[0])
            suitList.append(cards[2].suit[0])
        }
        else if cntC == 1 {
            if rankList[0] - rankList[1] == 1 {
                straightHead = min(self.maxRank, rankList[0] + 1)
                suitList.append(cards[2].suit[0])
                suitList.append(cards[0].suit[0])
                suitList.append(cards[1].suit[0])
            }
            else if rankList[0] - rankList[1] == 2 {
                straightHead = rankList[0]
                suitList.append(cards[0].suit[0])
                suitList.append(cards[2].suit[0])
                suitList.append(cards[1].suit[0])
            }
        }
        else {
            if rankList[0] - rankList[1] == 1 &&
                rankList[0] - rankList[2] == 2 &&
                rankList[2] != 0 {
                straightHead = rankList[0]
                for i in 0..<3 {
                    suitList.append(cards[i].suit[0])
                }
            }
        }

        if straightHead == self.minRank + 1 {
            if self.isAceStraight == 2 {
                rank = rank << 4 | self.maxRank + 1
                for i in 1..<3 {
                    rank = rank << 4 | (straightHead - i)
                }
                for i in 0..<3 {
                    rank = rank << 2 | suitList[i]
                }
            } else if self.isAceStraight == 3 {
                rank = rank << 4 | self.maxRank
                for i in 1..<3 {
                    rank = rank << 4 | (straightHead - i)
                }
                for i in 0..<3 {
                    rank = rank << 2 | suitList[i]
                }
            }
        } else if straightHead != -1 {
            for i in 0..<3 {
                rank = rank << 4 | (straightHead - i)
            }
            for i in 0..<3 {
                rank = rank << 2 | suitList[i]
            }
        }

        return rank
    }
    
    func eval_truepair(cards: [Card]) -> Int {
        var rank: Int = 0

        var pairRank: Int = -1
        var singleRank: Int = -1
        var cntC: Int = 0
        var suitList: [Int] = []

        for i in 0..<3 {
            if cards[i].rank == -1 {
                cntC += 1
            }
        }

        if cntC == 3 {
            pairRank = self.maxRank
            singleRank = self.maxRank
            if cards[0].suit[0] == cards[1].suit[0] {
                suitList.append(cards[0].suit[0])
                suitList.append(cards[1].suit[0])
                suitList.append(cards[2].suit[0])
            } else {
                suitList.append(cards[1].suit[0])
                suitList.append(cards[2].suit[0])
                suitList.append(cards[0].suit[0])
            }
        } else if cntC == 2 {
            if cards[1].suit[0] == cards[2].suit[0] {
                pairRank = self.maxRank
                singleRank = cards[0].rank
                suitList.append(cards[1].suit[0])
                suitList.append(cards[2].suit[0])
                suitList.append(cards[0].suit[0])
            } else if cards[0].suit.contains(cards[1].suit[0]) {
                pairRank = cards[0].rank
                singleRank = self.maxRank
                suitList.append(cards[0].suit[0])
                suitList.append(cards[0].suit[0])
                suitList.append(cards[2].suit[0])
            } else if cards[0].suit.contains(cards[2].suit[0]) {
                pairRank = cards[0].rank
                singleRank = self.maxRank
                suitList.append(cards[0].suit[0])
                suitList.append(cards[0].suit[0])
                suitList.append(cards[1].suit[0])
            }
        } else if cntC == 1 {
            if cards[0].suit.contains(cards[2].suit[0]) {
                pairRank = cards[0].rank
                singleRank = cards[1].rank
                suitList.append(cards[0].suit[0])
                suitList.append(cards[0].suit[0])
                suitList.append(cards[1].suit[0])
            } else if cards[1].suit.contains(cards[2].suit[0]) {
                pairRank = cards[1].rank
                singleRank = cards[0].rank
                suitList.append(cards[1].suit[0])
                suitList.append(cards[1].suit[0])
                suitList.append(cards[0].suit[0])
            }
        } else {
            if cards[0].rank == cards[1].rank && cards[0].suit.contains(cards[1].suit[0]) {
                pairRank = cards[0].rank
                singleRank = cards[2].rank
                suitList.append(cards[0].suit[0])
                suitList.append(cards[0].suit[0])
                suitList.append(cards[2].suit[0])
            }

            if cards[1].rank == cards[2].rank && cards[1].suit.contains(cards[2].suit[0]) {
                pairRank = cards[1].rank
                singleRank = cards[0].rank
                suitList.append(cards[1].suit[0])
                suitList.append(cards[1].suit[0])
                suitList.append(cards[0].suit[0])
            }
        }

        if pairRank != -1 {
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for i in 0..<3 {
                rank = rank << 2 | suitList[i]
            }
        }

        return rank
    }
    
    func eval_onepair(cards: [Card]) -> Int {
        var rank: Int = 0

        var pairRank: Int = -1
        var singleRank: Int = -1
        var cntC: Int = 0
        var suitList: [Int] = []

        for i in 0..<3 {
            if cards[i].rank == -1 {
                cntC += 1
            }
        }

        if cntC == 3 {
            pairRank = self.maxRank
            singleRank = self.maxRank
            for i in 0..<3 {
                suitList.append(cards[i].suit[0])
            }
        } else if cntC == 2 {
            pairRank = self.maxRank
            singleRank = cards[0].rank
            suitList.append(cards[1].suit[0])
            suitList.append(cards[2].suit[0])
            suitList.append(cards[0].suit[0])
        } else if cntC == 1 {
            pairRank = cards[0].rank
            singleRank = cards[1].rank
            suitList.append(cards[0].suit[0])
            suitList.append(cards[2].suit[0])
            suitList.append(cards[1].suit[0])
        } else {
            if cards[0].rank == cards[1].rank {
                pairRank = cards[0].rank
                singleRank = cards[2].rank
                suitList.append(cards[0].suit[0])
                suitList.append(cards[1].suit[0])
                suitList.append(cards[2].suit[0])
            } else if cards[1].rank == cards[2].rank {
                pairRank = cards[1].rank
                singleRank = cards[0].rank
                suitList.append(cards[1].suit[0])
                suitList.append(cards[2].suit[0])
                suitList.append(cards[0].suit[0])
            }
        }

        if pairRank != -1 {
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for i in 0..<3 {
                rank = rank << 2 | suitList[i]
            }
        }

        return rank
    }

    func eval_holecard(cards: [Card]) -> Int {
        var jokerList: [[Int]] = []
        var normalList: [[Int]] = []
        var rank: Int = 0

        if (self.isReverseHighCard != 0) {
            var minRank = self.minRank
            if self.isAce == 1 {
                minRank = self.minRank - 1
            }
            for i in 0..<3 {
                if cards[i].rank == -1 {
                    jokerList.append([minRank, cards[i].rank])
                } else {
                    normalList.append([cards[i].rank, cards[i].suit[0]])
                }
            }
            for c in jokerList {
                rank = rank << 4 | self.maxRank - c[0]
            }
            for c in normalList {
                rank = rank << 4 | self.maxRank - c[0]
            }
            for c in jokerList {
                rank = rank << 2 | c[1]
            }
            for c in normalList {
                rank = rank << 2 | c[1]
            }
        } else {
            for i in 0..<3 {
                if cards[i].rank == -1 {
                    jokerList.append([self.maxRank, cards[i].rank])
                } else {
                    normalList.append([cards[i].rank, cards[i].suit[0]])
                }
            }
            for c in jokerList {
                rank = rank << 4 | c[0]
            }
            for c in normalList {
                rank = rank << 4 | c[0]
            }
            for c in jokerList {
                rank = rank << 2 | c[1]
            }
            for c in normalList {
                rank = rank << 2 | c[1]
            }
        }

        return rank
    }

}
