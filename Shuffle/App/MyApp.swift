/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's body.
*/


import SwiftUI
import AVFoundation

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .onAppear {
//                    requestPermissions()
//                }
            SelectRuleView().onAppear {
                requestPermissions()
            }
        }
    }

    private func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                print("camera access fail")
            }
            else{
                print("camera access success")
            }
        }
    }
}
