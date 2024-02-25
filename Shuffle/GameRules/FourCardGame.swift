
import Foundation
//import Python
//import PythonKit

//九点半

class FourCardGameRule : Rule{
    
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
        0:"同点一样大",
    ]
    let cardRankRule:[Int: String] = [
        0:"A最大，2最小"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            2: "对子",
            1: "单张",
            0: "四张点数"
        ]
        self.setting = [
            0: "4张比单张[410]",
            1: "4张9点[411]",
        ]
        self.ruleInfo = [
            0:"""
    52张牌，每人4张，分为2组牌
    1.最大 对A > 对K > ... 对2
    2.单张 A最大 2最小
    3.2组牌总点数最大为最大
    """,
            
            1:"""
    扑克张数 54张， 52张
    每人4张牌
    1.4张牌点数相加, 9点最大，0点最小。王 = 0点，J = 0点，Q = 0点，K = 0点
    """,

        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class FourCardGame{
    
    
    
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
            result = Array(0...51)
            break
        case 1:
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
            return playerNum * 4
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
    //10 cardRankRule


    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([Int],[Int],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let redJokerValueRange = args[3]
        let blackJokerValueRange = args[4]
        let KValueRange = args[5]
        let QValueRange = args[6]
        let JValueRange = args[7]
        let pointComparision = args[8]
        let samePointComparision = args[9]
        let cardRankRule = args[10]

        
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
        if dealNum == 0{
            for _ in 0..<4{
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
            allPlayCards[i].evaluateFlag = FourCardGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerValueRange: blackJokerValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,pointComparision: pointComparision,samePointComparision: samePointComparision,cardRankRule: cardRankRule)
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
        if leftCards.count < FourCardGame.getMinCardNum(playerNum: playerNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        print("winners \(winners)")
        return (winners, leftCards, winnerRanks)
    }
}

class FourCardGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([FourCardCard]) -> Int] = [:]
    var pointComparision:Int = 0
    var samePointComparision: Int = 0
    var cardRankRule: Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0:self.eval_isPoint(cards:),
            1:self.eval_isHighCard(cards:),
            2:self.eval_isPair(cards:),

        ]
    }
    
    func evalHand(cards: [Card],redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, pointComparision: Int, samePointComparision: Int, cardRankRule: Int)->Int{
        var cards = cards
        self.pointComparision = pointComparision
        self.samePointComparision = samePointComparision
        
        let num1 = FourCardCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        let num2 = FourCardCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
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
    
    func eval_isPair(cards:[FourCardCard]) -> Int{
        if cards[0].rank == cards[1].rank{
            return cards[0].rank << 2 | (cards[0].suit + cards[1].suit)
        }
        return 0
    }
    
    func eval_isHighCard(cards: [FourCardCard]) -> Int{
        return cards[0].rank
    }
    
    func eval_isPoint(cards:[FourCardCard]) -> Int {
        let point = cards.reduce(0){$0 + $1.rank} % 10
        return point << 4 | cards[0].rank
    }
    
    class FourCardCard{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var cardIndex: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int){
            let rule = GameManager.gameRules[12] as! FourCardGameRule
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

