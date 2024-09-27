import SwiftUI
import Localize_Swift

struct RegisterView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showPassword = false

    
    @EnvironmentObject var loginStatus: AppViewModel

    var body: some View {
        VStack{
            VStack(spacing: 20) {
                
                TextField("Enter your new username".localized(), text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                
                HStack {
                    if showPassword {
                        TextField("Enter your new password".localized(), text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    } else {
                        SecureField("Enter your new password".localized(), text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                    }
                    .padding(.trailing, 20)
                }
                
                
                Button(action: {
                    if username == ""{
                        showAlert = true
                        alertMessage = "Username can not be empty.".localized()
                    }
                    else if password == ""{
                        showAlert = true
                        alertMessage = "Password can not be empty.".localized()
                    }
                    else{
                        registerUser(username: username, password: password)
                    }
                }) {
                    Text("Sign Up".localized())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
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
        .navigationTitle("Register".localized())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Registration Status".localized()), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }


    func registerUser(username: String, password: String) {
        guard let url = URL(string: "http://192.168.1.224:8080/register") else { return }

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
        }

        task.resume()
    }
}
