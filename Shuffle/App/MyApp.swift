import SwiftUI
import AVFoundation

@main
struct MyApp: App {
    
    init(){
        // 创建导航栏外观样式
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titlePositionAdjustment = .zero // 将标题文本居中
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // 标题文本颜色
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // 大标题文本颜色
        appearance.backgroundImage = UIImage(named: "top_bg") // 自定义背景图片
        
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
                print("camera access fail")
            }
            else{
                print("camera access success")
            }
        }
    }
    
    public func initFile(){
        
        createParaJSON()
        
        //创建config json文件
        createConfigJSON()
        
        //创建cls json文件
        createRecordHistoryJSON()
        
        //读取储存的规则
        RuleManager.allUsersGameRule = RuleManager.loadGameRule()!
        //读取预设的游戏规则
        RuleManager.LoadAllPresetRules()
        RuleManager.LoadAllReportRules()
        
    }
    
    
}

