
import Foundation


class FCStatisticRule : Rule{
    
    let redspecialfeatureValueRange:[Int:String] = [
        0:"0"
    ]
    let blackspecialfeatureValueRange: [Int: String] = [
        0:"0"
    ]
    let KValueRange:[Int:String] = [
        0:"0",
        1:"13"
    ]
    let QValueRange:[Int:String] = [
        0:"0",
        1:"12"
    ]
    let JValueRange:[Int:String] = [
        0:"0",
        1:"11"
    ]
    let pointComparision:[Int: String] = [
        0:"9点最大，0点最小",
    ]
    let samePointComparision:[Int: String] = [
        0:"同点一样大",
    ]
    let singlefeatureRankRule:[Int: String] = [
        0:"A最大，2最小"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            2: "对子",
            1: "单张",
            0: "四张点数"
        ]
        self.setting = [
            0: "4张比单张[410]",
            1: "4张9点[411]",
        ]
        self.ruleInfo = [
            0:"""
    52张牌，每人4张，分为2组牌
    1.最大 对A > 对K > ... 对2
    2.单张 A最大 2最小
    3.2组牌总点数最大为最大
    """,
            
            1:"""
    扑克张数 54张， 52张
    每人4张牌
    1.4张牌点数相加, 9点最大，0点最小。王 = 0点，J = 0点，Q = 0点，K = 0点
    """,

        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10]

    }
}


class FCStatistic{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([StatisticReturnRCInfo],[Int]) {
        
        var FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
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
            result = Array(0...51)
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
    //10 singlefeatureRankRule


    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([StatisticReturnRCInfo],[Int]) {
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
            (allPlaySingleFeatures[i].evaluateFlag,allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = FCStatisticHandEvaluator(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureValueRange: blackspecialfeatureValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,pointComparision: pointComparision,samePointComparision: samePointComparision,singlefeatureRankRule: singlefeatureRankRule)
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
        if leftSingleFeatures.count < FCStatistic.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        return (returnRCInfos, leftSingleFeatures)
    }
}

class FCStatisticHandEvaluator{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([FCSingleFeature]) -> (Int, String, Int)] = [:]
    var pointComparision:Int = 0
    var samePointComparision: Int = 0
    var singlefeatureRankRule: Int = 0
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0:self.eval_isPoint(singlefeatures:),
            1:self.eval_isHighSingleFeature(singlefeatures:),
            2:self.eval_isPair(singlefeatures:),

        ]
    }
    
    func evalHand(singlefeatures: [SingleFeature],redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, pointComparision: Int, samePointComparision: Int, singlefeatureRankRule: Int)->(Int, String, Int){
        var singlefeatures = singlefeatures
        self.pointComparision = pointComparision
        self.samePointComparision = samePointComparision
        
        let num1 = FCSingleFeature(singlefeature: singlefeatures[0], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, singlefeatureRankRule: singlefeatureRankRule)
        
        let num2 = FCSingleFeature(singlefeature: singlefeatures[1], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange,singlefeatureRankRule: singlefeatureRankRule)
        
        var numList = [num1, num2]
        numList = numList.sorted(by: {$0.rank > $1.rank})
        
        var score = 0
        var maxSingleFeatureType: String = ""
        var maxIsPair: Int = 0
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rank, singlefeatureType, isPair) = self.ruleDict[ruleIndex]!(numList)
            i -= 1
            if rank == 0{
                continue
            } else {
                score = (1 << (i + 5)) | rank
                maxSingleFeatureType = singlefeatureType
                maxIsPair = isPair
                
                break
            }
        }
        
        return (score, maxSingleFeatureType, maxIsPair)
    }
    
    func eval_isPair(singlefeatures:[FCSingleFeature]) -> (Int, String, Int){
        if singlefeatures[0].rank == singlefeatures[1].rank{
            let singlefeatureType: String = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            return (singlefeatures[0].rank, singlefeatureType, 1)
        }
        return (0, "", 0)
    }
    
    func eval_isHighSingleFeature(singlefeatures: [FCSingleFeature]) -> (Int, String, Int) {
        let singlefeatureType: String = "高牌" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
        return (singlefeatures[0].rank, singlefeatureType, 0)
    }
    
    func eval_isPoint(singlefeatures:[FCSingleFeature]) -> (Int, String, Int) {
        let point = singlefeatures.reduce(0){$0 + $1.point} % 10
        let singlefeatureType: String = String(point) + "点"
        return (point + 1, singlefeatureType, 0)
    }
    
    class FCSingleFeature{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var singlefeatureIndex: Int = 0
                var originalRank: Int = 0
        
        init(singlefeature: SingleFeature, redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int, singlefeatureRankRule: Int){
            let rule = ClassifierSettingArgs.targetSetting[11] as! FCStatisticRule
            self.singlefeatureIndex = singlefeature.singlefeatureIndex
            //Rank Initialization
            self.originalRank = singlefeature.rank
            if singlefeatureRankRule == 0 {
                if singlefeature.rank == 1{
                    self.rank = 13
                } else if singlefeature.rank < 14 {
                    self.rank = singlefeature.rank - 1
                } else {
                    self.rank = singlefeature.rank
                }
            } else {
                self.rank = singlefeature.rank
            }
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
                self.point = singlefeature.rank
            }
        }
    }

}

