import SwiftUI
import Localize_Swift
import CryptoKit
import Foundation
import DeviceCheck

struct MainMenuView: View {
    @StateObject var loginStatus = AppViewModel()
    @State private var historyNavigate: Int? = -1
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    
    @AppStorage("appLanguage") private var appLanguage: String = "en"

    var body: some View {
        NavigationView {
            
            ZStack{
                VStack {
                    Divider().colorInvert()
                    
                    Image("sampleImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .bubbleBackground()
                    
                    Spacer()
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        NavigationLink(destination: OriginVisionObjectRecognitionView()) {
                            VStack {
                                Image(systemName: "camera")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Collect".localized())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                        }
                        
                        VStack {
                            Button(action: {
                                if !AuthManager.isLoginServer{
                                    historyNavigate = 0
                                } else if AuthManager.isActive{
                                    historyNavigate = 1
                                } else {
                                    historyNavigate = 2
                                }
                            }) {
                                VStack {
                                    Image(systemName: "clock")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("History".localized())
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                            }
                            .background(
                                NavigationLink(destination: LoginView().environmentObject(loginStatus), tag: 0, selection: $historyNavigate) { EmptyView() }
                            )
                            .background(
                                NavigationLink(destination: DeprecatedMainView(), tag: 1, selection: $historyNavigate) { EmptyView() }
                            )
                            .background(
                                NavigationLink(destination: HistoryView(), tag: 2, selection: $historyNavigate) { EmptyView() }
                            )
                        }
                        
                        NavigationLink(destination: InfoView()) {
                            VStack {
                                Image(systemName: "info.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Information".localized())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                        }
                        
                        NavigationLink(destination: LoginView().environmentObject(loginStatus)) {
                            VStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Account".localized())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                        }
                        
                        NavigationLink(destination: AuthTestView()) {
                            VStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Auth".localized())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                        }
                        
                    }
                    
                    Spacer()
                    
                    Image("lifeCatcherTitle")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .padding(.bottom, 20)
                        .cornerRadius(10)
                    
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleLanguage) {
                        Text(appLanguage == "en" ? "中文" : "EN")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                Localize.setCurrentLanguage(appLanguage)
                AutoLogin(username: "", password: "")
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage),dismissButton: .default(Text("OK")))
            }
            .navigationTitle("LifeCatcher".localized())
        }
        .persistentSystemOverlays(.hidden)
    }

    private func toggleLanguage() {
        if appLanguage == "en" {
            appLanguage = "zh-Hans" // Simplified Chinese code
        } else {
            appLanguage = "en"
        }
        Localize.setCurrentLanguage(appLanguage)
    }
    
    func AutoLogin(username: String, password: String) {
        
        if AuthManager.isLoginServer
        {
            isLoading = false
            return
        }
        
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
            
            //传递版本号，2.0.2用新逻辑登录，否则用旧逻辑
            //客户端发送加密的time_deviceID_token
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
            let rawData = timestamp + "_" + AuthManager.retrieveUUID() + "_" + tokenString
            
            
            let encryptString = try! AuthManager.encrypt(rawData, key: dataKey)
//            测试密文
//            print("测试密文 \(encryptString)")
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
                let returnMessage = jsonResponse?["message"] as? String ?? ""
                
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
                    else{
                        print("验证失败")
                    }
                //登陆失败
                } else {
                    print("登录失败")
                }
                
                if returnMessage != ""{
                    showAlert = true
                    alertMessage = returnMessage
                }
                
                isLoading = false
            }
            task.resume()
        }
    }

}


struct DeprecatedMainView: View {
    var body: some View {
        ZStack{
            //Image("Logo")
            VStack {
                NavigationLink(
                    destination: SettingRecordView(configType: 0)
                ) {
                    VStack(alignment: .leading) {
                        Text("历史记录  (界面样式1)")
                            .foregroundColor(.white)
                        Divider().colorInvert()
                    }
                    .padding()
                }
                NavigationLink(
                    destination: SettingRecordView(configType: 1)
                ) {
                    VStack(alignment: .leading) {
                        Text("历史记录  (界面样式2)")
                            .foregroundColor(.white)
                        Divider().colorInvert()
                    }
                    .padding()
                }
                NavigationLink(
                    destination: DeprecatedInfoView()
                ) {
                    VStack(alignment: .leading) {
                        Text("功能设置")
                            .foregroundColor(.white)
                        Divider().colorInvert()
                    }
                    .padding()
                }
                
                Spacer()
            }
            
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarTitle("幻影")
    }
}
