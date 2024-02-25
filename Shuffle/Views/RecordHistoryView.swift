//
//  RecordHistoryView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 8/6/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct RecordHistoryView: View {
    @State private var searchText = ""
    @State private var selectedRuleIndex: Int? = nil
    @State private var isNav = false
    @StateObject private var viewModel = RecordHistoryViewModel()
    
    var body: some View {
        VStack {
            NavigationLink(destination: SelectRuleView(), isActive: $isNav) {
            }
            .hidden()
            
            ScrollView {
                VStack(spacing: 0) {
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
        .onAppear {
            // Show the navigation bar when this view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isNav = viewModel.isActive
            }
        }
    }
}

struct RecordHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        RecordHistoryView()
    }
}
