import Foundation
import SwiftUI

struct SettingRecordView: View {
    
    var configType : Int
    
    @State private var selectedRuleIndex: Int? = nil
    @State private var rules:[DatasetRule] = DetectSettingArgs.allUsersDatasetRule
    @State private var isNavigateToSelectDatasetView : Bool = false
    
    var body: some View {
        VStack{
            VStack {
                
                List {
                    if rules.count != 0{
                        ForEach(0..<rules.count, id: \.self) { index in
                            
                            if configType == 0{
                                NavigationLink(
                                    destination: SettingRecordConfigView(selectedSaveIndex: index)
                                ) {
                                    
                                    let name: String = rules[index].RuleName
                                    
                                    VStack(spacing: 5) {
                                        HStack{
                                            Text("方案\(index+1)")
                                                .foregroundColor(.white)
                                                .frame(width: 80, alignment: .leading)
                                                .font(.system(size: 20, weight: .bold))
                                            
                                            Text(name)
                                                .foregroundColor(.white)
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
                            }
                            else{
                                NavigationLink(
                                    destination: SettingRecordConfigView_leishen(selectedSaveIndex: index)
                                ) {
                                    
                                    let name: String = rules[index].RuleName
                                    
                                    VStack(spacing: 5) {
                                        HStack{
                                            Text("方案\(index+1)")
                                                .foregroundColor(.white)
                                                .frame(width: 80, alignment: .leading)
                                                .font(.system(size: 20, weight: .bold))
                                            
                                            Text(name)
                                                .foregroundColor(.white)
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
                            }
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
                    if configType == 0{
                        Button(action: {
                            self.isNavigateToSelectDatasetView = true
                        }){
                            Image("icon_add").resizable().frame(width: 150, height: 60)
                        }.background(NavigationLink(destination:SettingRecordConfigView(selectedSaveIndex: -1),
                                                    isActive: $isNavigateToSelectDatasetView,
                                                    label: EmptyView.init).hidden()
                        )
                    }
                    else{
                        Button(action: {
                            self.isNavigateToSelectDatasetView = true
                        }){
                            Image("icon_add").resizable().frame(width: 150, height: 60)
                        }.background(NavigationLink(destination:SettingRecordConfigView_leishen(selectedSaveIndex: -1),
                                                    isActive: $isNavigateToSelectDatasetView,
                                                    label: EmptyView.init).hidden()
                        )
                    }
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
        let reportSetting0 = ReportManager.allReportName[rules[index].reportSetting[0]]!
        
        if rules[index].shuffleMode[0] != 0{
            settingWord += shuffleMode0 + "  "
            if rules[index].cutMode[0] != 0{
                settingWord += cutMode0 + "  "
            }
            settingWord += "\n" + reportSetting0
        }
        
        
        let shuffleMode1 = generalRuleSetting.allRiffleMode[rules[index].shuffleMode[1]]!
        let cutMode1 = generalRuleSetting.allCutMode[rules[index].cutMode[1]]!
        let reportSetting1 = ReportManager.allReportName[rules[index].reportSetting[1]]!
        
        if rules[index].shuffleMode[1] != 0{
            if settingWord != "\n"{
                settingWord += "\n\n"
            }
            settingWord += shuffleMode1 + "  "
            if rules[index].cutMode[1] != 0{
                settingWord += cutMode1 + "  "
            }
            settingWord += "\n" + reportSetting1
        }
        
        return settingWord
    }
}
