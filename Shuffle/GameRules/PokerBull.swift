//
//  PokerBull.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/16/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
//import Python
//import PythonKit

class PokerBullRule : Rule{
    let setting: [Int: String] = [
        0: "标准五张牛牛52张牌",
        1: "标准五张牛牛54张牌",
        2: "牛牛40张牌",
        3: "牛牛54张牌2",
        4: "牛牛54张牌3",
        5: "牛牛54张牌4",
        6: "益阳40张牛牛",
        7: "义乌斗牛",
        8: "牛牛54张牌5",
        9: "自定义"
    ]
    
    let ruleInfo:[Int:String] = [
        0: """
发52张牌，没有大小王，每家5张牌。
1)选其中三张组牛，三张牌的点数相加为0的为牛(K，Q，J，10为0点).
2)若能组成牛的，再统计剩下的两张的点数，为几就称为牛几。
3)若同牛同点比最大的牌。
4) 若不能组成牛，比最大的牌
""",
        1:"""
54张牌，每家5张牌
1)选其中三张组牛，三张牌的点数相加为0的为牛(W，K，Q, J，10为0点)
2)若能组成牛的，再统计剩下的两张的点数，为几就称为牛几
3)若同牛同点比最大的牌
4)若不能组成牛，比最大的牌
""",
        2:"""
40张牌，1-10，每家5张牌。
1)选其中三张组牛，三张牌的点数相加为0的为牛。
2)若能组成牛的，再统计剩下的两张的点数，为几就称为牛几。3)若同牛同点比最大的牌。4)若不能组成牛，比最大的牌
""",
        3:"""
54张牌，每家5张牌
1)选其中三张组牛，三张牌的点数相加为0的为牛(W，K，Q, J，10为0点)
2)五张牌加起来是0也称为牛
3)若能组成牛的，再统计剩下的两张的点数，为几就称为牛几
4)若同牛同点比最大的牌
5)若不能组成牛，比最大的牌
""",
        4:"""
54张牌，每家5张牌，选其中三张组牛。
1)三张牌的点数相加为0的为牛(W，K，Q，J，10为0点)。
2)三张牌数字一样为牛。
3)三张顺子为牛。
4)若能组成牛的，再统计剩下的两张的点数，为几就称为牛几。
5)若同牛同点比最大的牌。
6)若不能组成牛，比最大的牌
""",
        5:"""
54张斗牛:
54张牌，每家5张牌
1)五花 (JQKW任意5张)，比最大牌
2)四条
3) 五小(所有等于5和比5小的报牌)，比最大牌
4)牛 有三张牌点数相加为0的为牛。大小王JQK为0点，A-9分别算1-9点10算0点。若能组成牛
的，再统计剩下的两张的点数，为几就称为牛几(牛10也称为牛牛)若同牛同点比最大的牌大王>小王>黑头K>....方片A
5) 单张 比最大牌 大王>小王>黑头K>...方片A
""",
        6:"""
益阳40张斗牛:
益阳斗牛 (1-10)，40张全选。1，炸弹:4条加一张单牌，同是炸弹比炸弹的大小。
2，5大:5张牌点数加起来超过40点，同点情况下比最大牌。
3，5小:5张牌点数加起来小于10点，同点情况下比最小牌。
4，葫芦: 3条加1对，同是葫芦比三条大小。
5，一条龙:5张顺子，清色大于杂色，同杂色比最大牌。同样大小的清色顺子，黑红梅方排序;
6，铁板牛牛: 3条加2张单牌，切2单牌点数和为0点，同是铁板牛牛比3条大小。
7，其他和常规斗牛一样。
""",
        7:"""
义乌斗牛玩法:
54张牌，单牌比最大，
K>Q>J>10>大王>小王...3>2>1，每人5张
声同牛同点比最大的牌若不能组成牛，比最大的牌，只
不过大小王比KQJ10小，都算0点
""",
        8:"""
54张，
数字比较： k>q>j>10>9>8>7>6>5>4>3>2>a。
花色比较：黑桃>红桃>梅花>方块。
牌型比较：无牛<有牛<牛牛<银牛<金牛<炸弹<五小牛。
无牛牌型比较：取其中最大的一张牌比较大小，牌大的赢，大小相同比花色。
有牛牌型比较：比牛数；牛数相同庄吃闲。
牛牛牌型比较：取其中最大的一张牌比较大小，牌大的赢，大小相同比花色。
银牛牌型比较：取其中最大的一张牌比较大小，牌大的赢，大小相同比花色。
金牛牌型比较：取其中最大的一张牌比较大小，牌大的赢，大小相同比花色。
炸弹之间大小比较：取炸弹牌比较大小。
五小牛牌型比较：庄吃闲。
""",
        9:"""
自定义你的规则
"""
    ]
    let playerNum : [Int] = [2,3,4,5,6,7,8]
    //TODO: 加入总牌数量来限制规则的选择，当前为所有规则都能选择
    let cardsNum : [Int] = [
        20,//1-10 不分黑红
        32,//4，6，7，8，10全选，2，5，9，J，Q各选两张，王一张，3一张
        36,//1-9
        40,//1-10
        42,//1-10，加两个王
        52,//1-k
        54//1-k, 大小王
    ]
    let handNum :[Int] = [3,4,5]
    let wayToDeal:[Int:String] = [
        0:"一人发一张牌",
        ]
    let isCompareSuit : [Int: String] = [
        0: "否",
        1: "是"
    ]
    let fiveLittleRank : [Int:String] = [
        0:"五小一样大",
        1:"五小谁小谁大",
        2:"五小谁大谁大",
        3:"比较最大牌"
    ]
    
    let secondRankRule:[Int:String] = [
        0:"同牛同点比最大的牌，无牛也比最大的牌",
        1:"同牛同点比牛架后两张，无牛比最大的牌",
        2:"同牛同点一样大，无牛一样大",
    ]
    
    let jokerIsMinZero:[Int:String] = [
        0:"否",
    ]
    
    let BullRules: [Int:String] = [
        0:"任意三张牌点数之和是10的倍数",
        1:"三条",
        2:"所有的牌点数之和是10的倍数",
        3:"三张牌组成的顺子",
        4:"只有jkq大小王（牛牛）",
        5:"三张牌点数相加是1",
        6:"五张牌点数相加小于10，相加是几就是牛几",
        7:"五张牌相加小于等于9",
        8:"任意三张牌点数之和是10的倍数并且大于20点",
    ]
    let tenValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"1/0（计算点数时还是10）",
        3:"1/0（计算点数时是0/1）"
    ]
    
    let JValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"11",
    ]
    let QValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"2",
        3:"12",
    ]
    
    let KValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"6",
        3:"13"
    ]
    let blackJokerValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"3",
    ]
    let redJokerValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"6",
    ]
    let threeValueRange:[Int:String] = [
        0:"3",
    ]
    let sixValueRange:[Int:String] = [
        0:"6",
    ]
    let spadeAValueRange:[Int:String] = [
        0:"1",
        1:"0",
    ]
    
    let threeCardsRankRules:[Int: String] = [
        0:"三条",
        1:"jqk",
        2:"qj10",
        3:"点数之和等于10",
        4:"同花顺",
        5:"顺子",
    ]
    static let fiveCardsRankRules: [Int: String] = [
        0:"牌的点数之和大于等于40",
        1:"炸弹（四条）",
        2:"牌的点数之和小于等于10",
        3:"牌的点数之和等于20并且有牛",
        4:"牌的点数之和等于30并且有牛",
        5:"三条并且剩下的两张牌点数之和是10的倍数",
        6:"牌的点数之和等于20或者30",
        7:"葫芦",
        8:"顺子",
        9:"牛牛",
        10:"有牛",
        11:"黄金牛，五张牌都是公牌",
        12:"银牛，五张牌都是公牌和10",
        13:"两对",
        14:"牛九",
        15:"对子",
        16:"同花",
        17:"五小（所有的牌都比五小）",
        18:"钻石牛牛（五花牛且有一张王）",
        19:"牛+一对9",
        20:"牛+JQ",
        21:"牛+10J",
        22:"牛+a10",
        23:"235加一个对子",
        24:"牛加对子",
        25:"五张牌点数之和为40",
        26:"铁板牛牛（三条+剩下的牌是10的倍数）",
        27:"同色（同红或者同黑）",
        28:"顺斗，有一组三张顺子+两张牌",
        29:"硬斗，235加一组牌",
        30:"同花顺",
        31:"五个1",
        32:"五张牌点数等于10",
        33:"五张牌点数等于20",
        34:"五张牌点数等于30",
        35:"五张牌点数等于40",
        36:"五张牌点数等于5",
        37:"♠️a，剩下的牌都是jqk",
        38:"牛+对a",
        39:"带♠️a的牛",
        40:"带♠️a的五花牛（有大小王）",
        41:"五小牛，五张牌的每一张牌都小于等于5并且总和小于10",
        42:"高牌"
    ]
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = PokerBullRule.fiveCardsRankRules
    }
}

class PokerBull{
    static func FindWinner(inputCards:[Int], args:[Int], rankRules:[Int], suitRules: [Int]) -> [Int]? {
        

//        let json = Python.import("json")
//
//        let pythonObject =  json.PokerBullGame.calResult(inputCards, args, rankRules, suitRules)
        // 使用 map() 函数将 PythonList 转换为 Int 数组
//        let intArray = Array<Int>(pythonObject)!
        
        return nil
    }
    
    static func legalCheck(playerNum: Int, handNum: Int, cardNum: Int)->String{
        if (handNum == 4){
            return "4张牛牛还不可以使用哦亲"
        }
        
        if(handNum * playerNum > cardNum){
            return "牌数不足"
        }
        
        
        return ""
        
    }
    
    static func GetAllCardIndex()->[Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...12{
                    result.append(rank + i * 13)
            }
        }
        return result
    }
    
    static func GetMinCardNum(playerNum: Int, handNum: Int) -> Int{
        return playerNum * handNum
    }
    
}



//# UI STRUCTURE TO ARGUMENT VALUE
//# number of cards -> int value:
//# 0: 20, 1: 32, 2: 36, 3: 40, 4: 42, 5: 52, 6: 54
//
//# way to deal cards -> int value:
//# 0, normal dealing, 5 cards each
//# 1, one card each for the first round and begin from the largest card
//# 2, normal dealing, 3 cards each
//# 3, normal dealing, 4 cards each*
//# 4, normal dealing, 10 cards each*
//
//# numberchangearray
//# if card number change -> int Array:
//# 0, 10 -> 0, 1, 1/0(计算点数时还是10)*, 1/0(计算点数时候时0/1)*
//# 1, J -> 0, 1, 11
//# 2, Q -> 0, 1, 2, 12
//# 3, K -> 0, 1, 6, 13
//# 4, BLACKJoker ->0, 1, 3, any*
//# 5, REDJOKER ->0, 1, 6, any*
//# 6, 3 -> 3, 3/6*
//# 7, 6 -> 6, 3/6*
//# 8, Spade A -> 1, 0(公牌)
//
//# Bull Rule for dealing 0, 1 -> int Array 0->no 1->yes:
//# 0, any three cards equal to 10 * n
//# 1, total five cards equal to 10 * n
//# 2, Threecard
//# 3, thress card straight
//# 4, only contains J,K,Q,A,JOKER is BULLBULL(不看点数)
//# 5, Three cards equal to 1
//# 6, Five cards sum <= 10 (sum is the Bull number, exp. 1,2,2,2,1 牛8)
//# 7, five cards sum <= 9
//# 8, any three cards equal to 10 * n and at least > 20
//
//# Rank Rule for dealing 0, 1, 4-> int Array
//# 0, five cards sum >= 40
//# 1, Fourcard
//# 2, five cards sum <= 10
//# 3, five cards sum == 20 and have bull
//# 4, five cards sum == 30 and have bull
//# 5, Threecard and other two sum == 10
//# 6, five cards sum == 20 or 30
//# 7, Fullhouse
//# 8, straight
//# 9, Bullbull
//# 10, Bull
//# 11, GoldBull (JQK)
//# 12, SilverBull (JQK10)
//# 13, Twopair
//# 14, BullNine
//# 15, Onepair
//# 16, Flush
//# 17, all cards < 5
//# 18, DiamandBull(JQKJOKER)
//# 19, Bull+9pair max
//# 20, Bull + JQ
//# 21, Bull + 10J
//# 22, Bull + A10
//# 23, 235+pair
//# 24, Bull + 10pair max
//# 25, five cards sum = 40
//# 26, IRONBULL threecard + other two sums 10 * n
//# 27, same color, all red or all black
//# 28, straight Bull
//# 29, hard bull three 2,3,5 -> bull
//# 30，StraightFlush
//# 31, FiveOne
//# 32, five cards sum == 10
//# 33, five cards sum == 20
//# 34, five cards sum == 30
//# 35, five cards sum == 40
//# 36, five cards sum == 5
//# 37, spade A with JQK
//# 38, BUll + Apairmax
//# 39, BUll with spade A
//# 40, GoldBull with Spade A
//
//# Rank Rule for dealing 2-> int Array
//# 0，threecard
//# 1, KQJ
//# 2, QJ10
//# 3, sum = 10 bull
//# 4, StraightFlush
//# 5, Straight
//
//
//# Second rank rule ->int Array
//# 0, 0 同牛同点比最大牌，无牛比最大牌, 1 同牛同点比牛架后的两张, 无牛比最大 2 同牛同点一样大，无牛一样大
//# 3, 五小一样大
//# 4, 五小谁小谁大
//# 5, 五小谁大谁大
//# 6, 顺子五小一样大*
//# 7, 不分花色
//# 8, 无牛只比最大两张牌
//# 9，Joker是最小的0*


class BullPlayer {
    
    var playerID: Int
    var playerCard: [PokerBullGame.PokerBullCard]
    var evaluateFlag: Int
    
    init(playerIndex: Int) {
        self.playerID = playerIndex
        self.playerCard = []
        self.evaluateFlag = 0
    }
    
    func insertCard(card: PokerBullGame.PokerBullCard) {
        self.playerCard.append(card)
    }
    
    func evaluateHandCards(bullRules: [Int], sameBullPointComparision: Int, fiveLittleComparision: Int, fiveLittleEqualToStraight: Bool, rankRules: [Int]) {
        self.evaluateFlag = BullHandEvaluator.evaluate(cards: self.playerCard, bullRules: bullRules, inputSameBullPointComparision: sameBullPointComparision, inputFiveLittleComparision: fiveLittleComparision, inputFiveLittleEqualToStraight: fiveLittleEqualToStraight, rankRules: rankRules)
    }
}


//# example5041: [6,   54张牌
//#               0,   每家五张牌
//#               0, 0, 0, 0, 0, 0, 3, 6, 1    大小王JQK算0点，10 算0点， A-9算1-9点
//#               1, 0, 0, 0, 0, 0, 0, 0, 0    有三张牌点数相加为0算牛
//#               1, 0, 0, 0, 0, 0, 0, 0, 0, 0   同牛不比牛架，单张比最大
//#               rankRules [1，7，9，10] 四条 》 葫芦 》牛牛 》牛
//# example2: []


class PokerBullGame {
    
    class PokerBullCard {
        var tenValue, JValue, QValue, KValue, BJokerValue, RJokerValue, ThreeValue, SixValue, SpadeA: Int
        var suit, rank1Value, rank2Value, trueRank: Int
        
        var score: Int
        
        init(card: Card, numberChangeArray: [Int], isNoSuit: Int, jokerMinZero: Int) {
            self.tenValue = numberChangeArray[0]
            self.JValue = numberChangeArray[1]
            self.QValue = numberChangeArray[2]
            self.KValue = numberChangeArray[3]
            self.BJokerValue = numberChangeArray[4]
            self.RJokerValue = numberChangeArray[5]
            self.ThreeValue = numberChangeArray[6]
            self.SixValue = numberChangeArray[7]
            self.SpadeA = numberChangeArray[8]
            
            self.suit = -1
            self.rank1Value = -1
            self.rank2Value = -1
            self.trueRank = card.rank
            
            if isNoSuit == 1 {
                self.suit = 0
            } else {
                self.suit = card.suit[0]
            }
            
//            # rank1_value是用来组牛和计算点数时候的点数
//            # rank2_value是用来比大小时候的点数
//            # true_value是用来组成牌型的点数
//            # 10 -10 10是0，1
            
            if card.rank == 10 {
                        if self.tenValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = card.rank
                        } else if self.tenValue == 1 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.tenValue == 2 {
                            self.rank1Value = -10
                            self.rank2Value = -10
                        }
                    } else if card.rank == 11 {
                        if self.JValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = card.rank
                        } else if self.JValue == 1 {

                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.JValue == 2 {
                            self.rank1Value = 11
                            self.rank2Value = 11
                        }
                    } else if card.rank == 12{
                        if self.QValue == 0{
                            self.rank1Value = 0
                            self.rank2Value = card.rank
                        } else if self.QValue == 1{

                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.QValue == 2{
                            self.rank1Value = 2
                            self.rank2Value = 2
                        } else if self.QValue == 3{
                            self.rank1Value = 12
                            self.rank2Value = 12
                        }
                    } else if card.rank == 13 {
                        if self.KValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = 13
                        } else if self.KValue == 1 {

                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.KValue == 2 {
                            self.rank1Value = 6
                            self.rank2Value = 6
                        } else if self.KValue == 3 {
                            self.rank1Value = 13
                            self.rank2Value = 13
                        }
                    } else if card.rank == 14 {
                        if self.BJokerValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = 14
                        } else if self.BJokerValue == 1 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.BJokerValue == 2 {
                            self.rank1Value = 3
                            self.rank2Value = 3
                        } else if self.BJokerValue == 3 {
                            self.rank1Value = -1
                            self.rank2Value = -1
                        }
                    } else if card.rank == 15 {
                        if self.RJokerValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = 15
                        } else if self.RJokerValue == 1 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.RJokerValue == 2 {
                            self.rank1Value = 6
                            self.rank2Value = 6
                        } else if self.RJokerValue == 3 {
                            self.rank1Value = -1
                            self.rank2Value = -1
                        }
                    } else if card.rank == 3 {
                        if self.ThreeValue == 0 {
                            self.rank1Value = 3
                            self.rank2Value = 3
                        } else if self.ThreeValue == 1 {
                            self.rank1Value = -3
                            self.rank2Value = -3
                        }
                    } else if card.rank == 6 {
                        if self.SixValue == 0 {
                            self.rank1Value = 6
                            self.rank2Value = 6
                        } else if self.SixValue == 1 {
                            self.rank1Value = -6
                            self.rank2Value = -6
                        }
                    } else if card.rank == 1, card.suit[0] == 3 {
                        if self.SpadeA == 0 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.SpadeA == 1 {
                            self.rank1Value = 0
                            self.rank2Value = 0
                        }
                    } else {
                        self.rank1Value = card.rank
                        self.rank2Value = card.rank
                        self.suit = card.suit[0]
                    }
            
                    self.score = self.rank2Value << 2 | self.suit
            // rest of the translation for this block follows...
            
            // Note: Due to space limitations, I'm continuing the translation in the next response.
        }
        
        func calScore(pokerBullCard: PokerBullCard) -> Int {
            return pokerBullCard.rank2Value << 2 | pokerBullCard.suit
        }
        
        func calSelfScore() -> Int {
            return self.rank2Value << 2 | self.suit
        }
        
        // Rest of the PokerBullCard class translation...
    }
    
    static func calResult(cardArray: [Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> [Int] {
        let deck = initDeck(initialCards: cardArray, suitRules: suitRules)
        let winners = calWinners(deck: deck, args: args, rankRules: rankRules)
        return winners
    }
    
    static func calWinners(deck: [Card], args: [Int], rankRules: [Int]) -> [Int] {
        // 解析 args
        let playerNum = args[0]
        let cardsNum = args[1]
        let handNum = args[2]
        let wayToDealCards = args[3]
        let noSuit = args[4]
        let fiveLittleComparision = args[5]
        let sameBullPointComparision = args[6]
        let jokerMinZero = args[7]
        let numberChangeArray = Array(args[8...15])
        let bullRule = Array(args[15...24])

        let fiveLittleEqualToStraight = args[25] == 1
        // 组建bull deck
        let bullDeck: [PokerBullCard] = deck.map { PokerBullCard.init(card: $0, numberChangeArray: numberChangeArray, isNoSuit: noSuit, jokerMinZero: jokerMinZero) }
        var allPlayers: [BullPlayer] = (0..<playerNum).map { BullPlayer(playerIndex: $0) }
        
        // 发牌
        if wayToDealCards == 0 {
            for i in 0..<(playerNum * handNum) {
                allPlayers[i % playerNum].insertCard(card: bullDeck[i])
            }
        }
        if wayToDealCards == 1 {
            for i in 0..<handNum {
                allPlayers[i % playerNum].insertCard(card: bullDeck[i])
            }
            allPlayers.sort { $0.playerCard[0].rank2Value > $1.playerCard[0].rank2Value }
            for i in 0..<((playerNum - 1) * handNum) {
                allPlayers[i % playerNum].insertCard(card: bullDeck[i + handNum])
            }
        }
        if wayToDealCards == 2 {
            for i in 0..<(playerNum * 3) {
                allPlayers[i % playerNum].insertCard(card: bullDeck[i])
            }
        }
        if wayToDealCards == 3 {
            for i in 0..<(playerNum * 5) {
                allPlayers[i % playerNum].insertCard(card: bullDeck[i])
            }
        }
        if wayToDealCards == 4 {
            for i in 0..<(playerNum * 10) {
                allPlayers[i % playerNum].insertCard(card: bullDeck[i])
            }
        }
        
//        // 计算牌额大小
        for player in allPlayers {
            player.evaluateHandCards(bullRules: bullRule, sameBullPointComparision: sameBullPointComparision, fiveLittleComparision: fiveLittleComparision, fiveLittleEqualToStraight: fiveLittleEqualToStraight, rankRules: rankRules)
        }
        
        return [allPlayers.sorted { $0.evaluateFlag > $1.evaluateFlag }[0].playerID]
    }
    
    // Rest of the PokerBullGame class translation...
}

// Define your Card, RankRules, Init_deck, and Player classes here
// These classes are referenced in the translated code but not provided in your original Python snippet.

class BullHandEvaluator {

    
    // Replace this with the actual class constants in Swift
//    # 0, 0 同牛同点比最大牌，无牛比最大牌,
//    # 1 同牛同点比牛架后的两张, 无牛比最大
//    # 2 同牛同点一样大，无牛一样大
    static let BULLSECONDRANK = 0
//    # 0, 五小一样大
//    # 1, 五小谁小谁大
//    # 2, 五小谁大谁大
    static let FIVELITTLESECONDRANK = 0
//    # 6, 顺子五小一样大

    static let STRAITEQUALFIVELITTLE = false
//    # 7, 不分花色

    static let NOSUIT = false
//    # 8, 无牛只比最大两张牌
    static let NOBULLRANKTOPTWO = false
//    # 9，Joker是最小的0
    static let JOKERISSMALLESTZERO = false
    // ... (other class properties)
    static var bullRules: [Int] = [0]
    static var sameBullPointComparison: Int = 0
    static var fiveLittleComparison: Int = 0
    static var fiveLittleEqualToStraight: Bool = false
    static let IS_BULL_DIC: [Int: ([PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]]] = [
        0: anyThreeCardSumNten,
        1: threeCard,
        2: totalEqualToN10,
        3: threeCardStraight,
        4: onlyJKQAJoker,
        5: threeRankOneCard,
        6: fiveCardsSumLessThanTen,
        7: fiveCardsSumLessThanNine,
        8: anyThreeCardSumNtenOverTwenty
        ]
    static let THREE_CARDS_RANK_RULE_DIC: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int)] = [
        1: isThreeCardTHR(cards:),
        2: isJQKTHR(cards:),
        3: isQJTENTHR(cards:),
        4: isSumEqualToTenTHR(cards:),
        5: isStraightTHR(cards:),
        6: isStraightFlushTHR(cards:)
    ]
    
    static let FIVE_CARDS_RANK_RULE_Dic: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int)] = [
        0: isCardsSumLargerOrEqualForty,
        1: isFourcard(cards:),
        2: isFiveCardsSumLessOrEqualTen,
        3: isFiveCardsSumEqualsToTwentyAndHaveBulls,
        4: isFiveCardsSumEqualsToThirtyAndHaveBulls,
        5: threecardAndOtherTen(cards:),
        6: sumEqualTwentyOrThirty,
        7: isFullhouse(cards:),
        8: isStratght(cards:),
        9: isBullBull,
        10: isBull,
        11: isGoldbull(cards:),
        12: isSilverbull(cards:),
        13: isTwoPair,
        14: isBullNine,
        15: isOnePair,
        16: isFlush,
        17: isAllCardsLessThanFive,
        18: isDiamandBull,
        19: isBullPlusPairNine,
        20: isBullPlusJQ,
        21: isBullPlusTenJ,
        22: isBullPlusATen,
        23: is235PlusPair,
        24: isBullPlusPairTen,
        25: isFiveCardsSumForty,
        26: isIronBull,
        27: isSameColor,
        28: isStraightBull,
        29: is235Bull,
        30: isStraightFlush,
        31: isFiveOne,
        32: isFiveCardsEqualTen,
        33: isFiveCardsEqualTwenty,
        34: isFiveCardsEqualThirty,
        35: isFiveCardsEqualForty,
        36: isFiveCardsEqualFive,
        37: isSpadeAWithJQK,
        38: isBullAPair,
        39: isBullWithSpadeA,
        40: isGoldBullWithSpadeA,
        41: isFiveLittle,
        42: isHighCard
            ]
    
    static var TEN_CARDS_RANK_RULE_DIC: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int)] = [:]
        
    static var FOUR_CARDS_RANK_RULE_DIC: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int)] = [:]

    
    static func evaluate(cards: [PokerBullGame.PokerBullCard], bullRules: [Int], inputSameBullPointComparision: Int, inputFiveLittleComparision: Int, inputFiveLittleEqualToStraight: Bool, rankRules: [Int]) -> Int {
            
        
        self.bullRules = bullRules
        self.sameBullPointComparison = inputSameBullPointComparision
        self.fiveLittleComparison = inputFiveLittleComparision
        self.fiveLittleEqualToStraight = inputFiveLittleEqualToStraight
        let rank_rules: [Int] = rankRules
        

        var funcs: [(_ cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int)] = []
        var ruleDic: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int)] = [:]

        if cards.count == 3 {
            ruleDic = THREE_CARDS_RANK_RULE_DIC
        } else if cards.count == 5 {
            ruleDic = FIVE_CARDS_RANK_RULE_Dic
        }

        for rankIndex in rank_rules {
            funcs.append(ruleDic[rankIndex]!)
        }

        var i = funcs.count + 1
        for funcTuple in funcs {
            i -= 1
            let (flag, rank) = funcTuple(cards)
            if flag != true {
                continue
            } else {
                let eval = (1 << (8 + i)) | rank
                print(eval)
                return eval
            }
        }
        return 0 // You should adjust the return value accordingly
    }
        
//        ###################################################
//            # 判断是否有牛
//            # 不同判断牛的函数
//            # TODO 组牛时候的多个值的变化
//        ###################################################
        // Tested
        static func anyThreeCardSumNten(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            for combination in cards.combinations(ofCount: 3) {
                
                let sumOfCombination = sumAllBullCard(combination: combination, rank: 1)
                print("cal bull ",sumOfCombination)
                if sumOfCombination % 10 == 0 {
                    bulls.append(Array(combination))
                }
            }
            
            return bulls
        }
        //Tested
        static func threeCard(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var counts: [Int: [PokerBullGame.PokerBullCard]] = [:]
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            
            for card in cards {
                counts[card.rank2Value, default: []].append(card)
                if counts[card.rank2Value]!.count == 3 {
                    bulls.append(counts[card.rank2Value]!)
                }
            }
            return bulls
        }
        //Tested
        static func totalEqualToN10(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            let sum = sumAllBullCard(combination: cards, rank: 1)
            print("sum", sum)
            if sum % 10 == 0 {
                return [cards]
            }
            return []
        }
        //tested
        static func threeCardStraight(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            
            for combination in cards.combinations(ofCount: 3) {
                let sortedCombination = combination.sorted(by: { (card1, card2) -> Bool in
                    return card1.trueRank < card2.trueRank
                })
                if sortedCombination[0].trueRank + 2 == sortedCombination[1].trueRank + 1 &&
                   sortedCombination[1].trueRank + 1 == sortedCombination[2].trueRank {
                    bulls.append(sortedCombination)
                }
            }
            
            return bulls
        }
        //Tested
        static func onlyJKQAJoker(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            var combination: [PokerBullGame.PokerBullCard] = []
            
            for card in cards {
                if card.trueRank == 1 || card.trueRank > 10 {
                    combination.append(card)
                }
            }
            
            if combination.count == 5 {
                bulls.append(combination)
            }
            
            return bulls
        }
        //tested
        static func threeRankOneCard(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            
            for combination in cards.combinations(ofCount: 3) {
                let sumOfCombination = sumAllBullCard(combination: combination, rank: 1)
                print(sumOfCombination)
                if sumOfCombination == 3 {
                    bulls.append(Array(combination))
                }
            }
            
            return bulls
        }
        //Tested
        static func fiveCardsSumLessThanTen(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            
            if sumAllBullCard(combination: cards,rank: 2) <= 10 {
                bulls.append(cards)
            }
            
            return bulls
        }
        // Tested
        static func fiveCardsSumLessThanNine(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            
            if sumAllBullCard(combination: cards,rank: 2) < 10 {
                bulls.append(cards)
            }
            
            return bulls
        }
        //Tested
        static func anyThreeCardSumNtenOverTwenty(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            
            for combination in cards.combinations(ofCount: 3) {
                let sumOfCombination = sumAllBullCard(combination: combination, rank: 1)
                if sumOfCombination % 10 == 0 && sumOfCombination > 20 {
                    bulls.append(Array(combination))
                }
            }
            
            return bulls
        }
//        # 所有的牌型判断
//        ###########################################################
//        #所有的3张牌的牌型判断
//        # ################################
    //Tested
    static func isThreeCardTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var counts: [Int: Int] = [:]
        for card in cards {
            counts[card.trueRank, default: 0] += 1
        }
        
        if counts.count == 1 {
            return (true, cards[0].rank2Value)
        } else {
            return (false, 0)
        }
    }
    //Tested
    static func isJQKTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var mutableCards = cards
        mutableCards.sort(by: { $0.trueRank < $1.trueRank })
        var firstRank = 11
        for card in mutableCards {
            if card.trueRank != firstRank {
                return (false, 0)
            }
            firstRank += 1
        }
        return (true, mutableCards.last!.score)
    }
    //Tested
    static func isQJTENTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var mutableCards = cards // 创建可变副本
        mutableCards.sort(by: { $0.trueRank < $1.trueRank })
        var firstRank = 10
        for card in mutableCards {
            if card.trueRank != firstRank {
                return (false, 0)
            }
            firstRank += 1
        }
        return (true, mutableCards.last!.score)
    }

    //Tested
    static func isSumEqualToTenTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if sumAllBullCard(combination: cards, rank: 1) == 10 {
            return (true, self.rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    //Tested
    static func isStraightFlushTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        return isStraightFlush(cards: cards)
    }
    //Tested
    static func isStraightTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        return isStratght(cards: cards)
    }
    
    //五张牌牌型判断
    //######################################
    
    //Tested
    static func isCardsSumLargerOrEqualForty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        print(sumAllBullCard(combination: cards, rank: 2))
        if sumAllBullCard(combination: cards, rank: 2) < 40 {
                return (false, 0)
            } else {
                let rank = rankForMaxCard(cards: cards)
                return (true, rank)
            }
        }
    //Tested
    static func isFourcard(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var counts: [Int: Int] = [:]
        
        for card in cards {
            counts[card.trueRank, default: 0] += 1
            if counts[card.trueRank] == 4 {
                return (true, card.trueRank)
            }
        }
        
        return (false, 0)
    }
    //Tested
    static func isFiveCardsSumLessOrEqualTen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if sumAllBullCard(combination: cards, rank: 2) > 10 {
            return (false, 0)
        } else {
            if self.FIVELITTLESECONDRANK == 0 {
                return (true, 0)
            } else if self.FIVELITTLESECONDRANK == 1 {
                return (true, sumAllBullCard(combination: cards, rank: 2))
            } else if self.FIVELITTLESECONDRANK == 2 {
                return (true, ~sumAllBullCard(combination: cards, rank: 2))
            }
        }
        return (false, 0)
    }
    //Tested
    static func isFiveCardsSumEqualsToTwentyAndHaveBulls(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        print(isBull(cards: cards).0)
        if sumAllBullCard(combination: cards, rank: 2) == 20 && isBull(cards: cards).0 {
            let rank = rankForMaxCard(cards: cards)
            return (true, rank)
        } else {
            return (false, 0)
        }
    }
    
    static func isFiveCardsSumEqualsToThirtyAndHaveBulls(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.reduce(into: 0) { $0 + $1.rank2Value } == 30 && isBull(cards: cards).0 {
            let rank = rankForMaxCard(cards: cards)
            return (true, rank)
        } else {
            return (false, 0)
        }
    }
    
    static func threecardAndOtherTen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var counts: [Int: Int] = [:]
        
        for card in cards {
            counts[card.rank1Value, default: 0] += 1
        }
        
        for (key, value) in counts {
            if value == 3 {
                let rank = key
                let otherValuesSum = counts.filter { $0.key != key }.reduce(0) { $0 + $1.value }
                if otherValuesSum % 10 == 0 {
                    return (true, rank)
                }
            }
        }
        
        return (false, 0)
    }
    
    static func sumEqualTwentyOrThirty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.reduce(0) { $0 + $1.rank1Value } == 20 || cards.reduce(0) { $0 + $1.rank1Value } == 30 {
            return (true, rankForMaxCard(cards: cards))
        } else {
            return (false, 0)
        }
    }
    
    static func isFullhouse(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var counts: [Int: Int] = [:]
        var trueValueDic: [Int: Int] = [:]
        
        for card in cards {
            counts[card.trueRank, default: 0] += 1
            trueValueDic[card.trueRank] = card.rank2Value
        }
        
        for (key, value) in counts {
            if value == 3 {
                let rank = trueValueDic[key] ?? 0
                let otherValuesNum = counts.filter { $0.key != key }.values.first ?? 0
                if otherValuesNum == 2 {
                    return (true, rank)
                }
            }
        }
        
        return (false, 0)
    }
    
    static func isStratght(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        let sortedCards = cards.sorted { $0.rank2Value < $1.rank2Value }
        
        for cardIndex in 0..<(sortedCards.count - 1) {
            if sortedCards[cardIndex].rank2Value + 1 != sortedCards[cardIndex + 1].rank2Value {
                return (false, 0)
            }
        }
        
        return (true, sortedCards[0].score)
    }
    
    static func isBullBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var bullRank = 0
        
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        var rank = 0
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    bullRank = bull.reduce(0) { $0 + $1.rank2Value } % 10
                    if bullRank == 0 || !self.onlyJKQAJoker(cards: cards).isEmpty {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            print("同牛同点比牛架，不能加入这个牛型")
                        } else if self.sameBullPointComparison == 2 {
                            rank = 0
                        }
                    }
                }
                
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                            otherCards.append(card)
                        }
                    }
                    
                    var cardsRank = 0
                    for item in otherCards {
                        cardsRank += item.rank2Value
                    }
                    
                    cardsRank = cardsRank % 10
                    
                    if cardsRank == 0 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        } else if self.sameBullPointComparison == 2 {
                            rank = 0
                        }
                    }
                }
            }
        }
        
        return (true, (bullRank << 4) | rank)
    }
    
    static func isBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var bullRank = 0
        var rank = 0
        
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    bullRank = sumAllBullCard(combination: bull, rank: 1) % 10
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if hasCard(combination: bull, searchCard: card) == false {
                            otherCards.append(card)
                        }
                    }
                    var cardsRank = 0
                    for item in otherCards {
                        cardsRank += item.rank1Value
                    }
                    cardsRank = cardsRank % 10
                    if cardsRank > bullRank {
                        bullRank = cardsRank
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        }
                        if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        }
                        if self.sameBullPointComparison == 2{
                            rank = 0
                        }
                    }
                }
            }
        }
        
        return (true, (bullRank << 4) | rank)
    }

    static func isGoldbull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
            var count = 0
            
            for card in cards {
                if card.rank2Value > 10 {
                    count += 1
                }
            }
            
            if count == 5 {
                let rank = rankForMaxCard(cards: cards)
                return (true, rank)
            }
            
            return (false, 0)
        }
        
        static func isSilverbull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
            var count = 0
            
            for card in cards {
                if card.rank2Value < 10 {
                    return (false, 0)
                }
                
                if card.rank2Value == 10 {
                    count += 1
                }
                
                if count > 1 {
                    return (false, 0)
                }
            }
            
            let rank = rankForMaxCard(cards: cards)
            return (true, rank)
        }
        
        static func isTwoPair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
            var counts: [Int: Int] = [:]
            
            for card in cards {
                counts[card.trueRank, default: 0] += 1
            }
            
            var pair: [Int] = []
            var highcard: [Int] = []
            
            for (key, value) in counts {
                if value == 2 {
                    pair.append(key)
                } else {
                    highcard.append(key)
                }
            }
            
            if pair.count == 2 {
                pair.sort(by: >)
                highcard.sort(by: >)
                return (true, (pair[0] << 8) | (pair[1] << 4) | highcard[0])
            }
            
            return (false, 0)
        }
        
        static func isBullNine(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
            var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
            var bullRank = 0
            var rank = 0
            
            for index in self.bullRules {
                let bullFunc = self.IS_BULL_DIC[index]!
                let bulls = bullFunc(cards)
                if !bulls.isEmpty {
                    allbulls.append(bulls)
                }
            }
            
            if allbulls.isEmpty {
                return (false, 0)
            }
            
            for bulls in allbulls {
                for bull in bulls {
                    if bull.count == 5 {
                        bullRank = bull.reduce(0) { $0 + $1.rank1Value } % 10
                    }
                    
                    if bull.count == 3 {
                        var otherCards: [PokerBullGame.PokerBullCard] = []
                        for card in cards {
                            if !bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                                otherCards.append(card)
                            }
                        }
                        
                        var cardsRank = 0
                        for item in otherCards {
                            cardsRank += item.rank1Value
                        }
                        
                        cardsRank = cardsRank % 10
                        
                        if cardsRank > bullRank {
                            bullRank = cardsRank
                            
                            if self.sameBullPointComparison == 0 {
                                rank = rankForMaxCard(cards: cards)
                            } else if self.sameBullPointComparison == 1 {
                                rank = rankForMaxCard(cards: otherCards)
                            } else if self.sameBullPointComparison==2 {
                                rank = 0
                            }
                        }
                    }
                }
            }
            
            if bullRank == 9 {
                return (true, rank)
            }
            
            return (false, 0)
        }
        
        static func isOnePair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
            var counts: [Int: Int] = [:]
            
            for card in cards {
                counts[card.trueRank, default: 0] += 1
            }
            
            var pair: [Int] = []
            var highcard: [Int] = []
            
            for (key, value) in counts {
                if value == 2 {
                    pair.append(key)
                } else {
                    highcard.append(key)
                }
            }
            
            if pair.count == 2 {
                pair.sort(by: >)
                highcard.sort(by: >)
                return (true, (pair[0] << 8) | highcard[0])
            }
            
            return (false, 0)
        }
        
        static func isFlush(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
            let suit = cards[0].suit
            
            for card in cards {
                if card.suit != suit {
                    return (false, 0)
                }
            }
            
            return (true, rankForMaxCard(cards: cards))
        }

    static func isAllCardsLessThanFive(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        for card in cards {
            if card.rank2Value > 5 {
                return (false, 0)
            }
        }
        return (true, rankForMaxCard(cards: cards))
    }
    
    static func isDiamandBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var diamand = 0
        for card in cards {
            if card.trueRank < 11 {
                return (false, 0)
            }
            if card.trueRank > 13 {
                diamand += 1
            }
        }
        if diamand != 0 {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isBullPlusPairNine(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if !bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                            otherCards.append(card)
                        }
                    }
                    rank = 0
                    if otherCards[0].trueRank == 9 && otherCards[1].trueRank == 9 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        } else if self.sameBullPointComparison == 2 {
                            rank = 0
                        }
                        return (true, rank)
                    }
                }
            }
        }
        return (false, 0)
    }
    
    static func isBullPlusJQ(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if !bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                            otherCards.append(card)
                        }
                    }
                    otherCards.sort(by: { $0.trueRank > $1.trueRank })
                    rank = 0
                    if otherCards[0].trueRank == 12 && otherCards[1].trueRank == 11 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        } else if self.sameBullPointComparison==2 {
                            rank = 0
                        }
                        return (true, rank)
                    }
                }
            }
        }
        return (false, 0)
    }
    
    static func isBullPlusTenJ(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if !bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                            otherCards.append(card)
                        }
                    }
                    otherCards.sort(by: { $0.trueRank > $1.trueRank })
                    rank = 0
                    if otherCards[0].trueRank == 11 && otherCards[1].trueRank == 10 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        } else if (self.sameBullPointComparison != 0) {
                            rank = 0
                        }
                        return (true, rank)
                    }
                }
            }
        }
        return (false, 0)
    }
    
    static func isBullPlusATen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if !bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                            otherCards.append(card)
                        }
                    }
                    otherCards.sort(by: { $0.trueRank > $1.trueRank })
                    rank = 0
                    if otherCards[0].trueRank == 10 && otherCards[1].trueRank == 1 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        } else if self.sameBullPointComparison==2{
                            rank = 0
                        }
                        return (true, rank)
                    }
                }
            }
        }
        return (false, 0)
    }
    
    static func is235PlusPair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var counts: [Int: Int] = [:]
        for card in cards {
            counts[card.trueRank] = (counts[card.trueRank] ?? 0) + 1
        }
        var pair: [Int] = []
        var highcard: [Int] = []
        for (key, value) in counts {
            if value == 2 {
                pair.append(key)
            } else {
                highcard.append(key)
            }
        }
        if pair.count == 1 {
            pair.sort(by: >)
            highcard.sort(by: >)
            if highcard[0] == 5 && highcard[1] == 3 && highcard[2] == 2 {
                return (true, (pair[0] << 4) | highcard[0])
            }
        }
        return (false, 0)
    }
    
    static func isBullPlusPairTen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if !bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                            otherCards.append(card)
                        }
                    }
                    rank = 0
                    if otherCards[0].trueRank == 10 && otherCards[1].trueRank == 10 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        } else if self.sameBullPointComparison == 2 {
                            rank = 0
                        }
                        return (true, rank)
                    }
                }
            }
        }
        return (false, 0)
    }
    
    static func isFiveCardsSumForty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.map({ $0.rank2Value }).reduce(0, +) == 40 {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isIronBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        let threeCard = self.threeCard(cards: cards)
        if threeCard.isEmpty {
            return (false, 0)
        }
        return (false, 0)
    }
    
    static func isSameColor(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var black = 0
        var red = 0
        for card in cards {
            if card.suit == 1 || card.suit == 3 {
                black += 1
            }
            if card.suit == 2 || card.suit == 0 {
                red += 1
            }
        }
        if black == 5 || red == 5 {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isStraightBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if !self.threeCardStraight(cards: cards).isEmpty {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func is235Bull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var sortedCard = self.sortBullCardsFromLowToHigh(cards: cards)
        var a = 0
        var b = 0
        var c = 0
        var clonedList = sortedCard
        
        for card in sortedCard {
            if card.rank2Value == 2 && a != 1 {
                a = 1
                clonedList.removeAll { $0 as! AnyHashable == card as! AnyHashable }
            }
            if card.rank2Value == 3 && b != 1 {
                b = 1
                clonedList.removeAll { $0 as! AnyHashable == card as! AnyHashable }
            }
            if card.rank2Value == 5 && c != 1 {
                c = 1
                clonedList.removeAll { $0 as! AnyHashable == card as! AnyHashable }
            }
        }
        if clonedList.count == 2 {
            if self.sameBullPointComparison == 0 {
                let rank = rankForMaxCard(cards: cards)
                return (true, rank)
            }
            if self.sameBullPointComparison == 1 {
                let rank = rankForMaxCard(cards: clonedList)
                return (true, rank)
            }
            if self.sameBullPointComparison==2 {
                return (true, 0)
            }
        }
        return (false, 0)
    }

    static func isStraightFlush(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        let (isFlush, _) = self.isFlush(cards: cards)
        let (isStraight, _) = self.isStratght(cards: cards)

        if isFlush && isStraight {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isFiveOne(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        for card in cards {
            if card.rank2Value != 1 {
                return (false, 0)
            }
        }
        return (true, rankForMaxCard(cards: cards))
    }
    
    static func isFiveCardsEqualTen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 10 {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isFiveCardsEqualTwenty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 20 {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isFiveCardsEqualThirty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 30 {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isFiveCardsEqualForty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 40 {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isFiveCardsEqualFive(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 5 {
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isSpadeAWithJQK(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var sortedCards = cards.sorted(by: { $0.trueRank > $1.trueRank })
        if sortedCards.last?.trueRank == 1 && sortedCards.last?.suit == 3 {
            sortedCards.removeLast()
            for card in sortedCards {
                if card.trueRank < 11 || card.trueRank > 13 {
                    return (false, 0)
                }
            }
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isBullAPair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if !bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                            otherCards.append(card)
                        }
                    }
                    rank = 0
                    if otherCards[0].trueRank == 1 && otherCards[1].trueRank == 1 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        } else if self.sameBullPointComparison==2{
                            rank = 0
                        }
                        return (true, rank)
                    }
                }
            }
        }
        return (false, 0)
    }
    
    static func isBullWithSpadeA(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var allbulls: [[[PokerBullGame.PokerBullCard]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(cards)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0)
        }
        
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if !bull.contains(where: {$0 as! AnyHashable == card as! AnyHashable}) {
                            otherCards.append(card)
                        }
                    }
                    rank = 0
                    if (otherCards[0].trueRank == 1 && otherCards[0].suit == 3) || (otherCards[1].trueRank == 1 && otherCards[1].suit == 3) {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxCard(cards: cards)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxCard(cards: otherCards)
                        } else if self.sameBullPointComparison == 2{
                            rank = 0
                        }
                        return (true, rank)
                    }
                }
            }
        }
        return (false, 0)
    }
    
    static func isGoldBullWithSpadeA(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        var sortedCards = cards.sorted(by: { $0.trueRank < $1.trueRank })
        if sortedCards.last?.trueRank == 1 && sortedCards.last?.suit == 3 {
            sortedCards.removeLast()
            for card in sortedCards {
                if card.trueRank < 11 || card.trueRank > 15 {
                    return (false, 0)
                }
            }
            return (true, rankForMaxCard(cards: cards))
        }
        return (false, 0)
    }
    
    static func isFiveLittle(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        if cards.map({ $0.rank2Value }).reduce(0, +) > 10 {
            return (false, 0)
        }
        for card in cards {
            if card.rank2Value > 5 {
                return (false, 0)
            }
        }
        let rank = rankForMaxCard(cards: cards)
        return (true, rank)
    }
    
    static func isHighCard(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int) {
        
        return (true, rankForMaxCard(cards: cards))
    }

    // ... (other rank rule functions)
    //
    static func rankForMaxCard(cards: [PokerBullGame.PokerBullCard]) -> Int {
            let sortedCards = sortBullCardsFromHighToLow(cards: cards)
            let rank = sortedCards[0].score
            return rank
        }
        
        static func sortBullCardsFromHighToLow(cards: [PokerBullGame.PokerBullCard]) -> [PokerBullGame.PokerBullCard] {
            return cards.sorted { $0.score > $1.score }
        }
        
        static func sortBullCardsFromLowToHigh(cards: [PokerBullGame.PokerBullCard]) -> [PokerBullGame.PokerBullCard] {
            return cards.sorted { $0.score < $1.score }
        }
    static func sumAllBullCard(combination:[PokerBullGame.PokerBullCard], rank: Int) -> Int{
        var sum:Int = 0
        for card in combination{
            if rank == 1{
                sum += card.rank1Value

            } else if rank == 2{
                sum += card.rank2Value

            } else if rank == 3{
                sum += card.trueRank
            }
        }
        return sum
    }
    
    static func hasCard(combination: [PokerBullGame.PokerBullCard], searchCard: PokerBullGame.PokerBullCard)-> Bool{
        for card in combination{
            if card.trueRank == searchCard.trueRank && card.suit == searchCard.suit{
                return true
            }
        }
        
        return false
    }
    
    
}
