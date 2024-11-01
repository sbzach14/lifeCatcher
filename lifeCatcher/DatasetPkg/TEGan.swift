import Foundation


class TEGDatasetRule : Rule{
    let samePointComparision:[Int:String] = [
        0:"同点比最大牌",
        1:"同点比最大牌，最大牌相同时红红>黑红>黑黑，同点同色庄大",
        2:"同点比最大花色",
        3:"同点庄家大"
    ]
    
    let isCompareSuit:[Int:String] = [
        0:"否",
        1:"是"
    ]
    
    let KValueRange:[Int:String] = [
        0:"0",
        1:"3"
    ]
    
    let QValueRange:[Int:String] = [
        0:"2",
        1:"0"
    ]
    let JValueRange:[Int:String] = [
        0:"1",
        1:"0"
    ]
    let pointComparision:[Int:String] = [
        0:"9点最大，0点最小",
        1:"10点最大，1点最小"
    ]

        
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            0:"点数",
            1:"2+8",
            2:"对子",
        ]
        self.setting = [
            0: "二八杠对子大[240]",
            1: "二八杠28比对子大[241]",
            2: "二八分黑红[242]",
            3: "二八最大对k次大[243]",
            4: "二八杠10点大",
            5: "江苏52张二八",
            6: "28杠28比对子大[244]",
            7: "28杠28比对子大[245]",
            8: "28杠比花色[246]"
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:40张 1到10
    1) 对10>对 9>对8>....对A
    2）2+8>10+9>8+1>7+2>.....0点
    3)2+8大于9点，同点比最大牌
    4)最大牌从大到小，
    10>9>8>7>6>5>4>3>2>1
    """,
            1:"""
    扑克张数:40张 1到10
    1) 28>对10>对9>对8>....>对A
    2) 10+9>8+1>7+2>.....0点
    3) 2和8最大，同点比最大牌
    4) 最大牌从大到小，10>9>8>7>6>5>4>3>2>1
    """,
            2:"""
    扑克张数:40张分花色
    1) 用1到10的牌
    2>对红 10>对混 10>对黑 10>对红9>...对黑A，两个红的大于1黑1红大于两黑
    3)红2+红8>红2+黑8=黑2+红8>黑2+黑8>红10+红9>红8+红A.....>0点最小
    4)同点时两个红的大于1黑1红大于两黑，同点同色庄大
    """,
            3:"""
    扑克张数:40张 1到9 4个K
    1) 28>对K>对9>对8>....>对A
    2) 9点>8点>7点>.....0点
    3) 2和8最大，K算0点，同点同对庄赢
    """,
            4:"""
    扑克张数:40张 1到10
    1) 对10>对9>对8>....对A
    2)2+8>1+9>3+7>4+6>.....1点(10点最大，1点最小)
    3)同点比最大牌
    4) 最大牌从大到小，
    10>9>8>7>6>5>4>3>2>1
    """,
            5:"""
    KK最大...AA最小，K算3点、Q算2点、 J算1点，28最大，0点最小，同点比单张大小!
    """,
            6:"""
扑克张数:40张1到10
1)28>对10>对9>对8>....>对A
2)10点>9点>8点.....0点
3)同点庄家大
""",
            7:"""
扑克张数:52张1到K
1)28>对K>对Q>对J>对10>....>对A
2)9点>8点>7点>.....0点 JQK都为10点
""",
            8:"""
扑克张数:40张1到10
1)对10>对9>对8>....对A。同是对5，
比最大花色: ♠️>♥️>♣️>♦️
2)2+8，不比花色
3)9点>8点>7点>...>0点。同点比最大
花色: ♠️>♥️>♣️>♦️
""",
        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
    }
    
}


class TEGDataset{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum: [Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        
        let FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int) -> String{
        var errMessage : String = ""
        if(rcNum * 2 > 36)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllSingleFeatureIndex(setting:Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 1:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 2:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 3:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 4:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 5:
            result = Array(0...51)
            break
        case 6:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        case 7:
            result = Array(0...51)
            break
        case 8:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
            break
        default:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
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
    //3 samePointComparision
    //4 isCompareSuit
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 pointComparision
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo], [Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let samePointComparision = args[4]
        let isCompareSuit = args[5]
        let KValueRange = args[6]
        let QValueRange = args[7]
        let JValueRange = args[8]
        let pointComparision = args[9]
        
        
        var returnRCInfos: [DatasetReturnRCInfo] = []

        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
        if FeatureList.count < TEGDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
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
            (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = TEGDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, samePointComparision: samePointComparision, isCompareSuit: isCompareSuit, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, pointComparision: pointComparision)
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
        
        if leftSingleFeatures.count < TEGDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        
        return (returnRCInfos, leftSingleFeatures)
    }
}

class TEGDatasetHandAnalyst{
    var rankRules: [Int]
    var suitRules: [Int]
    var samePointComparision = 0
    var isCompareSuit = 0
    var KValueRange = 0
    var QValueRange = 0
    var JValueRange = 0
    var pointComparision = 0
    var rankRulesDic:[Int: ([SingleFeature]) -> (Int, String, Int)] = [:]
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [
            0:self.eval_Points,
            1:self.eval_is28,
            2:self.eval_isPair
        ]
    }
    
    func evalHand(singlefeatures: [SingleFeature], samePointComparision: Int, isCompareSuit: Int, KValueRange:Int, QValueRange:Int, JValueRange:Int, pointComparision: Int)->(Int, String, Int){
        
        self.samePointComparision = samePointComparision
        self.isCompareSuit = isCompareSuit
        self.KValueRange = KValueRange
        self.QValueRange = QValueRange
        self.JValueRange = JValueRange
        self.pointComparision = pointComparision
        var singlefeatures = singlefeatures
        if isCompareSuit == 0{
            for i in 0..<singlefeatures.count{
                singlefeatures[i].suit[0] = 0
            }
        }
        singlefeatures.sort(by: { singlefeature1, singlefeature2 in
            return SingleFeature.calScore(singlefeature: singlefeature1) > SingleFeature.calScore(singlefeature: singlefeature2)
        })
        var handString = "手牌 "
        for singlefeature in singlefeatures{
            handString += ClassifierSettingArgs.singlefeatureLabelDic[singlefeature.singlefeatureIndex]!
            handString += "花色 \(singlefeature.suit[0])"
        }
        
        var score = 0
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (rank, singlefeatureType, isPair) = self.rankRulesDic[ruleIndex]!(singlefeatures)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 11)) | rank
                return (score, singlefeatureType, isPair)
            }
        }
        
//        let num1 = singlefeatures[0].rank
//        let num2 = singlefeatures[1].rank
//
//        if num1 == num2 {
//            score = num1 + 100
//        } else if (num1 == 2 && num2 == 8) || (num1 == 8 && num2 == 2) {
//            score = 100
//        } else {
//            score = (num1 + num2) % 10
//        }
        
        return (score, "", 0)
    }
    
    func eval_isPair(singlefeatures: [SingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].rank == singlefeatures[1].rank {
            
            let singlefeatureType: String = "对子"
//            let singlefeatureType: String = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            
            if self.samePointComparision == 1{
                return (singlefeatures[0].rank << 2 | (self.blackRedJudger(singlefeature: singlefeatures[0]) + self.blackRedJudger(singlefeature: singlefeatures[1])), singlefeatureType, 1)
            } else if self.samePointComparision == 2 {
                return (singlefeatures[0].rank << 2 | max(singlefeatures[0].suit[0], singlefeatures[1].suit[0]), singlefeatureType, 1)
            } else {
                return (singlefeatures[0].rank, singlefeatureType, 1)
            }
        }
        return (0,"",0)
    }
    
    func eval_is28(singlefeatures:[SingleFeature]) -> (Int, String, Int) {
        if singlefeatures[0].rank == 8 && singlefeatures[1].rank == 2{
            if self.samePointComparision == 1 {
                return (self.blackRedJudger(singlefeature: singlefeatures[0]) + self.blackRedJudger(singlefeature: singlefeatures[1]) + 1, "2 8", 0)
            } else {
                return (1, "2 8", 0)
            }
        }
        return (0, "", 0)
    }
    
    func eval_Points(singlefeatures: [SingleFeature]) -> (Int, String, Int){
        var num1 = self.PointsConvertor(singlefeature: singlefeatures[0])
        var num2 = self.PointsConvertor(singlefeature: singlefeatures[1])
        let singlefeatureType: String = String((num1 + num2) % 10) + "点"
        //0 最大 1 最小
        if self.pointComparision == 1 {
            num1 = (num1 + 10 - 1) % 10
            num2 = (num2 + 10 - 1) % 10
        }
        let rank = (num1 + num2) % 10 + 1
        
        
        if self.samePointComparision == 0 {
            return (rank << 6 | singlefeatures[0].rank << 2 | singlefeatures[0].suit[0], singlefeatureType, 0)
        } else if self.samePointComparision == 1 {
            return (rank << 8 | singlefeatures[0].rank << 4 | singlefeatures[0].suit[0] << 2 | (self.blackRedJudger(singlefeature: singlefeatures[0]) + self.blackRedJudger(singlefeature: singlefeatures[1])), singlefeatureType, 0)
        } else if self.samePointComparision == 2 {
            return (rank << 2 | max(singlefeatures[0].suit[0], singlefeatures[1].suit[0]), singlefeatureType, 0)
        } else {
            return (rank, singlefeatureType, 0)
        }
    }
    
    func blackRedJudger(singlefeature: SingleFeature) -> Int{
        //红
        if self.suitRules.firstIndex(of: singlefeature.suit[0]) == 1 || self.suitRules.firstIndex(of: singlefeature.suit[0]) == 3 {
            return 1
        //黑
        } else{
            return 0
            
        }
    }
    func PointsConvertor(singlefeature: SingleFeature) -> Int{
        let rule = ClassifierSettingArgs.targetSetting[5] as! TEGDatasetRule
        if singlefeature.rank == 13 {
            return Int(rule.KValueRange[self.KValueRange]!)!
        }
        if singlefeature.rank == 12 {
            return Int(rule.QValueRange[self.QValueRange]!)!
        }
        if singlefeature.rank == 11 {
            return Int(rule.JValueRange[self.JValueRange]!)!
        }
        
        return singlefeature.rank
    }
}
