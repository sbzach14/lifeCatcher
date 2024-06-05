
import Foundation
import SwiftUI

struct PanguMainMenuView: View {
    
    var body: some View {
        
        ZStack{
            
            Image("Logo")
    
            VStack{
                Spacer()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        NavigationLink(
                            destination: SelectRuleView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("游戏设置")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: SettingView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("设置")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
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
        .navigationBarTitle("盘古")
        
    }
    
    
}
