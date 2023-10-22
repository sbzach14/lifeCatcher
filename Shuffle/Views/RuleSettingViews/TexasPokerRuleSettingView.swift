//
//  RuleSettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/27/23.
//  Copyright © 2023 Apple. All rights reserved.
//
import SwiftUI

struct TexasPokerRuleSettingView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var shuffleMode: Int = 0
    @State private var calMode: Int = 0//0不打色 1去色 2留色
    
    @State private var target: Int = 0//0max 1min
    @State private var targetPos: Int = 1//目标位置
    
    
    @State private var setting : Int = 0
    
    @State private var playerNum: Int = 0
    @State private var isCompareSuit: Int = 0
    @State private var isAceStraight: Int = 1
    @State private var minRank: Int = 0
    @State private var handNum: Int = 1
    @State private var communityNum: Int = 2
    @State private var handUseType: Int = 0
    @State private var handUseNum: Int = 0
    @State private var suitRules: [Int] = [3,2,1,0]
    @State private var rankRules: [RankRulesSate] = [
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
                        Image("icon_shufflemode")
                            .resizable()
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("洗牌模式")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white) // 左侧间距
                        Picker("shuffleMode", selection: $shuffleMode) {
                            Text("洗牌").tag(0)
                            Text("拨到顶").tag(1)
                            Text("拨中间").tag(2)
                    
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
                        Image("icon_cutmode")
                            .resizable()
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("打色模式")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white) // 左侧间距
                        Picker("calMode", selection: $calMode) {
                            Text("不打色").tag(0)
                            Text("去色").tag(1)
                            Text("留色").tag(2)
                    
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
                    
                    if calMode == 0{
                        HStack
                        {
                            Image("icon_voice")
                                .resizable()
                                .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("报牌模式")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)// 左侧间距
                            Picker("target", selection: $target) {
                                Text("报最大家位置").tag(0)
                                Text("报最小家位置").tag(1)
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
                    }
                    
                    else{
                        HStack
                        {
                            Image("icon_voice")
                                .resizable()
                                .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("报牌模式")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                            Picker("target", selection: $target) {
                                Text("报切几张目标位置最大").tag(0)
                                Text("报切几张目标位置最小").tag(1)
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
                            Image("icon_voice")
                                .resizable()
                                .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("目标位置")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                            Picker("targetPos", selection: $targetPos) {
                                ForEach(1...selectedRule.playerNum[playerNum], id: \.self) { index in
                                    Text(String(index)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
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

                        Image("icon_user")
                            .resizable()
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("玩家数量")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                        Picker("playerNum", selection: $playerNum) {
                            ForEach(0...selectedRule.playerNum.count - 1, id: \.self) { index in
                                Text(String(selectedRule.playerNum[index])).tag(index)
                                
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
                        Image("icon_setting")
                            .resizable()
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("设置模版")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                        Picker("setting", selection: $setting) {
                            ForEach(0...selectedRule.setting.count - 1, id: \.self) {
                                index in
                                Text(selectedRule.setting[index]!).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing, 30) // 右侧间距
                        .accentColor(.white)
                        .onChange(of: setting) { _ in
                            handleSettingChange()
                        }
                    }
                    .background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    
                    
                    if(setting == 2)
                    {
                        HStack
                        {
                            Image("icon_list")
                                .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("手牌数量")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)// 左侧间距
                            Picker("handNum", selection: $handNum) {
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
                            Picker("communityNum", selection: $communityNum) {
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
                            Picker("isCompareSuit", selection: $isCompareSuit) {
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
                            Picker("isAceStraight", selection: $isAceStraight) {
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
                            Picker("minRank", selection: $minRank) {
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
                            Picker("handUseType", selection: $handUseType) {
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
                                Picker("handUseNum", selection: $handUseNum) {
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
                                Image(systemName: "gear")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .padding(3)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .frame(width: 40, height: 40) // 设置正方形大小
                            }
                            .padding(.trailing, 30)
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
                                    Image(systemName: "gear")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .padding(3)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                        .frame(width: 40, height: 40) // 设置正方形大小
                                }
                                .padding(.trailing, 30)
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
            }
            
            Spacer()
            
            Button(action: {
                alertMessage = TexasPoker.legalCheck(
                    playerNum: selectedRule.playerNum[playerNum],
                    minRank: selectedRule.minRank[minRank],
                    handUseType: handUseType,
                    handUseNum: selectedRule.handUseNum[handUseNum],
                    handNum: selectedRule.handNum[handNum],
                    communityNum: selectedRule.communityNum[communityNum]
                )
                
                if(alertMessage != "")
                {
                    showAlertWithMessage()
                }
                else {
                    navigateToMainContent = true
                }
                
            }) {
                Image("icon_start").resizable().frame(width: 150, height: 60)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("参数错误"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .background(
                NavigationLink(
                    destination: MainContentView(
                        shuffleMode: shuffleMode,
                        calModeArgs: [calMode, target, targetPos],
                        ruleIndex: selectedRule.ruleIndex, args : [
                        selectedRule.playerNum[playerNum],
                        isCompareSuit,
                        isAceStraight,
                        selectedRule.minRank[minRank],
                        selectedRule.handNum[handNum],
                        selectedRule.communityNum[communityNum],
                        handUseType,
                        selectedRule.handUseNum[handUseNum]
                    ], rankRules : GameManager.getCheckedIndexes(rankRules: rankRules), suitRules: suitRules, allCardIndex: TexasPoker.getAllCardIndex(minRank: selectedRule.minRank[minRank]), minCardNum : TexasPoker.getMinCardNum(playerNum: selectedRule.playerNum[playerNum], handNum: selectedRule.handNum[handNum], communityNum: selectedRule.communityNum[communityNum])),
                    isActive: $navigateToMainContent,
                    label: EmptyView.init
                )
                .hidden()
            )
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
        if(setting == 0)
        {
            isCompareSuit = 0
            isAceStraight = 1
            minRank = 0
            handNum = 1
            communityNum = 2
            handUseType = 0
            handUseNum = 0
            suitRules = [3,2,1,0]
            rankRules = [
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
        }
        
        else if(setting == 1)
        {
            isCompareSuit = 0
            isAceStraight = 1
            minRank = 4
            handNum = 1
            communityNum = 2
            handUseType = 0
            handUseNum = 0
            suitRules = [3,2,1,0]
            rankRules = [
                RankRulesSate(index: 11, isChecked: true),
                RankRulesSate(index: 10, isChecked: true),
                RankRulesSate(index: 8, isChecked: true),
                RankRulesSate(index: 9, isChecked: true),
                RankRulesSate(index: 7, isChecked: true),
                RankRulesSate(index: 6, isChecked: true),
                RankRulesSate(index: 5, isChecked: false),
                RankRulesSate(index: 4, isChecked: false),
                RankRulesSate(index: 3, isChecked: false),
                RankRulesSate(index: 2, isChecked: true),
                RankRulesSate(index: 1, isChecked: true),
                RankRulesSate(index: 0, isChecked: true)
            ]
        }
        
    }
}


struct TexasPokerRuleSettingView_Previews: PreviewProvider {
    static var previews: some View {
        TexasPokerRuleSettingView()
    }
}






