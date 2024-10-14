import CryptoKit
import Foundation
import DeviceCheck

func AutoLogin(username: String, password: String) {
    let url = URL(string: "http://1.94.17.30:8080/login")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let timestamp = String(Date().timeIntervalSince1970)
    var tokenString = ""
    
    DCDevice.current.generateToken { (token, error) in
        if let error = error {
            print("Error generating device token: \(error.localizedDescription)")
            return
        }
        guard let token = token else {
            print("Token generation failed")
            return
        }
        
        // 将 token 发送到服务器进行验证
        tokenString = token.base64EncodedString()
        print("Device Token: \(tokenString)")
    }
    
    //客户端发送加密的time_deviceid_token
    //服务端如果解密出的time在一分钟内，且deviceid是正式版，则校验token
    //服务端如果token正确，且excel记录里是正式版，那么返回加密的time_authkey, 否则返回空字符串
    //客户端解密并校验收到的time和authkey是否正确
    
    // 自定义密钥字符串
    let keyData = "_isCameraSetting".md5().hexToBytes()
    // 使用自定义的密钥数据创建 SymmetricKey
    let dataKey = SymmetricKey(data: keyData!)
    let rawData = timestamp + "_" + AuthManager.getUniqueID()! + "_" + tokenString
    let encryptString = try! AuthManager.encrypt(rawData, key: dataKey)
    
    let parameters: [String: Any] = [
        "username": username,
        "password": password,
        "encryptString": encryptString,
        "version": AuthManager.version
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            return
        }
        let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
//            # account status
//            # 0, 未激活
//            # 1, 正式版
//            # 2, 测试版
        
        let success = jsonResponse?["success"] as? Bool ?? false
        let returnLoginStatus = jsonResponse?["loginStatus"] as? Int ?? -1
        let returnAccountStatus = jsonResponse?["accountStatus"] as? Int ?? -1
        let returnExpiredTime = jsonResponse?["expiredTime"] as? Int ?? 0
        let returnActiveCode = jsonResponse?["activated_code"] as? String ?? ""
        
        let decryptString = try! AuthManager.decrypt(returnActiveCode, key: dataKey)
        let separatedStrings = decryptString.split(separator: "_")
        // 将结果转换为字符串数组
        let stringArray = separatedStrings.map { String($0) }
        let authtimestamp = stringArray[0]
        let authkey = stringArray[1]
        
        if success {
            // 更新为已登录状态并保存用户信息
            AuthManager.isLoginServer = true
            AuthManager.loginStatus = returnAccountStatus
            let date = Date(timeIntervalSince1970: TimeInterval(returnExpiredTime))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let dateString = dateFormatter.string(from: date)
            AuthManager.activeDate = dateString
            
            if returnAccountStatus == 1 && AuthManager.authOnline(onlineKey: authkey) && timestamp == authtimestamp{
                print("正式版")
                AuthManager.isActive = true
            }
        //登陆失败
        } else {
            
        }
    }
    task.resume()
    
}
