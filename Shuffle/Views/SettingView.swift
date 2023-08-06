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
    @State private var showPrivacyAlert = false
    @State private var showInfoAlert = false
    
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

                            Button(action: {
                                // Show privacy alert
                                self.showPrivacyAlert.toggle()
                            }) {
                                Text("Privacy")
                                    .foregroundColor(.primary)
                                    .padding()
                            }
                            .alert(isPresented: $showPrivacyAlert) {
                                Alert(title: Text("Privacy"), message: Text("Your privacy information goes here."), dismissButton: .cancel())
                            }

                            Divider()

                            Button(action: {
                                // Show info alert
                                self.showInfoAlert.toggle()
                            }) {
                                Text("Info")
                                    .foregroundColor(.primary)
                                    .padding()
                            }
                            .alert(isPresented: $showInfoAlert) {
                                Alert(title: Text("Info"), message: Text("Version 1.0"), dismissButton: .cancel())
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
