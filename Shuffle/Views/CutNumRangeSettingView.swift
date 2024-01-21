//
//  CutNumRangeSettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 12/12/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct CutNumRangeSettingView: View {
    @Binding var cutNumRangeSetting:[Int]
    var body: some View {
        VStack{
            HStack{
                Text("    最小位置   ").foregroundColor(.white)
                TextField("X = ", value: $cutNumRangeSetting[0], format: .number).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
            }
            HStack{
                Text("    最大位置   ").foregroundColor(.white)

                TextField("Y = ", value: $cutNumRangeSetting[1], format: .number).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
            }
            
            
            Spacer()
        }.background(Image("bg").resizable().scaledToFill()).navigationTitle("打色范围设置")
    }
}

struct CutNumRangeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        let cutNumRangeSetting: Binding<[Int]> = .constant([2,10])
        CutNumRangeSettingView(cutNumRangeSetting: cutNumRangeSetting)
    }
}
