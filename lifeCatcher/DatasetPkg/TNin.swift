
import Foundation


//小九

class TNDatasetRule : Rule{
    let handNum :[Int] = [2]
    let redspecialfeatureValueRange:[Int:String] = [
        0: "1",
        1: "6"
    ]
    let blackspecialfeatureValueRange:[Int: String] = [
        0: "1",
        1: "3"
    ]
    let samePointComparision:[Int: String] = [
        0:"同点比最大的牌",
        1:"同点一样大"
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.setting = [
            0: "标准小九",
            1: "湖南小九[255]"
        ]
        
        self.rankRules = [2:"对王，对A，A加王",
                          1:"对子",
                          0:"点数"]
        
        self.rcNum = [2,3,4,5,6,7,8]

        self.ruleInfo = [
            0:"""
    一人发两张牌，一共四十张牌1-10
    对子最大，如果不是对子比较两张牌加起来除以十的余数，如果一样则一样大
    """, 1:"""
扑克张数:54张 不分花色
1) 对王=对A=A+王一样大>对K>.....>对2
2)9点>8点....0点最小
3)王为1点，K为3点,Q为2点，J为1点。同点比最大牌。
4) 最大的牌从大到小，王
>A>K>Q>J>10>9>8>7>6>5>4>3>2

""",
        ]
        
        self.rcNum = [2,3,4,5,6,7,8,9,10]
        
    }
}



class TNDataset{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int) -> String{
        var errMessage : String = ""
        if(rcNum * 2 > 40)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllSingleFeatureIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting{
        case 0:
            result = Array(0...9) + Array(13...22) + Array(26...35) + Array(39...48)
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
    //3 handNum
    //4 redspecialfeatureValueRange
    //5 blackspecialfeatureValueRange
    //6 samePointComparision
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {

        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let redspecialfeatureValueRange = args[5]
        let blackspecialfeatureValueRange = args[6]
        let samePointComparision = args[7]
        
        
        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
        var returnRCInfos: [DatasetReturnRCInfo] = []
        if FeatureList.count < TNDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
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
            (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = TNDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureValueRange: blackspecialfeatureValueRange, samePointComparision: samePointComparision)
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
        
        if leftSingleFeatures.count < self.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus) {
            leftSingleFeatures = []
        }
        
        return (returnRCInfos, leftSingleFeatures)
    }
}

class TNDatasetHandAnalyst{
    
    var rankRules: [Int]
    var suitRules: [Int]
    var redspecialfeatureValueRange = 0
    var blackspecialfeatureValueRange = 0
    var samePointComparision = 0
    var rankRulesDic:[Int:([SingleFeature]) -> (Bool, Int, String, Int)] = [:]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [0:self.PointsCalculator,
                             1:self.isPair,
                             2:self.isPairKingPairAKingPlusA
        ]
        
        
    }
    
    func evalHand(singlefeatures: [SingleFeature], redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, samePointComparision: Int)->(Int, String, Int){
        self.redspecialfeatureValueRange = redspecialfeatureValueRange
        self.blackspecialfeatureValueRange = blackspecialfeatureValueRange
        self.samePointComparision = samePointComparision
        var score = 0
        
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (flag, rank, singlefeatureType, isPair) = self.rankRulesDic[ruleIndex]!(singlefeatures)
            i -= 1
            if flag == false{
                continue
            } else {
                score = (1 << (i + 10)) | rank
                return (score, singlefeatureType, isPair)
            }
        }

        return (score, "", 0)
    }
    
    func isPairKingPairAKingPlusA(singlefeatures: [SingleFeature]) -> (Bool, Int, String, Int){
        if singlefeatures[0].rank > 13 && singlefeatures[1].rank > 13 {
            return (true, 1, "对王", 1)
        }
        if singlefeatures[0].rank > 13 && singlefeatures[1].rank == 1 {
            return (true, 1, "王加A", 0)
        }
        if singlefeatures[0].rank == 1 && singlefeatures[1].rank > 13 {
            return (true, 1, "王加A", 0)
        }
        if singlefeatures[0].rank == 1 && singlefeatures[1].rank == 1{
            return (true, 1, "对A", 1)
        }
        
        return (false, 0, "", 0)
        
    }
    
    func isPair(singlefeatures: [SingleFeature]) -> (Bool, Int, String, Int){
        if singlefeatures[0].rank == singlefeatures[1].rank {
            let singlefeatureType: String = "对子"
//            let singlefeatureType: String = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].rank]!
            return (true, singlefeatures[0].rank, singlefeatureType, 1)
        }
        return (false, 0, "", 0)
    }
    
    func PointsCalculator(singlefeatures: [SingleFeature]) -> (Bool, Int, String, Int){
        let num1 = self.SingleFeaturePointConvertor(singlefeature: singlefeatures[0])
        let num2 = self.SingleFeaturePointConvertor(singlefeature: singlefeatures[1])
        let points = (num1 + num2) % 10
        let singlefeatureType: String = String(points) + "点"
        if self.samePointComparision == 0{
            let rank = RankForMaxSingleFeature(singlefeatures: singlefeatures)
            return (true, points << 6 | rank, singlefeatureType, 0)
        } else if self.samePointComparision == 1{
            return (true, points << 6 | 1, singlefeatureType, 0)
        }
        return (false, 0, "", 0)
    }
    
    func RankForMaxSingleFeature(singlefeatures: [SingleFeature]) -> Int{
        var rank = 0
        let rank1 = SingleFeatureRankConvertor(singlefeature: singlefeatures[0]) << 2 | singlefeatures[0].suit[0]
        let rank2 = SingleFeatureRankConvertor(singlefeature: singlefeatures[1]) << 2 | singlefeatures[1].suit[0]
        if rank1 >= rank2 {
            rank = rank1
        } else {
            rank = rank2
        }
        
        return rank
        
    }
    
    func SingleFeatureRankConvertor(singlefeature: SingleFeature) -> Int{
        if singlefeature.rank <= 13 && singlefeature.rank != 1{
            return singlefeature.rank - 1
        }
        if singlefeature.rank == 1{
            return 13
        }
        return singlefeature.rank
    }
    
    
    func SingleFeaturePointConvertor(singlefeature: SingleFeature) -> Int {
        if singlefeature.rank == 14 {
            if self.blackspecialfeatureValueRange == 0{
                return 1
            } else if self.blackspecialfeatureValueRange == 1{
                return 3
            }
        }
        if singlefeature.rank == 15 {
            if self.redspecialfeatureValueRange == 0{
                return 1
            } else if self.redspecialfeatureValueRange == 1{
                return 6
            }
        }
        
        return singlefeature.rank
    }
    
    
    
    
}
