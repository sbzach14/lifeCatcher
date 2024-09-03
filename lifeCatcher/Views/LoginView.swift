import SwiftUI
import Localize_Swift

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

    @EnvironmentObject var loginStatus: AppViewModel
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                if case .loggedOut = loginStatus.appState {
                    // Username input
                    TextField("Username".localized(), text: $username)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)

                    // Password input with visibility toggle
                    HStack {
                        if showPassword {
                            TextField("Password".localized(), text: $password)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        } else {
                            SecureField("Password".localized(), text: $password)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 20)
                    }

                    // Remember Password checkbox
                    Toggle(isOn: $rememberPassword) {
                        Text("Remember Password".localized()).foregroundColor(.gray)
                    }
                    .padding(.horizontal, 30)

                    HStack{
                        // 验证码输入框
                        TextField("Verification Code".localized(), text: $vericode)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        
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
                        if vericode != loginStatus.vericode{
                            showAlert = true
                            alertMessage = "Verification Code Error"
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

                    // Register button
                    NavigationLink(destination: RegisterView().environmentObject(loginStatus)) {
                        Text("Sign Up".localized())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }

                    // Error alert
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error".localized()), message: Text(alertMessage.localized()), dismissButton: .default(Text("OK")))
                    }
                } else if case .loggedIn(username: loginStatus.userInfo?.username) = loginStatus.appState {
                    
                    VStack {
                        // 显示当前登录账号，居中加粗
                        if let username = loginStatus.userInfo?.username {
                            Text(username)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
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

                        // 登出按钮
                        Button(action: {
                            // 执行登出操作
                            loginStatus.userInfo = nil // 清除用户名
                            loginStatus.appState = .loggedOut // 设置状态为已登出
                            AuthManager.isLoginServer = false
                            AuthManager.loginStatus = -1
                        }) {
                            Text("Sign Out".localized())
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }.padding(.top, 20)
                
            Spacer()
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle("Account".localized())

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
        
        let parameters: [String: Any] = [
            "deviceID": AuthManager.retrieveUUID(),
            "username": username,
            "password": password,
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

                    if (returnAccountStatus == 1 && AuthManager.authOnline())
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
            }
        }
        task.resume()
    }
}
