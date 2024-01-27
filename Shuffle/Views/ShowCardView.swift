/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's overlay view.
*/

import SwiftUI

struct ShowCardView: View {
    @EnvironmentObject var viewModel : ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isShowCard {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 45))]) {
                        ForEach(viewModel.cardArray.indices, id: \.self) { index in
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color.white)
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                Text(viewModel.cardLabelDic[viewModel.cardArray[index]]!)
                                    .font(.system(size: 14)).foregroundColor(Color.black)
                            }.padding(5)
                        }
                    }
                }
                .bubbleBackground()
                .padding(.horizontal)
            }
            
            Spacer()
            
            HStack {
                Button {
                    viewModel.showCardToggle()
                } label: {
                    Label("ShowCard", systemImage: "magnifyingglass")
                        .foregroundColor(.primary)
                        .labelStyle(.iconOnly)
                        .bubbleBackground()
                }
                
                Text("Winner :")
                    .font(.title)
                    .foregroundColor(.primary)
                
                Text(viewModel.winnerPlayerShow)
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
        ShowCardView().environmentObject(ViewModel())
    }
}
