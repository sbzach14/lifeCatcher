//
//  RuleSettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/27/23.
//  Copyright © 2023 Apple. All rights reserved.
//
import SwiftUI

struct TexasPokerRuleSettingView: View {
    @Binding var args: [Int]
    @Binding var suitRules: [Int]
    @Binding var rankRules: [RankRulesSate]
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isCompareSuit: Int = 0
    @State private var isAceStraight: Int = 1
    @State private var minRank: Int = 0
    @State private var handNum: Int = 1
    @State private var communityNum: Int = 2
    @State private var handUseType: Int = 0
    @State private var handUseNum: Int = 0
    @State private var tempsuitRules: [Int] = [3,2,1,0]
    @State private var temprankRules: [RankRulesSate] = [
        RankRulesSate(index: 11, isChecked: true),
        RankRulesSate(index: 10, isChecked: true),
        RankRulesSate(index: 9, isChecked: true),
        RankRulesSate(index: 8, isChecked: true),
        RankRulesSate(index: 7, isChecked: true),
        RankRulesSate(index: 6, isChecked: true),
        RankRulesSate(index: 5, isChecked: false),
        RankRulesSate(index: 4, isChecked: false),
        RankRulesSate(index: 3, isChecked: false),
        RankRulesSate(index: 2, isChecked: true),
        RankRulesSate(index: 1, isChecked: true),
        RankRulesSate(index: 0, isChecked: true)
    ]
    
    @State private var navigateToSuitRules = false
    @State private var navigateToRankRules = false
    @State private var navigateToMainContent = false
    
    var body: some View {
        VStack
        {
            let selectedRule = GameManager.gameRules[0] as! TexasPokerRule
            
            Spacer()
            
            ScrollView{
                VStack {
                    HStack
                    {
                        Image("icon_list")
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("手牌数量")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)// 左侧间距
                        Picker("handNum", selection: $args[3]) {
                            ForEach(0...selectedRule.handNum.count - 1, id: \.self) { index in
                                Text(String(selectedRule.handNum[index])).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing, 30) // 右侧间距
                        .accentColor(.white)
                    }
                    .background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    HStack
                    {
                        Image("icon_list")
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("公共牌数量")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white) // 左侧间距
                        Picker("communityNum", selection: $args[4]) {
                            ForEach(0...selectedRule.communityNum.count - 1, id: \.self) { index in
                                Text(String(selectedRule.communityNum[index])).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing, 30) // 右侧间距
                        .accentColor(.white)
                    }
                    .background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    HStack {
                        Image("icon_list")
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("是否比较花色")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white) // 左侧间距
                        Picker("isCompareSuit", selection: $args[0]) {
                            ForEach(0...selectedRule.isCompareSuit.count - 1, id: \.self) { index in
                                Text(String(selectedRule.isCompareSuit[index]!)).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing, 30) // 右侧间距
                        .accentColor(.white) // 右侧间距
                    }
                    .background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    HStack
                    {
                        Image("icon_list")
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        
                        Text("是否计A顺子")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white) // 左侧间距
                        Picker("isAceStraight", selection: $args[1]) {
                            ForEach(0...selectedRule.isAceStraight.count - 1, id: \.self) { index in
                                Text(String(selectedRule.isAceStraight[index]!)).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing, 30) // 右侧间距
                        .accentColor(.white)
                    }
                    .background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    HStack
                    {
                        Image("icon_list")
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("牌堆最小牌")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white) // 左侧间距
                        Picker("minRank", selection: $args[2]) {
                            ForEach(0...selectedRule.minRank.count - 1, id: \.self) { index in
                                Text(String(selectedRule.minRank[index])).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing, 30) // 右侧间距
                        .accentColor(.white)
                    }
                    .background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    
                    HStack
                    {
                        Image("icon_list")
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("手牌限制")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)// 左侧间距
                        Picker("handUseType", selection: $args[5]) {
                            ForEach(0...selectedRule.handUseType.count - 1, id: \.self) { index in
                                Text(String(selectedRule.handUseType[index]!)).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing, 30) // 右侧间距
                        .accentColor(.white)
                    }
                    .background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    if(handUseType != 0)
                    {
                        HStack
                        {
                            Image("icon_list")
                                .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("n")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                            Picker("handUseNum", selection: $args[6]) {
                                ForEach(0...selectedRule.handUseNum.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.handUseNum[index])).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white) // 右侧间距
                        }
                        .background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                    }
                    
                    HStack
                    {
                        Image("icon_ranksetting")
                            .resizable()
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        
                        Text("自定义牌型顺序")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white) // 左侧间距
                        
                        Button(action: {
                            navigateToRankRules = true
                        }) {
                            Image("icon_next")
                                .resizable()
                                .frame(width: 30, height: 30) // 设置正方形大小
                        }
                        .padding(.trailing, 40)
                        .background(
                            NavigationLink(
                                destination: RankRulesView(rankRules: $rankRules, selectedRuleIndex: selectedRule.ruleIndex),
                                isActive: $navigateToRankRules,
                                label: EmptyView.init
                            )
                            .hidden()
                        )
                    }
                    .background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    if(isCompareSuit == 1)
                    {
                        HStack
                        {
                            Image("icon_suitsetting")
                                .resizable()
                                .frame(width: 40, height: 40).padding(.leading, 20)
                            
                            Text("自定义花色顺序")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距

                            Button(action: {
                                navigateToSuitRules = true
                            }) {
                                Image("icon_next")
                                    .resizable()
                                    .frame(width: 30, height: 30) // 设置正方形大小
                            }
                            .padding(.trailing, 40)
                            .background(
                                NavigationLink(
                                    destination: SuitRulesView(suitRules: $suitRules),
                                    isActive: $navigateToSuitRules,
                                    label: EmptyView.init
                                )
                                .hidden()
                            )
                        }
                        .background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                    }
                    
                }
            }
                        
//            Button(action: {
//                alertMessage = TexasPoker.legalCheck(
//                    playerNum: selectedRule.playerNum[playerNum],
//                    minRank: selectedRule.minRank[minRank],
//                    handUseType: handUseType,
//                    handUseNum: selectedRule.handUseNum[handUseNum],
//                    handNum: selectedRule.handNum[handNum],
//                    communityNum: selectedRule.communityNum[communityNum]
//                )
//
//                if(alertMessage != "")
//                {
//                    showAlertWithMessage()
//                }
//                else {
//                    navigateToMainContent = true
//                }
//
//            }) {
//                Image("icon_start").resizable().frame(width: 150, height: 60)
//            }
//            .padding()
//            .alert(isPresented: $showAlert) {
//                Alert(
//                    title: Text("参数错误"),
//                    message: Text(alertMessage),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//            .background(
//                NavigationLink(
//                    destination: MainContentView(
//                        shuffleMode: shuffleMode,
//                        calModeArgs: [calMode, target, targetPos],
//                        ruleIndex: selectedRule.ruleIndex, args : [
//                        selectedRule.playerNum[playerNum],
//                        isCompareSuit,
//                        isAceStraight,
//                        selectedRule.minRank[minRank],
//                        selectedRule.handNum[handNum],
//                        selectedRule.communityNum[communityNum],
//                        handUseType,
//                        selectedRule.handUseNum[handUseNum]
//                    ], rankRules : GameManager.getCheckedIndexes(rankRules: rankRules), suitRules: suitRules, allCardIndex: TexasPoker.getAllCardIndex(minRank: selectedRule.minRank[minRank]), minCardNum : TexasPoker.getMinCardNum(playerNum: selectedRule.playerNum[playerNum], handNum: selectedRule.handNum[handNum], communityNum: selectedRule.communityNum[communityNum])),
//                    isActive: $navigateToMainContent,
//                    label: EmptyView.init
//                )
//                .hidden()
//            )
        }.navigationTitle("规则设置")
            .background(Image("bg").resizable().scaledToFill())
    }
    
    
    
    private func showAlertWithMessage() {
        showAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showAlert = false
        }
    }
    
    private func handleSettingChange() {
    }
}


struct TexasPokerRuleSettingView_Previews:
    PreviewProvider {
    static var previews: some View {
        let args: Binding<[Int]> = .constant([])  // 提供一个初始值
        let suitRules: Binding<[Int]> = .constant([])  // 提供一个初始值
        let rankRules: Binding<[RankRulesSate]> = .constant([])  // 提供一个初始值
        TexasPokerRuleSettingView(args: args, suitRules: suitRules, rankRules: rankRules)
    }
}






