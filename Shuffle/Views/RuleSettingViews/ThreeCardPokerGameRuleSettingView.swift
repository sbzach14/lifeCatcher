//
//import SwiftUI
//
//struct ThreeCardPokerGameRuleSettingView: View {
//    @Binding var args: [Int]
//    @Binding var suitRules: [Int]
//    @Binding var rankRules: [RankRulesSate]
//    
//    
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    
//    @State private var handNum: Int = 0
//    @State private var isCompareSuit: Int = 1
//    @State private var minRank: Int = 0
//    @State private var isAce: Int = 2
//    @State private var isAceStraight: Int = 1
//    @State private var isHeadCard: Int = 1
//    @State private var isRedJoker: Int = 0
//    @State private var redJokerSuit: Int = 0
//    @State private var redJokerRank: Int = 0
//    @State private var isBlackJoker: Int = 0
//    @State private var blackJokerSuit: Int = 0
//    @State private var blackJokerRank: Int = 0
//    @State private var isReverseHighCard: Int = 0
//    
//    @State private var navigateToSuitRules = false
//    @State private var navigateToRankRules = false
//    @State private var navigateToMainContent = false
//    
//    var body: some View {
//        VStack
//        {
//            let selectedRule = GameManager.gameRules[2] as! ThreeCardPokerGameRule
//            
//            ScrollView {
//                VStack {
//                        if(true)
//                        {
//                            HStack
//                            {Image("icon_list")
//                                  
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("手牌数量")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("handNum", selection: $args[0]) {
//                                    ForEach(0...selectedRule.handNum.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.handNum[index])).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//                            
//                            HStack {
//                                Image("icon_list")
//                                        .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("是否比较花色")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("isCompareSuit", selection: $args[1]) {
//                                    ForEach(0...selectedRule.isCompareSuit.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.isCompareSuit[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//                            
//                            
//                            HStack
//                            {
//                                Image("icon_list")
//                                  
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("散牌倒序")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("isReverseHighCard", selection: $args[12]) {
//                                    ForEach(0...selectedRule.isReverseHighCard.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.isReverseHighCard[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//                            
//                            HStack
//                            {Image("icon_list")
//                                  
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("牌堆最小数字牌")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("minRank", selection: $args[2]) {
//                                    ForEach(0...selectedRule.minRank.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.minRank[index])).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//                        }
//
//
//                        HStack
//                        {Image("icon_list")
//              
//                                .frame(width: 40, height: 40).padding(.leading, 20)
//                            Text("是否有A")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .foregroundColor(.white)// 左侧间距
//                            Picker("isAce", selection: $args[3]) {
//                                ForEach(0...selectedRule.isAce.count - 1, id: \.self) { index in
//                                    Text(String(selectedRule.isAce[index]!)).tag(index)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                        .frame(width: 160, height: 30, alignment: .trailing)
//                            .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                        }.background(
//                            Image("list_bg") // 背景图片
//                                .resizable()
//                                .scaledToFill()
//                        )
//                        .frame(height: 50)
//
//                        if(args[3] == 2)
//                        {
//
//                            HStack
//                            {Image("icon_list")
//                                  
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("是否计A顺子")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("isAceStraight", selection: $args[4]) {
//                                    ForEach(0...selectedRule.isAceStraight.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.isAceStraight[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//                        }
//
//                        HStack
//                        {Image("icon_list")
//              
//                                .frame(width: 40, height: 40).padding(.leading, 20)
//                            Text("是否有JQK")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .foregroundColor(.white) // 左侧间距
//                            Picker("isHeadCard", selection: $args[5]) {
//                                ForEach(0...selectedRule.isHeadCard.count - 1, id: \.self) { index in
//                                    Text(String(selectedRule.isHeadCard[index]!)).tag(index)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                        .frame(width: 160, height: 30, alignment: .trailing)
//                            .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                        }.background(
//                            Image("list_bg") // 背景图片
//                                .resizable()
//                                .scaledToFill()
//                        )
//                        .frame(height: 50)
//
//
//                        HStack
//                        {Image("icon_list")
//              
//                                .frame(width: 40, height: 40).padding(.leading, 20)
//                            Text("是否有大王")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .foregroundColor(.white) // 左侧间距
//                            Picker("isRedJoker", selection: $args[6]) {
//                                ForEach(0...selectedRule.isRedJoker.count - 1, id: \.self) { index in
//                                    Text(String(selectedRule.isRedJoker[index]!)).tag(index)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                        .frame(width: 160, height: 30, alignment: .trailing)
//                            .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                        }.background(
//                            Image("list_bg") // 背景图片
//                                .resizable()
//                                .scaledToFill()
//                        )
//                        .frame(height: 50)
//
//                        if(isRedJoker == 1)
//                        {
//
//                            HStack
//                            {Image("icon_list")
//                                  
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("大王可替花色")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("redJokerSuit", selection: $args[7]) {
//                                    ForEach(0...selectedRule.redJokerSuit.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.redJokerSuit[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//
//                            HStack
//                            {Image("icon_list")
//                                  
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("大王可替点数")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("redJokerRank", selection: $args[8]) {
//                                    ForEach(0...selectedRule.redJokerRank.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.redJokerRank[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//                        }
//
//
//                        HStack
//                        {Image("icon_list")
//
//                                .frame(width: 40, height: 40).padding(.leading, 20)
//                            Text("是否有小王")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .foregroundColor(.white)// 左侧间距
//                            Picker("isBlackJoker", selection: $args[9]) {
//                                ForEach(0...selectedRule.isBlackJoker.count - 1, id: \.self) { index in
//                                    Text(String(selectedRule.isBlackJoker[index]!)).tag(index)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                        .frame(width: 160, height: 30, alignment: .trailing)
//                            .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                        }.background(
//                            Image("list_bg") // 背景图片
//                                .resizable()
//                                .scaledToFill()
//                        )
//                        .frame(height: 50)
//
//                        if(args[9] == 1)
//                        {
//                            HStack
//                            {Image("icon_list")
//                                  
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("小王可替花色")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("blackJokerSuit", selection: $args[10]) {
//                                    ForEach(0...selectedRule.blackJokerSuit.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.blackJokerSuit[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//
//                            HStack
//                            {Image("icon_list")
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("小王可替点数")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//                                Picker("blackJokerRank", selection: $args[11]) {
//                                    ForEach(0...selectedRule.blackJokerRank.count - 1, id: \.self) { index in
//                                        Text(String(selectedRule.blackJokerRank[index]!)).tag(index)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                .padding(.trailing, 30).accentColor(.white) // 右侧间距
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//                            
//                        }
//                        
//
//                        HStack{Image("icon_ranksetting")
//                                .resizable()
//                                .frame(width: 40, height: 40).padding(.leading, 20)
//                            Text("自定义牌型顺序")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .foregroundColor(.white) // 左侧间距
//
//                            Button(action: {
//                                navigateToRankRules = true
//                            }) {
//                                Image("icon_next")
//                                    .resizable()
//                                    .frame(width: 30, height: 30) // 设置正方形大小
//                            }
//                            .padding(.trailing, 40)
//                            .background(
//                                NavigationLink(
//                                    destination: RankRulesView(rankRules: $rankRules, selectedRuleIndex: selectedRule.ruleIndex),
//                                    isActive: $navigateToRankRules,
//                                    label: EmptyView.init
//                                )
//                                .hidden()
//                            )
//                        }.background(
//                            Image("list_bg") // 背景图片
//                                .resizable()
//                                .scaledToFill()
//                        )
//                        .frame(height: 50)
//
//                        if(isCompareSuit == 1)
//                        {
//                            HStack
//                            {Image("icon_suitsetting")
//                                    .resizable()
//                                    .frame(width: 40, height: 40).padding(.leading, 20)
//                                Text("自定义花色顺序")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.white) // 左侧间距
//
//                                Button(action: {
//                                    navigateToSuitRules = true
//                                }) {
//                                    Image("icon_next")
//                                        .resizable()
//                                        .frame(width: 30, height: 30) // 设置正方形大小
//                                }
//                                .padding(.trailing, 40)
//                                .background(
//                                    NavigationLink(
//                                        destination: SuitRulesView(suitRules: $suitRules),
//                                        isActive: $navigateToSuitRules,
//                                        label: EmptyView.init
//                                    )
//                                    .hidden()
//                                )
//                            }.background(
//                                Image("list_bg") // 背景图片
//                                    .resizable()
//                                    .scaledToFill()
//                            )
//                            .frame(height: 50)
//                        }
//                    
//                }
//            }
//    
//            Spacer()
//
//        }.navigationTitle("规则设置").background(Image("bg").resizable().scaledToFill())
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
//        
//    }
//}
//
//
//struct ThreeCardPokerGameRuleSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        let args: Binding<[Int]> = .constant([])  // 提供一个初始值
//        let suitRules: Binding<[Int]> = .constant([])  // 提供一个初始值
//        let rankRules: Binding<[RankRulesSate]> = .constant([])  // 提供一个初始值
//        ThreeCardPokerGameRuleSettingView(args: args, suitRules: suitRules, rankRules: rankRules)
//    }
//}
//
//
//
//
//
//
