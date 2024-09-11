
import Foundation


//三公

class TMDatasetRule : Rule{
    let pointComparision:[Int: String] = [
        0:"0最大，9次大，1最小",
        1:"9最大，0最小"
    ]
    let samePointComparision:[Int: String] = [
        0:"同点比公数，同公比最大牌，王, K...1",
        1:"同点比最大牌",
        2:"同点比公数，同公比最大牌，王，A，K...2",
        3:"同点一样大",
        4:"同点比公数，同公一样大"
    ]
    //算公数是A是否算公
    let isAAsMan:[Int: String] = [
        0:"否",
        1:"是"
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    let threeSingleFeatureComparision: [Int:String] = [
        0:"KKK>QQQ>JJJ>...222>AAA",
        1:"AAA>KKK>QQQ...333>222",
        2:"333>AAA>KKK>QQQ...>222"
    ]
    let mixManComparision:[Int:String] = [
        0:"混公比最大牌",
        1:"混公一样大"
    ]
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            
            7:"任意三个公，都一样大",
            6:"任意对子+大王或小王+KKK+QQQ+JJJ",
            5:"大小王+任意牌",
            4: "三三",
            3: "三条",
            2: "三公",
            1: "混公",
            0: "散牌"
        ]
        
        self.setting = [
            0: "常规三公[310]",
            1:"三公3-0点大[311]",
            2:"三公2-3同大[312]",
            3:"三公4-3同大无混公[313]",
            4:"三公5-A大于K[314]",
            5:"三公8-单张比花色[315]",
            6:"三公9-3公一样大[316]",
            7:"三公10-333最大[317]",
            8:"三公12-AAA最大[318]",
            9:"三公13-10算公[319]",
            10:"三公7-单张比花色",
            11:"三公11-单张比花色",
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:54张，52张，48张三公
    1)最大: 3个公组合:KKK>QQQ>JJJ>
    2)次大:三个混合公(任意JQK王)同是混公比最大牌
    3)无三公混公比点数(点数是指三张牌点数相加的总点数取个位数的值)，9最大，0最小 (K、Q、J、10为0点)
    4)无三公混公比点数，同点的情况下比公数，例如:双公9点>单公9点
    5)无三公混公比点数，同点同公数的情况下比最大牌。王最大K次大，1最小
    """,
            1:"""
    扑克张数:54张，52张，48张三公
    1) 最大: 3个公组合:KKK>QQQ>JJJ>
    2) 次大:三个混合公(任意JQK王)同是混公比最大牌
    3)无三公混公比点数(点数是指三张牌点数相加的总点数取个位数的值)，0最大，9次大，1最小 (K、Q、J、10为0点)
    4)无三公混公比点数，同点的情况下比公数，例如:双公9点>单公9点
    5)无三公混公比点数，同点同公数的情况下比最大牌。王最大K次大，1最小
    """,
            2:"""
    扑克张数:54张，52张，48张三公
    1) 最大: 三个公组合:
    KKK>QQQ>JJJ>3个10>3个9......>3个1.
    2) 次大:三个混合公(任意JQK王)同是混公比最大牌
    3)无三公混公比点数(点数是指三张牌点数相加的总点数取个位数的值)，9最大，0最小(K、Q、J、10为0点)
    4)无三公混公比点数，同点的情况下比公数，例如:双公9点>单公9点、
    5)无三公混公比点数，同点同公的情况下比最大牌，王最大K次大，1最小
    """,
            3:"""
    扑克张数:54张，52张，48张
    1)最大:3个公组合:KKK>QQQ>JJJ>3个10>3个9...>3个1
    2)无三公比点数(所谓点数是指三张牌点数相加的总点数取个位数的值)，9点最大，0点最小。(王，K，Q，J，10为0点)
    3)无三公同点的情况下比最大牌。王最大 K次大，1最小
    """,
            4:"""
    扑克张数:54张，52张，48张
    1) 最大: 3个公组台:KKK>QQQ >JJJ
    2) 次大:三个混合公(任意JQK王)同是混公比最大牌
    3)无三公混公比点数(点数是指三张牌点数相加的总点数取个位数的值)，9最大，0最小(王,K、Q、J、10为0点)
    4)无三公混公比点数，同点的情况下比公数，例如:双公9点>单公9点。A也算公，但是AKQ又不算混公)
    5)无三公混公比点数，同点同公数的情况下比最大牌。A最大K次大，2最小
    """,
            5:"""
    54张，52张，48张
    1)最大:三个混合公(任意JQK王)同是混公比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,方片>黑桃>红心>梅花3
    2)无混公比点数(所谓点数是指三张牌点数相加的总点数取个位数的值)，0点大，9点次大，1点最小。(王，K，Q， J，10为0点)
    3)无混公比点数，同点情况下比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,方片>黑桃>红心>梅花
    """,
            6:"""
    扑克张数:54张，52张，48张
    1)最大: 大小王+任意一张牌
    2)次大:3个公组合KKK=QQQ=JJJ=任意对子+大王(或小王)
    3)混公KKQ=KQJ=K()王......... ;
    4)无三公混公比点数9点大，0点小。
    """,
            7:"""
    扑克张数:52张
    1)三公3个相同的数字.
    333>AAA>KKK>QQQ>JJJ...>222
    2)混公3个不相同的JQK: JJQ JQK JKK等，同为混公比最大牌K>Q>J
    3)点数WKQJ算0点，其它算自然数9点最大，0点最小，同点双公>单公>无公，同点同公比。最大牌。K>Q>...>A
    """,
            8:"""
    扑克张数:36张
    I) AAA>999。。 >222
    2)点数0点最大,9点次大,1点最小,同点比最大牌.A>9>8...... >2
    3)花色方片>红心>梅花>黑桃
    """,
            9:"""
    52张
    1.最大:3个公(任意JQK10).KKK KQ10一样大
    2.9点最大，0点最小
    3.同点公数多的大
    4.同点同公数，一样大
    """,
            10:"""
    扑克张数:54张，52张，48张
    1) 最大:三个混合公(任意JQK王)同是混公比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,黑桃>红心>梅花>方片
    2) 无混公比点数(所谓点数是指三张牌点数相加的总点数取个位数的值)，0点大，9点次大，1点最小。(王，K，Q， J，10为0点)
    3)无混公比点数，同点情况下比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,黑桃>红心>梅花>方片
    """,
            11:"""
    扑克张数:54张，52张，48张
    1) 最大:三个混合公(任意JQK王)同是混公比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,方片>红心>梅花>黑桃
    2) 无混公比点数(所谓点数是指三张牌点数相加的总点数取个位数的值)，0点大，9点次大，1点最小。(王，K，Q， J，10为0点)
    3) 无混公比点数，同点情况下比最大牌。单张先比大小，同大比花色。大王>小王>K>...>2>A,方片>红心>梅花>黑桃
    """
        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10,11,12,13,14,15]

    }
}


class TMDataset{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        var FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int) -> String{
        var errMessage : String = ""
        if(rcNum * 3 > 52)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllSingleFeatureIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting{
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
            result = Array(0...51)
            break
        case 4:
            result = Array(0...51)
            break
        case 5:
            result = Array(0...51)
            break
        case 6:
            result = Array(0...51)
            break
        case 7:
            result = Array(0...51)
            break
        case 8:
            result = Array(0...8) + Array(13...21) + Array(26...34) + Array(39...47)
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
        default:
            result = Array(0...51)
            break
        }
        
        return result
    }
    
    static func getMinSingleFeatureNum(rcNum: Int,handNum: Int, communityNum: Int,dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
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
    //3 pointComparision
    //4 samePointComparision
    //5 isAAsMan
    //6 isCompareSuit
    //7 threeSingleFeatureComparision
    //8 mixManComparision
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let rule = ClassifierSettingArgs.targetSetting[4] as! TMDatasetRule
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let pointPointComparision = args[5]
        let samePointComparision = args[6]
        let isAAsMan = args[7]
        let isCompareSuit = args[8]
        let threeSingleFeatureComparision = args[9]
        let mixManComparision = args[10]
        
        var maxRank = 0
        var returnRCInfos: [DatasetReturnRCInfo] = []

        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
        if FeatureList.count < TMDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
            return ([],[])
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
            (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = TMDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, pointComparision: pointPointComparision, samePointComparision: samePointComparision, isAAsMan: isAAsMan, isCompareSuit: isCompareSuit, threeSingleFeatureComparision: threeSingleFeatureComparision,mixManComparision: mixManComparision)
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
        
        if leftSingleFeatures.count < TMDataset.getMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum,dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus) {
            leftSingleFeatures = []
        }
        
        return (returnRCInfos, leftSingleFeatures)
    }
}

class TMDatasetHandAnalyst{
    var rankRules: [Int]
    var suitRules: [Int]
    var pointComparision = 0
    var samePointComparision = 0
    var isAAsMan = 0
    var isCompareSuit = 0
    var threeSingleFeatureComparision = 0
    var mixManComparision = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
    }
    
    func evalHand(singlefeatures: [SingleFeature], pointComparision: Int, samePointComparision: Int, isAAsMan: Int, isCompareSuit: Int, threeSingleFeatureComparision: Int, mixManComparision: Int)->(Int, String, Int){
        
        var singlefeatures = singlefeatures
        
        if isCompareSuit == 0{
            for i in 0..<singlefeatures.count{
                singlefeatures[i].suit[0] = 0
            }
        }
        
        singlefeatures.sort(by: { singlefeature1, singlefeature2 in
            return (singlefeature1.rank<<2 | singlefeature1.suit[0]) > (singlefeature2.rank << 2 | singlefeature2.suit[0])
        })
        
    
        
        self.pointComparision = pointComparision
        self.samePointComparision = samePointComparision
        self.isAAsMan = isAAsMan
        self.isCompareSuit = isCompareSuit
        self.threeSingleFeatureComparision = threeSingleFeatureComparision
        self.mixManComparision = mixManComparision
        let (score, singlefeatureType, isPair) = calcHandInfoFlg(sortedSingleFeatures: singlefeatures)
        return (score, singlefeatureType, isPair)
    }
    
    func calcHandInfoFlg(sortedSingleFeatures: [SingleFeature]) -> (Int, String, Int) {
        var rankResult = 0
        var singlefeatureType: String = ""
        var isPair = 0
        var ruleDict: [Int: ([SingleFeature]) -> (Int, String, Int)] = [
            0  : self.eval_holesinglefeature,
            1  : self.eval_mixMan,
            2  : self.eval_threemen,
            3  : self.eval_threesinglefeature,
            4  : self.eval_threethree,
            5  : self.eval_specialfeaturePlusAny,
            6  : self.eval_anyPairPlusspecialfeaturePlusThreeKQJ,
            7  : self.eval_anyThreeMan_allSameRank
        ]
        
        var handSingleFeatureString = ""
        for singlefeature in sortedSingleFeatures{
            handSingleFeatureString += ClassifierSettingArgs.singlefeatureLabelDic[singlefeature.singlefeatureIndex]!
        }
        
        for (index, ruleIndex) in rankRules.enumerated() {
            var rankFlag = 1 << (rankRules.count - index + 12)
            (rankResult, singlefeatureType, isPair) = ruleDict[ruleIndex]!(sortedSingleFeatures)
            
            if rankResult != 0 {
                rankResult |= rankFlag
                break
            }
        }

        return (rankResult, singlefeatureType, isPair)
    }
    func eval_anyThreeMan_allSameRank(singlefeatures: [SingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].rank >= 10 && singlefeatures[1].rank >= 10 && singlefeatures[2].rank >= 10 {
            return (1, "三公", 0)
        }
        
        return (0, "", 0)
    }
    func eval_anyPairPlusspecialfeaturePlusThreeKQJ(singlefeatures: [SingleFeature]) -> (Int, String, Int){
        if (singlefeatures[0].rank == 15 || singlefeatures[0].rank == 14) && singlefeatures[1].rank == singlefeatures[2].rank {
            return (1, "对子加王", 1)
        } else if (singlefeatures[0].rank == singlefeatures[1].rank && singlefeatures[1].rank == singlefeatures[2].rank) && (singlefeatures[0].rank > 10 && singlefeatures[1].rank > 10 && singlefeatures[2].rank > 10){
            var singlefeatureType: String = "三条" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].rank]!
            return (1, singlefeatureType, 0)
        }
        return (0, "", 0)
            
    }
    
    func eval_specialfeaturePlusAny(singlefeatures: [SingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].rank == 15 && singlefeatures[1].rank == 14{
            var singlefeatureType: String = "大小王加" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[2].originalRank]!
            return (1, singlefeatureType, 0)
        }
        return (0, "", 0)
    }
    
    func eval_mixMan(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].rank > 10 && singlefeatures[1].rank > 10 && singlefeatures[2].rank > 10 {
            if self.mixManComparision == 0{
                return (singlefeatures[0].rank << 2 | singlefeatures[0].suit[0], "混公", 0)
            } else if self.mixManComparision == 1{
                return (1, "混公", 0)
            }
        }
        return (0, "", 0)
    }
    
    func eval_threethree(_ singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank = 0
        if singlefeatures[0].rank == 3 && singlefeatures[1].rank == 3 && singlefeatures[2].rank == 3{
            rank = 1
        }
        return (rank, "三三", 0)
    }
    
    func eval_threesinglefeature(_ singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank = 0
        if singlefeatures[0].rank == singlefeatures[1].rank && singlefeatures[0].rank == singlefeatures[2].rank{
            let singlefeatureType: String = "三条" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            if self.threeSingleFeatureComparision == 0 {
                return (singlefeatures[0].rank, singlefeatureType, 0)
            } else if self.threeSingleFeatureComparision == 1 {
                if singlefeatures[0].rank == 1{
                    return (13, singlefeatureType, 0)
                } else {
                    return (singlefeatures[0].rank - 1, singlefeatureType, 0)
                }
            } else if self.threeSingleFeatureComparision == 2 {
                if singlefeatures[0].rank == 3 {
                    return (13, singlefeatureType, 0)
                } else if singlefeatures[0].rank == 1 {
                    return (12, singlefeatureType, 0)
                } else {
                    return (singlefeatures[0].rank - 2, singlefeatureType, 0)
                }
            }
        }
        return (rank, "", 0)
    }
    
    func eval_threemen(_ singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank = 0
        if singlefeatures[0].rank > 10 && singlefeatures[1].rank > 10 && singlefeatures[2].rank > 10 && singlefeatures[1].rank == singlefeatures[0].rank && singlefeatures[1].rank == singlefeatures[2].rank{
            rank = singlefeatures[0].rank << 2 | singlefeatures[0].suit[0]
        }
        return (rank, "三公", 0)
    }
    
    func eval_holesinglefeature(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        
        var sumRank = 0
        for i in 0..<3 {
            sumRank += min(10, singlefeatures[i].rank)
        }
        sumRank = sumRank % 10
        if self.pointComparision == 0{
            sumRank = (sumRank + 10 - 1) % 10
        }
        var rank = 0
        switch self.samePointComparision{
        case 0:
            var menNum = 0
            for singlefeature in singlefeatures{
                if self.isAAsMan == 1 {
                    if singlefeature.rank > 10 || singlefeature.rank == 1{
                        menNum += 1
                    }
                } else {
                    if singlefeature.rank > 10{
                        menNum += 1
                    }
                }
            }
            rank = sumRank << 8 | menNum << 6 | (singlefeatures[0].rank << 2 | singlefeatures[0].suit[0])
            break
        case 1:
            rank = sumRank << 6 | (singlefeatures[0].rank << 2 | singlefeatures[0].suit[0])
            break
        case 2:
            var menNum = 0
            for singlefeature in singlefeatures{
                if self.isAAsMan == 1 {
                    if singlefeature.rank > 10 || singlefeature.rank == 1{
                        menNum += 1
                    }
                } else {
                    if singlefeature.rank > 10{
                        menNum += 1
                    }
                }
            }
            
            let rank1 = rankConvertor(singlefeature: singlefeatures[0], convertorFlag: 0)<<2 | singlefeatures[0].suit[0]
            let rank2 = rankConvertor(singlefeature: singlefeatures[1], convertorFlag: 0)<<2 | singlefeatures[1].suit[0]
            let rank3 = rankConvertor(singlefeature: singlefeatures[2], convertorFlag: 0) | singlefeatures[2].suit[0]
            
            let maxRank = max(rank1, rank2, rank3)
            
            
            rank = sumRank << 8 | menNum << 6 | maxRank
            break
        case 3:
            rank = sumRank
            break
        case 4:
            var menNum = 0
            for singlefeature in singlefeatures{
                if self.isAAsMan == 1 {
                    if singlefeature.rank > 10 || singlefeature.rank == 1{
                        menNum += 1
                    }
                } else {
                    if singlefeature.rank > 10{
                        menNum += 1
                    }
                }
            }
            rank = sumRank << 2 | menNum
            break
        default:
            break
        }
        
        return (rank, String(sumRank) + "点", 0)
    }
    
    //0, A K ... 2
    
    func rankConvertor(singlefeature: SingleFeature, convertorFlag: Int) -> Int{
        switch convertorFlag {
        case 0:
            if singlefeature.rank == 1{
                return 13
            } else if singlefeature.rank < 14 {
                return singlefeature.rank - 1
            }
            break
        default:
            break
        }
        return singlefeature.rank
    }

}

