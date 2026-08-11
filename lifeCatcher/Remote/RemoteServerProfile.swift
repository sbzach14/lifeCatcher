import Foundation

enum RemoteRegion: String, Codable, CaseIterable, Identifiable {
    case cn
    case sg

    var id: String { rawValue }
    var title: String { self == .cn ? "大陆服务器" : "新加坡服务器" }

    var serverIP: String {
        switch self {
        case .cn: return Self.configuredIP(key: "LifeCatcherRemoteCNIP")
        case .sg: return Self.configuredIP(key: "LifeCatcherRemoteSGIP")
        }
    }

    var isConfigured: Bool {
        serverIP != "0.0.0.0" && Self.isIPv4(serverIP)
    }

    var apiBaseURL: URL {
        URL(string: "http://\(serverIP):8080")!
    }

    var endpointDescription: String { "\(serverIP):8080" }

    private static func configuredIP(key: String) -> String {
        let configured = (Bundle.main.object(forInfoDictionaryKey: key) as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let configured, isIPv4(configured) else { return "0.0.0.0" }
        return configured
    }

    private static func isIPv4(_ value: String) -> Bool {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        return parts.count == 4 && parts.allSatisfy { part in
            guard !part.isEmpty, part.count <= 3, let number = Int(part) else { return false }
            return number >= 0 && number <= 255 && String(number) == part
        }
    }
}

enum RemotePreferenceKeys {
    static let sourceEnabled = "remote.source.enabled"
    static let sourceRegion = "remote.source.region"
    static let receiverRegion = "remote.receiver.region"
    static let receiverLastSerial = "remote.receiver.lastSerial"
    static let clientInstanceId = "remote.client.instanceId"
}

enum RemotePreferences {
    static var sourceEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: RemotePreferenceKeys.sourceEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: RemotePreferenceKeys.sourceEnabled) }
    }

    static var sourceRegion: RemoteRegion {
        get { RemoteRegion(rawValue: UserDefaults.standard.string(forKey: RemotePreferenceKeys.sourceRegion) ?? "cn") ?? .cn }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: RemotePreferenceKeys.sourceRegion) }
    }

    static var clientInstanceId: UUID {
        if let value = UserDefaults.standard.string(forKey: RemotePreferenceKeys.clientInstanceId), let id = UUID(uuidString: value) {
            return id
        }
        let id = UUID()
        UserDefaults.standard.set(id.uuidString, forKey: RemotePreferenceKeys.clientInstanceId)
        return id
    }
}
