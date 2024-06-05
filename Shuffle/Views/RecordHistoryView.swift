

import SwiftUI

struct RecordHistoryView: View {
    @State private var searchText = ""
    @State private var selectedRuleIndex: Int? = nil
    @StateObject private var viewModel = RecordHistoryViewModel()
    
    var body: some View {
        
        VStack{
            Spacer()
            
            ScrollView {
                VStack(spacing: 0) {
                    Divider().colorInvert()
                    ForEach(viewModel.recordHistoryData.keys.sorted(), id: \.self) { key in
                        if let value = viewModel.recordHistoryData[key]?.count {
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
