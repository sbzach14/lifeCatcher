

import SwiftUI

struct UsingCardsSettingView: View {
    @Binding var cardToUse: [Int]
    @State private var allCardList:[Int] = (0...54).filter { $0 != 52 }
    private let rowCount = 6
    var body: some View {
        ScrollView {
            Spacer()
            VStack(spacing: 15) {
                ForEach(0...allCardList.count / rowCount, id: \.self) { rowIndex in
                    HStack(spacing: 15) { // 设置间隔
                        ForEach(0..<rowCount, id: \.self) { colIndex in
                            let listindex = rowIndex * rowCount + colIndex
                            if listindex < self.allCardList.count {
                                let index = self.allCardList[listindex]
                                let imageName: String = GameManager.cardLabelDic[index]!
                                if !(cardToUse.contains(index)) {
                                    Image("card_back")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 45, height: 60)
                                        .onTapGesture {
                                            toggleCard(index: index)
                                        }

                                } else {
                                    Text(imageName)
                                        .frame(width: 45, height: 60)
                                        .foregroundColor(Color.black)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.white)
                                        )
                                        .onTapGesture {
                                            toggleCard(index: index)
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 100, bottom: 0, trailing: 100)) // 设置整体边缘间隔
        }.background(Image("bg").resizable().scaledToFill())
            .navigationTitle("用牌设置")
    }
    private func toggleCard(index: Int) {
        print(cardToUse, index)
        if cardToUse.contains(index) {
            cardToUse = cardToUse.filter{$0 != index}
        } else {
            cardToUse.append(index)
        }
        cardToUse = cardToUse.sorted()
    }
}


struct UsingCardsSettingView_Previews: PreviewProvider {
    static var previews: some View {
        let cardToUse: Binding<[Int]> = .constant([0,1,2,3,4,5,6,7,8,9,10,11,12])
        return UsingCardsSettingView(cardToUse: cardToUse)
    }
}
