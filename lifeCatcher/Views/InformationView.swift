import SwiftUI
import Localize_Swift

struct InfoView: View {
    @StateObject var viewModel = SettingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10){
                    
            // 版本信息
            Text("Version:".localized() + AuthManager.version)
                .padding()
                .foregroundColor(.white)

            Divider().colorInvert()

            // 序列号
            HStack {
                Text("ID:".localized() + viewModel.uniqueID)
                    .textSelection(.enabled)
                    .padding()
                    .foregroundColor(.white)
                
                Button(action: {
                    UIPasteboard.general.string = viewModel.uniqueID
                }) {
                    Text("Copy".localized())
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
            }
            Divider().colorInvert()
            
            // 激活日期（如果激活）
            if viewModel.trueVersion != ""{
                Text("激活版本:" + viewModel.trueVersion)
                    .padding()
                    .foregroundColor(.white)
                
                Divider().colorInvert()
            }
            
            if viewModel.trueDate != ""{
                Text("有效日期:" + viewModel.trueDate)
                    .padding()
                    .foregroundColor(.white)
                
                Divider().colorInvert()
            }
            
//             声明信息
            ScrollView{
                Text("Disclaimer: The use of this software is limited to image recognition and recording for daily life purposes. Any consequences and responsibilities resulting from the use of this program are borne by the user. Our company does not assume any responsibility for any consequences or liabilities arising from the use or sale of this software by users or agents beyond the permitted scope.".localized())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .bubbleBackground()
                
            Spacer()
            
            Image("lifeCatcherTitle") // Replace with your image name
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding()
                .cornerRadius(10)
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
    var isLocalEndpoint = false
    var includesReceiverSettings = false
    @StateObject var viewModel = SettingViewModel()
    @State private var remoteRegion = RemotePreferences.sourceRegion
    @AppStorage(RemotePreferenceKeys.videoFPS) private var remoteVideoFPS = 30
    @AppStorage(RemotePreferenceKeys.videoResolution) private var remoteVideoResolution = 720
    @AppStorage(RemotePreferenceKeys.videoLowPower) private var remoteVideoLowPower = false
    
    var body: some View {
        ScrollView {
        VStack{
            NavigationLink(frameRateTestTitle) {
                FrameRateTestView(
                    isBackCamera: viewModel.isBackCamera,
                    remoteEnabled: !isLocalMode,
                    remoteVideoFPS: [30, 60].contains(remoteVideoFPS) ? remoteVideoFPS : 30,
                    remoteVideoResolution: remoteVideoResolution == 1080 ? 1080 : 720
                )
            }
            .padding()

            if includesReceiverSettings {
                RemoteReceiverAudioSettingsRows()
            }

            Divider().colorInvert()
            if isLocalMode {
                HStack {
                    Text("播报设备").foregroundColor(.white)
                    Spacer()
                    Picker("播报设备", selection: $viewModel.voiceDevice) {
                        Text("扬声器").tag(0)
                        Text("耳机").tag(1)
                    }.pickerStyle(.menu)
                }.padding(.horizontal)
                HStack {
                    Text("播报音量").foregroundColor(.white)
                    Slider(value: $viewModel.volumeValue, in: 0...1)
                }.padding(.horizontal)
                HStack {
                    Text("播报语速").foregroundColor(.white)
                    Slider(value: $viewModel.voiceRate, in: 0...1)
                }.padding(.horizontal)
                HStack {
                    Text("时间显示").foregroundColor(.white)
                    Spacer()
                    Picker("时间显示", selection: $viewModel.timeMode) {
                        Text("无").tag(0)
                        Text("HH:MM").tag(1)
                        Text("HH:MM:SS").tag(2)
                    }.pickerStyle(.menu)
                }.padding(.horizontal)
                Divider().colorInvert()
            } else {
                HStack {
                    Text("显示帧率").foregroundColor(.white).padding(.leading, 20)
                    Spacer()
                    Picker("显示帧率", selection: $remoteVideoFPS) {
                        Text("30 FPS").tag(30)
                        Text("60 FPS").tag(60)
                    }
                    .pickerStyle(.menu)
                    .padding(.trailing, 30)
                    .onChange(of: remoteVideoFPS) { _, value in
                        RemotePreferences.videoFPS = value
                    }
                }
                Divider().colorInvert()
                Toggle(isOn: $remoteVideoLowPower) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("低功耗传输").foregroundColor(.white)
                        Text("LiveKit 最高码率减半").font(.caption).foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .onChange(of: remoteVideoLowPower) { _, value in
                    RemotePreferences.videoLowPower = value
                }
                Divider().colorInvert()
                HStack {
                    Text("送帧分辨率").foregroundColor(.white).padding(.leading, 20)
                    Spacer()
                    Picker("送帧分辨率", selection: $remoteVideoResolution) {
                        Text("720p").tag(720)
                        Text("1080p").tag(1080)
                    }
                    .pickerStyle(.menu)
                    .padding(.trailing, 30)
                    .onChange(of: remoteVideoResolution) { _, value in
                        RemotePreferences.videoResolution = value
                    }
                }
                Divider().colorInvert()
                HStack {
                    Text("连接服务器").foregroundColor(.white).padding(.leading, 20)
                    Spacer()
                    Picker("连接服务器", selection: $remoteRegion) {
                        ForEach(RemoteRegion.allCases) { region in Text(region.title).tag(region) }
                    }
                    .pickerStyle(.menu)
                    .padding(.trailing, 30)
                    .onChange(of: remoteRegion) { _, value in
                        RemotePreferences.sourceRegion = value
                        RemoteDiagnostics.record(
                            value.isConfigured ? .info : .warning,
                            category: "settings",
                            message: value.isConfigured ? "已选择\(value.title)：\(value.endpointDescription)" : "\(value.title) IP 尚未配置",
                            toast: true
                        )
                    }
                }
                Divider().colorInvert()
            }
            
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

            Divider().colorInvert()
            
            HStack {
                Text("亮度\(String(format: "%.2f",viewModel.blackFactor))").foregroundColor(.white).padding(.leading, 20).frame(width: 100, alignment: .leading)
                
                Spacer()
                
                Slider(value: $viewModel.blackFactor, in: 0...1, step: 0.01)
                    .frame(maxWidth: 200, alignment: .trailing)
                    .padding(.trailing,30) // 右侧间距
                    .accentColor(.white)
            }.frame(height: 30)
                
            
            Spacer()
        }
        .onAppear { RemotePreferences.recognitionMode = isLocalEndpoint ? .local : .remote }
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
        .navigationBarTitle("功能设置")
    }

    private var isLocalMode: Bool {
        isLocalEndpoint
    }

    private var frameRateTestTitle: String {
        if isLocalMode { return "帧率测试（本地 CLS）" }
        return "帧率测试（LiveKit \(remoteVideoResolution == 1080 ? 1080 : 720)p / \([30, 60].contains(remoteVideoFPS) ? remoteVideoFPS : 30) FPS ＋ CLS）"
    }
}

class FunctionSetting{
    static let volumeUpDict: [Int: String] = [
        0: "无功能",
        1: "人数",
        2: "位置",
        3: "人数和位置",
        4: "洗牌手法",
        5: "拨牌手法",
        6: "方案",
        7: "开始暂停",
        8: "报下一轮"
    ]
    
    static let volumeDownDict: [Int: String] = [
        0: "无功能",
        1: "人数",
        2: "位置",
        3: "人数和位置",
        4: "洗牌手法",
        5: "拨牌手法",
        6: "方案",
        7: "开始暂停",
        8: "报下一轮",
        9: "音量+功能菜单切换"
    ]
    
    static let blackModeDict: [Int: String] = [
        0: "相机图像",
        1: "正常黑屏(双击进入)",
        2: "黑屏点击(双击进入，单击暂停）"
    ]
    
    static let voiceDeviceDict: [Int: String] = [
        0: "扬声器",
        1: "耳机"
    ]
    
    static let timeModeDict: [Int: String] = [
        0: "无",
        1: "HH:MM",
        2: "HH:MM:SS"
    ]
}
