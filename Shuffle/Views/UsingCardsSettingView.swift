//
//  UsingCardsSettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 12/10/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct UsingCardsSettingView: View {
    @Binding var cardToUse: [Int]
    @State private var allCardList:[Int] = []
    private let rowCount = 7
    private func SetUpAll(){
        for i in 0...54{
            allCardList.append(i)
        }
    }
    var body: some View {
        ScrollView{
            VStack {
                ForEach(0...allCardList.count / rowCount, id: \.self) { rowIndex in
                    HStack(){
                        ForEach(0..<rowCount, id: \.self) { colIndex in
                            let index = rowIndex * rowCount + colIndex
                            if index != 52 && index < 55{
                                let imageName:String = GameManager.cardLabelDic[index]!
                                if !(cardToUse.contains(index)){
                                    Text(imageName)
                                        .frame(width: 50, height: 70).foregroundColor(Color.black.opacity(0.1))
                                        .onTapGesture {
                                            toggleCard(index: index)
                                        }
                                } else {
                                    Text(imageName)
                                        .frame(width: 50, height: 70).foregroundColor(Color.black.opacity(1))
                                        .onTapGesture {
                                            toggleCard(index: index)
                                        }
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }.background(Image("bg").resizable().scaledToFill()).onAppear(){
            self.SetUpAll()
        }.navigationTitle("用牌设置")
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
