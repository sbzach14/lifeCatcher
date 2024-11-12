
import Foundation


class CBDatasetRule : Rule{
    
    //此处填入需要的参数，因为rulesettingview没有了，主要作用是注释
    let winCondition:[Int:String] = [
        0:"比尾墩",
        1:"比道数",
        2:"比积分"
    ]
    
    let AStraightMin:[Int:String] = [
        0:"A23第二大",
        1:"A23最小",
    ]
    
    let specialfeatureChangeSetting:[Int:String] = [
        0:"王百变",
        1:"大王红牌 小王黑牌",
        2:"大王红6 小王黑3",
    ]
    
    let specialfeatureThreeSingleFeatureSetting:[Int:String] = [
        0:"王不能当三头",
        1:"王能当三头"
    ]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            5: "豹子",
            4: "顺金",
            3: "金花",
            2: "顺子",
            1: "对子",
            0: "单牌"
        ]
        self.setting = [
            0: "比鸡比道数[902]",
            1: "比鸡百变尾墩大[903]",
            2: "比鸡百变尾墩大4[904]",
            3: "比鸡百变尾墩大5[905]",
            4: "比鸡百变尾墩大2[906]",
            5: "比鸡9张金花[907]",
            6: "比鸡比道数A23[908]",
            7: "比鸡9张金花A23[909]",
            8: "比鸡9张百变金花[910]",
            9: "比鸡9张百变金花A23[911]",
            10: "比鸡百变尾墩大[912]",
        ]
        self.ruleInfo = [
            0: """
牌数:52张，不包括大小王
每人9张牌，分为3组，每组3张。3组分别比大小。
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌.花色不全相同的相连3张牌.AKQ>JQK>...>234 > A23
5)对子:
6)散牌:A最大2最小
""",
            1:"""
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大王代替红桃和方片，小王代替黑头和梅花，大小王不能当四个头三个头，只能当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            2: """
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大小王任意变，大小王不能当四个头三个头，只能当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            3:"""
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大小王任意变4花色，大小王能当四个头三个头，当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6) 散牌:A最大2最小
""",
            4: """
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大王代替红桃和方片，小王代替黑头和梅花，大小王能当四个头三个头，能当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            5:"""
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大王代替红桃和方片，小王代替黑头和梅花，大小王能当四个头三个头，能当顺金，顺子，对子，(搭配)
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            6: """
牌数:52张，不包括大小王
每人9张牌，分为3组，每组3张。3组分别比大小。
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌. AKQ > A23>JQK>...>234
5)对子:
6)散牌:A最大2最小
""",
            7:"""
牌数:52，不包括大小王
每人9张，分为三组，每组3张。3组分别比大小。单组最大为1分，单组不是最大为0分，三组积分最多为最大。
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:QKA> A23>JQK...>234
5)对子:
6)散牌:A最大2最小
""",
            8: """
牌数:54
每人9张，分为三组，每组3张。3组分别比大小。单组最大为1分，单组不是最大为0分，三组积分最多为最大。大王可变任意红牌。小王可变任意黑牌
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小
""",
            9:"""
牌数:54
每人9张，分为三组，每组3张。3组分别比大小。单组最大为1分，单组不是最大为0分，三组积分最多为最大。大王可变任意红牌。小王可变任意黑牌
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:QKA > A23>JQK...>234
5)对子:
6)散牌:A最大2最小
""",
            10: """
牌数:54张
每人9张牌，分为3组，每组3张。确保第3组最大。大王代替红桃6和方片6，小王代替黑桃3和梅花3
1)豹子:3张同样大小的牌
2)顺金:花色相同的顺子
3)金花:花色相同的牌
4)顺子:花色不全相同的相连3张牌
5)对子:
6)散牌:A最大2最小

(
""",
        ]
        self.rcNum = [2,3,4,5,6]

    }
}


class CBDataset{
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        
        let FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int, setting: Int) -> String{
        var errMessage : String = ""
        if(rcNum * 9 > getAllSingleFeatureIndex(setting: setting).count)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    //加入每个规则需要的用牌
    static func getAllSingleFeatureIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 0:
            result = Array(0...51)
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
        case 6:
            result = Array(0...51)
            break
        case 7:
            result = Array(0...51)
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
    //3 handNum
    //4 communityNum
    //5 winCondition
    //6 AStraightMin
    //7 specialfeatureChangeSetting
    //8 specialfeatureThreeSingleFeatureSetting

    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let winCondition = args[5]
        let AStraightMin = args[6]
        let specialfeatureChangeSetting = args[7]
        let specialfeatureThreeSingleFeatureSetting = args[8]
        
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
        
        
        var rcRankList : [[Int]] = []
        
        for i in 0..<rcNum {
            
            var turn1SingleFeatures:[CBDatasetSingleFeature] = []
            for singlefeature in allPlaySingleFeatures[i].rcSingleFeature {
                turn1SingleFeatures.append(CBDatasetSingleFeature(singlefeature: singlefeature, specialfeatureChangeSetting: specialfeatureChangeSetting))
            }
            turn1SingleFeatures = turn1SingleFeatures.sorted(by: {$0.rank > $1.rank})
            
            let (rank1, singlefeaturetype1, isPair1, usedSingleFeatureIndex1) = CBDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                specialfeatureThreeSingleFeatureSetting: specialfeatureThreeSingleFeatureSetting
            ).evalHand(singlefeatures: turn1SingleFeatures)
            
            allPlaySingleFeatures[i].evaluateFlag = rank1
            allPlaySingleFeatures[i].singlefeatureType = singlefeaturetype1
            allPlaySingleFeatures[i].isPair = isPair1
                
            var turn2SingleFeatures:[CBDatasetSingleFeature] = []
            for singlefeatureIndex in 0..<turn1SingleFeatures.count {
                if !usedSingleFeatureIndex1.contains(singlefeatureIndex){
                    turn2SingleFeatures.append(turn1SingleFeatures[singlefeatureIndex])
                }
            }
            
            let (rank2, singlefeaturetype2, isPair2, usedSingleFeatureIndex2) = CBDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                specialfeatureThreeSingleFeatureSetting: specialfeatureThreeSingleFeatureSetting
            ).evalHand(singlefeatures: turn2SingleFeatures)
            
            var turn3SingleFeatures:[CBDatasetSingleFeature] = []
            for singlefeatureIndex in 0..<turn2SingleFeatures.count {
                if !usedSingleFeatureIndex2.contains(singlefeatureIndex){
                    turn3SingleFeatures.append(turn2SingleFeatures[singlefeatureIndex])
                }
            }
                    
            let (rank3, singlefeaturetype3, isPair3, usedSingleFeatureIndex3) = CBDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                specialfeatureThreeSingleFeatureSetting: specialfeatureThreeSingleFeatureSetting
            ).evalHand(singlefeatures: turn3SingleFeatures)
            
            rcRankList.append([rank1, rank2, rank3])
        }
        
        //尾墩
        if winCondition == 0{
            
        }
        //道数
        else if winCondition == 1{
            for i in 0..<rcNum {
                allPlaySingleFeatures[i].evaluateFlag = 0
            }
            for currentRC in 0..<rcNum {
                for i in 0..<rcNum{
                    if currentRC != i{
                        for turn in 0..<3{
                            if rcRankList[currentRC][turn] > rcRankList[i][turn]{
                                allPlaySingleFeatures[currentRC].evaluateFlag += 1
                            }
                            else if rcRankList[currentRC][turn] < rcRankList[i][turn]{
                                allPlaySingleFeatures[currentRC].evaluateFlag -= 1
                            }
                        }
                    }
                }
            }
        }
        //积分
        else if winCondition == 2{
            
            for i in 0..<rcNum {
                allPlaySingleFeatures[i].evaluateFlag = 0
            }
            
            for turn in 0..<3{
                
                var maxRC = 0
                var maxRank = 0
                
                for i in 0..<rcNum {
                    let currentRank = rcRankList[i][turn]
                    if currentRank > maxRank{
                        maxRank = currentRank
                        maxRC = i
                    }
                }
                
                allPlaySingleFeatures[maxRC].evaluateFlag += 1
            }
        }
        
        
        //这里后面都不用改，最后按照牌的大小（evaluateflag）排序返回
        
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
        if leftSingleFeatures.count < CBDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        return (returnRCInfos, leftSingleFeatures)
    }
    
    
    static func sortSingleFeatures(originSingleFeatures: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> [SingleFeature]{
        let AStraightMin = args[6]
        let specialfeatureChangeSetting = args[7]
        let specialfeatureThreeSingleFeatureSetting = args[8]
        
        var sortSingleFeatures : [[SingleFeature]] = [[],[],[],[]]
        
        var turn1SingleFeatures:[CBDatasetSingleFeature] = []
        
        for singlefeature in originSingleFeatures {
            turn1SingleFeatures.append(CBDatasetSingleFeature(singlefeature: singlefeature, specialfeatureChangeSetting: specialfeatureChangeSetting))
        }
        turn1SingleFeatures = turn1SingleFeatures.sorted(by: {$0.rank > $1.rank})
        
        let (rank1, singlefeaturetype1, isPair1, usedSingleFeatureIndex1) = CBDatasetHandAnalyst(
            rankRules: rankRules,
            suitRules: suitRules,
            AStraightMin: AStraightMin,
            specialfeatureThreeSingleFeatureSetting: specialfeatureThreeSingleFeatureSetting
        ).evalHand(singlefeatures: turn1SingleFeatures)
        
        var turn2SingleFeatures:[CBDatasetSingleFeature] = []
        for singlefeatureIndex in 0..<turn1SingleFeatures.count {
            if !usedSingleFeatureIndex1.contains(singlefeatureIndex){
                turn2SingleFeatures.append(turn1SingleFeatures[singlefeatureIndex])
            }
            else{
                sortSingleFeatures[0].append(SingleFeature(suit: [turn1SingleFeatures[singlefeatureIndex].originRank], rank: 0, singlefeatureIndex: turn1SingleFeatures[singlefeatureIndex].singleFeatureIndex))
            }
        }
            
        let (rank2, singlefeaturetype2, isPair2, usedSingleFeatureIndex2) = CBDatasetHandAnalyst(
            rankRules: rankRules,
            suitRules: suitRules,
            AStraightMin: AStraightMin,
            specialfeatureThreeSingleFeatureSetting: specialfeatureThreeSingleFeatureSetting
        ).evalHand(singlefeatures: turn2SingleFeatures)
            
                
        var turn3SingleFeatures:[CBDatasetSingleFeature] = []
        for singlefeatureIndex in 0..<turn2SingleFeatures.count {
            if !usedSingleFeatureIndex2.contains(singlefeatureIndex){
                turn3SingleFeatures.append(turn2SingleFeatures[singlefeatureIndex])
            }
            else{
                sortSingleFeatures[1].append(SingleFeature(suit: [turn2SingleFeatures[singlefeatureIndex].originRank], rank: 0, singlefeatureIndex: turn2SingleFeatures[singlefeatureIndex].singleFeatureIndex))
            }
        }
        
        let (rank3, singlefeaturetype3, isPair3, usedSingleFeatureIndex3) = CBDatasetHandAnalyst(
            rankRules: rankRules,
            suitRules: suitRules,
            AStraightMin: AStraightMin,
            specialfeatureThreeSingleFeatureSetting: specialfeatureThreeSingleFeatureSetting
        ).evalHand(singlefeatures: turn3SingleFeatures)
        
        
        for singlefeatureIndex in 0..<turn3SingleFeatures.count {
            if !usedSingleFeatureIndex3.contains(singlefeatureIndex){
                sortSingleFeatures[3].append(SingleFeature(suit: [turn3SingleFeatures[singlefeatureIndex].originRank], rank: 0, singlefeatureIndex: turn3SingleFeatures[singlefeatureIndex].singleFeatureIndex))
            }
            else{
                sortSingleFeatures[2].append(SingleFeature(suit: [turn3SingleFeatures[singlefeatureIndex].originRank], rank: 0, singlefeatureIndex: turn3SingleFeatures[singlefeatureIndex].singleFeatureIndex))
            }
        }
        
        var result: [SingleFeature] = []
        for i in 0..<3{
            if i < sortSingleFeatures[0].count{
                result.append(sortSingleFeatures[0][i])
            }
            else{
                result.append(sortSingleFeatures[3].removeFirst())
            }
        }
        for i in 0..<3{
            if i < sortSingleFeatures[1].count{
                result.append(sortSingleFeatures[1][i])
            }
            else{
                result.append(sortSingleFeatures[3].removeFirst())
            }
        }
        for i in 0..<3{
            if i < sortSingleFeatures[2].count{
                result.append(sortSingleFeatures[2][i])
            }
            else{
                result.append(sortSingleFeatures[3].removeFirst())
            }
        }
        
        return result
    }
}

class CBDatasetHandAnalyst{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([CBDatasetSingleFeature]) -> ([Int], [String], Int, [[Int]])] = [:]
    var AStraightMin: Int
    var specialfeatureThreeSingleFeatureSetting: Int
        
    init(rankRules: [Int],
         suitRules: [Int],
         AStraightMin: Int,
         specialfeatureThreeSingleFeatureSetting: Int){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.AStraightMin = AStraightMin
        self.specialfeatureThreeSingleFeatureSetting = specialfeatureThreeSingleFeatureSetting
        
        self.ruleDict = [
            0:self.eval_holesinglefeature(singlefeatures:),
            1:self.eval_onepair(singlefeatures:),
            2:self.eval_straight(singlefeatures:),
            3:self.eval_flush(singlefeatures:),
            4:self.eval_straightflush(singlefeatures:),
            5:self.eval_threesinglefeature(singlefeatures:)
        ]
    }
    
    //传入需要的参数
    func evalHand(singlefeatures: [CBDatasetSingleFeature])->(Int, String, Int, [Int]){
        
        var rank:Int = 0
        var singlefeatureType:String = ""
        var isPair:Int = 0
        var usedSingleFeatureIndex:[Int] = []
        
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            let (rankList, singlefeatureTypeList, isPair, usedSingleFeatureIndexList) = self.ruleDict[ruleIndex]!(singlefeatures)
            i -= 1
            
            if rankList.count == 0{
                continue
            }
            else {
                let maxIndex = rankList.firstIndex(of: rankList.max() ?? 0)!
                
                rank = (1 << (i + 15)) | rankList[maxIndex]
                singlefeatureType = singlefeatureTypeList[maxIndex]
                usedSingleFeatureIndex = usedSingleFeatureIndexList[maxIndex]
                
                break
            }
        }

        return (rank, singlefeatureType, isPair, usedSingleFeatureIndex)
    }
    
    //牌型函数
    
    func eval_threesinglefeature(singlefeatures: [CBDatasetSingleFeature]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        if self.specialfeatureThreeSingleFeatureSetting == 1{
            if singlefeatures[0].rank == 15 && singlefeatures[1].rank == 15{
                for i in 2..<singlefeatures.count{
                    usedSingleFeatureIndexList.append([0,1,i])
                }
            }
            else if singlefeatures[0].rank == 15{
                for i in 1..<singlefeatures.count-1{
                    if singlefeatures[i].rank == singlefeatures[i+1].rank{
                        usedSingleFeatureIndexList.append([0,i,i+1])
                    }
                }
            }
            else {
                for i in 0..<singlefeatures.count-2{
                    if singlefeatures[i].rank == singlefeatures[i+1].rank && singlefeatures[i].rank == singlefeatures[i+2].rank{
                        usedSingleFeatureIndexList.append([i,i+1,i+2])
                    }
                }
            }
        }
        else{
            for i in 0..<singlefeatures.count-2{
                if singlefeatures[i].originRank == singlefeatures[i+1].originRank && singlefeatures[i].originRank == singlefeatures[i+2].originRank{
                    usedSingleFeatureIndexList.append([i,i+1,i+2])
                }
            }
        }

        if usedSingleFeatureIndexList.count > 0 {
            
            for currentUsedSingleFeatureIndex in usedSingleFeatureIndexList{
                var rank = 0
                
                var threeSingleFeatureRank = singlefeatures[currentUsedSingleFeatureIndex[2]].rank
                var threeSingleFeatureSuit = singlefeatures[currentUsedSingleFeatureIndex[0]].rank
                
                if threeSingleFeatureSuit == -1{
                    threeSingleFeatureSuit = 0
                }
                
                rank = rank << 4 | threeSingleFeatureRank
                rank = rank << 2 | threeSingleFeatureSuit
                
//                let singlefeatureType = "豹子" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[currentUsedSingleFeatureIndex[2]].originRank]!
                let singlefeatureType = "豹子"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
        }
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    
    func eval_straightflush(singlefeatures: [CBDatasetSingleFeature]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        let (straightRankList, straightSingleFeatureTypeList, _, straightUsedSingleFeatureIndexList) = eval_straight(singlefeatures: singlefeatures)
        
        if straightRankList.count > 0 {
            
            for i in 0..<straightUsedSingleFeatureIndexList.count{
                let currentStraightUsedSingleFeatureIndex = straightUsedSingleFeatureIndexList[i]
                
                var suit = 3
                for c in currentStraightUsedSingleFeatureIndex {
                    if singlefeatures[c].suit >= 0{
                        suit = singlefeatures[c].suit
                        break
                    }
                }
                
                var isFlush : Bool = true
                for currentSingleFeatureIndex in currentStraightUsedSingleFeatureIndex{
                    let currentSingleFeatureSuit = singlefeatures[currentSingleFeatureIndex].suit
                    
                    if currentSingleFeatureSuit == -1
                        || currentSingleFeatureSuit == suit
                        || (currentSingleFeatureSuit == -2 && (suit == 0 || suit == 2))
                        || (currentSingleFeatureSuit == -3 && (suit == 1 || suit == 3)){
                        continue
                    }
                    else{
                        isFlush = false
                        break
                    }
                }
                
                if isFlush{
                    usedSingleFeatureIndexList.append(currentStraightUsedSingleFeatureIndex)
                    
                    var rank = straightRankList[i] >> 2
                    
//                    let singlefeatureType = "顺金" + String(rank)
//                    rank = rank << 2 | suit
                    let singlefeatureType = "顺金"
                    
                    rankList.append(rank)
                    singlefeatureTypeList.append(singlefeatureType)
                }
            }
        }
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    
    func eval_flush(singlefeatures: [CBDatasetSingleFeature]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        
        for suit in 0..<4{
            var suitSingleFeatures : [Int] = []
            for i in 0..<singlefeatures.count{
                if singlefeatures[i].suit == -1
                    || singlefeatures[i].suit == suit
                    || (singlefeatures[i].suit == -2 && (suit == 0 || suit == 2))
                    || (singlefeatures[i].suit == -3 && (suit == 1 || suit == 3)){
                    suitSingleFeatures.append(i)
                }
            }
            
            if suitSingleFeatures.count >= 3{
                usedSingleFeatureIndexList += suitSingleFeatures.combinations(ofCount: 3)
            }
        }
        
        if usedSingleFeatureIndexList.count > 0 {
            
            for currentUsedSingleFeatureIndex in usedSingleFeatureIndexList{
                var rank = 0
                
                var suit = 3
                for c in currentUsedSingleFeatureIndex {
                    if singlefeatures[c].suit >= 0{
                        suit = singlefeatures[c].suit
                        break
                    }
                }
                
                for c in currentUsedSingleFeatureIndex {
                    if singlefeatures[c].rank == 15{
                        rank = rank << 4 | 0
                    }
                    else{
                        rank = rank << 4 | singlefeatures[c].rank
                    }
                }
                rank = rank << 2 | suit
                
//                let singlefeatureType = "金花" + String(singlefeatures[currentUsedSingleFeatureIndex[0]].rank)
                let singlefeatureType = "金花"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
        }
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    

    func eval_straight(singlefeatures: [CBDatasetSingleFeature]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        
        var allIndex:[Int] = Array(0...singlefeatures.count-1)
       
        let allCombinations = allIndex.combinations(ofCount: 3)
        for combination in allCombinations {
            var currentCombination = combination
            currentCombination.sort(by: { index1, index2 in
                return singlefeatures[index1].rank > singlefeatures[index2].rank
            })
            
            var cntC = 0
            if singlefeatures[currentCombination[0]].rank == 15{
                cntC = 1
            }
            if singlefeatures[currentCombination[1]].rank == 15{
                cntC = 2
            }
            
            var headRank = -1
            var headSuit = -1
            
            if cntC == 2{
                let nowRank = singlefeatures[currentCombination[2]].rank
                if nowRank == 14{
                    headRank = 15 //AQK rank 15
                    headSuit = singlefeatures[currentCombination[2]].suit
                }
                else if nowRank == 13{
                    headRank = 15 //AQK rank 15
                    headSuit = 0
                }
                else if self.AStraightMin == 0 && (nowRank == 3 || nowRank == 2){
                    headRank = 14 //A23 rank 14
                    headSuit = 0
                }
                else{
                    headRank = nowRank + 2
                    headSuit = 0
                }
            }
            else{
                var gap = cntC
                
                if singlefeatures[currentCombination[cntC]].rank == 14{
                    singlefeatures[currentCombination[cntC]].rank = 1
                    currentCombination.sort(by: { index1, index2 in
                        return singlefeatures[index1].rank > singlefeatures[index2].rank
                    })
                    for i in cntC..<currentCombination.count-1{
                        let nowRank = singlefeatures[currentCombination[i]].rank
                        let nextRank = singlefeatures[currentCombination[i+1]].rank
                        if nowRank == nextRank {
                            gap = -1
                            break
                        }
                        else{
                            gap -= nowRank - nextRank - 1
                        }
                    }
                    
                    singlefeatures[currentCombination[currentCombination.count-1]].rank = 14
                    currentCombination.sort(by: { index1, index2 in
                        return singlefeatures[index1].rank > singlefeatures[index2].rank
                    })
                    
                    if gap > 0{
                        if self.AStraightMin == 0{
                            headRank = 14
                            headSuit = singlefeatures[currentCombination[cntC]].suit
                        }
                        else{
                            headRank = 3
                            headSuit = singlefeatures[currentCombination[cntC]].suit
                        }
                    }
                }
                
                gap = cntC
                for i in cntC..<currentCombination.count-1{
                    let nowRank = singlefeatures[currentCombination[i]].rank
                    let nextRank = singlefeatures[currentCombination[i+1]].rank
                    if nowRank == nextRank {
                        gap = -1
                        break
                    }
                    else{
                        gap -= nowRank - nextRank - 1
                    }
                }
                
                if gap >= 0{
                    let nowRank = singlefeatures[currentCombination[cntC]].rank
                    if nowRank == 14{
                        headRank = 15
                        headSuit = singlefeatures[currentCombination[cntC]].suit
                    }
                    else if nowRank + gap > 13{
                        headRank = 14
                        headSuit = 0
                    }
                    else if gap > 0{
                        headRank = nowRank + gap
                        headSuit = 0
                    }
                    else{
                        headRank = nowRank
                        headSuit = singlefeatures[currentCombination[cntC]].suit
                    }
                }
            }
            
            if headRank != -1{
                usedSingleFeatureIndexList.append(currentCombination)
                var rank = 0
                if headSuit < 0{
                    headSuit = 0
                }
                
                rank = rank << 4 | headRank
                rank = rank << 2 | headSuit

//                let singlefeatureType = "顺子" + String(headRank)
                let singlefeatureType = "顺子"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
        }
        
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }

    
    func eval_onepair(singlefeatures: [CBDatasetSingleFeature]) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        for i in 0..<singlefeatures.count-1{
            if singlefeatures[i].rank != 15 && singlefeatures[i].rank == singlefeatures[i+1].rank{
                usedSingleFeatureIndexList.append([i, i+1])
            }
        }
        
        if singlefeatures[0].rank == 15{
            for i in 1..<singlefeatures.count{
                usedSingleFeatureIndexList.append([0, i])
            }
        }

        if usedSingleFeatureIndexList.count > 0 {
            
            for currentUsedSingleFeatureIndex in usedSingleFeatureIndexList{
                var rank = 0
                
                var pairRank = singlefeatures[currentUsedSingleFeatureIndex[1]].rank
                var pairsuit = singlefeatures[currentUsedSingleFeatureIndex[0]].suit
                
                if pairRank == 15{
                    pairRank = 14
                }
                if pairsuit < 0{
                    pairsuit = 0
                }
                                
                rank = rank << 4 | pairRank
                
                let singlefeatureType = "对子"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
            
            
        }

        return (rankList, singlefeatureTypeList, 1, usedSingleFeatureIndexList)
    }

    func eval_holesinglefeature(singlefeatures: [CBDatasetSingleFeature]) -> ([Int], [String], Int, [[Int]]) {
        var rank: Int = 0
        var usedSingleFeatureIndexList : [Int] = []
        
        for i in 0..<singlefeatures.count-1{
            if singlefeatures[i].rank != 15{
                usedSingleFeatureIndexList.append(i)
                break
            }
        }
        
        for c in usedSingleFeatureIndexList {
            rank = rank << 4 | singlefeatures[c].rank
        }
        
        for c in usedSingleFeatureIndexList {
            
            var suit = singlefeatures[c].suit
            if suit == -1{
                suit = 3
            }
            else if suit == -2{
                suit = 2
            }
            else if suit == -3{
                suit = 3
            }
            
            rank = rank << 2 | suit
        }

        return ([rank], ["单牌"], 0, [usedSingleFeatureIndexList])
    }
}

class CBDatasetSingleFeature{
    var rank: Int = 0
    var suit: Int = 0
    var originRank : Int = 0
    var singleFeatureIndex : Int = 0
    
    init(singlefeature: SingleFeature, specialfeatureChangeSetting: Int){
        self.originRank = singlefeature.rank
        self.singleFeatureIndex = singlefeature.singlefeatureIndex
        
        if singlefeature.rank == 14 {
            if specialfeatureChangeSetting == 0{
                self.rank = 15
                self.suit = -1
            }
            else if specialfeatureChangeSetting == 1{
                self.rank = 15
                self.suit = -3
            }
            else if specialfeatureChangeSetting == 2{
                self.rank = 3
                self.suit = -3
            }
        }
        else if singlefeature.rank == 15 {
            if specialfeatureChangeSetting == 0{
                self.rank = 15
                self.suit = -1
            }
            else if specialfeatureChangeSetting == 1{
                self.rank = 15
                self.suit = -2
            }
            else if specialfeatureChangeSetting == 2{
                self.rank = 6
                self.suit = -2
            }
        }
        else if singlefeature.rank == 1{
            self.rank = 14
            self.suit = singlefeature.suit[0]
        }
        else{
            self.rank = singlefeature.rank
            self.suit = singlefeature.suit[0]
        }
    }
}
