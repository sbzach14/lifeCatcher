
import Foundation


class TPFiveDatasetRule : Rule{
    let handNum :[Int] = [2]
    let redspecialfeatureValueRange:[Int:String] = [
        0: "1",
    ]
    let blackspecialfeatureValueRange:[Int: String] = [
        0: "1",
    ]
    let KValueRange: [Int: String] = [
        0:"1",

    ]
    let QValueRange: [Int: String] = [
        0:"1",
    ]
    let JValueRange: [Int: String] = [
        0:"1",
    ]
    let samePointComparision:[Int: String] = [
        0:"同点庄大",
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    let pointComparision: [Int: String] = [
        0:"10点最大，1点最小"
    ]
    
    let singlefeatureRankRule: [Int: String] = [
        0:"王>K>Q>J,其他一样大"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.setting = [
            0: "十点半[270]",
            1: "十点半[271]"
        ]
        
        self.rankRules = [
            1:"10点半",
            0:"点数"
        ]
        self.ruleInfo = [
            0:"""
    扑克张数:54张
    1) 10+王>10+K>10+Q>10+J>...1点最小
    2)大小王和KQJ都算半点，同点庄家大
    3)同点王>K>Q>J其他同点庄大
    """,
            1:"""
扑克张数:54张
1)10+王>10+K>10+Q>10+J>...1点最小
2)大小王和KQJ都算半点，同点庄家大
3) 同点王>K>Q>J其他同点庄大
""",
     ]
        self.rcNum = [2,3,4,5,6,7,8,9,10]    }
}



class TPFiveDataset{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        var FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
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
            result = Array(0...51) + [53,54]
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
    //3 handNum
    //4 redspecialfeatureValueRange
    //5 blackspecialfeatureValueRange
    //6 KValueRange
    //7 QValueRange
    //8 JValueRange
    //9 samePointComparision
    //10 isCompareSuit
    //11 pointComparision
    //12 singlefeatureRankRule
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let rule  = ClassifierSettingArgs.targetSetting[14] as! TPFiveDatasetRule
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
        let pointComparision = args[12]
        let singlefeatureRankRule = args[13]
        
        
        var maxRank = 0
        var returnRCInfos: [DatasetReturnRCInfo] = []

        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
        if FeatureList.count < TPFiveDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
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
            (allPlaySingleFeatures[i].evaluateFlag,allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = TPFiveDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, samePointComparision: samePointComparision,pointComparision: pointComparision, singlefeatureRankRule: singlefeatureRankRule)
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

class TPFiveDatasetHandAnalyst{
    
    var rankRules: [Int]
    var suitRules: [Int]
    var samePointComparision = 0
    var pointComparision = 0
    var rankRulesDic:[Int:([TPFiveSingleFeature]) -> (Bool, Int, String, Int)] = [:]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [0:self.eval_Points,
                             1:self.eval_TPFive,
        ]
        
        
    }
    
    func evalHand(singlefeatures: [SingleFeature], redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, pointComparision: Int, singlefeatureRankRule: Int)->(Int, String, Int){
        
        self.samePointComparision = samePointComparision
        var score = 0
        var maxSingleFeatureType: String = ""
        var maxIsPair: Int = 0
        
        var num1 = TPFiveSingleFeature(singlefeature: singlefeatures[0], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, singlefeatureRankRule: singlefeatureRankRule)
        var num2 = TPFiveSingleFeature(singlefeature: singlefeatures[1], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, singlefeatureRankRule: singlefeatureRankRule)
        
        var inputSingleFeatures = [num1, num2]
        inputSingleFeatures = inputSingleFeatures.sorted(by: {$0.rank >= $1.rank})
        
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (flag, rank, singlefeatureType, isPair) = self.rankRulesDic[ruleIndex]!(inputSingleFeatures)
            i -= 1
            if flag == false{
                continue
            } else {
                score = (1 << (i + 10)) | rank
                maxSingleFeatureType = singlefeatureType
                maxIsPair = isPair
                return (score, maxSingleFeatureType, maxIsPair)
            }
        }

        return (score, maxSingleFeatureType, maxIsPair)
    }
    
    func eval_TPFive(singlefeatures: [TPFiveSingleFeature]) -> (Bool, Int, String, Int) {
        if singlefeatures[0].point + singlefeatures[1].point == 21 {
            return(true, singlefeatures[0].rank, "10点半", 0)
        }
        return (false, 0, "", 0)
    }
    
    
    func eval_Points(singlefeatures: [TPFiveSingleFeature]) -> (Bool, Int, String, Int){
        if pointComparision == 0{
            var point = (singlefeatures[0].point + singlefeatures[1].point) % 20
            
            if point == 0 {
                point = 20
            }
            
            var singlefeatureType: String = String(point / 2) + "点"
            
            if point % 2 == 1{
                singlefeatureType += "半"
            }
            return (true, point << 4 | singlefeatures[0].rank, singlefeatureType, 0)
        }
        return (false, 0, "", 0)
    }
    
    class TPFiveSingleFeature{
        var rank: Int = 0
        var originalRank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var singlefeatureIndex: Int = 0
        
        init(singlefeature: SingleFeature, redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, singlefeatureRankRule: Int) {
            let rule = ClassifierSettingArgs.targetSetting[14] as! TPFiveDatasetRule
            self.singlefeatureIndex = singlefeature.singlefeatureIndex
            //initial suit
            self.suit = singlefeature.suit[0]
            //initial rank
            self.originalRank = singlefeature.rank
            if singlefeatureRankRule == 0 {
                if singlefeature.rank < 11 {
                    self.rank = 1
                
                } else if singlefeature.rank == 15 {
                    self.rank = 14
                } else {
                    self.rank = singlefeature.rank
                }
            } else {
                self.rank = singlefeature.rank

            }
            
            //initial point
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
            }else {
                self.point = singlefeature.rank * 2
            }
        }
        
    }
    
    
}
