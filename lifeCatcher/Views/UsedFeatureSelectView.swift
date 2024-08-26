import SwiftUI

struct UsedFeatureSelectView: View {
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
        // print(singlefeatureToUse, index)
        if singlefeatureToUse.contains(index) {
            singlefeatureToUse = singlefeatureToUse.filter{$0 != index}
        } else {
            singlefeatureToUse.append(index)
        }
        singlefeatureToUse = singlefeatureToUse.sorted()
    }
}
