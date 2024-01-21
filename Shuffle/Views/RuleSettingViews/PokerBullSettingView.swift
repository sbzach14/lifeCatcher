//
//  RuleSettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/27/23.
//  Copyright © 2023 Apple. All rights reserved.
//
import SwiftUI

struct PokerBullSettingView: View {
    @Binding var args: [Int]
    @Binding var suitRules: [Int]
    @Binding var rankRules: [RankRulesSate]
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var handNum: Int = 2
    @State private var wayToDeal: Int = 0
    @State private var cardsNum: Int = 5
    @State private var isCompareSuit: Int = 1
    @State private var fiveLittleRank: Int = 0
    @State private var secondRankRule: Int = 0
    @State private var jokerIsMinZero: Int = 0
    @State private var BullRules: [Int] = [0]
    @State private var selectedIndices: Set<Int> = []
    @State private var bullrulelist: [Int] = [1,0,0,0,0,0,0,0,0]
    @State private var tenValueRange: Int = 0
    @State private var JValueRange:Int = 0
    @State private var QValueRange:Int = 0
    @State private var KValueRange:Int = 0
    @State private var blackJokerValueRange: Int = 0
    @State private var redJokerValueRange: Int = 0
    @State private var threeValueRange: Int = 0
    @State private var sixValueRange: Int = 0
    @State private var spadeAValueRange: Int = 0
    @State private var threeCardsRankRules: [RankRulesSate] = [
        RankRulesSate(index: 5, isChecked: true),
        RankRulesSate(index: 4, isChecked: true),
        RankRulesSate(index: 3, isChecked: true),
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
            let selectedRule = GameManager.gameRules[1] as!PokerBullRule
            Spacer()
            
            ScrollView{
                VStack{
                        HStack{Image("icon_list")
                                        .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("牌库数量")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                            Picker("cardsNum", selection: $args[0]) {
                                ForEach(0...selectedRule.cardsNum.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.cardsNum[index])).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                        
                        HStack{Image("icon_list")
                                        .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("手牌数量")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                            Picker("handNum", selection: $args[1]) {
                                ForEach(0...selectedRule.handNum.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.handNum[index])).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white) // 右侧间距
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                        
                        HStack{Image("icon_list")
                                .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("发牌方式")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                            Picker("wayToDeal", selection: $args[3]) {
                                ForEach(0...selectedRule.wayToDeal.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.wayToDeal[index]!)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white) // 右侧间距
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                        
                        HStack{Image("icon_list")
                                        .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("是否比较花色")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                            Picker("isCompareSuit", selection: $args[2]) {
                                ForEach(0...selectedRule.isCompareSuit.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.isCompareSuit[index]!)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white) // 右侧间距
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                        HStack{Image("icon_list")
                                        .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("同牛同点比较规则")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                            Picker("secondRankRule", selection: $args[5]) {
                                ForEach(0...selectedRule.secondRankRule.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.secondRankRule[index]!)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white) // 右侧间距
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                        Group{
                        if(args[0] == 6 || args[0] == 1 || args[0] == 4){
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("大王的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("redJokerValueRange", selection: $args[12]) {
                                    ForEach(0...selectedRule.redJokerValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.redJokerValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("小王的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("blackJokerValueRange", selection: $args[11]) {
                                    ForEach(0...selectedRule.blackJokerValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.blackJokerValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                            if(args[11] == 0 && args[12] == 0){
                                
                                HStack{Image("icon_list")
                                        .frame(width: 40, height: 40).padding(.leading, 20)
                                    Text("王是否是最小的0")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.white) // 左侧间距
                                    Picker("jokerIsMinZero", selection: $args[6]) {
                                        ForEach(0...selectedRule.jokerIsMinZero.count - 1, id: \.self) { index in
                                            Text(String(selectedRule.jokerIsMinZero[index]!)).tag(index)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 30) // 右侧间距
                                    .accentColor(.white)
                                }.background(
                                    Image("list_bg") // 背景图片
                                        .resizable()
                                        .scaledToFill()
                                )
                                .frame(height: 50)
                            }
                        }//card == 6 54张牌, 32张牌，42张牌, 含有大小王
                        if(args[0] != 2){
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("10的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("tenValueRange", selection: $args[7]) {
                                    ForEach(0...selectedRule.tenValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.tenValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                        }//card != 2, 有10
                        
                        if (args[0] == 0 || args[0] == 1 || args[0] == 5 || args[0] == 6){
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("J的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("JValueRange", selection: $args[8]) {
                                    ForEach(0...selectedRule.JValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.JValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                            
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("Q的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("QValueRange", selection: $args[9]) {
                                    ForEach(0...selectedRule.QValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.QValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                            
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("K的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("KValueRange", selection: $args[10]) {
                                    ForEach(0...selectedRule.KValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.KValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("Q的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("QValueRange", selection: $args[9]) {
                                    ForEach(0...selectedRule.QValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.QValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                        }//包含J,Q,K
                        // 3, 6, SpadeAValue
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("♠️A的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("spadeAValueRange", selection: $args[15]) {
                                    ForEach(0...selectedRule.spadeAValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.spadeAValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("3的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("threeValueRange", selection: $args[13]) {
                                    ForEach(0...selectedRule.threeValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.threeValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                            
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("6的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                                Picker("sixValueRange", selection: $args[14]) {
                                    ForEach(0...selectedRule.sixValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.sixValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing, 30) // 右侧间距
                            .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                        }

                        if (args[1] == 2){
                            HStack{Image("icon_list")
                                    .frame(width: 40, height: 40).padding(.leading, 20)
                                Text("可以组成牛的牌型:").font(.headline).frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 50)
                            
                            ForEach(0..<selectedRule.BullRules.count-1, id: \.self) { index in
                                HStack {
                                    Image("icon_list")
                                            .frame(width: 40, height: 40).padding(.leading, 20)
                                    
                                    Text(selectedRule.BullRules[index]!)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 200, alignment: .leading)
                                    
                                    Spacer()

                                    Toggle("", isOn: bindingForIndex(index))
                                        .toggleStyle(CustomToggleStyle())
                                        .padding(.trailing,50)
                                        .frame(width: 60, height: 40)
                                    
                                }.background(
                                    Image("list_bg") // 背景图片
                                        .resizable()
                                        .scaledToFill()
                                )
                                .frame(height: 50)
                            }
//                            args.replaceSubrange(15..<args.count, with: bullrulelist)
                        }
                        
                        HStack{
                            Image("icon_ranksetting")
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
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                    //setting = 3,自定义
                }//VStack
            }//ScrollView
            
            Spacer()
            
//            Button(action: {
//                alertMessage = PokerBull.legalCheck(
//                    playerNum: selectedRule.playerNum[playerNum], handNum: selectedRule.handNum[handNum],cardNum: selectedRule.cardsNum[cardsNum]
//                )
//
//                if(alertMessage != "")
//                {
//                    showAlertWithMessage()
//                }
//                else {
//                    print("牛牛rulelist", bullrulelist.count)
//                    //organize the args
//                    args = [
//                        selectedRule.playerNum[playerNum], selectedRule.cardsNum[cardsNum],
//                        selectedRule.handNum[handNum],
//                        wayToDeal,
//                        isCompareSuit,
//                        fiveLittleRank,
//                        secondRankRule,
//                        jokerIsMinZero,
//                        tenValueRange,
//                        JValueRange,
//                        QValueRange,
//                        KValueRange,
//                        blackJokerValueRange,
//                        redJokerValueRange,
//                        threeValueRange,
//                        sixValueRange,
//                        spadeAValueRange] + bullrulelist + [0]
//                    navigateToMainContent = true
//                }
//
//
//
//            }) {
//                Image("icon_start").resizable().frame(width: 150, height: 60)
//            }.padding()
//                .alert(isPresented: $showAlert) {
//                    Alert(
//                        title: Text("参数错误"),
//                        message: Text(alertMessage),
//                        dismissButton: .default(Text("OK"))
//                    )
//                }.background(
//                    NavigationLink(
//                        destination: MainContentView(shuffleMode: shuffleMode,calModeArgs:[calMode, target, targetPos], ruleIndex: selectedRule.ruleIndex, args : args, rankRules : GameManager.getCheckedIndexes(rankRules: rankRules), suitRules: suitRules, allCardIndex: PokerBull.GetAllCardIndex(), minCardNum: PokerBull.GetMinCardNum(playerNum: playerNum, handNum: handNum)),
//                        isActive: $navigateToMainContent,
//                        label: EmptyView.init
//                    )
//                    .hidden()
//                )
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
    
    private func bindingForIndex(_ index: Int) -> Binding<Bool> {
        return Binding<Bool>(
            get: { selectedIndices.contains(index) },
            set: { isSelected in
                if isSelected {
                    selectedIndices.insert(index)
                    bullrulelist.append(index)
                } else {
                    selectedIndices.remove(index)
                    if let indexToRemove = bullrulelist.firstIndex(of: index) {
                        bullrulelist.remove(at: indexToRemove)
                    }
                }
            }
        )
    }
    
}


struct PokerBullSettingView_Previews: PreviewProvider {
    static var previews: some View {
        let args: Binding<[Int]> = .constant([])  // 提供一个初始值
        let suitRules: Binding<[Int]> = .constant([])  // 提供一个初始值
        let rankRules: Binding<[RankRulesSate]> = .constant([])  // 提供一个初始值
        PokerBullSettingView(args: args, suitRules: suitRules, rankRules: rankRules)
    }
}






