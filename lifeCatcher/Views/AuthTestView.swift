import SwiftUI

struct AuthTestView: View {
    @State private var userInput = ""
    @State private var passcode = ""
    @State private var activeKey = ""
    @State private var isAuthorized = false
    @State private var activateStatus = -1
    @State private var expiredTime = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var timeLimit = "One" // Add the state variable for timeLimit
    @State private var isTimeLimited = false // Add this state variable to track Toggle state


    var body: some View {
        VStack {
            TextField("Enter your Key here", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Enter your Passcode here", text: $passcode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack{
                
                Button(action: {
                    if containsOnlyHalfWidthUppercaseAndDigits(self.userInput){
                        self.activeKey = AuthManager.hashWithSalt(input: self.userInput)!
                    }
                    else{
                        showAlert = true
                        alertMessage = "非法序列号，请手动输入。"
                    }
                }, label: {
                    Text("Generate")
                })
                .padding()
                
                Spacer()
                
                Button(action: {
                    if containsOnlyHalfWidthUppercaseAndDigits(self.userInput){
                        self.activeKey = AuthManager.hashWithSalt(input: self.userInput)!
                        sendActivateRequest()
                    }
                    else{
                        showAlert = true
                        alertMessage = "非法序列号，请手动输入。"
                    }
                }, label: {
                    Text("Authorize")
                })
                .padding()
            }
            
            ScrollView{
                Text(activeKey)
                    .textSelection(.enabled)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
            }

            
            Text("Activation Status: \(activateStatus)").foregroundColor(.white)
            

            Text("Expired Time: \(expiredTime)").foregroundColor(.white)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage),
                message: Text(""),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle("Auth".localized())
    }

    private func sendActivateRequest() {
        guard let url = URL(string: "http://1.94.17.30:8080/activate") else { return }
        
        self.activeKey = AuthManager.hashWithSalt(input: self.userInput)!
        
        
        
        let json: [String: Any] = [
            "activate_code": activeKey,
            "passCode": passcode,
            "deviceID": userInput,
            "timeLimit": timeLimit
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: json)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "激活失败"
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = jsonResponse["success"] as? Bool, success {
                        DispatchQueue.main.async {
                            let returnActivateStatus = jsonResponse["activateStatus"] as? Int ?? -1
                            let returnExpiredTime = jsonResponse["expiredTime"] as? Int ?? 0
                            self.activateStatus = jsonResponse["activateStatus"] as? Int ?? -1
                            self.expiredTime = jsonResponse["expiredTime"] as? Int ?? 0
                          
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert = true
                            self.alertMessage = "激活失败"
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "激活失败"
                }
            }
        }

        task.resume()
    }
    
    func containsOnlyHalfWidthUppercaseAndDigits(_ input: String) -> Bool {
        return input.allSatisfy { char in
            if let scalar = char.unicodeScalars.first {
                // 检查是否是半角大写字母、数字或 '-'
                return (scalar.value >= 0x41 && scalar.value <= 0x5A) || // A-Z
                       (scalar.value >= 0x30 && scalar.value <= 0x39) || // 0-9
                       (char == "-") // -
            }
            return false
        }
    }
}


