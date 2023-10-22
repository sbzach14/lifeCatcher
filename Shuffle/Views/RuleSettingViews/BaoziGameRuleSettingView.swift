
import SwiftUI

struct BaoziGameRuleSettingView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var shuffleMode: Int = 0
    @State private var calMode: Int = 0
    
    @State private var targetPos: Int = 1
    @State private var target: Int = 0//0max 1min
    
    @State private var setting : Int = 0
    
    @State private var playerNum: Int = 0
    
    @State private var suitRules: [Int] = [3,2,1,0]
    @State private var rankRules: [RankRulesSate] = [
        
    ]
    
    @State private var navigateToSuitRules = false
    @State private var navigateToRankRules = false
    @State private var navigateToMainContent = false
    
    var body: some View {
        VStack
        {
            let selectedRule = GameManager.gameRules[7] as! BaoziGameRule
            
            ScrollView {
                VStack {
                    
                    HStack
                    {Image("icon_shufflemode")
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
                    }.background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                    HStack
                    {Image("icon_cutmode")
                            .resizable()
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("打色模式")
                            .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                        Picker("calMode", selection: $calMode) {
                            Text("切牌").tag(0)
                            Text("去色").tag(1)
                            Text("留色").tag(2)
                            
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
                    
                    
                    if calMode == 0{
                        HStack
                        {Image("icon_voice")
                                .resizable()
                                .frame(width: 40, height: 40).padding(.leading, 20)
                            Text("报牌模式")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white) // 左侧间距
                            Picker("target", selection: $target) {
                                Text("报最大位置").tag(0)
                                Text("报最小位置").tag(1)
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
                    
                    else{
                        HStack
                        {Image("icon_voice")
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
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                        
                        HStack
                        {Image("icon_voice")
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
                                .accentColor(.white)
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 50)
                    }
                    
                    
                    
                    HStack
                    {Image("icon_user")
                            .resizable()
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("玩家数量")
                            .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
                        Picker("playerNum", selection: $playerNum) {
                            ForEach(0...selectedRule.playerNum.count - 1, id: \.self) { index in
                                Text(String(selectedRule.playerNum[index])).tag(index)
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
                    
                    HStack
                    {Image("icon_setting")
                            .resizable()
                            .frame(width: 40, height: 40).padding(.leading, 20)
                        Text("设置模版")
                            .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white) // 左侧间距
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
                    }.background(
                        Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(height: 50)
                    
                }
            }
    
            Spacer()

            Button(action: {
                alertMessage = BaoziGame.legalCheck(
                    playerNum: selectedRule.playerNum[playerNum]
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
                        selectedRule.playerNum[playerNum]], rankRules : GameManager.getCheckedIndexes(rankRules: rankRules), suitRules: suitRules, allCardIndex: BaoziGame.getAllCardIndex(), minCardNum : BaoziGame.getMinCardNum(playerNum: selectedRule.playerNum[playerNum])),
                    isActive: $navigateToMainContent,
                    label: EmptyView.init
                )
                .hidden()
            )
        }.navigationTitle("规则设置").background(Image("bg").resizable().scaledToFill())
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


struct BaoziGameRuleSettingView_Previews: PreviewProvider {
    static var previews: some View {
        BaoziGameRuleSettingView()
    }
}






