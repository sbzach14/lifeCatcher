//
//  InfoView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 8/10/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    @State private var searchText = ""
    
    var activeDate: String
    
    var body: some View {
        VStack{
            SearchBar(searchText: $searchText)
            ScrollView {
                VStack(alignment: .leading, spacing: 0)  {
                    Text("版本:   1.0").padding()
                        .foregroundColor(.white)
                    
                    Divider()
                        .foregroundColor(.white)
                    
                    Text("序列号:  " + AuthManager.getUniqueID()!).padding()
                        .foregroundColor(.white)
                    
                    Divider()
                        .foregroundColor(.white)
                    
                    Text("激活日期: " + activeDate).padding()
                        .foregroundColor(.white)
                    
                    Divider()
                        .foregroundColor(.white)
                    
                    Text("声明:   本软件的使用范围仅限于日常生活图像识别与记录用途，使用本程序造成的任何后果及责任由使用者承担，本公司不承担因用户或代理商在非允许使用范围内使用或销售而导致的任何后果及相关责任。").padding()
                        .foregroundColor(.white)
                    
                }
            }
        }
        .background(
            Image("bg")
                .resizable()
                .scaledToFill()
        )
        .navigationBarTitle("信息")
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(activeDate: "Now")
    }
}
