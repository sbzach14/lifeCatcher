import Foundation

class Card {
    var suit: [Int]
    var rank: Int
    var cardIndex: Int
    let originalRank: Int
    
    init(suit: [Int], rank: Int, cardIndex: Int) {
        self.suit = suit
        self.rank = rank
        self.originalRank = rank
        self.cardIndex = cardIndex
    }
    
    static func calScore(card: Card) -> Int {
        return card.rank * 10 + card.suit.max()!
    }
}


class Player {
    var playerCard = [Card]()
    var evaluateFlag = 0
    var cardType: String = ""
    var cardSuit: String = ""
    var isPair: Int = 0
    
    func insertCard(card: Card) {
        playerCard.append(card)
    }
}


func initDeck(initialCards: [Int], suitRules: [Int]) -> [Card] {
    var deckList = [Card]()
    
    for cardIndex in initialCards {
        if cardIndex < 52 {
            deckList.append(Card(suit: [suitRules[cardIndex / 13]], rank: cardIndex % 13 + 1, cardIndex: cardIndex))
        } else {
            if cardIndex == 53 {
                deckList.append(Card(suit: [0], rank: 14, cardIndex: cardIndex))
            } else if cardIndex == 54 {
                deckList.append(Card(suit: [0], rank: 15, cardIndex: cardIndex))
            }
        }
    }
    
    return deckList
}

func randomCardArray(cardNum: Int) -> [Int] {
    var cardArray = [Int]()
    
    if cardNum == 52 {
        for suit in 0..<4 {
            for rank in 0..<13 {
                cardArray.append(suit * 13 + rank)
            }
        }
    } else if cardNum == 40 {
        for suit in 0..<4 {
            for rank in 0..<10 {
                cardArray.append(suit * 13 + rank)
            }
        }
    }
    
    cardArray.shuffle()
    return cardArray
}

func showCardArray(cardArray: [Int]) {
    let suitDic = ["S", "H", "C", "D"]
    
    for card in cardArray {
        print("\(card % 13 + 1)\(suitDic[card / 13]) ", terminator: "")
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
            if reduced.count < count - 1{
                break
            }
            let subcombinations = reduced.combinations(ofCount: count - 1)
            for subcombination in subcombinations {
                result.append([element] + subcombination)
            }
        }
        return result
    }
}
