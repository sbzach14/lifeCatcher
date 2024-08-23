
import Foundation


class TCPDatasetRule : Rule{
    let handNum :[Int] = [2]
    let redspecialfeatureValueRange:[Int:String] = [
        0: "20",
        1: "1",
        2: "2",
        3: "0"
    ]
    let blackspecialfeatureValueRange:[Int: String] = [
        0: "20",
        1: "1",
        2: "2",
        3: "0"
    ]
    let KValueRange: [Int: String] = [
        0:"6",
        1:"1",
        2:"2",
        3:"0"
    ]
    let QValueRange: [Int: String] = [
        0:"4",
        1:"1",
        2:"2",
        3:"0"
    ]
    let JValueRange: [Int: String] = [
        0:"2",
        1:"1",
        2:"0"
    ]
    let samePointComparision:[Int: String] = [
        0:"同点庄大",
    ]
    let isCompareSuit: [Int:String] = [
        0:"否",
        1:"是"
    ]
    let pointComparision: [Int: String] = [
        0:"9点最大，0点最小",
        1:"10点最大，1点最小"
    ]
    
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.setting = [
            0: "三张9点[330]",
            1: "三张9点半[331]",
            2: "三张10点半[332]",
            3: "三张9点[333]",
            4: "三张9点[334]",
            5: "三张10点半[335]"
        ]
        
        self.rankRules = [2:"9点半",
                          1:"10点半",
                          0:"点数"]
        self.ruleInfo = [
            0:"""
    扑克张数:54张，52张
    1.3张牌点数相加.9点最大
    2.王=10点、K=3点、Q=2点、J=1点
    """, 1:"""
扑克张数:54张，52张
1.3张牌点数相加.9点半最大,0点最小
2.王JQK=半点，同点庄大
""",
     2:"""
扑克张数:54张，52张
1.3张牌点数相加，10点半最大，0点最小。王JQK=半点
2.同点庄大
""",
            3:"""
扑克张数:54张，52张
1.3张牌点数相加，9点最大。0点最小。王=1点，J=1点，Q=1点，K=1点
""",
            4:"""
扑克张数:54张，52张
1.3张牌点数相加，9点最大。0点最小。王=0点，J=0点，Q=0点，K=0点
""",
            5:"""
扑克张数:54张，52张
1.3张牌点数相加，10点半最大，10点次大， 1点最小。王JQK=半点
2.同点庄大
"""
    
            ]
        self.rcNum = [2,3,4,5,6,7,8,9,10]    }
}



class TCPDataset{
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        var FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int) -> String{
        var errMessage : String = ""
        if(rcNum * 3 > 40)
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
    //6 KValueRange
    //7 QValueRange
    //8 JValueRange
    //9 samePointComparision
    //10 isCompareSuit
    //11 pointComparision
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {

        let rule  = ClassifierSettingArgs.targetSetting[13] as! TCPDatasetRule

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
        
        
        var maxRank = 0
        var returnRCInfos: [DatasetReturnRCInfo] = []

        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
        if FeatureList.count < TCPDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum,dealType: dealType,diyDealNum: diyDealNum,diyDealStatus: diyDealStatus){
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
            (allPlaySingleFeatures[i].evaluateFlag,allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = TCPDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange, samePointComparision: samePointComparision,pointComparision: pointComparision)
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

class TCPDatasetHandAnalyst{
    
    var rankRules: [Int]
    var suitRules: [Int]
    var samePointComparision = 0
    var pointComparision = 0
    var rankRulesDic:[Int:([TCPSingleFeature]) -> (Bool, Int, String, Int)] = [:]
    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.rankRulesDic = [0:self.eval_Points,
                             1:self.eval_TenPointFive,
                             2:self.eval_NinePointFive
        ]
        
        
    }
    
    func evalHand(singlefeatures: [SingleFeature], redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, pointComparision: Int)->(Int, String, Int){
        
        self.samePointComparision = samePointComparision
        var score = 0
        var maxSingleFeatureType: String = ""
        var maxIsPair: Int = 0
        
        var num1 = TCPSingleFeature(singlefeature: singlefeatures[0], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        var num2 = TCPSingleFeature(singlefeature: singlefeatures[1], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        var num3 = TCPSingleFeature(singlefeature: singlefeatures[2], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureValueRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange)
        
        var i = self.rankRules.count + 1
        for ruleIndex in self.rankRules{
            let (flag, rank, singlefeatureType, isPair) = self.rankRulesDic[ruleIndex]!([num1, num2, num3])
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
    
    func eval_NinePointFive(singlefeatures: [TCPSingleFeature]) -> (Bool, Int, String, Int) {
        if (singlefeatures[0].point + singlefeatures[1].point + singlefeatures[2].point) % 20 == 19 {
            return (true, 1, "9点半", 0)
        }
        return (false, 0, "", 0)
    }
    
    func eval_TenPointFive(singlefeatures: [TCPSingleFeature]) -> (Bool, Int, String, Int) {
        if singlefeatures[0].point + singlefeatures[1].point + singlefeatures[2].point == 21 {
            return(true, 1, "10点半", 0)
        }
        return (false, 0, "", 0)
    }
    
    func eval_Points(singlefeatures: [TCPSingleFeature]) -> (Bool, Int, String, Int){
        //9点最大
        var singlefeatureType: String = ""
        let originpoint = singlefeatures[0].point + singlefeatures[1].point + singlefeatures[2].point
        singlefeatureType = String(originpoint % 20 / 2) + "点"
        if originpoint % 2 == 1{
            singlefeatureType += "半"
        }
        if self.pointComparision == 0{
            return(true, (singlefeatures[0].point + singlefeatures[1].point + singlefeatures[2].point) % 20, singlefeatureType, 0)
            
        //10点最大
        } else if pointComparision == 1{
            return (true, (singlefeatures[0].point + singlefeatures[1].point + singlefeatures[2].point - 1) % 20, singlefeatureType, 0)
        }
        return (false, 0, "", 0)
    }
    
    class TCPSingleFeature{
        var rank: Int = 0
        var originalRank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var singlefeatureIndex: Int = 0
        
        init(singlefeature: SingleFeature, redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange:Int, JValueRange:Int) {
            let rule = ClassifierSettingArgs.targetSetting[13] as! TCPDatasetRule
            self.singlefeatureIndex = singlefeature.singlefeatureIndex
            //initial suit
            self.suit = singlefeature.suit[0]
            //initial rank
            self.originalRank = singlefeature.rank
            self.rank = singlefeature.rank
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
