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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 25))]) {
                        ForEach(viewModel.cardArray, id: \.self) { index in
                            CardIconView(index: index)
                        }
                    }
                  
                    //TODO: 替换成viewmodel保存的计算结果
                    let result = Array(0...3)
                    
                    ForEach(result, id: \.self) { resultIndex in
                        VStack(spacing: 20){
                            
                            VStack{
                                
                                Divider()
                                
                                Spacer().frame(height: 20)
                                
                                
                                HStack{
                                    Text("轮次").font(.system(size: 25))
                                    Text("\(resultIndex+1)").font(.system(size: 25))
                                    Spacer()
                                }
                                
                                Spacer().frame(height: 40)
                                
                                //TODO: 替换成本轮色牌（若每轮相同则是本局色牌）没有则隐藏
                                HStack{
                                    Text("色牌").font(.system(size: 25))
                                    
                                    let colorCardIndex = 0
                                    
                                    CardIconView(index: colorCardIndex)
                                    
                                    Spacer()
                                    
                                }
                                
                                Spacer().frame(height: 20)
                                
                                //TODO: 替换成本轮公牌（若每轮相同则是本局公牌）没有则隐藏
                                HStack{
                                    Text("公牌").font(.system(size: 25))
                                    
                                    let pubCardList = Array(0...5)
                                    
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 25))]){
                                        
                                        ForEach(pubCardList, id: \.self) { pubCardIndex in
                                            CardIconView(index: pubCardIndex)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                    
                                Spacer().frame(height: 40)
                                
                                HStack{
                                    Text("位置").frame(width: 60, alignment: .leading).font(.system(size: 25))
                                    
                                    Text("排名").frame(width: 60, alignment: .leading).font(.system(size: 25))
                                    
//                                    Text("牌型").frame(width: 60, alignment: .leading).font(.system(size: 25))
                                    
                                    Text("手牌").frame(width: 60, alignment: .leading).font(.system(size: 25))
                                    
                                    Spacer()
                                }
                                
                                //TODO: 替换成位置数量
                                let posList = Array(0...4)
                                
                                ForEach(posList, id: \.self) { posIndex in
                                    HStack{
                                        Text("\(posIndex)").frame(width: 60, alignment: .leading).font(.system(size: 25))
                                        
                                        //TODO: 替换成该位置玩家的排名
                                        let rate = 2
                                        
                                        Text("\(rate)").frame(width: 60, alignment: .leading).font(.system(size: 25))
                                        
//                                        //TODO: 替换成该位置玩家的牌型
//                                        let cardRank = "对子"
//                                        
//                                        Text(cardRank).frame(width: 45, alignment: .leading).font(.system(size: 25))
                                        
                                        //TODO: 替换成该位置玩家的手牌
                                        let handCardList = Array(0...12)
                                        
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 25))]){
                                            
                                            ForEach(handCardList, id: \.self) { handCardIndex in
                                                CardIconView(index: handCardIndex)
                                            }
                                            
                                        }
                                        Spacer()
                                    }
                                }
//                                Spacer().frame(height: 20)
                            }
                        }
                    }
                    Divider()
                }
                .bubbleBackground()
                .padding(.horizontal, 10)
            }
            
            Spacer()
            
            HStack {
                Button {
                    viewModel.isShowCard.toggle()
                } label: {
                    Label("ShowCard", systemImage: "magnifyingglass")
                        .foregroundColor(.blue)
                        .labelStyle(.iconOnly)
                        .bubbleBackground()
                }
                
                Spacer()
                
                if viewModel.isShowCard{
                    Button {
                        viewModel.generateTestResult()
                    } label: {
                        Text("测试")
                            .foregroundColor(.blue)
                            .labelStyle(.iconOnly)
                            .bubbleBackground()
                    }
                }
            }
            .padding(.horizontal,10)
            
            
        }
    }
}

extension View {
    func bubbleBackground() -> some View {
        self.padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray)
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
                .frame(width: 25, height: 25)
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
