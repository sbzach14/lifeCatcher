/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's overlay view.
*/

import SwiftUI

struct ShowCardView: View {
    var cards: Array<Int>
    var winners: Array<Int>
    @State var showCardView = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if showCardView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 45))]) {
                        ForEach(cards.indices, id: \.self) { index in
                            let imageName = "\(cards[index])"
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(5)
                                .background(Color.gray)
                                .cornerRadius(10)
                        }
                    }
                }
                .bubbleBackground()
                .padding(.horizontal)
            }
            
            Spacer()
            
            HStack {
                Button {
                    showCardView.toggle()
                } label: {
                    Label("ShowCard", systemImage: "magnifyingglass")
                        .foregroundColor(.primary)
                        .labelStyle(.iconOnly)
                        .bubbleBackground()
                }
                
                Text("Winner :")
                    .font(.title)
                    .foregroundColor(.primary)
                
                Text(winners.map { String($0 + 1) }.joined(separator: " "))
                                    .font(.title)
                                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

extension View {
    func bubbleBackground() -> some View {
        self.padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.primary)
                    .opacity(0.4)
            }
    }
}

struct ShowCardView_Previews: PreviewProvider {
    static var previews: some View {
        ShowCardView(cards: Array(0...51), winners: Array(0...2))
    }
}
