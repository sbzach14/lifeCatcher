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
            MainContentView()
        }
    }

    private func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                // 摄像头权限被拒绝，执行相应操作
            }
        }
    }
}
