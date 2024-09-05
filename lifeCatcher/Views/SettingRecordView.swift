import Foundation
import SwiftUI

struct SettingRecordView: View {

    @State private var selectedRuleIndex: Int? = nil
    @State private var rules:[DatasetRule] = DetectSettingArgs.allUsersDatasetRule
    @State private var isNavigateToSelectDatasetView : Bool = false
    private var DatasetImageDic:[Int:String] = [
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
                                destination: SettingRecordConfigView(selectedSaveIndex: index)
                            ) {
                                
                                let name: String = rules[index].RuleName
                                
                                
                                
                                
                                VStack(spacing: 5) {
                                    HStack{
                                        Text("方案\(index+1)")
                                            .foregroundColor(.black)
                                            .frame(width: 80, alignment: .leading)
                                            .font(.system(size: 20, weight: .bold))
                                
                                        Text(name)
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.system(size: 20, weight: .bold))
                                        
                                        Spacer()
                                    }
                                    
                                    Text(generateSettingWord(index: index))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            .listRowBackground(Image("list_bg")
                                .resizable()
                                .scaledToFill())
                        }.onDelete { indices in
                            DetectSettingArgs.allUsersDatasetRule.remove(atOffsets: indices)
                            rules = DetectSettingArgs.allUsersDatasetRule
                            DetectSettingArgs.saveDatasetRule()
                        }
                    }
                }.listStyle(PlainListStyle())
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
                
                Spacer()
                
                
                HStack{
                    
                    Button(action: {
                        self.isNavigateToSelectDatasetView = true
                    }){
                        Image("icon_add").resizable().frame(width: 150, height: 60)
                    }.background(NavigationLink(destination:SettingRecordConfigView(selectedSaveIndex: -1),
                                                isActive: $isNavigateToSelectDatasetView,
                                                label: EmptyView.init).hidden()
                    )
                }.frame(height: 60, alignment: .bottom)
            }

        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
        ).navigationTitle("历史记录").onAppear(){
            self.rules = DetectSettingArgs.allUsersDatasetRule
        }
    }
    
    private func generateSettingWord(index: Int) -> String{
        var settingWord = "\n"
        
        let shuffleMode0 = generalRuleSetting.allShuffleMode[rules[index].shuffleMode[0]]!
        let cutMode0 = generalRuleSetting.allCutMode[rules[index].cutMode[0]]!
        let special0 = generalRuleSetting.allSpecialCard[rules[index].specialCard[0]]!
        let reportSetting0 = ReportManager.allReportName[rules[index].reportSetting[0]]!
        
        if rules[index].shuffleMode[0] != 0{
            settingWord += shuffleMode0 + "  "
            if rules[index].cutMode[0] != 0{
                settingWord += cutMode0 + "  "
            }
            if rules[index].specialCard[0] != 0{
                settingWord += special0 + "  "
            }
            settingWord += "\n" + reportSetting0
        }
        
        
        let shuffleMode1 = generalRuleSetting.allRiffleMode[rules[index].shuffleMode[1]]!
        let cutMode1 = generalRuleSetting.allCutMode[rules[index].cutMode[1]]!
        let special1 = generalRuleSetting.allSpecialCard[rules[index].specialCard[1]]!
        let reportSetting1 = ReportManager.allReportName[rules[index].reportSetting[1]]!
        
        if rules[index].shuffleMode[1] != 0{
            settingWord += "\n\n" + shuffleMode1 + "  "
            if rules[index].cutMode[1] != 0{
                settingWord += cutMode1 + "  "
            }
            if rules[index].specialCard[1] != 0{
                settingWord += special1 + "  "
            }
            settingWord += "\n" + reportSetting1
        }
        
        return settingWord
    }
}
