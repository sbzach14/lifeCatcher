import Foundation
import SwiftUI
import CoreML
import Vision
import CryptoKit
import CryptoSwift

class SettingViewModel: ObservableObject {
    
    @Published var isBackCamera: Bool = false
    @Published var isCameraHorizon: Bool = true
    @Published var isHighHz: Bool = true
    @Published var isMaxLightness: Bool = false
    
    @Published var activeDate: String = ""
    @Published var uniqueID: String = ""
    @Published var authKey: String = ""
    
    @Published var volumeUp: Int = 0
    @Published var volumeDown: Int = 0
    @Published var blackMode: Int = 0
    @Published var voiceDevice: Int = 0
    @Published var timeMode: Int = 0
    @Published var addCardMode: Int = 1

    
    @Published var volumeValue: Float = 0.5
    @Published var voiceRate: Float = 0.5
    @Published var zoomFactor: Float = 0
    @Published var focusFactor: Float = 0.6
    @Published var blackFactor: Float = 0
    
    var dateKey : SymmetricKey?
    @Published var trueVersion : String = ""
    @Published var trueDate : String = ""
    

    public init() {
        // Load data from config.json
        if let configData = readConfigJSON() {
            let boolDict = configData["Bool"] as! [String : Bool]
            self.isBackCamera = boolDict["isBackCamera"]!
            self.isCameraHorizon = boolDict["isCameraHorizon"]!
            self.isHighHz = boolDict["isHighHz"]!
            self.isMaxLightness = boolDict["isMaxLightness"]!
            
            let intDict = configData["Int"] as! [String : Int]
            self.volumeUp = intDict["volumeUp"]!
            self.volumeDown = intDict["volumeDown"]!
            self.blackMode = intDict["blackMode"]!
            self.voiceDevice = intDict["voiceDevice"]!
            self.timeMode = intDict["timeMode"]!
            self.addCardMode = intDict["addCardMode"]!
            
            let floatDict = configData["Float"] as! [String : Float]
            self.volumeValue = floatDict["volumeValue"]!
            self.voiceRate = floatDict["voiceRate"]!
            self.zoomFactor = floatDict["zoomFactor"]!
            self.focusFactor = floatDict["focusFactor"]!
            self.blackFactor = floatDict["blackFactor"]!
        }
        
        if let paraData = readParaJSON() {
            self.activeDate = paraData["activeTime"] ?? ""
            self.uniqueID = paraData["uniqueID"] ?? ""
            self.authKey = paraData["authKey"] ?? ""
        }
            
        if uniqueID == ""{
            uniqueID = AuthManager.retrieveUUID()
        }
        
        if AuthManager.isLoginServer{
            
            if AuthManager.authLocal(){
                do{
                    // 自定义密钥字符串
                    let keyData = "_isCameraSetting".md5().hexToBytes()
                    
                    // 使用自定义的密钥数据创建 SymmetricKey
                    self.dateKey = SymmetricKey(data: keyData!)
                    
                    self.trueDate = try AuthManager.decrypt(self.activeDate, key: self.dateKey!)
                    self.trueVersion = "正式版"
                }
                catch{
                    
                }
            }
            else if AuthManager.loginStatus == 1{
                self.trueDate = AuthManager.activeDate
                self.trueVersion = "正式版"
            }
            else if AuthManager.loginStatus == 2{
                self.trueDate = AuthManager.activeDate
                self.trueVersion = "测试版"
            }
        }

    }

    // Method to update the config.json file whenever any property changes
    public func updateConfigJSON() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("config.json")
            let languageFileURL = documentsURL.appendingPathComponent("language.json")

            let boolDict: [String: Bool] = [
                "isBackCamera" : self.isBackCamera,
                "isCameraHorizon": self.isCameraHorizon,
                "isHighHz": self.isHighHz,
                "isMaxLightness": self.isMaxLightness,
                
            ]
            
            let intDict : [String: Int] = [
                "volumeUp": self.volumeUp,
                "volumeDown": self.volumeDown,
                "blackMode": self.blackMode,
                "voiceDevice": self.voiceDevice,
                "timeMode": self.timeMode,
                "addCardMode": self.addCardMode
            ]
            
            let floatDict : [String: Float] = [
                "volumeValue": self.volumeValue,
                "voiceRate": self.voiceRate,
                "zoomFactor": self.zoomFactor,
                "focusFactor": self.focusFactor,
                "blackFactor": self.blackFactor
            ]
            
            let configData: [String: Any] = [
                "Int": intDict,
                "Float": floatDict,
                "Bool": boolDict,
                "Version": AuthManager.version
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: configData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)

            // print("config.json file updated successfully")
        } catch {
            // print("Error updating config.json: \(error)")
        }
    }
}

