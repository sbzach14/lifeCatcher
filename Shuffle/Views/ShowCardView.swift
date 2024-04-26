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
            
            ScrollView {
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 27))]) {
                    ForEach(viewModel.cardArray, id: \.self) { index in
                        CardIconView(index: index)
                    }
                }.padding()
                
                Divider().colorInvert()
              
                //TODO: 替换成viewmodel保存的计算结果
                let result = Array(0..<viewModel.multipleGamePlayerInfos.singleResultList.count)
                
                ForEach(result, id: \.self) { resultIndex in
                    VStack(spacing: 0){
                        
                        VStack(spacing: 15){
                            
                            HStack{
                                
                                Text("轮次").font(.system(size: 20)).foregroundColor(.white).bold()
                                Text("\(resultIndex+1)").font(.system(size: 20)).foregroundColor(.white)
                                Spacer()
                                
                            }
                            
                            HStack{
                                //TODO: 替换成本轮切牌（若每轮相同则是本局切牌）没有则隐藏
                                if viewModel.cutShowArray.count > 0{
                                    
                                    Text("切牌").font(.system(size: 20)).foregroundColor(.white).bold()
                                    
                                    CardIconView(index: viewModel.cutShowArray[viewModel.cutShowArray.count - 1])
                                }
                                
                                
                                //TODO: 替换成本轮色牌（若每轮相同则是本局色牌）没有则隐藏
                                if viewModel.multipleGamePlayerInfos.singleResultList[resultIndex].ColorCards.count > 0{
                                    
                                    Text("色牌").font(.system(size: 20)).foregroundColor(.white).bold()
                                    
                                    ForEach(viewModel.multipleGamePlayerInfos.singleResultList[resultIndex].ColorCards, id: \.self) { colorCardIndex in
                                        CardIconView(index: colorCardIndex)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            HStack{
                                //TODO: 替换成本轮公牌（若每轮相同则是本局公牌）没有则隐藏
                                if viewModel.multipleGamePlayerInfos.singleResultList[resultIndex].community.count > 0{
                                    
                                    Text("公牌").font(.system(size: 20)).foregroundColor(.white).bold()
                                    
                                    let pubCardList = viewModel.multipleGamePlayerInfos.singleResultList[resultIndex].community
                                    
                                    ForEach(pubCardList, id: \.self) { pubCardIndex in
                                        CardIconView(index: pubCardIndex)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            HStack{
                                Text("位置").frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white).bold()
                                
                                Text("排名").frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white).bold()
                                
                                Text("牌型").frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white).bold()
                                
                                Text("手牌").frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white).bold()
                                
                                Spacer()
                            }
                            
                            //TODO: 替换成位置数量
                            
                            let rankList = viewModel.multipleGamePlayerInfos.singleResultList[resultIndex].PlayerReturnInfoList
                            
                            if rankList.count > 0 {
                                var posList = (0...rankList.count - 1)
                                ForEach(posList, id: \.self) { posIndex in
                                    HStack{
                                        Text("\(posIndex+1)").frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                                        
                                        //TODO: 替换成该位置玩家的排名
                                        let rate = rankList[posIndex].playerGameRank
                                        
                                        Text("\(rate)").frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                                        
                                        //TODO: 替换成该位置玩家的牌型
                                        let cardRank = rankList[posIndex].playerCardsType

                                        Text(cardRank).frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                                        
                                        //TODO: 替换成该位置玩家的手牌
                                        let handCardList = Array(0...rankList[posIndex].PlayerCards.count - 1)
                                        
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 27))]){
                                            
                                            ForEach(handCardList, id: \.self) { handCardIndex in
                                                CardIconView(index: rankList[posIndex].PlayerCards[handCardIndex].cardIndex)
                                            }
                                            
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            
                            Divider().colorInvert()
                        }
                        
                    }.padding()
                }
                
            }
            
            Spacer()
            
            HStack{
                Spacer()
                Button {
                    viewModel.generateTestResult()
                } label: {
                    Image("icon_test").resizable().frame(width: 150, height: 60)
                }
                Spacer()
            }
        }
        .background(Image("bg").scaledToFill())
        .navigationTitle("结果显示")
    }
    
}

extension View {
    func bubbleBackground() -> some View {
        self.padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray)
                    .opacity(0.7)
            }
    }
}

struct CardIconView: View{
    var index: Int
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(5)
                .shadow(radius: 2)
                .frame(width: 27, height: 27)
            Text(GameManager.cardLabelDic[index]!)
                .font(.system(size: 10)).foregroundColor(Color.black)
        }
    }
}

struct ShowCardView_Previews: PreviewProvider {
    static var previews: some View {
        ShowCardView().environmentObject(ViewModel())
    }
}
