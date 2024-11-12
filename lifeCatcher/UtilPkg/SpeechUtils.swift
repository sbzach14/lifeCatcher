import Foundation

func convertArabicNumbersToChinese(_ input: String) -> String {
    let numberMap: [Int: String] = [
        0: "零", 1: "一", 2: "二", 3: "三", 4: "四",
        5: "五", 6: "六", 7: "七", 8: "八", 9: "九"
    ]
    
    let unitMap: [Int: String] = [
        1: "", 10: "十", 100: "百", 1000: "千"
    ]
    
    var result = ""
    var currentNumber = ""

    for char in input {
        if let _ = char.wholeNumberValue {
            // 累计数字字符
            currentNumber.append(char)
        } else {
            // 处理累计的数字
            if let number = Int(currentNumber) {
                result += convertNumberToChinese(number, numberMap: numberMap, unitMap: unitMap)
            }
            // 清空数字缓存并处理非数字字符
            currentNumber = ""
            result.append(char)
        }
    }
    
    // 处理结尾的数字
    if let number = Int(currentNumber) {
        result += convertNumberToChinese(number, numberMap: numberMap, unitMap: unitMap)
    }

    return result
}

func convertNumberToChinese(_ number: Int, numberMap: [Int: String], unitMap: [Int: String]) -> String {
    if number == 0 { return numberMap[0]! }

    var result = ""
    var remainingNumber = number
    var unit = 1

    while remainingNumber > 0 {
        let digit = remainingNumber % 10
        if digit != 0 {
            let digitChinese = numberMap[digit]!
            let unitChinese = unitMap[unit] ?? ""
            result = digitChinese + unitChinese + result
        } else if !result.hasPrefix(numberMap[0]!) {
            result = numberMap[0]! + result
        }
        
        remainingNumber /= 10
        unit *= 10
    }
    
    // 处理十位数的简写情况，例如12转为"十二"而不是"一十二"
    if result.hasPrefix("一十") {
        result.removeFirst()
    }
    
    // 处理十位数的简写情况，例如12转为"十二"而不是"一十二"
    if result.hasSuffix("十零") {
        result.removeLast()
    }
    
    return result
}
