import SwiftUI
import Localize_Swift
import CryptoKit
import DeviceCheck

enum AppState {
    case loggedOut
    case loggedIn(username: String)
}

struct UserInfo {
    var username: String
}


struct LoginView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "savedUsername") ?? ""    
    @State private var rememberPassword = UserDefaults.standard.bool(forKey: "savedRememberFlag")
    @State private var password: String = UserDefaults.standard.string(forKey: "savedPassword") ?? ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isAction: Bool = true
    @State private var showPassword = false
    @State private var vericode: String = ""
    @State private var isLoading: Bool = false

    @EnvironmentObject var loginStatus: AppViewModel
    
    var body: some View {
        ZStack{
            VStack {
                VStack(spacing: 20) {
                    if case .loggedOut = loginStatus.appState {
                        // Username input
                        ZStack(alignment: .leading){
                            if username == ""{
                                Text("Username".localized())
                                    .foregroundColor(.white) // 占位符文本颜色
                                    .opacity(0.5) // 仅在没有输入时显示占位符
                                    .padding(.leading, 40)
                            }
                            TextField("", text: $username)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .foregroundColor(.white)
                        }
                        
                        // Password input with visibility toggle
                        HStack {
                            if showPassword {
                                ZStack(alignment: .leading){
                                    if password == ""{
                                        Text("Password".localized())
                                            .foregroundColor(.white) // 占位符文本颜色
                                            .opacity(0.5) // 仅在没有输入时显示占位符
                                            .padding(.leading, 40)
                                    }
                                    TextField("", text: $password)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 20)
                                        .foregroundColor(.white)
                                }
                            } else {
                                ZStack(alignment: .leading){
                                    if password == ""{
                                        Text("Password".localized())
                                            .foregroundColor(.white) // 占位符文本颜色
                                            .opacity(0.5) // 仅在没有输入时显示占位符
                                            .padding(.leading, 40)
                                    }
                                    
                                    SecureField("", text: $password)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 20)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                            }
                            .padding(.trailing, 20)
                        }
                        
                        // Remember Password checkbox
                        Toggle(isOn: $rememberPassword) {
                            Text("Remember Password".localized()).foregroundColor(.gray)
                        }
                        .padding(.horizontal, 30)
                        
                        HStack{
                            ZStack(alignment: .leading){
                                if vericode == ""{
                                    Text("Verification Code".localized())
                                        .foregroundColor(.white) // 占位符文本颜色
                                        .opacity(0.5) // 仅在没有输入时显示占位符
                                        .padding(.leading, 40)
                                }
                                // 验证码输入框
                                TextField("", text: $vericode)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text(loginStatus.vericode)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 100)
                                .background(Color.gray)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .contextMenu {
                                    Text("") // 空的contextMenu意味着禁用所有默认操作
                                }
                        }
                        
                        // Sign In button
                        Button(action: {
                            if username == ""{
                                showAlert = true
                                alertMessage = "Username can not be empty.".localized()
                            }
                            else if password == ""{
                                showAlert = true
                                alertMessage = "Password can not be empty.".localized()
                            }
                            else if vericode != loginStatus.vericode{
                                showAlert = true
                                alertMessage = "Verification code error.".localized()
                            }
                            else{
                                loginUser()
                            }
                            loginStatus.resetVericode()
                        }) {
                            Text("Sign In".localized())
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                        
                        // Sign Up button
                        Button(action: {
                            if username == ""{
                                showAlert = true
                                alertMessage = "Username can not be empty.".localized()
                            }
                            else if password == ""{
                                showAlert = true
                                alertMessage = "Password can not be empty.".localized()
                            }
                            else if vericode != loginStatus.vericode{
                                showAlert = true
                                alertMessage = "Verification code error.".localized()
                            }
                            else{
                                registerUser()
                            }
                            loginStatus.resetVericode()
                        }) {
                            Text("Sign Up".localized())
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                    } else if case .loggedIn(username: loginStatus.userInfo?.username) = loginStatus.appState {
                        
                        VStack {
                            // 显示当前登录账号，居中加粗
                            if let username = loginStatus.userInfo?.username {
                                Text(username)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // 登陆成功提示
                            Text("You have logged in".localized())
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                    }
                }.padding(.top, 20)
                
                Spacer()
            }
            
            // 当 isLoading 为 true 时显示加载遮罩
            if isLoading {
                LoadingOverlay()
            }
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle("Account".localized())
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage.localized()),dismissButton: .default(Text("OK")))
        }

    }
    
    // 登录逻辑
    func loginUser() {
        isLoading = true
        
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
            
            
            //客户端发送加密的time_deviceid_token
            //服务端如果解密出的time在一分钟内，且deviceid是正式版，则校验token
            //服务端如果token正确，且excel记录里是正式版，那么返回加密的time_authkey, 否则返回空字符串
            //客户端解密并校验收到的time和authkey是否正确
            
            // 自定义密钥字符串
            let keyData = AuthManager.returnString(input: "_isCameraSetting").md5().hexToBytes()
            // 使用自定义的密钥数据创建 SymmetricKey
            let dataKey = SymmetricKey(data: keyData!)
            let rawData = timestamp + "_" + AuthManager.retrieveUUID() + "_" + tokenString
            let encryptString = try! AuthManager.encrypt(rawData, key: dataKey)
            
            let parameters: [String: Any] = [
                "username": username,
                "password": password,
                "encryptString": encryptString,
                "version": AuthManager.version
            ]
            
            UserDefaults.standard.set(username, forKey: "savedUsername")
            if rememberPassword {
                UserDefaults.standard.set(password, forKey: "savedPassword")
            } else {
                UserDefaults.standard.set("", forKey: "savedPassword")
            }
            UserDefaults.standard.set(rememberPassword, forKey: "savedRememberFlag")
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        showAlert = true
                        alertMessage = "Please check your network.".localized()
                    }
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
                let returnMessage = jsonResponse?["message"] as? String ?? ""
                
                let decryptString = try! AuthManager.decrypt(returnActiveCode, key: dataKey)
                let separatedStrings = decryptString.split(separator: "_")
                // 将结果转换为字符串数组
                let stringArray = separatedStrings.map { String($0) }
                let authtimestamp = stringArray[0]
                let authkey = stringArray[1]

                DispatchQueue.main.async {
                    if success {
                        // 更新为已登录状态并保存用户信息
                        loginStatus.appState = .loggedIn(username: username)
                        loginStatus.userInfo = UserInfo(username: username)
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
                        else if returnAccountStatus == 2{
                            AuthManager.isActive = true
                            AuthManager.autoQuit()
                            print("测试版")
                            showAlert = true
                            alertMessage = "五分钟后将自动退出"
                        }
                    //登陆失败
                    } else {
                        
                        var message: String = ""
                        if returnLoginStatus == 1{
                            message = "Wrong username".localized()
                        } else if returnLoginStatus == 2{
                            message = "Wrong password".localized()
                        } else if returnLoginStatus == 3{
                            message = "username is expired".localized()
                        } else if returnLoginStatus == 4{
                            message = "username does not exist".localized()
                        } else if returnAccountStatus == 3{
                            message = "The device is locked".localized()
                        }
                        
                        showAlert = true
                        alertMessage = message
                    }
                    
                    if returnMessage != ""{
                        showAlert = true
                        alertMessage = returnMessage
                    }
                }
                
                isLoading = false
            }
            task.resume()
        }
        
        
    }
    
    func registerUser() {
        isLoading = true
        
        guard let url = URL(string: "http://1.94.17.30:8080/register") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //获取设备序列号
        
        let body: [String: Any] = [
            "deviceID": AuthManager.retrieveUUID(),
            "username": username,
            "password": password,
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            print("Error in encoding request body: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in registration: \(error)")
                DispatchQueue.main.async {
                    self.alertMessage = "Please check your network.".localized()
                    self.showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "No data received.".localized()
                    self.showAlert = true
                }
                return
            }

            do {
                if let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let success = responseObject["success"] as? Bool ?? false
                    let registerStatus = responseObject["registerStatus"] as? Int ?? -1
                    DispatchQueue.main.async {
                        if success {
                            self.alertMessage = "register successfully".localized()
                        } else {
                            if registerStatus == 0{
                                self.alertMessage = "The device is registered".localized()
                            } else if registerStatus == 2 {
                                self.alertMessage = "Ilegal username".localized()
                            }
                        }
                        self.showAlert = true
                    }
                }
            } catch {
                print("Error in decoding response data: \(error)")
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to parse server response.".localized()
                    self.showAlert = true
                }
            }
            
            isLoading = false
        }

        task.resume()
    }
}
