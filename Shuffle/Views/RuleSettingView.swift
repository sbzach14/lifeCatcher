//
//  RuleSettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/27/23.
//  Copyright © 2023 Apple. All rights reserved.
//
import SwiftUI

struct RuleSettingView: View {
    var selectedRuleIndex: Int
    @State private var selectedPlayerNum: Int = 0
    @State private var navigateToMainContent = false
    
    var body: some View {
        VStack {
            Text("Rule Setting")
                .font(.title)
                .padding()
            
            Spacer()
            
            Text("Player Num")
            Picker("Player Num", selection: $selectedPlayerNum) {
                if let selectedRule = GameManager.gameRules[selectedRuleIndex] {
                    ForEach(0...selectedRule.maxPlayerNum - selectedRule.minPlayerNum, id: \.self) { index in
                        Text(String(index + selectedRule.minPlayerNum)).tag(index)
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            
            Spacer()
            
            Button(action: {
                navigateToMainContent = true
            }) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .background(
                NavigationLink(
                    destination: MainContentView(ruleIndex: selectedRuleIndex, playerNum: selectedPlayerNum + GameManager.gameRules[selectedRuleIndex]!.minPlayerNum),
                    isActive: $navigateToMainContent,
                    label: EmptyView.init
                )
                .hidden()
            )
        }
    }
}


struct RuleSettingView_Previews: PreviewProvider {
    static var previews: some View {
        RuleSettingView(selectedRuleIndex: 0)
    }
}

