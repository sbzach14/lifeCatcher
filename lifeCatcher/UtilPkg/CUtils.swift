import Foundation

class SingleFeature {
    var suit: [Int]
    var rank: Int
    var singlefeatureIndex: Int
    let originalRank: Int
    
    init(suit: [Int], rank: Int, singlefeatureIndex: Int) {
        self.suit = suit
        self.rank = rank
        self.originalRank = rank
        self.singlefeatureIndex = singlefeatureIndex
    }
    
    static func calScore(singlefeature: SingleFeature) -> Int {
        return singlefeature.rank * 10 + singlefeature.suit.max()!
    }
}


class RC {
    var rcSingleFeature = [SingleFeature]()
    var evaluateFlag = 0
    var singlefeatureType: String = ""
    var singlefeatureSuit: String = ""
    var isPair: Int = 0
    
    func insertSingleFeature(singlefeature: SingleFeature) {
        rcSingleFeature.append(singlefeature)
    }
}


func initFeatureList(initialSingleFeatures: [Int], suitRules: [Int]) -> [SingleFeature] {
    var FeatureListList = [SingleFeature]()
    
    for singlefeatureIndex in initialSingleFeatures {
        if singlefeatureIndex < 52 {
            FeatureListList.append(SingleFeature(suit: [suitRules[singlefeatureIndex / 13]], rank: singlefeatureIndex % 13 + 1, singlefeatureIndex: singlefeatureIndex))
        } else {
            if singlefeatureIndex == 53 {
                FeatureListList.append(SingleFeature(suit: [0], rank: 14, singlefeatureIndex: singlefeatureIndex))
            } else if singlefeatureIndex == 54 {
                FeatureListList.append(SingleFeature(suit: [0], rank: 15, singlefeatureIndex: singlefeatureIndex))
            }
        }
    }
    
    return FeatureListList
}

func randomSingleFeatureArray(singlefeatureNum: Int) -> [Int] {
    var singlefeatureArray = [Int]()
    
    if singlefeatureNum == 52 {
        for suit in 0..<4 {
            for rank in 0..<13 {
                singlefeatureArray.append(suit * 13 + rank)
            }
        }
    } else if singlefeatureNum == 40 {
        for suit in 0..<4 {
            for rank in 0..<10 {
                singlefeatureArray.append(suit * 13 + rank)
            }
        }
    }
    
    singlefeatureArray.shuffle()
    return singlefeatureArray
}

// Helper extension for combinations
extension Array {
    func combinations(ofCount count: Int) -> [[Element]] {
        if count == 0 {
            return [[]]
        }
        guard !isEmpty else {
            return []
        }
        if count >= self.count {
            return [self]
        }
        if count == 1 {
            return self.map { [$0] }
        }
        var result: [[Element]] = []
        for (index, element) in self.enumerated() {
            var reduced = self
            reduced.removeFirst(index + 1)
            if reduced.count < count - 1{
                break
            }
            let subcombinations = reduced.combinations(ofCount: count - 1)
            for subcombination in subcombinations {
                result.append([element] + subcombination)
            }
        }
        return result
    }
}

struct cutStruct{
    var cutcardIndex: Int = 0
    //0，看底，1，看顶，2，看色，3，看手
    var cutMode: Int = 0
}
