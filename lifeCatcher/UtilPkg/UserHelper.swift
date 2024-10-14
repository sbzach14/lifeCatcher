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
    
    //传递版本号，2.0.2用新逻辑登录，否则用旧逻辑
    //客户端发送加密的time_deviceid_token
    //服务端如果解密出的time在一分钟内，且deviceid是正式版，则校验token
    //服务器上校验token操作为向苹果接口发请求，返回一个设备标识符
    //（excel中新增一项设备标识符，默认为abc）
    //获取接口返回的设备标识符后，如果excel中为abc，则替换excel，且登录成功
    //如果excel中不为abc，则若设备标识符与excel相同即登录成功
    //如果正式版登录成功，那么返回加密的time_authkey。登录失败或是其他版本则返回空字符串
    //客户端解密并校验收到的time和authkey是否正确
    
    // 自定义密钥字符串
    let keyData = AuthManager.returnString(input: "_isCameraSetting").md5().hexToBytes()
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
