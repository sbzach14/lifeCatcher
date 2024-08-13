

import SwiftUI

struct RecordHistoryView: View {
    @State private var searchText = ""
    @State private var selectedRuleIndex: Int? = nil
    @StateObject private var viewModel = RecordHistoryViewModel()
    @StateObject private var settingviewModel = SettingViewModel()
    
    var showRecordHistoryData : [String:[String]]{
        if searchText.isEmpty {
            return viewModel.recordHistoryData
        } else {
            return viewModel.recordHistoryData.filter { $0.key.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        
        VStack{
            HStack{
                
                SearchBar(searchText: $searchText)
                
                Button {
                    // 收回键盘
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    // 等待键盘收回后再执行搜索操作
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        settingviewModel.onReturnKeyPressed(searchText: searchText)
                    }
                } label: {
                    Label("ShowSingleFeature", systemImage: "magnifyingglass")
                        .foregroundColor(.gray)
                        .labelStyle(.iconOnly)
                }
                .frame(width: 20, height: 20)
                .padding(.trailing, 20)
            }
            
            NavigationLink(destination: DeprecatedMainMenuView(), isActive: $settingviewModel.isLogin) {
            }
            .hidden()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    ForEach(showRecordHistoryData.keys.sorted(), id: \.self) { key in
                        if let value = showRecordHistoryData[key]?.count {
                            if value > 0{
                                NavigationLink(
                                    destination: ShowRecordHistoryView(cls: key)
                                ) {
                                    HStack {
                                        Text(key)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(value)")
                                            .foregroundColor(.white)
                                        
                                    }
                                    .padding()
                                    Divider()
                                        .colorInvert()
                                }
                            }
                        }
                    }
                }
            }
    }
    .background(
        Image("Newbg2")
            .resizable()
            .scaledToFill()
    )
    .navigationBarTitle("历史美图")
    }
}

struct DeprecatedRecordHistoryView: View {
    @Binding var reportSetting: Int
    
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
                        Text(ReportManager.allReportName[reportSetting]!)
                            .foregroundColor(.green)
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
                               reportSetting = currentIndex
                               self.presentationMode.wrappedValue.dismiss()
                            }
                           
                           Divider()
                       }
                   }
            }.padding()
            
        }.background(Image("bg").resizable().scaledToFill())
        .navigationTitle("报法选择")
    }
}

