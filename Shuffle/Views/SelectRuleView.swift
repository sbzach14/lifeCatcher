import SwiftUI

struct SelectRuleView: View {
    @State private var searchText = ""
    @State private var selectedRuleIndex: Int? = nil
    
    var body: some View {
        VStack {
            SearchBar(searchText: $searchText)
            
            ScrollView {
                VStack(spacing: 0) {
                    let ruleCnt = GameManager.gameRules.count
                    ForEach(0..<ruleCnt, id: \.self) { index in
                        NavigationLink(
                            destination: destinationView(for: index)
                        ) {
                            VStack(alignment: .leading) {
                                if let rule = GameManager.gameRules[index] {
                                    Text(rule.ruleName)
                                }
                                Divider()
                            }
                            .padding()
                        }
                    }
                }
            }
        }.navigationBarTitle("Select Rules")
    }
}

private func destinationView(for index: Int) -> some View {
    switch index {
    case 0:
        return AnyView(TexasPokerRuleSettingView())
    case 2:
        return AnyView(ThreeCardPokerGameRuleSettingView())
    default:
        return AnyView(EmptyView())
    }
}

struct SelectRuleView_Previews: PreviewProvider {
    static var previews: some View {
        SelectRuleView()
    }
}


