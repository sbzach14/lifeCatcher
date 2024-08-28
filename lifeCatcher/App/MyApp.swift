import SwiftUI
import AVFoundation
import CryptoKit

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init(){
        // 创建导航栏外观样式
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titlePositionAdjustment = .zero // 将标题文本居中
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // 标题文本颜色
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // 大标题文本颜色
        appearance.backgroundImage = UIImage(named: "Newbg2") // 自定义背景图片
        
        // 应用全局导航栏样式
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainMenuView().onAppear {
                requestPermissions()
                initFile()
            }
        }
    }
    
    
    private func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                // print("camera access fail")
            }
            else{
                // print("camera access success")
            }
        }
    }
    
    public func initFile(){
        
        createParaJSON()
        createConfigJSON()
        createRecordHistoryJSON()
        
        DetectSettingArgs.allUsersDatasetRule = DetectSettingArgs.loadDatasetRule()!
        DetectSettingArgs.LoadAllPresetRules()
        DetectSettingArgs.LoadAllReportRules()
    }
}
