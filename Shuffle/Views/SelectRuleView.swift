import SwiftUI

struct SelectRuleView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText)
                
                ScrollView {
                    VStack(spacing: 0) {
                        let ruleCnt = GameManager.gameRules.count
                        ForEach(0..<ruleCnt, id: \.self) { index in
                            NavigationLink(destination: RuleSettingView(selectedRuleIndex : index)) {
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
                .navigationBarTitle("Select Rule")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}

struct SelectRuleView_Previews: PreviewProvider {
    static var previews: some View {
        SelectRuleView()
    }
}
