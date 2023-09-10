import CoreGraphics
import SwiftUI

struct RankRulesView: View {
    @Binding var rankRules: [RankRulesSate]
    let selectedRuleIndex: Int

    @State private var draggedIndex: Int?
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        let selectedRule = GameManager.gameRules[selectedRuleIndex]!
        
        VStack{
            Divider()
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
                }
                .frame(width: 300, height: 30)
                .background(draggedIndex == index ? Color.gray.opacity(0.6) : Color.clear)
                .cornerRadius(10)
                .offset(draggedIndex == index ? dragOffset : .zero)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation {
                                draggedIndex = index
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                if let currentIndex = draggedIndex {
                                    let newIndex = calculateNewIndex(value)
                                    rankRules.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: newIndex)
                                }
                                draggedIndex = nil
                                dragOffset = .zero
                            }
                        }
                )

                Divider()
            }
            Spacer()
        }
        
    }

    private func calculateNewIndex(_ value: DragGesture.Value) -> Int {
        guard let draggedIndex = draggedIndex else { return 0 }
        
        // 初始化新的索引位置
        var newIndex = draggedIndex
        var offset = Int(dragOffset.height)
        if offset > 0{
            newIndex = newIndex + offset / 45 + 1
            newIndex = min(newIndex, rankRules.count)
        }
        else{
            newIndex = newIndex - (-offset) / 45
            newIndex = max(newIndex, 0)
        }
        
        return newIndex
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
    @State static var rankRules: [RankRulesSate] = [
        RankRulesSate(index: 0, isChecked: false),
        RankRulesSate(index: 1, isChecked: true),
        // Add more RankRulesState items as needed
    ]
    
    static var previews: some View {
        RankRulesView(rankRules: $rankRules, selectedRuleIndex: 1)
            .onAppear {
                // You can modify rankRules here as needed for preview
                rankRules[0].isChecked = true
                rankRules[1].isChecked = false
            }
    }
}
