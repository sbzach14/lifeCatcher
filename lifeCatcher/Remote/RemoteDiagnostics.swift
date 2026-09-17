import Foundation
import SwiftUI

enum RemoteDiagnosticLevel: String, Equatable {
    case info
    case success
    case warning
    case error

    var color: Color {
        switch self {
        case .info: return .blue
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        }
    }

    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }
}

struct RemoteToast: Identifiable, Equatable {
    let id = UUID()
    let level: RemoteDiagnosticLevel
    let message: String
}

@MainActor
final class RemoteToastCenter: ObservableObject {
    static let shared = RemoteToastCenter()

    @Published private(set) var current: RemoteToast?
    private var dismissTask: Task<Void, Never>?

    private init() {}

    func show(_ message: String, level: RemoteDiagnosticLevel, duration: TimeInterval? = nil) {
        let normalized = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        current = RemoteToast(level: level, message: normalized)
        dismissTask?.cancel()
        let visibleDuration = duration ?? (level == .error ? 5 : 3)
        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(visibleDuration))
            guard !Task.isCancelled else { return }
            self?.current = nil
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        current = nil
    }
}

@MainActor
enum RemoteDiagnostics {
    static func record(
        _ level: RemoteDiagnosticLevel,
        category: String,
        message: String,
        toast: Bool = false
    ) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[lifeCatcher.remote][\(timestamp)][\(level.rawValue)][\(category)] \(message)")
        if toast { RemoteToastCenter.shared.show(message, level: level) }
    }

    nonisolated static func serverMessage(code: String?, fallback: String?) -> String {
        switch code {
        case "wrong_region": return "服务器区域不匹配，请检查所选服务器"
        case "source_offline": return "目标识别端尚未连接当前服务器"
        case "slot_occupied": return "该序列号的当前角色已被另一台设备占用"
        case "receiver_offline": return "接收端尚未连接，命令未发送"
        case "invalid_resume": return "连接凭证已过期，正在重新建立连接"
        case "inactive_session": return "当前会话已经失效，正在重新连接"
        case "invalid_sequence": return "远程事件顺序不一致，正在重新同步"
        case "invalid_source_session": return "识别端会话已变化，正在重新同步"
        case "invalid_message": return "服务器拒绝了不符合协议的消息"
        case "rate_limited": return "连接请求过于频繁，请稍后重试"
        case "missing_token", "invalid_token": return "服务器认证失败，请重新连接"
        case "bad_request", "invalid_request": return "连接请求格式错误，请检查客户端版本"
        case "not_found": return "服务器接口不存在，请检查 IP 与端口"
        default:
            let normalized = fallback?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return normalized.isEmpty ? "远程服务发生未知错误" : normalized
        }
    }

    nonisolated static func userMessage(for error: Error) -> String {
        let nsError = error as NSError
        if let code = nsError.userInfo["remoteCode"] as? String {
            return serverMessage(code: code, fallback: nsError.localizedDescription)
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut: return "连接超时，请检查网络、服务器 IP 和防火墙"
            case .notConnectedToInternet: return "当前设备没有可用网络"
            case .cannotFindHost: return "找不到服务器，请检查服务器 IP"
            case .cannotConnectToHost: return "无法连接服务器，请检查服务是否启动及端口是否开放"
            case .networkConnectionLost: return "网络连接已中断，正在自动重连"
            case .secureConnectionFailed, .serverCertificateUntrusted: return "服务器安全连接失败"
            case .cancelled: return "连接已取消"
            default: return urlError.localizedDescription
            }
        }
        if error is DecodingError { return "服务器响应不符合当前协议，请检查三端版本" }
        let normalized = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalized.isEmpty ? "远程操作失败" : normalized
    }
}

struct RemoteToastHost: View {
    @StateObject private var center = RemoteToastCenter.shared

    var body: some View {
        VStack {
            if let toast = center.current {
                HStack(spacing: 10) {
                    Image(systemName: toast.level.icon)
                        .foregroundColor(toast.level.color)
                    Text(toast.message)
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 4)
                    Button { center.dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(.black.opacity(0.88))
                .overlay(alignment: .leading) {
                    Rectangle().fill(toast.level.color).frame(width: 4)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture { center.dismiss() }
            }
            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: center.current)
        .allowsHitTesting(center.current != nil)
    }
}
