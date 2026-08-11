import Foundation

enum RemotePresentationBuilder {
    static func make(
        deck: [Int],
        hidesLastCard: Bool,
        cutCards: [Int],
        result: ReportManager.MultipleReportResultInfo,
        speech: [[SpeakResultStruct]],
        voiceRate: Float,
        repeatCount: Int,
        separateUtterances: Bool,
        timeDisplayCue: RemoteTimeDisplayCue? = nil
    ) -> RemotePresentationSnapshot {
        let visibleDeck = hidesLastCard && !deck.isEmpty ? Array(deck.dropLast()) : deck
        let rounds = result.singleResultList.enumerated().map { roundIndex, round in
            RemotePresentationSnapshot.Round(
                roundNumber: roundIndex + 1,
                colorCards: round.ColorSingleFeatures,
                communityCards: round.community,
                positions: round.RCReturnInfoList.enumerated().map { positionIndex, position in
                    RemotePresentationSnapshot.Round.Position(
                        positionNumber: positionIndex + 1,
                        rank: position.rcDatasetRank,
                        handType: position.rcSingleFeaturesType,
                        cards: position.RCSingleFeatures.map(\.singlefeatureIndex)
                    )
                }
            )
        }
        let utterances = speech.flatMap { $0 }.map {
            RemoteUtterance(text: $0.content, voiceIntent: $0.voiceType == 0 ? .male : .female)
        }
        return RemotePresentationSnapshot(
            schemaVersion: RemoteProtocolVersion.current,
            visibleDeck: visibleDeck,
            cutCard: cutCards.last,
            rounds: rounds,
            playbackPlan: RemotePlaybackPlan(
                utterances: utterances,
                voiceRate: voiceRate,
                repeatCount: max(1, repeatCount),
                playbackMode: separateUtterances ? .separate : .joined
            ),
            timeDisplayCue: timeDisplayCue
        )
    }
}
