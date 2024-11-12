import SwiftUI
import MediaPlayer
import Combine
import AVFoundation

struct CurrentVisionObjectRecognitionView: View {
    var saveRuleIndex : Int
    var configType : Int
    @StateObject var viewModel : CurrentVisionObjectRecognitionViewModel = CurrentVisionObjectRecognitionViewModel()
    @State var isAVCaptureActive = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ButtonViewControllerWrapper(viewmodel: viewModel)
             
            if viewModel.isBlack {
                VStack (spacing: 0){
                    if viewModel.timeMode != 0{
                        // 公历日期和农历日期显示
                        Text("\(TimeModeFormatter.dateFormatter.string(from: viewModel.currentDate).replacingOccurrences(of: "星期", with: "周")) · \(TimeModeFormatter.lunarDateString(from: viewModel.currentDate))")
                            .font(.system(size: 22))
                            .bold()
                            .padding(.top, 40)
                            .foregroundColor(.white)
                        
                        if viewModel.timeMode == 1{
                            // 显示时间
                            Text(viewModel.timeModeText)
                                .bold()
                                .foregroundColor(.white)
                                .font(.system(size: 100))
                        }
                        else if viewModel.timeMode == 2{
                            // 显示时间
                            Text(viewModel.timeModeText)
                                .bold()
                                .foregroundColor(.white)
                                .font(.system(size: 70))
                        }
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)  // 让 VStack 填充整个可用空间
                .background(
                    Color.black
                    .edgesIgnoringSafeArea(.all)
                    .opacity(1.0))
                .onAppear {
                    UIScreen.main.brightness = CGFloat(viewModel.blackFactor)
                }
                .navigationBarBackButtonHidden(true)
            } 
            else if viewModel.isShowSingleFeature{
                ShowResultView().environmentObject(viewModel)
            }
            else {
                if let cameraImage = viewModel.cameraImage{
                    Image(cameraImage, scale: 1.0, label: Text("Camera"))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2){
                            if viewModel.blackMode != 0{
                                viewModel.isBlack = true
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 50)
                                .onChanged { value in
                                    if value.translation.width < 0 {
                                        // 右滑
                                        viewModel.isShowSingleFeature = true
                                    }
                                }
                        )
                }
                
                VStack{
                    if viewModel.isCamereSetting{
                        VStack{
                            HStack {
                                Text("相机选择")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 80, alignment: .leading)
                                
                                Spacer()
                                
                                Text("前置")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 40, alignment: .trailing)
                                
                                Toggle("", isOn: $viewModel.isBackCamera)
                                    .toggleStyle(CustomToggleStyle_NoText())
                                    .frame(width:70, height: 30, alignment: .trailing)
                                    .accentColor(.white)
                                    .onChange(of: viewModel.isBackCamera) {
                                        newValue in
                                        
                                        //前置
                                        if newValue == false{
                                            viewModel.isCameraHorizon = true
                                        }
                                        else{
                                            viewModel.isCameraHorizon = false
                                        }
                                        
                                        viewModel.stopCamera()
                                        viewModel.setupAVCapture()
                                        viewModel.prestartCamera()
                                        viewModel.updateConfigJSON()
                                    }
                                
                                Text("后置")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 40, alignment: .trailing)
                            }
                            
                            Divider().colorInvert()
                            
                            HStack {
                                Text("相机亮度")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 80, alignment: .leading)
             
                                Spacer()
                                
                                Text("自动")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 40, alignment: .trailing)
                                
                                Toggle("", isOn: $viewModel.isMaxLightness)
                                    .toggleStyle(CustomToggleStyle_NoText())
                                    .frame(width: 70, height: 30, alignment: .trailing)
                                    .accentColor(.white)
                                    .onChange(of: viewModel.isMaxLightness) {
                                        newValue in
                                        
                                        viewModel.stopCamera()
                                        viewModel.setupAVCapture()
                                        viewModel.prestartCamera()
                                        viewModel.updateConfigJSON()
                                    }
                                
                                Text("最大")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 40, alignment: .trailing)
                            }
                            
                            if viewModel.isBackCamera{
                                
                                Divider().colorInvert()
                                
                                HStack {
                                    Text("屏幕方向")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 80, alignment: .leading)
                 
                                    Spacer()
                                    
                                    Text("竖屏")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 40, alignment: .trailing)
                                    
                                    Toggle("", isOn: $viewModel.isCameraHorizon)
                                        .toggleStyle(CustomToggleStyle_NoText())
                                        .frame(width: 70, height: 30, alignment: .trailing)
                                        .accentColor(.white)
                                        .onChange(of: viewModel.isCameraHorizon) {
                                            newValue in
                                            viewModel.updateConfigJSON()
                                        }
                                    
                                    Text("横屏")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 40, alignment: .trailing)
                                }
                            }
                            
                            if viewModel.isBackCamera{
                                
                                Divider().colorInvert()
                                
                                HStack {
                                    Text("焦距:\(String(format: "%.2f", viewModel.focusFactor))").foregroundColor(.white).frame(maxWidth:80, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    Slider(value: $viewModel.focusFactor, in: 0...1, step: 0.01)
                                        .frame(width: .infinity, height: 30, alignment: .trailing)
                                        .accentColor(.white)
                                        .onChange(of: viewModel.focusFactor) {
                                            newValue in
                                            viewModel.updateFocusFactor()
                                            viewModel.updateConfigJSON()
                                    }
                                }
                            }
//                            else{
//                                Divider().colorInvert()
//                                
//                                HStack {
//                                    Text("刷新频率")
//                                        .foregroundColor(.white)
//                                        .frame(maxWidth: 80, alignment: .leading)
//                 
//                                    Spacer()
//                                    
//                                    Text("正常")
//                                        .foregroundColor(.white)
//                                        .frame(maxWidth: 40, alignment: .trailing)
//                                    
//                                    Toggle("", isOn: $viewModel.isHighHz)
//                                        .toggleStyle(CustomToggleStyle_NoText())
//                                        .frame(width: 70, height: 30, alignment: .trailing)
//                                        .accentColor(.white)
//                                        .onChange(of: viewModel.isHighHz) {
//                                            newValue in
//                                            
//                                            viewModel.stopCamera()
//                                            viewModel.setupAVCapture()
//                                            viewModel.prestartCamera()
//                                            viewModel.updateConfigJSON()
//                                        }
//                                    
//                                    Text("增强")
//                                        .foregroundColor(.white)
//                                        .frame(maxWidth: 40, alignment: .trailing)
//                                }
//                            }
                            
                            Divider().colorInvert()
                            
                            HStack {
                                Text("缩放:\(String(format: "%.2f", viewModel.zoomFactor))").foregroundColor(.white).frame(maxWidth: 80, alignment: .leading)
                                
                                Spacer()
                                
                                Slider(value: $viewModel.zoomFactor, in: 0...1, step: 0.01)
                                    .frame(width: .infinity, height: 30, alignment: .trailing)
                                    .accentColor(.white)
                                    .onChange(of: viewModel.zoomFactor) {
                                        newValue in
                                        viewModel.updateZoomFactor()
                                        viewModel.updateConfigJSON()
                                    }
                            }
                        }
                        .bubbleBackground()
                    }
                    
                    HStack{
                        Button {
                            viewModel.isShowSingleFeature = true
                        } label: {
                            Label("ShowSingleFeature", systemImage: "magnifyingglass")
                                .foregroundColor(.blue)
                                .labelStyle(.iconOnly)
                                .bubbleBackground()
                                
                        }
                        .frame(width: 50, height: 50)
                        
                        Spacer()
                        
                        Button {
                            viewModel.isCamereSetting.toggle()
                        } label: {
                            Label("CameraSetting", systemImage: "camera")
                                .foregroundColor(.blue)
                                .labelStyle(.iconOnly)
                                .bubbleBackground()
                                
                        }
                        .frame(width: 50, height: 50)
                    }
                    .padding()
                }
                
            }
            Spacer()
        }
        .onAppear {
            if !self.isAVCaptureActive && self.saveRuleIndex != -1{
                viewModel.initialize(saveRuleIndex: saveRuleIndex, configType: configType)
            }
            self.isAVCaptureActive = true
            viewModel.isWorking = true
            viewModel.isShowSingleFeature = false
            viewModel.isCamereSetting = false
            viewModel.prestartCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
            viewModel.speechPerformer.stopSpeechSynthesis()
        }
        .onTapGesture{
            if viewModel.blackMode == 2 && viewModel.isBlack{
                viewModel.toggleWorking()
                //viewModel.generateTestResult()
            }
        }
        .toolbarBackground(.hidden)
        .navigationTitle("")
    }
}

struct ButtonViewControllerWrapper: UIViewControllerRepresentable {
    
    var viewmodel: CurrentVisionObjectRecognitionViewModel?
    
    func makeUIViewController(context: Context) -> ButtonViewController {
        let viewController = ButtonViewController(viewModel: viewmodel!)
        return viewController
    }

    func updateUIViewController(_ uiViewController: ButtonViewController, context: Context) {
    }
}

class ButtonViewController: UIViewController {
    
    var viewModel: CurrentVisionObjectRecognitionViewModel?
    var lastVolumeNotificationSequenceNumber: Int = -1
    var currentVolume: Float = -1
    let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
    var lastVolumeChangeTime: Date = Date()
    var isFirst: Bool = true
    var volumeValue: Float = 0.5
    var voiceDevice: Int = 1
    
    private var tapTimer: Timer?
    private var lastTapTime: Date?
    private let doubleTapDelay: TimeInterval = 0.5
    private let ignoreInterval: TimeInterval = 0.1 // 忽略快速连续按键的时间间隔


    private func handleSingleTap(isUp: Bool) {
        print("Single Tap    isUp:\(isUp)")
        self.viewModel?.handleTap(isUp: isUp, isSingle: true)
    }

    private func handleDoubleTap(isUp: Bool) {
        print("Double Tap    isUp:\(isUp)")
        self.viewModel?.handleTap(isUp: isUp, isSingle: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(volumeView)
    }
    
    init(viewModel: CurrentVisionObjectRecognitionViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        
        // Load data from config.json
        if let configData = readConfigJSON() {
            let floatDict = configData["Float"] as! [String : Float]
            self.volumeValue = floatDict["volumeValue"]!
            let intDict = configData["Int"] as! [String : Int]
            self.voiceDevice = intDict["voiceDevice"]!
        }
        self.currentVolume = self.volumeValue
        
        if self.isHeadphonesConnected(){
            self.voiceDevice = 1
        }
    }
    
    func isHeadphonesConnected() -> Bool {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        let connectedBluetoothHeadphones = currentRoute.outputs.contains { $0.portType == .bluetoothA2DP }
        return connectedBluetoothHeadphones
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSystemVolume(volume: self.volumeValue)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(_:)), name: NSNotification.Name(rawValue: "SystemVolumeDidChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除自定义视图
        volumeView.removeFromSuperview()
        
        // 移除通知观察者
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SystemVolumeDidChange"), object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
    }
    
    func setSystemVolume(volume: Float) {
        DispatchQueue.main.async {
            let volumeViewSlider = self.volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
            if volumeViewSlider?.value == volume && self.isFirst{
                self.isFirst = false
            }
            volumeViewSlider?.value = volume
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? Int,
              let reason = AVAudioSession.RouteChangeReason(rawValue: UInt(reasonValue)) else {
            return
        }
        
        if reason == .oldDeviceUnavailable && self.voiceDevice == 1 {
            print("Earphones or other audio device was disconnected")
            // 在这里处理耳机断开的逻辑
            viewModel?.speechPerformer.stopSpeechSynthesis()
            viewModel?.speakText(input: -1)
            setSystemVolume(volume: 0)
        }
        
        if reason == .newDeviceAvailable && self.voiceDevice == 0 && self.isHeadphonesConnected(){
            print("Earphones or other audio device connect")
            self.voiceDevice = 1
            viewModel?.voiceDevice = 1
            viewModel?.updateConfigJSON()
        }
    }

    deinit {
        volumeView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SystemVolumeDidChange"), object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
    }
    
    @objc func volumeChanged(_ notification: NSNotification) {
        
        DispatchQueue.main.async {
            guard let userInfo = notification.userInfo,
                  let volume = userInfo["Volume"] as? Float,
                  let reason = userInfo["Reason"] as? String else {
                return
            }
            
            if reason == "ExplicitVolumeChange"{
                guard let sequenceNumber = userInfo["SequenceNumber"] as? Int else {
                    return
                }
                
                if sequenceNumber == self.lastVolumeNotificationSequenceNumber {
                    return
                }
                self.lastVolumeNotificationSequenceNumber = sequenceNumber
                
                let currentTime = Date()
                let timeSinceLastChange = currentTime.timeIntervalSince(self.lastVolumeChangeTime)
                if timeSinceLastChange < self.ignoreInterval {
                    return
                }
                self.lastVolumeChangeTime = currentTime
                
                if self.isFirst{
                    self.isFirst = false
                    return
                }
                
                var isUp = true
                if volume == 1 || self.currentVolume < volume {
                    isUp = true
                } else if volume == 0 || self.currentVolume > volume {
                    isUp = false
                }
                self.currentVolume = self.volumeValue
                
                if let timer = self.tapTimer {
                    // 如果计时器已存在，取消它并认为是双击
                    timer.invalidate()
                    self.tapTimer = nil
                    self.handleDoubleTap(isUp: isUp)
                } else {
                    // 启动计时器，等待可能的双击
                    self.tapTimer = Timer.scheduledTimer(withTimeInterval: self.doubleTapDelay, repeats: false) { [weak self] _ in
                        self?.tapTimer = nil
                        self?.handleSingleTap(isUp: isUp)
                    }
                }
                
                self.setSystemVolume(volume: self.volumeValue)
            }
        }
    }
}
