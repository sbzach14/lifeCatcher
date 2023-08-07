import Foundation

class SettingViewModel: ObservableObject {
    @Published var isBlack: Bool = false
    @Published var isMute: Bool = false
    @Published var isBackCamera: Bool = false
    @Published var isActive: Bool = false
    
    @Published var searchText : String = ""

    init() {
        // Load data from config.json
        if let configData = readConfigJSON() {
            self.isBlack = configData["isBlack"]!
            self.isMute = configData["isMute"]!
            self.isBackCamera = configData["isBackCamera"]!
            self.isActive = configData["isActive"]!
        } else {
            // If config.json is not found or invalid, set default values
            self.isBlack = false
            self.isMute = false
            self.isBackCamera = false
            self.isActive = false
        }
    }

    // Method to save changes to config.json whenever any property changes
    public func saveChanges() {
        updateConfigJSON()
    }
    
    // Method to update the config.json file whenever any property changes
    public func updateConfigJSON() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("config.json")

            let configData: [String: Bool] = [
                "isBlack": self.isBlack,
                "isMute": self.isMute,
                "isBackCamera" : self.isBackCamera,
                "isActive": self.isActive
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: configData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)

            print("config.json file updated successfully")
        } catch {
            print("Error updating config.json: \(error)")
        }
    }
    
    public func onReturnKeyPressed(){
        if searchText == "TEMP"{
            self.isActive.toggle()
            let dateString = "TEMP"
            
            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsURL.appendingPathComponent("para.json")

                let paraData: [String: String] = [
                    "activeTime": dateString
                ]

                let jsonData = try JSONSerialization.data(withJSONObject: paraData, options: .prettyPrinted)
                try jsonData.write(to: fileURL)

                print("para.json file updated successfully")
            } catch {
                print("Error updating para.json: \(error)")
            }
        }
        else if searchText == "WHOSYOURDADDY"{
            fetchInternetCurrentDate { internetDate in
                if let internetDate = internetDate {
                    
                    self.isActive.toggle()
                    
                    let activeTimeString = readParaJSON()!["activeTime"]
                    if activeTimeString == ""{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                        let dateString = dateFormatter.string(from: internetDate)
                        
                        do {
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsURL.appendingPathComponent("para.json")

                            let paraData: [String: String] = [
                                "activeTime": dateString
                            ]

                            let jsonData = try JSONSerialization.data(withJSONObject: paraData, options: .prettyPrinted)
                            try jsonData.write(to: fileURL)

                            print("para.json file updated successfully")
                        } catch {
                            print("Error updating para.json: \(error)")
                        }

                    }
                } else {
                    print("无法获取互联网当前日期")
                    exit(0)
                }
            }
        
        }
        searchText = ""
    }
}

// Usage in SettingView remains unchanged
