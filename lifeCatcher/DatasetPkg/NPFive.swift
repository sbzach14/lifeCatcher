
import Foundation



class NPFiveDatasetRule : Rule{
    
    let redspecialfeatureValueRange: [Int: String] = [
        0: "1",
        1: "2"
    ]
    
    let blackspecialfeatureValueRange: [Int: String] = [
        0:"1",
        1:"2"
    ]
    
    let KValueRange: [Int: String] = [
        0:"1",
        1:"6"
    ]
    
    let QValueRange: [Int: String] = [
        0:"1",
        1:"4"
    ]
    let JValueRange: [Int: String] = [
        0:"1",
        1:"2"
    ]
    
    let samePointComparision: [Int: String] = [
        0: "同点同对庄赢",
        1: "同点时 两红>一红一黑>两黑",
    ]
    
    let isPairSameRank: [Int: String] = [
        0:"否",
        1:"是"
    ]
    
    let pairRequirement: [Int: String] = [
        0:"无限制",
        1:"同色才是对子，不同色直接算点数"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            7:"黑8 + 大王",
            6:"黑8 + 小王",
            5:"红8 + 大王",
            4:"红8 + 小王",
            3: "王对",
            2: "九点半",
            1: "对子",
            0: "散牌"
        ]
        self.setting = [
            0: "54张九点半[227]",
            1: "54张9点半1[228]",
            2: "江西九点半[229]",
            3: "安徽九点半[230]",
            4: "江西54张九点半[231]",
            5: "九点半最大[232]",
            6: "江西九点半1[233]",
            7: "临沂九点半，对王最大[234]",
            8: "江西九点半2",
            9: "九点半最大2",
            10:"安徽九点半[226]",
            11:"安徽九点半[235]",
            12:"江西九点半[237]",
            13:"54张九点半[238]"
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:54张 不分花色
    1) 9+王=K+9=Q+9=J+9一样大，最大牌
    2)对子一样大，两黑或者两红才算对子，对子一黑一红算点数。
    3) 9点>8+王>8点...0点最小
    4) 王/K/Q/J算半点，同点同对庄赢
    """,
            1:"""
    扑克张数:52张 不分花色
    1)K+9=Q+9=J+9一样大，最大牌
    2>对子一样大，两黑或者两红才算对子，对子一黑一红算点数。
    3) 9点>8+k>8点...0点最小
    4) K/Q/J算半点，同点同对庄赢
    """,
            2:"""
    扑克张数:54张 不分花色
    1) 9+王>对子，对子一样大不分大小。
    2) 9点>8+王>8点...0点最小
    3) 王/K/Q/J算半点，同点同对庄赢
    """,
            3:"""
    扑克张数:54张 不分花色
    1)9+k>对王>对子，对子一样大，两黑或者两红才算对子，对子一黑一红算点数
    2>黑8+小王>黑8+大王>红8+大王>红8+小王>9点>8点半.....0点最小
    3)大王算1点，k算半点，Q算2点，J算一点，同色才为对子，，不同色算数。
    """,
            4:"""
    扑克张数:54张 不分花色
    1) 九点半最大>对子，同色才为对子，不同色算点数。
    2) 9点>8点半>8点>.....0点最小
    3)大小王，JKQ算半点，对子一样大，同点庄家大。
    """,
            5:"""
    扑克张数:52张不分花色
    1) 9点半>9点>8点半>.....>0点最小
    2) K/Q/J算半点，对子算点数，9点半最大。
    """,
            6:"""
    扑克张数:54张不分花色
    1 9+王>对子，对子一样大不分大小。
    2) 9点>8+王>8点...0点最小
    3)王算半点，K为3点，Q为2点。J为1点，同点同对庄赢
    """,
            7:"""
    扑克张数:54 52不分花色
    1) 对王最大0点最小 对王>对K>
    对Q>对J>对10>对9
    2) 王/K/Q/J算半点 10算0点
    """,

            8:"""
    扑克张数: 54张 不分花色
    1 9+王>对子，对子一样大不分大小。
    2) 9点>8+王>8点...0点最小
    3)王算半点，K为3点，Q为2点。J为1点，同点同对庄赢
    """,
            9:"""
    扑克张数:54张 不分花色
    1) 9点半>9点>8点半>...….>0点最小
    2) 王/K/Q/J算半点，对子算点数，9点半最大。
    """,
            10:"""
            扑克张数:54张不分花色
            1)9+k>对子，对子一样大，两黑或者两红才算对子，对子一黑一红算点数
            2)9点>8点半.....0点最小
            3)大王算1点，k算半点，Q算2点，J算一点，同色才为对子,不同色算点数。
            """,
            11:"""
            扑克张数:54张不分花色
            1)9+k>对子，对子一样大，两黑或者两红才算对子，对子一黑一红算点数
            2)9点>8点半.....0点最小
            3)大王算1点，k算半点，Q算2点，J算一点，同色才为对子，不同色算点数。
            """,
            12:"""
            扑克张数:54张分花色
            1) 9+王>对K>对Q>对J>......>对1
            2)9点>8点半>8点>7点半>...0最小同色才算对子同点时两红>一红一黑>两黑
            王=半点K=3 Q=2 J=1
            """,
            13:"""
            扑克张数:54张不分花色,对子算点数
            1)九点半最大
            2)9点>8点半>8点>.....0点最小大小王，JKQ算半点
            """
        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]

    }
}


class NPFiveDataset{
    
    
    
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
            result = Array(0...51) + [53,54]
            break
        case 1:
            result = Array(0...51)
            break
        case 2:
            result = Array(0...51) + [53,54]
            break
        case 3:
            result = Array(0...51) + [53,54]
            break
        case 4:
            result = Array(0...51) + [53,54]
            break
        case 5:
            result = Array(0...51)
            break
        case 6:
            result = Array(0...51) + [53,54]
            break
        case 7:
            result = Array(0...51) + [53,54]
            break
        case 8:
            result = Array(0...51) + [53,54]
            break
        case 9:
            result = Array(0...51) + [53,54]
            break
        case 10:
            result = Array(0...51) + [53,54]
            break
        case 11:
            result = Array(0...51) + [53,54]
            break
        case 12:
            result = Array(0...51) + [53,54]
            break
        case 13:
            result = Array(0...51) + [53,54]
            break
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
    //3 redspecialfeatureValueRange
    //4 blackspecialfeatureValueRange
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 samePointComparision
    //9 isPairSameRank
    //10 pairRequirement
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
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
        let samePointComparision = args[10]
        let isPairSameRank = args[11]
        let pairRequirement = args[12]
        
        var maxRank = 0
        var returnRCInfos: [DatasetReturnRCInfo] = []

        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
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
        
        
        for i in 0..<rcNum {
            (allPlaySingleFeatures[i].evaluateFlag,allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = NPFiveDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureRange: blackspecialfeatureValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,samePointComparision: samePointComparision,isPairSameRank: isPairSameRank,pairRequirement: pairRequirement)
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
        if leftSingleFeatures.count < NPFiveDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        return (returnRCInfos, leftSingleFeatures)
    }
}

class NPFiveDatasetHandAnalyst{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([NPFiveSingleFeature]) -> (Int, String, Int)] = [:]
    var samePointComparision: Int = 0
    var isPairRank: Int = 0
    var pairRequirement: Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0  : self.eval_holesinglefeature,
            1  : self.eval_onepair,
            2  : self.eval_ninepointfive,
            3  : self.eval_kingpair,
            4  : self.eval_red8PlusBlackspecialfeature(singlefeatures:),
            5: self.eval_red8PlusRedspecialfeature(singlefeatures:),
            6: self.eval_black8PlusBlackspecialfeature(singlefeatures:),
            7: self.eval_black8PlusRedspecialfeature(singlefeatures:)
            
        ]
    }
    
    func evalHand(singlefeatures: [SingleFeature], redspecialfeatureValueRange: Int, blackspecialfeatureRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, isPairSameRank: Int, pairRequirement: Int)->(Int, String, Int){
        var singlefeatures = singlefeatures
        singlefeatures.sort(by: {singlefeature1, singlefeature2 in return singlefeature1.rank > singlefeature2.rank})
        self.samePointComparision = samePointComparision
        self.isPairRank = isPairSameRank
        self.pairRequirement = pairRequirement
        
        
        
        let num1 = NPFiveSingleFeature(singlefeature: singlefeatures[0], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        let num2 = NPFiveSingleFeature(singlefeature: singlefeatures[1], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        var score = 0
        var maxSingleFeatureType: String = ""
        var maxIsPair: Int = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rank, singlefeatureType, isPair) = self.ruleDict[ruleIndex]!([num1, num2])
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 8)) | rank
                maxSingleFeatureType = singlefeatureType
                maxIsPair = isPair
                break
            }
        }
        
        return (score, maxSingleFeatureType, maxIsPair)
    }
    
    func eval_black8PlusRedspecialfeature(singlefeatures: [NPFiveSingleFeature]) -> (Int, String, Int) {
        if (singlefeatures[0].rank == 15 && singlefeatures[1].rank == 8 && self.blackRedJudger(singlefeature: singlefeatures[1]) == 1){
            return (1, "黑8大王", 0)
        }
        return (0, "", 0)
    }
    
    func eval_black8PlusBlackspecialfeature(singlefeatures: [NPFiveSingleFeature]) -> (Int, String, Int){
        if (singlefeatures[0].rank == 14 && singlefeatures[1].rank == 8 && self.blackRedJudger(singlefeature: singlefeatures[1]) == 1){
            return (1, "黑8小王", 0)
        }
        return (0, "", 0)
    }
    
    func eval_red8PlusRedspecialfeature(singlefeatures: [NPFiveSingleFeature]) -> (Int, String, Int) {
        if (singlefeatures[0].rank == 15 && singlefeatures[1].rank == 8 && self.blackRedJudger(singlefeature: singlefeatures[1]) == 0){
            return (1, "红8大王", 0)
        }
        return (0, "", 0)
    }
    
    func eval_red8PlusBlackspecialfeature(singlefeatures: [NPFiveSingleFeature]) -> (Int, String, Int){
        if (singlefeatures[0].rank == 14 && singlefeatures[1].rank == 8 && self.blackRedJudger(singlefeature: singlefeatures[1]) == 0){
            return (1, "红8小王", 0)
        }
        return (0, "", 0)
    }
    
    func eval_kingpair(_ singlefeatures: [NPFiveSingleFeature]) -> (Int, String, Int) {
        var rank = 0
        if singlefeatures[0].rank > 13 && singlefeatures[1].rank > 13{
            rank = 1
        }
        return (rank, "王对", 1)
    }
    
    func eval_ninepointfive(_ singlefeatures: [NPFiveSingleFeature]) -> (Int, String, Int) {
        var rank = 0
        if ((singlefeatures[0].point + singlefeatures[1].point) % 20 == 19){
            rank = 1
        }
        return (rank, "九点半", 0)
    }
    
    func eval_onepair(_ singlefeatures: [NPFiveSingleFeature]) -> (Int, String, Int) {
        let rank = 0
        var singlefeatureType: String = ""
        if self.pairRequirement == 0 {
            if singlefeatures[0].rank == singlefeatures[1].rank {
//                singlefeatureType = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].rank]!
                singlefeatureType = "对子"
                if self.isPairRank == 0{
                    return (singlefeatures[0].rank, singlefeatureType, 1)
                } else if self.isPairRank == 1 {
                    return (1, singlefeatureType, 1)
                }
                
            }
        } else if self.pairRequirement == 1 {
            if singlefeatures[0].rank == singlefeatures[1].rank && self.blackRedJudger(singlefeature: singlefeatures[0]) == self.blackRedJudger(singlefeature: singlefeatures[1]){
//                singlefeatureType = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].rank]!
                singlefeatureType = "对子"
                if self.isPairRank == 0 {
                    return (singlefeatures[0].rank, singlefeatureType, 1)
                } else {
                    return (1, singlefeatureType, 1)
                }
            }
        }
        return (rank, "", 0)
    }
    
    func eval_holesinglefeature(singlefeatures: [NPFiveSingleFeature]) -> (Int, String, Int) {
        var rank = 0
        
        rank = singlefeatures[0].point + singlefeatures[1].point
        rank = rank % 20
        var singlefeatureType: String = String(rank / 2) + "点"
        if rank % 2 == 1{
            singlefeatureType += "半"
        }
        if self.samePointComparision == 1{
            //两红
            if self.blackRedJudger(singlefeature: singlefeatures[0]) == self.blackRedJudger(singlefeature: singlefeatures[1]) && self.blackRedJudger(singlefeature: singlefeatures[0]) == 0{
                return ((rank + 1) << 2 | 2, singlefeatureType, 0)
            //混色
            } else if self.blackRedJudger(singlefeature: singlefeatures[0]) != self.blackRedJudger(singlefeature: singlefeatures[1]){
                return ((rank + 1) << 2 | 1, singlefeatureType, 0)
            //两黑
            } else if self.blackRedJudger(singlefeature: singlefeatures[0]) == self.blackRedJudger(singlefeature: singlefeatures[1]) && self.blackRedJudger(singlefeature: singlefeatures[0]) == 1{
                return ((rank + 1) << 2, singlefeatureType, 0)
            }
            
        }
        
        return (rank + 1, singlefeatureType, 0)
    }
    
    func blackRedJudger(singlefeature: NPFiveSingleFeature) -> Int{
        //黑色
        if self.suitRules.firstIndex(of: singlefeature.suit) == 0 || self.suitRules.firstIndex(of: singlefeature.suit) == 2 {
            return 1
        //红色
        } else {
            return 0
        }
    }
    
    class NPFiveSingleFeature{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        
        init(singlefeature: SingleFeature, redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int){
            let rule = ClassifierSettingArgs.targetSetting[6] as! NPFiveDatasetRule
            //Rank Initialization
            self.rank = singlefeature.rank
            //suit Initialization
            self.suit = singlefeature.suit[0]
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
            } else {
                self.point = singlefeature.rank * 2
            }
            
        }
    }

}

