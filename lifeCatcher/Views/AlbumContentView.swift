

import SwiftUI

struct UpdatedShowRecordHistoryView: View {
    @EnvironmentObject var viewModel : UpdatedVisionObjectRecognitionViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ScrollView {
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 27))]) {
                    ForEach(viewModel.singlefeatureArray, id: \.self) { index in
                        SingleIconView(index: index)
                    }
                }.padding()
                
                Divider().colorInvert()
              
                let result = Array(0..<viewModel.multipleStatisticRCInfos.singleResultList.count)
                
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
                                    
                                    Text("切牌").font(.system(size: 20)).foregroundColor(.white).bold()
                                    
                                    SingleIconView(index: viewModel.cutShowArray[viewModel.cutShowArray.count - 1])
                                }
                                
                                
                                if viewModel.multipleStatisticRCInfos.singleResultList[resultIndex].ColorSingleFeatures.count > 0{
                                    
                                    Text("色牌").font(.system(size: 20)).foregroundColor(.white).bold()
                                    
                                    ForEach(viewModel.multipleStatisticRCInfos.singleResultList[resultIndex].ColorSingleFeatures, id: \.self) { colorSingleFeatureIndex in
                                        SingleIconView(index: colorSingleFeatureIndex)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            HStack{
                                if viewModel.multipleStatisticRCInfos.singleResultList[resultIndex].community.count > 0{
                                    
                                    Text("公牌").font(.system(size: 20)).foregroundColor(.white).bold()
                                    
                                    let pubSingleFeatureList = viewModel.multipleStatisticRCInfos.singleResultList[resultIndex].community
                                    
                                    ForEach(pubSingleFeatureList, id: \.self) { pubSingleFeatureIndex in
                                        SingleIconView(index: pubSingleFeatureIndex)
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
                            
                            let rankList = viewModel.multipleStatisticRCInfos.singleResultList[resultIndex].RCReturnInfoList
                            
                            if rankList.count > 0 {
                                var posList = (0...rankList.count - 1)
                                ForEach(posList, id: \.self) { posIndex in
                                    HStack{
                                        Text("\(posIndex+1)").frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                                        
                                        let rate = rankList[posIndex].rcStatisticRank
                                        
                                        Text("\(rate)").frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                                        
                                        let singlefeatureRank = rankList[posIndex].rcSingleFeaturesType

                                        Text(singlefeatureRank).frame(width: 60, alignment: .leading).font(.system(size: 20)).foregroundColor(.white)
                                        
                                        let handSingleFeatureList = Array(0...rankList[posIndex].RCSingleFeatures.count - 1)
                                        
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 27))]){
                                            
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
            }
        }
        .background(Image("bg").scaledToFill())
        .navigationTitle("结果显示")
    }
    
}

struct ShowRecordHistoryView: View {
    var cls: String
    
    // Read the recordHistory.json file and get the corresponding value for the cls
    private var imagePaths: [String] {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recordHistory.json")
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            if let recordData = jsonObject as? [String: [String]], let images = recordData[cls] {
                return images
            }
        } catch {
            print("Error reading recordHistory.json: \(error)")
        }
        return []
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(imagePaths, id: \.self) { imageName in
                        if let imagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recordHistory").appendingPathComponent(imageName).path {
                            if let image = UIImage(contentsOfFile: imagePath) {
                                Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100) // 设置图片的大小
                                .cornerRadius(10)
                        } else {
                            Color.black // 如果加载图片失败，显示黑色背景
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
        )
        .navigationTitle(cls)
    }

}

struct DeprecatedShowRecordHistoryView: View {
    @Binding var singlefeatureToUse: [Int]
    @State private var allSingleFeatureList:[Int] = (0...54).filter { $0 != 52 }
    private let rowCount = 6
    var body: some View {
        ScrollView {
            Spacer()
            VStack(spacing: 15) {
                ForEach(0...allSingleFeatureList.count / rowCount, id: \.self) { rowIndex in
                    HStack(spacing: 15) { // 设置间隔
                        ForEach(0..<rowCount, id: \.self) { colIndex in
                            let listindex = rowIndex * rowCount + colIndex
                            if listindex < self.allSingleFeatureList.count {
                                let index = self.allSingleFeatureList[listindex]
                                let imageName: String = ClassifierSettingArgs.singlefeatureLabelDic[index]!
                                if !(singlefeatureToUse.contains(index)) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray)
                                        .frame(width: 45, height: 60)
                                        .onTapGesture {
                                            toggleSingleFeature(index: index)
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
                                            toggleSingleFeature(index: index)
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 100, bottom: 0, trailing: 100)) // 设置整体边缘间隔
        }.background(Image("bg").resizable().scaledToFill())
            .navigationTitle("使用设置")
    }
    private func toggleSingleFeature(index: Int) {
        print(singlefeatureToUse, index)
        if singlefeatureToUse.contains(index) {
            singlefeatureToUse = singlefeatureToUse.filter{$0 != index}
        } else {
            singlefeatureToUse.append(index)
        }
        singlefeatureToUse = singlefeatureToUse.sorted()
    }
}

