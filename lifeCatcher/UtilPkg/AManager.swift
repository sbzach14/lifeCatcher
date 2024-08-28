import UIKit
import Security
import Foundation
import CryptoKit
import CoreML

class AuthManager {
    
    static var det_model_url : URL = URL(fileURLWithPath: "")
    static var cls_model_url : URL = URL(fileURLWithPath: "")
    static var detectModel: MLModel?
    
    static var deviceID: String = ""
    static var isLoginServer: Bool = false
    static var loginStatus: Int = -1
    static var activeTime: String = ""
 
    static func getUniqueID() -> String? {
        // 获取设备ID
        let keychainIdentifier = UIDevice.current.identifierForVendor!.uuidString
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = keychainIdentifier
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            // 如果标识符在钥匙串中存在，则返回它
            if let existingItem = item as? [String: Any],
               let data = existingItem[kSecAttrGeneric as String] as? Data,
               let identifier = String(data: data, encoding: .utf8) {
                return identifier
            }
        } else if status == errSecItemNotFound {
            // 如果标识符在钥匙串中不存在，则创建一个新的并存储它
            let newID = UUID().uuidString
            let data = newID.data(using: .utf8)!
            query[kSecValueData as String] = data
            let status = SecItemAdd(query as CFDictionary, nil)
            
            if status == errSecSuccess {
                return newID
            }
        }
        
        // 如果出现错误，则返回nil
        return nil
    }
    
    static func hashWithSalt(input: String) -> String? {
        
        let salt1: String = returnDeformString(input: "Jimei.MyUIViewController")
        let salt2: String = returnDeformString(input: "_Laplacian")
        
        // 使用SHA-512哈希算法对新字符串进行哈希加密
        let hashedData = SHA512.hash(data: Data((salt1 + input + salt2).utf8))
        // 将哈希值转换成字符串
        let hash = hashedData.map { String(format: "%02hhx", $0) }.joined()
        
        return hash
    }
    
    static func authKey(input: String, uniqueID: String) -> Bool? {
        guard let hash = hashWithSalt(input: uniqueID) else {
            return nil
        }
        
        return hash == input
    }
    
    static func authOnline() -> Bool{
        var isActive = false
        if isLoginServer{
            //正式
            if loginStatus == 0{
                isActive = true
            }
            //测试
            else if loginStatus == 1{
                autoQuit()
                isActive = true
            }
        }
        return isActive
    }
    
    static func authLocal() -> Bool {
        let paraData = readParaJSON()!
        let activeDate = paraData["activeTime"]!
        let uniqueID = paraData["uniqueID"]!
        let authKey = paraData["authKey"]!
        
        var isActive = false
        
        if loginStatus != 4{
            
            if activeDate == "测试版"{
                autoQuit()
                isActive = true
            }
            
            else if AuthManager.authKey(input: authKey, uniqueID: uniqueID) == true{
                do{
                    let keyData = "_isCameraSetting".md5().hexToBytes()
                    
                    // 使用自定义的密钥数据创建 SymmetricKey
                    let dateKey = SymmetricKey(data: keyData!)
                    let trueDate = try decrypt(activeDate, key: dateKey)!
                    isActive = timeCheck(trueDate: trueDate)
                }
                catch{
                    
                }
            }
        }

        return isActive
    }
    
    static func returnString(input: String)->String{
        return input
    }
    
    static func returnDeformString(input: String)->String{
        return input.replacingOccurrences(of: "a", with: "@").replacingOccurrences(of: "e", with: "#").replacingOccurrences(of: "i", with: "$").replacingOccurrences(of: "o", with: "%").replacingOccurrences(of: "u", with: "^")
    }
    
    static func randomChar()-> String{
        var charList = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l",
                        "m","n","o","p","q","r","s","t","u","v","w","x","y","z","~","!","@","#","$","%","^","&",
                        "*","(",")",".","_"]
        
        return charList.randomElement()!
    }
    
    static func storeUUID() {
        let uuidKey = "com.lifeCatcher.uniqueUUID"
        
        if let savedUUID = KeychainHelper.shared.getUUIDFromKeychain(forKey: uuidKey) {
            print("UUID already exists: \(savedUUID)")
        } else {
            let newUUID = UUID().uuidString
            KeychainHelper.shared.saveUUIDToKeychain(uuid: newUUID, forKey: uuidKey)
            print("New UUID saved: \(newUUID)")
        }
    }
    
    static func retrieveUUID() -> String {
        let uuidKey = "com.lifeCatcher.uniqueUUID"
        return KeychainHelper.shared.getUUIDFromKeychain(forKey: uuidKey)!
    }
    
    static func deleteStoredUUID() {
        let uuidKey = "com.lifeCatcher.uniqueUUID"
        KeychainHelper.shared.deleteUUIDFromKeychain(forKey: uuidKey)
    }

    // 加密方法
    static func encrypt(_ plaintext: String, key: SymmetricKey) throws -> String {
        let data = Data(plaintext.utf8)
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!.base64EncodedString()
    }

    // 解密方法
    static func decrypt(_ base64Ciphertext: String, key: SymmetricKey) throws -> String? {
        guard let ciphertext = Data(base64Encoded: base64Ciphertext) else { return nil }
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8)
    }
    
    static func autoQuit(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5 * 60) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
    }
    
    static func timeCheck(trueDate: String) -> Bool{
        var isInTime = false
        fetchInternetCurrentDate { internetDate in
            if let internetDate = internetDate{
                // 格式化日期字符串为 Date 对象
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let activeTime = dateFormatter.date(from: trueDate)
                
                if TimeLimitations(activeDate: activeTime!, nowDate: internetDate){
                    // print("有效期内")
                    isInTime = true
                }
            }
        }
        return isInTime
    }

}
