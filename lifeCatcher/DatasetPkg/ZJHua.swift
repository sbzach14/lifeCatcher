
import Foundation

class ZJHDatasetRule : Rule{
    
    let handNum: [Int] = [3,4,5,6,7,8,9,10,11,12]
    let minRank: [Int] = [2,3,4,5,6,7,8,9,10]
    let isCompareSuit : [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isAce:[Int: String] = [
        0: "无",
        1: "A最小",
        2: "A最大"
    ]
    let isAceStraight: [Int: String] = [
        0: "无",
        1: "最小顺",
        2: "最大顺",
        3: "第二大顺"
    ]
    let isHeadSingleFeature: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isReverseHighSingleFeature: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isRedspecialfeature: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let redspecialfeatureSuit: [Int: String] = [
        0: "任意",
        1: "红色"
    ]
    let redspecialfeatureRank: [Int: String] = [
        14: "任意牌",
        13: "K",
        12: "Q",
        11: "J",
        10: "10",
        9: "9",
        8: "8",
        7: "7",
        6: "6",
        5: "5",
        4: "4",
        3: "3",
        2: "2",
        1: "A",
        0: "0",
    ]
    let isBlackspecialfeature: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let blackspecialfeatureSuit: [Int: String] = [
        0: "任意",
        1: "红色"
    ]
    let blackspecialfeatureRank: [Int: String] = [
        14: "任意牌",
        13: "K",
        12: "Q",
        11: "J",
        10: "10",
        9: "9",
        8: "8",
        7: "7",
        6: "6",
        5: "5",
        4: "4",
        3: "3",
        2: "2",
        1: "A",
        0: "0"
    ]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            13: "对王",
            12: "豹子",
            11: "金花235",
            10: "235",
            9: "金花AKJ",
            8: "AKJ",
            7: "三公",
            6: "顺金",
            5: "同花对子",
            4: "金花",
            3: "顺子",
            2: "真对子",
            1: "对子",
            0: "散牌"
        ]
        self.setting = [
            0: "金花[301]",
            1: "金花顺大[302]",
            2: "金花AKJ[303]",
            3: "百变金花[305]",
            4: "金花4选3[420]",
            5: "金花A23[306]",
            6: "金花5选3[560]",
            7: "金花6选3[610]"
        ]
        self.ruleInfo = [
            0:"""
    牌数:52张(没有大小王)每家3张牌规则:
    1)豹子: 3张同样大小的牌
    2)顺金: 花色相同的顺子
    3)金花:花色相同的牌
    4)顺子:花色不全相同的相连3张牌
    5)对子: 对A最大，对2最小
    6)散牌: A最大 2最小
    """,
            1:"顺子大于清。其他和常规金花一样",
            2:"52张，3条 > 同花AKJ > 同花235 > AKJ > 235 > 同花顺 > 顺子 > 同花 > 对子 > 单张",
            3:"""
            牌数:54张牌，每家3张牌。王可变任意牌规则:
            1)豹子: 3张同样大小的牌
            2)顺金: 花色相同的顺子
            3)金花:花色相同的牌
            4) 顺子: 花色不全相同的相连3张牌
            5) 对子: 对A...对2
            6) 散牌: A最大 2最小
            """,
            4:"""
            游戏说明
            牌数:52张(没有大小王)每家4张牌，选3张规则:
            1)豹子:3张同样大小的牌
            2)顺金:花色相同的顺子
            3)金花:花色相同的牌
            4)顺子:花色不全相同的相连3张牌
            5)对子:对A...对26) 散牌:A最大2最小
            """,
            5:"""
            牌数:52张(没有大小王)每家3张牌规则:
            1)豹子:3张同样大小的牌
            2)顺金:花色相同的顺子
            3)金花:花色相同的牌
            4)顺子:QKA> A23>JQK...>234
            5)对子:对A...对2
            6) 散牌:A最大2最小
            """,
            6:"""
            牌数:52张(没有大小王)每家5张牌，选3张规则:
            1)豹子:3张同样大小的牌
            2)顺金:花色相同的顺子
            3)金花:花色相同的牌
            4)顺子:花色不全相同的相连3张牌
            5)对子:对A...对2
            6)散牌:A最大2最小
            """,
            7:"""
            牌数:52张(没有大小王)每家6张牌，选3张规则:
            1)豹子:3张同样大小的牌
            2)顺金:花色相同的顺子
            3)金花:花色相同的牌
            4)顺子:花色不全相同的相连3张牌
            5)对子:对A...对2
            6)散牌:A最大2最小
            """
        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10,11,12,13,14,15]

    }
}




//炸金花
class ZJHDataset{
    
    
    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo], [Int]) {
        
        var FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int, minRank: Int, handNum: Int, isHeadSingleFeature: Int, isRedspecialfeature: Int, isBlackspecialfeature: Int) -> String{
        var errMessage : String = ""
        if(rcNum * handNum > 52 - (minRank - 2) * 4 - isHeadSingleFeature * 12 + isRedspecialfeature + isBlackspecialfeature)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllSingleFeatureIndex(minRank: Int, isAce: Int, isHeadSingleFeature: Int, isRedspecialfeature: Int, isBlackspecialfeature: Int) -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...12{
                if rank == 0 && isAce != 0{
                    result.append(rank + i * 13)
                }
                else if (rank >= 10 || rank <= 12) && isHeadSingleFeature == 1{
                    result.append(rank + i * 13)
                }
                else if rank >= minRank - 1{
                    result.append(rank + i * 13)
                }
            }
        }
        if isBlackspecialfeature == 1{
            result.append(53)
        }
        if isRedspecialfeature == 1{
            result.append(54)
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
    
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let rule = ClassifierSettingArgs.targetSetting[2] as! ZJHDatasetRule
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let isCompareSuit = args[5]
        let minRank = rule.minRank[args[6]]
        let isAce = args[7]
        let isAceStraight = args[8]
        let isHeadSingleFeature = args[9]
        let isRedspecialfeature = args[10]
        let redspecialfeatureSuit = args[11]
        let redspecialfeatureRank = args[12]
        let isBlackspecialfeature = args[13]
        let blackspecialfeatureSuit = args[14]
        let blackspecialfeatureRank = args[15]
        let isReverseHighSingleFeature = args[16]
        
        
        var maxRank = 0
        var returnRCInfos: [DatasetReturnRCInfo] = []


        var allPlaySingleFeatures: [RC] = []
        var community = [SingleFeature]()
        if FeatureList.count < ZJHDataset.getMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
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
        

        
        for i in 0..<rcNum{
            var rcSingleFeatureStr = ""
            for singlefeature in allPlaySingleFeatures[i].rcSingleFeature{
                rcSingleFeatureStr += ClassifierSettingArgs.singlefeatureLabelDic[singlefeature.singlefeatureIndex]! + " "
            }
        }
        
        if handNum == 3 {
            for i in 0..<rcNum {
                (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = ZJHDatasetHandAnalyst(
                    isCompareSuit: isCompareSuit,
                    minRank: minRank,
                    isAce: isAce,
                    isAceStraight: isAceStraight,
                    isHeadSingleFeature: isHeadSingleFeature,
                    isRedspecialfeature: isRedspecialfeature,
                    redspecialfeatureSuit: redspecialfeatureSuit,
                    redspecialfeatureRank: redspecialfeatureRank,
                    isBlackspecialfeature: isBlackspecialfeature,
                    blackspecialfeatureSuit: blackspecialfeatureSuit,
                    blackspecialfeatureRank: blackspecialfeatureRank,
                    isReverseHighSingleFeature: isReverseHighSingleFeature,
                    rankRules: rankRules,
                    suitRules: suitRules
                ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature)
            }
        } else if handNum > 3{
            for i in 0..<rcNum {
                var allsinglefeatures = Array(allPlaySingleFeatures[i].rcSingleFeature)
                var maxFlag = 0
                for combination in allsinglefeatures.combinations(ofCount: 3){
                    (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = ZJHDatasetHandAnalyst(
                        isCompareSuit: isCompareSuit,
                        minRank: minRank,
                        isAce: isAce,
                        isAceStraight: isAceStraight,
                        isHeadSingleFeature: isHeadSingleFeature,
                        isRedspecialfeature: isRedspecialfeature,
                        redspecialfeatureSuit: redspecialfeatureSuit,
                        redspecialfeatureRank: redspecialfeatureRank,
                        isBlackspecialfeature: isBlackspecialfeature,
                        blackspecialfeatureSuit: blackspecialfeatureSuit,
                        blackspecialfeatureRank: blackspecialfeatureRank,
                        isReverseHighSingleFeature: isReverseHighSingleFeature,
                        rankRules: rankRules,
                        suitRules: suitRules
                    ).evalHand(singlefeatures: combination)
                    if maxFlag < allPlaySingleFeatures[i].evaluateFlag {
                        maxFlag = allPlaySingleFeatures[i].evaluateFlag
                    }
                }
                allPlaySingleFeatures[i].evaluateFlag = maxFlag
            }
        }
        for i in 0..<rcNum {
            (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeatureType, allPlaySingleFeatures[i].isPair) = ZJHDatasetHandAnalyst(
                isCompareSuit: isCompareSuit,
                minRank: minRank,
                isAce: isAce,
                isAceStraight: isAceStraight,
                isHeadSingleFeature: isHeadSingleFeature,
                isRedspecialfeature: isRedspecialfeature,
                redspecialfeatureSuit: redspecialfeatureSuit,
                redspecialfeatureRank: redspecialfeatureRank,
                isBlackspecialfeature: isBlackspecialfeature,
                blackspecialfeatureSuit: blackspecialfeatureSuit,
                blackspecialfeatureRank: blackspecialfeatureRank,
                isReverseHighSingleFeature: isReverseHighSingleFeature,
                rankRules: rankRules,
                suitRules: suitRules
            ).evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature)
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
        
        var leftSingleFeatures: [Int] = []
        for singlefeature in FeatureList{
            leftSingleFeatures.append(singlefeature.singlefeatureIndex)
        }
        if leftSingleFeatures.count < ZJHDataset.getMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        return (returnRCInfos, leftSingleFeatures)
    }
}


class ZJHDatasetHandAnalyst {
    
    var isCompareSuit: Int
    var minRank: Int
    var isAce: Int
    var isAceStraight: Int
    var isHeadSingleFeature: Int
    var isRedspecialfeature: Int
    var redspecialfeatureSuit: Int
    var redspecialfeatureRank: Int
    var isBlackspecialfeature: Int
    var blackspecialfeatureSuit: Int
    var blackspecialfeatureRank: Int
    var isReverseHighSingleFeature: Int
    var rankRules: [Int]
    var suitRules: [Int]
    var maxRank: Int
    
    init(isCompareSuit: Int,
          minRank: Int,
          isAce: Int,
          isAceStraight: Int,
          isHeadSingleFeature: Int,
          isRedspecialfeature: Int,
          redspecialfeatureSuit: Int,
          redspecialfeatureRank: Int,
          isBlackspecialfeature: Int,
          blackspecialfeatureSuit: Int,
          blackspecialfeatureRank: Int,
          isReverseHighSingleFeature: Int,
          rankRules: [Int],
          suitRules: [Int]){
        
        self.isCompareSuit = isCompareSuit
        self.minRank = minRank
        self.isAce = isAce
        self.isAceStraight = isAceStraight
        self.isHeadSingleFeature = isHeadSingleFeature
        self.isRedspecialfeature = isRedspecialfeature
        self.redspecialfeatureSuit = redspecialfeatureSuit
        self.redspecialfeatureRank = redspecialfeatureRank
        self.isBlackspecialfeature = isBlackspecialfeature
        self.blackspecialfeatureSuit = blackspecialfeatureSuit
        self.blackspecialfeatureRank = blackspecialfeatureRank
        self.isReverseHighSingleFeature = isReverseHighSingleFeature
        self.rankRules = rankRules
        self.suitRules = suitRules
        
        if isHeadSingleFeature == 1 {
            if isAce == 2 {
                self.maxRank = 14
            } else {
                self.maxRank = 13
            }
        } else {
            if isAce == 2 {
                self.maxRank = 11
            } else {
                self.maxRank = 10
            }
        }
        
        if minRank != 2 {
            if rankRules.contains(10) {
                self.rankRules.removeAll { $0 == 10 }
            }
            if rankRules.contains(11) {
                self.rankRules.removeAll { $0 == 11 }
            }
        }
        
        if isAce == 0 {
            if rankRules.contains(8) {
                self.rankRules.removeAll { $0 == 8 }
            }
            if rankRules.contains(9) {
                self.rankRules.removeAll { $0 == 9 }
            }
        }
        
        if isHeadSingleFeature == 0 {
            if rankRules.contains(7) {
                self.rankRules.removeAll { $0 == 7 }
            }
        }
    }
    
    func evalHand(singlefeatures: [SingleFeature])-> (Int, String, Int){
        
        var sortedSingleFeatures = sortSingleFeatures(singlefeatures: singlefeatures)
        var sortedString = ""
        var maxScore = 0
        var maxSingleFeatureType = ""
        var maxIsPair = 0
        
        for sortedSingleFeatures in sortedSingleFeatures {
            let (score, singlefeatureType, isPair) = calcHandInfoFlg(sortedSingleFeatures: sortedSingleFeatures)
            if score > maxScore {
                maxScore = score
                maxSingleFeatureType = singlefeatureType
                maxIsPair = isPair
            }
        }
        
        return (maxScore, maxSingleFeatureType, maxIsPair)
    }
    
    func sortSingleFeatures(singlefeatures: [SingleFeature]) -> [[SingleFeature]] {
        var singlefeatures = singlefeatures
        var allSingleFeatures = [[SingleFeature]]()
        
        for i in 0..<3 {
            if singlefeatures[i].rank == 14 && isBlackspecialfeature == 1 {
                if blackspecialfeatureRank == 14 {
                    singlefeatures[i].rank = -1
                } else {
                    singlefeatures[i].rank = blackspecialfeatureRank
                }
                if blackspecialfeatureSuit == 0 {
                    singlefeatures[i].suit = [3, 2, 1, 0]
                } else if blackspecialfeatureSuit == 1 {
                    singlefeatures[i].suit = [suitRules[0], suitRules[2]].sorted()
                }
            } else if singlefeatures[i].rank == 15 && isRedspecialfeature == 1 {
                if redspecialfeatureRank == 14 {
                    singlefeatures[i].rank = -1
                } else {
                    singlefeatures[i].rank = redspecialfeatureRank
                }
                if redspecialfeatureSuit == 0 {
                    singlefeatures[i].suit = [3, 2, 1, 0]
                } else if redspecialfeatureSuit == 1 {
                    singlefeatures[i].suit = [suitRules[1], suitRules[3]].sorted()
                }
            } else if singlefeatures[i].rank == 1 {
                if isAce == 1 {
                    singlefeatures[i].rank = minRank - 1
                } else if isAce == 2 {
                    singlefeatures[i].rank = maxRank
                }
            }
        }
        
        let handCombinations = singlefeatures.combinations(ofCount: 3)
        for handCombination in handCombinations{
            allSingleFeatures.append(handCombination)
            
            var aceList = [SingleFeature]()
            for singlefeature in handCombination{
                aceList.append(SingleFeature(suit: singlefeature.suit, rank: singlefeature.rank, singlefeatureIndex: singlefeature.singlefeatureIndex))
            }
            
            if self.isAceStraight != 0 && self.isAce == 2{
                var isAdd = false
                for singlefeature in aceList{
                    if singlefeature.rank == self.maxRank{
                        singlefeature.rank = self.minRank - 1
                        isAdd = true
                    }
                }
                if isAdd{
                    allSingleFeatures.append(aceList)
                }
            }
        }
        
        for i in 0..<allSingleFeatures.count{
            allSingleFeatures[i].sort(by: { singlefeature1, singlefeature2 in
                return SingleFeature.calScore(singlefeature: singlefeature1) > SingleFeature.calScore(singlefeature: singlefeature2)
            })
        }
        
        return allSingleFeatures
    }
    
    func calcHandInfoFlg(sortedSingleFeatures: [SingleFeature]) -> (Int, String, Int) {
        var rankResult = 0
        var singlefeatureType: String = ""
        var isPair: Int = 0
        var ruleDict: [Int: ([SingleFeature]) -> (Int, String, Int)] = [
            0  : self.eval_holesinglefeature,
            1  : self.eval_onepair,
            2  : self.eval_truepair,
            3  : self.eval_straight,
            4  : self.eval_flush,
            5  : self.eval_pairflush,
            6  : self.eval_straightflush,
            7  : self.eval_threehead,
            8  : self.eval_akj,
            9  : self.eval_akjflush,
            10 : self.eval_235,
            11 : self.eval_235flush,
            12 : self.eval_threesinglefeature,
            13 : self.eval_doublespecialfeature
        ]
        
        for (index, ruleIndex) in rankRules.enumerated() {
            var rankFlag = 1 << (rankRules.count - index + 18)
            (rankResult, singlefeatureType, isPair) = ruleDict[ruleIndex]!(sortedSingleFeatures) // 假设 ruleDict 是一个规则函数的字典
            
            if (isCompareSuit == 0) {
                rankResult >>= 6
            }
            
            if rankResult != 0 {
                rankResult |= rankFlag
                break
            }
        }

        
        return (rankResult, singlefeatureType, isPair)
    }
    
    func eval_doublespecialfeature(_ singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var cnt: Int = 0
        var singlefeatureType: String = ""
        var isPair: Int = 0
        for i in 0..<3 {
            if singlefeatures[i].rank == -1 {
                cnt += 1
            }
        }
        if cnt == 2 {
            for _ in 1..<3 {
                rank = rank << 4 | maxRank
            }
            rank = rank << 4 | singlefeatures[0].rank
            for i in 1..<3 {
                rank = rank << 2 | singlefeatures[i].suit[0]
            }
            rank = rank << 4 | singlefeatures[0].suit[0]
        }
        else if cnt == 3 {
            for _ in 0..<3 {
                rank = rank << 4 | maxRank
            }
            for i in 0..<3 {
                rank = rank << 4 | singlefeatures[i].suit[0]
            }
        }
        if rank > 0 {
            singlefeatureType = "对王"
            isPair = 1
        }
        
        return (rank, singlefeatureType, isPair)
    }
        
    func eval_threesinglefeature(_ singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var cnt: Int = 0
        var singlefeatureType: String = ""

        var targetRank = singlefeatures[0].rank
        if targetRank == -1 {
            targetRank = maxRank
        }
        
        for i in 0..<3 {
            if singlefeatures[i].rank == targetRank || singlefeatures[i].rank == -1 {
                cnt += 1
            }
        }
        
        if cnt == 3 && targetRank != 0 {
            for _ in 0..<3 {
                rank = rank << 4 | targetRank
            }
            for i in 0..<3 {
                rank = rank << 2 | singlefeatures[i].suit[0]
            }
        }
        
        if rank > 0{
            singlefeatureType = "三条" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!

        }

        
        return (rank, singlefeatureType, 0)
    }

    func eval_235flush(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var cnt5: Int = 0
        var cnt3: Int = 0
        var cnt2: Int = 0
        var cntC: Int = 0

        for i in 0..<3 {
            if singlefeatures[i].rank == 5 {
                cnt5 = 1
            } else if singlefeatures[i].rank == 3 {
                cnt3 = 1
            } else if singlefeatures[i].rank == 2 {
                cnt2 = 1
            } else if singlefeatures[i].rank == -1 {
                cntC += 1
            }
        }

        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]

        for i in 0..<3 {
            for suit in singlefeatures[i].suit {
                    cntSuit[suit] += 1
            }
        }

        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if cnt5 + cnt3 + cnt2 + cntC == 3 && targetSuit != -1 {
            rank = rank << 4 | 5
            rank = rank << 4 | 3
            rank = rank << 4 | 2
            for _ in 0..<3 {
                rank = rank << 2 | targetSuit
            }
        }
        return (rank, "同花235", 0)
    }

    func eval_235(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var cnt5: Int = 0
        var cnt3: Int = 0
        var cnt2: Int = 0
        var cntC: Int = 0

        for i in 0..<3 {
            if singlefeatures[i].rank == 5 {
                cnt5 = 1
            } else if singlefeatures[i].rank == 3 {
                cnt3 = 1
            } else if singlefeatures[i].rank == 2 {
                cnt2 = 1
            } else if singlefeatures[i].rank == -1 {
                cntC += 1
            }
        }

        if cnt5 + cnt3 + cnt2 + cntC == 3 {
            rank = rank << 4 | 5
            rank = rank << 4 | 3
            rank = rank << 4 | 2
            for i in 0..<3 {
                rank = rank << 2 | singlefeatures[i].suit[0]
            }
        }
        return (rank, "235", 0)
    }
    
    func eval_akjflush(singlefeatures: [SingleFeature]) -> (Int,String,Int) {
        var rank: Int = 0
        var cntA: Int = 0
        var cntK: Int = 0
        var cntJ: Int = 0
        var cntC: Int = 0

        for i in 0..<3 {
            if singlefeatures[i].rank == maxRank || singlefeatures[i].rank == minRank - 1 {
                cntA = 1
            } else if singlefeatures[i].rank == 13 {
                cntK = 1
            } else if singlefeatures[i].rank == 11 {
                cntJ = 1
            } else if singlefeatures[i].rank == -1 {
                cntC += 1
            }
        }

        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]
        for i in 0..<3 {
            for suit in singlefeatures[i].suit {
                    cntSuit[suit] += 1
            }
        }
        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if cntA + cntK + cntJ + cntC == 3 && targetSuit != -1 {
            rank = rank << 4 | 14
            rank = rank << 4 | 13
            rank = rank << 4 | 11
            for _ in 0..<3 {
                rank = rank << 2 | targetSuit
            }
        }
        return (rank, "同花AKJ", 0)
    }
    
    func eval_akj(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var cntA: Int = 0
        var cntK: Int = 0
        var cntJ: Int = 0
        var cntC: Int = 0

        for i in 0..<3 {
            if singlefeatures[i].rank == maxRank || singlefeatures[i].rank == minRank - 1 {
                cntA = 1
            } else if singlefeatures[i].rank == 13 {
                cntK = 1
            } else if singlefeatures[i].rank == 11 {
                cntJ = 1
            } else if singlefeatures[i].rank == -1 {
                cntC += 1
            }
        }

        if cntA + cntK + cntJ + cntC == 3 {
            rank = rank << 4 | 14
            rank = rank << 4 | 13
            rank = rank << 4 | 11
            for i in 0..<3 {
                rank = rank << 2 | singlefeatures[i].suit[0]
            }
        }
        return (rank, "AKJ", 0)
    }
    
    func eval_threehead(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var cnt: Int = 0

        for i in 0..<3 {
            if singlefeatures[i].rank == 13 ||
               singlefeatures[i].rank == 12 ||
               singlefeatures[i].rank == 11 ||
               singlefeatures[i].rank == -1 {
                cnt += 1
            }
        }

        if cnt == 3 {
            for i in 0..<3 {
                if singlefeatures[i].rank == -1 {
                    rank = rank << 4 | 13
                } else {
                    rank = rank << 4 | singlefeatures[i].rank
                }
            }
            for i in 0..<3 {
                rank = rank << 2 | singlefeatures[i].suit[0]
            }
        }
        return (rank, "三公", 0)
    }
    
    func eval_straightflush(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var cntC: Int = 0
        var straightHead: Int = -1
        var singlefeatureType: String = ""
        
        var rankList: [Int] = []
        for i in 0..<3 {
            if singlefeatures[i].rank == -1 {
                cntC += 1
            } else {
                rankList.append(singlefeatures[i].rank)
            }
        }

        if cntC == 3 {
            straightHead = 15
        } else if cntC == 2 {
            straightHead = min(self.maxRank, rankList[0] + 2)
        } else if cntC == 1 {
            if rankList[0] - rankList[1] == 1 {
                straightHead = min(self.maxRank, rankList[0] + 1)
            } else if rankList[0] - rankList[1] == 2 {
                straightHead = rankList[0]
            }
        } else {
            if rankList[0] - rankList[1] == 1 &&
               rankList[0] - rankList[2] == 2 &&
               rankList[2] != 0 {
                straightHead = rankList[0]
            }
        }

        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]
        for i in 0..<3 {
            for suit in singlefeatures[i].suit {
                cntSuit[suit] += 1
            }
        }
        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if targetSuit != -1 {
            if straightHead == self.minRank + 1 {
                if self.isAceStraight == 2 {
                    rank = rank << 4 | (self.maxRank + 1)
                    for i in 1..<3 {
                        rank = rank << 4 | (straightHead - i)
                    }
                    for _ in 0..<3 {
                        rank = rank << 2 | targetSuit
                    }
                } else if self.isAceStraight == 3 {
                    rank = rank << 4 | self.maxRank
                    for i in 1..<3 {
                        rank = rank << 4 | (straightHead - i)
                    }
                    for _ in 0..<3 {
                        rank = rank << 2 | targetSuit
                    }
                }
            }
            if straightHead != -1 {
                for i in 0..<3 {
                    rank = rank << 4 | (straightHead - i)
                }
                for _ in 0..<3 {
                    rank = rank << 2 | targetSuit
                }
            }
        }
        
        if rank > 0 {
            singlefeatureType = ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]! + "同花顺"
        }
        
        
        return (rank, singlefeatureType, 0)
    }
    
    func eval_pairflush(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0

        var pairRank: Int = -1
        var singleRank: Int = -1
        var cntC: Int = 0
        var rankList: [Int] = []
        var singlefeatureType: String = ""
        
        for i in 0..<3 {
            if singlefeatures[i].rank == -1 {
                cntC += 1
            } else {
                rankList.append(singlefeatures[i].rank)
            }
        }

        if cntC == 3 {
            pairRank = self.maxRank
            singleRank = self.maxRank
        } else if cntC == 2 {
            pairRank = self.maxRank
            singleRank = rankList[0]
        } else if cntC == 1 {
            pairRank = rankList[0]
            singleRank = rankList[1]
        } else {
            if rankList[0] == rankList[1] {
                pairRank = rankList[0]
                singleRank = rankList[2]
                singlefeatureType = "同花对" +  ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            } else if rankList[1] == rankList[2] {
                pairRank = rankList[1]
                singleRank = rankList[0]
                singlefeatureType = "同花对" +  ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[1].originalRank]!
            }
        }

        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]

        for i in 0..<3 {
            for suit in singlefeatures[i].suit {
                cntSuit[suit] += 1
            }
        }
        
        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if targetSuit != -1 && pairRank != -1 {
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for _ in 0..<3 {
                rank = rank << 2 | targetSuit
            }
        }
        return (rank, singlefeatureType, 1)
    }
    
    func eval_flush(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var targetSuit: Int = -1
        var cntSuit: [Int] = [0, 0, 0, 0]

        for i in 0..<3 {
            for suit in singlefeatures[i].suit {
                cntSuit[suit] += 1
            }
        }
        
        for i in cntSuit {
            if i == 3 {
                targetSuit = i
            }
        }

        if targetSuit != -1 {
            var specialfeatureList: [Int] = []
            var normalList: [Int] = []
            
            for i in 0..<3 {
                if singlefeatures[i].rank == -1 {
                    specialfeatureList.append(self.maxRank)
                } else {
                    normalList.append(singlefeatures[i].rank)
                }
            }

            for c in specialfeatureList {
                rank = rank << 4 | c
            }
            
            for c in normalList {
                rank = rank << 4 | c
            }

            for _ in 0..<3 {
                rank = rank << 2 | targetSuit
            }
        }
        return (rank, "同花", 0)
    }

    func eval_straight(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0
        var cntC: Int = 0
        var straightHead: Int = -1
        var rankList: [Int] = []
        var suitList: [Int] = []
        
        

        for i in 0..<3 {
            if singlefeatures[i].rank == -1 {
                cntC += 1
            } else {
                rankList.append(singlefeatures[i].rank)
            }
        }
        if cntC == 3 {
            straightHead = 15
            for i in 0..<3 {
                suitList.append(singlefeatures[i].suit[0])
            }
        }
        else if cntC == 2 {
            straightHead = min(self.maxRank, rankList[0] + 2)
            suitList.append(singlefeatures[0].suit[0])
            suitList.append(singlefeatures[1].suit[0])
            suitList.append(singlefeatures[2].suit[0])
        }
        else if cntC == 1 {
            if rankList[0] - rankList[1] == 1 {
                straightHead = min(self.maxRank, rankList[0] + 1)
                suitList.append(singlefeatures[2].suit[0])
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[1].suit[0])
            }
            else if rankList[0] - rankList[1] == 2 {
                straightHead = rankList[0]
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[2].suit[0])
                suitList.append(singlefeatures[1].suit[0])
            }
        }
        else {
            if rankList[0] - rankList[1] == 1 &&
                rankList[0] - rankList[2] == 2 &&
                rankList[2] != 0 {
                straightHead = rankList[0]
                for i in 0..<3 {
                    suitList.append(singlefeatures[i].suit[0])
                }
            }
        }

        if straightHead == self.minRank + 1 {
            if self.isAceStraight == 2 {
                rank = rank << 4 | self.maxRank + 1
                for i in 1..<3 {
                    rank = rank << 4 | (straightHead - i)
                }
                for i in 0..<3 {
                    rank = rank << 2 | suitList[i]
                }
            } else if self.isAceStraight == 3 {
                rank = rank << 4 | self.maxRank
                for i in 1..<3 {
                    rank = rank << 4 | (straightHead - i)
                }
                for i in 0..<3 {
                    rank = rank << 2 | suitList[i]
                }
            }
        } else if straightHead != -1 {
            for i in 0..<3 {
                rank = rank << 4 | (straightHead - i)
            }
            for i in 0..<3 {
                rank = rank << 2 | suitList[i]
            }
        }
        var singlefeatureType: String = ""
        if rank > 0 {
            singlefeatureType = ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]! + "顺子"
        }

        return (rank, singlefeatureType, 0)
    }
    
    func eval_truepair(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0

        var pairRank: Int = -1
        var singleRank: Int = -1
        var cntC: Int = 0
        var suitList: [Int] = []
        var singlefeatureType: String = ""

        for i in 0..<3 {
            if singlefeatures[i].rank == -1 {
                cntC += 1
            }
        }

        if cntC == 3 {
            pairRank = self.maxRank
            singleRank = self.maxRank
            if singlefeatures[0].suit[0] == singlefeatures[1].suit[0] {
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[2].suit[0])
            } else {
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[2].suit[0])
                suitList.append(singlefeatures[0].suit[0])
            }
        } else if cntC == 2 {
            if singlefeatures[1].suit[0] == singlefeatures[2].suit[0] {
                pairRank = self.maxRank
                singleRank = singlefeatures[0].rank
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[2].suit[0])
                suitList.append(singlefeatures[0].suit[0])
            } else if singlefeatures[0].suit.contains(singlefeatures[1].suit[0]) {
                pairRank = singlefeatures[0].rank
                singleRank = self.maxRank
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[2].suit[0])
            } else if singlefeatures[0].suit.contains(singlefeatures[2].suit[0]) {
                pairRank = singlefeatures[0].rank
                singleRank = self.maxRank
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[1].suit[0])
            }
        } else if cntC == 1 {
            if singlefeatures[0].suit.contains(singlefeatures[2].suit[0]) {
                pairRank = singlefeatures[0].rank
                singleRank = singlefeatures[1].rank
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[1].suit[0])
                singlefeatureType = "真对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            } else if singlefeatures[1].suit.contains(singlefeatures[2].suit[0]) {
                pairRank = singlefeatures[1].rank
                singleRank = singlefeatures[0].rank
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[0].suit[0])
                singlefeatureType = "真对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[1].originalRank]!
            }
        } else {
            if singlefeatures[0].rank == singlefeatures[1].rank && singlefeatures[0].suit.contains(singlefeatures[1].suit[0]) {
                pairRank = singlefeatures[0].rank
                singleRank = singlefeatures[2].rank
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[2].suit[0])
                singlefeatureType = "真对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            }

            if singlefeatures[1].rank == singlefeatures[2].rank && singlefeatures[1].suit.contains(singlefeatures[2].suit[0]) {
                pairRank = singlefeatures[1].rank
                singleRank = singlefeatures[0].rank
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[0].suit[0])
                singlefeatureType = "真对" +  ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[1].originalRank]!
            }
        }

        if pairRank != -1 {
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for i in 0..<3 {
                rank = rank << 2 | suitList[i]
            }
        }

        return (rank, singlefeatureType, 0)
    }
    
    func eval_onepair(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var rank: Int = 0

        var pairRank: Int = -1
        var singleRank: Int = -1
        var cntC: Int = 0
        var suitList: [Int] = []
        var singlefeatureType: String = ""

        for i in 0..<3 {
            if singlefeatures[i].rank == -1 {
                cntC += 1
            }
        }

        if cntC == 3 {
            pairRank = self.maxRank
            singleRank = self.maxRank
            for i in 0..<3 {
                suitList.append(singlefeatures[i].suit[0])
            }
        } else if cntC == 2 {
            pairRank = self.maxRank
            singleRank = singlefeatures[0].rank
            suitList.append(singlefeatures[1].suit[0])
            suitList.append(singlefeatures[2].suit[0])
            suitList.append(singlefeatures[0].suit[0])
        } else if cntC == 1 {
            pairRank = singlefeatures[0].rank
            singleRank = singlefeatures[1].rank
            suitList.append(singlefeatures[0].suit[0])
            suitList.append(singlefeatures[2].suit[0])
            suitList.append(singlefeatures[1].suit[0])
        } else {
            if singlefeatures[0].rank == singlefeatures[1].rank {
                pairRank = singlefeatures[0].rank
                singleRank = singlefeatures[2].rank
                suitList.append(singlefeatures[0].suit[0])
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[2].suit[0])
                singlefeatureType = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[0].originalRank]!
            } else if singlefeatures[1].rank == singlefeatures[2].rank {
                pairRank = singlefeatures[1].rank
                singleRank = singlefeatures[0].rank
                suitList.append(singlefeatures[1].suit[0])
                suitList.append(singlefeatures[2].suit[0])
                suitList.append(singlefeatures[0].suit[0])
                singlefeatureType = "对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[1].originalRank]!
            }
        }

        if pairRank != -1 {
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for i in 0..<3 {
                rank = rank << 2 | suitList[i]
            }
        }

        return (rank, singlefeatureType, 1)
    }

    func eval_holesinglefeature(singlefeatures: [SingleFeature]) -> (Int, String, Int) {
        var specialfeatureList: [[Int]] = []
        var normalList: [[Int]] = []
        var rank: Int = 0

        if (self.isReverseHighSingleFeature != 0) {
            var minRank = self.minRank
            if self.isAce == 1 {
                minRank = self.minRank - 1
            }
            for i in 0..<3 {
                if singlefeatures[i].rank == -1 {
                    specialfeatureList.append([minRank, singlefeatures[i].rank])
                } else {
                    normalList.append([singlefeatures[i].rank, singlefeatures[i].suit[0]])
                }
            }
            for c in specialfeatureList {
                rank = rank << 4 | self.maxRank - c[0]
            }
            for c in normalList {
                rank = rank << 4 | self.maxRank - c[0]
            }
            for c in specialfeatureList {
                rank = rank << 2 | c[1]
            }
            for c in normalList {
                rank = rank << 2 | c[1]
            }
        } else {
            for i in 0..<3 {
                if singlefeatures[i].rank == -1 {
                    specialfeatureList.append([self.maxRank, singlefeatures[i].rank])
                } else {
                    normalList.append([singlefeatures[i].rank, singlefeatures[i].suit[0]])
                }
            }
            for c in specialfeatureList {
                rank = rank << 4 | c[0]
            }
            for c in normalList {
                rank = rank << 4 | c[0]
            }
            for c in specialfeatureList {
                rank = rank << 2 | c[1]
            }
            for c in normalList {
                rank = rank << 2 | c[1]
            }
        }

        return (rank, "单牌", 0)
    }

}
