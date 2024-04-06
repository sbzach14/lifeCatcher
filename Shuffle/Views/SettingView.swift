//
//  SettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 8/6/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

class volumeSetting{
    static let volumeUpDict: [Int: String] = [
        0: "无功能",
        1: "增加人数",
        2: "下一个位置",
        3: "下一个洗牌手法",
        4: "下一个方案",
        5: "开始暂停",
        6: "报下一轮"
    ]
    
    static let volumeDownDict: [Int: String] = [
        0: "无功能",
        1: "减少人数",
        2: "上一个位置",
        3: "上一个洗牌手法",
        4: "上一个方案",
        5: "开始暂停",
        6: "报下一轮",
        7: "切换音量上键功能"
    ]
}

struct SettingView: View {
    @StateObject var viewModel = SettingViewModel()
    
    
    var body: some View {
            VStack{
                SearchBar(searchText: $viewModel.searchText)
                    .onAppear {
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { notification in
                            // Handle the "Return" button pressed event here
                            // For example, you can call a method in your ViewModel
                            viewModel.onReturnKeyPressed()
                        }
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
                    }

                ScrollView {
                    VStack()  {
                        
                        if(viewModel.isActive){
                            HStack {
                                Text("黑屏").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Toggle("", isOn: $viewModel.isBlack).toggleStyle(CustomToggleStyle())
                                    .frame(width: 160, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                            }
                            Divider()
                                .foregroundColor(.white)

                            HStack {
                                Text("后置相机")
                                    .foregroundColor(.white)
                                    .padding(.leading, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Toggle("", isOn: $viewModel.isBackCamera)
                                    .toggleStyle(CustomToggleStyle())
                                    .frame(width: 160, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                            }
                            Divider()
                                .foregroundColor(.white)
                            
//                            HStack {
//                                Text("快洗模式")
//                                    .foregroundColor(.white)
//                                    .padding(.leading, 20)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                                Toggle("", isOn: $viewModel.isFast)
//                                    .toggleStyle(CustomToggleStyle())
//                                    .frame(width: 160, height: 30, alignment: .trailing)
//                                    .padding(.trailing,30) // 右侧间距
//                                    .accentColor(.white)
//                            }
//                            Divider()
//                                .foregroundColor(.white)
//                            
//                            HStack {
//                                Text("远距离模式")
//                                    .foregroundColor(.white)
//                                    .padding(.leading, 20)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                                Toggle("", isOn: $viewModel.isRemote)
//                                    .toggleStyle(CustomToggleStyle())
//                                    .frame(width: 160, height: 30, alignment: .trailing)
//                                    .padding(.trailing,30) // 右侧间距
//                                    .accentColor(.white)
//                            }
//                            Divider()
//                                .foregroundColor(.white)
                            
                            HStack {
                                Text("耳机").foregroundColor(.white).padding(.leading, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Toggle("", isOn: $viewModel.isMute).toggleStyle(CustomToggleStyle())
                                    .frame(width: 160, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                            }
                            Divider()
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("音量上键功能").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Picker("volumeUp", selection: $viewModel.volumeUp) {
                                    ForEach(0...volumeSetting.volumeUpDict.count - 1, id: \.self){
                                        index in Text(volumeSetting.volumeUpDict[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 200, height: 30, alignment: .trailing)
                                .padding(.trailing,30) // 右侧间距
                                .accentColor(.white)
                            }
                            Divider()
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("音量下键功能").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Picker("volumeDown", selection: $viewModel.volumeDown) {
                                    ForEach(0...volumeSetting.volumeDownDict.count - 1, id: \.self){
                                        index in Text(volumeSetting.volumeDownDict[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 200, height: 30, alignment: .trailing)
                                .padding(.trailing,30) // 右侧间距
                                .accentColor(.white)
                            }
                            Divider()
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("音量大小").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Slider(value: $viewModel.volumeValue, in: 0.01...0.99)
                                    .frame(width: 200, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                            }
                            Divider()
                                .foregroundColor(.white)
                        }
                        
                        NavigationLink(
                            destination: InfoView(activeDate: viewModel.activeDate, authKey: viewModel.uniqueID)
                        ) {
                            Text("信息")
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider().foregroundColor(.white)
                        
                     }
                }
            }
            .onDisappear{
                viewModel.saveChanges()
            }
            .background(
                Image("bg")
                    .resizable()
                    .scaledToFill()
            )
            .navigationBarTitle("设置")
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
