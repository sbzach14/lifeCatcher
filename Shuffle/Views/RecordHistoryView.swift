

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
            SearchBar(searchText: $searchText)
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { notification in
                        settingviewModel.onReturnKeyPressed(searchText: searchText)
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
                }
            
            NavigationLink(destination: PanguMainMenuView(), isActive: $settingviewModel.isLogin) {
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
        Image("bg")
            .resizable()
            .scaledToFill()
    )
    .navigationBarTitle("历史记录")
        
            
    }
}

struct RecordHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        RecordHistoryView()
    }
}
