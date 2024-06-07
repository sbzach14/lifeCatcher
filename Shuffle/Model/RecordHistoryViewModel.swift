
import Foundation

class RecordHistoryViewModel: ObservableObject {
    @Published var recordHistoryData : [String:[String]]

    init() {
        recordHistoryData = readRecordHistoryJSON()!
    }

}


