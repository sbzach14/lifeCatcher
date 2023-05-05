import SwiftUI

struct CardView: View {
    let cards: [Int]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(cards, id: \.self) { card in
                Text("card")
            }
        }
        .padding()
        .background(Color.gray)
        .cornerRadius(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            GeometryReader { geo in
                Color.clear
                    .frame(width: 50, height: 50)
                    .position(x: geo.frame(in: .global).minX + 25, y: geo.frame(in: .global).minY + 25)
            },
            alignment: .topLeading
        )
    }
}
