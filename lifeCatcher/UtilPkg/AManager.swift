import UIKit
import Security
import Foundation
import CryptoKit
import CoreML

class AuthManager {
    
    static var isLoginServer: Bool = false
    static var loginStatus: Int = 0
    static var isActive: Bool = false
    static var activeDate: String = ""
    
    static var version: String = "2.0.1"
 
    //deprecated
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
    
    static func hashWithTimeSalt(input: String) ->String?{
        let salt1: String = returnDeformString(input: "HYSECRET_HEAD")
        let salt2: String = returnDeformString(input: "MESSI_RONALDO")
        
        // 使用SHA-512哈希算法对新字符串进行哈希加密
        let hashedData = SHA512.hash(data: Data((salt1 + input + salt2).utf8))
        // 将哈希值转换成字符串
        let hash = hashedData.map { String(format: "%02hhx", $0) }.joined()
        
        return hash
    }
    
    static func activeAccount(input: String) -> Bool{
        var isSuccess = false
        let transInput = input
        if authKey(input: transInput, uniqueID: retrieveUUID()) && isLoginServer && loginStatus == 0{
            storeAuthKey(newKey: transInput)
            
            //TODO: post active request
                        
            let url = URL(string: "http://1.94.17.30:8080/activate")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let parameters: [String: Any] = [
                "deviceID": AuthManager.retrieveUUID(),
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        print("Please check your network.")
                    }
                    return
                }
                let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
    //            # activate status
    //            # 0, 设备未注册
    //            # 1, 设备已激活
    //            # 2, 激活成功
                
                let success = jsonResponse?["success"] as? Bool ?? false
                let returnAccountStatus = jsonResponse?["activateStatus"] as? Int ?? -1
                let returnExpiredTime = jsonResponse?["expiredTime"] as? Int ?? 0

                DispatchQueue.main.async {
                    if success {
                        // 更新为已登录状态并保存用户信息
                        isSuccess = true
                        print("激活成功")
                    //登陆失败
                    } else {
                        isSuccess = false
                        if returnAccountStatus == 0{
                            
                        } else if returnAccountStatus == 1{
                            
                        }
                    print("激活失败")
                    }
                }
            }
            task.resume()
        }
        return isSuccess
    }
    
    static func authKey(input: String, uniqueID: String) -> Bool {
        guard let hash = hashWithSalt(input: uniqueID) else {
            return false
        }
        
        return hash == input
    }
    
    static func authTime(onlineKey: String, localKey: String) -> Bool{
        if hashWithTimeSalt(input: localKey) == onlineKey{
            return true
        }
        else{
            return false
        }
    }
    
    static func authOnline(onlineKey: String) -> Bool{
        let uniqueID = retrieveUUID()
        let uniqueKey = retrieveAuthKey()
        if uniqueID != "" && uniqueKey != ""{
            return authKey(input: uniqueKey, uniqueID: uniqueID)
        } else if uniqueID != "" && uniqueKey == ""{
            let verifySuccess = authKey(input: onlineKey, uniqueID: uniqueID)
//            if verifySuccess == true {
//                storeAuthKey(newKey: onlineKey)
//            }
            return verifySuccess
        }
        else{
            return false
        }
    }
    
    static func authLocal() -> Bool {
        let paraData = readParaJSON()!
        let activeDate = paraData["activeTime"]!
        let uniqueID = paraData["uniqueID"]!
        let uniqueKey = paraData["authKey"]!
        
        if activeDate != "" && uniqueID != "" && uniqueKey != ""{
            var trueDate = ""
            do{
                let keyData = "_isCameraSetting".md5().hexToBytes()
                // 使用自定义的密钥数据创建 SymmetricKey
                let dateKey = SymmetricKey(data: keyData!)
                trueDate = try decrypt(activeDate, key: dateKey)
            }
            catch{
                
            }
            return authKey(input: uniqueKey, uniqueID: uniqueID) && timeCheck(trueDate: trueDate)
        }
        else{
            return false
        }
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
    
    static func storeAuthKey(newKey: String) {
        let uuidKey = "com.lifeCatcher.uniqueKey"
        
        if let savedKey = KeychainHelper.shared.getUUIDFromKeychain(forKey: uuidKey) {
            print("Key already exists: \(savedKey)")
        } else {
            KeychainHelper.shared.saveUUIDToKeychain(uuid: newKey, forKey: uuidKey)
            print("New Key saved: \(newKey)")
        }
    }
    
    static func retrieveAuthKey() -> String {
        let uuidKey = "com.lifeCatcher.uniqueKey"
        return KeychainHelper.shared.getUUIDFromKeychain(forKey: uuidKey) ?? ""
    }
    
    static func deleteStoredAuthKey() {
        let uuidKey = "com.lifeCatcher.uniqueKey"
        KeychainHelper.shared.deleteUUIDFromKeychain(forKey: uuidKey)
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
        return KeychainHelper.shared.getUUIDFromKeychain(forKey: uuidKey) ?? ""
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
    static func decrypt(_ base64Ciphertext: String, key: SymmetricKey) throws -> String {
        guard let ciphertext = Data(base64Encoded: base64Ciphertext) else { return "" }
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8) ?? ""
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
