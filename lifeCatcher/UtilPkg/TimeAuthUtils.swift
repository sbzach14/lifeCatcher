

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
            // print("Error fetching internet time: \(error.localizedDescription)")
            completion(nil)
            return
        }

        if let data = data {
            do {
                // 使用 JSONDecoder 解析从互联网返回的日期数据
                let decoder = JSONDecoder()
                let internetTimeResponse = try decoder.decode(InternetTimeResponse.self, from: data)
                // print("utc time",internetTimeResponse.utc_datetime)

                // 格式化日期字符串为 Date 对象
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let internetDate = dateFormatter.date(from: internetTimeResponse.utc_datetime) {
                    completion(internetDate)
                } else {
                    completion(nil)
                }
            } catch {
                // print("Error decoding internet time response: \(error)")
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }

    // 开始数据任务
    task.resume()
}

class TimeModeFormatter{
    
    // 日期格式化器，用于显示公历的日期格式
    public static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN") // 使用中文区域设置
        formatter.dateFormat = "M月dd日EEEE" // 9月17日 星期二
        return formatter
    }
    
    // 时间格式化器，用于显示时间
    public static var timeFormatter1: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN") // 使用中文区域设置
        formatter.dateFormat = "HH:mm" // 小时:分钟
        return formatter
    }
    
    // 时间格式化器，用于显示时间
    public static var timeFormatter2: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN") // 使用中文区域设置
        formatter.dateFormat = "HH:mm:ss" // 小时:分钟
        return formatter
    }
    
    // 获取农历日期
    public static func lunarDateString(from date: Date) -> String {
        let chineseCalendar = Calendar(identifier: .chinese)
        // 获取农历年、月、日
        let yearComponent = chineseCalendar.component(.year, from: date)
        let monthComponent = chineseCalendar.component(.month, from: date)
        let dayComponent = chineseCalendar.component(.day, from: date)


        // 天干地支计算
        let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
        let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

        let heavenlyStemIndex = (yearComponent - 1) % 10
        let earthlyBranchIndex = (yearComponent - 1) % 12
        let ganZhiYear = "\(heavenlyStems[heavenlyStemIndex])\(earthlyBranches[earthlyBranchIndex])年"

        // 农历月份和日期转换为中文
        let chineseMonths = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
        let chineseDays = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]

        let chineseMonth = chineseMonths[monthComponent - 1]
        let chineseDay = chineseDays[dayComponent - 1]
        
        // 返回格式化后的日期字符串
        return "\(ganZhiYear)\(chineseMonth)\(chineseDay)"
    }
}
