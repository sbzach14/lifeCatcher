//
//  ReportSettingView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 1/30/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI

struct ReportSettingView: View {
    @State private var searchText = ""
    @State private var reportSettingDicShow:[Int] = []
    @State private var currentSelectReport: Int = -1
    
    var body: some View {
        VStack{
            SearchBar(searchText: $searchText)
            ScrollView{
                //优先显示当前选中的报法，如果没有当前报法则按顺序从gamemanager中显示
                //一个for循环便利所有的gamemanager中的报发只显示报法结构体中报法的info包含搜索的关键词searchText中的部分
                //每一个显示的报法都有一个点击效果，如果点击将会选中这个报法，把index加入到currentselectreport中，返回给上一个view
            }
        }.navigationTitle("报法设置设置").background(Image("bg").resizable().scaledToFill())
    }
}

struct ReportSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ReportSettingView()
    }
}


