import SwiftUI

struct SelectRuleView: View {
    @State private var searchText = ""
    @State private var selectedRuleIndex: Int? = nil
    private var GameImageDic:[Int:String] = [
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
        VStack {
            SearchBar(searchText: $searchText)
            
            ScrollView {
                VStack(spacing: 0) {
                    let ruleCnt = GameManager.gameRules.count
                    ForEach(0..<ruleCnt, id: \.self) { index in
                        NavigationLink(
                            destination: destinationView(for: index)
                        ) {
                            VStack(alignment: .center,spacing: 30) {
                                if let rule = GameManager.gameRules[index] {
                                    Text("                                 ")
                                        .foregroundColor(.none)
                                }
                                Divider()
                                    .colorInvert()
                            }.background(Image(GameImageDic[index]!).resizable().scaledToFill())
                            .padding()
                        }
                    }
                }
            }
        }
        .background(
            Image("bg")
                .resizable()
                .scaledToFill()
        )
        .navigationBarTitle("玩法选择")
    }
}

private func destinationView(for index: Int) -> some View {
    switch index {
    case 0:
        return AnyView(TexasPokerRuleSettingView())
    case 1:
        return AnyView(PokerBullSettingView())
    case 2:
        return AnyView(ThreeCardPokerGameRuleSettingView())
    case 3:
        return AnyView(TinyNineGameRuleSettingView())
    case 4:
        return AnyView(ThreeMenGameRuleSettingView())
    case 5:
        return AnyView(TwoEightGangGameRuleSettingView())
    case 6:
        return AnyView(NinePointFiveGameRuleSettingView())
    case 7:
        return AnyView(BaoziGameRuleSettingView())
    default:
        return AnyView(EmptyView())
    }
}

struct SelectRuleView_Previews: PreviewProvider {
    static var previews: some View {
        SelectRuleView()
    }
}


