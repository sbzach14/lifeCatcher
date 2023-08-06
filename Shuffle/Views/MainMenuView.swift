//
//  SwiftUIView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 7/30/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct MainMenuView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack{
                SearchBar(searchText: $searchText)
                ScrollView {
                    VStack(spacing: 0) {
                        NavigationLink(
                            destination: VisionObjectRecognitionView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("Recording")
                                Divider()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: RecordHistoryView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("History")
                                Divider()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: SettingView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("Setting")
                                Divider()
                            }
                            .padding()
                        }
                    }
                }
            }.navigationBarTitle("Main Menu")
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
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
            
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

