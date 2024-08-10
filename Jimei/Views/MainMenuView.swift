

import SwiftUI

struct MainMenuView: View {
    
    var body: some View {
        NavigationView {
            ZStack{
                //Image("Logo")
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
                            
//                            NavigationLink(
//                                destination: AuthView()
//                            ) {
//                                VStack(alignment: .leading) {
//                                    Text("验证")
//                                        .foregroundColor(.white)
//                                    Divider().colorInvert()
//                                }
//                                .padding()
//                            }
                        }
                    }
                }   
            }
            .background(
                Image("bg")
                    .resizable()
                    .scaledToFill()
            )
            .navigationBarTitle("主菜单")
        }
    }
}

struct SingleIconView: View{
    var index: Int
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(5)
                .shadow(radius: 2)
                .frame(width: 27, height: 27)
            Text(ClassifierSettingArgs.singlefeatureLabelDic[index]!)
                .font(.system(size: 10)).foregroundColor(Color.black)
        }
    }
}

extension View {
    func bubbleBackground() -> some View {
        self.padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray)
                    .opacity(0.7)
            }
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
                .padding(.leading, 10).frame(maxWidth: .infinity, alignment: .leading)
            
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

struct DeprecatedMainMenuView: View {
    var body: some View {
        ZStack{
            Image("Logo")
            VStack{
                Spacer()
                ScrollView {
                    VStack(spacing: 0) {
                        NavigationLink(
                            destination: DeprecatedRecordSettingView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("历史记录")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: DeprecatedInfoView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("系统设置")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
                            .padding()
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
        .navigationBarTitle("盘古")
    }
}
