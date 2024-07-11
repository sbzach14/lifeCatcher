import UIKit
import ZIPFoundation
import CryptoSwift
import Zip
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 启动时清空临时目录
        clearTemporaryDirectory()
        
        // 进行解密操作
        do {
            let encryptedZipFile_det = "detect_01.mlmodelc"
            let decryptionKey_det = AuthManager.returnDeformString(input: "com.apple.ttsbundle.Tong-Tong-compact")
            let decryptionIV_det = AuthManager.returnDeformString(input: "show_Alert")
            AuthManager.det_model_url = try decryptAndUnzip(encryptedZipFile: encryptedZipFile_det, decryptionKey: decryptionKey_det, decryptionIV: decryptionIV_det)
            
            let encryptedZipFile_cls = "cls_01.mlmodelc"
            let decryptionKey_cls = AuthManager.returnDeformString(input: "com.apple.ttsbundle.siri_female_zh-CN_compact")
            let decryptionIV_cls = AuthManager.returnDeformString(input: "camera_Image")
            AuthManager.cls_model_url = try decryptAndUnzip(encryptedZipFile: encryptedZipFile_cls, decryptionKey: decryptionKey_cls, decryptionIV: decryptionIV_cls
            )
            
        } catch {
            print("解密操作失败：\(error)")
        }
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // 退出时清空临时目录
        clearTemporaryDirectory()
    }

    // 清空临时目录
    func clearTemporaryDirectory() {
        let fileManager = FileManager()
        
        // Get the Documents directory path in the app's sandbox
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Create the config.json file URL
        let tempDirectory = documentsURL.appendingPathComponent("model")
        
        do{
            if !FileManager.default.fileExists(atPath: tempDirectory.path){
                try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            else{
                let tempDirectoryContents = try fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil, options: [])
                for file in tempDirectoryContents {
                    try fileManager.removeItem(at: file)
                }
            }
        }
        catch{
            
        }
    }

    // 解密并解压 ZIP 文件
    func decryptAndUnzip(encryptedZipFile: String, decryptionKey: String, decryptionIV: String) throws -> URL  {
        let fileManager = FileManager()
        
        let encryptedZipPath = Bundle.main.path(forResource: encryptedZipFile, ofType: "enc")!
        let encryptedURL = URL(fileURLWithPath: encryptedZipPath)
        
        // Get the Documents directory path in the app's sandbox
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Create the config.json file URL
        let tempDirectoryURL = documentsURL.appendingPathComponent("model")
        
        let decryptedZipURL = tempDirectoryURL.appendingPathComponent(encryptedZipFile).appendingPathExtension("zip")
        
        // 读取加密的 ZIP 文件数据
        let encryptedData = try Data(contentsOf: encryptedURL)
        
        let keybytes = decryptionKey.md5().hexToBytes()!
        let ivbytes = decryptionIV.md5().hexToBytes()!
        
        // 使用 AES 解密 ZIP 文件数据
        let decryptedData = try AES(key: keybytes, blockMode: CBC(iv: ivbytes), padding: .pkcs7).decrypt(encryptedData.bytes)
        
        // 写入解密后的 ZIP 文件数据
        try Data(decryptedData).write(to: decryptedZipURL)
        
        do {
            try Zip.unzipFile(decryptedZipURL, destination: tempDirectoryURL, overwrite: true, password: "password", progress: { (progress) -> () in
                    print(progress)
                }) // Unzip
        } catch {
            print("解压缩失败: \(error.localizedDescription)")
        }
        
        // 删除解密后的 ZIP 文件
        try fileManager.removeItem(at: decryptedZipURL)
        
        return decryptedZipURL.deletingPathExtension()
    }
}

extension String {
    func hexToBytes() -> [UInt8]? {
        var bytes = [UInt8]()
        var index = self.startIndex
        
        while index < self.endIndex {
            let nextIndex = self.index(index, offsetBy: 2)
            let substr = self[index..<nextIndex]
            
            if let byte = UInt8(substr, radix: 16) {
                bytes.append(byte)
            } else {
                return nil // 如果无法转换为字节，则返回空
            }
            
            index = nextIndex
        }
        
        return bytes
    }
}
