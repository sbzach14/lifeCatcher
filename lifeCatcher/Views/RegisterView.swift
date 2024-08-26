import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack {
            TextField("Enter your new username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.bottom, 10)
            
            SecureField("Enter your new password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.bottom, 10)
            
            Button(action: {
                registerUser(username: username, password: password)
            }) {
                Text("Register")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Register")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Registration Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func registerUser(username: String, password: String) {
        guard let url = URL(string: "http://1.94.17.30:8080/register") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //获取设备序列号

        let body: [String: Any] = [
            "deviceID": ClassifierSettingArgs.deviceID,
            "username": username,
            "password": password
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
                    self.alertMessage = "请检查网络连接"
                    self.showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "No data received."
                    self.showAlert = true
                }
                return
            }

            do {
                if let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = responseObject["success"] as? Bool {
                    DispatchQueue.main.async {
                        if success {
                            self.alertMessage = responseObject["message"] as? String ?? ""
                        } else {
                            self.alertMessage = responseObject["message"] as? String ?? ""
                        }
                        self.showAlert = true
                    }
                }
            } catch {
                print("Error in decoding response data: \(error)")
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to parse server response."
                    self.showAlert = true
                }
            }
        }

        task.resume()
    }
}
