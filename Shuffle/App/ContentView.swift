/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's content view.
*/

import SwiftUI

struct ContentView: View {
    @State private var userInput = ""
    @State private var isAuthorized = false
    let uniqueID = AuthManager.getUniqueID()

    var body: some View {
        VStack {
            if isAuthorized {
                MainContentView()
            } else {
                Text("Please enter your unique Key:")
                    .font(.headline)
                    .padding()
                Text(uniqueID ?? "Unknown")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                TextField("Enter your Key here", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                    if AuthManager.authKey(input: self.userInput) == true {
                        self.isAuthorized = true
                    } else {
                        self.userInput = ""
                    }
                }, label: {
                    Text("Authorize")
                })
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
