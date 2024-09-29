import SwiftUI

struct AuthTestView: View {
    @State private var userInput = ""
    @State private var passcode = ""
    @State private var activeKey = ""
    @State private var isAuthorized = false
    @State private var activateStatus = -1
    @State private var expiredTime = 0
    @State private var showError = false
    @State private var timeLimit = "One" // Add the state variable for timeLimit
    @State private var isTimeLimited = false // Add this state variable to track Toggle state

    var body: some View {
        VStack {
            Text("Please enter your Auth Key:")
                .font(.headline)
                .padding()

            TextField("Enter your Key here", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Enter your Passcode here", text: $passcode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            // Add the Toggle here
                    Toggle(isOn: $isTimeLimited) {
                        Text("Enable Time Limit")
                    }
                    .padding()
                    .onChange(of: isTimeLimited) { value in
                        timeLimit = value ? "half" : "One"
                    }
            HStack{
                
                Button(action: {
                    self.activeKey = AuthManager.hashWithSalt(input: self.userInput)!
                }, label: {
                    Text("Generate")
                })
                .padding()
                
                Spacer()
                
                Button(action: {
                    self.activeKey = AuthManager.hashWithSalt(input: self.userInput)!
                    sendActivateRequest()
                }, label: {
                    Text("Authorize")
                })
                .padding()
            }
            
            HStack{
                
                Button(action: {
                    sendDeleteRequest()
                }, label: {
                    Text("Delete")
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
            

            if showError {
                Text("Wrong passCode")
                    .foregroundColor(.red)
            }

        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle("Auth".localized())
    }
    
    private func sendDeleteRequest() {
        guard let url = URL(string: "http://192.168.1.224:8080/delete_user") else { return }
                
        let json: [String: Any] = [
            "deviceID": userInput,
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: json)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.showError = true
                }
                return
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = jsonResponse["success"] as? Bool, success {
                        DispatchQueue.main.async {
                            let deleteStatus = jsonResponse["deleteStatus"] as? Int ?? -1
                            
                            self.activateStatus = deleteStatus
                        }
                    } else {
                        DispatchQueue.main.async {
                            let deleteStatus = jsonResponse["deleteStatus"] as? Int ?? -1
                            self.activateStatus = deleteStatus
                            self.showError = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError = true
                }
            }
        }
        task.resume()
    }

    private func sendActivateRequest() {
        guard let url = URL(string: "http://192.168.1.224:8080/activate") else { return }
        
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
                    self.showError = true
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
                            self.showError = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError = true
                }
            }
        }

        task.resume()
    }
}
