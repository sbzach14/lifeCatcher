

import SwiftUI

struct ShowResultView: View {
    @EnvironmentObject var viewModel : CurrentVisionObjectRecognitionViewModel
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            ScrollView {
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30)), count: 10)) {
                    ForEach(viewModel.singlefeatureArray, id: \.self) { index in
                        SingleIconView(index: index)
                    }
                }.padding(3)
                
                Divider().colorInvert()
              
                let result = Array(0..<viewModel.multipleDatasetRCInfos.singleResultList.count)
                
                ForEach(result, id: \.self) { resultIndex in
                    VStack(spacing: 0){
                        
                        VStack(spacing: 15){
                            
                            HStack{
                                
                                Text("轮次").font(.system(size: 20)).foregroundColor(.white).bold()
                                Text("\(resultIndex+1)").font(.system(size: 20)).foregroundColor(.white)
                                Spacer()
                                
                            }
                            
                            HStack{
                                if viewModel.cutShowArray.count > 0{
                                    
                                    Text("切牌").font(.system(size: 15)).foregroundColor(.white).bold()
                                    
                                    SingleIconView(index: viewModel.cutShowArray[viewModel.cutShowArray.count - 1])
                                }
                                
                                
                                if viewModel.multipleDatasetRCInfos.singleResultList[resultIndex].ColorSingleFeatures.count > 0{
                                    
                                    Text("色牌").font(.system(size: 15)).foregroundColor(.white).bold()
                                    
                                    ForEach(viewModel.multipleDatasetRCInfos.singleResultList[resultIndex].ColorSingleFeatures, id: \.self) { colorSingleFeatureIndex in
                                        SingleIconView(index: colorSingleFeatureIndex)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            HStack{
                                if viewModel.multipleDatasetRCInfos.singleResultList[resultIndex].community.count > 0{
                                    
                                    Text("公牌").font(.system(size: 15)).foregroundColor(.white).bold()
                                    
                                    let pubSingleFeatureList = viewModel.multipleDatasetRCInfos.singleResultList[resultIndex].community
                                    
                                    ForEach(pubSingleFeatureList, id: \.self) { pubSingleFeatureIndex in
                                        SingleIconView(index: pubSingleFeatureIndex)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            HStack{
                                Text("位置").frame(width: 45, alignment: .leading).font(.system(size: 15)).foregroundColor(.white).bold()
                                
                                Text("排名").frame(width: 45, alignment: .leading).font(.system(size: 15)).foregroundColor(.white).bold()
                                
                                Text("牌型").frame(width: 45, alignment: .leading).font(.system(size: 15)).foregroundColor(.white).bold()
                                
                                Text("手牌").frame(width: 45, alignment: .leading).font(.system(size: 15)).foregroundColor(.white).bold()
                                
                                Spacer()
                            }
                            
                            let rankList = viewModel.multipleDatasetRCInfos.singleResultList[resultIndex].RCReturnInfoList
                            
                            if rankList.count > 0 {
                                var posList = (0...rankList.count - 1)
                                ForEach(posList, id: \.self) { posIndex in
                                    HStack{
                                        Text("\(posIndex+1)").frame(width: 45, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                                        
                                        let rate = rankList[posIndex].rcDatasetRank
                                        
                                        Text("\(rate)").frame(width: 45, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                                        
                                        let singlefeatureRank = rankList[posIndex].rcSingleFeaturesType

                                        Text(singlefeatureRank).frame(width: 45, alignment: .leading).font(.system(size: 15)).foregroundColor(.white)
                                        
                                        let handSingleFeatureList = Array(0...rankList[posIndex].RCSingleFeatures.count - 1)
                                        
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30)), count: 5)){
                                            
                                            ForEach(handSingleFeatureList, id: \.self) { handSingleFeatureIndex in
                                                SingleIconView(index: rankList[posIndex].RCSingleFeatures[handSingleFeatureIndex].singlefeatureIndex)
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
                
                Button {
                    viewModel.isShowSingleFeature = false
                } label: {
                    Image("icon_back").resizable().frame(width: 150, height: 60)
                }
                
                Spacer()
            }.frame(height: 60, alignment: .bottom)
        }
        .background(Image("Newbg2").resizable()
            .scaledToFill()
            .ignoresSafeArea())
        .gesture(
            DragGesture(minimumDistance: 50)
                .onChanged { value in
                    if value.translation.width > 0 {
                        // 左滑
                        viewModel.isShowSingleFeature = false
                    }
                }
        )
    }
    
}
