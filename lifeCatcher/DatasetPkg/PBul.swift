
import Foundation


class PBRule : Rule{
    
    
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
    
    let specialfeatureIsMinZero:[Int:String] = [
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
    let blackspecialfeatureValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"3",
    ]
    let redspecialfeatureValueRange:[Int:String] = [
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
    
    let threeSingleFeaturesRankRules:[Int: String] = [
        0:"三条",
        1:"jqk",
        2:"qj10",
        3:"点数之和等于10",
        4:"同花顺",
        5:"顺子",
    ]
    static let fiveSingleFeaturesRankRules: [Int: String] = [
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
        46:"三条",
        47:"牛或五张相加(9876)",
        48:"牛+对5",
        49:"牛+对10",
    ]
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = PBRule.fiveSingleFeaturesRankRules
        self.rcNum = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
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
            10: "斗牛10张比两次分花色[504]*",
            11: "斗牛4条3条[509]",
            12: "斗牛5大5小[510]",
            13: "斗牛-40张同点一样大[511]",
            14: "斗牛-40张第二轮有公牌[512]*",
            15: "斗牛-炸弹葫芦[515]",
            16: "斗牛-10算1点[514]",
            17: "40张斗牛三同对10最大[516]",
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
            """,
            15:"""
            用牌40张：1-10
            1）炸弹10101010>9999>...111
            2) 葫芦 101010>999>...111
            3) 牛10>牛9>牛8>...牛1，同牛比最大牌，同牌一样大
            4）无牛比最大牌，同牌一样大
""",
            16:"""
            人数扑克张数:40张。用牌1-10 三条算牛 10算1点,同点一样大
            1)5个1
            2)5张相加=10
            3)牛牛>5张相加为9>牛9>5张相加为8>牛8>5张相加为7>牛7>5张相加为6>牛6>牛5>牛4>牛3>牛2>牛1
            4)同点同牛无牛一样大
""",
            17:"""
            40张斗牛用牌1到10
            1.三同牛对10 普通牛对10一样大 如111和对10 999和对10 235和对10 118和对10一样大
            2.三同牛对5 普通牛对5一样大 (比如111和对5 999和对5 235和对5 118和对5都是一样大)
            3.牛牛 三同牛和普通牛都一样大
            4.有牛+对子 有牛+99>有牛+88>有牛+77>有牛+66>有牛
            +44>有牛+33>有牛+22>有牛+11,三同牛和普通牛一样大
            5.牛9最大 牛1最小三同牛和普通牛
            一样大 同点一样大不分花色
            6.无斗的都一样
""",
        ]
    }
}

class PB{
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args:[Int], rankRules:[Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        
        let testSingleFeatureLabelDic : [Int:String] = [
            0: "♠️A ", 1: "♠️2 ", 2: "♠️3 ", 3: "♠️4 ", 4: "♠️5 ", 5: "♠️6 ", 6: "♠️7 ", 7: "♠️8 ", 8: "♠️9 ", 9: "♠️10 ",
            10: "♠️J ", 11: "♠️Q ", 12: "♠️K ", 13: "♥️A ", 14: "♥️2 ", 15: "♥️3 ", 16: "♥️4 ", 17: "♥️5 ", 18: "♥️6 ",
            19: "♥️7 ", 20: "♥️8 ", 21: "♥️9 ", 22: "♥️10 ", 23: "♥️J ", 24: "♥️Q ", 25: "♥️K ", 26: "♣️A ", 27: "♣️2 ",
            28: "♣️3 ", 29: "♣️4 ", 30: "♣️5 ", 31: "♣️6 ", 32: "♣️7 ", 33: "♣️8 ", 34: "♣️9 ", 35: "♣️10 ", 36: "♣️J ",
            37: "♣️Q ", 38: "♣️K ", 39: "♦️A ", 40: "♦️2 ", 41: "♦️3 ", 42: "♦️4 ", 43: "♦️5 ", 44: "♦️6", 45: "♦️7",
            46: "♦️8 ", 47: "♦️9 ", 48: "♦️10 ", 49: "♦️J ", 50: "♦️Q ", 51: "♦️K ", 52: "none", 53: "小王", 54: "大王"
        ]

        var inputString : String = ""
        for i in 0..<inputSingleFeatures.count{
            inputString += testSingleFeatureLabelDic[inputSingleFeatures[i]]!
        }
        
        let (returnRCInfos, leftSingleFeatures) = PBDataset.calResult(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, singlefeatureArray: inputSingleFeatures, args: args, rankRules: rankRules, suitRules: suitRules)
        return (returnRCInfos, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int, handNum: Int, singlefeatureNum: Int)->String{
        
        if(handNum * rcNum > singlefeatureNum){
            return "牌数不足"
        }
        return ""
        
    }
    
    static func GetAllSingleFeatureIndex(setting: Int)->[Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...51)
            break
        case 1:
            result = Array(0...51)
            break
        case 2:
            result = Array(0...51)
            break
        case 3:
            result = Array(0...8) + Array(13...21) + Array(26...34) + Array(39...47)
            break
        case 4:
            result = Array(0...51)
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
            result = Array(0...51)
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
        case 15:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 16:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 17:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        default:
            result = Array(0...51) + [53,54]
        }
        return result
    }
    
    static func GetMinSingleFeatureNum(rcNum: Int, handNum: Int, communityNum: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
        if dealType == 0 || dealType == 1{
            return rcNum * handNum + communityNum
        } else {
            var minNum = 0
            for i in 0..<diyDealNum.count {
                let num = diyDealNum[i]
                //派牌
                if diyDealStatus[i][0] == true {
                    minNum += rcNum * num
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
//# number of singlefeatures -> int value:
//# 0: 20, 1: 32, 2: 36, 3: 40, 4: 42, 5: 52, 6: 54
//
//# way to deal singlefeatures -> int value:
//# 0, normal dealing, 5 singlefeatures each
//# 1, one singlefeature each for the first round and begin from the largest singlefeature
//# 2, normal dealing, 3 singlefeatures each
//# 3, normal dealing, 4 singlefeatures each*
//# 4, normal dealing, 10 singlefeatures each*
//
//# numberchangearray
//# if singlefeature number change -> int Array:
//# 0, 10 -> 0, 1, 1/0(计算点数时还是10)*, 1/0(计算点数时候时0/1)*
//# 1, J -> 0, 1, 11
//# 2, Q -> 0, 1, 2, 12
//# 3, K -> 0, 1, 6, 13
//# 4, BLACKspecialfeature ->0, 1, 3, any*
//# 5, REDspecialfeature ->0, 1, 6, any*
//# 6, 3 -> 3, 3/6*
//# 7, 6 -> 6, 3/6*
//# 8, Spade A -> 1, 0(公牌)
//
//# Bull Rule for dealing 0, 1 -> int Array 0->no 1->yes:
//# 0, any three singlefeatures equal to 10 * n
//# 1, total five singlefeatures equal to 10 * n
//# 2, Threesinglefeature
//# 3, thress singlefeature straight
//# 4, only contains J,K,Q,A,specialfeature is BULLBULL(不看点数)
//# 5, Three singlefeatures equal to 1
//# 6, Five singlefeatures sum <= 10 (sum is the Bull number, exp. 1,2,2,2,1 牛8)
//# 7, five singlefeatures sum <= 9
//# 8, any three singlefeatures equal to 10 * n and at least > 20
//
//# Rank Rule for dealing 0, 1, 4-> int Array
//# 0, five singlefeatures sum >= 40
//# 1, Foursinglefeature
//# 2, five singlefeatures sum <= 10
//# 3, five singlefeatures sum == 20 and have bull
//# 4, five singlefeatures sum == 30 and have bull
//# 5, Threesinglefeature and other two sum == 10
//# 6, five singlefeatures sum == 20 or 30
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
//# 17, all singlefeatures < 5
//# 18, DiamandBull(JQKspecialfeature)
//# 19, Bull+9pair max
//# 20, Bull + JQ
//# 21, Bull + 10J
//# 22, Bull + A10
//# 23, 235+pair
//# 24, Bull + 10pair max
//# 25, five singlefeatures sum = 40
//# 26, IRONBULL threesinglefeature + other two sums 10 * n
//# 27, same color, all red or all black
//# 28, straight Bull
//# 29, hard bull three 2,3,5 -> bull
//# 30，StraightFlush
//# 31, FiveOne
//# 32, five singlefeatures sum == 10
//# 33, five singlefeatures sum == 20
//# 34, five singlefeatures sum == 30
//# 35, five singlefeatures sum == 40
//# 36, five singlefeatures sum == 5
//# 37, spade A with JQK
//# 38, BUll + Apairmax
//# 39, BUll with spade A
//# 40, GoldBull with Spade A
//
//# Rank Rule for dealing 2-> int Array
//# 0，threesinglefeature
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
//# 9，specialfeature是最小的0*


class BullRC {
    
    var rcID: Int
    var rcSingleFeature: [PBDataset.PBSingleFeature]
    var evaluateFlag: Int
    var singlefeatureType: String
    
    
    init(rcIndex: Int) {
        self.rcID = rcIndex
        self.rcSingleFeature = []
        self.evaluateFlag = 0
        self.singlefeatureType = ""
    }
    
    func insertSingleFeature(singlefeature: PBDataset.PBSingleFeature) {
        self.rcSingleFeature.append(singlefeature)
    }
    
    func evaluateHandSingleFeatures(bullRules: [Int], sameBullPointComparision: Int, fiveLittleComparision: Int, fiveLittleEqualToStraight: Bool, rankRules: [Int], startIndex: Int) {
        (self.evaluateFlag, self.singlefeatureType) = BullHandAnalyst.evaluate(singlefeatures: Array(self.rcSingleFeature[startIndex..<startIndex+5]), inputBullRules: bullRules, inputSameBullPointComparision: sameBullPointComparision, inputFiveLittleComparision: fiveLittleComparision, inputFiveLittleEqualToStraight: fiveLittleEqualToStraight, rankRules: rankRules)
    }
}


//# example5041: [6,   54张牌
//#               0,   每家五张牌
//#               0, 0, 0, 0, 0, 0, 3, 6, 1    大小王JQK算0点，10 算0点， A-9算1-9点
//#               1, 0, 0, 0, 0, 0, 0, 0, 0    有三张牌点数相加为0算牛
//#               1, 0, 0, 0, 0, 0, 0, 0, 0, 0   同牛不比牛架，单张比最大
//#               rankRules [1，7，9，10] 四条 》 葫芦 》牛牛 》牛
//# example2: []


class PBDataset {
    
    class PBSingleFeature {
        var tenValue, JValue, QValue, KValue, BspecialfeatureValue, RspecialfeatureValue, ThreeValue, SixValue, SpadeA: Int
        var suit, rank1Value, rank2Value, trueRank: Int
        var singlefeatureIndex: Int
        var score: Int
        
        init(singlefeature: SingleFeature, numberChangeArray: [Int], isNoSuit: Int, specialfeatureMinZero: Int, suitRules: [Int]) {
            self.tenValue = numberChangeArray[0]
            self.JValue = numberChangeArray[1]
            self.QValue = numberChangeArray[2]
            self.KValue = numberChangeArray[3]
            self.BspecialfeatureValue = numberChangeArray[4]
            self.RspecialfeatureValue = numberChangeArray[5]
            self.ThreeValue = numberChangeArray[6]
            self.SixValue = numberChangeArray[7]
            self.SpadeA = numberChangeArray[8]
            
            self.suit = -1
            self.rank1Value = -1
            self.rank2Value = -1
            self.trueRank = singlefeature.rank
            self.singlefeatureIndex = singlefeature.singlefeatureIndex
            if isNoSuit == 0 {
                self.suit = 0
            } else {
                self.suit = singlefeature.suit[0]
            }
            
//            # rank1_value是用来组牛和计算点数时候的点数
//            # rank2_value是用来比大小时候的点数
//            # true_value是用来组成牌型的点数
//            # 10 -10 10是0，1
            
            if singlefeature.rank == 10 {
                        if self.tenValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = singlefeature.rank
                        } else if self.tenValue == 1 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.tenValue == 2 {
                            self.rank1Value = -10
                            self.rank2Value = -10
                        }
                    } else if singlefeature.rank == 11 {
                        if self.JValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = singlefeature.rank
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
                    } else if singlefeature.rank == 12{
                        if self.QValue == 0{
                            self.rank1Value = 0
                            self.rank2Value = singlefeature.rank
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
                    } else if singlefeature.rank == 13 {
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
                    } else if singlefeature.rank == 14 {
                        if self.BspecialfeatureValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = 14
                        } else if self.BspecialfeatureValue == 1 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.BspecialfeatureValue == 2 {
                            self.rank1Value = 3
                            self.rank2Value = 3
                        } else if self.BspecialfeatureValue == 3 {
                            self.rank1Value = -1
                            self.rank2Value = -1
                        }
                    } else if singlefeature.rank == 15 {
                        if self.RspecialfeatureValue == 0 {
                            self.rank1Value = 0
                            self.rank2Value = 15
                        } else if self.RspecialfeatureValue == 1 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.RspecialfeatureValue == 2 {
                            self.rank1Value = 6
                            self.rank2Value = 6
                        } else if self.RspecialfeatureValue == 3 {
                            self.rank1Value = -1
                            self.rank2Value = -1
                        }
                    } else if singlefeature.rank == 3 {
                        if self.ThreeValue == 0 {
                            self.rank1Value = 3
                            self.rank2Value = 3
                        } else if self.ThreeValue == 1 {
                            self.rank1Value = -3
                            self.rank2Value = -3
                        }
                    } else if singlefeature.rank == 6 {
                        if self.SixValue == 0 {
                            self.rank1Value = 6
                            self.rank2Value = 6
                        } else if self.SixValue == 1 {
                            self.rank1Value = -6
                            self.rank2Value = -6
                        }
                    } else if singlefeature.rank == 1, singlefeature.suit[0] == 3 {
                        if self.SpadeA == 0 {
                            self.rank1Value = 1
                            self.rank2Value = 1
                        } else if self.SpadeA == 1 {
                            self.rank1Value = 0
                            self.rank2Value = 0
                        }
                    } else {
                        self.rank1Value = singlefeature.rank
                        self.rank2Value = singlefeature.rank
                    }
            
            self.score = self.rank2Value << 2 | self.suit
            // rest of the translation for this block follows...
            
            // Note: Due to space limitations, I'm continuing the translation in the next response.
        }
        
        func calScore(targetBullSingleFeature: PBSingleFeature) -> Int {
            return targetBullSingleFeature.rank2Value << 2 | targetBullSingleFeature.suit
        }
        
        func calSelfScore() -> Int {
            return self.rank2Value << 2 | self.suit
        }
        
        // Rest of the PBSingleFeature class translation...
    }
    
    static func calResult(diyDealStatus:[[Bool]], diyDealNum:[Int], singlefeatureArray: [Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let FeatureList = initFeatureList(initialSingleFeatures: singlefeatureArray, suitRules: suitRules)
        let (returnRCInfos, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules,suitRules: suitRules)
        return (returnRCInfos, leftSingleFeatures)
    }
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        // 解析 args
        let rule = ClassifierSettingArgs.targetSetting[1] as! PBRule
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let communityNum = args[4]
        let handNum = args[3]
        //0 否，1 是
        let noSuit = args[5]
        let wayToDealSingleFeatures = args[6]
        let fiveLittleComparision = args[7]
        let sameBullPointComparision = args[8]
        let specialfeatureMinZero = args[9]
        let numberChangeArray = Array(args[10...18])
        let bullRule = Array(args[19...27])
        //TODO 是否需要添加牛牛
        let fiveLittleEqualToStraight = false
        //组建bull FeatureList
        let suitRules = suitRules
        //debuglog

        var bullFeatureList = [PBSingleFeature]()
        for singlefeature in FeatureList{
            bullFeatureList.append(PBSingleFeature.init(singlefeature: singlefeature, numberChangeArray: numberChangeArray, isNoSuit: noSuit, specialfeatureMinZero: specialfeatureMinZero, suitRules: suitRules))
        }

        let allRCs: [BullRC] = (0..<rcNum).map { BullRC(rcIndex: $0) }
        var community = [PBSingleFeature]()
        var returnRCInfos: [DatasetReturnRCInfo] = []
        
        if FeatureList.count < PB.GetMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            return ([], [])
        }
        
        // 发牌
        if dealNum == 0{
            for _ in 0..<handNum{
                //正发
                if dealType == 0{
                    for i in 0..<rcNum {
                        allRCs[i].insertSingleFeature(singlefeature: bullFeatureList.removeFirst())
                    }
                //反发
                } else if dealType == 1 {
                    for i in 0..<rcNum {
                        allRCs[i].insertSingleFeature(singlefeature: bullFeatureList.removeLast())
                    }
                }
            }
            
        } else {
            for actionIndex in 0...diyDealStatus.count - 1{
                let singlefeatureNum = diyDealNum[actionIndex]
                let action = diyDealStatus[actionIndex]
                //派牌
                if action[0] == true{
                    //正发
                    if dealType == 0{
                        for i in 0..<rcNum {
                            for _ in 0..<singlefeatureNum{
                                allRCs[i].insertSingleFeature(singlefeature: bullFeatureList.removeFirst())
                            }
                        }
                    //反发
                    } else if dealType == 1{
                        for i in 0..<rcNum {
                            for _ in 0..<singlefeatureNum{
                                allRCs[i].insertSingleFeature(singlefeature: bullFeatureList.removeLast())
                            }
                        }
                    }
                //公牌
                } else if action[1] == true {
                    if dealType == 0{
                        for _ in 0..<singlefeatureNum{
                            community.append(bullFeatureList.removeFirst())
                        }
                    } else if dealType == 1{
                        for _ in 0..<singlefeatureNum{
                            community.append(bullFeatureList.removeLast())
                        }
                    }
                    
                //去牌
                } else if action[2] == true {
                    if dealType == 0 {
                        for _ in 0..<singlefeatureNum{
                            bullFeatureList.removeFirst()
                        }
                    } else if dealType == 1{
                        for _ in 0..<singlefeatureNum{
                            bullFeatureList.removeLast()
                        }
                    }
                }
            }
        }
        
//        // 计算牌额大小
        if wayToDealSingleFeatures == 0{
            for rc in allRCs {
                rc.evaluateHandSingleFeatures(bullRules: bullRule, sameBullPointComparision: sameBullPointComparision, fiveLittleComparision: fiveLittleComparision, fiveLittleEqualToStraight: fiveLittleEqualToStraight, rankRules: rankRules, startIndex: 0)
            }
        } else if wayToDealSingleFeatures == 1{
            for rc in allRCs {
                rc.rcSingleFeature = rc.rcSingleFeature + community
                rc.evaluateHandSingleFeatures(bullRules: bullRule, sameBullPointComparision: sameBullPointComparision, fiveLittleComparision: fiveLittleComparision, fiveLittleEqualToStraight: fiveLittleEqualToStraight, rankRules: rankRules, startIndex: 0)
            }
        }
        
        var leftSingleFeatures:[Int] = []

        for leftSingleFeature in bullFeatureList{
            leftSingleFeatures.append(leftSingleFeature.singlefeatureIndex)
        }
        
        if leftSingleFeatures.count < PB.GetMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        let sortedRCs = allRCs.sorted{$0.evaluateFlag > $1.evaluateFlag}

        for rc in sortedRCs{
            var currentRCReturnInfo = DatasetReturnRCInfo()
            currentRCReturnInfo.rcID = rc.rcID
            currentRCReturnInfo.rcRank = rc.evaluateFlag
            currentRCReturnInfo.rcSingleFeaturesType = rc.singlefeatureType
            currentRCReturnInfo.rcSingleFeaturesSuit = ""
            //存入手牌和公牌
            for bullSingleFeature in rc.rcSingleFeature {
                currentRCReturnInfo.RCSingleFeatures.append(SingleFeature(suit: [bullSingleFeature.suit], rank: bullSingleFeature.trueRank, singlefeatureIndex: bullSingleFeature.singlefeatureIndex))
            }
            
            for bullSingleFeature in community {
                currentRCReturnInfo.communitySingleFeature.append(SingleFeature(suit: [bullSingleFeature.suit], rank: bullSingleFeature.trueRank, singlefeatureIndex: bullSingleFeature.singlefeatureIndex))
            }
            
            returnRCInfos.append(currentRCReturnInfo)
        }
        
        
        
        return (returnRCInfos, leftSingleFeatures)
    }
    
    // Rest of the PBDataset class translation...
}



class BullHandAnalyst {

    
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
//    # 9，specialfeature是最小的0
    static let specialfeatureISSMALLESTZERO = false
    // ... (other class properties)
    static var bullRules: [Int] = [0]
    static var sameBullPointComparison: Int = 0
    static var fiveLittleComparison: Int = 0
    static var fiveLittleEqualToStraight: Bool = false
    static let IS_BULL_DIC: [Int: ([PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]]] = [
        0: anyThreeSingleFeatureSumNten,
        1: threeSingleFeature,
        2: totalEqualToN10,
        3: threeSingleFeatureStraight,
        4: onlyJKQAspecialfeature,
        5: threeRankOneSingleFeature,
        6: fiveSingleFeaturesSumLessThanTen,
        7: fiveSingleFeaturesSumLessThanNine,
        8: anyThreeSingleFeatureSumNtenOverTwenty
        ]
    static let THREE_CARDS_RANK_RULE_DIC: [Int: ([PBDataset.PBSingleFeature]) -> (Bool, Int, String)] = [
        1: isThreeSingleFeatureTHR(singlefeatures:),
        2: isJQKTHR(singlefeatures:),
        3: isQJTENTHR(singlefeatures:),
        4: isSumEqualToTenTHR(singlefeatures:),
        5: isStraightTHR(singlefeatures:),
        6: isStraightFlushTHR(singlefeatures:)
    ]
    
    static let FIVE_CARDS_RANK_RULE_Dic: [Int: ([PBDataset.PBSingleFeature]) -> (Bool, Int, String)] = [
        0: isSingleFeaturesSumLargerOrEqualForty,
        1: isFoursinglefeature(singlefeatures:),
        2: isFiveSingleFeaturesSumLessOrEqualTen,
        3: isFiveSingleFeaturesSumEqualsToTwentyAndHaveBulls,
        4: isFiveSingleFeaturesSumEqualsToThirtyAndHaveBulls,
        5: threesinglefeatureAndOtherTen(singlefeatures:),
        6: sumEqualTwentyOrThirty,
        7: isFullhouse(singlefeatures:),
        8: isStratght(singlefeatures:),
        9: isBullBull,
        10: isBull,
        11: isGoldbull(singlefeatures:),
        12: isSilverbull(singlefeatures:),
        13: isTwoPair,
        14: isBullNine,
        15: isOnePair,
        16: isFlush,
        17: isAllSingleFeaturesLessThanFive,
        18: isDiamandBull,
        19: isBullPlusPairNine,
        20: isBullPlusJQ,
        21: isBullPlusTenJ,
        22: isBullPlusATen,
        23: is235PlusPair,
        24: isBullPlusPair,
        25: isFiveSingleFeaturesSumForty,
        26: isIronBull,
        27: isSameColor,
        28: isStraightBull,
        29: is235Bull,
        30: isStraightFlush,
        31: isFiveOne,
        32: isFiveSingleFeaturesEqualTen,
        33: isFiveSingleFeaturesEqualTwenty,
        34: isFiveSingleFeaturesEqualThirty,
        35: isFiveSingleFeaturesEqualForty,
        36: isFiveSingleFeaturesEqualFive,
        37: isSpadeAWithJQK,
        38: isBullAPair,
        39: isBullWithSpadeA,
        40: isGoldBullWithSpadeA,
        41: isFiveLittle,
        42: isHighSingleFeature,
        43: isIronBullPlusBull,
        44: isThreeSingleFeatureBullPlusBull,
        45: isThreeSingleFeatureBullBUllPlusBullBull,
        46: Is_threeSingleFeature(singlefeatures:),
        47: Is_bullOrFiveFeaturePoints(singlefeatures:),
        48: isBullPlusPairFive(singlefeatures:),
        49: isBullPlusPairTen(singlefeatures:),
            ]
    
    static var TEN_CARDS_RANK_RULE_DIC: [Int: ([PBDataset.PBSingleFeature]) -> (Bool, Int)] = [:]
        
    static var FOUR_CARDS_RANK_RULE_DIC: [Int: ([PBDataset.PBSingleFeature]) -> (Bool, Int)] = [:]

    
    static func evaluate(singlefeatures: [PBDataset.PBSingleFeature], inputBullRules: [Int], inputSameBullPointComparision: Int, inputFiveLittleComparision: Int, inputFiveLittleEqualToStraight: Bool, rankRules: [Int]) -> (Int, String) {
        let suitRules :[Int] = [3,2,1,0]

        var handSingleFeaturesString:String = ""
        for handSingleFeature in singlefeatures{
            handSingleFeaturesString += ClassifierSettingArgs.singlefeatureLabelDic[handSingleFeature.singlefeatureIndex]!
            handSingleFeaturesString += String(handSingleFeature.rank1Value) + " " + String(handSingleFeature.rank2Value)
        }
        self.bullRules.removeAll()
        for i in 0..<inputBullRules.count{
            if inputBullRules[i] != 0{
                self.bullRules.append(i)
            }
        }
        
        self.sameBullPointComparison = inputSameBullPointComparision
        self.fiveLittleComparison = inputFiveLittleComparision
        self.fiveLittleEqualToStraight = inputFiveLittleEqualToStraight
        let rank_rules: [Int] = rankRules
        
        var funcs: [(_ singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String)] = []
        var ruleDic: [Int: ([PBDataset.PBSingleFeature]) -> (Bool, Int, String)] = [:]

        if singlefeatures.count == 3 {
            ruleDic = THREE_CARDS_RANK_RULE_DIC
        } else if singlefeatures.count == 5 {
            ruleDic = FIVE_CARDS_RANK_RULE_Dic
        }

        for rankIndex in rank_rules {
            funcs.append(ruleDic[rankIndex]!)
        }

        var i = funcs.count + 1
        var tempIndex = 0
        for funcTuple in funcs {
            i -= 1
            let (flag, rank, singlefeatureType) = funcTuple(singlefeatures)
            if flag != true {
                tempIndex += 1
                continue
            } else {
                let eval = (1 << (25 + i)) | rank
                return (eval, singlefeatureType)
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
        static func anyThreeSingleFeatureSumNten(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            var bulls: [[PBDataset.PBSingleFeature]] = []
            for combination in singlefeatures.combinations(ofCount: 3) {
                
                let sumOfCombination = sumAllBullSingleFeature(combination: combination, rank: 1)
                if sumOfCombination % 10 == 0 && combination.count == 3 {
                    bulls.append(Array(combination))
                }
            }
            var allBulls = ""
            for bull in bulls{
                allBulls += "组牛"
                for singlefeature in bull{
                    allBulls += " \(singlefeature.rank1Value) \(singlefeature.trueRank) "
                }
            }
            
//            print("所有的牛 \(bulls)")
            
            return bulls
        }
        //Tested
        static func threeSingleFeature(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            var counts: [Int: [PBDataset.PBSingleFeature]] = [:]
            var bulls: [[PBDataset.PBSingleFeature]] = []
            
            for singlefeature in singlefeatures {
                counts[singlefeature.trueRank, default: []].append(singlefeature)
                if counts[singlefeature.trueRank]!.count == 3 {
                    bulls.append(counts[singlefeature.trueRank]!)
                }
            }
            return bulls
        }
        //Tested
        static func totalEqualToN10(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            let sum = sumAllBullSingleFeature(combination: singlefeatures, rank: 1)
            if sum % 10 == 0 {
                return [singlefeatures]
            }
            return []
        }
        //tested
        static func threeSingleFeatureStraight(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            var bulls: [[PBDataset.PBSingleFeature]] = []
            
            for combination in singlefeatures.combinations(ofCount: 3) {
                let sortedCombination = combination.sorted(by: { (singlefeature1, singlefeature2) -> Bool in
                    return singlefeature1.trueRank < singlefeature2.trueRank
                })
                if sortedCombination.count == 3 && sortedCombination[0].trueRank + 2 == sortedCombination[1].trueRank + 1 &&
                   sortedCombination[1].trueRank + 1 == sortedCombination[2].trueRank {
                    bulls.append(sortedCombination)
                }
            }
            return bulls
        }
        //Tested
        static func onlyJKQAspecialfeature(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            var bulls: [[PBDataset.PBSingleFeature]] = []
            var combination: [PBDataset.PBSingleFeature] = []
            
            for singlefeature in singlefeatures {
                if singlefeature.trueRank == 1 || singlefeature.trueRank > 10 {
                    combination.append(singlefeature)
                }
            }
            
            if combination.count == 5 {
                bulls.append(combination)
            }
            
            return bulls
        }
        //tested
        static func threeRankOneSingleFeature(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            var bulls: [[PBDataset.PBSingleFeature]] = []
            
            for combination in singlefeatures.combinations(ofCount: 3) {
                let sumOfCombination = sumAllBullSingleFeature(combination: combination, rank: 1)
                if sumOfCombination == 3 {
                    bulls.append(Array(combination))
                }
            }
            
            return bulls
        }
        //Tested
        static func fiveSingleFeaturesSumLessThanTen(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            var bulls: [[PBDataset.PBSingleFeature]] = []
            
            if sumAllBullSingleFeature(combination: singlefeatures,rank: 2) <= 10 {
                bulls.append(singlefeatures)
            }
            
            return bulls
        }
        // Tested
        static func fiveSingleFeaturesSumLessThanNine(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            var bulls: [[PBDataset.PBSingleFeature]] = []
            
            if sumAllBullSingleFeature(combination: singlefeatures,rank: 2) < 10 {
                bulls.append(singlefeatures)
            }
            
            return bulls
        }
        //Tested
        static func anyThreeSingleFeatureSumNtenOverTwenty(singlefeatures: [PBDataset.PBSingleFeature]) -> [[PBDataset.PBSingleFeature]] {
            var bulls: [[PBDataset.PBSingleFeature]] = []
            
            for combination in singlefeatures.combinations(ofCount: 3) {
                let sumOfCombination = sumAllBullSingleFeature(combination: combination, rank: 1)
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
    static func isThreeSingleFeatureTHR(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var counts: [Int: Int] = [:]
        for singlefeature in singlefeatures {
            counts[singlefeature.trueRank, default: 0] += 1
        }
        
        if counts.count == 1 {
            let singlefeatureType: String = "三条" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].trueRank]!
            return (true, singlefeatures[0].rank2Value, singlefeatureType)
        } else {
            return (false, 0, "")
        }
    }
    //Tested
    static func isJQKTHR(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var mutableSingleFeatures = singlefeatures
        mutableSingleFeatures.sort(by: { $0.trueRank < $1.trueRank })
        var firstRank = 11
        for singlefeature in mutableSingleFeatures {
            if singlefeature.trueRank != firstRank {
                return (false, 0, "")
            }
            firstRank += 1
        }
        return (true, mutableSingleFeatures.last!.score, "JQK")
    }
    //Tested
    static func isQJTENTHR(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var mutableSingleFeatures = singlefeatures // 创建可变副本
        mutableSingleFeatures.sort(by: { $0.trueRank < $1.trueRank })
        var firstRank = 10
        for singlefeature in mutableSingleFeatures {
            if singlefeature.trueRank != firstRank {
                return (false, 0, "")
            }
            firstRank += 1
        }
        return (true, mutableSingleFeatures.last!.score, "QJ十")
    }

    //Tested
    static func isSumEqualToTenTHR(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if sumAllBullSingleFeature(combination: singlefeatures, rank: 1) == 10 {
            return (true, self.rankForMaxSingleFeature(singlefeatures: singlefeatures), "点数和10点")
        }
        return (false, 0, "")
    }
    
    //Tested
    static func isStraightFlushTHR(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        return isStraightFlush(singlefeatures: singlefeatures)
    }
    //Tested
    static func isStraightTHR(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        return isStratght(singlefeatures: singlefeatures)
    }
    
    //五张牌牌型判断
    //######################################
    
    //Tested
    static func isSingleFeaturesSumLargerOrEqualForty(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if sumAllBullSingleFeature(combination: singlefeatures, rank: 2) < 40 {
                return (false, 0, "")
            } else {
                let rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                return (true, rank, "点数总和大于40")
            }
        }
    //Tested
    static func isFoursinglefeature(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var counts: [Int: Int] = [:]
        
        for singlefeature in singlefeatures {
            counts[singlefeature.trueRank, default: 0] += 1
            if counts[singlefeature.trueRank] == 4 {
                var singlefeatureType: String = "四条" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeature.trueRank]!
            
                return (true, singlefeature.trueRank, singlefeatureType)
            }
        }
        
        return (false, 0, "")
    }
    //Tested
    static func isFiveSingleFeaturesSumLessOrEqualTen(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if sumAllBullSingleFeature(combination: singlefeatures, rank: 2) > 10 {
            return (false, 0, "")
        } else {
            if self.FIVELITTLESECONDRANK == 0 {
                return (true, 0, "五张点数总和小于10")
            } else if self.FIVELITTLESECONDRANK == 1 {
                return (true, sumAllBullSingleFeature(combination: singlefeatures, rank: 2),"五张点数总和小于10")
            } else if self.FIVELITTLESECONDRANK == 2 {
                return (true, ~sumAllBullSingleFeature(combination: singlefeatures, rank: 2),"五张点数总和小于10")
            }
        }
        return (false, 0, "")
    }
    //Tested
    static func isFiveSingleFeaturesSumEqualsToTwentyAndHaveBulls(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if sumAllBullSingleFeature(combination: singlefeatures, rank: 2) == 20 && isBull(singlefeatures: singlefeatures).0 {
            let rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
            return (true, rank, "五张总和等于20有牛")
        } else {
            return (false, 0,"")
        }
    }
    
    static func isFiveSingleFeaturesSumEqualsToThirtyAndHaveBulls(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.reduce(into: 0) { $0 + $1.rank2Value } == 30 && isBull(singlefeatures: singlefeatures).0 {
            let rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
            return (true, rank,"五张总和等于30有牛")
        } else {
            return (false, 0,"")
        }
    }
    
    static func threesinglefeatureAndOtherTen(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var counts: [Int: Int] = [:]
        
        for singlefeature in singlefeatures {
            counts[singlefeature.trueRank, default: 0] += 1
        }
        
        for (key, value) in counts {
            if value == 3 {
                let rank = key
                let singlefeatureType: String = "三条" +  ClassifierSettingArgs.SingleFeatureNumberReportDic[rank]! + "其他牌10倍数"
                let otherValuesSum = counts.filter { $0.key != key }.reduce(0) { $0 + $1.value }
                if otherValuesSum % 10 == 0 {
                    
                    return (true, rank, singlefeatureType)
                }
            }
        }
        
        return (false, 0, "")
    }
    
    static func sumEqualTwentyOrThirty(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.reduce(0) { $0 + $1.rank1Value } == 20 || singlefeatures.reduce(0) { $0 + $1.rank1Value } == 30 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures),"点数总和等于20或30")
        } else {
            return (false, 0,"")
        }
    }
    
    static func isFullhouse(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int,String) {
        var counts: [Int: Int] = [:]
        var trueValueDic: [Int: Int] = [:]
        
        for singlefeature in singlefeatures {
            counts[singlefeature.trueRank, default: 0] += 1
            trueValueDic[singlefeature.trueRank] = singlefeature.rank2Value
        }
        
        for (key, value) in counts {
            if value == 3 {
                let rank = trueValueDic[key] ?? 0
                let singlefeatureType: String = ClassifierSettingArgs.SingleFeatureNumberReportDic[rank]! + "葫芦"
                let otherValuesNum = counts.filter { $0.key != key }.values.first ?? 0
                if otherValuesNum == 2 {
                    return (true, rank, singlefeatureType)
                }
            }
        }
        
        return (false, 0,"")
    }
    
    static func isStratght(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int,String) {
        let sortedSingleFeatures = singlefeatures.sorted { $0.rank2Value < $1.rank2Value }
        
        for singlefeatureIndex in 0..<(sortedSingleFeatures.count - 1) {
            if sortedSingleFeatures[singlefeatureIndex].rank2Value + 1 != sortedSingleFeatures[singlefeatureIndex + 1].rank2Value {
                return (false, 0, "")
            }
        }
        let singlefeatureType: String = ClassifierSettingArgs.SingleFeatureNumberReportDic[sortedSingleFeatures[0].trueRank]! + "顺子"
        return (true, sortedSingleFeatures[0].score, singlefeatureType)
    }
    
    static func isBullBull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var bullRank = 0
        
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
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
                    if bullRank == 0 || !self.onlyJKQAspecialfeature(singlefeatures: singlefeatures).isEmpty {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                        } else if self.sameBullPointComparison == 1 {
                            
                        } else if self.sameBullPointComparison == 2 {
                            rank = 0
                        } else if sameBullPointComparison == 4{
                            rank = 0x111111 & ~( singlefeatures.reduce(0){$0 + $1.rank1Value})
                        }
                    }
                }
                
                if bull.count == 3 {
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if hasSingleFeature(combination: bull, searchSingleFeature: singlefeature) == false {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    
                    
                    var singlefeaturesRank = 0
                    for item in otherSingleFeatures {
                        singlefeaturesRank += item.rank1Value
                    }
                    
                    singlefeaturesRank = singlefeaturesRank % 10
                    
                    if singlefeaturesRank == 0 {
                        let currentRank = self.rankForSameBullSamePoint(singlefeatures: singlefeatures, otherSingleFeatures: otherSingleFeatures)
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
    
    static func isBull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var bullRank = 0
        var rank = 0
        
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            
            let bulls = bullFunc(singlefeatures)
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
                    bullRank = sumAllBullSingleFeature(combination: bull, rank: 1) % 10
                }
                if bull.count == 3 {
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if hasSingleFeature(combination: bull, searchSingleFeature: singlefeature) == false {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    var singlefeaturesRank = 0
                    for item in otherSingleFeatures {
                        singlefeaturesRank += item.rank1Value
                    }
                    singlefeaturesRank = singlefeaturesRank % 10
                    if singlefeaturesRank > bullRank {
                        bullRank = singlefeaturesRank
                        rank = self.rankForSameBullSamePoint(singlefeatures: singlefeatures, otherSingleFeatures: otherSingleFeatures)
                    }
                }
            }
        }
        
        let singlefeatureType = "牛" + String(bullRank)
        return (true, (bullRank << 18) | rank, singlefeatureType)
    }

    static func isGoldbull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
            var count = 0
            
            for singlefeature in singlefeatures {
                if singlefeature.rank2Value > 10 {
                    count += 1
                }
            }
            
            if count == 5 {
                let rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                return (true, rank, "黄金牛")
            }
            
            return (false, 0, "")
        }
        
        static func isSilverbull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
            var count = 0
            
            for singlefeature in singlefeatures {
                if singlefeature.rank2Value < 10 {
                    return (false, 0, "")
                }
                
                if singlefeature.rank2Value == 10 {
                    count += 1
                }
                
                if count > 1 {
                    return (false, 0,"")
                }
            }
            
            let rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
            return (true, rank, "银牛")
        }
        
        static func isTwoPair(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
            var counts: [Int: Int] = [:]
            
            for singlefeature in singlefeatures {
                counts[singlefeature.trueRank, default: 0] += 1
            }
            
            var pair: [Int] = []
            var highsinglefeature: [Int] = []
            
            for (key, value) in counts {
                if value == 2 {
                    pair.append(key)
                } else {
                    highsinglefeature.append(key)
                }
            }
            
            if pair.count == 2 {
                pair.sort(by: >)
                highsinglefeature.sort(by: >)
                let singlefeatureType: String = ClassifierSettingArgs.SingleFeatureNumberReportDic[pair[0]]! + ClassifierSettingArgs.SingleFeatureNumberReportDic[pair[1]]! + "两对"
                return (true, (pair[0] << 8) | (pair[1] << 4) | highsinglefeature[0], singlefeatureType)
            }
            
            return (false, 0, "")
        }
        
        static func isBullNine(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
            var allbulls: [[[PBDataset.PBSingleFeature]]] = []
            var bullRank = 0
            var rank = 0
            
            for index in self.bullRules {
                let bullFunc = self.IS_BULL_DIC[index]!
                let bulls = bullFunc(singlefeatures)
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
                        var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                        for singlefeature in singlefeatures {
                            if !bull.contains(where: {$0 as! AnyHashable == singlefeature as! AnyHashable}) {
                                otherSingleFeatures.append(singlefeature)
                            }
                        }
                        
                        var singlefeaturesRank = 0
                        for item in otherSingleFeatures {
                            singlefeaturesRank += item.rank1Value
                        }
                        
                        singlefeaturesRank = singlefeaturesRank % 10
                        
                        if singlefeaturesRank > bullRank {
                            bullRank = singlefeaturesRank
                            
                            rank = self.rankForSameBullSamePoint(singlefeatures: singlefeatures, otherSingleFeatures: otherSingleFeatures)
                        }
                    }
                }
            }
            
            if bullRank == 9 {
                return (true, rank, "牛9")
            }
            
            return (false, 0, "")
        }
        
        static func isOnePair(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
            var counts: [Int: Int] = [:]
            
            for singlefeature in singlefeatures {
                counts[singlefeature.trueRank, default: 0] += 1
            }
            
            var pair: [Int] = []
            var highsinglefeature: [Int] = []
            
            for (key, value) in counts {
                if value == 2 {
                    pair.append(key)
                } else {
                    highsinglefeature.append(key)
                }
            }
            
            if pair.count == 2 {
                pair.sort(by: >)
                highsinglefeature.sort(by: >)
                let singlefeatureType: String = "对" +  ClassifierSettingArgs.SingleFeatureNumberReportDic[pair[0]]!
                return (true, (pair[0] << 8) | highsinglefeature[0], singlefeatureType)
            }
            
            return (false, 0, "")
        }
        
        static func isFlush(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
            let suit = singlefeatures[0].suit
            
            for singlefeature in singlefeatures {
                if singlefeature.suit != suit {
                    return (false, 0, "")
                }
            }
            
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "同花")
        }

    static func isAllSingleFeaturesLessThanFive(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        for singlefeature in singlefeatures {
            if singlefeature.rank2Value > 5 {
                return (false, 0, "")
            }
        }
        return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "所有点数之和小于5")
    }
    
    static func isDiamandBull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var diamand = 0
        for singlefeature in singlefeatures {
            if singlefeature.trueRank < 11 {
                return (false, 0,"")
            }
            if singlefeature.trueRank > 13 {
                diamand += 1
            }
        }
        if diamand != 0 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "钻石牛牛")
        }
        return (false, 0, "")
    }
    
    static func isBullPlusPairNine(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
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
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if !bull.contains(where: {$0 as! AnyHashable == singlefeature as! AnyHashable}) {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    rank = 0
                    if otherSingleFeatures[0].trueRank == 9 && otherSingleFeatures[1].trueRank == 9 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxSingleFeature(singlefeatures: otherSingleFeatures)
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
    
    static func isBullPlusJQ(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
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
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if !bull.contains(where: {$0 as! AnyHashable == singlefeature as! AnyHashable}) {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    otherSingleFeatures.sort(by: { $0.trueRank > $1.trueRank })
                    rank = 0
                    if otherSingleFeatures[0].trueRank == 12 && otherSingleFeatures[1].trueRank == 11 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxSingleFeature(singlefeatures: otherSingleFeatures)
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
    
    static func isBullPlusTenJ(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
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
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if !bull.contains(where: {$0 as! AnyHashable == singlefeature as! AnyHashable}) {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    otherSingleFeatures.sort(by: { $0.trueRank > $1.trueRank })
                    rank = 0
                    if otherSingleFeatures[0].trueRank == 11 && otherSingleFeatures[1].trueRank == 10 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxSingleFeature(singlefeatures: otherSingleFeatures)
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
    
    static func isBullPlusATen(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
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
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if !bull.contains(where: {$0 as! AnyHashable == singlefeature as! AnyHashable}) {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    otherSingleFeatures.sort(by: { $0.trueRank > $1.trueRank })
                    rank = 0
                    if otherSingleFeatures[0].trueRank == 10 && otherSingleFeatures[1].trueRank == 1 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxSingleFeature(singlefeatures: otherSingleFeatures)
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
    
    static func is235PlusPair(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var counts: [Int: Int] = [:]
        for singlefeature in singlefeatures {
            counts[singlefeature.trueRank] = (counts[singlefeature.trueRank] ?? 0) + 1
        }
        var pair: [Int] = []
        var highsinglefeature: [Int] = []
        for (key, value) in counts {
            if value == 2 {
                pair.append(key)
            } else {
                highsinglefeature.append(key)
            }
        }
        if pair.count == 1 {
            pair.sort(by: >)
            highsinglefeature.sort(by: >)
            if highsinglefeature[0] == 5 && highsinglefeature[1] == 3 && highsinglefeature[2] == 2 {
                return (true, (pair[0] << 4) | highsinglefeature[0], "235加对子")
            }
        }
        return (false, 0, "")
    }
    
    static func isBullPlusPair(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int,String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0, "")
        }
        var singlefeatureType: String = ""
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if self.hasSingleFeature(combination: bull, searchSingleFeature: singlefeature) == false {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    rank = 0
                    if otherSingleFeatures[0].trueRank == otherSingleFeatures[1].trueRank{
                        
                        let currentRank = (otherSingleFeatures[0].trueRank << 18) | self.rankForSameBullSamePoint(singlefeatures: singlefeatures, otherSingleFeatures: otherSingleFeatures)
                        if currentRank > rank{
                            rank = currentRank
                            singlefeatureType = "牛加对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[otherSingleFeatures[0].trueRank]!
                        }
                    }
                }
            }
        }
        if rank == 0 {
            return (false, 0,"")
        }
        return (true, rank, singlefeatureType)
    }
    
    static func isFiveSingleFeaturesSumForty(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.map({ $0.rank2Value }).reduce(0, +) == 40 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "五张牌等于40")
        }
        return (false, 0, "")
    }
    
    static func isIronBull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        let threeSingleFeature = self.threeSingleFeature(singlefeatures: singlefeatures)
        if threeSingleFeature.isEmpty {
            return (false, 0,"")
        } else {
            var num = 0
            for singlefeature in singlefeatures {
                if !threeSingleFeature[0].contains(where: {$0.singlefeatureIndex == singlefeature.singlefeatureIndex}) {
                    num += singlefeature.rank1Value
                }
            }
            if num % 10 == 0{
                return (true, threeSingleFeature[0][0].trueRank, "铁板牛牛")
            }
        }
        return (false, 0, "")
    }
    
    static func isSameColor(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var black = 0
        var red = 0
        for singlefeature in singlefeatures {
            if singlefeature.suit == 1 || singlefeature.suit == 3 {
                black += 1
            }
            if singlefeature.suit == 2 || singlefeature.suit == 0 {
                red += 1
            }
        }
        if black == 5 || red == 5 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "同色")
        }
        return (false, 0, "")
    }
    
    static func isStraightBull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if !self.threeSingleFeatureStraight(singlefeatures: singlefeatures).isEmpty {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "顺牛")
        }
        return (false, 0, "")
    }
    
    static func is235Bull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var sortedSingleFeature = self.sortBullSingleFeaturesFromLowToHigh(singlefeatures: singlefeatures)
        var a = 0
        var b = 0
        var c = 0
        var clonedList = sortedSingleFeature
        
        for singlefeature in sortedSingleFeature {
            if singlefeature.rank2Value == 2 && a != 1 {
                a = 1
                clonedList.removeAll { $0 as! AnyHashable == singlefeature as! AnyHashable }
            }
            if singlefeature.rank2Value == 3 && b != 1 {
                b = 1
                clonedList.removeAll { $0 as! AnyHashable == singlefeature as! AnyHashable }
            }
            if singlefeature.rank2Value == 5 && c != 1 {
                c = 1
                clonedList.removeAll { $0 as! AnyHashable == singlefeature as! AnyHashable }
            }
        }
        if clonedList.count == 2 {
            if self.sameBullPointComparison == 0 {
                let rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                return (true, rank, "235牛")
            }
            if self.sameBullPointComparison == 1 {
                let rank = rankForMaxSingleFeature(singlefeatures: clonedList)
                return (true, rank, "235牛")
            }
            if self.sameBullPointComparison==2 {
                return (true, 0, "235牛")
            }
        }
        return (false, 0, "")
    }

    static func isStraightFlush(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        let (isFlush, _,_) = self.isFlush(singlefeatures: singlefeatures)
        let (isStraight, _,_) = self.isStratght(singlefeatures: singlefeatures)

        if isFlush && isStraight {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "同花顺")
        }
        return (false, 0, "")
    }
    
    static func isFiveOne(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        for singlefeature in singlefeatures {
            if singlefeature.rank2Value != 1 {
                return (false, 0,"")
            }
        }
        return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "五个1点")
    }
    
    static func isFiveSingleFeaturesEqualTen(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.map({ $0.rank1Value }).reduce(0, +) == 10 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "五张牌和为10")
        }
        return (false, 0, "")
    }
    
    static func isFiveSingleFeaturesEqualTwenty(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.map({ $0.rank1Value }).reduce(0, +) == 20 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "五张牌和为20")
        }
        return (false, 0, "")
    }
    
    static func isFiveSingleFeaturesEqualThirty(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.map({ $0.rank1Value }).reduce(0, +) == 30 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "五张牌和为30")
        }
        return (false, 0, "")
    }
    
    static func isFiveSingleFeaturesEqualForty(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.map({ $0.rank1Value }).reduce(0, +) == 40 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "五张牌和为40")
        }
        return (false, 0, "")
    }
    
    static func isFiveSingleFeaturesEqualFive(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.map({ $0.rank1Value }).reduce(0, +) == 5 {
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "五张牌和为5")
        }
        return (false, 0, "")
    }
    
    static func isSpadeAWithJQK(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var sortedSingleFeatures = singlefeatures.sorted(by: { $0.trueRank > $1.trueRank })
        if sortedSingleFeatures.last?.trueRank == 1 && sortedSingleFeatures.last?.suit == 3 {
            sortedSingleFeatures.removeLast()
            for singlefeature in sortedSingleFeatures {
                if singlefeature.trueRank < 11 || singlefeature.trueRank > 13 {
                    return (false, 0, "")
                }
            }
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "黑桃A和JQK")
        }
        return (false, 0, "")
    }
    
    static func isBullAPair(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
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
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if !bull.contains(where: {$0 as! AnyHashable == singlefeature as! AnyHashable}) {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    rank = 0
                    if otherSingleFeatures[0].trueRank == 1 && otherSingleFeatures[1].trueRank == 1 {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxSingleFeature(singlefeatures: otherSingleFeatures)
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
    
    static func isBullWithSpadeA(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
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
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if !bull.contains(where: {$0 as! AnyHashable == singlefeature as! AnyHashable}) {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    rank = 0
                    if (otherSingleFeatures[0].trueRank == 1 && otherSingleFeatures[0].suit == 3) || (otherSingleFeatures[1].trueRank == 1 && otherSingleFeatures[1].suit == 3) {
                        if self.sameBullPointComparison == 0 {
                            rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
                        } else if self.sameBullPointComparison == 1 {
                            rank = rankForMaxSingleFeature(singlefeatures: otherSingleFeatures)
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
    
    static func isGoldBullWithSpadeA(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var sortedSingleFeatures = singlefeatures.sorted(by: { $0.trueRank < $1.trueRank })
        if sortedSingleFeatures.last?.trueRank == 1 && sortedSingleFeatures.last?.suit == 3 {
            sortedSingleFeatures.removeLast()
            for singlefeature in sortedSingleFeatures {
                if singlefeature.trueRank < 11 || singlefeature.trueRank > 15 {
                    return (false, 0, "")
                }
            }
            return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "黄金牛加黑桃A")
        }
        return (false, 0, "")
    }
    
    static func isFiveLittle(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        if singlefeatures.map({ $0.rank2Value }).reduce(0, +) > 10 {
            return (false, 0, "")
        }
        for singlefeature in singlefeatures {
            if singlefeature.rank2Value > 5 {
                return (false, 0, "")
            }
        }
        let rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
        return (true, rank, "五小")
    }
    
    static func isHighSingleFeature(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        
        return (true, rankForMaxSingleFeature(singlefeatures: singlefeatures), "单牌")
    }
    static func isIronBullPlusBull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String){
        let (flag1, rank1, singlefeatureType1) =  self.isIronBull(singlefeatures: singlefeatures)
        let (flag2, rank2, singlefeatureType2) = self.isBull(singlefeatures: singlefeatures)
        let mask = 0b111111111111111111
        let bullSecondRank = rank2 & mask
        let bullRank = (rank2 >> 18) << 1
        let ironRank = (rank1 << 1) | 1
        
        var singlefeatureType = ""
        var rank = 0
        if bullRank > ironRank {
            rank = (bullRank << 18 | bullSecondRank)
            singlefeatureType = singlefeatureType2
            
        } else {
            rank = (ironRank << 18 | mask)
            singlefeatureType = singlefeatureType1
        }
        
        return (flag1 || flag2, rank, singlefeatureType)
    }
    static func isThreeSingleFeatureBullPlusBull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String){
        let tempBullRules = Array(self.bullRules)
        let mask = 0b111111111111111111

        self.bullRules = [0]
        var (flag1, rank1, singlefeatureType1) = self.isBull(singlefeatures: singlefeatures)
        let secondRank1 = rank1 & mask
        self.bullRules = [1]

        var (flag2, rank2, singlefeatureType2) = self.isBull(singlefeatures: singlefeatures)
        let secondRank2 = rank2 & mask
        self.bullRules = tempBullRules
        rank1 = rank1>>18
        rank2 = rank2>>18

        if flag1 == true && flag2 == true{
            if rank1 > rank2{
                return (flag1, (rank1 << 19) | secondRank1, singlefeatureType1)
            } else {
                return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), singlefeatureType2)
            }
        } else if flag1 == false && flag2 == true {
            return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), singlefeatureType2)
            
        } else if flag2 == false && flag1 == true {
            return (flag1, (rank1 << 19) | secondRank1, singlefeatureType1)
        }
        return (false, 0, "")
    }
    
    static func isThreeSingleFeatureBullBUllPlusBullBull(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String){
        let tempBullRules = Array(self.bullRules)
        let mask = 0b111111111111111111

        self.bullRules = [0]
        var (flag1, rank1, singlefeatureType1) = self.isBullBull(singlefeatures: singlefeatures)
        let secondRank1 = rank1 & mask

        self.bullRules = [1]
        var (flag2, rank2, singlefeatureType2) = self.isBullBull(singlefeatures: singlefeatures)
        let secondRank2 = rank2 & mask
        
        rank1 = rank1>>18
        rank2 = rank2>>18

        self.bullRules = tempBullRules
        if flag1 == true && flag2 == true{
            if rank1 > rank2{
                return (flag1, (rank1 << 19) | secondRank1, singlefeatureType1)
            } else {
                return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), singlefeatureType2)
            }
        } else if flag1 == false && flag2 == true {
            return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), singlefeatureType2)
            
        } else if flag2 == false && flag1 == true {
            return (flag1, (rank1 << 19) | secondRank1, singlefeatureType1)
        }
        return (false, 0, "")
    }
    
    static func Is_threeSingleFeature(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String) {
        var counts: [Int: [PBDataset.PBSingleFeature]] = [:]
        for singlefeature in singlefeatures {
            counts[singlefeature.trueRank, default: []].append(singlefeature)
            if counts[singlefeature.trueRank]!.count == 3 {
                let singlefeatureType: String = "三条" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeature.trueRank]!
                return (true, singlefeature.rank2Value, singlefeatureType)
            }
        }
        return (false, 0, "")
    }
    
    static func Is_bullOrFiveFeaturePoints(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int, String){
        let mask = 0b111111111111111111

        var (flag1, rank1, singlefeatureType1) = self.isBull(singlefeatures: singlefeatures)
        let secondRank1 = rank1 & mask
        var rank2 = self.sumAllBullSingleFeature(combination: singlefeatures, rank: 1)
        let secondRank2 = 1

        rank1 = rank1>>18
        var flag2 = false
        let singlefeatureType2: String = "5张相加\(rank2)"
        if rank2 > 5 && rank2 < 10 {
            flag2 = true
        }
        
        print("牛：\(singlefeatureType1) 五张点数和 \(rank2)")
        if flag1 == true && flag2 == true{
            if rank1 > rank2{
                return (flag1, (rank1 << 19) | secondRank1, singlefeatureType1)
            } else {
                return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), singlefeatureType2)
            }
        } else if flag1 == false && flag2 == true {
            return (flag2, (((rank2 << 1) | 1)<<18 | secondRank2), singlefeatureType2)
            
        } else if flag2 == false && flag1 == true {
            return (flag1, (rank1 << 19) | secondRank1, singlefeatureType1)
        }
        return (false, 0, "")
    }
    
    static func isBullPlusPairFive(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int,String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0, "")
        }
        var singlefeatureType: String = ""
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if self.hasSingleFeature(combination: bull, searchSingleFeature: singlefeature) == false {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    rank = 0
                    if otherSingleFeatures[0].trueRank == otherSingleFeatures[1].trueRank && otherSingleFeatures[0].trueRank == 5{
                        
                        let currentRank = (otherSingleFeatures[0].trueRank << 18) | self.rankForSameBullSamePoint(singlefeatures: singlefeatures, otherSingleFeatures: otherSingleFeatures)
                        if currentRank > rank{
                            rank = currentRank
                            singlefeatureType = "牛加对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[otherSingleFeatures[0].trueRank]!
                        }
                    }
                }
            }
        }
        if rank == 0 {
            return (false, 0,"")
        }
        return (true, rank, singlefeatureType)
    }
    
    static func isBullPlusPairTen(singlefeatures: [PBDataset.PBSingleFeature]) -> (Bool, Int,String) {
        var allbulls: [[[PBDataset.PBSingleFeature]]] = []
        var rank = 0
        
        // find out all bull
        for index in self.bullRules {
            let bullFunc = self.IS_BULL_DIC[index]!
            let bulls = bullFunc(singlefeatures)
            if !bulls.isEmpty {
                allbulls.append(bulls)
            }
        }
        
        if allbulls.isEmpty {
            return (false, 0, "")
        }
        var singlefeatureType: String = ""
        for bulls in allbulls {
            for bull in bulls {
                if bull.count == 5 {
                    continue
                }
                if bull.count == 3 {
                    var otherSingleFeatures: [PBDataset.PBSingleFeature] = []
                    for singlefeature in singlefeatures {
                        if self.hasSingleFeature(combination: bull, searchSingleFeature: singlefeature) == false {
                            otherSingleFeatures.append(singlefeature)
                        }
                    }
                    rank = 0
                    if otherSingleFeatures[0].trueRank == otherSingleFeatures[1].trueRank && otherSingleFeatures[0].trueRank == 10{
                        
                        let currentRank = (otherSingleFeatures[0].trueRank << 18) | self.rankForSameBullSamePoint(singlefeatures: singlefeatures, otherSingleFeatures: otherSingleFeatures)
                        if currentRank > rank{
                            rank = currentRank
                            singlefeatureType = "牛加对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[otherSingleFeatures[0].trueRank]!
                        }
                    }
                }
            }
        }
        if rank == 0 {
            return (false, 0,"")
        }
        return (true, rank, singlefeatureType)
    }



    // ... (other rank rule functions)
    //
    static func rankForMaxSingleFeature(singlefeatures: [PBDataset.PBSingleFeature]) -> Int {
            let sortedSingleFeatures = sortBullSingleFeaturesFromHighToLow(singlefeatures: singlefeatures)
            let rank = sortedSingleFeatures[0].score
            return rank
        }
    
    
    static func sortBullSingleFeaturesFromHighToLow(singlefeatures: [PBDataset.PBSingleFeature]) -> [PBDataset.PBSingleFeature] {
        return singlefeatures.sorted { $0.score > $1.score }
    }
    
    static func sortBullSingleFeaturesFromLowToHigh(singlefeatures: [PBDataset.PBSingleFeature]) -> [PBDataset.PBSingleFeature] {
        return singlefeatures.sorted { $0.score < $1.score }
    }
    
    static func rankForSameBullSamePoint(singlefeatures: [PBDataset.PBSingleFeature], otherSingleFeatures: [PBDataset.PBSingleFeature]) -> Int {
        switch self.sameBullPointComparison{
        case 0:
            let rank = rankForMaxSingleFeature(singlefeatures: singlefeatures)
            return rank
        case 1:
            let rank = rankForMaxSingleFeature(singlefeatures: otherSingleFeatures)
            return rank
        case 2:
            return 1
        case 3:
            let sortedSingleFeatures = sortBullSingleFeaturesFromHighToLow(singlefeatures: singlefeatures)
            let rank = sortedSingleFeatures[0].score << 12 | sortedSingleFeatures[1].score << 6 | sortedSingleFeatures[2].score
            return rank
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    static func sumAllBullSingleFeature(combination:[PBDataset.PBSingleFeature], rank: Int) -> Int{
        var sum:Int = 0
        for singlefeature in combination{
            if rank == 1{
                sum += singlefeature.rank1Value

            } else if rank == 2{
                sum += singlefeature.rank2Value

            } else if rank == 3{
                sum += singlefeature.trueRank
            }
        }
        return sum
    }
    
    static func hasSingleFeature(combination: [PBDataset.PBSingleFeature], searchSingleFeature: PBDataset.PBSingleFeature)-> Bool{
        for singlefeature in combination{
            if singlefeature.singlefeatureIndex == searchSingleFeature.singlefeatureIndex{
                return true
            }
        }
        return false
    }
    
    
}
