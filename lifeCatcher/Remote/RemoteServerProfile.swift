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

enum RecognitionMode: String, CaseIterable, Identifiable {
    case remote, local
    var id: String { rawValue }
    var title: String { self == .remote ? "远程模式" : "本地模式" }
}

enum RemoteRecognitionPolicy {
    static var sourceConnectionEnabled: Bool { RemotePreferences.recognitionMode == .remote }
    static var localAudioEnabled: Bool { RemotePreferences.recognitionMode == .local }
    static var localResultDisplayEnabled: Bool { RemotePreferences.recognitionMode == .local }
}

enum RemotePreferenceKeys {
    static let recognitionMode = "recognition.mode"
    static let sourceRegion = "remote.source.region"
    static let videoFPS = "remote.video.fps"
    static let videoResolution = "remote.video.resolution"
    static let videoLowPower = "remote.video.lowPower"
    static let receiverRegion = "remote.receiver.region"
    static let receiverLastSerial = "remote.receiver.lastSerial"
    static let clientInstanceId = "remote.client.instanceId"
}

enum RemotePreferences {
    // Preserve remote behavior for existing installations and unknown stored values.
    static var recognitionMode: RecognitionMode {
        get { RecognitionMode(rawValue: UserDefaults.standard.string(forKey: RemotePreferenceKeys.recognitionMode) ?? "remote") ?? .remote }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: RemotePreferenceKeys.recognitionMode) }
    }

    static var sourceEnabled: Bool { RemoteRecognitionPolicy.sourceConnectionEnabled }

    static var videoFPS: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: RemotePreferenceKeys.videoFPS)
            return [30, 60].contains(value) ? value : 30
        }
        set { UserDefaults.standard.set([30, 60].contains(newValue) ? newValue : 30, forKey: RemotePreferenceKeys.videoFPS) }
    }

    static var videoResolution: Int {
        get { UserDefaults.standard.integer(forKey: RemotePreferenceKeys.videoResolution) == 1080 ? 1080 : 720 }
        set { UserDefaults.standard.set(newValue == 1080 ? 1080 : 720, forKey: RemotePreferenceKeys.videoResolution) }
    }

    static var videoLowPower: Bool {
        get { UserDefaults.standard.bool(forKey: RemotePreferenceKeys.videoLowPower) }
        set { UserDefaults.standard.set(newValue, forKey: RemotePreferenceKeys.videoLowPower) }
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
