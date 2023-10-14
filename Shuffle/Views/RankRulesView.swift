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
                HStack{
                    if index == 0{
                        Image("icon_list_onlydown").resizable()
                            .frame(width: 30, height: 55)
                            .alignmentGuide(.top) { d in d[.top] }
                            .foregroundColor(.white)
                            .offset(y:15)
                    } else if index == (rankRules.count - 1){
                        Image("icon_list_onlyup").resizable()
                            .frame(width: 30, height: 55)
                            .alignmentGuide(.top) { d in d[.top] }
                            .foregroundColor(.white)                         .offset(y:-15)

                    } else {
                        Image("icon_list").resizable()
                            .frame(width: 30, height: 80)
                            .alignmentGuide(.top) { d in d[.top] }
                            .foregroundColor(.white)
                    }
                    
                    if let firstWord = selectedRule.rankRules[rankRules[index].index] {
                        Text(firstWord)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                            
                    }

                    Spacer()

                    Toggle("", isOn: bindingForIndex(index))
                        .toggleStyle(CustomToggleStyle())
                        .padding(.trailing,50)
                        .frame(width: 60, height: 40)
                        
                }
                .frame(height: 50)
                .background(draggedIndex == index ? Color.gray.opacity(0.6) : Color.clear)
                .background(
                    Image("list_bg") // 背景图片
                        .resizable()
                        .scaledToFill()
                )
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
            }
            Spacer()
            
        }
        .navigationTitle("规则设置")
        .background(
            Image("bg")
                .resizable()
                .scaledToFill()
        )
        
    }

    private func calculateNewIndex(_ value: DragGesture.Value) -> Int {
        guard let draggedIndex = draggedIndex else { return 0 }
        
        // 初始化新的索引位置
        var newIndex = draggedIndex
        let offset = Int(dragOffset.height)
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
        RankRulesSate(index: 2, isChecked: true),
        RankRulesSate(index: 3, isChecked: true)
        // Add more RankRulesState items as needed
    ]
    
    static var previews: some View {
        RankRulesView(rankRules: $rankRules, selectedRuleIndex: 1)
            .onAppear {
                // You can modify rankRules here as needed for preview
                rankRules[0].isChecked = true
                rankRules[1].isChecked = true
                rankRules[2].isChecked = true
                rankRules[3].isChecked = false
            }
    }
}
