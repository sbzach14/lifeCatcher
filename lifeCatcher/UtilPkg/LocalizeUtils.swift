import Foundation
import Localize_Swift

/// 界面与播报文案的本地化入口。
///
/// 数据层（牌型名、报法名、播报词）内部一律保持中文，因为这些字符串同时参与
/// 逻辑判断（例如 `rcTypeList[i] == "同花顺"`、`hasPrefix("9点")`），改成英文会改变行为。
/// 翻译只在「显示给用户 / 念给用户听」这一层做。
enum LocalizeUtils {

    static var isChinese: Bool {
        Localize.currentLanguage().hasPrefix("zh")
    }

    /// 整句翻译：先按完整字符串查词条，查不到再按术语切分逐段翻译。
    ///
    /// 播报文案是运行时拼出来的（"活门" + 门号、"牛" + 点数），整句不会出现在词条表里，
    /// 所以需要退回到切分翻译。
    static func phrase(_ text: String) -> String {
        if isChinese || text.isEmpty { return text }

        let whole = text.localized()
        if whole != text { return whole }
        if !containsChinese(text) { return text }

        return segmented(text)
    }

    /// 按词条表里的中文 key 做最长匹配切分，逐段替换成英文。
    private static func segmented(_ text: String) -> String {
        var result = ""
        var pendingASCII = ""
        var index = text.startIndex

        while index < text.endIndex {
            var matched = false
            // 最长匹配优先，避免 "半活门" 被先匹配成 "活门"
            for length in stride(from: min(maxTokenLength, text.distance(from: index, to: text.endIndex)), through: 1, by: -1) {
                guard let end = text.index(index, offsetBy: length, limitedBy: text.endIndex) else { continue }
                let candidate = String(text[index..<end])
                guard containsChinese(candidate) else { continue }
                let translated = candidate.localized()
                if translated != candidate {
                    result += flush(&pendingASCII) + spacerIfNeeded(result) + translated
                    index = end
                    matched = true
                    break
                }
            }
            if !matched {
                let ch = text[index]
                if containsChinese(String(ch)) {
                    // 没有对应词条的中文原样保留，至少不会丢信息
                    result += flush(&pendingASCII) + spacerIfNeeded(result) + String(ch)
                } else {
                    // 译文紧跟数字会念成一团（"Players6"），先补个空格
                    if pendingASCII.isEmpty, let last = result.last, last != " ", last != "\n" {
                        pendingASCII.append(" ")
                    }
                    pendingASCII.append(ch)
                }
                index = text.index(after: index)
            }
        }
        return result + flush(&pendingASCII)
    }

    private static func flush(_ buffer: inout String) -> String {
        defer { buffer = "" }
        guard !buffer.isEmpty else { return "" }
        return buffer
    }

    private static func spacerIfNeeded(_ current: String) -> String {
        guard let last = current.last else { return "" }
        return (last == " " || last == "\n") ? "" : " "
    }

    private static let maxTokenLength = 12

    private static func containsChinese(_ text: String) -> Bool {
        text.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) }
    }
}

extension String {
    /// 显示层用：整句查不到就按术语切分翻译。
    func localizedPhrase() -> String {
        LocalizeUtils.phrase(self)
    }
}
