import CoreGraphics
import SwiftUI

struct SuitRulesView: View {
    @Binding var suitRules: [Int]

    @State private var draggedIndex: Int?
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        
        VStack{
            Divider()
            ForEach(suitRules.indices, id: \.self) { index in
                HStack {
                    Text(GameManager.suitNames[suitRules[index]]!)
                            .padding(.leading)
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
                                    suitRules.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: newIndex)
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
            newIndex = min(newIndex, suitRules.count)
        }
        else{
            newIndex = newIndex - (-offset) / 45
            newIndex = max(newIndex, 0)
        }
        
        return newIndex
    }
}

struct SuitRulesView_Previews: PreviewProvider {
    static var previews: some View {
        SuitRulesView(suitRules: .constant([3,2,1,0]))
    }
}
