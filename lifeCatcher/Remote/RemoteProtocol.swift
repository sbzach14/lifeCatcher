import Foundation

enum RemoteProtocolVersion {
    static let current = 1
}

enum RemoteRole: String, Codable, Equatable {
    case source
    case receiver
    case desktop
}

enum RemotePresenceState: String, Codable, Equatable {
    case offline
    case online
    case reconnecting

    var isOnline: Bool { self == .online }

    static func resolved(_ value: RemotePresenceState?, online: Bool) -> RemotePresenceState {
        value ?? (online ? .online : .offline)
    }
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

enum RemoteSourceCommand: Equatable {
    case awaitShuffle
    case recomputeCut(Int)
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
    let isPreview: Bool?

    static let empty = RemotePresentationSnapshot(
        schemaVersion: RemoteProtocolVersion.current,
        visibleDeck: [],
        cutCard: nil,
        rounds: [],
        playbackPlan: RemotePlaybackPlan(utterances: [], voiceRate: 0.5, repeatCount: 1, playbackMode: .joined),
        timeDisplayCue: nil,
        isPreview: nil
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
    let receiverOnline: Bool
    let desktopOnline: Bool
    let sourcePresence: RemotePresenceState
    let receiverPresence: RemotePresenceState
    let desktopPresence: RemotePresenceState
    let sourceSessionId: UUID?
    let nextSourceEventSeq: Int?
    let forwardingEnabled: Bool
    let videoWanted: Bool

    private enum CodingKeys: String, CodingKey {
        case protocolVersion, region, role, serial, connectionId, resumeToken, historyEpoch
        case sourceOnline, receiverOnline, desktopOnline
        case sourcePresence, receiverPresence, desktopPresence
        case sourceSessionId, nextSourceEventSeq, forwardingEnabled, videoWanted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        protocolVersion = try container.decode(Int.self, forKey: .protocolVersion)
        region = try container.decode(String.self, forKey: .region)
        role = try container.decode(RemoteRole.self, forKey: .role)
        serial = try container.decode(String.self, forKey: .serial)
        connectionId = try container.decode(UUID.self, forKey: .connectionId)
        resumeToken = try container.decode(String.self, forKey: .resumeToken)
        historyEpoch = try container.decode(UUID.self, forKey: .historyEpoch)
        sourceOnline = try container.decode(Bool.self, forKey: .sourceOnline)
        receiverOnline = try container.decodeIfPresent(Bool.self, forKey: .receiverOnline) ?? false
        desktopOnline = try container.decodeIfPresent(Bool.self, forKey: .desktopOnline) ?? false
        sourcePresence = RemotePresenceState.resolved(
            try container.decodeIfPresent(RemotePresenceState.self, forKey: .sourcePresence),
            online: sourceOnline
        )
        receiverPresence = RemotePresenceState.resolved(
            try container.decodeIfPresent(RemotePresenceState.self, forKey: .receiverPresence),
            online: receiverOnline
        )
        desktopPresence = RemotePresenceState.resolved(
            try container.decodeIfPresent(RemotePresenceState.self, forKey: .desktopPresence),
            online: desktopOnline
        )
        sourceSessionId = try container.decodeIfPresent(UUID.self, forKey: .sourceSessionId)
        nextSourceEventSeq = try container.decodeIfPresent(Int.self, forKey: .nextSourceEventSeq)
        forwardingEnabled = try container.decode(Bool.self, forKey: .forwardingEnabled)
        videoWanted = try container.decode(Bool.self, forKey: .videoWanted)
    }
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
    case sourcePresence(state: RemotePresenceState, sourceSessionId: UUID?)
    case receiverPresence(state: RemotePresenceState)
    case desktopPresence(state: RemotePresenceState)
    case sourceEvent(event: RemoteSourceEvent, replayed: Bool, historySeq: Int?)
    case receiverDelivery(RemoteReceiverDelivery)
    case forwardingState(Bool)
    case sourceControl(videoWanted: Bool)
    case sourceCommand(RemoteSourceCommand)
    case pong(clientTimeMs: Int64, serverTimeMs: Int64, resumeToken: String?)

    private enum CodingKeys: String, CodingKey {
        case type, requestId, status, sourceEventSeq, deliverySeq, code, message
        case online, state, sourceSessionId, event, replayed, historySeq, enabled, videoWanted, command, cutCard
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
        case "source.presence":
            let online = try container.decode(Bool.self, forKey: .online)
            self = .sourcePresence(
                state: RemotePresenceState.resolved(
                    try container.decodeIfPresent(RemotePresenceState.self, forKey: .state),
                    online: online
                ),
                sourceSessionId: try container.decodeIfPresent(UUID.self, forKey: .sourceSessionId)
            )
        case "receiver.presence":
            let online = try container.decode(Bool.self, forKey: .online)
            self = .receiverPresence(state: RemotePresenceState.resolved(
                try container.decodeIfPresent(RemotePresenceState.self, forKey: .state),
                online: online
            ))
        case "desktop.presence":
            let online = try container.decode(Bool.self, forKey: .online)
            self = .desktopPresence(state: RemotePresenceState.resolved(
                try container.decodeIfPresent(RemotePresenceState.self, forKey: .state),
                online: online
            ))
        case "source.event": self = .sourceEvent(
            event: try container.decode(RemoteSourceEvent.self, forKey: .event),
            replayed: try container.decode(Bool.self, forKey: .replayed),
            historySeq: try container.decodeIfPresent(Int.self, forKey: .historySeq)
        )
        case "receiver.delivery": self = .receiverDelivery(try RemoteReceiverDelivery(from: decoder))
        case "forwarding.state": self = .forwardingState(try container.decode(Bool.self, forKey: .enabled))
        case "source.control": self = .sourceControl(videoWanted: try container.decode(Bool.self, forKey: .videoWanted))
        case "source.command":
            switch try container.decode(String.self, forKey: .command) {
            case "awaitShuffle": self = .sourceCommand(.awaitShuffle)
            case "recomputeCut": self = .sourceCommand(.recomputeCut(try container.decode(Int.self, forKey: .cutCard)))
            default:
                throw DecodingError.dataCorruptedError(forKey: .command, in: container, debugDescription: "Unknown source command")
            }
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
