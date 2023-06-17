import CoreGraphics
import SwiftUI

struct SuitRulesView: View {
    @Binding var suitRules: [Int]
    
    
    var body: some View {
        
        ScrollView {
            Divider()
            VStack {
                ForEach(suitRules.indices, id: \.self) { index in
                    HStack {
                        Text(GameManager.suitNames[suitRules[index]]!)
                                .padding(.leading)
                        
                        Spacer()
                        
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
        suitRules.swapAt(index, index - 1)
    }
    
    private func moveItemDown(_ index: Int) {
        guard index < suitRules.count - 1 else { return }
        suitRules.swapAt(index, index + 1)
    }
}

struct SuitRulesView_Previews: PreviewProvider {
    static var previews: some View {
        SuitRulesView(suitRules: .constant([3,2,1,0]))
    }
}
