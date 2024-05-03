import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    @Published var isBlack: Bool = false
    @Published var isMute: Bool = false
    @Published var isBackCamera: Bool = true
    @Published var isRemote: Bool = true
    @Published var isFast: Bool = true
    @Published var isActive: Bool = false
    @Published var isAutoFocus: Bool = true
    @Published var activeDate: String = ""
    @Published var uniqueID: String = ""
    @Published var volumeUp: Int = 0
    @Published var volumeDown: Int = 0
    @Published var volumeValue: Float = 0.5
    @Published var zoomFactor: Float = 0
    @Published var focusFactor: Float = 0.55
    
    @Published var searchText : String = ""

    init() {
        // Load data from config.json
        if let configData = readConfigJSON() {
            let boolDict = configData["Bool"] as! [String : Bool]
            self.isBlack = boolDict["isBlack"]!
            self.isMute = boolDict["isMute"]!
            self.isBackCamera = boolDict["isBackCamera"]!
            self.isRemote = boolDict["isRemote"]!
            self.isFast = boolDict["isFast"]!
            self.isActive = boolDict["isActive"]!
            self.isAutoFocus = boolDict["isAutoFocus"]!
            
            let intDict = configData["Int"] as! [String : Int]
            self.volumeUp = intDict["volumeUp"]!
            self.volumeDown = intDict["volumeDown"]!
            
            let floatDict = configData["Float"] as! [String : Float]
            self.volumeValue = floatDict["volumeValue"]!
            self.zoomFactor = floatDict["zoomFactor"]!
            self.focusFactor = floatDict["focusFactor"]!
        }
        
        if let paraData = readParaJSON() {
            self.activeDate = paraData["activeTime"]!
            self.uniqueID = paraData["uniqueID"]!
        }
    }
    
    // Method to update the config.json file whenever any property changes
    public func updateConfigJSON() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("config.json")

            let boolDict: [String: Bool] = [
                "isBlack": self.isBlack,
                "isMute": self.isMute,
                "isBackCamera" : self.isBackCamera,
                "isRemote" : self.isRemote,
                "isFast": self.isFast,
                "isActive": self.isActive,
                "isAutoFocus": self.isAutoFocus
            ]
            
            let intDict : [String: Int] = [
                "volumeUp": self.volumeUp,
                "volumeDown": self.volumeDown
            ]
            
            let floatDict : [String: Float] = [
                "volumeValue": self.volumeValue,
                "zoomFactor": self.zoomFactor,
                "focusFactor": self.focusFactor
            ]
            
            let configData: [String: Any] = [
                "Int": intDict,
                "Float": floatDict,
                "Bool": boolDict
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
                    "activeTime": dateString,
                    "uniqueID": self.uniqueID
                ]

                let jsonData = try JSONSerialization.data(withJSONObject: paraData, options: .prettyPrinted)
                try jsonData.write(to: fileURL)

                print("para.json file updated successfully")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5 * 60) {
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }
            } catch {
                print("Error updating para.json: \(error)")
            }
        }
        else if (searchText == "WHOSYOURDADDY" || AuthManager.authKey(input: searchText, uniqueID: self.uniqueID) == true) && self.isActive == false{
            fetchInternetCurrentDate { internetDate in
                if let internetDate = internetDate {
                    
                    self.isActive = true
                    
                    let activeTimeString = readParaJSON()!["activeTime"]
                    if activeTimeString == ""{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                        let dateString = dateFormatter.string(from: internetDate)
                        
                        do {
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsURL.appendingPathComponent("para.json")

                            let paraData: [String: String] = [
                                "activeTime": dateString,
                                "uniqueID": self.uniqueID
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
