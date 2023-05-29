import Foundation

class TexasPoker_Deprecated{

    static func findWinningPlayer(inputCards: [Int], playerNum: Int) -> [Int]? { 
        guard inputCards.count == 52 && playerNum > 0 && playerNum <= 22 else { return nil }
        
        var cards = inputCards
        
        //var cards : [Int] = [47, 10, 33, 38, 22, 25, 35, 7, 32, 31, 41, 50, 28, 6, 3, 9, 20, 4, 16]
        
        // 按规则分配底牌给每个玩家
        var players = [[Int]]()
        // 按顺序给每个玩家发一张牌，再发第二张牌 .... i,j被弄反了,我直接改了, 而且这时候要把牌扔掉.....
        for k in 0..<playerNum { players.append( [ cards[k],cards[k+playerNum]] ) }
        for _ in 0..<2*playerNum { cards.removeFirst() }

        // 公共牌
        var communityCards = [Int]()
        
        
        
        // 翻牌，一次性翻开3张牌
        cards.removeFirst()
        for _ in 0..<3 {
            if let flopCard = cards.first {
                communityCards.append(flopCard)
                cards.removeFirst()
            }
        }
        
        // 转牌，再翻开一张牌
        cards.removeFirst()
        if let turnCard = cards.first {
            communityCards.append(turnCard)
            cards.removeFirst()
        }
        
        // 河牌，再翻开一张牌
        cards.removeFirst()
        if let riverCard = cards.first {
            communityCards.append(riverCard)
            cards.removeFirst()
        }
        

        let winners = texasPokerEval(holeCards:players, communityCards: communityCards)
        return winners
    }
    
    
    
    
    static func texasPokerEval(holeCards: [[Int]], communityCards: [Int]) -> [Int] {
        
        
        // 将数字转换为形如 "As", "Ks" 的字符串表示形式
        let holeCardsStr: [[String]] = holeCards.map(_: { $0.map(_:  {intToStr(card : $0)} ) })
        let communityCardsStr: [String] = communityCards.map(_: {intToStr(card : $0)} )

        
    
        //TODO: fix cal rank
        // texasPokerEval.hand_score() take in an array of 7 Cards(String) and output a list of winners
        
        var maxScore : Int = -1
        var winners: [Int] = []


        
        var kthHand : [String] = []
        var kthScore : Int = 0
        for k in 0..<holeCards.count {
            kthHand   = holeCardsStr[k] + communityCardsStr
            kthScore = handScore(hand : kthHand)
            print(kthScore)
            if  kthScore == maxScore {
                winners.append(k)
            } else if kthScore > maxScore {
                maxScore = kthScore
                winners.removeAll()
                winners.append(k)
            }         
        }
        return winners
    }
    
    
    
    
    
    static func handScore(hand : [String]) -> Int{
        // will use integer to represent strength of a hand
        // returns [4bitType of hands] [4bitRank * 5]

        var handSorted = hand.sorted(by:compareCards)
        handSorted.reverse()
        
        var maxScore = -1
        maxScore = max(maxScore,checkStraightflush(handSorted: handSorted))
        maxScore = max(maxScore,checkFourcards(handSorted: handSorted))
        maxScore = max(maxScore,checkFullhouse(handSorted: handSorted))
        maxScore = max(maxScore,checkFlush(handSorted: handSorted))
        maxScore = max(maxScore,checkStraight(handSorted: handSorted))
        maxScore = max(maxScore,checkThreecards(handSorted: handSorted))
        maxScore = max(maxScore,checkTwopairs(handSorted: handSorted))
        maxScore = max(maxScore,checkOnepair(handSorted: handSorted))
        maxScore = max(maxScore,checkHighcard(handSorted: handSorted))
        return maxScore
    }
    
    
    //Check straightflush
    static func checkStraightflush(handSorted : [String]) -> Int{
        var isStraight : Bool
        var isFlush : Bool
        
        for i in 0...2{
            isStraight = cardToInt(card:handSorted[i]) == cardToInt(card:handSorted[i+1])+1
            isStraight = isStraight && cardToInt(card:handSorted[i+1]) == cardToInt(card:handSorted[i+2])+1
            isStraight = isStraight && cardToInt(card:handSorted[i+2]) == cardToInt(card:handSorted[i+3])+1
            isStraight = isStraight && cardToInt(card:handSorted[i+3]) == cardToInt(card:handSorted[i+4])+1
            if isStraight{
                let c : Character = Array(handSorted[i])[1]
                isFlush = c==Array(handSorted[i+1])[1]
                isFlush = isFlush && c==Array(handSorted[i+2])[1]
                isFlush = isFlush && c==Array(handSorted[i+3])[1]
                isFlush = isFlush && c==Array(handSorted[i+4])[1]
                if isFlush {return (straightflush<<20)|(cardToInt(card:handSorted[i])<<16)}
            }
        }
        return -1
    }
    
    
    //Check fourcards
    static func checkFourcards(handSorted : [String]) -> Int{
        var rank : Int
        var remain : Int
        for i in 0...3{
            rank = cardToInt(card:handSorted[i])
            if rank==cardToInt(card:handSorted[i+1]) && rank==cardToInt(card:handSorted[i+2]) && rank==cardToInt(card:handSorted[i+3]){
                remain = cardToInt(card:handSorted[i==0 ? 4 : 0])
                return (fourcards<<20)|(rank<<16)|(remain<<12)
            }
            
        }
        return -1
    }
    
    
    
    //Check fullhouse
    static func checkFullhouse(handSorted : [String]) -> Int{
        var rank : Int
        var remain : Int
        for i in 0...4{
            rank = cardToInt(card:handSorted[i])
            if rank==cardToInt(card:handSorted[i+1]) && rank==cardToInt(card:handSorted[i+2]){
                if i>=2 {
                    for j in 0...i-2{
                        let m : Int = cardToInt(card: handSorted[j])
                        if m==cardToInt(card: handSorted[j+1]){
                            remain = m
                            return (fullhouse<<20)|(rank<<16)|(remain<<12)
                        }}}
                if i<=2{
                    for j in i+3...6{
                        let m : Int = cardToInt(card: handSorted[j])
                        if m==cardToInt(card: handSorted[j+1]){
                            remain = m
                            return (fullhouse<<20)|(rank<<16)|(remain<<12)
                        }}}}
        }
        return -1
    }
    
    
    //Check flush
    static func checkFlush(handSorted : [String]) -> Int {
        var suitDict : [Character:Int] = ["s":0,"h":0, "c":0, "d":0]
        for card in handSorted{
            let suit : Character = Array(card)[1]
            let count = suitDict[suit]!
            suitDict[suit] = count+1
        }
        for (suit,count) in suitDict{
            if count>=5{
                var sameSuit : [Int] = []
                for card in handSorted{
                    if suit==Array(card)[1]{
                        sameSuit.append(cardToInt(card:card))
                    }
                }
                return (flush<<20) | (sameSuit[0]<<16) | (sameSuit[1]<<12) | (sameSuit[2]<<8) | (sameSuit[3]<<4) | (sameSuit[4]<<0)
            }
        }
        return -1
    }
    
    
    //Check straight
    static func checkStraight(handSorted : [String]) -> Int{
        var isStraight : Bool
        for i in 0...2{
            isStraight = cardToInt(card:handSorted[i]) == cardToInt(card:handSorted[i+1])+1
            isStraight = isStraight && cardToInt(card:handSorted[i+1]) == cardToInt(card:handSorted[i+2])+1
            isStraight = isStraight && cardToInt(card:handSorted[i+2]) == cardToInt(card:handSorted[i+3])+1
            isStraight = isStraight && cardToInt(card:handSorted[i+3]) == cardToInt(card:handSorted[i+4])+1
            if isStraight {return (straight<<20) | (cardToInt(card:handSorted[i])<<16) }
        }
        return -1
    }
    
    
    //Check threecards
    static func checkThreecards(handSorted : [String]) -> Int{
        var rank1 : Int = 0
        var rank2 : Int = 0
        var rank3 : Int = 0
        for i in 0...4{
            rank1 = cardToInt(card:handSorted[i])
            if rank1==cardToInt(card:handSorted[i+1]) && rank1==cardToInt(card:handSorted[i+2]){
                if i==0 {
                    rank2=cardToInt(card:handSorted[3])
                    rank3=cardToInt(card:handSorted[4])
                } else if i==1{
                    rank2=cardToInt(card:handSorted[0])
                    rank3=cardToInt(card:handSorted[4])
                } else{
                    rank2=cardToInt(card:handSorted[0])
                    rank3=cardToInt(card:handSorted[1])
                }

            return (threecards<<20) | (rank1<<16) | (rank2<<12) | (rank3<<8)
            }
           
        }
        return -1
    }
    
    
    
    //Check twopairs
    static func checkTwopairs(handSorted : [String]) -> Int{
        var rank1 : Int = 0
        var rank2 : Int = 0
        var rank3 : Int = 0
        for i in 0...3{
            rank1 = cardToInt(card:handSorted[i])
            if rank1 == cardToInt(card:handSorted[i+1]){
                for j in i+2...5{
                    rank2 = cardToInt(card:handSorted[j])
                    if rank2 == cardToInt(card:handSorted[j+1]) {
                        if i==0 && j==2{
                            rank3 = cardToInt(card:handSorted[4])
                        }else if i==0 && j>=3{
                            rank3 = cardToInt(card:handSorted[3])
                        }
                        else{
                            rank3 = cardToInt(card:handSorted[0])
                        }
                        return (twopairs<<20) | (rank1<<16) | (rank2<<12) | (rank3<<8)
                    }
                }
            }
        }
        return -1
    }
    
    
    
    //Check onepair
    static func checkOnepair(handSorted : [String]) -> Int{
        var rank1 : Int = 0
        let rank2 : Int = 0
        let rank3 : Int = 0
        let rank4 : Int = 0
        for i in 0...5{
            rank1 = cardToInt(card:handSorted[i])
            if rank1 == cardToInt(card:handSorted[i+1]){
                return (onepair<<20) | (rank1<<16) | (rank2<<12) | (rank3<<8) | (rank4<<4)
            }
        }
        return -1
    }
    
    
    //Check highcard
    static func checkHighcard(handSorted : [String]) -> Int{
        let rank1 : Int = cardToInt(card:handSorted[0])
        let rank2 : Int = cardToInt(card:handSorted[1])
        let rank3 : Int = cardToInt(card:handSorted[2])
        let rank4 : Int = cardToInt(card:handSorted[3])
        let rank5 : Int = cardToInt(card:handSorted[4])
        return (highcard<<20) | (rank1<<16) | (rank2<<12) | (rank3<<8) | (rank4<<4) | (rank5<<0)
    }
    
    
    
    
    // made a mistake, A2345 should be the minimal straight
    static var highcard=0  //      <~800000
    static var onepair=1  //      <~2000000
    static var twopairs=2  //     <~3000000
    static var threecards=3  //   <~4000000
    static var straight=4  //     <~5000000
    static var flush=5  //        <~6000000
    static var fullhouse=6  //    <~7100000
    static var fourcards=7  //    <~8200000
    static var straightflush=8  // ~9200000
    static var pokerToIntDict:[Character:Int]=["2":2,"3":3,"4":4,"5":5,"6":6,"7":7,"8":8,"9":9,"T":10,"J":11,"Q":12,"K":13,"A":14]
    static func cardToInt(card:String) -> Int { return pokerToIntDict[Array(card)[0]]! }
    static func compareCards(card0:String,card1:String) -> Bool { return cardToInt(card:card0)<cardToInt(card:card1) }
    
    static func intToStr(card: Int) -> String {
        // intput from 0...51
        let suits: [String] = ["s", "h", "c", "d"]
        let ranks: [String] = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"]
        let suit = suits[card / 13]
        let rank = ranks[card % 13]
        return rank + suit
    }
    
    
}
