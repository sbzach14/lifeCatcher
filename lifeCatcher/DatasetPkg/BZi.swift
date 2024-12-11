
import Foundation


//宝子

class BZDatasetRule : Rule{
    
    let KValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"3"
    ]
    let QValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"2",
        3:"0.5"
    ]
    let JValueRange:[Int:String] = [
        0:"0",
        1:"1",
    ]
    let specialfeatureValueRange:[Int:String] = [
        0:"0",
        1:"1",
        2:"5",
        3:"6"
    ]
    let samePointComparision:[Int:String] = [
        0:"同点同对庄家大",
        1:"同点比最大牌",
        2:"同点比最大牌，同牌同点庄家大",
        3:"同点比最大牌，最大牌相同时红红>黑红>黑黑",
        4:"同点比最大牌带花色"
    ]
    let pointComparision :[Int:String] = [
        0:"9点最大，0点最小",
        1:"0点最大，1点最小"
    ]
    
    let singlefeatureRank :[Int: String] = [
        0:"K最大",
        1:"A最大",
        2:"K，Q，J，10一样大, 都为最大"
    ]
    let pairRank :[Int:String] = [
        0:"对子按照牌大小分大小",
        1:"对子不分大小"
    ]
    let AValueRange :[Int:String] = [
        0: "1",
        1: "4"
    ]
    let isCompareSuit :[Int: String] = [
        0: "否",
        1: "是"
    ]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        
        self.setting = [
            0: "宝子2张9点大[201]",
            1: "宝子2张10点大[202]",
            2: "宝子P对大[203]",
            3: "52张宝子[204]",
            4: "52张上海宝子[205]",
            5: "54张宝子12[206]",
            6: "唐山54张宝子[207]",
            7: "40张宝子分花色[208]",
            8: "54张宝子13[209]",
            9: "54张比宝子14[210]",
            10: "52张新疆宝子[211]",
            11: "宝子J",
            12: "宝子Q",
            13: "宝子K",
            14: "江苏52张二八",
            15: "52张宝子对子算点数[216]",
            16: "54张宝子15[213]",
            17: "宝子2张9点大[212]",
            18: "宝子(100017.北海宝子)"
        ]
        self.rankRules = [
                          7:"双公",
                          6:"同色对子",
                          5:"对子",
                          4:"对10",
                          3:"对5",
                          2:"对王",
                          1:"王+A",
                          0:"点数",]
        self.ruleInfo = [
            0:"""
    扑克张数:40张 不分花色
    1) 用1到10的牌
    2) 对10最大>对 9>...>对1
    3) 9点>8点>....0点最小
    4)同点同对庄家大
    """,
            1:"""
    扑克张数:40张 不分花色
    1) 用1到10的牌
    2)对10最大>对9>...>对1
    3)10点>9点>....1点最小
    4)同点同对庄家大
    """,
            2:"""
    扑克张数:40张 不分花色
    1) 用1到9和四个Q的牌
    2) 对Q最大>对9>...>对1
    3) 9+Q>9点>....0点最小
    4)Q算半点，同点同对庄家大
    """,
            3:"""
    扑克张数:52张 不分花色
    1) 对K对Q对J对10一样大>对9>对8>...>对1
    2)K+9/Q+9+J+9+10+9一样大>8+1>7+2...>0点最小
    3)K/Q/J算10点，同点比单张大小，最大的牌从大到小K=Q=J=10>9>8....>1
    """,
            4:"""
    扑克张数:52张 不分花色
    1) 对A最大>对K>对Q>....对2
    2) 9点>8点>....0点
    3) K算3点,Q算2点，J算1点，同点同对庄大
    """,
            5:"""
    扑克张数:54张 不分花色
    1) 对10最大对5次大
    2)10点>9点>8点>....>1点
    3)大小王/J/Q/K算1点，对10最大，对5次大，其他的不算对子。
    """,
            6:"""
    扑克张数:54张 不分花色
    1) 对王最大>对A>对K>....>对2
    2) 王+8>A+8>K+6>Q+7>J+8>..>0点
    3)王算1点，K算3点，Q算2点,J算1点。同点比最大张牌，同牌同点庄家大
    4) 最大的牌从大到小，王
    >A>K>Q>J>10>9>8>7>6>5>4>3>2
    """,
            7:"""
    扑克张数:40张分色
    1) 用1到10的牌
    2>对红 10>对混 10>对黑 10>对红9>...对黑A，两个红的大于1黑1红大于两黑
    3)红10+红9>红10+黑 9=黑10+红9..>黑两张为0点最小
    4) 9点最大，同点时两个红的大于1黑1红大于两黑，同点同色庄大
    """,

            8:"""
    扑克张数:54张 不分花色
    1) 对王最大>王+A>对A>对K....>对2
    2) 王+8>A+8>K+6>Q+7>J+8>..>0点最小
    3) 王+A算对子，王算1点，K算3点， Q算2点,J算1点。同点比最大张牌，同牌同点庄家大
    4) 最大的牌从大到小，王>A>K>Q>J>10>9>8>7>6>5>4>3>2
    """,
            9:"""
    扑克张数:54张 不分花色
    1) 对子不分大小
    2>9点最大，0点最小
    4) 王/K/Q/J算1点，同点同对庄赢
    """,
            10:"""
    扑克张数:52 不分花色
    1) 对K>对Q>...对1
    2) 9点>8点>...0点
    K=3 Q=2 J=1
    3)同点同对庄家大
    """,
            11:"""
    1-10 四个J
    JJ最大...AA最小，J算0点，10点最大...1点最小，同点庄家大。
    """,
            12:"""
    1-10 四个Q
    QQ最大...AA最小，Q算0点。10点最大...1点最小，同点庄家大!
    """,
            13:"""
    1-10 四个K
    KK最大...AA最小，K算0点，10点最大...1点最小，同点庄家大!
    """,
            14:"""
    KK最大...AA最小，K算3点、Q算2点、 J算1点，九点最大，0点最小，同点比单张大小!
    """,
            15:"""
            扑克张数 52张不分花色
            1. K Q J 算0点
            2. 9点最大,
            3. 0点最小, 同点庄大
            4. 对子算点数
            """,
            16:"""
            扑克张数：54张，不分花色
            W=5，K=3，Q=2，J=1，A=4
            1）对子 WW > AA > KK > QQ...22
            2) 9点最大，0点最小，同点比最大牌不分花色，同点同最大牌庄家大，0点一样大，W>K>Q>J>.....2
            """,
            17:"""
            扑克张数：54张
            1）对王>对k>对Q>...对A，2张牌全黑或者全红才算对子，对黑>对红
            2）9点最大，0点最小，王=6点，K=3点，Q=2点，J=1点。
            3）同点比最大牌点数，点数一样比最大牌花色黑桃>红桃>梅花>方片，K最大A最小
            """,
            18:"""
            玩家牌数: 2
            1. 对子: 对A最大 > 对K >..对2
            2. 双公: K,Q,J是公牌, 公派为0点 （K + Q > Q + J)
            3. 9点最大，0点最小 （双公牌除外），同点比牌大（A + 8 > K + 9>..)
            4. 同牌比最大牌花色(黑>红>梅>方)
            """,
        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]

    }
}


class BZDataset{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        
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
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 1:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 2:
            result = Array(0...8) + Array(13...21) + Array(26...34) + Array(39...47) + [11,24,37,50]
            break
        case 3:
            result = Array(0...51)
            break
        case 4:
            result = Array(0...51)
            break
        case 5:
            result = Array(0...51) + [53,54]
            break
        case 6:
            result = Array(0...51) + [53,54]
            break
        case 7:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 8:
            result = Array(0...51) + [53,54]
            break
        case 9:
            result = Array(0...51) + [53,54]
            break
        case 10:
            result = Array(0...51)
            break
        case 11:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48) + [10,23,36,49]
            break
        case 12:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48) + [11,24,37,50]
            break
        case 13:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48) + [12,25,38,51]
            break
        case 14:
            result = Array(0...51)
            break
        case 15:
            result = Array(0...51)
            break
        case 16:
            result = Array(0...51) + [53,54]
            break
        case 17:
            result = Array(0...51) + [53,54]
            break
        case 18:
            result = Array(0...51)
        default:
            result = Array(0...51) + [53,54]
            break
        }
        return result
    }
    
    static func getMinSingleFeatureNum(rcNum: Int, handNum: Int, communityNum: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
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
    //3 KValueRange
    //4 QValueRange
    //5 JValueRange
    //6 specialfeatureValueRange
    //7 samePointComparision
    //8 pointComparision
    //9 singlefeatureRank
    //10 pairRank
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let KValueRange = args[5]
        let QValueRange = args[6]
        let JValueRange = args[7]
        let specialfeatureValueRange = args[8]
        let samePointComparision = args[9]
        let pointComparision = args[10]
        let singlefeatureRank = args[11]
        let pairRank = args[12]
        let AValueRange = args[13]
        let isCompareSuit = args[14]
        
        var maxRank = 0
        var returnRCInfos: [DatasetReturnRCInfo] = []

        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
        if FeatureList.count < self.getMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum, dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
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
        

        
        
        for i in 0..<rcNum {
            (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = BZDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,specialfeatureValueRange: specialfeatureValueRange,samePointComparision: samePointComparision,pointComparision: pointComparision,singlefeatureRank: singlefeatureRank,pairRank: pairRank, AValueRange: AValueRange, isCompareSuit: isCompareSuit)
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
        if leftSingleFeatures.count < self.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        
        return (returnRCInfos, leftSingleFeatures)
    }
}

class BZDatasetHandAnalyst{
    var rankRules: [Int]
    var suitRules: [Int]
    var rankRulesDic: [Int: ([BZSingleFeature]) -> (Int, String, Int)] = [:]
    var samePointComparision: Int = 0
    var pointComparision: Int = 0
    var QValueRange: Int = 0
    var PairRank :Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [
            0:eval_Points(singlefeatures:),
            1:eval_isspecialfeaturePlusA(singlefeatures:),
            2:eval_isPairspecialfeature(singlefeatures:),
            3:eval_isPairFive(singlefeatures:),
            4:eval_isPairTen(singlefeatures:),
            5:eval_isPair(singlefeatures:),
            6:eval_isSameColorPair(singlefeatures:),
            7:eval_twoHeads(singlefeatures:)
        ]
        
    }
    
    func evalHand(singlefeatures: [SingleFeature], KValueRange: Int, QValueRange: Int, JValueRange: Int, specialfeatureValueRange: Int, samePointComparision: Int, pointComparision: Int, singlefeatureRank: Int, pairRank: Int, AValueRange: Int, isCompareSuit: Int)->(Int, String, Int){
        
        self.samePointComparision = samePointComparision
        self.pointComparision = pointComparision
        self.QValueRange = QValueRange
        self.PairRank = pairRank
        var score = 0
        let num1 = BZSingleFeature(singlefeature: singlefeatures[0], KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, specialfeatureValueRange: specialfeatureValueRange, singlefeatureRank: singlefeatureRank, AValueRange: AValueRange, isCompareSuit: isCompareSuit)
        let num2 = BZSingleFeature(singlefeature: singlefeatures[1], KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, specialfeatureValueRange: specialfeatureValueRange, singlefeatureRank: singlefeatureRank, AValueRange: AValueRange, isCompareSuit: isCompareSuit)
        
        let numList = [num1, num2]
//        numList = numList.sorted(by: {$0.originalRank > $1.originalRank})
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (rank, singlefeatureType, isPair) = self.rankRulesDic[ruleIndex]!(numList)
            i -= 1
            if rank == 0 {
                continue
            } else {
                score = (1<<(i + 12)) | rank
                return (score, singlefeatureType, isPair)
            }
        }
        return (score, "", 0)
    }
    
    func eval_twoHeads(singlefeatures:[BZSingleFeature]) -> (Int, String, Int){
        print("计算两公牌")

        if (singlefeatures[0].originalRank > 10 && singlefeatures[0].originalRank < 14) && (singlefeatures[1].originalRank > 10 && singlefeatures[1].originalRank < 14) {
            let maxRank = max(singlefeatures[0].rank, singlefeatures[1].rank)
            return (maxRank, "两公牌", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isSameColorPair(singlefeatures:[BZSingleFeature]) -> (Int, String, Int){
        if self.blackRedJudger(singlefeature: singlefeatures[0]) == self.blackRedJudger(singlefeature: singlefeatures[1]) && singlefeatures[0].originalRank == singlefeatures[1].originalRank {
            var colorRank = 1
            var singlefeatureType: String = "黑对子"
            if self.blackRedJudger(singlefeature: singlefeatures[0]) == 1{
                singlefeatureType = "红对子"
                colorRank = 0
            }
            
            singlefeatureType += String(singlefeatures[0].originalRank)
            return (singlefeatures[0].rank << 2 | colorRank, singlefeatureType, 1)
        }
        
        return (0, "", 0)
    }
    
    func eval_isPair(singlefeatures:[BZSingleFeature]) -> (Int, String, Int){
        print("计算对子")
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank {
            
            let singlefeatureType: String = "对子"
            
            if self.PairRank == 0 {
                if self.samePointComparision == 3{
                    return (singlefeatures[0].rank << 2 | (self.blackRedJudger(singlefeature: singlefeatures[0]) + self.blackRedJudger(singlefeature: singlefeatures[1])), singlefeatureType, 1)
                    
                } else {
                    return (singlefeatures[0].rank, singlefeatureType, 1)
                }
            } else {
                return (1, singlefeatureType, 1)
            }
        }
        return (0,"", 0)
        
    }
    func eval_isPairTen(singlefeatures:[BZSingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].originalRank == 10{
            return (1, "对十", 1)
        }
        return (0, "", 0)
    }
    func eval_isPairFive(singlefeatures:[BZSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank == singlefeatures[1].originalRank && singlefeatures[0].originalRank == 5 {
            return (1, "对五", 1)
        }
        return (0, "", 0)
        
    }
    func eval_isPairspecialfeature(singlefeatures:[BZSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank > 13 && singlefeatures[1].originalRank > 13 {
            return (1, "对王", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isspecialfeaturePlusA(singlefeatures:[BZSingleFeature]) -> (Int, String, Int){
        if max(singlefeatures[0].originalRank, singlefeatures[1].originalRank) > 13 && min(singlefeatures[0].originalRank, singlefeatures[1].originalRank) == 1 {
            return (1, "王加尖", 0)
        }
        return (0, "", 0)
    }
    func eval_Points(singlefeatures:[BZSingleFeature]) -> (Int, String, Int){
        var point = 0
        var mod = 0
        var singlefeatureType = ""
        if self.QValueRange == 3 {
            mod = 20
            point = (singlefeatures[0].point + singlefeatures[1].point) % mod
            singlefeatureType = String(point / 2) + "点"
            if point % 2 == 1{
                singlefeatureType += "半"
            }
        } else {
            mod = 10
            point = (singlefeatures[0].point + singlefeatures[1].point) % mod
            singlefeatureType = String(point) + "点"
        }
        
        if self.pointComparision == 1 {
            point = (point + mod - 1) % mod
        }
        
        if self.samePointComparision == 0 {
            return (point + 1, singlefeatureType, 0)
        } else if self.samePointComparision == 1 {
            return (point << 4 | max(singlefeatures[0].rank, singlefeatures[1].rank) + 1, singlefeatureType, 0)
        } else if self.samePointComparision == 2 {
            return (point << 4 | max(singlefeatures[0].rank, singlefeatures[1].rank) + 1, singlefeatureType, 0)
        } else if self.samePointComparision == 3 {
            
            return (point << 6 | max(singlefeatures[0].rank, singlefeatures[1].rank) << 2 | (self.blackRedJudger(singlefeature: singlefeatures[0]) + self.blackRedJudger(singlefeature: singlefeatures[1])), singlefeatureType, 0)
        } else if self.samePointComparision == 4 {
            var maxFeature: BZSingleFeature
            if singlefeatures[0].rank > singlefeatures[1].rank {
                maxFeature = singlefeatures[0]
            } else {
                maxFeature = singlefeatures[1]
            }
            return (point << 6 | maxFeature.rank << 2 | maxFeature.suit, singlefeatureType, 0)
        }
        return (0, "", 0)
    }
    
    func blackRedJudger(singlefeature: BZSingleFeature) -> Int{
        //红
        if self.suitRules.firstIndex(of: singlefeature.suit) == 1 || self.suitRules.firstIndex(of: singlefeature.suit) == 3 {
            return 1
        //黑
        } else{
            return 0
            
        }
    }
    
}

class BZSingleFeature{
    var originalRank:Int
    var rank:Int
    var point:Int
    var suit:Int
    
    init(singlefeature: SingleFeature, KValueRange:Int, QValueRange: Int, JValueRange: Int, specialfeatureValueRange: Int, singlefeatureRank:Int, AValueRange: Int, isCompareSuit: Int){
        //rank initialization
        let rule = ClassifierSettingArgs.targetSetting[7] as! BZDatasetRule
        if singlefeature.rank > 13{
            self.rank = singlefeature.rank + 1
        }
        else if singlefeature.rank == 1 && singlefeatureRank == 1{
            self.rank = 14
        }
        else if singlefeature.rank >= 10 && singlefeature.rank <= 13 && singlefeatureRank == 2 {
            self.rank = 10
        } else {
            self.rank = singlefeature.rank
        }
        
        //point initialization
        if singlefeature.rank == 11{
            self.point = Int(rule.JValueRange[JValueRange]!)!
        }
        else if singlefeature.rank == 12{
            if QValueRange < 3{
                self.point = Int(rule.QValueRange[QValueRange]!)!
            } else {
                self.point = 1
            }
        }
        else if singlefeature.rank == 13{
            self.point = Int(rule.KValueRange[KValueRange]!)!
        } else if singlefeature.rank > 13 {
            self.point = Int(rule.specialfeatureValueRange[specialfeatureValueRange]!)!
        } else if singlefeature.rank == 1{
            self.point = Int(rule.AValueRange[AValueRange]!)!
        }
        else{
            self.point = singlefeature.rank
        }
        
        //如果Q算半点大家全部*2
        if QValueRange == 3 && singlefeature.rank != 12 {
            self.point = self.point * 2
        }
        // suit initialization
        if isCompareSuit == 0 {
            self.suit = 1
        } else {
            self.suit = singlefeature.suit[0]
        }
        self.originalRank = singlefeature.rank
    }
}
