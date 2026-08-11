import Foundation

struct RemotePendingSourceEvent: Codable, Equatable {
    let region: RemoteRegion
    let serial: String
    let eventId: UUID
    let operationId: UUID
    let createdAtMs: Int64
    let expiresAtMs: Int64?
    let payload: RemoteSourcePayload
}

final class RemoteOutboxStore {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = base.appendingPathComponent("lifeCatcher/Remote", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("source-outbox-v1.json")
    }

    func load() -> [RemotePendingSourceEvent] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? decoder.decode([RemotePendingSourceEvent].self, from: data)) ?? []
    }

    func save(_ events: [RemotePendingSourceEvent]) {
        guard let data = try? encoder.encode(events) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
