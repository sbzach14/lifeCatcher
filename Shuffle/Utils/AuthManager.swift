import UIKit
import Security
import Foundation
import CryptoKit

class AuthManager {
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
        // 设置盐值
        let salt = "hellofromtheotherside"
        // 将盐值和getUniqueID获得的字符串组合成一个新字符串
        let saltedInput = salt + input
        // 使用SHA-512哈希算法对新字符串进行哈希加密
        let hashedData = SHA512.hash(data: Data(saltedInput.utf8))
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

}
