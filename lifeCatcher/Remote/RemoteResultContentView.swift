import SwiftUI

struct RemoteResultContentView: View {
    let presentation: RemotePresentationSnapshot

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30)), count: 10)) {
                ForEach(Array(presentation.visibleDeck.enumerated()), id: \.offset) { _, card in
                    SingleIconView(index: card)
                }
            }
            .padding(3)

            Divider().colorInvert()

            ForEach(presentation.rounds) { round in
                VStack(spacing: 15) {
                    HStack {
                        Text("轮次").font(.system(size: 20)).foregroundColor(.white).bold()
                        Text("\(round.roundNumber)").font(.system(size: 20)).foregroundColor(.white)
                        Spacer()
                    }

                    HStack {
                        if let cutCard = presentation.cutCard {
                            Text("切牌").font(.system(size: 15)).foregroundColor(.white).bold()
                            SingleIconView(index: cutCard)
                        }
                        if !round.colorCards.isEmpty {
                            Text("色牌").font(.system(size: 15)).foregroundColor(.white).bold()
                            ForEach(Array(round.colorCards.enumerated()), id: \.offset) { _, card in SingleIconView(index: card) }
                        }
                        Spacer()
                    }

                    if !round.communityCards.isEmpty {
                        HStack {
                            Text("公牌").font(.system(size: 15)).foregroundColor(.white).bold()
                            ForEach(Array(round.communityCards.enumerated()), id: \.offset) { _, card in SingleIconView(index: card) }
                            Spacer()
                        }
                    }

                    HStack {
                        Text("位置").frame(width: 45, alignment: .leading)
                        Text("排名").frame(width: 45, alignment: .leading)
                        Text("牌型").frame(width: 45, alignment: .leading)
                        Text("手牌").frame(width: 45, alignment: .leading)
                        Spacer()
                    }
                    .font(.system(size: 15)).foregroundColor(.white).bold()

                    ForEach(round.positions) { position in
                        HStack {
                            Text("\(position.positionNumber)").frame(width: 45, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                            Text("\(position.rank)").frame(width: 45, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                            Text(position.handType).frame(width: 45, alignment: .leading).font(.system(size: 15)).foregroundColor(.white)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30)), count: 5)) {
                                ForEach(Array(position.cards.enumerated()), id: \.offset) { _, card in SingleIconView(index: card) }
                            }
                            Spacer()
                        }
                    }
                    Divider().colorInvert()
                }
                .padding()
            }
        }
        .background(Image("Newbg2").resizable().scaledToFill().ignoresSafeArea())
    }
}
