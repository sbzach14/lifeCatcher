import SwiftUI
import AVFoundation

@main
struct MyApp: App {
    
    @State private var showTimeOutAlert = false
    @State private var showNetWorkAlert = false
    
    var body: some Scene {
        WindowGroup {
            MainMenuView().onAppear {
                requestPermissions()
                initFile()
                fetchInternetCurrentDate { internetDate in
                    if let internetDate = internetDate {
                        //TimeLimitations(targetDate: internetDate)
                    } else {
                        print("无法获取互联网当前日期")
                        exit(0)
                    }
                }
            }.alert(isPresented: $showTimeOutAlert){
                Alert(title: Text("使用时间已超时"), message: nil, dismissButton: .default(Text("确定"), action: {
                    exit(0)
                }))
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
    

    
    private func TimeLimitations(targetDate: Date) {
        // 设置固定的当前日期为2023年8月1日
        let fixedCurrentDateComponents = DateComponents(year: 2023, month: 8, day: 2)
        guard let currentDate = Calendar.current.date(from: fixedCurrentDateComponents) else {
            print("无效的日期")
            return
        }
        
        
        // 计算当前日期与指定日期的时间间隔
        let timeInterval = targetDate.timeIntervalSince(currentDate)
        
        // 判断时间间隔是否超过十五天
        let fifteenDays: TimeInterval = 15 * 24 * 60 * 60 // 15 天的时间间隔
        if timeInterval <= fifteenDays {
            // 时间未超过十五天
            print("距离 2023 年 8 月 1 日还有 \(timeInterval / (24 * 60 * 60)) 天")
        } else {
            print("alert flag change")
            showTimeOutAlert = true
        }
    }
    
    // 函数用于从互联网获取当前日期
    func fetchInternetCurrentDate(completion: @escaping (Date?) -> Void) {
        // 指定用于获取当前日期的 URL，这里使用的是一个支持 HTTPS 的日期 API
        guard let url = URL(string: "http://worldtimeapi.org/api/ip") else {
            completion(nil)
            return
        }

        // 创建一个 URL 请求
        let request = URLRequest(url: url)

        // 创建一个 URLSession 数据任务
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching internet time: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = data {
                do {
                    // 使用 JSONDecoder 解析从互联网返回的日期数据
                    let decoder = JSONDecoder()
                    let internetTimeResponse = try decoder.decode(InternetTimeResponse.self, from: data)
                    print("utc time",internetTimeResponse.utc_datetime)

                    // 格式化日期字符串为 Date 对象
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    if let internetDate = dateFormatter.date(from: internetTimeResponse.utc_datetime) {
                        completion(internetDate)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("Error decoding internet time response: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }

        // 开始数据任务
        task.resume()
    }
}

struct InternetTimeResponse: Codable {
    let datetime: String
    let utc_datetime: String
}
