//
//  UserHelper.swift
//  lifeCatcher
//
//  Created by Zhangyi Chen on 9/6/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

func AutoLogin(username: String, password: String) {
    let url = URL(string: "http://192.168.1.224:8080/login")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let parameters: [String: Any] = [
        "deviceID": AuthManager.retrieveUUID(),
        "username": username,
        "password": password,
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
        let returnActiveCode = jsonResponse?["active_code"] as? String ?? ""

//        DispatchQueue.main.async {
            if success {
                // 更新为已登录状态并保存用户信息
                AuthManager.isLoginServer = true
                AuthManager.loginStatus = returnAccountStatus
                let date = Date(timeIntervalSince1970: TimeInterval(returnExpiredTime))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年MM月dd日"
                let dateString = dateFormatter.string(from: date)
                AuthManager.activeDate = dateString
                
                print("过期时间 \(returnExpiredTime) \(dateString) 激活码 \(returnActiveCode)")


                if (returnAccountStatus == 1 && AuthManager.authOnline(onlineKey: returnActiveCode))
                    || AuthManager.authLocal(){
                    print("正式版")
                    AuthManager.isActive = true
                }
                else if returnAccountStatus == 2{
                    AuthManager.isActive = true
                    AuthManager.autoQuit()
                    print("测试版")
                }
            //登陆失败
            } else {
                
            }
//        }
    }
    task.resume()
    
}
