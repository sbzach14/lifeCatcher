import Foundation

enum RemoteProtocolVersion {
    static let current = 1
}

enum RemoteRole: String, Codable, Equatable {
    case source
    case receiver
    case desktop
}

enum RemoteVoiceIntent: String, Codable {
    case male
    case female
}

enum RemotePromptKind: String, Codable {
    case start
    case success
    case failure
}

struct RemoteUtterance: Codable, Equatable {
    let text: String
    let voiceIntent: RemoteVoiceIntent
}

struct RemotePlaybackPlan: Codable, Equatable {
    enum Mode: String, Codable {
        case joined
        case separate
    }

    let utterances: [RemoteUtterance]
    let voiceRate: Float
    let repeatCount: Int
    let playbackMode: Mode
}

struct RemoteTimeDisplayCue: Codable, Equatable {
    enum Kind: String, Codable {
        case recognitionComplete
        case reportDigits
        case singleValue
    }

    let kind: Kind
    let digits: String
    let fullDeck: Bool?
    let displayText: String?
}

struct RemotePresentationSnapshot: Codable, Equatable {
    struct Round: Codable, Equatable, Identifiable {
        struct Position: Codable, Equatable, Identifiable {
            let positionNumber: Int
            let rank: Int
            let handType: String
            let cards: [Int]

            var id: Int { positionNumber }
        }

        let roundNumber: Int
        let colorCards: [Int]
        let communityCards: [Int]
        let positions: [Position]

        var id: Int { roundNumber }
    }

    let schemaVersion: Int
    let visibleDeck: [Int]
    let cutCard: Int?
    let rounds: [Round]
    let playbackPlan: RemotePlaybackPlan
    let timeDisplayCue: RemoteTimeDisplayCue?

    static let empty = RemotePresentationSnapshot(
        schemaVersion: RemoteProtocolVersion.current,
        visibleDeck: [],
        cutCard: nil,
        rounds: [],
        playbackPlan: RemotePlaybackPlan(utterances: [], voiceRate: 0.5, repeatCount: 1, playbackMode: .joined),
        timeDisplayCue: nil
    )
}

enum RemoteSourcePayload: Codable, Equatable {
    case prompt(RemotePromptKind)
    case presentation(RemotePresentationSnapshot)

    private enum CodingKeys: String, CodingKey { case kind, prompt, presentation }
    private enum Kind: String, Codable { case prompt, presentation }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .prompt:
            self = .prompt(try container.decode(RemotePromptKind.self, forKey: .prompt))
        case .presentation:
            self = .presentation(try container.decode(RemotePresentationSnapshot.self, forKey: .presentation))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .prompt(let prompt):
            try container.encode(Kind.prompt, forKey: .kind)
            try container.encode(prompt, forKey: .prompt)
        case .presentation(let presentation):
            try container.encode(Kind.presentation, forKey: .kind)
            try container.encode(presentation, forKey: .presentation)
        }
    }
}

struct RemoteSourceEvent: Codable, Equatable {
    let schemaVersion: Int
    let eventId: UUID
    let operationId: UUID
    let sourceSessionId: UUID
    let sourceEventSeq: Int
    let createdAtMs: Int64
    let expiresAtMs: Int64?
    let payload: RemoteSourcePayload
}

enum RemoteReceiverCommand: Codable, Equatable {
    case speakText(text: String, voiceIntent: RemoteVoiceIntent, voiceRate: Float, repeatCount: Int)
    case prompt(RemotePromptKind)
    case presentation(RemotePresentationSnapshot)

    private enum CodingKeys: String, CodingKey { case kind, text, voiceIntent, voiceRate, repeatCount, prompt, presentation }
    private enum Kind: String, Codable { case speakText, prompt, presentation }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .speakText:
            self = .speakText(
                text: try container.decode(String.self, forKey: .text),
                voiceIntent: try container.decode(RemoteVoiceIntent.self, forKey: .voiceIntent),
                voiceRate: try container.decode(Float.self, forKey: .voiceRate),
                repeatCount: try container.decode(Int.self, forKey: .repeatCount)
            )
        case .prompt:
            self = .prompt(try container.decode(RemotePromptKind.self, forKey: .prompt))
        case .presentation:
            self = .presentation(try container.decode(RemotePresentationSnapshot.self, forKey: .presentation))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .speakText(let text, let voiceIntent, let voiceRate, let repeatCount):
            try container.encode(Kind.speakText, forKey: .kind)
            try container.encode(text, forKey: .text)
            try container.encode(voiceIntent, forKey: .voiceIntent)
            try container.encode(voiceRate, forKey: .voiceRate)
            try container.encode(repeatCount, forKey: .repeatCount)
        case .prompt(let prompt):
            try container.encode(Kind.prompt, forKey: .kind)
            try container.encode(prompt, forKey: .prompt)
        case .presentation(let presentation):
            try container.encode(Kind.presentation, forKey: .kind)
            try container.encode(presentation, forKey: .presentation)
        }
    }
}

struct RemoteWelcomeMessage: Decodable {
    let protocolVersion: Int
    let region: String
    let role: RemoteRole
    let serial: String
    let connectionId: UUID
    let resumeToken: String
    let historyEpoch: UUID
    let sourceOnline: Bool
    let sourceSessionId: UUID?
    let nextSourceEventSeq: Int?
    let forwardingEnabled: Bool
    let videoWanted: Bool
}

struct RemoteReceiverDelivery: Decodable {
    enum Origin: String, Decodable { case automatic, manual }
    let deliverySeq: Int
    let origin: Origin
    let operationId: UUID
    let sourceEventSeq: Int?
    let command: RemoteReceiverCommand
}

enum RemoteServerMessage: Decodable {
    case welcome(RemoteWelcomeMessage)
    case acknowledgement(requestId: UUID, status: String, sourceEventSeq: Int?, deliverySeq: Int?)
    case error(requestId: UUID?, code: String, message: String)
    case sourcePresence(online: Bool, sourceSessionId: UUID?)
    case sourceEvent(event: RemoteSourceEvent, replayed: Bool, historySeq: Int?)
    case receiverDelivery(RemoteReceiverDelivery)
    case forwardingState(Bool)
    case sourceControl(videoWanted: Bool)
    case pong(clientTimeMs: Int64, serverTimeMs: Int64, resumeToken: String?)

    private enum CodingKeys: String, CodingKey {
        case type, requestId, status, sourceEventSeq, deliverySeq, code, message
        case online, sourceSessionId, event, replayed, historySeq, enabled, videoWanted
        case clientTimeMs, serverTimeMs, resumeToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "welcome": self = .welcome(try RemoteWelcomeMessage(from: decoder))
        case "ack": self = .acknowledgement(
            requestId: try container.decode(UUID.self, forKey: .requestId),
            status: try container.decode(String.self, forKey: .status),
            sourceEventSeq: try container.decodeIfPresent(Int.self, forKey: .sourceEventSeq),
            deliverySeq: try container.decodeIfPresent(Int.self, forKey: .deliverySeq)
        )
        case "error": self = .error(
            requestId: try container.decodeIfPresent(UUID.self, forKey: .requestId),
            code: try container.decode(String.self, forKey: .code),
            message: try container.decode(String.self, forKey: .message)
        )
        case "source.presence": self = .sourcePresence(
            online: try container.decode(Bool.self, forKey: .online),
            sourceSessionId: try container.decodeIfPresent(UUID.self, forKey: .sourceSessionId)
        )
        case "source.event": self = .sourceEvent(
            event: try container.decode(RemoteSourceEvent.self, forKey: .event),
            replayed: try container.decode(Bool.self, forKey: .replayed),
            historySeq: try container.decodeIfPresent(Int.self, forKey: .historySeq)
        )
        case "receiver.delivery": self = .receiverDelivery(try RemoteReceiverDelivery(from: decoder))
        case "forwarding.state": self = .forwardingState(try container.decode(Bool.self, forKey: .enabled))
        case "source.control": self = .sourceControl(videoWanted: try container.decode(Bool.self, forKey: .videoWanted))
        case "pong": self = .pong(
            clientTimeMs: try container.decode(Int64.self, forKey: .clientTimeMs),
            serverTimeMs: try container.decode(Int64.self, forKey: .serverTimeMs),
            resumeToken: try container.decodeIfPresent(String.self, forKey: .resumeToken)
        )
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown server message type \(type)")
        }
    }
}

struct RemoteConnectRequest: Encodable {
    let schemaVersion = RemoteProtocolVersion.current
    let region: RemoteRegion
    let role: RemoteRole
    let serial: String
    let clientInstanceId: UUID
    let resumeToken: String?
}

struct RemoteConnectResponse: Decodable {
    let protocolVersion: Int
    let region: String
    let wsUrl: URL
    let sessionToken: String
    let expiresIn: Int
}

struct RemoteMediaTokenResponse: Decodable {
    let serverUrl: URL
    let participantToken: String
    let expiresIn: Int
}

struct RemoteSourceEventMessage: Encodable {
    let type = "source.event"
    let requestId: UUID
    let event: RemoteSourceEvent
}

struct RemotePresenceMessage: Encodable {
    let type = "presence.update"
    let displayMode: String
    let videoWanted: Bool
}

struct RemoteGoodbyeMessage: Encodable { let type = "client.goodbye" }
struct RemoteDeliveryAckMessage: Encodable { let type = "delivery.ack"; let deliverySeq: Int }
struct RemotePingMessage: Encodable { let type = "ping"; let clientTimeMs: Int64 }
