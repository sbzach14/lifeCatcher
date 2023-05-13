import SwiftUI

struct ShowRuleView: View {
    @EnvironmentObject private var viewModel: ViewModel
    @State private var selectedPlayerNum: Int = 0
    @State private var selectedRuleIndex: Int = 0
    @State private var refreshPlayerNum: Bool = false

    var body: some View {
        VStack {
            Spacer()

            HStack {
                VStack {
                    Text("Rule Index")
                    Picker("Rule Index", selection: $selectedRuleIndex) {
                        ForEach(0..<GameManager.gameRules.count, id: \.self) { index in
                            if let rule = GameManager.gameRules[index] {
                                Text(rule.ruleName).tag(index)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedRuleIndex) { newValue in
                        updateRuleIndex(newValue)
                    }
                }
                .padding()
                
                VStack {
                    Text("Player Num")
                    Picker("Player Num", selection: $selectedPlayerNum) {
                        let ruleIndex = viewModel.ruleIndex
                        if let selectedRule = GameManager.gameRules[ruleIndex] {
                            ForEach(selectedRule.minPlayerNum...selectedRule.maxPlayerNum, id: \.self) { num in
                                Text(String(num)).tag(num)
                            }
                        }
                    }
                    .id(refreshPlayerNum) // Add id modifier to trigger update
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedPlayerNum) { newValue in
                        updatePlayerNum(newValue)
                    }
                }
                .padding()
                
                VStack {
                    Text("Winner")
                    Spacer().frame(height: 20) // 添加一个空的 Spacer 视图，并设置高度为 20
                    Text(viewModel.winnerPlayer.map { String($0 + 1) }.joined(separator: " "))
                }
                .padding()


                Spacer()
            }
        }
    }

    private func updatePlayerNum(_ playerNum: Int) {
        let ruleIndex = viewModel.ruleIndex
        if let selectedRule = GameManager.gameRules[ruleIndex] {
            viewModel.playerNum = selectedRule.minPlayerNum + playerNum
            viewModel.winnerPlayer = []
        }
    }

    private func updateRuleIndex(_ ruleIndex: Int) {
        if let selectedRule = GameManager.gameRules[ruleIndex] {
            viewModel.ruleIndex = ruleIndex
            viewModel.playerNum = selectedRule.minPlayerNum
            refreshPlayerNum.toggle() // Toggle the refreshPlayerNum to trigger update
            viewModel.winnerPlayer = []
        }
    }
}
