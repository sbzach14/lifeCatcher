
import Foundation


class CNDatasetRule : Rule{
    
    let redspecialfeatureValueRange:[Int:String] = [
        0:"6",
        1:"1"
    ]
    let blackspecialfeatureValueRange: [Int: String] = [
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
    let singlefeatureRankRule:[Int:String] = [
        0:"K>Q>J>...2>A",
        1:"A>K>Q>J>...>2",
        2:"红Q>红2>红8>红4>红10>红6>黑4>黑八>黑10>红7>黑6>黑9>",
        3:"红Q>红2>红8>红4>红10>红6>黑4>黑J>黑10>红7>黑6>黑9>黑8>黑7>黑5>大王>小王",
        4:"红Q>红2>红8>红4>红6(=红10=黑4)>红J(=黑10=红7=黑6)>红9(=黑8=黑7=红5=大王=黑桃A=黑桃3=红桃3)",
        5:"黑2>红2>红8>红4>红10>红6>黑4>红1>黑10>红7>黑6>黑9>黑8>黑7>黑5>大王>小王",
        6:"红Q>红2>红8>红4>红6(=红10=黑4)>红J(=黑10=红7=黑6)>红9(=黑8=黑7=红5=大王=黑桃A=黑桃3=红桃3)"
    ]
    let handNum:[Int] = [2,4]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            46: "红3+大王",
            45:"对红J=黑10=红7=黑6",
            44:"红6=红10=黑4",
            43:"大王+黑3=大王+红三=黑A+黑3=黑A+红3",
            42:"对红1",
            41:"王+9",
            40:"同色对子",
            39:"红8+红J",
            38:"红2+7",
            37:"红Q+7",
            36:"红2红9",
            35:"对红9=对红5=对黑8=对黑7",
            34:"红3黑8",
            33:"红5大王",
            32:"红桃3红8",
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
            1: "温州牌九[2601]",
            2: "通用四张-牌九大牌九1[415]*",
            3: "52张小牌九[262]",
            4: "宁波小牌九[263]",
            5: "杭州牌九[264]*",
            6: "安徽牌九[273]*",
            7: "湖南牌九[265]*",
            8: "通用四张-32张牌九[416]",
            9: "山西牌九[268]",
            10: "通用四张-54张大牌九",
            11: "34张小牌九[457]",
            12: "通用四张-32张牌九二[417]",
            13: "温州牌九黑大3[269]*",
            14: "南京牌九[261]*",
            15: "32张牌九[266]",
            16: "山西牌九[269]",
            17: "通用四张-杭州牌九[420]*",
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
    牌数:34每家2张牌。(黑桃A、红桃2、手法红桃5、4个6、4个7、4个8、红桃9、方块2、黑桃3、红桃3、4个4、方块5、
    方块9、4个10、红桃J,方块J,红桃Q、方块Q、大王)
    规则:
    1大小顺序(只区分黑、红，红桃=方块，黑桃=梅花)红Q>红2>红8>红4>红6(=
    切牌9(=黑 8=黑7=红5=大王=黑红10=黑4) >红J(=黑10=红7=黑6)>红
    A=黑 3=红3)
    2)先比对子(黑A+黑3是算一对子)，对子一样大庄赢。大王+黑3=大王+红三
    =黑A+黑3=黑A+红3>红Q>红2>红8>红4>红6(=红10=黑4)>红J(=黑10=红7=黑6)>红9(=黑8=黑7=红5)
    3)不成对子时，红Q+红9最大>红Q+红8=红Q+黑8，接着红2+红8=红2+黑8
    4)接下比点数。(Q=2点，J=1点，黑
    报法 A=6点，大王=6点)，点数相同比较最大牌
    5)最大牌相同时，庄家赢，同时0点一样大
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
扑克张数:32张用牌红对Q，两张红5，两张红9，两张红2，两张红J，对王，4个4/4个6/4个7/4个8/4个10
1)对王最大>对红Q>对红2对红8>对红4>对黑10>对黑6>对黑4>对红6>红J>对红10>对红7>对黑7>对黑8>对红9>对红5
2)杂牌不分黑红，同点一样大，9点最大，0点最小
3)大王=6点,小王3点，J=1点，Q=2点
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
        self.rcNum = [2,3,4,5,6,7,8,9,10]

    }
}


class CNDataset{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        
        let FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int) -> String{
        var errMessage : String = ""
        if(rcNum * 2 > 52)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllSingleFeatureIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = [14,40,3,16,29,42,4,17,5,18,31,44,6,19,32,45,7,20,33,46,8,21,9,22,35,48,10,36,24,50,54,2]
        case 1:
            result = [24,50,17,43,21,47,14,40,23,49,53,54,3,16,29,42,5,18,31,44,6,19,32,45,7,20,33,46,9,22,35,48]
            break
        case 2:
            result = [24,50,54,53,14,40,3,4,5,6,7,8,9,10,16,17,18,19,20,21,22,23,29,30,31,32,33,34,35,36,42,43,44,45,46,47,48,49,2,15,41]
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
    
    static func getMinSingleFeatureNum(rcNum: Int, handNum: Int, communityNum: Int,dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
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
    
    //args
    //0 dealType
    //1 diyDealType
    //2 rcNum
    //3 redspecialfeatureValueRange
    //4 blackspecialfeatureValueRange
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 pointComparision
    //9 samePointComparision
    //10 AValueRange
    //11 pairRank
    //12 singlefeatureRankRule
    //13 handNum


    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let rule = ClassifierSettingArgs.targetSetting[9] as! CNDatasetRule
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let redspecialfeatureValueRange = args[5]
        let blackspecialfeatureValueRange = args[6]
        let KValueRange = args[7]
        let QValueRange = args[8]
        let JValueRange = args[9]
        let pointComparision = args[10]
        let samePointComparision = args[11]
        let AValueRange = args[12]
        let pairRank = args[13]
        let singlefeatureRankRule = args[14]

        
        var maxRank = 0

        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
        var returnRCInfos:[DatasetReturnRCInfo] = []
        if FeatureList.count < self.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([], [])
        }
        
        for _ in 0..<rcNum {
            allPlaySingleFeatures.append(RC())
        }
        
        
        var FeatureList = FeatureList
        // 发牌
        if dealNum == 0{
            for _ in 0..<handNum{
                //正发
                if dealType == 0{
                    for i in 0..<rcNum {
                        allPlaySingleFeatures[i].insertSingleFeature(singlefeature: FeatureList.removeFirst())
                    }
                //反发
                } else if dealType == 1 {
                    for i in 0..<rcNum {
                        allPlaySingleFeatures[i].insertSingleFeature(singlefeature: FeatureList.removeLast())
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
                                allPlaySingleFeatures[i].insertSingleFeature(singlefeature: FeatureList.removeFirst())
                            }
                        }
                    //反发
                    } else if dealType == 1{
                        for i in 0..<rcNum {
                            for _ in 0..<singlefeatureNum{
                                allPlaySingleFeatures[i].insertSingleFeature(singlefeature: FeatureList.removeLast())
                            }
                        }
                    }
                //公牌
                } else if action[1] == true {
                    if dealType == 0{
                        for _ in 0..<singlefeatureNum{
                            community.append(FeatureList.removeFirst())
                        }
                    } else if dealType == 1{
                        for _ in 0..<singlefeatureNum{
                            community.append(FeatureList.removeLast())
                        }
                    }
                    
                //去牌
                } else if action[2] == true {
                    if dealType == 0 {
                        for _ in 0..<singlefeatureNum{
                            FeatureList.removeFirst()
                        }
                    } else if dealType == 1{
                        for _ in 0..<singlefeatureNum{
                            FeatureList.removeLast()
                        }
                    }
                }
            }
        }
        
        let currentHandNum = allPlaySingleFeatures[0].rcSingleFeature.count
        
        if currentHandNum == 2 {
            
            for i in 0..<rcNum {
                (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = CNDatasetHandAnalyst(
                    rankRules: rankRules,
                    suitRules: suitRules
                ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureValueRange: blackspecialfeatureValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange, AValueRange: AValueRange,pointComparision: pointComparision,samePointComparision: samePointComparision, singlefeatureRankRule: singlefeatureRankRule, pairRank: pairRank)
            }
            
        } else if currentHandNum == 4 {
            
            var allHeadRank: [Int] = []
            var allTailRank: [Int] = []
            var allType: [String] = []
            var allPair: [Int] = []
            
            for i in 0..<rcNum {
                let currentHand = allPlaySingleFeatures[i].rcSingleFeature
                
                var combinations : [[SingleFeature]] = []
                for i in 0..<currentHand.count {
                    for j in (i + 1)..<currentHand.count {
                        combinations.append([currentHand[i], currentHand[j]])
                    }
                }
                
                //算最大的两张
                var currentMaxRank: Int = 0
                var currentMaxType: String = ""
                var currentHeadFeature: [SingleFeature] = []
                var currentMaxPair: Int = 0
                for combination in combinations {
                    let (currentRank, currentFeatureType, currentIsPair) = CNDatasetHandAnalyst(
                        rankRules: rankRules,
                        suitRules: suitRules
                    ).evalHand(singlefeatures: combination, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureValueRange: blackspecialfeatureValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange, AValueRange: AValueRange,pointComparision: pointComparision,samePointComparision: samePointComparision, singlefeatureRankRule: singlefeatureRankRule, pairRank: pairRank)
                    
                    if currentMaxRank < currentRank {
                        currentMaxRank = currentRank
                        currentMaxType = currentFeatureType
                        currentHeadFeature = combination
                        currentMaxPair = currentIsPair
                    }
                }
                
                let currentTailFeature = currentHand.filter { $0 != currentHeadFeature[0] && $0 != currentHeadFeature[1] }
                
                print("currentHeadFeature \(currentHeadFeature[0].singlefeatureIndex) \(currentHeadFeature[1].singlefeatureIndex) currentTailFeature \(currentTailFeature[0].singlefeatureIndex) \(currentTailFeature[1].singlefeatureIndex)")
                
                //尾部的牌型
                let (tailRank, tailFeatureType, tailIsPair) = CNDatasetHandAnalyst(
                    rankRules: rankRules,
                    suitRules: suitRules
                ).evalHand(singlefeatures: currentTailFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureValueRange: blackspecialfeatureValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange, AValueRange: AValueRange,pointComparision: pointComparision,samePointComparision: samePointComparision, singlefeatureRankRule: singlefeatureRankRule, pairRank: pairRank)
                
                allHeadRank.append(currentMaxRank)
                allTailRank.append(tailRank)
                allType.append(currentMaxType)
                allPair.append(currentMaxPair)
            }
            
            //重新组合出新的rank
            let newHeadRank = GetNewRankArray(allRankSet: allHeadRank)
            let newTailRank = GetNewRankArray(allRankSet: allTailRank)
            
            for i in 0..<rcNum{
                allPlaySingleFeatures[i].evaluateFlag = newHeadRank[i]<<6 | newTailRank[i]
                allPlaySingleFeatures[i].singlefeatureType = allType[i]
                allPlaySingleFeatures[i].isPair = allPair[i]
            }
        }
        
        
                
        for rcID in 0..<allPlaySingleFeatures.count {
            var currentReturnRCInfo = DatasetReturnRCInfo()
            currentReturnRCInfo.rcID = rcID
            currentReturnRCInfo.rcRank = allPlaySingleFeatures[rcID].evaluateFlag
            currentReturnRCInfo.rcSingleFeaturesType = allPlaySingleFeatures[rcID].singlefeatureType
            currentReturnRCInfo.isPair = allPlaySingleFeatures[rcID].isPair
            currentReturnRCInfo.RCSingleFeatures = allPlaySingleFeatures[rcID].rcSingleFeature
            currentReturnRCInfo.communitySingleFeature = community
            returnRCInfos.append(currentReturnRCInfo)
        }
        
        //从大到小排序
        returnRCInfos = returnRCInfos.sorted(by: {$0.rcRank > $1.rcRank})
        
        var leftSingleFeatures:[Int] = []
        for singlefeature in FeatureList{
            leftSingleFeatures.append(singlefeature.singlefeatureIndex)
        }
        if leftSingleFeatures.count < CNDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        return (returnRCInfos, leftSingleFeatures)
    }
}

class CNDatasetHandAnalyst{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([CNSingleFeature]) -> (Int,String,Int)] = [:]
    var pointComparision:Int = 0
    var samePointComparision: Int = 0
    var pairRank: Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0:self.eval_isPoint(singlefeatures:),
            1:self.eval_is2Plus8(singlefeatures:),
            2:self.eval_isQPlus8(singlefeatures:),
            3:self.eval_isQPlus9(singlefeatures:),
            4:self.eval_isPair(singlefeatures:),
            5:self.eval_isMixColorPair(singlefeatures: ),
            6:self.eval_isBlackColorPair(singlefeatures: ),
            7:self.eval_isRedColorPair(singlefeatures: ),
            8:self.eval_isRedQPair(singlefeatures: ),
            9:self.eval_isRedTwoPair(singlefeatures: ),
            10:self.eval_BlackAandBlackThree(singlefeatures: ),
            11:self.eval_isRedFivePair(singlefeatures: ),
            12:self.eval_RedspecialfeatureandBlackThree(singlefeatures: ),
            13:self.eval_isBlackFivePair(singlefeatures:),
            14:self.eval_isQPair(singlefeatures: ),
            15:self.eval_isTwoPair(singlefeatures: ),
            16:self.eval_isspecialfeaturePair(singlefeatures: ),
            17:self.eval_isRedEightPair(singlefeatures: ),
            18:self.eval_isRedFourPair(singlefeatures: ),
            19:self.eval_isRedTenPair(singlefeatures: ),
            20:self.eval_isRedSixPair(singlefeatures: ),
            21:self.eval_isBlackFourPair(singlefeatures: ),
            22:self.eval_isBlackJPair(singlefeatures: ),
            23:self.eval_isBlackTenPair(singlefeatures: ),
            24:self.eval_isRedSevenPair(singlefeatures: ),
            25:self.eval_isBlackSixPair(singlefeatures: ),
            26:self.eval_isBlackNinePair(singlefeatures: ),
            27:self.eval_isBlackEightPair(singlefeatures: ),
            28:self.eval_isBlackSevenPair(singlefeatures: ),
            29:self.eval_isBlackTenSixFourPair(singlefeatures: ),
            30:self.eval_isRedJTenSevenSixPair(singlefeatures: ),
            31:self.eval_isBlackNineEightSevenFivePair(singlefeatures: ),
            32:self.eval_HeartThreeRedEight(singlefeatures: ),
            33:self.eval_RedFiveRedspecialfeature(singlefeatures: ),
            34:self.eval_RedThreeBlackEight(singlefeatures: ),
            35:self.eval_isRedNineFiveBlackEightSevenPair(singlefeatures: ),
            36:self.eval_RedTwoRedNine(singlefeatures: ),
            37:self.eval_RedQRedSeven(singlefeatures: ),
            38:self.eval_RedTwoRedSeven(singlefeatures: ),
            39:self.eval_RedEightRedJ(singlefeatures: ),
            40:self.eval_isSameColorPair(singlefeatures:),
            41:self.eval_isspecialfeaturePlusNine(singlefeatures:),
            42:self.eval_isRedAPair(singlefeatures:),
            43: self.eval_isRedJoJoOrBlackAThree,
            44: self.eval_isRedSixTenBlackFourPair,
            45: self.eval_isRedJSevenBlackTenSixPair,
            46: self.eval_RedThreeRedJoJo(singlefeatures:),
        ]
    }
    
    func evalHand(singlefeatures: [SingleFeature],redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, AValueRange: Int, pointComparision: Int, samePointComparision: Int, singlefeatureRankRule: Int, pairRank: Int)->(Int, String, Int){
        var singlefeatures = singlefeatures
        self.pointComparision = pointComparision
        self.samePointComparision = samePointComparision
        self.pairRank = pairRank
        
        let num1 = CNSingleFeature(singlefeature: singlefeatures[0], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, AValueRange: AValueRange, suitRules: self.suitRules, singlefeatureRankRule: singlefeatureRankRule)
        
        let num2 = CNSingleFeature(singlefeature: singlefeatures[1], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, AValueRange: AValueRange, suitRules: self.suitRules, singlefeatureRankRule: singlefeatureRankRule)
        
        var numList = [num1, num2]
        numList = numList.sorted(by: {$0.originalRank > $1.originalRank})
        
        
        var score = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rank, singlefeatureType, isPair) = self.ruleDict[ruleIndex]!(numList)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 10)) | rank
                return (score, singlefeatureType, isPair)
            }
        }
        
        return (score, "", 0)
    }
    
    func eval_RedThreeRedJoJo(singlefeatures:[CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == 15 && singlefeatures[1].originalRank == 3 && singlefeatures[1].color == 1 {
            return(0,"红三大王", 0)
        }
        return (0, "", 0)
    }
    //规则函数，返回(rank, singlefeatureType, isPair)
    func eval_BlackThreeRedJoJo(singlefeatures:[CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == 15 && singlefeatures[1].originalRank == 3 && singlefeatures[1].color == 0 {
            return(0,"黑三大王", 0)
        }
        return (0, "", 0)
    }
//    "对红J=黑10=红7=黑6"
    func eval_isRedJSevenBlackTenSixPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank {
            if singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 6 {
                return (1,"黑对6",1)
            }
            if singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 10 {
                return (1, "黑对10", 1)
            }
            if singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 11 {
                return (1, "红对J", 1)
            }
            if singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 7 {
                return (1, "红对7", 1)
            }
        }
        
        return (0,"", 0)
    }
    
    func eval_isRedSixTenBlackFourPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank {
            if singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 6 {
                return (1,"红对6",1)
            }
            if singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 10 {
                return (1, "红对10", 1)
            }
            if singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 4 {
                return (1, "黑对4", 1)
            }
        }
        return (0, "", 0)
    }
    
//    43:"大王+黑3=大王+红三=黑A+黑3=黑A+红3",
    func eval_isRedJoJoOrBlackAThree(singlefeatures:[CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == 15 && singlefeatures[1].originalRank == 3 {
            return (1, "大王3", 1)
        } else if singlefeatures[0].originalRank == 3 && singlefeatures[1].originalRank == 1 {
            return (1, "黑A3", 1)
        }
        
        return (0, "", 0)
    }
    
    func eval_isRedAPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 1{
            return (1, "对红尖", 1)
        }
        return (0, "", 0)
    }
    
    
    func eval_isspecialfeaturePlusNine(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == 15 && singlefeatures[0].originalRank == 9{
            return (1, "王9", 1)
        }
        return (0, "", 0)
    }
    
    
    func eval_isSameColorPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == singlefeatures[1].color {
            
//            var singlefeatureType: String = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            var singlefeatureType: String = "同色对子"
            
            if self.pairRank == 0{
                return (singlefeatures[0].rank, singlefeatureType, 1)
            } else if self.pairRank == 1{
                return (1, singlefeatureType, 1)
            }
        }
        return (0, "", 0)
    }
    
    
    func eval_RedEightRedJ(singlefeatures: [CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == 8 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 11 && singlefeatures[1].color == 1{
            return (1, "红8红J", 0)
        }
        if singlefeatures[0].originalRank == 11 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 8 && singlefeatures[1].color == 1{
            return (1, "红8红J", 0)
        }
        return (1, "", 0)
    }
    
    func eval_RedTwoRedSeven(singlefeatures: [CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == 2 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 7 && singlefeatures[1].color == 1{
            return (1, "红2红7", 0)
        }
        if singlefeatures[0].originalRank == 7 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 2 && singlefeatures[1].color == 1{
            return (1, "红8红J", 0)
        }
        return (0, "", 0)
    }
    
    func eval_RedQRedSeven(singlefeatures: [CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == 12 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 7 && singlefeatures[1].color == 1{
            return (1, "红Q红7", 0)
        }
        if singlefeatures[0].originalRank == 7 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 12 && singlefeatures[1].color == 1{
            return (1, "红Q红7", 0)
        }
        return (0, "", 0)
    }
    
    func eval_RedTwoRedNine(singlefeatures: [CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == 2 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 9 && singlefeatures[1].color == 1{
            return (1, "红2红9", 0)
        }
        if singlefeatures[0].originalRank == 9 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 2 && singlefeatures[1].color == 1{
            return (1, "红2红9", 0)
        }
        return (0, "", 0)
    }
    
    func eval_isRedNineFiveBlackEightSevenPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && (singlefeatures[0].originalRank == 9 || singlefeatures[0].originalRank == 5){
            
            var singlefeatureType: String = ""
            
            if singlefeatures[0].originalRank == 5{
                singlefeatureType = "对红5"
            } else if singlefeatures[0].originalRank == 9 {
                singlefeatureType = "对红9"
            }
            
            return (1, singlefeatureType, 1)
        }
        
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && (singlefeatures[0].originalRank == 8 || singlefeatures[0].originalRank == 7){
            var singlefeatureType: String = ""
            
            if singlefeatures[0].originalRank == 7{
                singlefeatureType = "对黑7"
            } else if singlefeatures[0].originalRank == 8 {
                singlefeatureType = "对黑8"
            }
            
            return (1, singlefeatureType, 1)
        }
        return (0,"",0)
    }
    
    
    func eval_RedThreeBlackEight(singlefeatures: [CNSingleFeature]) -> (Int,String, Int){
        if singlefeatures[0].originalRank == 3 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 8 && singlefeatures[1].color == 0{
            return (1, "红3黑8", 0)
        }
        if singlefeatures[0].originalRank == 8 && singlefeatures[0].color == 0 && singlefeatures[1].originalRank == 3 && singlefeatures[1].color == 1{
            return (1, "红3黑8", 0)
        }
        return (0, "", 0)
    }
    
    func eval_RedFiveRedspecialfeature(singlefeatures: [CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == 15 && singlefeatures[1].originalRank == 5 && singlefeatures[1].color == 1{
            return (1, "红5大王", 0)
        }
        if singlefeatures[0].originalRank == 5 && singlefeatures[0].color == 1 && singlefeatures[1].originalRank == 15 {
            return (1, "红5大王", 0)
        }
        return (0, "", 0)
    }
    
    func eval_HeartThreeRedEight(singlefeatures: [CNSingleFeature]) -> (Int, String, Int){
        if (singlefeatures[0].originalRank == 8 && singlefeatures[0].color == 1) && (singlefeatures[1].originalRank == 3 && self.suitRules.firstIndex(of: singlefeatures[1].suit) == 1){
            return (1, "红桃3红8", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isBlackNineEightSevenFivePair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && (singlefeatures[0].originalRank == 9 || singlefeatures[0].originalRank == 8 || singlefeatures[0].originalRank == 7 || singlefeatures[0].originalRank == 5){
            
            if singlefeatures[0].originalRank == 9{
                return (1, "对黑9", 1)
            } else if singlefeatures[0].originalRank == 8 {
                return (1, "对黑8", 1)
            } else if singlefeatures[0].originalRank == 7 {
                return (1, "对黑7", 1)
            } else if singlefeatures[0].originalRank == 5 {
                return (1, "对黑5", 1)
            }
        }
        return (0, "", 0)
    }
    
    func eval_isRedJTenSevenSixPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && (singlefeatures[0].originalRank == 11 || singlefeatures[0].originalRank == 10 || singlefeatures[0].originalRank == 7 || singlefeatures[0].originalRank == 6){
            
            if singlefeatures[0].originalRank == 11{
                return (1, "对红J", 1)
            } else if singlefeatures[0].originalRank == 10 {
                return (1, "对红10", 1)
            } else if singlefeatures[0].originalRank == 7 {
                return (1, "对红7", 1)
            } else if singlefeatures[0].originalRank == 6 {
                return (1, "对红6", 1)
            }
            
        }
        return (0, "", 0)
    }
    
    func eval_isBlackTenSixFourPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && (singlefeatures[0].originalRank == 10 || singlefeatures[0].originalRank == 6 || singlefeatures[0].originalRank == 5){
            
            if singlefeatures[0].originalRank == 10{
                return (1, "对黑10", 1)
            } else if singlefeatures[0].originalRank == 6 {
                return (1, "对黑6", 1)
            } else if singlefeatures[0].originalRank == 4 {
                return (1, "对黑4", 1)
            }
        }
        return (0, "", 0)
    }
    
    func eval_isBlackSevenPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 7{
            return (1, "对黑7", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isBlackEightPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 8{
            return (1, "对黑8", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isBlackNinePair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 9{
            return (1, "对黑9", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isBlackSixPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 6{
            return (1, "对黑6", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isRedSevenPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 7{
            return (1, "对红7", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isBlackTenPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 10{
            return (1, "对黑10", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isBlackJPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 11{
            return (1, "对黑J", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isBlackFourPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 4{
            return (1, "对黑4", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isRedSixPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 6{
            return (1, "对红6", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isRedTenPair(singlefeatures:[CNSingleFeature]) -> (Int, String,Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 10{
            return (1, "对红10", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isRedFourPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 4{
            return (1, "对红4", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isRedEightPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 8{
            return (1, "对红8", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isspecialfeaturePair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == 15 && singlefeatures[0].originalRank == 14{
            return (1, "对王", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isTwoPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].originalRank == 2{
            return (1, "对2", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isQPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].originalRank == 12{
            return (1, "对Q", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isBlackFivePair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 && singlefeatures[0].originalRank == 5{
            return (1, "对黑5", 1)
        }
        return (0, "", 0)
    }
    
    func eval_RedspecialfeatureandBlackThree(singlefeatures: [CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == 15 && singlefeatures[0].color == 0 && singlefeatures[1].originalRank == 3 && singlefeatures[1].color == 0{
            return (1, "黑3大王", 0)
        }
        if singlefeatures[0].originalRank == 3 && singlefeatures[0].color == 0 && singlefeatures[1].originalRank == 15 && singlefeatures[1].color == 0{
            return (1, "黑3大王", 0)
        }
        return (0, "", 0)
        
    }
    
    func eval_isRedFivePair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 5{
            return (1, "对红5", 1)
        }
        return (0, "", 0)
    }
    
    func eval_BlackAandBlackThree(singlefeatures: [CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == 1 && singlefeatures[0].color == 0 && singlefeatures[1].originalRank == 3 && singlefeatures[1].color == 0{
            return (1, "黑A黑3", 0)
        }
        if singlefeatures[0].originalRank == 3 && singlefeatures[0].color == 0 && singlefeatures[1].originalRank == 1 && singlefeatures[1].color == 0{
            return (1, "黑A黑3", 0)
        }
        return (0, "", 0)
        
    }
    func eval_isRedTwoPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 2{
            return (1, "对红2", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isRedQPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 && singlefeatures[0].originalRank == 12{
            return (1, "对红Q", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isRedColorPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 1 && singlefeatures[1].color == 1 {
            
//            var singlefeatureType: String = "红对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            var singlefeatureType: String = "红对子"
            
            if self.pairRank == 0{
                return (singlefeatures[0].rank, singlefeatureType, 1)
            } else if self.pairRank == 1{
                return (1, singlefeatureType, 1)
            }
        }
        return (0, "", 0)
    }
    
    func eval_isBlackColorPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color == 0 && singlefeatures[1].color == 0 {
            
//            var singlefeatureType: String = "黑对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            
            var singlefeatureType: String = "黑对子"
            
            if self.pairRank == 0{
                return (singlefeatures[0].rank, singlefeatureType, 1)
            } else if self.pairRank == 1{
                return (1, singlefeatureType, 1)
            }
        }
        return (0, "", 0)
    }
    
    func eval_isMixColorPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].color != singlefeatures[1].color {
            
//            var singlefeatureType: String = "混对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            var singlefeatureType: String = "混对子"
            
            if self.pairRank == 0{
                return (singlefeatures[0].rank, singlefeatureType, 1)
            } else if self.pairRank == 1{
                return (1, singlefeatureType, 1)
            }
        }
        return (0, "", 0)
    }
    
    func eval_isPair(singlefeatures:[CNSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank{
            
//            var singlefeatureType: String = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            var singlefeatureType: String = "对子"
            
            if self.pairRank == 0{
                return (singlefeatures[0].rank, singlefeatureType, 1)
            } else if self.pairRank == 1{
                return (1, singlefeatureType, 1)
            }
        }
        return (0, "", 0)
    }
                                                      
    func eval_isQPlus9(singlefeatures: [CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == 12 && singlefeatures[1].originalRank == 9{
            return (1, "Q加9", 0)
        }
        return (0, "",  0)
    }
    func eval_isQPlus8(singlefeatures: [CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == 12 && singlefeatures[1].originalRank == 8{
            return (1, "Q加8", 0)
        }
        return (0, "",  0)
    }
    func eval_is2Plus8(singlefeatures: [CNSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == 8 && singlefeatures[1].originalRank == 2{
            return (1, "2加8", 0)
        }
        return (0, "",  0)
    }
    func eval_isPoint(singlefeatures:[CNSingleFeature]) -> (Int, String, Int) {
        let point = (singlefeatures[0].point + singlefeatures[1].point) % 10
        
        var singlefeatureType: String = String(point) + "点"
        
        return ((point + 1) << 4 | singlefeatures[0].rank, singlefeatureType, 0)
    }
    
    class CNSingleFeature{
        var rank: Int = 0
        var originalRank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var singlefeatureIndex: Int = 0
        var color: Int = 0
        
        init(singlefeature: SingleFeature, redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, AValueRange: Int, suitRules:[Int], singlefeatureRankRule: Int){
            let rule = ClassifierSettingArgs.targetSetting[9] as! CNDatasetRule
            self.singlefeatureIndex = singlefeature.singlefeatureIndex
            
            //suit Initialization
            self.suit = singlefeature.suit[0]
            //color Initialization
            //black
            if suitRules.firstIndex(of: self.suit)! == 0 || suitRules.firstIndex(of: self.suit)! == 2{
                self.color = 0
            //red
            } else if suitRules.firstIndex(of: self.suit)! == 1 || suitRules.firstIndex(of: self.suit)! == 3{
                self.color = 1
            }
            
            //Rank Initialization
            self.originalRank = singlefeature.rank
            if singlefeatureRankRule == 0{
                self.rank = singlefeature.rank
            } else if singlefeatureRankRule == 1{
                if singlefeature.rank == 1{
                    self.rank = 14
                }
                if singlefeature.rank > 13 {
                    self.rank = singlefeature.rank + 1
                }
            } else if singlefeatureRankRule == 2{
                //红Q
                if self.color == 1 && singlefeature.rank == 12{
                    self.rank = 17
                }
                //红2
                if self.color == 1 && singlefeature.rank == 2{
                    self.rank = 16
                }
                //红8
                if self.color == 1 && singlefeature.rank == 8{
                    self.rank = 15
                }
                //红4
                if self.color == 1 && singlefeature.rank == 4{
                    self.rank = 14
                }
                //红10
                if self.color == 1 && singlefeature.rank == 10{
                    self.rank = 13
                }
                //红6
                if self.color == 1 && singlefeature.rank == 6{
                    self.rank = 12
                }
                //黑4
                if self.color == 0 && singlefeature.rank == 4{
                    self.rank = 11
                }
                //黑8
                if self.color == 0 && singlefeature.rank == 8{
                    self.rank = 10
                }
                //黑10
                if self.color == 0 && singlefeature.rank == 10{
                    self.rank = 9
                }
                //红7
                if self.color == 1 && singlefeature.rank == 7{
                    self.rank = 8
                }
                //黑6
                if self.color == 0 && singlefeature.rank == 6{
                    self.rank = 7
                }
                //黑9
                if self.color == 0 && singlefeature.rank == 9{
                    self.rank = 6
                }
                
            } else if singlefeatureRankRule == 3 {
                //红Q
                if self.color == 1 && singlefeature.rank == 12{
                    self.rank = 17
                }
                //红2
                if self.color == 1 && singlefeature.rank == 2{
                    self.rank = 16
                }
                //红8
                if self.color == 1 && singlefeature.rank == 8{
                    self.rank = 15
                }
                //红4
                if self.color == 1 && singlefeature.rank == 4{
                    self.rank = 14
                }
                //红10
                if self.color == 1 && singlefeature.rank == 10{
                    self.rank = 13
                }
                //红6
                if self.color == 1 && singlefeature.rank == 6{
                    self.rank = 12
                }
                //黑4
                if self.color == 0 && singlefeature.rank == 4{
                    self.rank = 11
                }
                //黑J
                if self.color == 0 && singlefeature.rank == 11{
                    self.rank = 10
                }
                //黑10
                if self.color == 0 && singlefeature.rank == 10{
                    self.rank = 9
                }
                //红7
                if self.color == 1 && singlefeature.rank == 7{
                    self.rank = 8
                }
                //黑6
                if self.color == 0 && singlefeature.rank == 6{
                    self.rank = 7
                }
                //黑9
                if self.color == 0 && singlefeature.rank == 9{
                    self.rank = 6
                }
                //黑8
                if self.color == 0 && singlefeature.rank == 8{
                    self.rank = 5
                }
                //黑7
                if self.color == 0 && singlefeature.rank == 7{
                    self.rank = 4
                }
                //黑5
                if self.color == 0 && singlefeature.rank == 5{
                    self.rank = 3
                }
                //大王
                if singlefeature.rank == 15{
                    self.rank = 2
                }
                //小王
                if singlefeature.rank == 14{
                    self.rank = 1
                }
            } else if singlefeatureRankRule == 4{
                //红Q
                if self.color == 1 && singlefeature.rank == 12{
                    self.rank = 17
                }
                //红2
                if self.color == 1 && singlefeature.rank == 2{
                    self.rank = 16
                }
                //红8
                if self.color == 1 && singlefeature.rank == 8{
                    self.rank = 15
                }
                //红4
                if self.color == 1 && singlefeature.rank == 4{
                    self.rank = 14
                }
                //红10
                if self.color == 1 && singlefeature.rank == 10{
                    self.rank = 13
                }
                //红6
                if self.color == 1 && singlefeature.rank == 6{
                    self.rank = 13
                }
                //黑4
                if self.color == 0 && singlefeature.rank == 4{
                    self.rank = 13
                }
                //红J
                if self.color == 1 && singlefeature.rank == 11{
                    self.rank = 10
                }
                //黑10
                if self.color == 0 && singlefeature.rank == 10{
                    self.rank = 10
                }
                //红7
                if self.color == 1 && singlefeature.rank == 7{
                    self.rank = 10
                }
                //黑6
                if self.color == 0 && singlefeature.rank == 6{
                    self.rank = 10
                }
                //红9
                if self.color == 1 && singlefeature.rank == 9{
                    self.rank = 6
                }
                //黑8
                if self.color == 0 && singlefeature.rank == 8{
                    self.rank = 6
                }
                //黑7
                if self.color == 0 && singlefeature.rank == 7{
                    self.rank = 6
                }
                //红5
                if self.color == 1 && singlefeature.rank == 5{
                    self.rank = 6
                }
                //大王
                if singlefeature.rank == 15{
                    self.rank = 6
                }
                //黑桃A
                //黑桃3
                //红桃3
                else {
                    self.rank = 6
                }
            } else if singlefeatureRankRule == 5{
                //黑2
                if self.color == 0 && singlefeature.rank == 2{
                    self.rank = 17
                }
                //红2
                if self.color == 1 && singlefeature.rank == 2{
                    self.rank = 16
                }
                //红8
                if self.color == 1 && singlefeature.rank == 8{
                    self.rank = 15
                }
                //红4
                if self.color == 1 && singlefeature.rank == 4{
                    self.rank = 14
                }
                //红10
                if self.color == 1 && singlefeature.rank == 10{
                    self.rank = 13
                }
                //红6
                if self.color == 1 && singlefeature.rank == 6{
                    self.rank = 12
                }
                //黑4
                if self.color == 0 && singlefeature.rank == 4{
                    self.rank = 11
                }
                //红1
                if self.color == 1 && singlefeature.rank == 1{
                    self.rank = 10
                }
                //黑10
                if self.color == 0 && singlefeature.rank == 10{
                    self.rank = 9
                }
                //红7
                if self.color == 1 && singlefeature.rank == 7{
                    self.rank = 8
                }
                //黑6
                if self.color == 0 && singlefeature.rank == 6{
                    self.rank = 7
                }
                //黑9
                if self.color == 0 && singlefeature.rank == 9{
                    self.rank = 6
                }
                //黑8
                if self.color == 0 && singlefeature.rank == 8{
                    self.rank = 5
                }
                //黑7
                if self.color == 0 && singlefeature.rank == 7{
                    self.rank = 4
                }
                //黑5
                if self.color == 0 && singlefeature.rank == 5{
                    self.rank = 3
                }
                //大王
                if singlefeature.rank == 15{
                    self.rank = 2
                }
                //小王
                if singlefeature.rank == 14{
                    self.rank = 1
                }
            }
            
            
            
            //Point Initialization
            if singlefeature.rank == 15 {
                self.point =  Int(rule.redspecialfeatureValueRange[redspecialfeatureValueRange]!)!
            }
            else if singlefeature.rank == 14 {
                self.point = Int(rule.blackspecialfeatureValueRange[blackspecialfeatureValueRange]!)!
            }
            else if singlefeature.rank == 13 {
                self.point = Int(rule.KValueRange[KValueRange]!)!
            }
            else if singlefeature.rank == 12 {
                self.point = Int(rule.QValueRange[QValueRange]!)!
            }
            else if singlefeature.rank == 11 {
                self.point = Int(rule.JValueRange[JValueRange]!)!
            }else if singlefeature.rank == 1{
                self.point = Int(rule.AValueRange[AValueRange]!)!
            } else {
                self.point = singlefeature.rank
            }
        }
    }

}

