
import SwiftUI

struct AuthView: View {
    @State private var userInput = ""
    @State private var activeKey = ""
    @State private var isAuthorized = false

    var body: some View {
        VStack {
                Text("Please enter your Auth Key:")
                    .font(.headline)
                    .padding()
                
                TextField("Enter your Key here", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                    self.activeKey = AuthManager.hashWithSalt(input: self.userInput)!
                    print(self.activeKey)
                }, label: {
                    Text("Authorize")
                })
                    .padding()
            
                Text(activeKey)
                .textSelection(.enabled)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
