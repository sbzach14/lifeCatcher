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
                                destination: SettingRecordConfigView(DatasetType: rules[index].DatasetType, selectedSaveIndex: index)
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
                    }.background(NavigationLink(destination: NewSettingRecordView(),
                                                isActive: $isNavigateToSelectDatasetView,
                                                label: EmptyView.init).hidden()
                    )
                }
            }.padding()

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
}
