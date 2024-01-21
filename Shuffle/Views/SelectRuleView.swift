import SwiftUI

struct SelectRuleView: View {
    @State private var searchText = ""
    @State private var selectedRuleIndex: Int? = nil
    @State private var rules:[GameRule] = RuleManager.allUsersGameRule

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
            VStack {
                HStack{
                    SearchBar(searchText: $searchText)
                    NavigationLink(destination: AddRuleSettingView(selectedSaveIndex: -1)) {
                    Text("添加").foregroundColor(.white).frame(alignment: .trailing)
                    }
                }
                List {
                    if rules.count != 0{
                        ForEach(0..<rules.count, id: \.self) { index in
                            
                            NavigationLink(
                                destination: AddRuleSettingView(selectedSaveIndex: index)
                            ) {
                                // Your existing content here
                        let name: String = rules[index].RuleName

                                let calmode: String = generalRuleSetting.allCuttingSetting[rules[index].calMode]!
//                                var reportSetting: String
//                                if rules[index].calMode == 0{
//                                    reportSetting = generalRuleSetting.allReportSettingWithoutCutting[rules[index].reportSetting]!
//                                } else {
//                                    reportSetting = generalRuleSetting.allReportSettingWithCutting[rules[index].reportSetting]!
//                                }
                               
                                
                                let dealType: String = generalRuleSetting.allDealType[rules[index].dealType]!

                                HStack(spacing: 5) {
                                    Text(name)
                                        .foregroundColor(.black)
                                    Divider()
                                        .colorInvert()
                                    Spacer()
                                    Text(calmode)
                                        .foregroundColor(.black)
                                    if rules[index].calMode == 0 {
                                            Text(generalRuleSetting.allReportSettingWithoutCutting[rules[index].reportSetting]!)
                                                       .foregroundColor(.black)
                                               } else {
                                                Text(generalRuleSetting.allReportSettingWithCutting[rules[index].reportSetting]!)
                                                       .foregroundColor(.black)
                                               }
//                                    Text(reportSetting)
//                                        .foregroundColor(.black)
                                    Text(dealType)
                                        .foregroundColor(.black)
                                }
                                .padding()
                            }
                        }.onDelete { indices in
                            RuleManager.allUsersGameRule.remove(atOffsets: indices)
                            rules = RuleManager.allUsersGameRule
                            RuleManager.saveGameRule()
                        }.background(Image("list_bg") // 背景图片
                            .resizable()
                            .scaledToFill())
                    }
                }.listStyle(GroupedListStyle()).background(Color.blue).accentColor(Color.blue)

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
    static let testRule1 =  GameRule(RuleName: "规则001", gameType: 0, setting: 0, calMode: 2, dealType: 0, diyDealType: 0, diyDealNum: [], diyDealStatus: [], playerNum: 0, shuffleMode: 0, cardToUse: [0,1,2,3,4,5,6,7,8,9], cutNumSetting: 0, reportSetting: 0, cutNumRangeSetting: [2,10], positionSetting: 0, consecutiveReport: 0, cutSetting: 0, reportNumber: 0, voiceReport: 0,args: [], suitRanks: [], rankRules: [], rankRuleChecked: [])
    static let testRule2 = GameRule(RuleName: "规则002", gameType: 0, setting: 0, calMode: 1, dealType: 0, diyDealType: 0, diyDealNum: [], diyDealStatus: [], playerNum: 0, shuffleMode: 0, cardToUse: [0,1,2,3,4,5,6,7,8,9], cutNumSetting: 0, reportSetting: 2, cutNumRangeSetting: [2,10], positionSetting: 0, consecutiveReport: 0, cutSetting: 0, reportNumber: 0, voiceReport: 0,args: [], suitRanks: [], rankRules: [], rankRuleChecked: [])
            
    static var previews: some View {
        if RuleManager.allUsersGameRule.count == 0 {
            RuleManager.allUsersGameRule.append(testRule1)
            RuleManager.allUsersGameRule.append(testRule2)
        }
        return SelectRuleView()
    }
}


