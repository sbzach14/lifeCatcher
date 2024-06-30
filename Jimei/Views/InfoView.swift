

import SwiftUI

struct InfoView: View {
    @StateObject var viewModel = SettingViewModel()

    var body: some View {
        VStack{
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0)  {
                    Text("版本 : 1.0").padding()
                        .foregroundColor(.white)
                    
                    Divider().colorInvert()
                    
                    Text("序列号 : " + viewModel.uniqueID).textSelection(.enabled).padding()
                        .foregroundColor(.white)
                    
                    Divider().colorInvert()
                    
                    if viewModel.isActive{
                        Text("激活日期 : " + viewModel.activeDate).padding()
                            .foregroundColor(.white)
                        
                        Divider().colorInvert()
                    }
                    
                    Text("声明:本软件的使用范围仅限于日常生活图像识别与记录用途，使用本程序造成的任何后果及责任由使用者承担，本公司不承担因用户或代理商在非允许使用范围内使用或销售而导致的任何后果及相关责任。").padding()
                        .foregroundColor(.white)
                    
                    Divider().colorInvert()
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

struct DeprecatedInfoView: View {
    @StateObject var viewModel = SettingViewModel()
    
    var body: some View {
            VStack{

                ScrollView {
                    VStack()  {
                            HStack {
                                Text("黑屏").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)

                                Toggle("", isOn: $viewModel.isBlack).toggleStyle(CustomToggleStyle())
                                    .frame(width: 160, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                            }
                            Divider().colorInvert()
                            
                            HStack {
                                Text("耳机").foregroundColor(.white).padding(.leading, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Toggle("", isOn: $viewModel.isMute).toggleStyle(CustomToggleStyle())
                                    .frame(width: 160, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                            }
                            Divider().colorInvert()
                            
                            HStack {
                                Text("音量上键功能").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Picker("volumeUp", selection: $viewModel.volumeUp) {
                                    ForEach(0...volumeSetting.volumeUpDict.count - 1, id: \.self){
                                        index in Text(volumeSetting.volumeUpDict[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 200, height: 30, alignment: .trailing)
                                .padding(.trailing,30) // 右侧间距
                                .accentColor(.white)
                            }
                            Divider().colorInvert()
                            
                            HStack {
                                Text("音量下键功能").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Picker("volumeDown", selection: $viewModel.volumeDown) {
                                    ForEach(0...volumeSetting.volumeDownDict.count - 1, id: \.self){
                                        index in Text(volumeSetting.volumeDownDict[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 200, height: 30, alignment: .trailing)
                                .padding(.trailing,30) // 右侧间距
                                .accentColor(.white)
                            }
                            Divider().colorInvert()
                            
                            HStack {
                                Text("音量大小").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Slider(value: $viewModel.volumeValue, in: 0.01...0.99)
                                    .frame(width: 200, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                            }
                            Divider().colorInvert()
                        }
                }
            }
            .onDisappear{
                viewModel.updateConfigJSON()
            }
            .background(
                Image("bg")
                    .resizable()
                    .scaledToFill()
            )
            .navigationBarTitle("设置")
    }
}

class volumeSetting{
    static let volumeUpDict: [Int: String] = [
        0: "无功能",
        1: "增加人数",
        2: "下一个位置",
        3: "下一个手法",
        4: "下一个方案",
        5: "开始暂停",
        6: "报下一轮"
    ]
    
    static let volumeDownDict: [Int: String] = [
        0: "无功能",
        1: "减少人数",
        2: "上一个位置",
        3: "上一个手法",
        4: "上一个方案",
        5: "开始暂停",
        6: "报下一轮",
        7: "切换音量上键功能"
    ]
}
