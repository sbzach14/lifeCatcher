

import Foundation


class TWDatasetRule : Rule{
    
    //此处填入需要的参数，因为rulesettingview没有了，主要作用是注释
    let winCondition:[Int:String] = [
        0:"比尾墩",
        1:"比道数",
        2:"比两道"
    ]
    
    let AStraightMin:[Int:String] = [
        0:"A2345第二大",
        1:"A2345最小"
        
    ]
    
    let isDouble:[Int:String] = [
        0:"不翻倍",
        1:"翻倍"
    ]
    
    override init(ruleIndex: Int, ruleName: String) {
        super.init(ruleIndex: ruleIndex, ruleName: ruleName)
        self.rankRules = [
            8: "清顺",
            7: "炸弹",
            6: "葫芦",
            5: "清一色",
            4: "顺子",
            3: "三条",
            2: "两对",
            1: "对子",
            0: "单牌"
        ]
        self.setting = [
            0: "尾墩大13张[1302]",
            1: "道数13张翻倍[1301]",
            2: "54张百变13张尾墩大[1303]",
            3: "道数13张不翻倍[1300]",
            4: "道数13张不翻倍[1304]",
            5: "道数13张比两道[1305]",
            6: "道数13张不翻倍A2345二大[1306]",
            7: "道数13张比两道A2345二大[1307]",
        ]
        self.ruleInfo = [
            0: """
52张牌，每人13张
1.清顺 >炸弹> 3带2>清一色>顺子>3不带>2对>1对
2.保尾墩最大
""",
            1: """
52张牌，每人13张
1.清顺 >炸弹>3带2>清一色>顺子>3不带>2对>1对
2.保总道数最大
3.翻倍规则：头道三条3倍；中道葫芦3倍，炸弹5倍，同花顺6倍；尾道炸弹5倍，同花顺6倍；赢同一家三道再全部翻倍，上限24。
""",
            2: """
54张牌，每人13张.王百变
1.清顺 >炸弹> 3带2>清一色>顺子>3不带>2对>1对
2.保尾墩最大
""",
            3: """
52张牌，每人13张
1.清顺 >炸弹> 3带2>清一色>顺子>3不带>2对>1对
2.保总道数最大。不翻倍
""",
            4: """
52张牌，每人13张
1.其他规则:
1).清顺 >炸弹> 3带2 >清一色>顺子>3不带>2对>1对
2).保总道数最大
""",
            5: """
52张牌，每人13张
1.清顺>炸弹>3带2>清一色>顺子>3不带>2对>1对
2.和其他三家比，赢两道及三道最多一家为最大
""",
            6: """
52张牌，每人13张
1.其他规则:
1).清顺 >炸弹> 3带2>清一色>顺子>3不带>2对>1对
2).保总道数最大
3)顺大小规则:
AKQJ10>A2345>KQJ109>....>23456
""",
            7: """
52张牌，每人13张
1.清顺>炸弹>3带2>清一色>顺子>3不带>2对>1对
2.和其他三家比，赢两道及三道最多一家为最大
3.顺大小规则:
AKQJ10>A2345>KQJ109>....>23456
""",
        ]
        
        self.rcNum = [2,3,4]

    }
}


class TWDataset{
    
    static func FindWinner(diyDealStatus:[[Bool]], diyDealNum:[Int], inputSingleFeatures:[Int], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        
        let FeatureList = initFeatureList(initialSingleFeatures: inputSingleFeatures, suitRules: suitRules)
        let (winners, leftSingleFeatures) = calWinners(diyDealStatus: diyDealStatus, diyDealNum: diyDealNum, FeatureList: FeatureList, args: args, rankRules: rankRules, suitRules: suitRules)
        return (winners, leftSingleFeatures)
    }
    
    static func legalCheck(rcNum: Int) -> String{
        var errMessage : String = ""
        if(rcNum * 13 > 52)
        {
            errMessage = "需要牌数量超出牌堆总数，请重新设置！"
        }
        return errMessage
    }
    
    //加入每个规则需要的用牌
    static func getAllSingleFeatureIndex(setting: Int) -> [Int]{
        var result : [Int] = []
        switch setting {
        case 2:
            result = Array(0...51) + [53,54]
            break
        default:
            result = Array(0...51)
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
    //7 isDouble
    
    static func calWinners(diyDealStatus:[[Bool]], diyDealNum:[Int], FeatureList: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> ([DatasetReturnRCInfo],[Int]) {
        let dealNum = args[0]
        let dealType = args[1]
        let rcNum = args[2]
        let handNum = args[3]
        let communityNum = args[4]
        let winCondition = args[5]
        let AStraightMin = args[6]
        let isDouble = args[7]
        
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
        var rcTypeList : [[String]] = []
        
        for i in 0..<rcNum {
            
            var turn1SingleFeatures:[TWSingleFeature] = []
            for singlefeature in allPlaySingleFeatures[i].rcSingleFeature {
                turn1SingleFeatures.append(TWSingleFeature(singlefeature: singlefeature))
            }
            turn1SingleFeatures = turn1SingleFeatures.sorted(by: {$0.rank > $1.rank})
            
            let (rank1, singlefeaturetype1, isPair1, usedSingleFeatureIndex1) = TWDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                turn: 1
            ).evalHand(singlefeatures: turn1SingleFeatures)
            
            allPlaySingleFeatures[i].evaluateFlag = rank1
            allPlaySingleFeatures[i].singlefeatureType = singlefeaturetype1
            allPlaySingleFeatures[i].isPair = isPair1
                
            var turn2SingleFeatures:[TWSingleFeature] = []
            for singlefeatureIndex in 0..<turn1SingleFeatures.count {
                if !usedSingleFeatureIndex1.contains(singlefeatureIndex){
                    turn2SingleFeatures.append(turn1SingleFeatures[singlefeatureIndex])
                }
            }
                
            let (rank2, singlefeaturetype2, isPair2, usedSingleFeatureIndex2) = TWDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                turn: 2
            ).evalHand(singlefeatures: turn2SingleFeatures)
                
                    
            var turn3SingleFeatures:[TWSingleFeature] = []
            for singlefeatureIndex in 0..<turn2SingleFeatures.count {
                if !usedSingleFeatureIndex2.contains(singlefeatureIndex){
                    turn3SingleFeatures.append(turn2SingleFeatures[singlefeatureIndex])
                }
            }
                    
            let (rank3, singlefeaturetype3, isPair3, usedSingleFeatureIndex3) = TWDatasetHandAnalyst(
                rankRules: rankRules,
                suitRules: suitRules,
                AStraightMin: AStraightMin,
                turn: 3
            ).evalHand(singlefeatures: turn3SingleFeatures)
            
            rcRankList.append([rank1, rank2, rank3])
            rcTypeList.append([singlefeaturetype1, singlefeaturetype2, singlefeaturetype3])
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
                        var winNum = 0
                        var pointNum = 0
                        for turn in 0..<3{
                            if rcRankList[currentRC][turn] > rcRankList[i][turn]{
                                winNum += 1
                                
                                if isDouble == 1{
                                    //5
                                    if turn == 0{
                                        if rcTypeList[currentRC][turn] == "同花顺"{
                                            pointNum += 6
                                        }
                                        else if rcTypeList[currentRC][turn] == "炸弹"{
                                            pointNum += 5
                                        }
                                        else{
                                            pointNum += 1
                                        }
                                    }
                                    //5
                                    else if turn == 1{
                                        if rcTypeList[currentRC][turn] == "同花顺"{
                                            pointNum += 6
                                        }
                                        else if rcTypeList[currentRC][turn] == "炸弹"{
                                            pointNum += 5
                                        }
                                        else if rcTypeList[currentRC][turn] == "葫芦"{
                                            pointNum += 3
                                        }
                                        else{
                                            pointNum += 1
                                        }
                                    }
                                    //3
                                    else{
                                        if rcTypeList[currentRC][turn] == "三条"{
                                            pointNum += 3
                                        }
                                        else{
                                            pointNum += 1
                                        }
                                    }
                                }
                                else{
                                    pointNum += 1
                                }
                            }
                            else if rcRankList[currentRC][turn] < rcRankList[i][turn]{
                                winNum -= 1
                                
                                if isDouble == 1{
                                    //5
                                    if turn == 0{
                                        if rcTypeList[i][turn] == "同花顺"{
                                            pointNum -= 6
                                        }
                                        else if rcTypeList[i][turn] == "炸弹"{
                                            pointNum -= 5
                                        }
                                        else{
                                            pointNum -= 1
                                        }
                                    }
                                    //5
                                    else if turn == 1{
                                        if rcTypeList[i][turn] == "同花顺"{
                                            pointNum -= 6
                                        }
                                        else if rcTypeList[i][turn] == "炸弹"{
                                            pointNum -= 5
                                        }
                                        else if rcTypeList[i][turn] == "葫芦"{
                                            pointNum -= 3
                                        }
                                        else{
                                            pointNum -= 1
                                        }
                                    }
                                    //3
                                    else{
                                        if rcTypeList[i][turn] == "三条"{
                                            pointNum -= 3
                                        }
                                        else{
                                            pointNum -= 1
                                        }
                                    }
                                }
                                else{
                                    pointNum -= 1
                                }
                            }
                        }
                        
                        if isDouble == 1 && (winNum == 3 || winNum == -3){
                            pointNum *= 2
                            pointNum = min(pointNum, 24)
                        }
                        
                        allPlaySingleFeatures[currentRC].evaluateFlag += pointNum
                    }
                }
            }
        }
        //两道
        else if winCondition == 2{
            for i in 0..<rcNum {
                allPlaySingleFeatures[i].evaluateFlag = 0
            }
            for currentRC in 0..<rcNum {
                for i in 0..<rcNum{
                    if currentRC != i{
                        var winFlag = 0
                        for turn in 0..<3{
                            if rcRankList[currentRC][turn] > rcRankList[i][turn]{
                                winFlag += 1
                            }
                        }
                        if winFlag >= 2{
                            allPlaySingleFeatures[currentRC].evaluateFlag += 1
                        }
                    }
                }
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
        if leftSingleFeatures.count < TWDataset.getMinSingleFeatureNum(rcNum: rcNum,handNum: handNum, communityNum: communityNum, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus){
            leftSingleFeatures = []
        }
        return (returnRCInfos, leftSingleFeatures)
    }
    
    static func sortSingleFeatures(originSingleFeatures: [SingleFeature], args: [Int], rankRules: [Int], suitRules: [Int]) -> [SingleFeature]{
        let AStraightMin = args[6]
        
        var sortSingleFeatures : [[SingleFeature]] = [[],[],[],[]]
        
        var turn1SingleFeatures:[TWSingleFeature] = []
        
        for singlefeature in originSingleFeatures {
            turn1SingleFeatures.append(TWSingleFeature(singlefeature: singlefeature))
        }
        turn1SingleFeatures = turn1SingleFeatures.sorted(by: {$0.rank > $1.rank})
        
        let (rank1, singlefeaturetype1, isPair1, usedSingleFeatureIndex1) = TWDatasetHandAnalyst(
            rankRules: rankRules,
            suitRules: suitRules,
            AStraightMin: AStraightMin,
            turn: 1
        ).evalHand(singlefeatures: turn1SingleFeatures)
        
        var turn2SingleFeatures:[TWSingleFeature] = []
        for singlefeatureIndex in 0..<turn1SingleFeatures.count {
            if !usedSingleFeatureIndex1.contains(singlefeatureIndex){
                turn2SingleFeatures.append(turn1SingleFeatures[singlefeatureIndex])
            }
            else{
                sortSingleFeatures[0].append(SingleFeature(suit: [turn1SingleFeatures[singlefeatureIndex].originRank], rank: 0, singlefeatureIndex: turn1SingleFeatures[singlefeatureIndex].singleFeatureIndex))
            }
        }
            
        let (rank2, singlefeaturetype2, isPair2, usedSingleFeatureIndex2) = TWDatasetHandAnalyst(
            rankRules: rankRules,
            suitRules: suitRules,
            AStraightMin: AStraightMin,
            turn: 2
        ).evalHand(singlefeatures: turn2SingleFeatures)
            
                
        var turn3SingleFeatures:[TWSingleFeature] = []
        for singlefeatureIndex in 0..<turn2SingleFeatures.count {
            if !usedSingleFeatureIndex2.contains(singlefeatureIndex){
                turn3SingleFeatures.append(turn2SingleFeatures[singlefeatureIndex])
            }
            else{
                sortSingleFeatures[1].append(SingleFeature(suit: [turn2SingleFeatures[singlefeatureIndex].originRank], rank: 0, singlefeatureIndex: turn2SingleFeatures[singlefeatureIndex].singleFeatureIndex))
            }
        }
        
        let (rank3, singlefeaturetype3, isPair3, usedSingleFeatureIndex3) = TWDatasetHandAnalyst(
            rankRules: rankRules,
            suitRules: suitRules,
            AStraightMin: AStraightMin,
            turn: 3
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
        for i in 0..<5{
            if i < sortSingleFeatures[0].count{
                result.append(sortSingleFeatures[0][i])
            }
            else{
                result.append(sortSingleFeatures[3].removeFirst())
            }
        }
        for i in 0..<5{
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

class TWDatasetHandAnalyst{
    var rankRules: [Int]
    var suitRules: [Int]
    var ruleDict: [Int: ([TWSingleFeature], Int) -> ([Int], [String], Int, [[Int]])] = [:]
    var AStraightMin: Int
    var turn: Int
    var lastTurnRule: [Int]
    
    init(rankRules: [Int],
         suitRules: [Int],
         AStraightMin: Int, 
         turn: Int){
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.AStraightMin = AStraightMin
        self.turn = turn
        self.lastTurnRule = [0,1,3]
        
        self.ruleDict = [
            0:self.eval_holesinglefeature(singlefeatures:needSingleFeaturesNum:),
            1:self.eval_onepair(singlefeatures:needSingleFeaturesNum:),
            2:self.eval_twopair(singlefeatures:needSingleFeaturesNum:),
            3:self.eval_threesinglefeature(singlefeatures:needSingleFeaturesNum:),
            4:self.eval_straight(singlefeatures:needSingleFeaturesNum:),
            5:self.eval_flush(singlefeatures:needSingleFeaturesNum:),
            6:self.eval_fullhouse(singlefeatures:needSingleFeaturesNum:),
            7:self.eval_foursinglefeature(_:needSingleFeaturesNum:),
            8:self.eval_straightflush(singlefeatures:needSingleFeaturesNum:)
        ]
        
        
    }
    
    //传入需要的参数
    func evalHand(singlefeatures: [TWSingleFeature])->(Int, String, Int, [Int]){
        var needSingleFeatureNum = 5
        if turn == 3{
            needSingleFeatureNum = 3
        }
        
        var rank:Int = 0
        var singlefeatureType:String = ""
        var isPair:Int = 0
        var usedSingleFeatureIndex:[Int] = []
        
        var i = self.ruleDict.count + 1
        for ruleIndex in self.rankRules{
            i -= 1
            
            if turn == 3 && !self.lastTurnRule.contains(ruleIndex){
                continue
            }
            
            let (rankList, singlefeatureTypeList, isPair, usedSingleFeatureIndexList) = self.ruleDict[ruleIndex]!(singlefeatures, needSingleFeatureNum)
            
            
            if rankList.count == 0{
                continue
            } 
            else {
                let maxIndex = rankList.firstIndex(of: rankList.max() ?? 0)!
                
                rank = (1 << (i + 23)) | rankList[maxIndex]
                singlefeatureType = singlefeatureTypeList[maxIndex]
                usedSingleFeatureIndex = usedSingleFeatureIndexList[maxIndex]
                
                break
            }
        }

        return (rank, singlefeatureType, isPair, usedSingleFeatureIndex)
    }
    //牌型函数
    func eval_straightflush(singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        
        let (straightRankList, straightSingleFeatureTypeList, _, straightUsedSingleFeatureIndexList) = eval_straight(singlefeatures: singlefeatures, needSingleFeaturesNum: needSingleFeaturesNum)
        
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
                    let currentSingleFeature = singlefeatures[currentSingleFeatureIndex]
                    
                    if currentSingleFeature.suit != suit && currentSingleFeature.suit != -1{
                        isFlush = false
                        break
                    }
                }
                if isFlush{
                    usedSingleFeatureIndexList.append(currentStraightUsedSingleFeatureIndex)
                    
                    var rank = straightRankList[i] >> 2
                    var singlefeatureType = "同花顺"
                    
                    rank = rank << 2 | suit
                    
                    rankList.append(rank)
                    singlefeatureTypeList.append(singlefeatureType)
                }
            }
        }
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    
    func eval_foursinglefeature(_ singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        if singlefeatures.count >= 5{
            if singlefeatures[0].rank == 15 && singlefeatures[1].rank == 15{
                for i in 2..<singlefeatures.count-1{
                    if singlefeatures[i].rank == singlefeatures[i+1].rank{
                        usedSingleFeatureIndexList.append([0,1,i,i+1])
                    }
                }
            }
            else if singlefeatures[0].rank == 15{
                for i in 1..<singlefeatures.count-2{
                    if singlefeatures[i].rank == singlefeatures[i+1].rank && singlefeatures[i].rank == singlefeatures[i+2].rank{
                        usedSingleFeatureIndexList.append([0,i,i+1,i+2])
                    }
                }
            }
            else {
                for i in 0..<singlefeatures.count-3{
                    if singlefeatures[i].rank == singlefeatures[i+1].rank && singlefeatures[i].rank == singlefeatures[i+2].rank && singlefeatures[i].rank == singlefeatures[i+3].rank{
                        usedSingleFeatureIndexList.append([i,i+1,i+2,i+3])
                    }
                }
            }
        }

        if usedSingleFeatureIndexList.count > 0 {
            
            for currentUsedSingleFeatureIndex in usedSingleFeatureIndexList{
                var rank = 0
                
                var fourSingleFeatureRank = singlefeatures[currentUsedSingleFeatureIndex[2]].rank
                
                var foursinglefeatureSuit = singlefeatures[currentUsedSingleFeatureIndex[0]].suit
                if foursinglefeatureSuit == -1{
                    foursinglefeatureSuit = 0
                }
                
                rank = rank << 4 | fourSingleFeatureRank
                //rank = rank << 2 | foursinglefeatureSuit
                
//                let singlefeatureType = "炸弹" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[currentUsedSingleFeatureIndex[2]].originRank]!
                let singlefeatureType = "炸弹"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
        }
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    
    func eval_fullhouse(singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        if singlefeatures.count >= 5{
            let (threesinglefeatureRankList, threesinglefeatureSingleFeatureTypeList, _, threesinglefeatureUsedSingleFeatureIndexList) = eval_threesinglefeature(singlefeatures: singlefeatures, needSingleFeaturesNum: needSingleFeaturesNum)
            
            if threesinglefeatureUsedSingleFeatureIndexList.count > 0 {
                
                for currentThreeSingleFeatureUsedSingleFeatureIndex in threesinglefeatureUsedSingleFeatureIndexList{
                    
                    var pairSingleFeatures: [TWSingleFeature] = []
                    var pairSingleFeaturesIndex: [Int] = []
                    for i in 0..<singlefeatures.count{
                        if !currentThreeSingleFeatureUsedSingleFeatureIndex.contains(i){
                            pairSingleFeatures.append(singlefeatures[i])
                            pairSingleFeaturesIndex.append(i)
                        }
                    }
                    let (pairRankList, pairSingleFeatureTypeList, _, pairUsedSingleFeatureIndexList) = eval_onepair(singlefeatures: pairSingleFeatures, needSingleFeaturesNum: needSingleFeaturesNum)
                    
                    if pairUsedSingleFeatureIndexList.count > 0{
                        for currentPairUsedSingleFeatureIndex in pairUsedSingleFeatureIndexList{
                            usedSingleFeatureIndexList.append([currentThreeSingleFeatureUsedSingleFeatureIndex[0],currentThreeSingleFeatureUsedSingleFeatureIndex[1], currentThreeSingleFeatureUsedSingleFeatureIndex[2], pairSingleFeaturesIndex[currentPairUsedSingleFeatureIndex[0]],pairSingleFeaturesIndex[currentPairUsedSingleFeatureIndex[1]]])
                        }
                    }
                }
            }
        }
        
        if usedSingleFeatureIndexList.count > 0 {
            
            for currentUsedSingleFeatureIndex in usedSingleFeatureIndexList{
                var rank = 0
                
                var threesinglefeatureRank = singlefeatures[currentUsedSingleFeatureIndex[2]].rank
                var pairRank = singlefeatures[currentUsedSingleFeatureIndex[4]].rank
                var threesinglefeatureSuit = singlefeatures[currentUsedSingleFeatureIndex[0]].suit
                var pairSuit = singlefeatures[currentUsedSingleFeatureIndex[3]].suit
                
                if pairRank == 15{
                    pairRank = 14
                }
                if threesinglefeatureSuit == -1{
                    threesinglefeatureSuit = 0
                }
                if pairSuit == -1{
                    pairSuit = 0
                }
                
                rank = rank << 4 | threesinglefeatureRank
                rank = rank << 4 | (15 - pairRank) //用小的对子
                //rank = rank << 2 | threesinglefeatureSuit
                //rank = rank << 2 | pairSuit
                
//                let singlefeatureType = "三带二" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[currentUsedSingleFeatureIndex[2]].originRank]!
                let singlefeatureType = "葫芦"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
            
        }

        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    
    func eval_flush(singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        
        for suit in 0..<4{
            var suitSingleFeatures : [Int] = []
            for i in 0..<singlefeatures.count{
                if singlefeatures[i].suit == -1 || singlefeatures[i].suit == suit{
                    suitSingleFeatures.append(i)
                }
            }
            
            if suitSingleFeatures.count >= needSingleFeaturesNum{
                usedSingleFeatureIndexList += suitSingleFeatures.combinations(ofCount: needSingleFeaturesNum)
            }
        }
        
        if usedSingleFeatureIndexList.count > 0 {
            
            for currentUsedSingleFeatureIndex in usedSingleFeatureIndexList{
                var rank = 0
                
                var suit = 3
                for c in currentUsedSingleFeatureIndex {
                    if singlefeatures[c].suit != -1{
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
                
//                let singlefeatureType = "同花" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[currentUsedSingleFeatureIndex[0]].originRank]!
                let singlefeatureType = "同花"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
        }
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    

    func eval_straight(singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        
        var allIndex:[Int] = Array(0...singlefeatures.count-1)
        
        let allCombinations = allIndex.combinations(ofCount: needSingleFeaturesNum)
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
            
            if needSingleFeaturesNum == 3 && cntC == 2{
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
                if headSuit == -1{
                    headSuit = 0
                }
                rank = rank << 4 | headRank
                rank = rank << 2 | headSuit

                var singlefeatureType = "顺子"
//                for currentSingleFeatureIndex in currentCombination{
//                    let currentSingleFeature = singlefeatures[currentSingleFeatureIndex]
//                    singlefeatureType += String(currentSingleFeature.rank) + " "
//                }
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
        }
        
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    
    func eval_threesinglefeature(singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
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

        if usedSingleFeatureIndexList.count > 0 {
            
            for currentUsedSingleFeatureIndex in usedSingleFeatureIndexList{
                var rank = 0
                
                var threeSingleFeatureRank = singlefeatures[currentUsedSingleFeatureIndex[2]].rank
                var threeSingleFeatureSuit = singlefeatures[currentUsedSingleFeatureIndex[0]].rank
                
                if threeSingleFeatureSuit == -1{
                    threeSingleFeatureSuit = 0
                }
                
                rank = rank << 4 | threeSingleFeatureRank
                //rank = rank << 2 | threeSingleFeatureSuit
                
//                let singlefeatureType = "三条" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[currentUsedSingleFeatureIndex[2]].originRank]!
                let singlefeatureType = "三条"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
        }
        
        return (rankList, singlefeatureTypeList, 0, usedSingleFeatureIndexList)
    }
    
    func eval_twopair(singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        if singlefeatures.count >= 5{
            let (pairRankList, pairSingleFeatureTypeList, _, pairUsedSingleFeatureIndexList) = eval_onepair(singlefeatures: singlefeatures, needSingleFeaturesNum: needSingleFeaturesNum)
            
            if pairUsedSingleFeatureIndexList.count > 0 {
                
                for currentPairUsedSingleFeatureIndex in pairUsedSingleFeatureIndexList{
                    
                    var twopairSingleFeatures: [TWSingleFeature] = []
                    var twopairSingleFeaturesIndex: [Int] = []
                    for i in 0..<singlefeatures.count{
                        if !currentPairUsedSingleFeatureIndex.contains(i){
                            twopairSingleFeatures.append(singlefeatures[i])
                            twopairSingleFeaturesIndex.append(i)
                        }
                    }
                    let (twopairRankList, twopairSingleFeatureTypeList, _, twopairUsedSingleFeatureIndexList) = eval_onepair(singlefeatures: twopairSingleFeatures, needSingleFeaturesNum: needSingleFeaturesNum)
                    
                    if twopairUsedSingleFeatureIndexList.count > 0{
                        for currentTwopairUsedSingleFeatureIndex in twopairUsedSingleFeatureIndexList{
                            usedSingleFeatureIndexList.append([currentPairUsedSingleFeatureIndex[0],currentPairUsedSingleFeatureIndex[1],twopairSingleFeaturesIndex[currentTwopairUsedSingleFeatureIndex[0]],twopairSingleFeaturesIndex[currentTwopairUsedSingleFeatureIndex[1]]])
                        }
                    }
                }
            }
        }
        
        if usedSingleFeatureIndexList.count > 0 {
            
            for currentUsedSingleFeatureIndex in usedSingleFeatureIndexList{
                var rank = 0
                
                var firstPairRank = singlefeatures[currentUsedSingleFeatureIndex[1]].rank
                var firstPairSuit = singlefeatures[currentUsedSingleFeatureIndex[0]].suit
                var secondPairRank = singlefeatures[currentUsedSingleFeatureIndex[3]].rank
                var secondPairSuit = singlefeatures[currentUsedSingleFeatureIndex[2]].suit
                
                if firstPairRank == 15{
                    firstPairRank = 14
                }
                if secondPairRank == 15{
                    secondPairRank = 14
                }
                if firstPairSuit == -1{
                    firstPairSuit = 0
                }
                if secondPairSuit == -1{
                    secondPairSuit = 0
                }
                
                rank = rank << 4 | firstPairRank
                rank = rank << 4 | secondPairRank
                //rank = rank << 2 | firstPairSuit
                
                
//                let singlefeatureType = "两对" + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[currentUsedSingleFeatureIndex[1]].originRank]! + ClassifierSettingArgs.SingleFeatureNumberReportDic[singlefeatures[currentUsedSingleFeatureIndex[3]].originRank]!
                let singlefeatureType = "两对"
                
                rankList.append(rank)
                singlefeatureTypeList.append(singlefeatureType)
            }
            
            
        }

        return (rankList, singlefeatureTypeList, 1, usedSingleFeatureIndexList)
    }
    
    func eval_onepair(singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rankList: [Int] = []
        var singlefeatureTypeList: [String] = []
        var usedSingleFeatureIndexList : [[Int]] = []
        
        for i in 0..<singlefeatures.count-1{
            if i == 0{
                if singlefeatures[i].rank != 15
                    && singlefeatures[i].rank == singlefeatures[i+1].rank
                    && singlefeatures[i+1].rank != singlefeatures[i+2].rank{
                    usedSingleFeatureIndexList.append([i, i+1])
                }
            }
            else if i == singlefeatures.count-2{
                if singlefeatures[i].rank != 15
                    && singlefeatures[i].rank == singlefeatures[i+1].rank
                    && singlefeatures[i].rank != singlefeatures[i-1].rank{
                    usedSingleFeatureIndexList.append([i, i+1])
                }
            }
            else{
                if singlefeatures[i].rank != 15
                    && singlefeatures[i].rank == singlefeatures[i+1].rank
                    && singlefeatures[i].rank != singlefeatures[i-1].rank
                    && singlefeatures[i+1].rank != singlefeatures[i+2].rank{
                    usedSingleFeatureIndexList.append([i, i+1])
                }
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
                if pairsuit == -1{
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

    func eval_holesinglefeature(singlefeatures: [TWSingleFeature], needSingleFeaturesNum: Int) -> ([Int], [String], Int, [[Int]]) {
        var rank: Int = 0
        var usedSingleFeatureIndexList : [Int] = []
        
        for c in 0..<3 {
            if singlefeatures[c].rank == 15{
                rank = rank << 4 | 14
            }
            else{
                rank = rank << 4 | singlefeatures[c].rank
            }
            usedSingleFeatureIndexList.append(c)
        }

        return ([rank], ["单牌"], 0, [usedSingleFeatureIndexList])
    }
}

class TWSingleFeature{
    var rank: Int = 0
    var suit: Int = 0
    var originRank : Int = 0
    var singleFeatureIndex : Int = 0
    
    init(singlefeature: SingleFeature){
        self.originRank = singlefeature.rank
        self.singleFeatureIndex = singlefeature.singlefeatureIndex
        
        if singlefeature.rank == 14 || singlefeature.rank == 15{
            self.rank = 15
            self.suit = -1
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
