@preconcurrency import AVFoundation
import Foundation

@MainActor
final class RemoteReceiverAudioCoordinator: NSObject, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    private enum Work {
        case prompt(RemotePromptKind)
        case playback(RemotePlaybackPlan)
        case text(String, RemoteVoiceIntent, Float, Int)
    }

    private var queue: [Work] = []
    private var currentOperationId: UUID?
    private var audioPlayer: AVAudioPlayer?
    private var synthesizer = AVSpeechSynthesizer()
    private var pendingUtteranceCount = 0
    private var isPlaying = false

    override init() {
        super.init()
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
        synthesizer.delegate = self
    }

    func accept(_ delivery: RemoteReceiverDelivery) {
        guard RemotePreferences.receiverSoundEnabled else { return }
        if delivery.origin == .manual || currentOperationId != delivery.operationId {
            cancelAll()
            currentOperationId = delivery.origin == .automatic ? delivery.operationId : nil
        }
        switch delivery.command {
        case .prompt(let prompt): queue.append(.prompt(prompt))
        case .presentation(let presentation): queue.append(.playback(presentation.playbackPlan))
        case .speakText(let text, let voiceIntent, let voiceRate, let repeatCount):
            queue.append(.text(text, voiceIntent, voiceRate, repeatCount))
        }
        playNextIfNeeded()
    }

    func cancelAll() {
        queue.removeAll()
        currentOperationId = nil
        audioPlayer?.stop()
        audioPlayer = nil
        synthesizer.stopSpeaking(at: .immediate)
        pendingUtteranceCount = 0
        isPlaying = false
    }

    private func playNextIfNeeded() {
        guard !isPlaying, !queue.isEmpty else { return }
        guard shouldUseConfiguredOutput() else {
            queue.removeFirst()
            playNextIfNeeded()
            return
        }
        isPlaying = true
        switch queue.removeFirst() {
        case .prompt(let prompt): playPrompt(prompt)
        case .playback(let plan): play(plan)
        case .text(let text, let voiceIntent, let voiceRate, let repeatCount):
            play(RemotePlaybackPlan(
                utterances: [RemoteUtterance(text: text, voiceIntent: voiceIntent)],
                voiceRate: voiceRate,
                repeatCount: repeatCount,
                playbackMode: .separate
            ))
        }
    }

    private func playPrompt(_ prompt: RemotePromptKind) {
        let resource = prompt == .start ? "start_voice" : prompt == .success ? "success_voice" : "fail_voice"
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            finishCurrentWork()
            return
        }
        audioPlayer = player
        player.delegate = self
        player.volume = RemotePreferences.receiverVolume
        player.prepareToPlay()
        if !player.play() { finishCurrentWork() }
    }

    private func play(_ plan: RemotePlaybackPlan) {
        let utterances: [RemoteUtterance]
        if plan.playbackMode == .joined {
            let text = plan.utterances.map(\.text).joined()
            utterances = text.isEmpty ? [] : [RemoteUtterance(text: text, voiceIntent: plan.utterances.last?.voiceIntent ?? .female)]
        } else {
            utterances = plan.utterances
        }
        let repeated = (0..<max(1, plan.repeatCount)).flatMap { _ in utterances }
        guard !repeated.isEmpty else {
            finishCurrentWork()
            return
        }
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        pendingUtteranceCount = repeated.count
        for item in repeated {
            let text = item.text.isEmpty ? "0" : convertArabicNumbersToChinese(item.text)
            let utterance = AVSpeechUtterance(string: text)
            utterance.pitchMultiplier = 1
            utterance.rate = 0.25 + RemotePreferences.receiverVoiceRate * 0.5
            utterance.volume = RemotePreferences.receiverVolume
            utterance.voice = preferredVoice(for: item.voiceIntent)
            synthesizer.speak(utterance)
        }
    }

    private func preferredVoice(for intent: RemoteVoiceIntent) -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.lowercased().hasPrefix("zh") }
        let gender: AVSpeechSynthesisVoiceGender = intent == .male ? .male : .female
        if let matched = voices.first(where: { $0.gender == gender }) {
            return matched
        }
        return AVSpeechSynthesisVoice(language: "zh-CN") ?? voices.first
    }

    private func shouldUseConfiguredOutput() -> Bool {
        let configuredDevice = RemotePreferences.receiverVoiceDevice
        let hasBluetoothHeadphones = AVAudioSession.sharedInstance().currentRoute.outputs.contains { $0.portType == .bluetoothA2DP }
        return (!hasBluetoothHeadphones && configuredDevice == 0) || (hasBluetoothHeadphones && configuredDevice == 1)
    }

    private func finishCurrentWork() {
        audioPlayer = nil
        pendingUtteranceCount = 0
        isPlaying = false
        playNextIfNeeded()
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in self?.finishCurrentWork() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in self?.finishSpeechUtterance(cancelled: false) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in self?.finishSpeechUtterance(cancelled: true) }
    }

    private func finishSpeechUtterance(cancelled: Bool) {
        if cancelled && !isPlaying { return }
        pendingUtteranceCount -= 1
        if pendingUtteranceCount <= 0 { finishCurrentWork() }
    }
}
