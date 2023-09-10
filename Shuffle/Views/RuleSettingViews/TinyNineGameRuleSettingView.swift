
import SwiftUI

struct TinyNineGameRuleSettingView: View {
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
            let selectedRule = GameManager.gameRules[3] as! TinyNineGameRule
            
            ScrollView {
                VStack {
                    
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
                            Text("切牌").tag(0)
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
                                Text("报最大位置").tag(0)
                                Text("报最小位置").tag(1)
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
                    
                    HStack
                    {
                        Text("设置模版")
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
                    
                }
            }
    
            Spacer()

            Button(action: {
                alertMessage = TinyNineGame.legalCheck(
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
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
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
                        selectedRule.playerNum[playerNum]], rankRules : GameManager.getCheckedIndexes(rankRules: rankRules), suitRules: suitRules, allCardIndex: TinyNineGame.getAllCardIndex(), minCardNum : TinyNineGame.getMinCardNum(playerNum: selectedRule.playerNum[playerNum])),
                    isActive: $navigateToMainContent,
                    label: EmptyView.init
                )
                .hidden()
            )
        }.navigationTitle("Rule Setting")
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


struct TinyNineGameRuleSettingView_Previews: PreviewProvider {
    static var previews: some View {
        TinyNineGameRuleSettingView()
    }
}






