
import SwiftUI

struct NinePointFiveGameRuleSettingView: View {
    @Binding var args: [Int]
    @Binding var suitRules: [Int]
    @Binding var rankRules: [RankRulesSate]
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var navigateToSuitRules = false
    @State private var navigateToRankRules = false
    @State private var navigateToMainContent = false
    
    var body: some View {
        VStack
        {
            let selectedRule = GameManager.gameRules[6] as! NinePointFiveGameRule
            
            ScrollView {
                VStack {
                    
                    
                    
                }
            }
    
            Spacer()

        }.navigationTitle("九点半规则设置").background(Image("bg").resizable().scaledToFill())
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


struct NinePointFiveGameRuleSettingView_Previews: PreviewProvider {
    static var previews: some View {
        let args: Binding<[Int]> = .constant([])  // 提供一个初始值
        let suitRules: Binding<[Int]> = .constant([])  // 提供一个初始值
        let rankRules: Binding<[RankRulesSate]> = .constant([])  // 提供一个初始值
        NinePointFiveGameRuleSettingView(args: args, suitRules: suitRules, rankRules: rankRules)
    }
}






