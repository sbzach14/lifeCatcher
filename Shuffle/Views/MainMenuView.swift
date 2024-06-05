

import SwiftUI

struct MainMenuView: View {
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                
                ScrollView {
                    VStack(spacing: 0) {
                        NavigationLink(
                            destination: VisionObjectRecognitionView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("开始记录")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: RecordHistoryView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("历史记录")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: InfoView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("信息")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
                            .padding()
                        }
                    }
                }
            }
            .background(
                Image("bg")
                    .resizable()
                    .scaledToFill()
            )
            .navigationBarTitle("集美")
            
            
        }
    }
}

// 添加预览
struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}



struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.white)
                .padding(.leading, 30).frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, 10)
            }
        }
        .padding()
    }
}

