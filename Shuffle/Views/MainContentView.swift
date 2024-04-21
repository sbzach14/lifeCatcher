import SwiftUI
import MediaPlayer
import Combine

struct MainContentView: View {
    var saveRuleIndex : Int
    @StateObject var viewModel : ViewModel = ViewModel()
    @State var isNavigateToShowCardView = false
    @State var isAVCaptureActive = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            MyViewControllerWrapper(viewmodel: viewModel)
             
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
                                Text("后置相机")
                                    .foregroundColor(.white)
                                    .padding(.leading, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Toggle("", isOn: $viewModel.isBackCamera)
                                    .toggleStyle(CustomToggleStyle())
                                    .frame(width: 160, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                                    .onChange(of: viewModel.isBackCamera) {
                                        newValue in
                                        viewModel.stopCamera()
                                        viewModel.setupAVCapture()
                                        viewModel.startCamera()
                                        viewModel.updateConfigJSON()
                                    }
                            }
                            Divider().colorInvert()
                            
                            HStack {
                                Text("缩放比例").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Slider(value: $viewModel.zoomFactor, in: 0...1, step: 0.02)
                                    .frame(width: 160, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                                    .onChange(of: viewModel.zoomFactor) {
                                        newValue in
                                        viewModel.updateZoomFactor()
                                        viewModel.updateConfigJSON()
                                    }
                            }
                            Divider().colorInvert()
                            
                            HStack {
                                Text("焦距调节").foregroundColor(.white).padding(.leading, 20).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Slider(value: $viewModel.focusFactor, in: 0...1, step: 0.02)
                                    .frame(width: 160, height: 30, alignment: .trailing)
                                    .padding(.trailing,30) // 右侧间距
                                    .accentColor(.white)
                                    .onChange(of: viewModel.focusFactor) {
                                        newValue in
                                        viewModel.updateFocusFactor()
                                        viewModel.updateConfigJSON()
                                    }
                            }
                        }
                        .padding()
                        .bubbleBackground()
                    }
                    
                    HStack{
                        Button {
                            viewModel.isShowCard = true
                            self.isNavigateToShowCardView = true
                        } label: {
                            Label("ShowCard", systemImage: "magnifyingglass")
                                .foregroundColor(.blue)
                                .labelStyle(.iconOnly)
                                .bubbleBackground()
                                
                        }
                        .frame(width: 50, height: 50)
                        .background(NavigationLink(destination: ShowCardView().environmentObject(viewModel),
                                                   isActive: $isNavigateToShowCardView,
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
            viewModel.isShowCard = false
            viewModel.isCamereSetting = false
            viewModel.startCamera()
            
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .toolbarBackground(.hidden)
        .navigationTitle("")
        .background {
            if let image = viewModel.cameraImage {
                CameraView(cameraImage: image)
                    .ignoresSafeArea()
            }
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(saveRuleIndex: -1)
    }
}

struct MyViewControllerWrapper: UIViewControllerRepresentable {
    
    var viewmodel: ViewModel?
    
    func makeUIViewController(context: Context) -> MyViewController {
        let viewController = MyViewController(viewModel: viewmodel!)
        return viewController
    }

    func updateUIViewController(_ uiViewController: MyViewController, context: Context) {
        // 可选：在这里更新视图控制器的状态
    }
}

class MyViewController: UIViewController {
    
    var viewModel: ViewModel?
    var lastVolumeNotificationSequenceNumber: Int = -1
    var currentVolume: Float = -1
    let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
    var lastVolumeChangeTime: Date = Date() // 添加一个变量来跟踪上次音量变化的时间
    let minVolumeChangeInterval: TimeInterval = 0.2 // 设置最小触发间隔时间，单位为秒
    var isFirst: Bool = true
    var volumeValue: Float = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewcontroller load")
    }
    
    // 自定义初始化方法，接收参数
    init(viewModel: ViewModel) {
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

        print("viewcontroller init")

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
            // 设置音量
            volumeViewSlider?.value = volume
            print("\(volumeViewSlider?.value ?? -100)")
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

        // 判断音量变化的原因是否为 "ExplicitVolumeChange"
        if reason == "ExplicitVolumeChange" && volume != currentVolume{
            
            // 避免重复事件
            guard let sequenceNumber = userInfo["SequenceNumber"] as? Int else {
                return
            }
            
            if sequenceNumber == lastVolumeNotificationSequenceNumber {
                NSLog("Duplicate notification received")
                return
            }
            
            // 检查时间间隔是否满足最小触发间隔
            let currentTime = Date()
            let timeSinceLastChange = currentTime.timeIntervalSince(lastVolumeChangeTime)
            if timeSinceLastChange < minVolumeChangeInterval {
                NSLog("Volume change occurred too soon after last change")
                return
            }
            
            // 更新上次音量变化的时间
            lastVolumeChangeTime = currentTime
            
            //print("Volume: \(notification) \(currentVolume) \(volume)")
            
            var isUp = true
            if volume == 1 || currentVolume < volume {
                isUp = true
            } else if volume == 0 || currentVolume > volume {
                isUp = false
            }
            currentVolume = self.volumeValue
            
            lastVolumeNotificationSequenceNumber = sequenceNumber
            setSystemVolume(volume: self.volumeValue)
            // 处理音量变化逻辑
            
            if isUp {
                // 处理音量增加逻辑
                viewModel?.handleVolumeIncrease()
            } else {
                // 处理音量减少逻辑
                viewModel?.handleVolumeDecrease()
            }
            
        }
    }
}
