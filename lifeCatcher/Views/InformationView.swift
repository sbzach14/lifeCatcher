import SwiftUI
import Localize_Swift

struct InfoView: View {
    @StateObject var viewModel = SettingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10){
                    
            // 版本信息
            Text("Version:".localized() + AuthManager.version)
                .padding()
                .foregroundColor(.black)
            
            Divider()
            
            // 序列号
            HStack {
                Text("ID:".localized() + viewModel.uniqueID)
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
            
//             声明信息
            ScrollView{
                Text("Disclaimer: The use of this software is limited to image recognition and recording for daily life purposes. Any consequences and responsibilities resulting from the use of this program are borne by the user. Our company does not assume any responsibility for any consequences or liabilities arising from the use or sale of this software by users or agents beyond the permitted scope.".localized())
                    .foregroundColor(.white)
            }
            .bubbleBackground()
                
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
        .navigationBarTitle("Information".localized())
    }
}


struct DeprecatedInfoView: View {
    @StateObject var viewModel = SettingViewModel()
    
    var body: some View {
        VStack{
            
            Divider()
            
            HStack {
                Text("屏幕显示").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("blackMode", selection: $viewModel.blackMode) {
                    ForEach(0...FunctionSetting.blackModeDict.count - 1, id: \.self){
                        index in Text(FunctionSetting.blackModeDict[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200, height: 30, alignment: .trailing)
                .padding(.trailing,30) // 右侧间距
            }
            Divider()
        
            
            HStack {
                Text("音量上键功能").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("volumeUp", selection: $viewModel.volumeUp) {
                    ForEach(0...FunctionSetting.volumeUpDict.count - 1, id: \.self){
                        index in Text(FunctionSetting.volumeUpDict[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200, height: 30, alignment: .trailing)
                .padding(.trailing,30) // 右侧间距
            }
            Divider()
        
            HStack {
                Text("音量下键功能").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("volumeDown", selection: $viewModel.volumeDown) {
                    ForEach(0...FunctionSetting.volumeDownDict.count - 1, id: \.self){
                        index in Text(FunctionSetting.volumeDownDict[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200, height: 30, alignment: .trailing)
                .padding(.trailing,30) // 右侧间距
            }
            Divider()
            
            HStack {
                Text("播放设备").foregroundColor(.white).padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("voiceDevice", selection: $viewModel.voiceDevice) {
                    ForEach(0...FunctionSetting.voiceDeviceDict.count - 1, id: \.self){
                        index in Text(FunctionSetting.voiceDeviceDict[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200, height: 30, alignment: .trailing)
                .padding(.trailing,30) // 右侧间距
            }
            
            Divider()
        
            HStack {
                Text("音量:\(String(format: "%.2f",viewModel.volumeValue))").foregroundColor(.white).padding(.leading, 20).frame(width: 100, alignment: .leading)
                
                Spacer()
                
                Slider(value: $viewModel.volumeValue, in: 0...1, step: 0.01)
                    .frame(maxWidth: 200, alignment: .trailing)
                    .padding(.trailing,30) // 右侧间距
                    .accentColor(.white)
            }.frame(height: 30)
            
            Divider()
            
            HStack {
                Text("语速:\(String(format: "%.2f",viewModel.voiceRate))").foregroundColor(.white).padding(.leading, 20).frame(width: 100, alignment: .leading)
                
                Spacer()
                
                Slider(value: $viewModel.voiceRate, in: 0...1, step: 0.01)
                    .frame(maxWidth: 200, alignment: .trailing)
                    .padding(.trailing,30) // 右侧间距
                    .accentColor(.white)
            }.frame(height: 30)
                
            
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

class FunctionSetting{
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
    
    static let blackModeDict: [Int: String] = [
        0: "相机图像",
        1: "正常黑屏",
        2: "黑屏点击"
    ]
    
    static let voiceDeviceDict: [Int: String] = [
        0: "扬声器",
        1: "耳机"
    ]
}
