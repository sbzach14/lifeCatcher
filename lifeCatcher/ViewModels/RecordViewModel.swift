
import Foundation

class RecordViewModel: ObservableObject {
    @Published var recordHistoryData : [String:[String]]

    init() {
        recordHistoryData = readRecordHistoryJSON()!
    }

}


