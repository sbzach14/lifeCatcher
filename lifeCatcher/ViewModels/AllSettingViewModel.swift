import Foundation
import SwiftUI
import CoreML
import Vision
import CryptoKit
import CryptoSwift

class SettingViewModel: ObservableObject {
    @Published var isBlack: Bool = false
    @Published var isMute: Bool = false
    @Published var isBackCamera: Bool = false
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
    @Published var language: Int = 0
    
    var dateKey : SymmetricKey?
    @Published var trueVersion : String = ""
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
            self.authKey = paraData["authKey"]!
            
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
                else if AuthManager.loginStatus == 1 && AuthManager.authOnline(){
                    self.trueDate = AuthManager.activeDate
                    self.trueVersion = "正式版"
                }
                else if AuthManager.loginStatus == 2{
                    self.trueDate = AuthManager.activeDate
                    self.trueVersion = "测试版"
                }
            }
        }
        if let languageData = readLanguageJSON(){
            self.language = languageData["languageSetting"] as! Int
            
        }
    }

    // Method to update the config.json file whenever any property changes
    public func updateConfigJSON() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("config.json")
            let languageFileURL = documentsURL.appendingPathComponent("language.json")

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
            
            let languageDict : [String: Int] = [
                "languageSetting": 0,
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: configData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            
            let languageJsonData = try JSONSerialization.data(withJSONObject: languageDict, options: .prettyPrinted)
            try languageJsonData.write(to: languageFileURL)

            // print("config.json file updated successfully")
        } catch {
            // print("Error updating config.json: \(error)")
        }
    }
}

