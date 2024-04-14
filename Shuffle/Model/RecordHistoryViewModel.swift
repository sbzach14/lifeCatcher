
import Foundation

class RecordHistoryViewModel: ObservableObject {
    @Published var isActive: Bool = false
    @Published var recordHistoryData : [String:[String]]

    init() {
        // Load data from config.json
        if let configData = readConfigJSON() {
            let boolDict = configData["Bool"] as! [String : Bool]
            self.isActive = boolDict["isActive"]!
        } else {
            self.isActive = false
        }
        
        recordHistoryData = readRecordHistoryJSON()!
    }

}


