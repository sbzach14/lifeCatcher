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
    
    
    //TODO: 加入总牌数量来限制规则的选择，当前为所有规则都能选择
    let CommunityNum : Int = 0
    let handNum :Int = 0
    
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
        3:"同牛同点比最大的牌，最大一样比次大，次大一样比第三大",
        4:"同为牛牛相比5张总点数，点输越小越大，同牛同点一样大，无牛一样大"
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
        3:"和A一样"
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
        42:"高牌",
        43:"铁板牛牛+牛",
        44:"三条牛+牛",
        45:"三条牛牛 + 牛牛",
        46:"三条"
    ]
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = PokerBullRule.fiveCardsRankRules
        self.playerNum = [2,3,4,5,6,7,8]
        self.setting = [
            0: "斗牛-分花色[501]",
            1: "斗牛-不分花色[502]",
            2: "斗牛-不分花色2[503]",
            3: "斗牛-36张炸弹最大[505]",
            4: "斗牛-顺算牛[506]",
            5: "斗牛-4带1[507]",
            6: "斗牛-对子[508]",
            7: "斗牛-40张炸弹最大",
            8: "斗牛-54张炸弹最大",
            9: "斗牛3条算牛[513]",
            10: "斗牛10张比两次分花色[504]",
            11: "斗牛4条3条[509]",
            12: "斗牛5大5小[510]",
            13: "斗牛-40张同点一样大[511]",
            14: "斗牛-40张第二轮有公牌[512]"
        ]
        self.ruleInfo = [
            0: """
    扑克张数:54张,52张,40张,36张,20张
    1)同牛同点比最大的牌.
    2)无牛比最大的牌.
    3)单张大小关系:大王>小王>黑桃 K>...方块K>....黑桃 10>红桃 10>梅花10>方块10>黑桃 9...>方块1
    """,
            1:"""
    扑克张数:54张 52张 40张 36张 20张
    1)同牛同点比最大的牌,最大一样比次大的牌，次大一样，比第3大的牌
    2)若不能组成牛,比最大的牌,最大一样比次大的牌，次大一样，比第3大的牌
    3)单张大小关系:大王>小王>K>Q>J>10>......>1
    """,
            2:"""
    扑克张数:54张52张 40张
    1) 同牛同点比最大的牌
    2)无牛,比最大的牌
    3)单张大小关系:大王>小王>K>Q>J>10>......>1(不分花色)
    """,
            3:"""
        用到的牌:36张1-9
        1.炸弹
        2.40点:5张牌点数相加为40点以上(包括40点)
        3.10点:5张牌点数相加为10点以下(包括10点)
        4.葫芦: 3条加1对
        5.顺子: 56789最大12345最小
        6.铁板牛牛:3条加后面2张加起来是0点 (同是铁板牛牛比3条大小)
        7.铁板牛 3>普通牛3>铁板牛 2>普通牛2
        8.无牛比最大牌次大牌3大牌
        9.单张 9>8.....>1
    """,
            4:"""
    扑克张数:54 52 40 36 20
    1.3张牌数字一样为牛
    2.3张顺子为牛
    3.同牛比最大牌
    4.无牛比最大牌
    """,
            5:"""
    扑克张数:54张 52张 40张 36张 20张
    1) KKKK>QQQQ>....>AAAA
    2)5张牌点数和=10
    3)同牛同点比最大牌次大牌3大牌
    4) 无牛比最大牌 最大牌一样比次大
    """,
            6:"""
    牌数:52张(没有大小王)每家5张牌
    1)有牛的情况下剩下2张牌是对子的大于牛10.对K>...>对1
    2)普通牛: 同牛同点比最大的牌.
    3)无牛比最大的牌.
    4) 单张大小关系:大王>小王>黑桃K>...方块K>....黑桃 10>红桃10>梅花10>方块10>黑桃 9...>方块1
    """,
            7:"""
    扑克张数: 40张 A-10
    1)炸弹
    2) 葫芦: 3条加1对
    3) 顺子:678910最大，12345最小
    4) 普通牛，同牛比单张最大.黑桃 10>红桃 10.。。>方块1
    5) 无牛,比最大的牌,黑桃 10>红桃 10.。。>方块1
    """,
            8:"""
    玩法名称= 斗牛-54张炸弹最大扑克张数:54张
    1)炸弹:4条
    2) 葫芦:3条加1对
    3)同牛同点比最大的牌.
    4) 无牛比最大的牌.
    5)单张大小关系:大王>小王>黑桃 K>...方块K>....黑桃10>红桃 10>梅花10>方块10>黑桃 9...>方块1
    """,
            9:"""
    扑克张数:52张
    1)3张牌数字一样为牛，3条牛5大于普通牛5
    2)同牛同点比最大的牌，点数一样比花色
    4)无牛,比最大的牌,点数一样比花色
    5) 单张大小关系:大王>小王>黑桃
    K>...方块K>....黑桃10>红桃 10>梅花10>方块 10>黑桃 9...>方块1
    """,
            10:"""
            52张牌
            1.每家10张牌，比两次
            2.大小关系：炸弹>3带2>有牛>无牛
            3.同牛同点比最大牌
            4.无牛比最大牌
            5.单张大小关系: 黑桃K>...>方片A
            """,
            11:"""
            扑克张数 54张 52张 40张 36张 20张
            1）四条，同样四条比大小
            2）三条，同样三条比大小
            3）牛，三张牌点输相加为0算牛，三张顺子也为牛。若同牛同点比最大的牌，最大牌黑桃K>...>方片A
            4）无牛比最大牌：黑桃K>...>方片A
            """,
            12:"""
            人数牌数:52张(没有大小王)每家5张牌
            1)5大:5张牌点数和40点以上，包
            括40点
            手法10点
            2)5小:5张牌点数和10点以内，包括10点
            3)炸弹，4张一样的牌
            4)3同带1对
            5)3同牛和普通牛。都是牛5的情况，3同牛大于普通牛
            6)同牛同点比最大的牌.
            7)无牛比最大的牌.
            8)单张大小:大王>小王>黑桃K>...方块K>....黑桃10>红桃10>梅花10>方块10>黑桃 9...>方块1
            """,
            13:"""
            40张斗牛 同点一样大用到的牌:123456789J J算一点 1=J
            1)炸弹:9999>8888··>1111=JJJJ 1和J可代替组合为炸弹炸弹相同比最后一张牌
            2)5小:五张牌相加，总点数在10以内包括10，总点数越小牌越大如1111J>11223>11233
            3)牛牛:5张相加总数为10的倍数算牛牛。三同牛牛。普通牛牛。
            同为牛牛时5张相加比总点数，总点数越小越大
            4)牛9>牛8>···>牛1:3同牛，普通牛。同点一样大，不比单张，不比花色
            5)无牛:无牛一样大
            """,
            14:"""
            扑克张数:40张
            第一轮一人先发5张，第二轮每人先先发2张，去掉2张，最后3张为公牌。发牌配置选择自定义，按次序配置第1轮，第2轮的发牌方式。
            1、炸弹最大10101010>9999>8888...1111
            2、有牛:包括3同牛，普通牛。3张一样的为3同牛。3同牛3>普通牛3.同点比单张大小:黑桃10>红桃10>梅花10>方块10>黑桃9>方块1
            3、无牛比单张:黑桃10>红桃10>梅花10>方块10>黑桃9.>方块1
            1.9版本:
            2个人玩玩4轮没有公牌，
            3个人玩3轮，第3轮每人两张去掉一张3张公牌
            """
        ]
    }
}

class PokerBull{
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args:[Int], rankRules:[Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
        let testCardLabelDic : [Int:String] = [
            0: "♠️A ", 1: "♠️2 ", 2: "♠️3 ", 3: "♠️4 ", 4: "♠️5 ", 5: "♠️6 ", 6: "♠️7 ", 7: "♠️8 ", 8: "♠️9 ", 9: "♠️10 ",
            10: "♠️J ", 11: "♠️Q ", 12: "♠️K ", 13: "♥️A ", 14: "♥️2 ", 15: "♥️3 ", 16: "♥️4 ", 17: "♥️5 ", 18: "♥️6 ",
            19: "♥️7 ", 20: "♥️8 ", 21: "♥️9 ", 22: "♥️10 ", 23: "♥️J ", 24: "♥️Q ", 25: "♥️K ", 26: "♣️A ", 27: "♣️2 ",
            28: "♣️3 ", 29: "♣️4 ", 30: "♣️5 ", 31: "♣️6 ", 32: "♣️7 ", 33: "♣️8 ", 34: "♣️9 ", 35: "♣️10 ", 36: "♣️J ",
            37: "♣️Q ", 38: "♣️K ", 39: "♦️A ", 40: "♦️2 ", 41: "♦️3 ", 42: "♦️4 ", 43: "♦️5 ", 44: "♦️6", 45: "♦️7",
            46: "♦️8 ", 47: "♦️9 ", 48: "♦️10 ", 49: "♦️J ", 50: "♦️Q ", 51: "♦️K ", 52: "none", 53: "小王", 54: "大王"
        ]

//        let json = Python.import("json")
//
//        let pythonObject =  json.PokerBullGame.calResult(inputCards, args, rankRules, suitRules)
        // 使用 map() 函数将 PythonList 转换为 Int 数组
//        let intArray = Array<Int>(pythonObject)!
        print("Array")
        var inputString : String = ""
        for i in 0..<inputCards.count{
            inputString += testCardLabelDic[inputCards[i]]!
        }
        print(inputString)
        
        let (returnPlayerInfos, leftCards) = PokerBullGame.calResult(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, cardArray: inputCards, args: args, rankRules: rankRules, suitRules: suitRules)
        return (returnPlayerInfos, leftCards)
    }
    
    static func legalCheck(playerNum: Int, handNum: Int, cardNum: Int)->String{
        
        if(handNum * playerNum > cardNum){
            return "牌数不足"
        }
        return ""
        
    }
    
    static func GetAllCardIndex(setting: Int)->[Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...51) + [53,54]
            break
        case 1:
            result = Array(0...51) + [53,54]
            break
        case 2:
            result = Array(0...51) + [53,54]
            break
        case 3:
            result = Array(0...8) + Array(13...21) + Array(26...34) + Array(39...47)
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
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 8:
            result = Array(0...51) + [53,54]
            break
        case 9:
            result = Array(0...51)
            break
        case 10:
            result = Array(0...51)
            break
        case 11:
            result = Array(0...51) + [53,54]
            break
        case 12:
            result = Array(0...51)
            break
        case 13:
            result = Array(0...8) + Array(13...21) + Array(26...34) + Array(39...47) + [10, 23, 36, 49]
            break
        case 14:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        default:
            result = Array(0...51) + [53,54]
        }
        return result
    }
    
    static func GetMinCardNum(playerNum: Int, handNum: Int, communityNum: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
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
    var cardType: String
    
    
    init(playerIndex: Int) {
        self.playerID = playerIndex
        self.playerCard = []
        self.evaluateFlag = 0
        self.cardType = ""
    }
    
    func insertCard(card: PokerBullGame.PokerBullCard) {
        self.playerCard.append(card)
    }
    
    func evaluateHandCards(bullRules: [Int], sameBullPointComparision: Int, fiveLittleComparision: Int, fiveLittleEqualToStraight: Bool, rankRules: [Int], startIndex: Int) {
        (self.evaluateFlag, self.cardType) = BullHandEvaluator.evaluate(cards: Array(self.playerCard[startIndex..<startIndex+5]), inputBullRules: bullRules, inputSameBullPointComparision: sameBullPointComparision, inputFiveLittleComparision: fiveLittleComparision, inputFiveLittleEqualToStraight: fiveLittleEqualToStraight, rankRules: rankRules)
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
        var cardIndex: Int
        var score: Int
        
        init(card: Card, numberChangeArray: [Int], isNoSuit: Int, jokerMinZero: Int, suitRules: [Int]) {
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
            self.cardIndex = card.cardIndex
            if isNoSuit == 0 {
//                print("输入牌 \(GameManager.cardLabelDic[cardIndex]),没有花色")
                self.suit = 0
            } else {
//                print("有花色 \(card.suit)")
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
                        } else if self.JValue == 3 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                            self.trueRank = 1
                            
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
    
    static func calResult(diyDealStatus:[[Bool]], diyDealNum:[Int], cardArray: [Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let deck = initDeck(initialCards: cardArray, suitRules: suitRules)
        let (returnPlayerInfos, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules,suitRules: suitRules)
        return (returnPlayerInfos, leftCards)
    }
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        // 解析 args
        //TODO 整理牛牛的参数，并且debug
        print("牛牛参数长度 \(args.count) 牛牛参数 \(args)")
        let rule = GameManager.gameRules[1] as! PokerBullRule
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let communityNum = args[4]
        let handNum = args[3]
        //0 否，1 是
        let noSuit = args[5]
        let wayToDealCards = args[6]
        let fiveLittleComparision = args[7]
        let sameBullPointComparision = args[8]
        let jokerMinZero = args[9]
        let numberChangeArray = Array(args[10...18])
        let bullRule = Array(args[19...27])
        //TODO 是否需要添加牛牛
        let fiveLittleEqualToStraight = false
        //组建bull deck
        let suitRules = suitRules
        //debuglog

        var bullDeck = [PokerBullCard]()
        for card in deck{
            bullDeck.append(PokerBullCard.init(card: card, numberChangeArray: numberChangeArray, isNoSuit: noSuit, jokerMinZero: jokerMinZero, suitRules: suitRules))
        }

        var allPlayers: [BullPlayer] = (0..<playerNum).map { BullPlayer(playerIndex: $0) }
        var community = [PokerBullCard]()
        var returnPlayerInfos: [GameReturnPlayerInfo] = []
        
        if deck.count < PokerBull.GetMinCardNum(playerNum: playerNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            return ([], [])
        }
        
        // 发牌
        if dealNum == 0{
            for _ in 0..<handNum{
                //正发
                if dealType == 0{
                    for i in 0..<playerNum {
                        allPlayers[i].insertCard(card: bullDeck.removeFirst())
                    }
                //反发
                } else if dealType == 1 {
                    for i in 0..<playerNum {
                        allPlayers[i].insertCard(card: bullDeck.removeLast())
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
                                allPlayers[i].insertCard(card: bullDeck.removeFirst())
                            }
                        }
                    //反发
                    } else if dealType == 1{
                        for i in 0..<playerNum {
                            for _ in 0..<cardNum{
                                allPlayers[i].insertCard(card: bullDeck.removeLast())
                            }
                        }
                    }
                //公牌
                } else if action[1] == true {
                    if dealType == 0{
                        for _ in 0..<cardNum{
                            community.append(bullDeck.removeFirst())
                        }
                    } else if dealType == 1{
                        for _ in 0..<cardNum{
                            community.append(bullDeck.removeLast())
                        }
                    }
                    
                //去牌
                } else if action[2] == true {
                    if dealType == 0 {
                        for _ in 0..<cardNum{
                            bullDeck.removeFirst()
                        }
                    } else if dealType == 1{
                        for _ in 0..<cardNum{
                            bullDeck.removeLast()
                        }
                    }
                }
            }
        }
        
//        // 计算牌额大小
        if wayToDealCards == 0{
            for player in allPlayers {
                player.evaluateHandCards(bullRules: bullRule, sameBullPointComparision: sameBullPointComparision, fiveLittleComparision: fiveLittleComparision, fiveLittleEqualToStraight: fiveLittleEqualToStraight, rankRules: rankRules, startIndex: 0)
            }
        } else if wayToDealCards == 1{
            for player in allPlayers {
                player.playerCard = player.playerCard + community
                player.evaluateHandCards(bullRules: bullRule, sameBullPointComparision: sameBullPointComparision, fiveLittleComparision: fiveLittleComparision, fiveLittleEqualToStraight: fiveLittleEqualToStraight, rankRules: rankRules, startIndex: 0)
            }
        }
        
        var leftCards:[Int] = []

        for leftCard in bullDeck{
            leftCards.append(leftCard.cardIndex)
        }
        
        if leftCards.count < PokerBull.GetMinCardNum(playerNum: playerNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        let sortedPlayers = allPlayers.sorted{$0.evaluateFlag > $1.evaluateFlag}

        for player in sortedPlayers{
            var currentPlayerReturnInfo = GameReturnPlayerInfo()
            currentPlayerReturnInfo.playerID = player.playerID
            currentPlayerReturnInfo.playerRank = player.evaluateFlag
            currentPlayerReturnInfo.playerCardsType = player.cardType
            currentPlayerReturnInfo.playerCardsSuit = ""
            //存入手牌和公牌
            for bullCard in player.playerCard {
                currentPlayerReturnInfo.PlayerCards.append(Card(suit: [bullCard.suit], rank: bullCard.trueRank, cardIndex: bullCard.cardIndex))
            }
            
            for bullCard in community {
                currentPlayerReturnInfo.communityCard.append(Card(suit: [bullCard.suit], rank: bullCard.trueRank, cardIndex: bullCard.cardIndex))
            }
            
            returnPlayerInfos.append(currentPlayerReturnInfo)
            print("每一个玩家手牌 \(currentPlayerReturnInfo.PlayerCards)")
        }
        
        
        
        return (returnPlayerInfos, leftCards)
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
    static let THREE_CARDS_RANK_RULE_DIC: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int, String)] = [
        1: isThreeCardTHR(cards:),
        2: isJQKTHR(cards:),
        3: isQJTENTHR(cards:),
        4: isSumEqualToTenTHR(cards:),
        5: isStraightTHR(cards:),
        6: isStraightFlushTHR(cards:)
    ]
    
    static let FIVE_CARDS_RANK_RULE_Dic: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int, String)] = [
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
        24: isBullPlusPair,
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
        42: isHighCard,
        43: isIronBullPlusBull,
        44: isThreeCardBullPlusBull,
        45: isThreeCardBullBUllPlusBullBull,
        46: Is_threeCard(cards:)
            ]
    
    static var TEN_CARDS_RANK_RULE_DIC: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int)] = [:]
        
    static var FOUR_CARDS_RANK_RULE_DIC: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int)] = [:]

    
    static func evaluate(cards: [PokerBullGame.PokerBullCard], inputBullRules: [Int], inputSameBullPointComparision: Int, inputFiveLittleComparision: Int, inputFiveLittleEqualToStraight: Bool, rankRules: [Int]) -> (Int, String) {
        let suitRules :[Int] = [3,2,1,0]

        var handCardsString:String = ""
        for handCard in cards{
            handCardsString += GameManager.cardLabelDic[handCard.cardIndex]!
            handCardsString += String(handCard.rank1Value) + " " + String(handCard.rank2Value)
        }
        print("牛牛手牌：", handCardsString)
        self.bullRules.removeAll()
        for i in 0..<inputBullRules.count{
            if inputBullRules[i] != 0{
                self.bullRules.append(i)
            }
        }
        
        print("牛牛 组牛规则 原始数组 \(inputBullRules) 有效组牛函数 \(self.bullRules) 函数个数 \(self.bullRules.count)")
        self.sameBullPointComparison = inputSameBullPointComparision
        self.fiveLittleComparison = inputFiveLittleComparision
        self.fiveLittleEqualToStraight = inputFiveLittleEqualToStraight
        let rank_rules: [Int] = rankRules
        
        var funcs: [(_ cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String)] = []
        var ruleDic: [Int: ([PokerBullGame.PokerBullCard]) -> (Bool, Int, String)] = [:]

        if cards.count == 3 {
            ruleDic = THREE_CARDS_RANK_RULE_DIC
        } else if cards.count == 5 {
            ruleDic = FIVE_CARDS_RANK_RULE_Dic
        }

        for rankIndex in rank_rules {
            funcs.append(ruleDic[rankIndex]!)
        }

        var i = funcs.count + 1
        var tempIndex = 0
        for funcTuple in funcs {
            i -= 1
            let (flag, rank, cardType) = funcTuple(cards)
            if flag != true {
                tempIndex += 1
                continue
            } else {
                let eval = (1 << (25 + i)) | rank
                print(eval)
                print("牛牛牌型是 ", PokerBullRule.fiveCardsRankRules[rank_rules[tempIndex]] as Any)
                return (eval, cardType)
            }
        }
        return (0, "") // You should adjust the return value accordingly
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
//                print("计算任意三张牌是10的整数倍 ",sumOfCombination)
                if sumOfCombination % 10 == 0 && combination.count == 3 {
                    bulls.append(Array(combination))
                }
            }
            var allBulls = ""
            for bull in bulls{
                allBulls += "组牛"
                for card in bull{
                    allBulls += " \(card.rank1Value) \(card.trueRank) "
                }
            }
            print("所有的牛 \(allBulls)")
            return bulls
        }
        //Tested
        static func threeCard(cards: [PokerBullGame.PokerBullCard]) -> [[PokerBullGame.PokerBullCard]] {
            var counts: [Int: [PokerBullGame.PokerBullCard]] = [:]
            var bulls: [[PokerBullGame.PokerBullCard]] = []
            
            for card in cards {
                counts[card.trueRank, default: []].append(card)
                if counts[card.trueRank]!.count == 3 {
                    bulls.append(counts[card.trueRank]!)
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
                if sortedCombination.count == 3 && sortedCombination[0].trueRank + 2 == sortedCombination[1].trueRank + 1 &&
                   sortedCombination[1].trueRank + 1 == sortedCombination[2].trueRank {
                    bulls.append(sortedCombination)
                }
            }
            print("三顺牛个数", bulls.count)
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
                if sumOfCombination % 10 == 0 && sumOfCombination > 20 && combination.count == 3{
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
    static func isThreeCardTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var counts: [Int: Int] = [:]
        for card in cards {
            counts[card.trueRank, default: 0] += 1
        }
        
        if counts.count == 1 {
            let cardType: String = "三条" + GameManager.CardNumberReportDic[cards[0].trueRank]!
            return (true, cards[0].rank2Value, cardType)
        } else {
            return (false, 0, "")
        }
    }
    //Tested
    static func isJQKTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var mutableCards = cards
        mutableCards.sort(by: { $0.trueRank < $1.trueRank })
        var firstRank = 11
        for card in mutableCards {
            if card.trueRank != firstRank {
                return (false, 0, "")
            }
            firstRank += 1
        }
        return (true, mutableCards.last!.score, "JQK")
    }
    //Tested
    static func isQJTENTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var mutableCards = cards // 创建可变副本
        mutableCards.sort(by: { $0.trueRank < $1.trueRank })
        var firstRank = 10
        for card in mutableCards {
            if card.trueRank != firstRank {
                return (false, 0, "")
            }
            firstRank += 1
        }
        return (true, mutableCards.last!.score, "QJ十")
    }

    //Tested
    static func isSumEqualToTenTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if sumAllBullCard(combination: cards, rank: 1) == 10 {
            return (true, self.rankForMaxCard(cards: cards), "点数和10点")
        }
        return (false, 0, "")
    }
    
    //Tested
    static func isStraightFlushTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        return isStraightFlush(cards: cards)
    }
    //Tested
    static func isStraightTHR(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        return isStratght(cards: cards)
    }
    
    //五张牌牌型判断
    //######################################
    
    //Tested
    static func isCardsSumLargerOrEqualForty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        print(sumAllBullCard(combination: cards, rank: 2))
        if sumAllBullCard(combination: cards, rank: 2) < 40 {
                return (false, 0, "")
            } else {
                let rank = rankForMaxCard(cards: cards)
                return (true, rank, "点数总和大于40")
            }
        }
    //Tested
    static func isFourcard(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var counts: [Int: Int] = [:]
        
        for card in cards {
            counts[card.trueRank, default: 0] += 1
            if counts[card.trueRank] == 4 {
                var cardType: String = "四条" + GameManager.CardNumberReportDic[card.trueRank]!
            
                return (true, card.trueRank, cardType)
            }
        }
        
        return (false, 0, "")
    }
    //Tested
    static func isFiveCardsSumLessOrEqualTen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if sumAllBullCard(combination: cards, rank: 2) > 10 {
            return (false, 0, "")
        } else {
            if self.FIVELITTLESECONDRANK == 0 {
                return (true, 0, "五张点数总和小于10")
            } else if self.FIVELITTLESECONDRANK == 1 {
                return (true, sumAllBullCard(combination: cards, rank: 2),"五张点数总和小于10")
            } else if self.FIVELITTLESECONDRANK == 2 {
                return (true, ~sumAllBullCard(combination: cards, rank: 2),"五张点数总和小于10")
            }
        }
        return (false, 0, "")
    }
    //Tested
    static func isFiveCardsSumEqualsToTwentyAndHaveBulls(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        print(isBull(cards: cards).0)
        if sumAllBullCard(combination: cards, rank: 2) == 20 && isBull(cards: cards).0 {
            let rank = rankForMaxCard(cards: cards)
            return (true, rank, "五张总和等于20有牛")
        } else {
            return (false, 0,"")
        }
    }
    
    static func isFiveCardsSumEqualsToThirtyAndHaveBulls(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.reduce(into: 0) { $0 + $1.rank2Value } == 30 && isBull(cards: cards).0 {
            let rank = rankForMaxCard(cards: cards)
            return (true, rank,"五张总和等于30有牛")
        } else {
            return (false, 0,"")
        }
    }
    
    static func threecardAndOtherTen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var counts: [Int: Int] = [:]
        
        for card in cards {
            counts[card.trueRank, default: 0] += 1
        }
        
        for (key, value) in counts {
            if value == 3 {
                let rank = key
                let cardType: String = "三条" +  GameManager.CardNumberReportDic[rank]! + "其他牌10倍数"
                let otherValuesSum = counts.filter { $0.key != key }.reduce(0) { $0 + $1.value }
                if otherValuesSum % 10 == 0 {
                    
                    return (true, rank, cardType)
                }
            }
        }
        
        return (false, 0, "")
    }
    
    static func sumEqualTwentyOrThirty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.reduce(0) { $0 + $1.rank1Value } == 20 || cards.reduce(0) { $0 + $1.rank1Value } == 30 {
            return (true, rankForMaxCard(cards: cards),"点数总和等于20或30")
        } else {
            return (false, 0,"")
        }
    }
    
    static func isFullhouse(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int,String) {
        var counts: [Int: Int] = [:]
        var trueValueDic: [Int: Int] = [:]
        
        for card in cards {
            counts[card.trueRank, default: 0] += 1
            trueValueDic[card.trueRank] = card.rank2Value
        }
        
        for (key, value) in counts {
            if value == 3 {
                let rank = trueValueDic[key] ?? 0
                let cardType: String = GameManager.CardNumberReportDic[rank]! + "葫芦"
                let otherValuesNum = counts.filter { $0.key != key }.values.first ?? 0
                if otherValuesNum == 2 {
                    return (true, rank, cardType)
                }
            }
        }
        
        return (false, 0,"")
    }
    
    static func isStratght(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int,String) {
        let sortedCards = cards.sorted { $0.rank2Value < $1.rank2Value }
        
        for cardIndex in 0..<(sortedCards.count - 1) {
            if sortedCards[cardIndex].rank2Value + 1 != sortedCards[cardIndex + 1].rank2Value {
                return (false, 0, "")
            }
        }
        let cardType: String = GameManager.CardNumberReportDic[sortedCards[0].trueRank]! + "顺子"
        return (true, sortedCards[0].score, cardType)
    }
    
    static func isBullBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (false, 0, "")
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
                        } else if sameBullPointComparison == 4{
                            rank = 0x111111 & ~( cards.reduce(0){$0 + $1.rank1Value})
                        }
                    }
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
                    
                    if otherCards.count != 0 {
                        print("牛牌 \(bull[0].trueRank) \(bull[1].trueRank)  \(bull[2].trueRank) 其他牌 \(otherCards[0].trueRank) \(otherCards[1].trueRank)")
                    }
                    
                    cardsRank = cardsRank % 10
                    
                    if cardsRank == 0 {
                        let currentRank = self.rankForSameBullSamePoint(cards: cards, otherCards: otherCards)
                        if currentRank > rank{
                            rank = currentRank
                        }
                    }
                }
            }
        }
        if rank == 0 {
            return (false, rank, "")
        }
        
        return (true, (bullRank << 18) | rank, "牛牛")
    }
    
    static func isBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (false, 0, "")
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
                        rank = self.rankForSameBullSamePoint(cards: cards, otherCards: otherCards)
                    }
                }
            }
        }
        
        let cardType = "牛" + String(bullRank)
        return (true, (bullRank << 18) | rank, cardType)
    }

    static func isGoldbull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
            var count = 0
            
            for card in cards {
                if card.rank2Value > 10 {
                    count += 1
                }
            }
            
            if count == 5 {
                let rank = rankForMaxCard(cards: cards)
                return (true, rank, "黄金牛")
            }
            
            return (false, 0, "")
        }
        
        static func isSilverbull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
            var count = 0
            
            for card in cards {
                if card.rank2Value < 10 {
                    return (false, 0, "")
                }
                
                if card.rank2Value == 10 {
                    count += 1
                }
                
                if count > 1 {
                    return (false, 0,"")
                }
            }
            
            let rank = rankForMaxCard(cards: cards)
            return (true, rank, "银牛")
        }
        
        static func isTwoPair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
                let cardType: String = GameManager.CardNumberReportDic[pair[0]]! + GameManager.CardNumberReportDic[pair[1]]! + "两对"
                return (true, (pair[0] << 8) | (pair[1] << 4) | highcard[0], cardType)
            }
            
            return (false, 0, "")
        }
        
        static func isBullNine(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
                return (false, 0,"")
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
                            
                            rank = self.rankForSameBullSamePoint(cards: cards, otherCards: otherCards)
                        }
                    }
                }
            }
            
            if bullRank == 9 {
                return (true, rank, "牛9")
            }
            
            return (false, 0, "")
        }
        
        static func isOnePair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
                let cardType: String = "对" +  GameManager.CardNumberReportDic[pair[0]]!
                return (true, (pair[0] << 8) | highcard[0], cardType)
            }
            
            return (false, 0, "")
        }
        
        static func isFlush(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
            let suit = cards[0].suit
            
            for card in cards {
                if card.suit != suit {
                    return (false, 0, "")
                }
            }
            
            return (true, rankForMaxCard(cards: cards), "同花")
        }

    static func isAllCardsLessThanFive(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        for card in cards {
            if card.rank2Value > 5 {
                return (false, 0, "")
            }
        }
        return (true, rankForMaxCard(cards: cards), "所有点数之和小于5")
    }
    
    static func isDiamandBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var diamand = 0
        for card in cards {
            if card.trueRank < 11 {
                return (false, 0,"")
            }
            if card.trueRank > 13 {
                diamand += 1
            }
        }
        if diamand != 0 {
            return (true, rankForMaxCard(cards: cards), "钻石牛牛")
        }
        return (false, 0, "")
    }
    
    static func isBullPlusPairNine(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (false, 0, "")
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
                        return (true, rank, "牛对9")
                    }
                }
            }
        }
        return (false, 0, "")
    }
    
    static func isBullPlusJQ(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (false, 0, "")
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
                        return (true, rank, "牛加JQ")
                    }
                }
            }
        }
        return (false, 0, "")
    }
    
    static func isBullPlusTenJ(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (false, 0, "")
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
                        return (true, rank, "牛加十J")
                    }
                }
            }
        }
        return (false, 0, "")
    }
    
    static func isBullPlusATen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (false, 0, "")
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
                        return (true, rank, "牛加A十")
                    }
                }
            }
        }
        return (false, 0, "")
    }
    
    static func is235PlusPair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
                return (true, (pair[0] << 4) | highcard[0], "235加对子")
            }
        }
        return (false, 0, "")
    }
    
    static func isBullPlusPair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int,String) {
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
            return (false, 0, "")
        }
        var cardType: String = ""
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherCards: [PokerBullGame.PokerBullCard] = []
                    for card in cards {
                        if self.hasCard(combination: bull, searchCard: card) == false {
                            otherCards.append(card)
                        }
                    }
                    rank = 0
                    if otherCards[0].trueRank == otherCards[1].trueRank{
                        
                        let currentRank = (otherCards[0].trueRank << 18) | self.rankForSameBullSamePoint(cards: cards, otherCards: otherCards)
                        if currentRank > rank{
                            rank = currentRank
                            cardType = "牛加对" + GameManager.CardNumberReportDic[otherCards[0].trueRank]!
                        }
                    }
                }
            }
        }
        if rank == 0 {
            return (false, 0,"")
        }
        return (true, rank, cardType)
    }
    
    static func isFiveCardsSumForty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.map({ $0.rank2Value }).reduce(0, +) == 40 {
            return (true, rankForMaxCard(cards: cards), "五张牌等于40")
        }
        return (false, 0, "")
    }
    
    static func isIronBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        let threeCard = self.threeCard(cards: cards)
        if threeCard.isEmpty {
            return (false, 0,"")
        } else {
            var num = 0
            for card in cards {
                if !threeCard[0].contains(where: {$0.cardIndex == card.cardIndex}) {
                    num += card.rank1Value
                }
            }
            if num % 10 == 0{
                return (true, threeCard[0][0].trueRank, "铁板牛牛")
            }
        }
        return (false, 0, "")
    }
    
    static func isSameColor(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (true, rankForMaxCard(cards: cards), "同色")
        }
        return (false, 0, "")
    }
    
    static func isStraightBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if !self.threeCardStraight(cards: cards).isEmpty {
            return (true, rankForMaxCard(cards: cards), "顺牛")
        }
        return (false, 0, "")
    }
    
    static func is235Bull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
                return (true, rank, "235牛")
            }
            if self.sameBullPointComparison == 1 {
                let rank = rankForMaxCard(cards: clonedList)
                return (true, rank, "235牛")
            }
            if self.sameBullPointComparison==2 {
                return (true, 0, "235牛")
            }
        }
        return (false, 0, "")
    }

    static func isStraightFlush(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        let (isFlush, _,_) = self.isFlush(cards: cards)
        let (isStraight, _,_) = self.isStratght(cards: cards)

        if isFlush && isStraight {
            return (true, rankForMaxCard(cards: cards), "同花顺")
        }
        return (false, 0, "")
    }
    
    static func isFiveOne(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        for card in cards {
            if card.rank2Value != 1 {
                return (false, 0,"")
            }
        }
        return (true, rankForMaxCard(cards: cards), "五个1点")
    }
    
    static func isFiveCardsEqualTen(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 10 {
            return (true, rankForMaxCard(cards: cards), "五张牌和为10")
        }
        return (false, 0, "")
    }
    
    static func isFiveCardsEqualTwenty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 20 {
            return (true, rankForMaxCard(cards: cards), "五张牌和为20")
        }
        return (false, 0, "")
    }
    
    static func isFiveCardsEqualThirty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 30 {
            return (true, rankForMaxCard(cards: cards), "五张牌和为30")
        }
        return (false, 0, "")
    }
    
    static func isFiveCardsEqualForty(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 40 {
            return (true, rankForMaxCard(cards: cards), "五张牌和为40")
        }
        return (false, 0, "")
    }
    
    static func isFiveCardsEqualFive(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.map({ $0.rank1Value }).reduce(0, +) == 5 {
            return (true, rankForMaxCard(cards: cards), "五张牌和为5")
        }
        return (false, 0, "")
    }
    
    static func isSpadeAWithJQK(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var sortedCards = cards.sorted(by: { $0.trueRank > $1.trueRank })
        if sortedCards.last?.trueRank == 1 && sortedCards.last?.suit == 3 {
            sortedCards.removeLast()
            for card in sortedCards {
                if card.trueRank < 11 || card.trueRank > 13 {
                    return (false, 0, "")
                }
            }
            return (true, rankForMaxCard(cards: cards), "黑桃A和JQK")
        }
        return (false, 0, "")
    }
    
    static func isBullAPair(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (false, 0, "")
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
                        return (true, rank, "牛加对A")
                    }
                }
            }
        }
        return (false, 0, "")
    }
    
    static func isBullWithSpadeA(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
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
            return (false, 0, "")
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
                        return (true, rank, "牛加黑桃A")
                    }
                }
            }
        }
        return (false, 0, "")
    }
    
    static func isGoldBullWithSpadeA(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var sortedCards = cards.sorted(by: { $0.trueRank < $1.trueRank })
        if sortedCards.last?.trueRank == 1 && sortedCards.last?.suit == 3 {
            sortedCards.removeLast()
            for card in sortedCards {
                if card.trueRank < 11 || card.trueRank > 15 {
                    return (false, 0, "")
                }
            }
            return (true, rankForMaxCard(cards: cards), "黄金牛加黑桃A")
        }
        return (false, 0, "")
    }
    
    static func isFiveLittle(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        if cards.map({ $0.rank2Value }).reduce(0, +) > 10 {
            return (false, 0, "")
        }
        for card in cards {
            if card.rank2Value > 5 {
                return (false, 0, "")
            }
        }
        let rank = rankForMaxCard(cards: cards)
        return (true, rank, "五小")
    }
    
    static func isHighCard(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        
        return (true, rankForMaxCard(cards: cards), "单牌")
    }
    static func isIronBullPlusBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String){
        let (flag1, rank1, cardType1) =  self.isIronBull(cards: cards)
        let (flag2, rank2, cardType2) = self.isBull(cards: cards)
        let mask = 0b111111111111111111
        let bullSecondRank = rank2 & mask
        let bullRank = (rank2 >> 18) << 1
        let ironRank = (rank1 << 1) | 1
        
        var cardType = ""
        var rank = 0
        if bullRank > ironRank {
            rank = (bullRank << 18 | bullSecondRank)
            cardType = cardType2
            
        } else {
            rank = (ironRank << 18 | mask)
            cardType = cardType1
        }
        
        print("铁板牛 + 牛 铁板： \(cardType1) 牛 \(cardType2) 结果 \(cardType)")
        
        
        return (flag1 || flag2, rank, cardType)
    }
    static func isThreeCardBullPlusBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String){
        let tempBullRules = Array(self.bullRules)
        let mask = 0b111111111111111111

        self.bullRules = [0]
        var (flag1, rank1, cardType1) = self.isBull(cards: cards)
        let secondRank1 = rank1 & mask
        self.bullRules = [1]

        var (flag2, rank2, cardType2) = self.isBull(cards: cards)
        let secondRank2 = rank2 & mask
        self.bullRules = tempBullRules
        rank1 = rank1>>18
        rank2 = rank2>>18

        if flag1 == true && flag2 == true{
            if (rank1>>18) < (rank2>>18){
                return (flag1, (rank1 << 19) | secondRank1, cardType1)
            } else {
                return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), cardType2)
            }
        } else if flag1 == false && flag2 == true {
            return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), cardType2)
            
        } else if flag2 == false && flag1 == true {
            return (flag1, (rank1 << 19) | secondRank1, cardType1)
        }
        return (false, 0, "")
    }
    
    static func isThreeCardBullBUllPlusBullBull(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String){
        let tempBullRules = Array(self.bullRules)
        let mask = 0b111111111111111111

        self.bullRules = [0]
        var (flag1, rank1, cardType1) = self.isBullBull(cards: cards)
        let secondRank1 = rank1 & mask

        self.bullRules = [1]
        var (flag2, rank2, cardType2) = self.isBullBull(cards: cards)
        let secondRank2 = rank2 & mask
        
        rank1 = rank1>>18
        rank2 = rank2>>18

        self.bullRules = tempBullRules
        if flag1 == true && flag2 == true{
            if rank1 < rank2{
                return (flag1, (rank1 << 19) | secondRank1, cardType1)
            } else {
                return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), cardType2)
            }
        } else if flag1 == false && flag2 == true {
            return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), cardType2)
            
        } else if flag2 == false && flag1 == true {
            return (flag1, (rank1 << 19) | secondRank1, cardType1)
        }
        return (false, 0, "")
    }
    
    static func Is_threeCard(cards: [PokerBullGame.PokerBullCard]) -> (Bool, Int, String) {
        var counts: [Int: [PokerBullGame.PokerBullCard]] = [:]
        for card in cards {
            counts[card.trueRank, default: []].append(card)
            if counts[card.trueRank]!.count == 3 {
                let cardType: String = "三条" + GameManager.CardNumberReportDic[card.trueRank]!
                return (true, card.rank2Value, cardType)
            }
        }
        return (false, 0, "")
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
    
    static func rankForSameBullSamePoint(cards: [PokerBullGame.PokerBullCard], otherCards: [PokerBullGame.PokerBullCard]) -> Int {
        switch self.sameBullPointComparison{
        case 0:
            let rank = rankForMaxCard(cards: cards)
            return rank
        case 1:
            let rank = rankForMaxCard(cards: otherCards)
            return rank
        case 2:
            return 1
        case 3:
            let sortedCards = sortBullCardsFromHighToLow(cards: cards)
            let rank = sortedCards[0].score << 12 | sortedCards[1].score << 6 | sortedCards[2].score
            return rank
        case 4:
            return 1
        default:
            return 0
        }
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
            if card.cardIndex == searchCard.cardIndex{
                return true
            }
        }
        return false
    }
    
    
}
