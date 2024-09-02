

import SwiftUI
import Localize_Swift

struct InfoView: View {
    @StateObject var viewModel = SettingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10){
                    
            // 版本信息
            Text("Version:1.0.2")
                .padding()
                .foregroundColor(.black)
            
            Divider()
            
            // 序列号
            HStack {
                Text("ID: \(viewModel.uniqueID)")
                    .textSelection(.enabled)
                    .padding()
                    .foregroundColor(.black)
                
                Button(action: {
                    UIPasteboard.general.string = viewModel.uniqueID
                }) {
                    Text("复制")
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
            }
            Divider()
            
            // 激活日期（如果激活）
            if viewModel.trueVersion != ""{
                Text("激活版本:" + viewModel.trueVersion)
                    .padding()
                    .foregroundColor(.black)
                
                Divider()
            }
            if viewModel.trueDate != ""{
                Text("有效日期:" + viewModel.trueDate)
                    .padding()
                    .foregroundColor(.black)
                
                Divider()
            }
            
            // 声明信息
//                    Text("声明:本软件的使用范围仅限于日常生活图像识别与记录用途，使用本程序造成的任何后果及责任由使用者承担，本公司不承担因用户或代理商在非允许使用范围内使用或销售而导致的任何后果及相关责任。")
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color.black.opacity(0.3))
//                        )
                    
                
                Spacer()
                
                Image("lifeCatcherTitle") // Replace with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.3))
                    )
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarTitle("Information")
    }
}


struct DeprecatedInfoView: View {
    @StateObject var viewModel = SettingViewModel()
    
    var body: some View {
        VStack{
            VStack{
                HStack {
                    Text("语言")
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle("", isOn: $viewModel.isLanguageToggleOn)
                        .toggleStyle(CustomToggleStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing, 30)
                        .accentColor(.white)
                        .onChange(of: viewModel.isLanguageToggleOn) { newValue in
                            if newValue {
                                    Localize.setCurrentLanguage("zh-Hans")
                                    UserDefaults.standard.set(true, forKey: "isLanguageToggleOn")
                                } else {
                                    Localize.setCurrentLanguage("en")
                                    UserDefaults.standard.set(false, forKey: "isLanguageToggleOn")
                                }
                        }
                }
                Divider().colorInvert()


            }.padding()
            
            VStack{
                HStack {
                    Text("黑屏").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle("", isOn: $viewModel.isBlack).toggleStyle(CustomToggleStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing,30) // 右侧间距
                        .accentColor(.white)
                }
                Divider().colorInvert()
            }.padding()
            
            VStack{
                HStack {
                    Text("耳机").foregroundColor(.white).padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle("", isOn: $viewModel.isMute).toggleStyle(CustomToggleStyle())
                        .frame(width: 160, height: 30, alignment: .trailing)
                        .padding(.trailing,30) // 右侧间距
                        .accentColor(.white)
                }
                Divider().colorInvert()
            }.padding()
            
            VStack{
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
            }.padding(/*@START_MENU_TOKEN@*/EdgeInsets()/*@END_MENU_TOKEN@*/)
            
            VStack{
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
            }.padding()
            
            VStack{
                HStack {
                    Text("音量大小").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                    
                    Slider(value: $viewModel.volumeValue, in: 0.01...0.99)
                        .frame(width: 200, height: 30, alignment: .trailing)
                        .padding(.trailing,30) // 右侧间距
                        .accentColor(.white)
                }
                Divider().colorInvert()
            }.padding()
            
            Spacer()
        }
        .onDisappear{
            viewModel.updateConfigJSON()
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
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
