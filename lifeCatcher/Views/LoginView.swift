import SwiftUI

enum AppState {
    case loggedOut
    case loggedIn(username: String)
}

struct UserInfo {
    var username: String
}


struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @ObservedObject var loginStatus: AppViewModel = AppViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if case .loggedOut = loginStatus.appState {
                // 用户名输入框
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                
                // 密码输入框
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                
                // 登录按钮
                Button(action: {
                    loginUser()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                
                // 注册账号按钮
                NavigationLink(destination: RegisterView()) {
                    Text("Register")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                
                // 错误提示框
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            } else if case .loggedIn(username: loginStatus.userInfo?.username) = loginStatus.appState {
                VStack {
                    Text("You have logged in")
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    
                    Button(action: {
                        // 执行退出登录操作
                        loginStatus.userInfo = nil // 清空用户名
                        loginStatus.appState = .loggedOut // 将状态改为未登录
                        ClassifierSettingArgs.isLoginServer = false
                    }) {
                        Text("退出登录")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }
                    .padding(.top, 20) // 给按钮与上方元素增加一些间距
                }
            }
        }
        .padding()
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill())
    }
    
    // 登录逻辑
    func loginUser() {
        guard !username.isEmpty, !password.isEmpty else {
            showAlert = true
            return
        }
        
        let url = URL(string: "http://1.94.17.30:8080/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //获取登陆的时间戳
        let timestamp = Int(Date().timeIntervalSince1970)

        let parameters: [String: Any] = [
            "deviceID": ClassifierSettingArgs.deviceID,
            "username": username,
            "password": password,
            "loginTime": timestamp
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    showAlert = true
                    alertMessage = "请检查网络连接"
                }
                return
            }
            let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
//            # account status
//            # -1, login error, 错误
//            # 0, formal version, 正式
//            # 1, test version, 测试
//            # 2, exipired, 超时
//            # 3, not activated, 未激活 appletest (True 3)
            
            let success = jsonResponse?["success"] as? Bool ?? false
            let message = jsonResponse?["message"] as? String ?? "对方什么也没说"
            let accountStatus = jsonResponse?["accountStatus"] as? Int ?? -1
            print("账号状态：\(accountStatus)")
            
            DispatchQueue.main.async {
                if success {
                    // 更新为已登录状态并保存用户信息
                    loginStatus.appState = .loggedIn(username: username)
                    loginStatus.userInfo = UserInfo(username: username)
                    ClassifierSettingArgs.isLoginServer = true
                } else {
                    showAlert = true
                    alertMessage = message
                }
            }
        }
        task.resume()
    }
}
