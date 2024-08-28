import Foundation
import SwiftUI
import CoreML
import Vision
import CryptoKit
import CryptoSwift

class SettingViewModel: ObservableObject {
    @Published var isBlack: Bool = false
    @Published var isMute: Bool = false
    @Published var isBackCamera: Bool = true
    @Published var isCameraHorizon: Bool = true
    @Published var isRemote: Bool = true
    @Published var isAutoFocus: Bool = true
    @Published var activeDate: String = ""
    @Published var uniqueID: String = ""
    @Published var authKey: String = ""
    @Published var volumeUp: Int = 0
    @Published var volumeDown: Int = 0
    @Published var volumeValue: Float = 0.5
    @Published var zoomFactor: Float = 0
    @Published var focusFactor: Float = 0.65
    
    var dateKey : SymmetricKey?
    @Published var trueDate : String = ""
    

    init() {
        // Load data from config.json
        if let configData = readConfigJSON() {
            let boolDict = configData["Bool"] as! [String : Bool]
            self.isBlack = boolDict["isBlack"]!
            self.isMute = boolDict["isMute"]!
            self.isBackCamera = boolDict["isBackCamera"]!
            self.isCameraHorizon = boolDict["isCameraHorizon"]!
            self.isRemote = boolDict["isRemote"]!
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
            print("uniqueID \(self.uniqueID)")
            self.authKey = paraData["authKey"]!
        }
        
        if AuthManager.authKey(input: self.authKey, uniqueID: self.uniqueID) == true{
            do{
                // 自定义密钥字符串
                let keyData = "_isCameraSetting".md5().hexToBytes()
                
                // 使用自定义的密钥数据创建 SymmetricKey
                self.dateKey = SymmetricKey(data: keyData!)
                
                self.trueDate = try AuthManager.decrypt(self.activeDate, key: self.dateKey!)!
            }
            catch{
                
            }
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
                "isCameraHorizon": self.isCameraHorizon,
                "isRemote" : self.isRemote,
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

            // print("config.json file updated successfully")
        } catch {
            // print("Error updating config.json: \(error)")
        }
    }
    
    public func onReturnKeyPressed(searchText: String){
        if AuthManager.authKey(input: searchText, uniqueID: self.uniqueID) == true && self.authKey == ""{
            fetchInternetCurrentDate { internetDate in
                if let internetDate = internetDate {
                    
                    self.authKey = searchText
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                    let dateString = dateFormatter.string(from: internetDate)
                    
                    do {
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileURL = documentsURL.appendingPathComponent("para.json")

                        let paraData: [String: String] = [
                            "activeTime": try AuthManager.encrypt(dateString, key: self.dateKey!),
                            "uniqueID": self.uniqueID,
                            "authKey": self.authKey
                        ]

                        let jsonData = try JSONSerialization.data(withJSONObject: paraData, options: .prettyPrinted)
                        try jsonData.write(to: fileURL)

                        // print("para.json file updated successfully")
                    } catch {
                        // print("Error updating para.json: \(error)")
                    }
                }
            }
        }
    }
}

