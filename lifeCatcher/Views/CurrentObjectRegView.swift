import SwiftUI
import MediaPlayer
import Combine

struct CurrentVisionObjectRecognitionView: View {
    var saveRuleIndex : Int
    @StateObject var viewModel : CurrentVisionObjectRecognitionViewModel = CurrentVisionObjectRecognitionViewModel()
    @State var isNavigateToShowSingleFeatureView = false
    @State var isAVCaptureActive = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ButtonViewControllerWrapper(viewmodel: viewModel)
             
            if viewModel.isBlack {
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                        .opacity(1.0)
                }
                .onAppear {
                    UIScreen.main.brightness = 0.0
                }
                .onDisappear {
                    
                    UIScreen.main.brightness = 1.0
                }
                .navigationBarBackButtonHidden(true)
            } else {
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
                                        
                                        viewModel.stopCamera()
                                        viewModel.setupAVCapture()
                                        viewModel.startCamera()
                                        viewModel.updateConfigJSON()
                                    }
                                
                                Text("后置")
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
                            
//                            Divider().colorInvert()
//                            
//                            HStack {
//                                Text("自动对焦").foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading)
//                                
//                                Spacer()
//                                
//                                if viewModel.captureDevice.isFocusModeSupported(.locked){
//                                    Toggle("", isOn: $viewModel.isAutoFocus)
//                                        .toggleStyle(CustomToggleStyle())
//                                        .frame(width: 200, height: 30, alignment: .trailing)
//                                        .accentColor(.white)
//                                        .onChange(of: viewModel.isAutoFocus) {
//                                            newValue in
//                                            viewModel.updateFocusFactor()
//                                            viewModel.updateConfigJSON()
//                                        }
//                                }
//                            }
                            
                            if !viewModel.isAutoFocus && viewModel.isBackCamera{
                                
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
                            self.isNavigateToShowSingleFeatureView = true
                        } label: {
                            Label("ShowSingleFeature", systemImage: "magnifyingglass")
                                .foregroundColor(.blue)
                                .labelStyle(.iconOnly)
                                .bubbleBackground()
                                
                        }
                        .frame(width: 50, height: 50)
                        .background(NavigationLink(destination: ShowResultView().environmentObject(viewModel),
                                                   isActive: $isNavigateToShowSingleFeatureView,
                                                   label: EmptyView.init).hidden()
                        )
                        
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
                viewModel.initialize(saveRuleIndex: saveRuleIndex)
            }
            self.isAVCaptureActive = true
            viewModel.isWorking = true
            viewModel.isShowSingleFeature = false
            viewModel.isCamereSetting = false
            viewModel.prestartCamera()
            viewModel.stopCamera()
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .toolbarBackground(.hidden)
        .navigationTitle("")
        .background {
            if let image = viewModel.cameraImage {
                CameraImageView(cameraImage: image)
                    .ignoresSafeArea()
            }
        }
        
    }
}

struct ButtonViewControllerWrapper: UIViewControllerRepresentable {
    
    var viewmodel: CurrentVisionObjectRecognitionViewModel?
    
    func makeUIViewController(context: Context) -> ButtonViewController {
        let viewController = ButtonViewController(viewModel: viewmodel!)
        return viewController
    }

    func updateUIViewController(_ uiViewController: ButtonViewController, context: Context) {
        // 可选：在这里更新视图控制器的状态
    }
}

class ButtonViewController: UIViewController {
    
    var viewModel: CurrentVisionObjectRecognitionViewModel?
    var lastVolumeNotificationSequenceNumber: Int = -1
    var currentVolume: Float = -1
    let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
    var lastVolumeChangeTime: Date = Date()
    let minVolumeChangeInterval: TimeInterval = 0.2
    var isFirst: Bool = true
    var volumeValue: Float = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(viewModel: CurrentVisionObjectRecognitionViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.view.addSubview(self.volumeView)
        
        // Load data from config.json
        if let configData = readConfigJSON() {
            let floatDict = configData["Float"] as! [String : Float]
            self.volumeValue = floatDict["volumeValue"]!
        } else {
            self.volumeValue = 0.5
        }
        
        viewModel.viewController = self
        self.currentVolume = self.volumeValue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(_:)), name: NSNotification.Name(rawValue: "SystemVolumeDidChange"), object: nil)
        setSystemVolume(volume: self.volumeValue)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SystemVolumeDidChange"), object: nil)
    }
    
    func setSystemVolume(volume: Float) {
        DispatchQueue.main.async {
            let volumeViewSlider = self.volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
            volumeViewSlider?.value = volume
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @objc func volumeChanged(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let volume = userInfo["Volume"] as? Float,
              let reason = userInfo["Reason"] as? String else {
            return
        }

        if reason == "ExplicitVolumeChange" && volume != currentVolume{
            guard let sequenceNumber = userInfo["SequenceNumber"] as? Int else {
                return
            }
            
            if sequenceNumber == lastVolumeNotificationSequenceNumber {
                return
            }
            
            let currentTime = Date()
            let timeSinceLastChange = currentTime.timeIntervalSince(lastVolumeChangeTime)
            if timeSinceLastChange < minVolumeChangeInterval {
                return
            }
            lastVolumeChangeTime = currentTime
            
            var isUp = true
            if volume == 1 || currentVolume < volume {
                isUp = true
            } else if volume == 0 || currentVolume > volume {
                isUp = false
            }
            currentVolume = self.volumeValue
            
            lastVolumeNotificationSequenceNumber = sequenceNumber
            setSystemVolume(volume: self.volumeValue)
            
            if isUp {
                viewModel?.handleVolumeIncrease()
            } else {
                viewModel?.handleVolumeDecrease()
            }
            
        }
    }
}
