/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's overlay view.
*/

import SwiftUI

/// - Tag: OverlayView
struct OverlayView: View {
    let cards: Array<Int>
    @State var showCardView = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                if showCardView {
                    
                    //TODO: show rule result
                    
                    ScrollView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                                    ForEach(cards, id: \.self) { card in
                                        Text(String(card))
                                            .padding(5)
                                            .background(Color.gray)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding()
                            }
                            .bubbleBackground()
                }
                
                Spacer()
            }.bubbleBackground()
            
            Spacer()
            
            HStack {
                Button{
                    if showCardView {
                        showCardView = false
                    }
                    else {
                        showCardView = true
                    }
                } label: {
                    Label("Flip", systemImage: "")
                        .foregroundColor(.primary)
                        .labelStyle(.iconOnly)
                        .bubbleBackground()
                }
                Spacer()
            }
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

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(cards: Array(0...51))
    }
}
