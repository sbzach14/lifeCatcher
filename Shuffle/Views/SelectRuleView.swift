import SwiftUI

struct SelectRuleView: View {
    @State private var searchText = ""
    @State private var selectedRuleIndex: Int? = nil
    @State private var rules:[GameRule] = RuleManager.allUsersGameRule
    @State private var isNavigateToSelectGameView : Bool = false
    private var GameImageDic:[Int:String] = [
        0:"德州",
        1:"牛牛",
        2:"炸金花",
        3:"小九",
        4:"三公",
        5:"二八杠",
        6:"九点半",
        7:"宝子"
    ]
    
    var body: some View {
        VStack{
            VStack {
                
                List {
                    if rules.count != 0{
                        ForEach(0..<rules.count, id: \.self) { index in
                            
                            NavigationLink(
                                destination: AddRuleSettingView(gameType: rules[index].gameType, selectedSaveIndex: index)
                            ) {
                                
                                let name: String = rules[index].RuleName
                                
                                let shuffleMode = generalRuleSetting.allShuffleMode[rules[index].shuffleMode]!
                                
                                let cutMode = generalRuleSetting.allCutMode[rules[index].cutMode]!
                                
                                let reportSetting = ReportManager.allReportName[rules[index].reportSetting]!
                                
                                HStack(spacing: 20) {
                                    Text("方案\(index+1)")
                                            .foregroundColor(.white)
                                            .frame(maxWidth: 60, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 5){
                                        Text(name)
                                            .foregroundColor(.white)
                                            .frame(height: 20, alignment: .leading)
                                        Text(shuffleMode)
                                            .foregroundColor(.white)
                                            .frame(height: 20, alignment: .leading)
                                        Text(cutMode)
                                            .foregroundColor(.white)
                                            .frame(height: 20, alignment: .leading)
                                        Text(reportSetting)
                                            .foregroundColor(.white)
                                            .frame(height: 20, alignment: .leading)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                }
                            }
                            .padding()
                            .listRowBackground(Image("list_bg")
                                .resizable()
                                .scaledToFill())
                        }.onDelete { indices in
                            RuleManager.allUsersGameRule.remove(atOffsets: indices)
                            rules = RuleManager.allUsersGameRule
                            RuleManager.saveGameRule()
                        }
                    }
                }.listStyle(PlainListStyle())
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
                
                Spacer()
                
                
                HStack{
                    
                    Button(action: {
                        self.isNavigateToSelectGameView = true
                    }){
                        Image("icon_add").resizable().frame(width: 150, height: 60)
                    }.background(NavigationLink(destination: SelectGameView(),
                                                isActive: $isNavigateToSelectGameView,
                                                label: EmptyView.init).hidden()
                    )
                }
            }.padding()

        }
        .background(
            Image("bg")
                .resizable()
                .scaledToFill()
            
        ).navigationTitle("选择规则").onAppear(){
            self.rules = RuleManager.allUsersGameRule
        }
    }
}

struct SelectRuleView_Previews: PreviewProvider {
    static let testRule1 =  GameRule(RuleName: "规则001", gameType: 0, setting: 0, dealNum: 0, coloringType: 0, dealType: 0, diyDealNum: [], diyDealStatus: [], playerNum: 0, shuffleMode: 0, cutMode: 0, cardToUse: [0,1,2,3,4,5,6,7,8,9], cutNumSetting: 0, reportSetting: 0, cutNumRangeSetting: [2,10], positionSetting: 0, consecutiveReport: 0, reportNumber: 0, voiceReport: 0,args: [], suitRanks: [], rankRules: [], rankRuleChecked: [], minCardNum: 0)
    static let testRule2 = GameRule(RuleName: "规则002", gameType: 0, setting: 0, dealNum: 0, coloringType: 0, dealType: 0, diyDealNum: [], diyDealStatus: [], playerNum: 0, shuffleMode: 4, cutMode: 3, cardToUse: [0,1,2,3,4,5,6,7,8,9], cutNumSetting: 0, reportSetting: 2, cutNumRangeSetting: [2,10], positionSetting: 0, consecutiveReport: 0, reportNumber: 0, voiceReport: 0,args: [], suitRanks: [], rankRules: [], rankRuleChecked: [], minCardNum: 0)
            
    static var previews: some View {
        if RuleManager.allUsersGameRule.count == 0 {
            RuleManager.allUsersGameRule.append(testRule1)
            RuleManager.allUsersGameRule.append(testRule2)
        }
        return SelectRuleView()
    }
}


