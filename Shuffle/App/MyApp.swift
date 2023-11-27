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
//            TestView()
            MainMenuView().onAppear {
                requestPermissions()
                initFile()
                timeCheck()
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
        
        
    }
    
    public func timeCheck(){
        
        fetchInternetCurrentDate { internetDate in
            
            let activeTimeString = readParaJSON()!["activeTime"]
            
            if let internetDate = internetDate {
                if activeTimeString == "TEMP"{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5 * 60) {
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    }
                }
                else if activeTimeString != ""{
                    // 格式化日期字符串为 Date 对象
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let activeTime = dateFormatter.date(from: activeTimeString!)
                        
                    if TimeLimitations(activeDate: activeTime!, nowDate: internetDate){
                        print("有效期内")
                    }
                    else{
                        print("已过期")
                        exit(0)
                    }
                }
            } else {
                print("无法获取互联网当前日期")
                exit(0)
            }
        }
    }
}


