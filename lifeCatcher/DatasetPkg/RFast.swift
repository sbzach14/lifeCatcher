
import Foundation



class RFastDatasetRule : Rule{
    
    let redspecialfeatureValueRange: [Int: String] = [
        0: "1",
    ]
    
    let blackspecialfeatureValueRange: [Int: String] = [
        0:"1",
    ]
    
    let KValueRange: [Int: String] = [
        0:"3",
    ]
    
    let QValueRange: [Int: String] = [
        0:"2",
    ]
    let JValueRange: [Int: String] = [
        0:"1",
    ]
    
    let samePointComparision: [Int: String] = [
        0: "同点同对庄赢",
    ]
    let isCompareSuit: [Int: String] = [
        0: "否",
    ]
    let handNum: [Int] = [12, 16]
    let singlefeatureRankRule:[Int: String] = [
        0:"2>A>K>Q>J..>4>3",
        1:"A>k>Q>10....>2",
    ]
    
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            0:"第一阶梯",
            1:"第二阶梯飞机",
            2:"第二阶梯3条",
            3:"第二阶梯顺子",
            4:"第二阶梯连对",
            5:"第二阶梯对子",
            6:"第三阶梯飞机",
            7:"第三阶梯3条",
            8:"第三阶梯顺子",
            9:"第三阶梯连对",
            10:"第三阶梯对子",
            11:"第四阶梯飞机",
            12:"第四阶梯3条",
            13:"第四阶梯顺子",
            14:"第四阶梯连对",
            15:"第四阶梯对子",
            16:"四条2",
            17:"3个炸弹",
            18:"一条龙",
            19:"全小牌",
            20:"4张顺子",
            21:"对子",
            22:"1703算分",
            23:"1350算分",
            24:"1501算分",
            25:"1604算分",
        ]
        self.setting = [
            0:"48张跑的快[1601]",
            1:"广西跑得快",
            2:"51张跑得快[1703]",
            3:"52张跑的快[1350]",
            4:"45张跑的快[1501]",
            5:"48张跑的快[1604]",
        ]
        self.ruleInfo = [
            0:"""
48张。去掉3个2，1个A，
1.第一阶梯:
1).炸弹，4个K,4个Q,4个J....4个3.
2.第二阶梯:
1)2+A+飞机(AAA+BBB)
2)2+A+ 3条(AAA)
3)2+A+顺(12345，23456不算)
4)2+A+ 连对(4455)
5)2+A+ 对子(大对优先)
3.第三阶梯:
1)2 + 飞机(AAA+BBB)只要JQK
2)2 + 3条(AAA)只要JQK
3)2 + 顺(12345，23456不算)
4)2 + 连对(4455)只要JQK
5)2 + 对子(大对优先)只要JQK
4.第四阶梯:
1).A + 飞机(AAA+BBB)只要JQK
2).A + 3条(AAA)只要JQK
3).A + 顺(12345，23456不算)只要 JQK
4).A + 连对(JJQQ) 只要JQK
5).A + 对子(大对优先) 只要JQK

""",
            1:"""
52张跑得快
用牌52张没有大小王 2最大 3最小
4个人每人13张
炸弹天牌如下
1.四条2
2.13张内3个炸弹
3.一条龙 A-K
4.全小牌（13张全部都是10以下）
5.顺子 1234 最小 jqka最大 四张为顺子，五张不算
6.对子 对2 最大 对3最小


""",
            2:"""
用牌张数： 51张 2-K 都是4张 3张A
游戏规则:
1.A最大, 2最小
2.每人17张, 大牌得分最多者为最大
3.A=2分 K=1.5分 Q=0.6分 其余都是0分
4.如果要飞张直接选择飞张相关报法就可以

""",
            3:"""
52张跑得快用牌:
52张没有大小王2最大3最小
4个人每人13张
如果要飞张直接选择飞张相关报法就可以。 2和A和炸弹最多算最大
""",
            4:"""
张数:45张。去掉3个2，3个A，2个王，1个K
只用于报下家手里的牌 报法710手法，没有大小排序
""",
            5:"""
1.用牌:去掉大小王，去掉4张2, 3算3分、炸弹算2.5分、A算2分、K算1分.
2。总分最高为最大家如果要飞张直接选择飞张相关报法就可以
""",
        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10]

    }
}


class RFastDataset{
    
    
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        
        let FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int, handNum: Int) -> String{
        var errMessage : String = ""
        if(rcNum * 13 > 52)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllSingleFeatureIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(2...13) + Array(15...26) + Array(28...51)
            break
        case 1:
            result = Array(0...51)
            break
        case 2:
            result = Array(1...51)
            break
        case 3:
            result = Array(0...51)
            break
        case 4:
            result = Array(2...11) + Array(15...25) + Array(28...51)
            break
        case 5:
            result = [0] + Array(2...13) + Array(15...26) + Array(28...39) + Array(41...51)
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
    //3 redspecialfeatureValueRange
    //4 blackspecialfeatureValueRange
    //5 KValueRange
    //6 QValueRange
    //7 JValueRange
    //8 samePointComparision
    //9 isCompareSuit
    //10 handNum
    //11 singlefeatureRankRule
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let rule = ClassifierSettingArgs.targetSetting[18] as! RFastDatasetRule
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
            while !FeatureList.isEmpty && FeatureList.count >= rcNum{
                //正发
                if dealType == 0 {
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
            (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = RFastDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, redspecialfeatureValueRange: redspecialfeatureValueRange,blackspecialfeatureRange: blackspecialfeatureValueRange,KValueRange: KValueRange,QValueRange: QValueRange,JValueRange: JValueRange,samePointComparision: samePointComparision,isCompareSuit: isCompareSuit,singlefeatureRankRule: singlefeatureRankRule)
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
        if leftSingleFeatures.count < RFastDataset.getMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum,dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        return (returnRCInfos, leftSingleFeatures)
    }
}

class RFastDatasetHandAnalyst{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([RFastSingelFeature]) -> (Int, String, Int)] = [:]
    var samePointComparision: Int = 0
    var singlefeatureRankRule: Int = 0
    

    
    init(rankRules: [Int],
         suitRules: [Int]){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.ruleDict = [
            0:self.eval_isFourcards(singlefeatures:),
            1:self.eval_isSecondLevelPlane(singlefeatures:),
            2:self.eval_isSecondLevelThreeCard(singlefeatures:),
            3:self.eval_isSecondLevelStraight(singlefeatures:),
            4:self.eval_isSecondLevelConsecutivePairs(singlefeatures:),
            5:self.eval_isSecondLevelPair(singlefeatures:),
            6:self.eval_isThirdLevelPlane(singlefeatures:),
            7:self.eval_isThirdLevelThreeCard(singlefeatures:),
            8:self.eval_isThirdLevelStraight(singlefeatures:),
            9:self.eval_isThirdLevelConsecutivePairs(singlefeatures:),
            10:self.eval_isThirdLevelPair(singlefeatures:),
            11:self.eval_isForthLevelPlane(singlefeatures:),
            12:self.eval_isForthLevelThreeCard(singlefeatures:),
            13:self.eval_isForthLevelStraight(singlefeatures:),
            14:self.eval_isForthLevelConsecutivePairs(singlefeatures:),
            15:self.eval_isForthLevelPair(singlefeatures:),
            16:self.eval_isFourTwo(singlefeatures:),
            17:self.eval_isThreeBoom(singlefeatures:),
            18:self.eval_isDragon(singlefeatures:),
            19:self.eval_isAllSmallCard(singlefeatures:),
            20:self.eval_isFourCardStraight(singlefeatures:),
            21:self.eval_isPair(singlefeatures:),
            22:self.eval_is1703Points(singlefeatures:),
            23:self.eval_is1350Points(singlefeatures:),
            24:self.eval_is1501Points(singlefeatures:),
            25:self.eval_is1604Points(singlefeatures:),
        ]
    }
    
    func evalHand(singlefeatures: [SingleFeature], redspecialfeatureValueRange: Int, blackspecialfeatureRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, samePointComparision: Int, isCompareSuit: Int, singlefeatureRankRule: Int)->(Int, String, Int){
        
        self.samePointComparision = samePointComparision
        self.singlefeatureRankRule = singlefeatureRankRule
        var nums:[RFastSingelFeature] = []

        for i in 0..<singlefeatures.count {
            nums.append(RFastSingelFeature(singlefeature: singlefeatures[i], redspecialfeatureValueRange: redspecialfeatureValueRange, blackspecialfeatureValueRange: blackspecialfeatureRange, KValueRange: KValueRange, QValueRange: QValueRange, JValueRange: JValueRange,isCompareSuit: isCompareSuit,singlefeatureRankRule: singlefeatureRankRule))
        }
        
        nums.sort { $0.rank > $1.rank }

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
                score = (1 << (i + 8)) | rank
                maxSingleFeatureType = singlefeatureType
                maxIsPair = isPair
                
                break
            }
        }
        
        return (score, maxSingleFeatureType, maxIsPair)
    }
    func eval_isFourcards(singlefeatures:[RFastSingelFeature]) -> (Int, String, Int){
        var currentCntFeatureRank: Int = 0
        var currentCnt: Int = 0
        for singlefeature in singlefeatures {
            if singlefeature.rank != currentCntFeatureRank {
                currentCnt = 1
                currentCntFeatureRank = singlefeature.rank
            } else {
                currentCnt += 1
            }
            
            if currentCnt == 4 {
                return (currentCntFeatureRank, "炸弹", 1)
            }
        }
        
        return (0, "", 0)
    }
    
    func eval_isSecondLevelPlane(singlefeatures:[RFastSingelFeature]) -> (Int, String, Int){
        //是否有2
        var hasTwo : Bool = false
        var hasAce : Bool = false
        var hasPlane : Bool = false
        var PlaneRank : Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        let length = singlefeatures.count
        var head: Int = 0
        var tail: Int = 0
        var subArray: [RFastSingelFeature] = []
        for pointerIndex in 0...length - 6 {
            head = pointerIndex
            tail = pointerIndex + 5
            
            subArray = Array(singlefeatures[head...tail])
            
            if (subArray[0].originalRank == subArray[1].originalRank &&
                subArray[0].originalRank == subArray[2].originalRank) &&
                (subArray[3].originalRank == subArray[4].originalRank &&
                 subArray[4].originalRank == subArray[5].originalRank) &&
                (subArray[2].rank == subArray[3].rank + 1) {
                hasPlane = true
                PlaneRank = subArray[0].rank
            }
        }
        
        if hasTwo && hasAce && hasPlane {
            return (PlaneRank, "A2飞机", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isSecondLevelThreeCard(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasTwo : Bool = false
        var hasAce : Bool = false
        var hasThreeCard : Bool = false
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        var currentCntFeatureRank: Int = 0
        var currentCnt: Int = 0
        for singlefeature in singlefeatures {
            if singlefeature.rank != currentCntFeatureRank {
                currentCnt = 1
                currentCntFeatureRank = singlefeature.rank
            } else {
                currentCnt += 1
            }
            
            if currentCnt == 3 {
                hasThreeCard = true
            }
        }
        
        if hasTwo && hasAce && hasThreeCard {
            return (currentCntFeatureRank, "A2三条", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isSecondLevelStraight(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasTwo : Bool = false
        var hasAce : Bool = false
        var hasStraight : Bool = false
        var straightHead : Int = 0
        var lastFeatureRank: Int = 99
        var straightNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 2 || singlefeature.rank == lastFeatureRank{
                continue
            } else if singlefeature.rank == lastFeatureRank - 1{
                lastFeatureRank = singlefeature.rank
                straightNum += 1
            } else if singlefeature.rank < lastFeatureRank - 1 {
                straightHead = singlefeature.rank
                straightNum = 1
                lastFeatureRank = singlefeature.rank

            }
            
            if straightNum == 5 {
                hasStraight = true
                break
            }
        }
        
        if hasTwo && hasAce && hasStraight {
            return (straightHead, "A2顺子", 0)
        }
        
        return (0, "", 0)
    }
    
    
    
    func eval_isSecondLevelConsecutivePairs(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasTwo : Bool = false
        var hasAce : Bool = false
        var hasStraight : Bool = false
        var straightHead : Int = 0
        var lastFeatureRank: Int = 99
        var straightNum: Int = 0
        var pairNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 2 || (singlefeature.rank == lastFeatureRank && pairNum == 2){
                continue
            } else if singlefeature.rank == lastFeatureRank - 1 && pairNum == 2{
                lastFeatureRank = singlefeature.rank
                pairNum = 1
            } else if singlefeature.rank < lastFeatureRank - 1 || (singlefeature.rank == lastFeatureRank - 1 && pairNum == 1){
                straightHead = singlefeature.rank
                straightNum = 1
                pairNum = 1
                lastFeatureRank = singlefeature.rank
            } else if singlefeature.rank == lastFeatureRank && pairNum == 1 {
                pairNum += 1
                straightNum += 1
            }
            
            if straightNum == 3 {
                hasStraight = true
                break
            }
        }
        
        if hasTwo && hasAce && hasStraight {
            return (straightHead, "A2连对", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isSecondLevelPair(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasTwo : Bool = false
        var hasAce : Bool = false
        var hasPair : Bool = false
        var pairFeature: Int = 0
        var pairNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        for singlefeature in singlefeatures {
            if pairFeature == singlefeature.rank {
                pairNum += 1
            } else {
                pairNum = 1
                pairFeature = singlefeature.rank
            }
            
            if pairNum == 2 {
                hasPair = true
                break
            }
        }
        
        if hasAce && hasTwo && hasPair {
            return (pairFeature, "A2对子", 0)
        }
        return (0, "", 0)
    }
    
    func eval_isThirdLevelPlane(singlefeatures:[RFastSingelFeature]) -> (Int, String, Int){
        //是否有2
        var hasTwo : Bool = false
        var hasPlane : Bool = false
        var PlaneRank : Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        
        let length = singlefeatures.count
        var head: Int = 0
        var tail: Int = 0
        var subArray: [RFastSingelFeature] = []
        for pointerIndex in 0...length - 6 {
            head = pointerIndex
            tail = pointerIndex + 5
            
            subArray = Array(singlefeatures[head...tail])
            
            if (subArray[0].originalRank == subArray[1].originalRank &&
                subArray[0].originalRank == subArray[2].originalRank) &&
                (subArray[3].originalRank == subArray[4].originalRank &&
                 subArray[4].originalRank == subArray[5].originalRank) &&
                (subArray[2].rank == subArray[3].rank + 1) {
                hasPlane = true
                PlaneRank = subArray[0].rank
            }
        }
        
        if hasTwo && hasPlane && PlaneRank > 10{
            return (PlaneRank, "2飞机", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isThirdLevelThreeCard(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasTwo : Bool = false
        var hasThreeCard : Bool = false
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        
        var currentCntFeatureRank: Int = 0
        var currentCnt: Int = 0
        for singlefeature in singlefeatures {
            if singlefeature.rank != currentCntFeatureRank {
                currentCnt = 1
                currentCntFeatureRank = singlefeature.rank
            } else {
                currentCnt += 1
            }
            
            if currentCnt == 3 {
                hasThreeCard = true
            }
        }
        
        if hasTwo && hasThreeCard && currentCntFeatureRank > 10{
            return (currentCntFeatureRank, "2三条", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isThirdLevelStraight(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasTwo : Bool = false
        var hasStraight : Bool = false
        var straightHead : Int = 0
        var lastFeatureRank: Int = 99
        var straightNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 2 || singlefeature.rank == lastFeatureRank{
                continue
            } else if singlefeature.rank == lastFeatureRank - 1{
                lastFeatureRank = singlefeature.rank
                straightNum += 1
            } else if singlefeature.rank < lastFeatureRank - 1 {
                straightHead = singlefeature.rank
                straightNum = 1
                lastFeatureRank = singlefeature.rank
            }
            
            if straightNum == 5 {
                hasStraight = true
                break
            }
        }
        
        if hasTwo && hasStraight {
            return (straightHead, "2顺子", 0)
        }
        
        return (0, "", 0)
    }
    
    
    
    func eval_isThirdLevelConsecutivePairs(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasTwo : Bool = false
        var hasStraight : Bool = false
        var straightHead : Int = 0
        var lastFeatureRank: Int = 99
        var straightNum: Int = 0
        var pairNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 2 || (singlefeature.rank == lastFeatureRank && pairNum == 2){
                continue
            } else if singlefeature.rank == lastFeatureRank - 1 && pairNum == 2{
                lastFeatureRank = singlefeature.rank
                pairNum = 1
            } else if singlefeature.rank < lastFeatureRank - 1 || (singlefeature.rank == lastFeatureRank - 1 && pairNum == 1) {
                straightHead = singlefeature.rank
                straightNum = 1
                pairNum = 1
                lastFeatureRank = singlefeature.rank

            } else if singlefeature.rank == lastFeatureRank && pairNum == 1 {
                pairNum += 1
                straightNum += 1
            }
            
            if straightNum == 3 {
                hasStraight = true
                break
            }
        }
        
        if hasTwo && hasStraight && straightHead > 10{
            return (straightHead, "2连对", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isThirdLevelPair(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasTwo : Bool = false
        var hasPair : Bool = false
        var pairFeature: Int = 0
        var pairNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 2 }) {
            hasTwo = true
        }
        
        for singlefeature in singlefeatures {
            if pairFeature == singlefeature.rank {
                pairNum += 1
            } else {
                pairNum = 1
                pairFeature = singlefeature.rank
            }
            
            if pairNum == 2 {
                hasPair = true
                break
            }
        }
        
        if hasTwo && hasPair && pairFeature > 10{
            return (pairFeature, "2对子", 0)
        }
        return (0, "", 0)
    }
    
    func eval_isForthLevelPlane(singlefeatures:[RFastSingelFeature]) -> (Int, String, Int){
        //是否有2
        var hasAce : Bool = false
        var hasPlane : Bool = false
        var PlaneRank : Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        let length = singlefeatures.count
        var head: Int = 0
        var tail: Int = 0
        var subArray: [RFastSingelFeature] = []
        for pointerIndex in 0...length - 6 {
            head = pointerIndex
            tail = pointerIndex + 5
            
            subArray = Array(singlefeatures[head...tail])
            
            if (subArray[0].originalRank == subArray[1].originalRank &&
                subArray[0].originalRank == subArray[2].originalRank) &&
                (subArray[3].originalRank == subArray[4].originalRank &&
                 subArray[4].originalRank == subArray[5].originalRank) &&
                (subArray[2].rank == subArray[3].rank + 1) {
                hasPlane = true
                PlaneRank = subArray[0].rank
            }
        }
        
        if hasAce && hasPlane && PlaneRank > 10{
            return (PlaneRank, "A飞机", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isForthLevelThreeCard(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasAce : Bool = false
        var hasThreeCard : Bool = false

        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        var currentCntFeatureRank: Int = 0
        var currentCnt: Int = 0
        for singlefeature in singlefeatures {
            if singlefeature.rank != currentCntFeatureRank {
                currentCnt = 1
                currentCntFeatureRank = singlefeature.rank
            } else {
                currentCnt += 1
            }
            
            if currentCnt == 3 {
                hasThreeCard = true
            }
        }
        
        if hasAce && hasThreeCard && currentCntFeatureRank > 10{
            return (currentCntFeatureRank, "A三条", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isForthLevelStraight(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasAce : Bool = false
        var hasStraight : Bool = false
        var straightHead : Int = 0
        var lastFeatureRank: Int = 99
        var straightNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 2 || singlefeature.rank == lastFeatureRank{
                continue
            } else if singlefeature.rank == lastFeatureRank - 1{
                lastFeatureRank = singlefeature.rank
                straightNum += 1
            } else if singlefeature.rank < lastFeatureRank - 1 {
                straightHead = singlefeature.rank
                straightNum = 1
                lastFeatureRank = singlefeature.rank

            }
            
            if straightNum == 5 {
                hasStraight = true
                break
            }
        }
        
        if hasAce && hasStraight && straightHead > 10{
            return (straightHead, "A顺子", 0)
        }
        
        return (0, "", 0)
    }
    
    
    
    func eval_isForthLevelConsecutivePairs(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasAce : Bool = false
        var hasStraight : Bool = false
        var straightHead : Int = 0
        var lastFeatureRank: Int = 99
        var straightNum: Int = 0
        var pairNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 2 || (singlefeature.rank == lastFeatureRank && pairNum == 2){
                continue
            } else if singlefeature.rank == lastFeatureRank - 1 && pairNum == 2{
                lastFeatureRank = singlefeature.rank
                pairNum = 1
            } else if singlefeature.rank < lastFeatureRank - 1 || (singlefeature.rank == lastFeatureRank - 1 && pairNum == 1) {
                straightHead = singlefeature.rank
                straightNum = 0
                pairNum = 1
                lastFeatureRank = singlefeature.rank

            } else if singlefeature.rank == lastFeatureRank && pairNum == 1 {
                pairNum += 1
                straightNum += 1
            }
            
            if straightNum == 3 {
                hasStraight = true
                break
            }
        }
        
        if hasAce && hasStraight && straightHead > 10{
            return (straightHead, "A连对", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isForthLevelPair(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasAce : Bool = false
        var hasPair : Bool = false
        var pairFeature: Int = 0
        var pairNum: Int = 0
        
        if singlefeatures.contains(where: { $0.originalRank == 1}) {
            hasAce = true
        }
        
        for singlefeature in singlefeatures {
            if pairFeature == singlefeature.rank {
                pairNum += 1
            } else {
                pairNum = 1
                pairFeature = singlefeature.rank
            }
            
            if pairNum == 2 {
                hasPair = true
                break
            }
        }
        
        if hasAce && hasPair && pairFeature > 10{
            return (pairFeature, "A对子", 0)
        }
        return (0, "", 0)
    }
    
    func eval_isFourTwo(singlefeatures:[RFastSingelFeature]) -> (Int, String, Int){
        
        var currentCnt: Int = 0
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 2 {
                currentCnt += 1
            }
        }
        
        if currentCnt == 4 {
            return (1, "4条2", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isThreeBoom(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int) {
        
        var allCardDic : [Int : Int] = [:]
        var keyList : [Int] = []
        
        for singlefeature in singlefeatures {
            if let currentV = allCardDic[singlefeature.originalRank] {
                allCardDic[singlefeature.originalRank] = currentV + 1
            } else {
                allCardDic[singlefeature.originalRank] = 1
                keyList.append(singlefeature.originalRank)
            }
        }
        var boomNum: Int = 0
        var boomKey: [Int] = []
        for key in keyList {
            if allCardDic[key] == 4 {
                boomNum += 1
                boomKey.append(key)
            }
        }
        
        if boomNum == 3 {
            return (boomKey[0], "3炸弹", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isDragon(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int) {
        
        var allCardDic : [Int : Int] = [:]
        var keyList : [Int] = []
        
        for singlefeature in singlefeatures {
            if let currentV = allCardDic[singlefeature.originalRank] {
                allCardDic[singlefeature.originalRank] = currentV + 1
            } else {
                allCardDic[singlefeature.originalRank] = 1
                keyList.append(singlefeature.originalRank)
            }
        }
        
        for i in 1...13 {
            if !keyList.contains(i){
                return (0, "", 0)
            }
        }
        
        return (1, "一条龙", 0)
    }
    
    func eval_isAllSmallCard(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int) {
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank < 3 || singlefeature.originalRank > 10 {
                return (0, "", 0)
                
            }
        }
        
        return (1, "全小牌", 0)
    }
    
    func eval_isFourCardStraight(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int) {
        
        var hasStraight : Bool = false
        var straightHead : Int = 0
        var lastFeatureRank: Int = 99
        var straightNum: Int = 0
        var rankList: [Int] = []
        
        //带12345， 23456
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 2{
                continue
            }
            rankList.append(singlefeature.rank)
        }
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 1 || singlefeature.originalRank == 2 {
                rankList.append(singlefeature.originalRank)
            }
        }
        
        print("4 straight rankList \(rankList)")
        
        
        
        
        for featureRank in rankList {
            if featureRank == lastFeatureRank{
                continue
            } else if featureRank == lastFeatureRank - 1{
                lastFeatureRank = featureRank
                straightNum += 1
            } else if featureRank < lastFeatureRank - 1 {
                straightHead = featureRank
                straightNum = 1
                lastFeatureRank = featureRank

            }
            
            if straightNum == 4 {
                hasStraight = true
                break
            }
        }
        
        if hasStraight {
            return (straightHead, "4张顺子", 0)
        }
        
        return (0, "", 0)
    }
    
    func eval_isPair(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var hasPair : Bool = false
        var pairFeature: Int = 0
        var pairNum: Int = 0
        
        for singlefeature in singlefeatures {
            print("当前的牌 \(pairFeature)  \(singlefeature.originalRank) \(singlefeature.rank)")
            if pairFeature == singlefeature.rank {
                pairNum += 1
            } else {
                pairNum = 1
                pairFeature = singlefeature.rank
            }
            
            if pairNum == 2 {
                hasPair = true
                break
            }
        }
        
        if hasPair {
            return (pairFeature, "对子", 0)
        }
        return (0, "", 0)
    }
    
    func eval_is1703Points(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var sum: Int = 0
        
        for singlefeature in singlefeatures {
            if singlefeature.originalRank == 1 {
                sum += 20
            } else if singlefeature.originalRank == 13 {
                sum += 15
            } else if singlefeature.originalRank == 12 {
                sum += 6
            }
        }
        
        return (sum, "分数\(sum)", 0)
    }
    
    func eval_is1350Points(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var sum: Int = 0
        var cardDic: [Int:Int] = [:]
        
        for singlefeature in singlefeatures {
            if let currentCnt = cardDic[singlefeature.originalRank] {
                
                cardDic[singlefeature.originalRank] = currentCnt + 1
            } else {
                cardDic[singlefeature.originalRank] = 1
            }
            
            if singlefeature.originalRank == 1 {
                sum += 1
            } else if singlefeature.originalRank == 2 {
                sum += 1
            }
        }
        
        for (key, value) in cardDic {
            if value == 4 {
                sum += 1
            }
        }
        
        return (sum, "分数\(sum)", 0)
    }
    
    func eval_is1501Points(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        return (1, "分数\(1)", 0)
    }
    
    func eval_is1604Points(singlefeatures: [RFastSingelFeature]) -> (Int, String, Int){
        
        var sum: Int = 0
        var cardDic: [Int:Int] = [:]
        
        for singlefeature in singlefeatures {
            if let currentCnt = cardDic[singlefeature.originalRank] {
                
                cardDic[singlefeature.originalRank] = currentCnt + 1
            } else {
                cardDic[singlefeature.originalRank] = 1
            }
            
            if singlefeature.originalRank == 1 {
                sum += 4
            } else if singlefeature.originalRank == 13 {
                sum += 2
            } else if singlefeature.originalRank == 3 && singlefeature.suit == 2 {
                sum += 6
            }
        }
        
        for (key, value) in cardDic {
            if value == 4 {
                sum += 5
            }
        }
        
        return (sum, "分数\(sum)", 0)
    }
    
    
    
    
    
    
    
    func blackRedJudger(singlefeature: RFastSingelFeature) -> Int{
        //红
        if self.suitRules.firstIndex(of: singlefeature.suit) == 1 || self.suitRules.firstIndex(of: singlefeature.suit) == 3 {
            return 1
        //黑
        } else{
            return 0
            
        }
    }
    
    
    class RFastSingelFeature{
        var rank: Int = 0
        var point: Int = 0
        var suit: Int = 0
        var originalRank: Int = 0
        init(singlefeature: SingleFeature, redspecialfeatureValueRange: Int, blackspecialfeatureValueRange: Int, KValueRange: Int, QValueRange: Int, JValueRange: Int, isCompareSuit: Int, singlefeatureRankRule: Int){
            let rule = ClassifierSettingArgs.targetSetting[18] as! RFastDatasetRule
            //Rank Initialization
            self.originalRank = singlefeature.rank
            if singlefeatureRankRule == 0{
                if singlefeature.originalRank == 1 {
                    self.rank = 14
                } else if singlefeature.originalRank == 2 {
                    self.rank = 15
                } else {
                    self.rank = singlefeature.originalRank
                }
            } else if singlefeatureRankRule == 1 {
                if singlefeature.originalRank == 1 {
                    self.rank = 14
                } else {
                    self.rank = singlefeature.originalRank
                }
            }
            
            //suit Initialization
            if isCompareSuit == 0{
                self.suit = 0
            } else {
                self.suit = singlefeature.suit[0]
            }
        }
    }

}

