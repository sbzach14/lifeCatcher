

import SwiftUI

struct MainMenuView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack{
                
                ScrollView {
                    VStack(spacing: 0) {
                        NavigationLink(
                            destination: VisionObjectRecognitionView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("开始记录")
                                    .foregroundColor(.white)
                                Divider()
                                    .colorInvert()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: RecordHistoryView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("记录历史")
                                    .foregroundColor(.white)
                                Divider()
                                    .colorInvert()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: SettingView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("设置")
                                    .foregroundColor(.white)
                                Divider()
                                    .colorInvert()
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("盘古")
            .background(
                Image("bg")
                    .resizable()
                    .scaledToFill()
            )
            
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
            TextField("         Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.white)
            
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 10)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}

