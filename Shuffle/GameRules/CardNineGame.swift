
import Foundation
//import Python
//import PythonKit

//九点半

class CardNineGameRule : Rule{
    
    let redJokerValueRange:[Int:String] = [
        0:"6",
        1:"1"
    ]
    let blackJokerValueRange: [Int: String] = [
        0:"6",
        1:"3",
        2:"1"
    ]
    let KValueRange:[Int:String] = [
        0:"3",
        1:"1"
    ]
    let QValueRange:[Int:String] = [
        0:"2",
        1:"1"
    ]
    let JValueRange:[Int:String] = [
        0:"1"
    ]
    let pointComparision:[Int: String] = [
        0:"9点最大，0点最小",
    ]
    let samePointComparision:[Int: String] = [
        0:"同点比最大牌，最大牌相同时庄家赢",
        1:"同对庄大，同点有Q最大，有2次大，其他同点同大",
    ]
    let AValueRange:[Int:String] = [
        0:"1",
        1:"6"
    ]
    let pairRank:[Int: String] = [
        0:"对子正常算大小",
        1:"对子一样大不分大小",
    ]
    let cardRankRule:[Int:String] = [
        0:"K>Q>J>...2>A",
        1:"A>K>Q>J>...>2",
        2:"红Q>红2>红8>红4>红10>红6>黑4>黑八>黑10>红7>黑6>黑9>",
        3:"红Q>红2>红8>红4>红10>红6>黑4>黑J>黑10>红7>黑6>黑9>黑8>黑7>黑5>大王>小王",
        4:"红Q>红2>红8>红4>红6(=红10=黑4)>红J(=黑10=红7=黑6)>红9(=黑8=黑7=红5=大王=黑桃A=黑桃3-红桃3)",
        5:"黑2>红2>红8>红4>红10>红6>黑4>红1>黑10>红7>黑6>黑9>黑8>黑7>黑5>大王>小王"
    ]
    let handNum:[Int] = [2,4]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            39:"红8+红J",
            38:"红2+7",
            37:"红Q+7",
            36:"红2+ 红9",
            35:"对红9=对红5=对黑8=对黑7",
            34:"红3 + 黑8",
            33:"红5 + 大王",
            32:"红桃3 + 红8",
            31:"对黑9=对黑8=对黑7=对黑5",
            30:"对红J=对红10=对红7=对红6",
            29:"对黑10=对黑6=对黑4",
            28:"对黑7",
            27:"对黑8",
            26:"对黑9",
            25:"对黑6",
            24:"对红7",
            23:"对黑10",
            22:"对黑J",
            21:"对黑4",
            20:"对红6",
            19:"对红10",
            18:"对红4",
            17:"对红8",
            16:"对王",
            15:"对2",
            14:"对Q",
            13:"对黑5",
            12:"黑3+大王",
            11:"对红5",
            10:"黑A+黑3",
            9: "对红2",
            8: "对红Q",
            7: "红对子",
            6: "黑对子",
            5: "混对子",
            4: "对子",
            3: "Q + 9",
            2: "Q + 8",
            1: "2 + 8",
            0: "点数"
        ]
        self.setting = [
            0: "杭州小牌九",
            1: "温州牌九[260]",
            2: "通用四张-牌九大牌九1[...",
            3: "52张小牌九[262]",
            4: "宁波小牌九[263]",
            5: "杭州牌九[264]",
            6: "32张牌9[456]",
            7: "湖南牌九[265]",
            8: "通用四张-32张牌九[416]",
            9: "山西牌九[268]",
            10: "通用四张-54张大牌九[..",
            11: "34张小牌九[457]",
            12: "通用四张-32张牌九二[...",
            13: "温州牌九黑大3[269]",
            14: "南京牌九[261]",
            15: "32张牌九[266]",
            16: "山西牌九[269]",
            17: "通用四张-杭州牌九[420]",
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
    扑克张数:32张
    用牌红对Q，两张红5，两张红9，两张红2，两张红J，对王，4个4/4个6/4个7/4个8/4个10
    1)对红Q最大>对红2>黑A+黑3,.>对红5
    2)红Q+红9>红Q+红8黑8>红2+红
    8.....0点最小。
    3) A=6点,同点比最大牌
    """,
            2:"""
扑克张数:41张
用牌红对Q，两张王，两张红2，4个4/4个6/4个7/4个8/4个10/4个J/4个九/4个5/两个红3-个黑3
1)黑3+大王>对红Q>对红2>.....对黑5
2)红Q+黑9>红Q+红8黑8>红2+红8黑8.....0点最小。
3)王=6点，同点比最大牌
""",
            3:"""
扑克张数:52张
1)对Q最大>对2>对K......>对A最小。
2) Q+8>2+8>9点>8点>....0点最小
3)k=3点 Q=2点J=1点，同对庄大，同点有Q最大，有2次大，其他同点同大
""",
            4:"""
扑克张数:32张
用牌红对Q，一张红5一张黑5，一张红9一张黑9，一张红3，两张红2，两张黑J，大王1张，4个4/4个6/4个7/4个8/4个10
1)至尊最大
2)天地人和三长四短五杂
3)三长都是平点，四短都是平点，所有零点都是平点
4)2+9为1点，选牌大王+红3，黑5红5，黑9红9，黑J梅J
""",
            5:"""
扑克张数:32张
选牌大王+黑3，59J都是黑色
1)至尊最大
2)天地人和三长四短五杂
3)三长都是平点，四短都是平点，所有零点都是平点
""",
            6:"""
32张大牌九每人四张牌、头两张牌尾两张牌
大小王/红Q两个/红2两个/黑J两个/黑9两个/黑5两个/4个10/4个8/4个7/4个6/4个4.共32张大小排名
1》对子:两个王>对红Q>红Q+黑9>对红2>对红8>对红4>对红10>对红6>对黑4>对黑J>对黑10>对红7>对黑6>对黑9>对黑8>对黑7>对黑5>Q和8>2和8对子要分红黑一红一黑不算对子只算点数
2》点数:9点最大0点最小。J为1点 Q为2点小王算3点大王算6点同点时比最大的牌，
同点同牌庄家大最大的牌从大到小:红Q>红2>红8>红4>红10>红6>黑4>黑八>黑10>红7>黑6>黑9>
""",
            7:"""
大小王最大
""",
            8:"""
扑克张数:32张
大小王/红Q两个/红2两个/黑J两个/黑9两个/黑5两个/4个10/4个8/4个7/4个6/4个4.共32张大小排名
1》对子:两个王>对红Q>红Q+黑9>对红2>对红8>对红4>对红10>对红6>对黑4>对黑J>对黑10>对红7>对黑6>对黑9>对黑8>对黑7>对黑5>Q和8>2和8对子要分红黑一红一黑不算对子只算点数
2》点数:9点最大0点最小。J为1点 Q为2点小王算3点大王算6点同点时比最大的牌，
同点同牌庄家大最大的牌从大到小:红Q>红2>红8>红4>红10>红6>黑4>黑J>黑10>红7>黑6>黑9>黑8>黑7>黑5>大王>小王
""",
            9:"""
扑克张数:32张
对红Q，对红2，对红J，对黑9，对黑5，4个8，4个4，4个10，4个6，4个7，黑3，黑A
1)黑A+黑3>对红Q>对红2>对红8>对红4>对黑10=对黑6=对黑4>对红J=对红10=对红7=对红6>对黑9=对黑8=对黑7=对黑5
2)红Q+红8=红Q+黑8>红2+红8=红2+黑8>9点>8点>7点......>0点同色才算对子 A=6点。
同点比最大牌
""",
            10:"""
扑克张数54张牌
1:两黑或者两红算对子，
2:对子一黑一红算点数，对子一样大不分大小，四张分头尾
3:对王>王+9>对A>对k>.....对2.
4:王+8> A+8> k+8>......0.同点庄赢
JQK王=1同点比最大牌
""",
            11:"""
1)用牌数，黑桃A，2个红2，黑桃3，红桃3，4个4，2个红5，4个6，4个7，4个8，2个红9，4个10，俩个红 J，俩个红Q，大王，一共34张牌，每家发2张牌
牌型大小顺序:对红Q>对红2>大王+黑桃 3>对红8>红桃3+红8>红5+大王>对红4>红3+黑8>对黑10(=对黑6=对黑4)>对红10(=对红J=对红7=对红6)>对红9(=对红5=对黑8=对黑7)>红
Q+红9>红2+红9>红Q+8>红2+8>红 Q+7>红2+7>红8+红J
接下来比点数，(Q=2点，J=1点，黑桃 A=6点，大王=6点)点数相同时比最大的牌。红Q>红2>红8>红4>红6(=红10=黑4)>红J(=黑10=红7=黑6)>红9(=黑8=黑7=红5=大王=黑桃A=黑桃3-红桃3)最大牌相同时庄家赢,同是0点一样的，黑桃3+红桃3=6点，大王+黑桃A=2点
""",
            12:"""
扑克数量:32张大牌九
1:每人四张牌、头两张牌尾两张牌2:大小王/4个2/红1两个/黑9两个/黑5两个/
4个10/4个8/4个7/4个6/4个4.共32张
大小排名
1》对子:两个王>对红2>红Q+黑9>对红2>对
红8>对红4>对红10>对红6>对黑4>对红1>
对黑10>对红7>对黑6>对黑9>对黑8>对黑7
>对黑5>Q和8>2和8对子要分红黑 一红一黑不算对子只算点数
2》点数:9点最大0点最小。J为1点 Q为2点小王算3点大王算6点同点时比最大的牌,同点同牌庄家大 最大的牌大到小：黑2>红2>红8>红4>红10>红6>黑4>红1>黑10>红7>黑6>黑9>黑8>黑7>黑5>大王>小王
""",
            13:"""
扑克张数:32张
1:大王红桃3，红J红9红5
2:对子大王红桃3最大，0点最小，同门点数一样，庄家大!
""",
            14:"""
扑克张数:32张
用牌红对Q，两张红5，两张红9，两张红2，两张红J，对王，4个4/4个6/4个7/4个8/4个10
1)对王最大>对红Q>对红2>对红5
2)红Q+红8黑8>红2+红8黑8.....0点最小。
3)大王=6点,小王3点，同点比最大牌
4)1自尊，2天地人和三长四短五杂，3三长都是平点，四短都是平点，所有零点都是平点。没有天九地九，选牌大小王，59J红色。
""",
            15:"""
扑克张数:32张
大小王/红Q两个/红2两个/黑J两个/黑9两个/黑5两个/4个10/4个8/4个7/4个6/4个4.共32张大小排名
1》对子:两个王>对红Q>红Q+黑9>对红2>对红8>对红4>对红10>对红6>对黑4>对黑J>对黑10>对红7>对黑6>对黑9>对黑8>对黑7>对黑5>Q和8>2和8对子要分红黑一红一黑不算对子只算点数
2》点数:9点最大0点最小。J为1点 Q为2点小王算3点大王算6点同点时比最大的牌，
同点同牌庄家大最大的牌从大到小:红Q>红2>红8>红4>红10>红6>黑4>黑J>黑10>红7>黑6>黑9>黑8>黑7>黑5>大王>小王
""",
            16:"""
扑克张数:32张
对红Q，对红2，对红J，对黑9，对黑5，4个8，4个4，4个10，4个6，4个7，黑3，黑A
1)黑A+黑3>对红Q>对红2>对红8>对红4>对黑10=对黑6=对黑4>对红J=对红10=对红7=对红6>对黑9=对黑8=对黑7=对黑5
2)红Q+红8=红Q+黑8>红2+红8=红2+黑8>9点>8点>7点.…...>0点同色才算对子 A=6点。
同点比最大牌
""",
            17:"""
游戏说明
扑克张数:32张
选牌大王+黑3，59J都是黑色
1)至尊最大
2)天地人和三长四短五杂
3)三长都是平点，四短都是平点，所有零点都是平点
""",
        ]
        self.playerNum = [2,3,4,5,6,7,8,9,10]

    }
}


class CardNineGame{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputCards:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        
        var deck = initDeck(initialCards: inputCards, suitRules: suitRules)
        let (winners, leftCards) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, deck: deck, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftCards)
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
        case 1:
            result = [24,50,17,43,21,47,14,40,23,49,53,54,3,16,29,42,5,18,31,44,6,19,32,45,7,20,33,46,9,22,35,48]
            break
        case 2:
            result = [24,50,53,52,14,40,3,4,5,6,7,8,9,10,16,17,18,19,20,21,22,23,29,30,31,32,33,34,35,36,42,43,44,45,46,47,48,49,2,15,41]
            break
        case 3:
            result = Array(0...51)
            break
        case 4:
            result = [24,50,4,17,8,21,15,14,40,10,36,54,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
        case 5:
            result = Array(0...51)
            break
        case 6:
            result = [54,53,24,50,14,40,10,36,8,34,4,30,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
            break
        case 7:
            result = [54,53,24,50,14,40,10,36,8,34,4,30,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
            break
        case 8:
            result = [54,53,24,50,14,40,10,36,8,34,4,30,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
            break
        case 9:
            result = [24,50,14,40,23,49,8,34,4,30,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48,2,0,28,26]
            break
        case 10:
            result = Array(0...51) + [53,54]
            break
        case 11:
            result = [0,14,40,2,15,17,43,21,47,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
            break
        case 12:
            result = [53,54,1,14,27,40,13,39,8,34,4,30,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
            break
        case 13:
            result = Array(0...51) + [53,54]
            break
        case 14:
            result = [24,50,17,43,21,47,14,40,23,49,53,54,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
            break
        case 15:
            result = [53,54,24,50,14,40,10,36,8,34,4,30,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
            break
        case 16:
            result = [24,50,14,40,23,49,8,34,4,30,2,0,28,26,3,5,6,7,9,16,18,19,20,22,29,31,32,33,35,42,44,45,46,48]
            break
        case 17:
            result = Array(0...51) + [53,54]
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
    //3 redJokerValueRange
    //4 blackJokerValueRange
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 pointComparision
    //9 samePointComparision
    //10 AValueRange
    //11 pairRank
    //12 cardRankRule
    //13 handNum


    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], deck: [Card], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([GameReturnPlayerInfo],[Int]) {
        let rule = GameManager.gameRules[9] as! CardNineGameRule
        let dealNum = args[0]
        let dealType = args[1]
        let playerNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let redJokerValueRange = args[5]
        let blackJokerValueRange = args[6]
        let KValueRange = args[7]
        let QValueRange = args[8]
        let JValueRange = args[9]
        let pointComparision = args[10]
        let samePointComparision = args[11]
        let AValueRange = args[12]
        let pairRank = args[13]
        let cardRankRule = args[14]

        
        var maxRank = 0

        var allPlayCards: [Player] = []
        var community = [Card]()
        var returnPlayerInfos:[GameReturnPlayerInfo] = []
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
        
        
        
        for i in 0..<playerNum {
            allPlayCards[i].evaluateFlag = CardNineGameHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(cards: allPlayCards[i].playerCard, redJokerValueRange: redJokerValueRange,blackJokerValueRange: blackJokerValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange, AValueRange: AValueRange,pointComparision: pointComparision,samePointComparision: samePointComparision, cardRankRule: cardRankRule, pairRank: pairRank)
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
        if leftCards.count < CardNineGame.getMinCardNum(playerNum: playerNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftCards = []
        }
        return (returnPlayerInfos, leftCards)
    }
}

class CardNineGameHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([CardNineCard]) -> Int] = [:]
    var pointComparision:Int = 0
    var samePointComparision: Int = 0
    var pairRank: Int = 0
    
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
    
    func evalHand(cards: [Card],redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, AValueRange: Int, pointComparision: Int, samePointComparision: Int, cardRankRule: Int, pairRank: Int)->Int{
        var cards = cards
        self.pointComparision = pointComparision
        self.samePointComparision = samePointComparision
        self.pairRank = pairRank
        
        let num1 = CardNineCard(card: cards[0], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, AValueRange: AValueRange, suitRules: self.suitRules, cardRankRule: cardRankRule)
        
        let num2 = CardNineCard(card: cards[1], redJokerValueRange: redJokerValueRange, blackJokerValueRange: blackJokerValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, AValueRange: AValueRange, suitRules: self.suitRules, cardRankRule: cardRankRule)
        
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
    
    func eval_RedEightRedJ(cards: [CardNineCard]) -> Int{
        if cards[0].originalRank == 8 && cards[0].color == 1 && cards[1].originalRank == 11 && cards[1].color == 1{
            return 1
        }
        if cards[0].originalRank == 11 && cards[0].color == 1 && cards[1].originalRank == 8 && cards[1].color == 1{
            return 1
        }
        return 0
    }
    
    func eval_RedTwoRedSeven(cards: [CardNineCard]) -> Int{
        if cards[0].originalRank == 2 && cards[0].color == 1 && cards[1].originalRank == 7 && cards[1].color == 1{
            return 1
        }
        if cards[0].originalRank == 7 && cards[0].color == 1 && cards[1].originalRank == 2 && cards[1].color == 1{
            return 1
        }
        return 0
    }
    
    func eval_RedQRedSeven(cards: [CardNineCard]) -> Int{
        if cards[0].originalRank == 12 && cards[0].color == 1 && cards[1].originalRank == 7 && cards[1].color == 1{
            return 1
        }
        if cards[0].originalRank == 7 && cards[0].color == 1 && cards[1].originalRank == 12 && cards[1].color == 1{
            return 1
        }
        return 0
    }
    
    func eval_RedTwoRedNine(cards: [CardNineCard]) -> Int{
        if cards[0].originalRank == 2 && cards[0].color == 1 && cards[1].originalRank == 9 && cards[1].color == 1{
            return 1
        }
        if cards[0].originalRank == 9 && cards[0].color == 1 && cards[1].originalRank == 2 && cards[1].color == 1{
            return 1
        }
        return 0
    }
    
    func eval_isRedNineFiveBlackEightSevenPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && (cards[0].originalRank == 9 || cards[0].originalRank == 5){
            return 1
        }
        
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && (cards[0].originalRank == 8 || cards[0].originalRank == 7){
            return 1
        }
        return 0
    }
    
    
    func eval_RedThreeBlackEight(cards: [CardNineCard]) -> Int{
        if cards[0].originalRank == 3 && cards[0].color == 1 && cards[1].originalRank == 8 && cards[1].color == 0{
            return 1
        }
        if cards[0].originalRank == 8 && cards[0].color == 0 && cards[1].originalRank == 3 && cards[1].color == 1{
            return 1
        }
        return 0
    }
    
    func eval_RedFiveRedJoker(cards: [CardNineCard]) -> Int{
        if cards[0].originalRank == 15 && cards[1].originalRank == 5 && cards[1].color == 1{
            return 1
        }
        if cards[0].originalRank == 5 && cards[0].color == 1 && cards[1].originalRank == 15 {
            return 1
        }
        return 0
    }
    
    func eval_HeartThreeRedEight(cards: [CardNineCard]) -> Int{
        if (cards[0].originalRank == 8 && cards[0].color == 1) && (cards[1].originalRank == 3 && self.suitRules.firstIndex(of: cards[1].suit) == 1){
            return 1
        }
        
        return 0
    }
    
    func eval_isBlackNineEightSevenFivePair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && (cards[0].originalRank == 9 || cards[0].originalRank == 8 || cards[0].originalRank == 7 || cards[0].originalRank == 5){
            return 1
        }
        return 0
    }
    
    func eval_isRedJTenSevenSixPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && (cards[0].originalRank == 11 || cards[0].originalRank == 10 || cards[0].originalRank == 7 || cards[0].originalRank == 6){
            return 1
        }
        return 0
    }
    
    func eval_isBlackTenSixFivePair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && (cards[0].originalRank == 10 || cards[0].originalRank == 6 || cards[0].originalRank == 5){
            return 1
        }
        return 0
    }
    
    func eval_isBlackSevenPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && cards[0].originalRank == 7{
            return 1
        }
        return 0
    }
    
    func eval_isBlackEightPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && cards[0].originalRank == 8{
            return 1
        }
        return 0
    }
    
    func eval_isBlackNinePair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && cards[0].originalRank == 9{
            return 1
        }
        return 0
    }
    
    func eval_isBlackSixPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && cards[0].originalRank == 6{
            return 1
        }
        return 0
    }
    
    func eval_isRedSevenPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && cards[0].originalRank == 7{
            return 1
        }
        return 0
    }
    
    func eval_isBlackTenPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && cards[0].originalRank == 10{
            return 1
        }
        return 0
    }
    
    func eval_isBlackJPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && cards[0].originalRank == 11{
            return 1
        }
        return 0
    }
    
    func eval_isBlackFourPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && cards[0].originalRank == 4{
            return 1
        }
        return 0
    }
    
    func eval_isRedSixPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && cards[0].originalRank == 6{
            return 1
        }
        return 0
    }
    
    func eval_isRedTenPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && cards[0].originalRank == 10{
            return 1
        }
        return 0
    }
    
    func eval_isRedFourPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && cards[0].originalRank == 4{
            return 1
        }
        return 0
    }
    
    func eval_isRedEightPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && cards[0].originalRank == 8{
            return 1
        }
        return 0
    }
    
    func eval_isJokerPair(cards:[CardNineCard]) -> Int{
        if cards[0].originalRank == 15 && cards[0].originalRank == 14{
            return 1
        }
        return 0
    }
    
    func eval_isTwoPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].originalRank == 2{
            return 1
        }
        return 0
    }
    
    func eval_isQPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].originalRank == 12{
            return 1
        }
        return 0
    }
    
    func eval_isBlackFivePair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 && cards[0].originalRank == 5{
            return 1
        }
        return 0
    }
    
    func eval_RedJokerandBlackThree(cards: [CardNineCard]) -> Int{
        if cards[0].originalRank == 15 && cards[0].color == 0 && cards[1].originalRank == 3 && cards[1].color == 0{
            return 1
        }
        if cards[0].originalRank == 3 && cards[0].color == 0 && cards[1].originalRank == 15 && cards[1].color == 0{
            return 1
        }
        return 0
        
    }
    
    func eval_isRedFivePair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && cards[0].originalRank == 5{
            return 1
        }
        return 0
    }
    
    func eval_BlackAandBlackThree(cards: [CardNineCard]) -> Int{
        if cards[0].originalRank == 1 && cards[0].color == 0 && cards[1].originalRank == 3 && cards[1].color == 0{
            return 1
        }
        if cards[0].originalRank == 3 && cards[0].color == 0 && cards[1].originalRank == 1 && cards[1].color == 0{
            return 1
        }
        return 0
        
    }
    func eval_isRedTwoPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && cards[0].originalRank == 2{
            return 1
        }
        return 0
    }
    
    func eval_isRedQPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 && cards[0].originalRank == 12{
            return 1
        }
        return 0
    }
    
    func eval_isRedColorPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 1 && cards[1].color == 1 {
            if self.pairRank == 0{
                return cards[0].rank
            } else if self.pairRank == 1{
                return 1
            }
        }
        return 0
    }
    
    func eval_isBlackColorPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color == 0 && cards[1].color == 0 {
            if self.pairRank == 0{
                return cards[0].rank
            } else if self.pairRank == 1{
                return 1
            }
        }
        return 0
    }
    
    func eval_isMixColorPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank && cards[0].color != cards[1].color {
            if self.pairRank == 0{
                return cards[0].rank
            } else if self.pairRank == 1{
                return 1
            }
        }
        return 0
    }
    
    func eval_isPair(cards:[CardNineCard]) -> Int{
        if cards[0].rank == cards[1].rank{
            if self.pairRank == 0{
                return cards[0].rank
            } else if self.pairRank == 1{
                return 1
            }
        }
        return 0
    }
    func eval_isQPlus9(cards: [CardNineCard]) -> Int {
        if cards[0].originalRank == 12 && cards[1].originalRank == 9{
            return 1
        }
        return 0
    }
    func eval_isQPlus8(cards: [CardNineCard]) -> Int {
        if cards[0].originalRank == 12 && cards[1].originalRank == 8{
            return 1
        }
        return 0
    }
    func eval_is2Plus8(cards: [CardNineCard]) -> Int {
        if cards[0].originalRank == 8 && cards[1].originalRank == 2{
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
        var originalRank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var cardIndex: Int = 0
        var color: Int = 0
        
        init(card: Card, redJokerValueRange: Int, blackJokerValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, AValueRange: Int, suitRules:[Int], cardRankRule: Int){
            let rule = GameManager.gameRules[9] as! CardNineGameRule
            self.cardIndex = card.cardIndex
            
            //suit Initialization
            self.suit = card.suit[0]
            //color Initialization
            //black
            if suitRules.firstIndex(of: self.suit)! == 0 || suitRules.firstIndex(of: self.suit)! == 2{
                self.color = 0
            //red
            } else if suitRules.firstIndex(of: self.suit)! == 1 || suitRules.firstIndex(of: self.suit)! == 3{
                self.color = 1
            }
            
            //Rank Initialization
            self.originalRank = card.rank
            if cardRankRule == 0{
                self.rank = card.rank
            } else if cardRankRule == 1{
                if card.rank == 1{
                    self.rank = 14
                }
                if card.rank > 13 {
                    self.rank = card.rank + 1
                }
            } else if cardRankRule == 2{
                //红Q
                if self.color == 1 && card.rank == 12{
                    self.rank = 17
                }
                //红2
                if self.color == 1 && card.rank == 2{
                    self.rank = 16
                }
                //红8
                if self.color == 1 && card.rank == 8{
                    self.rank = 15
                }
                //红4
                if self.color == 1 && card.rank == 4{
                    self.rank = 14
                }
                //红10
                if self.color == 1 && card.rank == 10{
                    self.rank = 13
                }
                //红6
                if self.color == 1 && card.rank == 6{
                    self.rank = 12
                }
                //黑4
                if self.color == 0 && card.rank == 4{
                    self.rank = 11
                }
                //黑8
                if self.color == 0 && card.rank == 8{
                    self.rank = 10
                }
                //黑10
                if self.color == 0 && card.rank == 10{
                    self.rank = 9
                }
                //红7
                if self.color == 1 && card.rank == 7{
                    self.rank = 8
                }
                //黑6
                if self.color == 0 && card.rank == 6{
                    self.rank = 7
                }
                //黑9
                if self.color == 0 && card.rank == 9{
                    self.rank = 6
                }
                
            } else if cardRankRule == 3 {
                //红Q
                if self.color == 1 && card.rank == 12{
                    self.rank = 17
                }
                //红2
                if self.color == 1 && card.rank == 2{
                    self.rank = 16
                }
                //红8
                if self.color == 1 && card.rank == 8{
                    self.rank = 15
                }
                //红4
                if self.color == 1 && card.rank == 4{
                    self.rank = 14
                }
                //红10
                if self.color == 1 && card.rank == 10{
                    self.rank = 13
                }
                //红6
                if self.color == 1 && card.rank == 6{
                    self.rank = 12
                }
                //黑4
                if self.color == 0 && card.rank == 4{
                    self.rank = 11
                }
                //黑J
                if self.color == 0 && card.rank == 11{
                    self.rank = 10
                }
                //黑10
                if self.color == 0 && card.rank == 10{
                    self.rank = 9
                }
                //红7
                if self.color == 1 && card.rank == 7{
                    self.rank = 8
                }
                //黑6
                if self.color == 0 && card.rank == 6{
                    self.rank = 7
                }
                //黑9
                if self.color == 0 && card.rank == 9{
                    self.rank = 6
                }
                //黑8
                if self.color == 0 && card.rank == 8{
                    self.rank = 5
                }
                //黑7
                if self.color == 0 && card.rank == 7{
                    self.rank = 4
                }
                //黑5
                if self.color == 0 && card.rank == 5{
                    self.rank = 3
                }
                //大王
                if card.rank == 15{
                    self.rank = 2
                }
                //小王
                if card.rank == 14{
                    self.rank = 1
                }
            } else if cardRankRule == 4{
                //红Q
                if self.color == 1 && card.rank == 12{
                    self.rank = 17
                }
                //红2
                if self.color == 1 && card.rank == 2{
                    self.rank = 16
                }
                //红8
                if self.color == 1 && card.rank == 8{
                    self.rank = 15
                }
                //红4
                if self.color == 1 && card.rank == 4{
                    self.rank = 14
                }
                //红10
                if self.color == 1 && card.rank == 10{
                    self.rank = 13
                }
                //红6
                if self.color == 1 && card.rank == 6{
                    self.rank = 13
                }
                //黑4
                if self.color == 0 && card.rank == 4{
                    self.rank = 13
                }
                //红J
                if self.color == 1 && card.rank == 11{
                    self.rank = 10
                }
                //黑10
                if self.color == 0 && card.rank == 10{
                    self.rank = 10
                }
                //红7
                if self.color == 1 && card.rank == 7{
                    self.rank = 10
                }
                //黑6
                if self.color == 0 && card.rank == 6{
                    self.rank = 10
                }
                //红9
                if self.color == 1 && card.rank == 9{
                    self.rank = 6
                }
                //黑8
                if self.color == 0 && card.rank == 8{
                    self.rank = 6
                }
                //黑7
                if self.color == 0 && card.rank == 7{
                    self.rank = 6
                }
                //红5
                if self.color == 1 && card.rank == 5{
                    self.rank = 6
                }
                //大王
                if card.rank == 15{
                    self.rank = 6
                }
                //黑桃A
                //黑桃3
                //红桃3
                else {
                    self.rank = 6
                }
            } else if cardRankRule == 5{
                //黑2
                if self.color == 0 && card.rank == 2{
                    self.rank = 17
                }
                //红2
                if self.color == 1 && card.rank == 2{
                    self.rank = 16
                }
                //红8
                if self.color == 1 && card.rank == 8{
                    self.rank = 15
                }
                //红4
                if self.color == 1 && card.rank == 4{
                    self.rank = 14
                }
                //红10
                if self.color == 1 && card.rank == 10{
                    self.rank = 13
                }
                //红6
                if self.color == 1 && card.rank == 6{
                    self.rank = 12
                }
                //黑4
                if self.color == 0 && card.rank == 4{
                    self.rank = 11
                }
                //红1
                if self.color == 1 && card.rank == 1{
                    self.rank = 10
                }
                //黑10
                if self.color == 0 && card.rank == 10{
                    self.rank = 9
                }
                //红7
                if self.color == 1 && card.rank == 7{
                    self.rank = 8
                }
                //黑6
                if self.color == 0 && card.rank == 6{
                    self.rank = 7
                }
                //黑9
                if self.color == 0 && card.rank == 9{
                    self.rank = 6
                }
                //黑8
                if self.color == 0 && card.rank == 8{
                    self.rank = 5
                }
                //黑7
                if self.color == 0 && card.rank == 7{
                    self.rank = 4
                }
                //黑5
                if self.color == 0 && card.rank == 5{
                    self.rank = 3
                }
                //大王
                if card.rank == 15{
                    self.rank = 2
                }
                //小王
                if card.rank == 14{
                    self.rank = 1
                }
            }
            
            
            
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
            }else if card.rank == 1{
                self.point = Int(rule.AValueRange[AValueRange]!)!
            } else {
                self.point = card.rank
            }
        }
    }

}

