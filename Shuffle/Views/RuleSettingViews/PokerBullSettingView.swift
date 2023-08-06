////
////  RuleSettingView.swift
////  Shuffle
////
////  Created by Zhangyi Chen on 5/27/23.
////  Copyright © 2023 Apple. All rights reserved.
////
//import SwiftUI
//
//struct PokerBullSettingView: View {
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//
//    @State private var setting : Int = 0
//
//    @State private var playerNum: Int = 0
//    @State private var handNum: Int = 2
//    @State private var isCompareSuit: Int = 1
//    @State private var fiveLittleRank: Int = 0
//    @State private var secondRankRule: Int = 0
//    @State private var jokerIsMinZero: Int = 0
//    @State private var BullRules: [Int] = [0]
//    @State private var tenValueRange: Int = 0
//    @State private var JValueRange:Int = 0
//    @State private var QValueRange:Int = 0
//    @State private var KValueRange:Int = 0
//    @State private var blackJokerValueRange: Int = 0
//    @State private var redJokerValueRange: Int = 0
//    @State private var threeValueRange: Int = 0
//    @State private var sixValueRange: Int = 0
//    @State private var spadeAValueRange: Int = 0
//
//    @State private var suitRules: [Int] = [3,2,1,0]
//    @State private var threeCardsRankRules: [RankRulesSate] = [
//        RankRulesSate(index: 5, isChecked: true),
//        RankRulesSate(index: 4, isChecked: true),
//        RankRulesSate(index: 3, isChecked: true),
//        RankRulesSate(index: 2, isChecked: true),
//        RankRulesSate(index: 1, isChecked: true),
//        RankRulesSate(index: 0, isChecked: true)
//    ]
//
//    @State private var rankRules = [RankRulesSate]()
//
//    @State private var navigateToSuitRules = false
//    @State private var navigateToRankRules = false
//    @State private var navigateToMainContent = false
//
//    var body: some View {
//        VStack
//        {
//            let selectedRule = GameManager.gameRules[1] as! ThreeCardPokerGameRule
//            for i in 0...PokerBullRule.fiveCardsRankRules.count - 1{
//                rankRules.append(RankRulesSate(index: i, isChecked: true))
//            }
//
//            Text("Rule Setting")
//                .font(.title)
//                .padding()
//
//            Spacer()
//
//            ScrollView {
//                VStack {
//
//                    HStack
//                    {
//                        Text("设置模版")
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.leading, 60) // 左侧间距
//                        Picker("setting", selection: $setting) {
//                            ForEach(0...selectedRule.setting.count - 1, id: \.self) {
//                                index in
//                                Text(selectedRule.setting[index]!).tag(index)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .padding(.trailing, 60) // 右侧间距
//                        .onChange(of: setting) { _ in
//                            handleSettingChange()
//                        }
//                    }
//
//                    HStack
//                    {
//                        Text("玩家数量")
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.leading, 60) // 左侧间距
//                        Picker("playerNum", selection: $playerNum) {
//                            ForEach(0...selectedRule.playerNum.count - 1, id: \.self) { index in
//                                Text(String(selectedRule.playerNum[index])).tag(index)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .padding(.trailing, 60) // 右侧间距
//                    }
//
//                    if(setting == 1)
//                    {
//                        if(true)
//                        {
//                            HStack
//                            {
//                                Text("手牌数量")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("handNum", selection: $handNum) {
//                                    ForEach(0...selectedRule.handNum.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.handNum[index])).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//
//                            HStack {
//                                Text("是否比较花色")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("isCompareSuit", selection: $isCompareSuit) {
//                                    ForEach(0...selectedRule.isCompareSuit.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.isCompareSuit[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//
//                            HStack
//                            {
//                                Text("五小大小比较")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("fiveLittleRank", selection: $fiveLittleRank) {
//                                    ForEach(0...selectedRule.isMixedSuit.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.fiveLittleRank[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//
//
//                            HStack
//                            {
//                                Text("同牛同点比较规则")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("secondRankRule", selection: $secondRankRule) {
//                                    ForEach(0...selectedRule.secondRankRule.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.secondRankRule[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//
//                            HStack
//                            {
//                                Text("王是最小的0")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("minRank", selection: $jokerIsMinZero) {
//                                    ForEach(0...selectedRule.minRank.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.jokeris[index])).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//                        }
//
//
//                        HStack
//                        {
//                            Text("是否有A")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.leading, 60) // 左侧间距
//                            Picker("isAce", selection: $isAce) {
//                                ForEach(0...selectedRule.isAce.count - 1, id: \.self) { index in
//                                    Text(String(selectedRule.isAce[index]!)).tag(index)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                            .padding(.trailing, 60) // 右侧间距
//                        }
//
//                        if(isAce == 2)
//                        {
//
//                            HStack
//                            {
//                                Text("是否计A顺子")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("isAceStraight", selection: $isAceStraight) {
//                                    ForEach(0...selectedRule.isAceStraight.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.isAceStraight[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//                        }
//
//                        HStack
//                        {
//                            Text("是否有JQK")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.leading, 60) // 左侧间距
//                            Picker("isHeadCard", selection: $isHeadCard) {
//                                ForEach(0...selectedRule.isHeadCard.count - 1, id: \.self) { index in
//                                    Text(String(selectedRule.isHeadCard[index]!)).tag(index)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                            .padding(.trailing, 60) // 右侧间距
//                        }
//
//
//                        HStack
//                        {
//                            Text("是否有大王")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.leading, 60) // 左侧间距
//                            Picker("isRedJoker", selection: $isRedJoker) {
//                                ForEach(0...selectedRule.isRedJoker.count - 1, id: \.self) { index in
//                                    Text(String(selectedRule.isRedJoker[index]!)).tag(index)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                            .padding(.trailing, 60) // 右侧间距
//                        }
//
//                        if(isRedJoker == 1)
//                        {
//
//                            HStack
//                            {
//                                Text("大王可替花色")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("redJokerSuit", selection: $redJokerSuit) {
//                                    ForEach(0...selectedRule.redJokerSuit.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.redJokerSuit[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//
//                            HStack
//                            {
//                                Text("大王可替点数")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("redJokerRank", selection: $redJokerRank) {
//                                    ForEach(0...selectedRule.redJokerRank.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.redJokerRank[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//                        }
//
//
//                        HStack
//                        {
//                            Text("是否有小王")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.leading, 60) // 左侧间距
//                            Picker("isBlackJoker", selection: $isBlackJoker) {
//                                ForEach(0...selectedRule.isBlackJoker.count - 1, id: \.self) { index in
//                                    Text(String(selectedRule.isBlackJoker[index]!)).tag(index)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                            .padding(.trailing, 60) // 右侧间距
//                        }
//
//                        if(isBlackJoker == 1)
//                        {
//                            HStack
//                            {
//                                Text("小王可替花色")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("blackJokerSuit", selection: $blackJokerSuit) {
//                                    ForEach(0...selectedRule.blackJokerSuit.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.blackJokerSuit[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//
//                            HStack
//                            {
//                                Text("小王可替点数")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//                                Picker("blackJokerRank", selection: $blackJokerRank) {
//                                    ForEach(0...selectedRule.blackJokerRank.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.blackJokerRank[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 60) // 右侧间距
//                            }
//
//                        }
//
//
//                        HStack
//                        {
//                            Text("自定义牌型顺序")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.leading, 60) // 左侧间距
//
//                            Button(action: {
//                                navigateToRankRules = true
//                            }) {
//                                Image(systemName: "gear")
//                                    .resizable()
//                                    .foregroundColor(.white)
//                                    .padding(3)
//                                    .background(Color.blue)
//                                    .cornerRadius(10)
//                                    .frame(width: 40, height: 40) // 设置正方形大小
//                            }
//                            .padding(.trailing, 60)
//                            .background(
//                                NavigationLink(
//                                    destination: RankRulesView(rankRules: $rankRules, selectedRuleIndex: selectedRule.ruleIndex),
//                                    isActive: $navigateToRankRules,
//                                    label: EmptyView.init
//                                )
//                                .hidden()
//                            )
//                        }
//
//                        if(isCompareSuit == 1)
//                        {
//                            HStack
//                            {
//                                Text("自定义花色顺序")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 60) // 左侧间距
//
//                                Button(action: {
//                                    navigateToSuitRules = true
//                                }) {
//                                    Image(systemName: "gear")
//                                        .resizable()
//                                        .foregroundColor(.white)
//                                        .padding(3)
//                                        .background(Color.blue)
//                                        .cornerRadius(10)
//                                        .frame(width: 40, height: 40) // 设置正方形大小
//                                }
//                                .padding(.trailing, 60)
//                                .background(
//                                    NavigationLink(
//                                        destination: SuitRulesView(suitRules: $suitRules),
//                                        isActive: $navigateToSuitRules,
//                                        label: EmptyView.init
//                                    )
//                                    .hidden()
//                                )
//                            }
//                        }
//                    }
//                }
//            }.frame(width: 400, height: 600)
//
//            Spacer()
//
//            Button(action: {
//                alertMessage = ThreeCardPokerGame.legalCheck(
//                    playerNum: selectedRule.playerNum[playerNum],
//                    minRank: selectedRule.minRank[minRank],
//                    handNum: selectedRule.handNum[handNum],
//                    isHeadCard: isHeadCard,
//                    isRedJoker: isRedJoker,
//                    isBlackJoker: isBlackJoker
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
//                Text("Start")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(10)
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
//                    destination: MainContentView(ruleIndex: selectedRule.ruleIndex, args : [
//                        selectedRule.playerNum[playerNum],
//                        selectedRule.handNum[handNum],
//                        isCompareSuit,
//                        selectedRule.minRank[minRank],
//                        isAce,
//                        isAceStraight,
//                        isHeadCard,
//                        isRedJoker,
//                        redJokerSuit,
//                        redJokerRank,
//                        isBlackJoker,
//                        blackJokerSuit,
//                        blackJokerRank,
//                        isMixedSuit,
//                        isReverseHighCard
//                    ], rankRules : GameManager.getCheckedIndexes(rankRules: rankRules), suitRules: suitRules),
//                    isActive: $navigateToMainContent,
//                    label: EmptyView.init
//                )
//                .hidden()
//            )
//        }
//    }
//
//    private func showAlertWithMessage() {
//        showAlert = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            showAlert = false
//        }
//    }
//
//    private func handleSettingChange() {
//        //标准五张牛牛
//        if(setting == 0)
//        {
//            isCompareSuit = 1
//
//
//            suitRules = [3,2,1,0]
//            rankRules = [
//                RankRulesSate(index: 13, isChecked: false),
//                RankRulesSate(index: 12, isChecked: true),
//                RankRulesSate(index: 11, isChecked: false),
//                RankRulesSate(index: 10, isChecked: false),
//                RankRulesSate(index: 9, isChecked: false),
//                RankRulesSate(index: 8, isChecked: false),
//                RankRulesSate(index: 7, isChecked: false),
//                RankRulesSate(index: 6, isChecked: true),
//                RankRulesSate(index: 5, isChecked: false),
//                RankRulesSate(index: 4, isChecked: true),
//                RankRulesSate(index: 3, isChecked: true),
//                RankRulesSate(index: 2, isChecked: false),
//                RankRulesSate(index: 1, isChecked: true),
//                RankRulesSate(index: 0, isChecked: true)
//            ]
//        }
//    }
//}
//
//
//struct PokerBullSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        PokerBullSettingView()
//    }
//}
//
//
//
//
//
//
