import Foundation
import SwiftUI
import CoreML
import Vision
import CryptoKit

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
    
    @Published var isLogin : Bool = false
    
    var dateKey : SymmetricKey?
    @Published var trueDate : String = ""
    @Published var isActive : Bool = false
    

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
        }
        
        if self.activeDate == "测试版" || AuthManager.authKey(input: self.authKey, uniqueID: self.uniqueID) == true{
            self.isActive = true
        }
        
        do{
            // 自定义密钥字符串
            let keyData = "_isCameraSetting".md5().hexToBytes()
            
            // 使用自定义的密钥数据创建 SymmetricKey
            self.dateKey = SymmetricKey(data: keyData!)
            
            if self.activeDate == "测试版"{
                self.trueDate = "测试版"
            }
            else if self.activeDate != ""{
                self.trueDate = try decrypt(self.activeDate, key: self.dateKey!)!
            }
        }
        catch{
            
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

            print("config.json file updated successfully")
        } catch {
            print("Error updating config.json: \(error)")
        }
    }
    
    public func onReturnKeyPressed(searchText: String){
        if searchText == "pangu" && self.isActive{
            timeCheck()
        }
        else if searchText == "pangutest" && !self.isActive{
            self.isActive = true
            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsURL.appendingPathComponent("para.json")

                let paraData: [String: String] = [
                    "activeTime": "测试版",
                    "uniqueID": self.uniqueID,
                    "authKey": ""
                ]

                let jsonData = try JSONSerialization.data(withJSONObject: paraData, options: .prettyPrinted)
                try jsonData.write(to: fileURL)
                
                print("para.json file updated successfully")
            } catch {
                print("Error updating para.json: \(error)")
            }
        }
        else if AuthManager.authKey(input: searchText, uniqueID: self.uniqueID) == true && self.authKey == ""{
            fetchInternetCurrentDate { internetDate in
                if let internetDate = internetDate {
                    
                    self.isActive = true
                    self.authKey = searchText
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                    let dateString = dateFormatter.string(from: internetDate)
                    
                    do {
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileURL = documentsURL.appendingPathComponent("para.json")

                        let paraData: [String: String] = [
                            "activeTime": try self.encrypt(dateString, key: self.dateKey!),
                            "uniqueID": self.uniqueID,
                            "authKey": self.authKey
                        ]

                        let jsonData = try JSONSerialization.data(withJSONObject: paraData, options: .prettyPrinted)
                        try jsonData.write(to: fileURL)

                        print("para.json file updated successfully")
                    } catch {
                        print("Error updating para.json: \(error)")
                    }
                }
            }
        }
    }
    
    public func timeCheck(){
        
        fetchInternetCurrentDate { internetDate in
            
            let activeTimeString = self.trueDate
            
            if let internetDate = internetDate {
                if activeTimeString == "测试版"{
                    self.isLogin = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5 * 60) {
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    }
                }
                else if activeTimeString != ""{
                    // 格式化日期字符串为 Date 对象
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let activeTime = dateFormatter.date(from: activeTimeString)
                        
                    if TimeLimitations(activeDate: activeTime!, nowDate: internetDate){
                        print("有效期内")
                        self.isLogin = true
                    }
                }
            }
            
            
        }
    }
    
    // 加密方法
    func encrypt(_ plaintext: String, key: SymmetricKey) throws -> String {
        let data = Data(plaintext.utf8)
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!.base64EncodedString()
    }

    // 解密方法
    func decrypt(_ base64Ciphertext: String, key: SymmetricKey) throws -> String? {
        guard let ciphertext = Data(base64Encoded: base64Ciphertext) else { return nil }
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8)
    }
}

