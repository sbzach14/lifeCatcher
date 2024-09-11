//
//  Ain.swift
//  lifeCatcher
//
//  Created by Zhangyi Chen on 9/11/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

class AinRule : Rule{
    //Test to be deleted
    let isCompareSuit : [Int: String] = [
        0: "否",
        1: "是"
    ]
    let isAceStraight: [Int: String] = [
        0: "否",
        1: "是"
    ]
    let minRank: [Int] = [2,3,4,5,6,7,8,9]
    let handNum: Int = 0
    let communityNum: Int = 0
    let handUseType: [Int: String] = [
        0: "无限制",
        1: "必须用n张",
        2: "最少用n张"
    ]
    let handUseNum: [Int] = [1,2,3,4,5]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            11: "同花顺",
            10: "四条",
            9: "葫芦",
            8: "同花",
            7: "顺子",
            6: "三条",
            5: "三同花顺",
            4: "三顺子",
            3: "三同花",
            2: "两对",
            1: "一对",
            0: "高牌"
        ]
        self.rcNum = [2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        self.setting = [
            0: "梭哈",
        ]
        self.ruleInfo = [
            0:"""
            没有公牌，其他和标准德州规则相同，需要在选择规则后在发牌设置里选择自定义发牌然后设置成一人发五张
            先比牌型，再比主要部分牌大小，不分花色。
            同花顺
            四条
            葫芦，三条带一对
            同花
            顺子
            三条
            两对
            一对
            高牌
            """,
        ]
    }
}


class Ain{
    

    static func FindWinner(diyDealStatus: [[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo], [Int]) {
        
        
        var inputString : String = ""
        for i in 0..<inputSingleFeatures.count{
            inputString += ClassifierSettingArgs.singlefeatureLabelDic[inputSingleFeatures[i]]!
        }
        
        let (resultInfoList,leftSingleFeatures) = AinDataset.calResult(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, singlefeatureArray: inputSingleFeatures, args: args, rankRules: rankRules, suitRules: suitRules)
        return (resultInfoList, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int, minRank: Int, handUseType: Int, handUseNum: Int, handNum: Int, communityNum: Int) -> String
    {
        var errMessage : String = ""
        if(handUseType == 0 && handNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(handUseType != 0 && handNum < handUseNum)
        {
            errMessage = "手牌数小于设置需求，请重新设置！"
        }
        else if(handUseType == 1 && handUseNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(handUseType == 2 && handNum + communityNum < 5)
        {
            errMessage = "可用牌不足5张，请重新设置！"
        }
        else if(rcNum * handNum + communityNum > 52 - (minRank - 2) * 4)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    static func getAllSingleFeatureIndex(minRank: Int) -> [Int]{
        var result : [Int] = []
        for i in 0...3{
            for rank in 0...12{
                if rank == 0 || rank >= minRank - 1{
                    result.append(rank + i * 13)
                }
            }
        }
        return result
    }
    
    static func getMinSingleFeatureNum(rcNum: Int, handNum: Int, communityNum: Int, dealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]]) -> Int{
        
        if dealType == 0 || dealType == 1{
            return rcNum * handNum
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
}


class AinRC {
    var rcSingleFeature = [SingleFeature]()
    var evaluateFlag = 0
    var singlefeaturesType: String = ""
    var singlefeaturesSuit: String = ""
    var isPair: Int = 0
    
    func insertSingleFeature(singlefeature: SingleFeature) {
        rcSingleFeature.append(singlefeature)
    }
}

class AinDataset {
//    #args
//    #0 rcNum
//    #1 isCompareSuit 0/1
//    #2 isAceStraight 0/1
//    #3 minRank 2-9
//    #4 handNum 1-5
//    #5 communityNum 0/3/5
//    #6 handUseType 0无限制/1必须/2至少
//    #7 handUseNum 1-5
    static func calResult(diyDealStatus:[[Bool]], diyDealNum:[Int], singlefeatureArray: [Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        var FeatureList = initFeatureList(initialSingleFeatures: singlefeatureArray, suitRules: suitRules)
            let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: &FeatureList, args: args, rankRules: rankRules)
            return (winners, leftSingleFeatures)
        }
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: inout [SingleFeature], args: [Int], rankRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let rule = ClassifierSettingArgs.targetSetting[17] as! AinRule
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let isCompareSuit = args[5] == 1
        let isAceStraight = args[6] == 1
        let minRank = rule.minRank[args[7]]
        let handUseType = args[8]
        let handUseNum = rule.handUseNum[args[9]]
        
        var returnRCInfos: [DatasetReturnRCInfo] = []

        var allPlaySingleFeatures = [AinRC]()
        var community = [SingleFeature]()
        if FeatureList.count < TP.getMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            return ([],[])
        }
        
        
        for _ in 0..<rcNum {
            allPlaySingleFeatures.append(AinRC())
        }
        
        // 发牌
        //反发倒过来
        if dealType == 1 {
            FeatureList = FeatureList.reversed()
        }
        // 每轮发一张
        if  dealNum == 0{

            for _ in 0..<handNum {
                for i in 0..<rcNum {
                    allPlaySingleFeatures[i].insertSingleFeature(singlefeature: FeatureList.removeFirst())
                }
            }
//            if communityNum == 3 {
//                FeatureList.removeFirst()
//                for _ in 0..<3 {
//                    community.append(FeatureList.removeFirst())
//                }
//            } else if communityNum == 5 {
//                FeatureList.removeFirst()
//                for _ in 0..<3 {
//                    community.append(FeatureList.removeFirst())
//                }
//                for _ in 0..<2 {
//                    FeatureList.removeFirst()
//                    community.append(FeatureList.removeFirst())
//                }
//            }
        }
        // 自定义发牌 dealNum = 2
        else {
            for actionIndex in 0...diyDealStatus.count - 1{
                let singlefeatureNum = diyDealNum[actionIndex]
                let action = diyDealStatus[actionIndex]
                //派牌
                if action[0] == true{
                    for i in 0..<rcNum {
                        for _ in 0..<singlefeatureNum{
                            allPlaySingleFeatures[i].insertSingleFeature(singlefeature: FeatureList.removeFirst())
                        }
                    }
                //公牌
                } else if action[1] == true {
                    for _ in 0..<singlefeatureNum{
                        community.append(FeatureList.removeFirst())
                    }
                //去牌
                } else if action[2] == true {
                    for _ in 0..<singlefeatureNum{
                        FeatureList.removeFirst()
                    }
                }
            }
        }
        if dealType == 1 {
            FeatureList = FeatureList.reversed()
        }
        
        for i in 0..<rcNum {
            
            (allPlaySingleFeatures[i].evaluateFlag, allPlaySingleFeatures[i].singlefeaturesType) = AinHandAnalyst.evalHand(singlefeatures: allPlaySingleFeatures[i].rcSingleFeature, community: community, isCompareSuit: isCompareSuit, isAceStraight: isAceStraight, minRank: minRank, handUseType: handUseType, handUseNum: handUseNum, rankRules: rankRules)
        }
        
        for rcID in 0..<allPlaySingleFeatures.count {
            var currentReturnRCInfo = DatasetReturnRCInfo()
            currentReturnRCInfo.rcID = rcID
            currentReturnRCInfo.rcRank = allPlaySingleFeatures[rcID].evaluateFlag
            currentReturnRCInfo.rcSingleFeaturesType = allPlaySingleFeatures[rcID].singlefeaturesType
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
        
        if leftSingleFeatures.count < TP.getMinSingleFeatureNum(rcNum: rcNum, handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        
        return (returnRCInfos, leftSingleFeatures)
    }
}

class AinHandAnalyst {
    
    static func evalHand(singlefeatures: [SingleFeature], community: [SingleFeature], isCompareSuit: Bool, isAceStraight: Bool, minRank: Int, handUseType: Int, handUseNum: Int, rankRules: [Int]) -> (Int, String) {
        let suitRules :[Int] = [3,2,1,0]

        var handSingleFeaturesString:String = ""
        for handSingleFeature in singlefeatures{
            handSingleFeaturesString += ClassifierSettingArgs.singlefeatureLabelDic[handSingleFeature.rank
                                                               - 1 + suitRules[handSingleFeature.suit[0]]*13]!
        }
        var communitySingleFeaturesString: String = ""
        for communitySingleFeature in community{
            communitySingleFeaturesString += ClassifierSettingArgs.singlefeatureLabelDic[communitySingleFeature.rank - 1 + suitRules[communitySingleFeature.suit[0]] * 13]!
        }
        
        let (singlefeaturesLength, allSortedSingleFeatures) = sortSingleFeatures(singlefeatures: singlefeatures, community: community, handUseType: handUseType, handUseNum: handUseNum, isAceStraight: isAceStraight, minRank: minRank)
        var sortedString:String = ""
        for sortedsinglefeature in allSortedSingleFeatures[0]{
            sortedString += ClassifierSettingArgs.singlefeatureLabelDic[sortedsinglefeature.singlefeatureIndex]!
        }
        
        var maxScore = 0
        var maxSingleFeatureType: String = ""
        for sortedSingleFeatures in allSortedSingleFeatures {
            let (score, singlefeatureType) = calcHandInfoFlg(sortedSingleFeatures: sortedSingleFeatures, isCompareSuit: isCompareSuit, rankRules: rankRules, singlefeaturesLength: singlefeaturesLength)
            if score > maxScore {
                maxScore = score
                maxSingleFeatureType = singlefeatureType
            }
        }
        return (maxScore, maxSingleFeatureType)
    }
    
    static func sortSingleFeatures(singlefeatures: [SingleFeature], community: [SingleFeature], handUseType: Int, handUseNum: Int, isAceStraight: Bool, minRank: Int) -> (Int, [[SingleFeature]]) {
        var allSingleFeatures = [[SingleFeature]]()
        var singlefeaturesLength = 0
        var singlefeatureCopy:[SingleFeature] = []
        var communityCopy:[SingleFeature] = []
        for singlefeature in singlefeatures {
            let copy:SingleFeature = SingleFeature(suit: singlefeature.suit, rank: singlefeature.rank, singlefeatureIndex: singlefeature.singlefeatureIndex)
            if copy.rank == 1 {
                copy.rank = 14
            }
            singlefeatureCopy.append(copy)
        }
        
        for singlefeature in community {
            let copy:SingleFeature = SingleFeature(suit: singlefeature.suit, rank: singlefeature.rank, singlefeatureIndex: singlefeature.singlefeatureIndex)

            if copy.rank == 1 {
                copy.rank = 14
            }
            communityCopy.append(copy)
        }
        
        if handUseType == 0 {
            allSingleFeatures.append(singlefeatureCopy + communityCopy)
            singlefeaturesLength = singlefeatureCopy.count + communityCopy.count
        } else if handUseType == 1 {
            singlefeaturesLength = 5
            let communityNum = 5 - handUseNum
            let handCombinations = singlefeatureCopy.combinations(ofCount: handUseNum)
            let communityCombinations = communityCopy.combinations(ofCount: communityNum)
            
            for handCombination in handCombinations {
                if communityNum != 0 {
                    for communityCombination in communityCombinations {
                        allSingleFeatures.append(handCombination + communityCombination)
                    }
                } else {
                    allSingleFeatures.append(handCombination)
                }
            }
        } else if handUseType == 2 {
            singlefeaturesLength = 5
            for handNum in 1...handUseNum {
                let communityNum = 5 - handNum
                let handCombinations = singlefeatureCopy.combinations(ofCount: handNum)
                let communityCombinations = communityCopy.combinations(ofCount: communityNum)
                
                for handCombination in handCombinations {
                    if communityNum != 0 {
                        for communityCombination in communityCombinations {
                            allSingleFeatures.append(handCombination + communityCombination)
                        }
                    } else {
                        allSingleFeatures.append(handCombination)
                    }
                }
            }
        }
        var returnAllSingleFeatures = [[SingleFeature]]()
        
        for var singlefeaturesList in allSingleFeatures {
            if isAceStraight {
                var aceSingleFeatures = [SingleFeature]()
                for singlefeature in singlefeaturesList {
                    if singlefeature.rank == 14 {
                        aceSingleFeatures.append(SingleFeature(suit: singlefeature.suit, rank: minRank - 1, singlefeatureIndex: singlefeature.singlefeatureIndex))
                    }
                }
                singlefeaturesList += aceSingleFeatures
            }
            singlefeaturesList.sort(by: { singlefeature1, singlefeature2 in
                return SingleFeature.calScore(singlefeature: singlefeature1) > SingleFeature.calScore(singlefeature: singlefeature2)
            })
            returnAllSingleFeatures.append(singlefeaturesList)
        }
        
        return (singlefeaturesLength, returnAllSingleFeatures)
    }
    
    static func calcHandInfoFlg(sortedSingleFeatures: [SingleFeature], isCompareSuit: Bool, rankRules: [Int], singlefeaturesLength: Int) -> (Int, String) {
        let ruleDict: [Int: ([SingleFeature], Int) -> Int] = [
            0: evalHoleSingleFeature,
            1: evalOnePair,
            2: evalTwoPair,
            3: evalThreeFlush,
            4: evalThreeStraight,
            5: evalThreeStraightFlush,
            6: evalThreeSingleFeature,
            7: evalStraight,
            8: evalFlush,
            9: evalFullHouse,
            10: evalFourSingleFeature,
            11: evalStraightFlush
        ]
        
        var rankResult = 0
        var singlefeatureType: String = ""
        let rule = ClassifierSettingArgs.targetSetting[17] as! AinRule
        for (index, ruleIndex) in rankRules.enumerated() {
            let rankFlag = 1 << (rankRules.count - index + 23)
            rankResult = ruleDict[ruleIndex]!(sortedSingleFeatures, singlefeaturesLength)
            if !isCompareSuit {
                rankResult >>= 2
            }
            if rankResult != 0 {
                rankResult |= rankFlag
                singlefeatureType = rule.rankRules[ruleIndex]!
                break
            }
        }
        return (rankResult, singlefeatureType)
    }
    
    
    static func evalStraightFlush(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
        var rank = 0
        for suit in [3, 2, 1, 0] {
            var rankList = [Int]()
            var cnt = 1
            var straightHeadRank = 0
            
            for i in 0..<singlefeatures.count {
                if singlefeatures[i].suit[0]  == suit {
                    rankList.append(singlefeatures[i].rank)
                }
            }
            
            if rankList.count == 0{
                continue
            }
            
            for i in 0..<rankList.count - 1 {
                if rankList[i] - rankList[i+1] == 1 {
                    cnt += 1
                    if straightHeadRank == 0 {
                        straightHeadRank = rankList[i]
                    }
                    if cnt == 5 {
                        rank = straightHeadRank
                        break
                    }
                } else {
                    cnt = 1
                    straightHeadRank = 0
                }
            }
            
            if rank != 0 {
                rank = rank << 2 | suit
                break
            }
        }
        
        return rank
    }
        
    static func evalFourSingleFeature(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            for i in 0...(singlefeaturesLength - 4) {
                var isFourSingleFeature = true
                for j in 1...3 {
                    if singlefeatures[i + j].rank != singlefeatures[i].rank {
                        isFourSingleFeature = false
                        break
                    }
                }
                if isFourSingleFeature {
                    rank = singlefeatures[i].rank << 4
                    if i == 0 {
                        rank = rank | singlefeatures[4].rank
                    } else {
                        rank = rank | singlefeatures[0].rank
                    }
                    rank = rank << 2
                    break
                }
            }
            return rank
        }
        
        static func evalFullHouse(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            var threeSingleFeatureRank = 0
            var pairRank = 0
            for i in 0...(singlefeaturesLength - 3) {
                if singlefeatures[i].rank == singlefeatures[i+1].rank && singlefeatures[i].rank == singlefeatures[i+2].rank {
                    threeSingleFeatureRank = singlefeatures[i].rank
                    break
                }
            }
            if threeSingleFeatureRank != 0 {
                for i in 0...(singlefeaturesLength - 2) {
                    if singlefeatures[i].rank == singlefeatures[i+1].rank && singlefeatures[i].rank != threeSingleFeatureRank {
                        pairRank = singlefeatures[i].rank
                        break
                    }
                }
            }
            if threeSingleFeatureRank != 0 && pairRank != 0 {
                rank = threeSingleFeatureRank << 4 | pairRank
                rank = rank << 2
            }
            return rank
        }
    
    
    static func evalFlush(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            for suit in [3, 2, 1, 0] {
                var cnt = 0
                for i in 0..<singlefeaturesLength {
                    if singlefeatures[i].suit[0] == suit && cnt < 5 {
                        cnt += 1
                        rank = rank << 4 | singlefeatures[i].rank
                    }
                }
                if cnt == 5 {
                    rank = rank << 2 | suit
                    break
                } else {
                    rank = 0
                }
            }
            return rank
        }
        
        static func evalStraight(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            var cnt = 1
            var straightHeadRank = 0
            
            
            
            for i in 0..<(singlefeatures.count - 1)  {
                if singlefeatures[i].rank - singlefeatures[i+1].rank == 1 {
                    cnt += 1
                    if straightHeadRank == 0 {
                        straightHeadRank = singlefeatures[i].rank
                    }
                    if cnt == 5 {
                        rank = straightHeadRank
                        break
                    }
                } else if singlefeatures[i].rank != singlefeatures[i+1].rank {
                    cnt = 1
                    straightHeadRank = 0
                }
            }
            if rank != 0 {
                for singlefeature in singlefeatures {
                    if singlefeature.rank == rank {
                        rank = rank << 2 | (singlefeature.suit[0])
                        break
                    }
                }
            }
            return rank
        }
        
        static func evalThreeSingleFeature(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            var threeSingleFeatureRank = 0
            var highSingleFeatureRank1 = 0
            var highSingleFeatureRank2 = 0
            var threeSingleFeatureSuit = 0
            for i in 0..<(singlefeaturesLength - 2) {
                if singlefeatures[i].rank == singlefeatures[i+1].rank && singlefeatures[i].rank == singlefeatures[i+2].rank {
                    threeSingleFeatureRank = singlefeatures[i].rank
                    threeSingleFeatureSuit = singlefeatures[i].suit[0]
                    break
                }
            }
            if threeSingleFeatureRank != 0 {
                for i in 0..<singlefeaturesLength {
                    if singlefeatures[i].rank != threeSingleFeatureRank {
                        highSingleFeatureRank1 = singlefeatures[i].rank
                        break
                    }
                }
                for i in 0..<singlefeaturesLength {
                    if singlefeatures[i].rank != threeSingleFeatureRank && singlefeatures[i].rank != highSingleFeatureRank1 {
                        highSingleFeatureRank2 = singlefeatures[i].rank
                        break
                    }
                }
                rank = threeSingleFeatureRank << 8 | highSingleFeatureRank1 << 4 | highSingleFeatureRank2
                rank = rank << 2 | threeSingleFeatureSuit
            }
            return rank
        }
    
    static func evalThreeStraightFlush(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            for suit in [3, 2, 1, 0] {
                var singlefeatureList: [SingleFeature] = []
                var cnt = 1
                var straightHeadRank = 0
                for singlefeature in singlefeatures {
                    if singlefeature.suit[0] == suit {
                        singlefeatureList.append(singlefeature)
                    }
                }
                if singlefeatureList.count < 3{
                    continue
                }
                for i in 0..<(singlefeatureList.count - 1) {
                    if singlefeatureList[i].rank - singlefeatureList[i+1].rank == 1 {
                        cnt += 1
                        if straightHeadRank == 0 {
                            straightHeadRank = singlefeatureList[i].rank
                        }
                        if cnt == 3 {
                            rank = straightHeadRank
                            singlefeatureList = Array(singlefeatureList[i - 1...i + 2])
                            break
                        }
                    } else {
                        cnt = 1
                        straightHeadRank = 0
                    }
                }
                if rank != 0 {
                    var highSingleFeatureCnt = 0
                    for singlefeature in singlefeatures {
                        if !singlefeatureList.contains(where: { $0 as! AnyHashable == singlefeature as! AnyHashable }){
                            rank = rank << 4 | singlefeature.rank
                            highSingleFeatureCnt += 1
                        }
                        if highSingleFeatureCnt == 2 {
                            break
                        }
                    }
                    rank = rank << 2 | suit
                    break
                }
            }
            return rank
        }
        
        static func evalThreeStraight(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            var cnt = 1
            var straightHeadRank = 0
            var singlefeatureList: [SingleFeature] = [singlefeatures[0]]
            for i in 0..<(singlefeatures.count - 1) {
                if singlefeatures[i].rank - singlefeatures[i+1].rank == 1 {
                    cnt += 1
                    singlefeatureList.append(singlefeatures[i + 1])
                    if straightHeadRank == 0 {
                        straightHeadRank = singlefeatures[i].rank
                    }
                    if cnt == 3 {
                        rank = straightHeadRank
                        break
                    }
                } else if singlefeatures[i].rank != singlefeatures[i+1].rank {
                    cnt = 1
                    singlefeatureList = [singlefeatures[i]]
                    straightHeadRank = 0
                }
            }
            if rank != 0 {
                var highSingleFeatureCnt = 0
                for singlefeature in singlefeatures {
                    if !singlefeatureList.contains(where: { $0 as! AnyHashable == singlefeature as! AnyHashable }) {
                        rank = rank << 4 | singlefeature.rank
                        highSingleFeatureCnt += 1
                    }
                    if highSingleFeatureCnt == 2 {
                        break
                    }
                }
                for singlefeature in singlefeatures {
                    if singlefeature.rank == rank {
                        rank = rank << 2 | (singlefeature.suit[0])
                        break
                    }
                }
            }
            return rank
        }
        
        static func evalThreeFlush(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            var singlefeatureList: [SingleFeature] = []
            for suit in [3, 2, 1, 0] {
                var cnt = 0
                for i in 0..<singlefeaturesLength {
                    if singlefeatures[i].suit[0] == suit && cnt < 3 {
                        cnt += 1
                        singlefeatureList.append(singlefeatures[i])
                        rank = rank << 4 | singlefeatures[i].rank
                    }
                }
                if cnt == 3 {
                    var highSingleFeatureCnt = 0
                    for singlefeature in singlefeatures {
                        if !singlefeatureList.contains(where: { $0 as! AnyHashable == singlefeature as! AnyHashable }) {
                            rank = rank << 4 | singlefeature.rank
                            highSingleFeatureCnt += 1
                        }
                        if highSingleFeatureCnt == 2 {
                            break
                        }
                    }
                    rank = rank << 2 | suit
                    break
                } else {
                    rank = 0
                    singlefeatureList = []
                }
            }
            return rank
        }
        
        static func evalTwoPair(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            var firstPairRank = 0
            var secondPairRank = 0
            var highSingleFeatureRank = 0
            var firstPairSuit = 0
            for i in 0..<(singlefeaturesLength - 1) {
                if singlefeatures[i].rank == singlefeatures[i+1].rank {
                    if firstPairRank == 0 {
                        firstPairRank = singlefeatures[i].rank
                        firstPairSuit = singlefeatures[i].suit[0]
                    } else {
                        secondPairRank = singlefeatures[i].rank
                        break
                    }
                }
            }
            if firstPairRank != 0 && secondPairRank != 0 {
                for i in 0..<singlefeaturesLength {
                    if singlefeatures[i].rank != firstPairRank && singlefeatures[i].rank != secondPairRank {
                        highSingleFeatureRank = singlefeatures[i].rank
                        break
                    }
                }
                rank = firstPairRank << 8 | secondPairRank << 4 | highSingleFeatureRank
                rank = rank << 2 | firstPairSuit
            }
            return rank
        }
    
    static func evalOnePair(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            var pairRank = 0
            var pairSuit = 0
            var rankList: [Int] = []
            for i in 0..<(singlefeaturesLength - 1) {
                if singlefeatures[i].rank == singlefeatures[i + 1].rank {
                    pairRank = singlefeatures[i].rank
                    pairSuit = singlefeatures[i].suit[0]
                    rankList.append(pairRank)
                    break
                }
            }
            if pairRank != 0 {
                for _ in 0..<3 {
                    for i in 0..<singlefeaturesLength {
                        if !rankList.contains(singlefeatures[i].rank) {
                            rankList.append(singlefeatures[i].rank)
                            break
                        }
                    }
                }
                for rank_ in rankList {
                    rank = rank << 4 | rank_
                }
                rank = rank << 2 | pairSuit
            }
            return rank
        }
        
        static func evalHoleSingleFeature(singlefeatures: [SingleFeature], singlefeaturesLength: Int) -> Int {
            var rank = 0
            for i in 0..<5 {
                rank = rank << 4 | singlefeatures[i].rank
            }
            rank = rank << 2 | (singlefeatures[0].suit[0])
            return rank
        }
}
