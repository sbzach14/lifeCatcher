
import Foundation
//import Python
//import PythonKit

//九点半

class CardNineGameRule : Rule{
    
    let redJokerValueRange:[Int:String] = [
        0:"6"
    ]
    let blackJokerValueRange: [Int: String] = [
        0:"6"
    ]
    let KValueRange:[Int:String] = [
        0:"3",
    ]
    let QValueRange:[Int:String] = [
        0:"2",
    ]
    let JValueRange:[Int:String] = [
        0:"1"
    ]
    let pointComparision:[Int: String] = [
        0:"9点最大，0点最小",
    ]
    let samePointComparision:[Int: String] = [
        0:"同点比最大牌，最大牌相同时庄家赢",
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            4: "对子",
            3: "Q + 9",
            2: "Q + 8",
            1: "2 + 8",
            0: "点数"
        ]
        self.setting = [
            0: "杭州小牌九",
            1: "自定义牌九",
        ]
        self.ruleInfo = [
            0:"""
    杭州小牌九 一共32张，每家发2张牌。
    1、选牌
      红心2、方块2、黑桃4、红心4、梅花4、方块4、黑桃5、红心5、黑桃6、红心6、梅花6、方块6、黑桃7、红心7、梅花7、方块7、黑桃8、红心8、梅花8、方块8、黑桃9、红心9、  黑桃10、红心10、梅花10、方块10、黑桃J、梅花J、红心Q、方块Q、大王、黑桃3
    2、大小顺序：
    1）最大：对子，分红对和黑对, 同点红对 > 混对 > 黑对
    2）不成对时，Q+9 > Q+8 > 2+8 > 9点，0点最小，大王=6点，黑桃3=3点，J=1点，Q=2点
    3）同点时比最大牌
    4）最大牌也相同时，庄家赢。
    """,
            1:"""
    自定义你的规则
    """,

        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class CardNineGame{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards, winnerRanks) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards, winnerRanks)
    }
    
    static func legalCheck(playerNum: Int) -> String{
        var errMessage : String = ""
        if(playerNum * 2 > 52)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllCardIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = [14,40,3,16,29,42,4,17,5,18,31,44,6,19,32,45,7,20,33,46,8,22,9,22,35,48,10,36,24,50,54,2]
            break
        default:
            result = Array(0...51) + [53,54]
            break
        }
        
        return result
    }
    
    static func getMinCardNum(playerNum: Int,dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
        if dealType == 0 || dealType == 1{
            return playerNum * 2
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
    //3 redJokerValueRange
    //4 blackJokerValueRange
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 pointComparision
    //9 samePointComparision


    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        let dealType = args[0]
        let diyDealType = args[1]
        let playerNum = args[2]
        let redJokerValueRange = args[3]
        let blackJokerValueRange = args[4]
        let KValueRange = args[5]
        let QValueRange = args[6]
        let JValueRange = args[7]
        let pointComparision = args[8]
        let samePointComparision = args[9]

        
        var maxRank = 0
        var winners: [Int] = []
        var winnerRanks: [Int] = []
        var allPlayCards: [Player] = []
        var community = [Card]()
        if deck.count < self.getMinCardNum(playerNum: playerNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([], [], [])
        }
        
        for _ in 0..<playerNum {
            allPlayCards.append(Player())
        }
        
        
        var deck = deck
        // 发牌
        if dealType == 0 || dealType == 1{
            for _ in 0..<2 {
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
        } else {
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
            allPlayCards[i].evaluateFlag = CardNineGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerValueRange: blackJokerValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,pointComparision: pointComparision,samePointComparision: samePointComparision)
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
        if leftCards.count < CardNineGame.getMinCardNum(playerNum: playerNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        print("winners \(winners)")
        return (winners, leftCards, winnerRanks)
    }
}

class CardNineGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([CardNineCard]) -> Int] = [:]
    var pointComparision:Int = 0
    var samePointComparision: Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0:self.eval_isPoint(cards:),
            1:self.eval_is2Plus8(cards:),
            2:self.eval_isQPlus8(cards:),
            3:self.eval_isQPlus9(cards:),
            4:self.eval_isPair(cards:)
        ]
    }
    
    func evalHand(cards: [Card],redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, pointComparision: Int, samePointComparision: Int)->Int{
        var cards = cards
        self.pointComparision = pointComparision
        self.samePointComparision = samePointComparision
        
        let num1 = CardNineCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        let num2 = CardNineCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        var numList = [num1, num2]
        numList = numList.sorted(by: {$0.rank > $1.rank})
        
        print("手牌 \(GameManager.cardLabelDic[numList[0].cardIndex])  \(GameManager.cardLabelDic[numList[1].cardIndex]) rank \(numList[0].rank) \(numList[1].rank) point \(numList[0].point) \(numList[1].point) suit \(numList[0].suit) \(numList[1].suit)")
        
        var score = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let rank = self.ruleDict[ruleIndex]!(numList)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 8)) | rank
                print("牌型 \(ruleIndex) rank \(score) i \(i)")

                break
            }
        }
        
        return score
    }
    
    func eval_isPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank{
            return cards[0].rank << 2 | (cards[0].suit + cards[1].suit)
        }
        return 0
    }
    func eval_isQPlus9(cards: [CardNineCard]) -> Int {
        if cards[0].rank == 12 && cards[1].rank == 9{
            return 1
        }
        return 0
    }
    func eval_isQPlus8(cards: [CardNineCard]) -> Int {
        if cards[0].rank == 12 && cards[1].rank == 8{
            return 1
        }
        return 0
    }
    func eval_is2Plus8(cards: [CardNineCard]) -> Int {
        if cards[0].rank == 8 && cards[1].rank == 2{
            return 1
        }
        return 0
    }
    func eval_isPoint(cards:[CardNineCard]) -> Int {
        let point = (cards[0].point + cards[1].point) % 10
        return point << 4 | cards[0].rank
    }
    
    class CardNineCard{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var cardIndex: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int){
            let rule = GameManager.gameRules[9] as! CardNineGameRule
            self.cardIndex = card.cardIndex
            //Rank Initialization
            self.rank = card.rank
            //suit Initialization
            self.suit = card.suit[0]
            //Point Initialization
            if card.rank == 15 {
                self.point =  Int(rule.redJokerValueRange[redJokerValueRange]!)!
            }
            else if card.rank == 14 {
                self.point = Int(rule.blackJokerValueRange[blackJokerValueRange]!)!
            }
            else if card.rank == 13 {
                self.point = Int(rule.KValueRange[KValueRange]!)!
            }
            else if card.rank == 12 {
                self.point = Int(rule.QValueRange[QValueRange]!)!
            }
            else if card.rank == 11 {
                self.point = Int(rule.JValueRange[JValueRange]!)!
            } else {
                self.point = card.rank
            }
        }
    }

}

