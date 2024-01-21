//
//  SelectGameView.swift
//  Shuffle
//
//  Created by Apple on 2024/1/22.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI

struct SelectGameView: View {
    var body: some View {
        
        ScrollView{
            Spacer()
            
            VStack{
                
                ForEach(Array(GameManager.gameRules.keys).sorted(), id: \.self) { key in
                    if let value = GameManager.gameRules[key] {
                        NavigationLink(
                            destination: AddRuleSettingView(gameType: key, selectedSaveIndex: -1)
                        ){
                            Image(value.ruleName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 70)
                        }
                    }
                }
            }.padding()
        }
        .background(Image("bg").resizable().scaledToFill())
            .navigationTitle("选择游戏")
    }
}

struct SelectGameView_Previews: PreviewProvider {
    static var previews: some View {
        return SelectGameView()
    }
}
