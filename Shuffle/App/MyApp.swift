import SwiftUI
import AVFoundation

@main
struct MyApp: App {
    
    var body: some Scene {
        WindowGroup {
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


