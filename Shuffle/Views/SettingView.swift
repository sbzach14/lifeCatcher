//
//  SettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 8/6/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

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
                    VStack(alignment: .leading, spacing: 0)  {
                            HStack {
                                Text("黑屏").foregroundColor(.white).padding()
                                Spacer()
                                Toggle("", isOn: $viewModel.isBlack).toggleStyle(CustomToggleStyle())
                                    .padding()
                            }
                            Divider()
                                .foregroundColor(.white)

                            HStack {
                                Text("静音")
                                    .foregroundColor(.white)
                                    .padding()

                                Spacer()

                                Toggle("", isOn: $viewModel.isMute)
                                    .toggleStyle(CustomToggleStyle())
                                    .padding()
                            }
                            Divider()
                                .foregroundColor(.white)

                            HStack {
                                Text("后置相机")
                                    .foregroundColor(.white)
                                    .padding()

                                Spacer()

                                Toggle("", isOn: $viewModel.isBackCamera)
                                    .toggleStyle(CustomToggleStyle())
                                    .padding()
                            }
                            Divider()
                                .foregroundColor(.white)
                        
//                            HStack {
//                                Text("isAug")
//                                    .foregroundColor(.primary)
//                                    .padding()
//
//                                Spacer()
//
//                                Toggle("", isOn: $viewModel.isContrastAug)
//                                    .padding()
//                            }
//                            Divider()

                            NavigationLink(
                                destination: InfoView(activeDate: viewModel.activeDate)
                            ) {
                                Text("信息")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            Divider()
                            .colorInvert()
                        
                            
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
