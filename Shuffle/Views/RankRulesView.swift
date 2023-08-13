import CoreGraphics
import SwiftUI

struct RankRulesView: View {
    @Binding var rankRules: [RankRulesSate]
    let selectedRuleIndex: Int
    
    var body: some View {
        let selectedRule = GameManager.gameRules[selectedRuleIndex]!
        
        ScrollView {
            Divider()
            VStack {
                ForEach(rankRules.indices, id: \.self) { index in
                    HStack {
                        if let firstWord = selectedRule.rankRules[rankRules[index].index] {
                            Text(firstWord)
                                .padding(.leading)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: bindingForIndex(index))
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .padding(.trailing)
                            .frame(width: 80, height: 20)
                        
                        Button(action: {
                            moveItemUp(index)
                        }) {
                            Image(systemName: "arrow.up")
                                .font(.title)
                                .padding(.trailing)
                        }
                        .frame(width: 20, height: 20)
                        
                        Button(action: {
                            moveItemDown(index)
                        }) {
                            Image(systemName: "arrow.down")
                                .font(.title)
                                .padding(.trailing)
                        }
                        .frame(width: 20, height: 20)
                    }
                    .frame(width: 300, height: 30)
                    
                    Divider()
                }
            }
        }
        .frame(width: 300, height: 600)
        .cornerRadius(10)
        .border(Color.black, width: 2)
    }

    private func moveItemUp(_ index: Int) {
        guard index > 0 else { return }
        rankRules.swapAt(index, index - 1)
    }
    
    private func moveItemDown(_ index: Int) {
        guard index < rankRules.count - 1 else { return }
        rankRules.swapAt(index, index + 1)
    }
    
    private func bindingForIndex(_ index: Int) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                rankRules[index].isChecked
            },
            set: { newValue in
                rankRules[index].isChecked = newValue
            }
        )
    }
}

struct RankRulesView_Previews: PreviewProvider {
    static var previews: some View {
        RankRulesView(rankRules: .constant([
            RankRulesSate(index: 0, isChecked: false),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true),
            RankRulesSate(index: 1, isChecked: true)]), selectedRuleIndex: 0)
    }
}
