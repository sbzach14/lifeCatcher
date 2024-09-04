import SwiftUI

struct ReportSettingView: View {

    @Binding var reportSetting: [Int]
    
    var target: Int
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
        
    var filteredReportSettings: [Int] {
        if searchText.isEmpty {
            return Array(ReportManager.allReportName.keys).sorted()
        } else {
            return ReportManager.allReportName.filter { $0.value.localizedCaseInsensitiveContains(searchText) }.map { $0.key }.sorted()
        }
    }

    var body: some View {
        VStack {
            // 搜索栏
            SearchBar(searchText: $searchText)
            
            ScrollView{
                VStack { // 垂直间距
                    HStack {
                        Text(ReportManager.allReportName[reportSetting[target]]! + "\n" + ReportManager.allReportInfo[reportSetting[target]]!)
                            .foregroundColor(.black)
                            .lineLimit(nil) // 可以显示多行文本
                            .fixedSize(horizontal: false, vertical: true) // 允许垂直方向上的大小自适应
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    .onTapGesture {
                        self.presentationMode.wrappedValue.dismiss()
                     }
                    Divider()
                    
                    ForEach(0..<filteredReportSettings.count, id: \.self) { index in
                            let currentIndex = filteredReportSettings[index]
                           HStack {
                               Text(ReportManager.allReportName[currentIndex]! + "\n" + ReportManager.allReportInfo[currentIndex]!)
                                   .foregroundColor(.white)
                                   .lineLimit(nil) // 可以显示多行文本
                                   .fixedSize(horizontal: false, vertical: true) // 允许垂直方向上的大小自适应
                                        
                           }
                           .frame(maxWidth: .infinity, alignment: .leading)
                           .padding(.vertical, 10)
                           .onTapGesture {
                               reportSetting[target] = currentIndex
                               self.presentationMode.wrappedValue.dismiss()
                            }
                           
                           Divider()
                       }
                   }
            }.padding()
            
        }.background(Image("Newbg2").resizable()
            .scaledToFill()
            .ignoresSafeArea())
        .navigationTitle("报法选择")
    }
}

