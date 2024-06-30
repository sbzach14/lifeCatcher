
import Foundation



class NPStatisticRule : Rule{
    
    let redspecialfeatureValueRange: [Int: String] = [
        0: "1",
    ]
    
    let blackspecialfeatureValueRange: [Int: String] = [
        0:"1",
    ]
    
    let KValueRange: [Int: String] = [
        0:"3",
        1:"1",
        2:"0"
    ]
    
    let QValueRange: [Int: String] = [
        0:"2",
        1:"1",
        2:"0"
    ]
    let JValueRange: [Int: String] = [
        0:"1",
        1:"0",
    ]
    
    let samePointComparision: [Int: String] = [
        0: "同点同对庄赢",
        1: "同点比最大牌",
        2:"同点比花色，两红>一红一黑>两黑"
    ]
    let isCompareSuit: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let handNum: [Int] = [2,4]
    let singlefeatureRankRule:[Int: String] = [
        0:"K>Q>J..>2>A",
        1:"A>K>Q>J..>3>2"
    ]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            0:"点数",
            1:"对子",
            2:"对王",
            3:"对K",
        ]
        self.setting = [
            0:"福建54张9点[221]",
            1:"通用四张-四张9点大[4..]",
            2:"通用四张-54张9点混...",
            3:"52张9点[226]",
            4:"9点昆[222]",
            5:"东兴九点[223]",
            6:"潍坊9点[224]",
            7:"9点对K大[225]",
            8:"52张9点最大[252]",
            9:"54张9点[228]",
            10:"通用四张9点[229]"
        ]
        self.ruleInfo = [
            0:"""
扑克张数 54张 不分花色
1）对王最大>对A>对K>...>对2
2）9点>8点>...>0点
3）王算1点K算3点Q算2点J算1点，同点同对庄家大
""",
            1:"""
扑克张数:52张不分花色
1)10+9=K+8=Q+8=J+8>10+8....>0点最小
2)9点最大0点最小，对子算点数。
3) K/Q/J算1点，同点庄大
4)四张自由组合比两次，两次点数大于其他家才算最大家
""",
            2:"""
扑克牌数:54张
1:对王最大>对A>对K.....>对2
2.9点>8点…...0点最小
3王JkQ为1点
4，最大的牌从大到小王
>A>k>Q>j>10>9>8>7>6>5>4>3>2
""",
            3:"""
用牌52张
对k最大对a最小
9点最大, 0点最小
JQK算1点
""",
            4:"""
扑克张数:52张不分花色
1)10+9=K+9=Q+9=J+9>10+8....>0点
2)9点最大0点最小，对子算点数。
3) K/Q/J算0点，同点庄大
""",
            5:"""
扑克张数:52张不分花色
1)对A最大>对A>对K....>对2
2)>A+8>K+6>Q+7>J+8>..>0点最小
3)K算3点，Q算2点,J算1点。同点比最大张牌，同牌同点庄家大
4)牌从大到小，A>K>Q>J>10>9>8>7>6>5>4>3>2
""",
            6:"""
扑克张数：54 52 不分花色
1）9点最大0点最小，对子算点数
2）J/Q/K 王算1点，同点庄大
""",
            7:"""
对K最大，同点庄大
""",
            8:"""
用牌52张
1: 9点最大，0点最小，对子算点数
2: KQJ算1点，同点庄赢
""",
            9:"""
用牌54张
9点最大，0点最小，对子算点数
J=1，Q=2，K=3 王=0
同点比花色
两红>一红一黑>两黑
""",
            10:"""
扑克张数:54 52张不分花色
1)9点最大0点最小，对子算点数。
3) K/Q/J，王算1点，同点庄大
4)四张自由组合比两次，两次点数大于其他家才算最大家
""",
            
            

        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10]

    }
}


class NPStatistic{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([StatisticReturnRCInfo],[Int]) {
        
        let FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int, handNum: Int) -> String{
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
            result = Array(0...51)
            break
        case 4:
            result = Array(0...51)
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
            result = Array(0...51)
            break
        case 9:
            result = Array(0...51) + [53,54]
        case 10:
            result = Array(0...51) + [53,54]
        default:
            result = Array(0...51) + [53,54]
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
    //3 redspecialfeatureValueRange
    //4 blackspecialfeatureValueRange
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 samePointComparision
    //9 isCompareSuit
    //10 handNum
    //11 singlefeatureRankRule
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([StatisticReturnRCInfo],[Int]) {
        let rule = ClassifierSettingArgs.targetSetting[10] as! NPStatisticRule
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
        let isCompareSuit = args[11]
        let singlefeatureRankRule = args[12]
        
        var maxRank = 0
        var returnRCInfos: [StatisticReturnRCInfo] = []

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
            (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = NPStatisticHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureRange: blackspecialfeatureValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,samePointComparision: samePointComparision,isCompareSuit: isCompareSuit,singlefeatureRankRule: singlefeatureRankRule)
        }
        
        
        for rcID in 0..<allPlaySingleFeatures.count {
            var currentReturnRCInfo = StatisticReturnRCInfo()
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
        if leftSingleFeatures.count < NPStatistic.getMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum,dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        return (returnRCInfos, leftSingleFeatures)
    }
}

class NPStatisticHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([NPSingleFeature]) -> (Int, String, Int)] = [:]
    var samePointComparision: Int = 0
    var singlefeatureRankRule: Int = 0
    

    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0:self.eval_Point(singlefeatures:),
            1:self.eval_isPair(singlefeatures:),
            2:self.eval_isPairspecialfeature(singlefeatures:),
            3:self.eval_isPairK(singlefeatures:)
        ]
    }
    
    func evalHand(singlefeatures: [SingleFeature], redspecialfeatureValueRange: Int, blackspecialfeatureRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, isCompareSuit: Int, singlefeatureRankRule: Int)->(Int, String, Int){
        var singlefeatures = singlefeatures
        singlefeatures.sort(by: {singlefeature1, singlefeature2 in return singlefeature1.rank > singlefeature2.rank})
        self.samePointComparision = samePointComparision
        self.singlefeatureRankRule = singlefeatureRankRule
        let num1 = NPSingleFeature(singlefeature: singlefeatures[0], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange,isCompareSuit: isCompareSuit,singlefeatureRankRule: singlefeatureRankRule)
        
        let num2 = NPSingleFeature(singlefeature: singlefeatures[1], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange,isCompareSuit: isCompareSuit,singlefeatureRankRule: singlefeatureRankRule)
        var nums = [num1,num2]
        nums.sort(by: {num1, num2 in return num1.rank > num2.rank})
        
        var score = 0
        var maxSingleFeatureType: String = ""
        var maxIsPair: Int = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rank, singlefeatureType, isPair) = self.ruleDict[ruleIndex]!(nums)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 9)) | rank
                maxSingleFeatureType = singlefeatureType
                maxIsPair = isPair
                
                break
            }
        }
        
        return (score, maxSingleFeatureType, maxIsPair)
    }
    func eval_isPairK(singlefeatures:[NPSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].rank == 13 && singlefeatures[1].rank == 13{
            return (1, "对K", 1)
        }
        return (0, "", 0)
    }
    func eval_isPairspecialfeature(singlefeatures:[NPSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].originalRank > 13 && singlefeatures[1].originalRank > 13 {
            return (1, "对王", 1)
        }
        return (0, "", 0)
    }
    
    func eval_isPair(singlefeatures: [NPSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].rank == singlefeatures[1].rank{
            let singlefeatureType: String = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            return (singlefeatures[0].rank, singlefeatureType, 1)
        }
        return (0, "", 0)
    }
    
    func eval_Point(singlefeatures: [NPSingleFeature]) -> (Int, String, Int){
        let num1 = singlefeatures[0].point
        let num2 = singlefeatures[1].point
        let point = (num1 + num2) % 10
        let singlefeatureType: String = String((num1 + num2) % 10) + "点"
        
        if self.samePointComparision == 0{
            return (point + 1, singlefeatureType, 0)
        } else if self.samePointComparision == 1{
            return ((point + 1) << 4 | singlefeatures[0].rank, singlefeatureType, 0)
        } else if self.samePointComparision == 2{
            return ((point + 1) << 2 | (self.blackRedJudger(singlefeature: singlefeatures[0]) + self.blackRedJudger(singlefeature: singlefeatures[1])), singlefeatureType, 0)
        }
        
        return (0, singlefeatureType, 0)
    }
    
    func blackRedJudger(singlefeature: NPSingleFeature) -> Int{
        //红
        if self.suitRules.firstIndex(of: singlefeature.suit) == 1 || self.suitRules.firstIndex(of: singlefeature.suit) == 3 {
            return 1
        //黑
        } else{
            return 0
            
        }
    }
    
    
    class NPSingleFeature{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
                    var originalRank: Int = 0
        init(singlefeature: SingleFeature, redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, isCompareSuit: Int, singlefeatureRankRule: Int){
            let rule = ClassifierSettingArgs.targetSetting[10] as! NPStatisticRule
            //Rank Initialization
            self.originalRank = singlefeature.rank
            if singlefeatureRankRule == 0{
                self.rank = singlefeature.rank
            }
            else if singlefeatureRankRule == 1{
                if singlefeature.rank > 13 {
                    self.rank = singlefeature.rank + 1
                }
                if singlefeature.rank == 1{
                    self.rank = 14
                }
            }
            //suit Initialization
            if isCompareSuit == 0{
                self.suit = 0
            } else {
                self.suit = singlefeature.suit[0]
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
            } else {
                self.point = singlefeature.rank
            }
            
        }
    }

}

