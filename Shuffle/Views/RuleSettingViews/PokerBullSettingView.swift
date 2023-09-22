//
//  RuleSettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 5/27/23.
//  Copyright © 2023 Apple. All rights reserved.
//
import SwiftUI

struct PokerBullSettingView: View {
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var shuffleMode: Int = 0
    @State private var calMode: Int = 0
    
    @State private var target: Int = 0
    @State private var targetPos: Int = 1
    
    
    @State private var setting : Int = 0
    @State private var playerNum: Int = 0
    @State private var handNum: Int = 2
    @State private var wayToDeal: Int = 0
    @State private var cardsNum: Int = 5
    @State private var isCompareSuit: Int = 1
    @State private var fiveLittleRank: Int = 0
    @State private var secondRankRule: Int = 0
    @State private var jokerIsMinZero: Int = 0
    @State private var BullRules: [Int] = [0]
    @State private var selectedIndices: Set<Int> = []
    @State private var bullrulelist: [Int] = []
    @State private var tenValueRange: Int = 0
    @State private var JValueRange:Int = 0
    @State private var QValueRange:Int = 0
    @State private var KValueRange:Int = 0
    @State private var blackJokerValueRange: Int = 0
    @State private var redJokerValueRange: Int = 0
    @State private var threeValueRange: Int = 0
    @State private var sixValueRange: Int = 0
    @State private var spadeAValueRange: Int = 0

    @State private var suitRules: [Int] = [3,2,1,0]
    @State private var threeCardsRankRules: [RankRulesSate] = [
        RankRulesSate(index: 5, isChecked: true),
        RankRulesSate(index: 4, isChecked: true),
        RankRulesSate(index: 3, isChecked: true),
        RankRulesSate(index: 2, isChecked: true),
        RankRulesSate(index: 1, isChecked: true),
        RankRulesSate(index: 0, isChecked: true)
    ]

    @State private var rankRules: [RankRulesSate] = [
        RankRulesSate(index: 41, isChecked: true),
        RankRulesSate(index: 39, isChecked: true),
        RankRulesSate(index: 38, isChecked: true),
        RankRulesSate(index: 2, isChecked: true),
        RankRulesSate(index: 1, isChecked: true),
        RankRulesSate(index: 0, isChecked: true)]
    @State private var args: [Int] = []

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
                    HStack
                    {
                        Text("洗牌模式")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 60) // 左侧间距
                        Picker("shuffleMode", selection: $shuffleMode) {
                            Text("洗牌").tag(0)
                            Text("拨到顶").tag(1)
                            Text("拨中间").tag(2)

                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 60) // 右侧间距
                    }
                    
                    HStack
                    {
                        Text("打色模式")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 60) // 左侧间距
                        Picker("calMode", selection: $calMode) {
                            Text("不打色").tag(0)
                            Text("去色").tag(1)
                            Text("留色").tag(2)

                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 60) // 右侧间距
                    }
                    
                    if calMode == 0{
                        HStack
                        {
                            Text("报牌模式")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            Picker("target", selection: $target) {
                                Text("报最大家位置").tag(0)
                                Text("报最小家位置").tag(1)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60) // 右侧间距
                        }
                    }

                    else{
                        HStack
                        {
                            Text("报牌模式")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            Picker("target", selection: $target) {
                                Text("报切几张目标位置最大").tag(0)
                                Text("报切几张目标位置最小").tag(1)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60) // 右侧间距
                        }

                        HStack
                        {
                            Text("目标位置")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            Picker("targetPos", selection: $targetPos) {
                                ForEach(1...selectedRule.playerNum[playerNum], id: \.self) { index in
                                    Text(String(index)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60) // 右侧间距
                        }
                    }
                    HStack{
                        Text("设置规则")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 60) // 左侧间距
                        Picker("setting", selection: $setting) {
                            ForEach(0...selectedRule.setting.count - 1, id: \.self) {
                                index in
                                Text(selectedRule.setting[index]!).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 60) // 右侧间距
                        .onChange(of: setting) { _ in
                            handleSettingChange()
                        }
                    }
                    
                    HStack
                    {
                        Text("玩家数量")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 60) // 左侧间距
                        Picker("playerNum", selection: $playerNum) {
                            ForEach(0...selectedRule.playerNum.count - 1, id: \.self) { index in
                                Text(String(selectedRule.playerNum[index])).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 60) // 右侧间距
                    }
                    if(setting == 3){
                        HStack{
                            Text("牌库数量")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            Picker("cardsNum", selection: $cardsNum) {
                                ForEach(0...selectedRule.cardsNum.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.cardsNum[index])).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60)
                        }
                        
                        HStack{
                            Text("手牌数量")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            Picker("handNum", selection: $handNum) {
                                ForEach(0...selectedRule.handNum.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.handNum[index])).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60) // 右侧间距
                        }
                        
                        HStack{
                            Text("发牌方式")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            Picker("wayToDeal", selection: $wayToDeal) {
                                ForEach(0...selectedRule.wayToDeal.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.wayToDeal[index]!)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60) // 右侧间距
                        }
                        
                        HStack{
                            Text("是否比较花色")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            Picker("isCompareSuit", selection: $isCompareSuit) {
                                ForEach(0...selectedRule.isCompareSuit.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.isCompareSuit[index]!)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60) // 右侧间距
                        }
                        HStack{
                            Text("同牛同点比较规则")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            Picker("secondRankRule", selection: $secondRankRule) {
                                ForEach(0...selectedRule.secondRankRule.count - 1, id: \.self) { index in
                                    Text(String(selectedRule.secondRankRule[index]!)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60) // 右侧间距
                        }
                        Group{
                        if(cardsNum == 6 || cardsNum == 1 || cardsNum == 4){
                            HStack{
                                Text("大王的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("redJokerValueRange", selection: $redJokerValueRange) {
                                    ForEach(0...selectedRule.redJokerValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.redJokerValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                            HStack{
                                Text("小王的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("blackJokerValueRange", selection: $blackJokerValueRange) {
                                    ForEach(0...selectedRule.blackJokerValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.blackJokerValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                            if(blackJokerValueRange == 0 && redJokerValueRange == 0){
                                
                                HStack{
                                    Text("王是否是最小的0")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 60) // 左侧间距
                                    Picker("jokerIsMinZero", selection: $jokerIsMinZero) {
                                        ForEach(0...selectedRule.jokerIsMinZero.count - 1, id: \.self) { index in
                                            Text(String(selectedRule.jokerIsMinZero[index]!)).tag(index)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 60) // 右侧间距
                                }
                            }
                        }//card == 6 54张牌, 32张牌，42张牌, 含有大小王
                        if(cardsNum != 2){
                            HStack{
                                Text("10的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("tenValueRange", selection: $tenValueRange) {
                                    ForEach(0...selectedRule.tenValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.tenValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                        }//card != 2, 有10
                        
                        if (cardsNum == 0 || cardsNum == 1 || cardsNum == 5 || cardsNum == 6){
                            HStack{
                                Text("J的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("JValueRange", selection: $JValueRange) {
                                    ForEach(0...selectedRule.JValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.JValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                            
                            HStack{
                                Text("Q的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("QValueRange", selection: $QValueRange) {
                                    ForEach(0...selectedRule.QValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.QValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                            
                            HStack{
                                Text("K的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("KValueRange", selection: $KValueRange) {
                                    ForEach(0...selectedRule.KValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.KValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                            HStack{
                                Text("Q的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("QValueRange", selection: $QValueRange) {
                                    ForEach(0...selectedRule.QValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.QValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                        }//包含J,Q,K
                        // 3, 6, SpadeAValue
                            HStack{
                                Text("♠️A的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("spadeAValueRange", selection: $spadeAValueRange) {
                                    ForEach(0...selectedRule.spadeAValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.spadeAValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                            HStack{
                                Text("3的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("threeValueRange", selection: $threeValueRange) {
                                    ForEach(0...selectedRule.threeValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.threeValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                            
                            HStack{
                                Text("6的点数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 60) // 左侧间距
                                Picker("sixValueRange", selection: $sixValueRange) {
                                    ForEach(0...selectedRule.sixValueRange.count - 1, id: \.self) { index in
                                        Text(String(selectedRule.sixValueRange[index]!)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 60) // 右侧间距
                            }
                        }

                        if (handNum == 2){
                            HStack{
                                Text("可以组成牛的牌型:").font(.headline).padding(.leading,60).padding(.top).frame(maxWidth: .infinity, alignment: .leading)
                            }
                            ForEach(0..<selectedRule.BullRules.count-1, id: \.self) { index in
                                HStack {
                                    Toggle(isOn: Binding(
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
                                    )) {
                                        Text(selectedRule.BullRules[index]!).padding(.leading, 60)
                                    }
                                }
                            }
                        }
                        
                        HStack{
                            Text("自定义牌型顺序")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 60) // 左侧间距
                            
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
                            .padding(.trailing, 60)
                            .background(
                                NavigationLink(
                                    destination: RankRulesView(rankRules: $rankRules, selectedRuleIndex: selectedRule.ruleIndex),
                                    isActive: $navigateToRankRules,
                                    label: EmptyView.init
                                )
                                .hidden()
                            )
                        }
                    }//setting = 3,自定义
                }//VStack
            }//ScrollView
            
            Spacer()
            
            Button(action: {
                alertMessage = PokerBull.legalCheck(
                    playerNum: selectedRule.playerNum[playerNum], handNum: selectedRule.handNum[handNum],cardNum: selectedRule.cardsNum[cardsNum]
                )
                
                if(alertMessage != "")
                {
                    showAlertWithMessage()
                }
                else {
                    //organize the args
                    args = [
                        selectedRule.playerNum[playerNum], selectedRule.cardsNum[cardsNum],
                        selectedRule.handNum[handNum],
                        wayToDeal,
                        isCompareSuit,
                        fiveLittleRank,
                        secondRankRule,
                        jokerIsMinZero,
                        tenValueRange,
                        JValueRange,
                        QValueRange,
                        KValueRange,
                        threeValueRange,
                        sixValueRange,
                        spadeAValueRange] + bullrulelist + [0]
                    navigateToMainContent = true
                }
                
                
                
            }) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }.padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("参数错误"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }.background(
                    NavigationLink(
                        destination: MainContentView(shuffleMode: shuffleMode,calModeArgs:[calMode, target, targetPos], ruleIndex: selectedRule.ruleIndex, args : args, rankRules : GameManager.getCheckedIndexes(rankRules: rankRules), suitRules: suitRules, allCardIndex: PokerBull.GetAllCardIndex(), minCardNum: PokerBull.GetMinCardNum(playerNum: playerNum, handNum: handNum)),
                        isActive: $navigateToMainContent,
                        label: EmptyView.init
                    )
                    .hidden()
                )
        }
    }

    private func showAlertWithMessage() {
        showAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showAlert = false
        }
    }

    private func handleSettingChange() {
        //标准五张牛牛
        if(setting == 0)
        {
            isCompareSuit = 1
            suitRules = [3,2,1,0]
            wayToDeal = 0
            fiveLittleRank = 0
            secondRankRule = 0
            jokerIsMinZero = 0
            tenValueRange = 0
            JValueRange = 0
            QValueRange = 0
            KValueRange = 0
            threeValueRange = 0
            sixValueRange = 0
            spadeAValueRange = 0
            bullrulelist = [0]
            rankRules = [
                RankRulesSate(index: 41, isChecked: true),
                RankRulesSate(index: 1, isChecked: true),
                RankRulesSate(index: 11, isChecked: true),
                RankRulesSate(index: 12, isChecked: true),
                RankRulesSate(index: 9, isChecked: true),
                RankRulesSate(index: 10, isChecked: true),
                RankRulesSate(index: 42, isChecked: true),
            ]
        }
        //标准四张牛牛
        if(setting == 1){
            
        }
        //标准三张牛牛
        if(setting == 2){
            
        }
    }
}


struct PokerBullSettingView_Previews: PreviewProvider {
    static var previews: some View {
        PokerBullSettingView()
    }
}






