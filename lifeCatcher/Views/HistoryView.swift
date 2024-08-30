

import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var selectedRuleIndex: Int? = nil
    @StateObject private var viewModel = RecordViewModel()
    @State private var showAlert: Bool = false
    
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
                        showAlert = AuthManager.activeAccount(input: searchText)
                    }
                } label: {
                    Label("ShowSingleFeature", systemImage: "magnifyingglass")
                        .foregroundColor(.black)
                        .labelStyle(.iconOnly)
                }
                .frame(width: 20, height: 20)
                .padding(.trailing, 20)
            }
            
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20){
                    ForEach(showRecordHistoryData.keys.sorted(), id: \.self) { key in
                        if let value = showRecordHistoryData[key]?.count {
                            if value > 0{
                                NavigationLink(
                                    destination: HistoryItemView(cls: key)
                                ) {
                                    HStack {
                                        Text(key)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text("\(value)")
                                            .foregroundColor(.black)
                                        
                                    }
                                    .padding()
                                    .bubbleBackground()
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
                .ignoresSafeArea()
        )
        .navigationBarTitle("History")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("激活成功"), message: Text(""), dismissButton: .default(Text("OK")))
        }
    }
}

