

import Foundation

struct InternetTimeResponse: Codable {
    let datetime: String
    let utc_datetime: String
}

public func TimeLimitations(activeDate: Date, nowDate: Date) -> Bool {

    
    // 计算当前日期与激活日期的时间间隔
    let timeInterval = nowDate.timeIntervalSince(activeDate)
    
    
    let maxTimeInterval: TimeInterval = 365 * 24 * 60 * 60 // 365 天的时间间隔
    if timeInterval <= maxTimeInterval {
        return true
    } else {
        return false
    }
}

// 函数用于从互联网获取当前日期
public func fetchInternetCurrentDate(completion: @escaping (Date?) -> Void) {
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
