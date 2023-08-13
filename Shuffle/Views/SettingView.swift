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
                                Text("isBlack")
                                    .foregroundColor(.primary)
                                    .padding()
                                Spacer()
                                Toggle("", isOn: $viewModel.isBlack)
                                    .padding()
                            }
                            Divider()

                            HStack {
                                Text("isMute")
                                    .foregroundColor(.primary)
                                    .padding()

                                Spacer()

                                Toggle("", isOn: $viewModel.isMute)
                                    .padding()
                            }
                            Divider()

                            HStack {
                                Text("isBackCamera")
                                    .foregroundColor(.primary)
                                    .padding()

                                Spacer()

                                Toggle("", isOn: $viewModel.isBackCamera)
                                    .padding()
                            }
                            Divider()
                        
                            HStack {
                                Text("isAug")
                                    .foregroundColor(.primary)
                                    .padding()

                                Spacer()

                                Toggle("", isOn: $viewModel.isContrastAug)
                                    .padding()
                            }
                            Divider()

                            NavigationLink(
                                destination: InfoView(activeDate: viewModel.activeDate)
                            ) {
                                Text("Info")
                                .padding()
                            }
                            Divider()
                        
                            
                     }
                }
            }
            .onDisappear{
                viewModel.saveChanges()
            }
            .navigationBarTitle("Setting")
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
