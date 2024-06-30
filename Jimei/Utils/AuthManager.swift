import UIKit
import Security
import Foundation
import CryptoKit
import CoreML


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
        // 使用SHA-512哈希算法对新字符串进行哈希加密
        let hashedData = SHA512.hash(data: Data(("~Hello!From@The#Other$Side%" + input).utf8))
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

    // 解密模型文件
//    static func decryptModel(target: String, key: [UInt8]) -> URL? {
//        let detect_key: [UInt8] = [0xe4, 0xb3, 0xd0, 0x49, 0x21, 0xe1, 0x7f, 0xfd, 0x43, 0x88, 0x13, 0x1c, 0xe2, 0x65, 0xaf, 0xb1]
//        let cls_key: [UInt8] = [0xcc, 0x11, 0x63, 0x20, 0xec, 0xb0, 0xa8, 0x1c, 0xe7, 0xc1, 0x6c, 0xbf, 0x84, 0xae, 0xbe, 0xbf]
//
//        let encryptedModelURL = Bundle.main.url(forResource: target + ".mlmodel.enc", withExtension: nil)!
//        let decryptedModelURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(target + ".mlmodel")
//
//        do {
//            let encryptedData = try Data(contentsOf: encryptedModelURL)
//            let iv = Array(encryptedData.prefix(16))
//            let ciphertext = Array(encryptedData.suffix(from: 16))
//
//            let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
//            let decryptedData = try aes.decrypt(ciphertext)
//
//            try decryptedData.write(to: decryptedModelURL)
//            return decryptedModelURL
//        } catch {
//            print("Failed to decrypt model: \(error)")
//            return nil
//        }
//    }

}
