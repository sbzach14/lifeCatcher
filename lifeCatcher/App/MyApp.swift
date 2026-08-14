import SwiftUI
import AVFoundation
import CryptoKit
import Localize_Swift

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
        appearance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        // 应用全局导航栏样式
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    @AppStorage("appLanguage") private var appLanguage: String = "en"

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                // 切换语言时重建整棵视图树，已打开的页面才会跟着变
                .id(appLanguage)
                .onAppear {
                    // 用用户存下来的语言，别写死 "en" 覆盖掉他的选择
                    Localize.setCurrentLanguage(appLanguage)
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
        
        fetchInternetCurrentDate { internetDate in
            print("network success")
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
