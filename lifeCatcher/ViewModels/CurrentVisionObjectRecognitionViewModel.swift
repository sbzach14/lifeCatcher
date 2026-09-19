import SwiftUI
import CreateMLComponents
import AsyncAlgorithms
import AVFoundation
import CoreMedia
import MobileCoreServices
import Foundation

import Vision
import Foundation
import CoreML
import Photos
import Accelerate
import AudioToolbox
import MediaPlayer


/// - Tag: ViewModel
class CurrentVisionObjectRecognitionViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVAudioPlayerDelegate{

    /// ROI routing follows the action currently being recognized rather than
    /// only the modes enabled in the saved rule. Horizontal shuffle and its
    /// cut phase remain distinct states but share one dynamic geometry.
    private enum TargetAreaScenario: Equatable {
        case standard
        case horizontalShuffle
        case horizontalShuffleCut
    }

    /// Horizontal-shuffle classification uses one geometry contract in both
    /// orientations. Landscape treats X as along; portrait swaps the axes.
    private let horizontalShuffleROIAspect: Float = 16.0 / 9.0
    private let horizontalShuffleROIAreaFactor: Float = 70.0
    private let horizontalShuffleROIPairSpanFactor: Float = 1.5
    /// Calibrated on all 1,631 retained 0813/0814 M2 pairs after phone-axis
    /// canonicalization. The observed cross-offset/mean-cross-size maximum is
    /// 1.3247; 1.5 keeps 13% headroom without weakening the along-axis gate.
    private let horizontalShufflePostureCrossOffsetLimit: Float = 1.5

    private struct HorizontalShufflePixelBox {
        let centerAlong: Float
        let centerCross: Float
        let sizeAlong: Float
        let sizeCross: Float
    }

    public static let context = CIContext()
    @MainActor private var remoteSourceBridge: RemoteSourceBridge?
    private var lastRemoteFrameTimestamp = CMTime.invalid

    @Published private(set) var remoteServerPresence: RemotePresenceState = .offline
    @Published private(set) var remoteReceiverPresence: RemotePresenceState = .offline
    @Published private(set) var remoteDesktopPresence: RemotePresenceState = .offline
    
    @Published var cameraImage : CGImage?
    @Published var isShowSingleFeature : Bool = false
    @Published var isCamereSetting : Bool = false
    
    @Published var singlefeatureArray :  [Int] = []
    @Published var multipleDatasetRCInfos: ReportManager.MultipleReportResultInfo = ReportManager.MultipleReportResultInfo()
    @Published var leftSingleFeatures: [Int] = []
    @Published var usedSingleFeatures: [Int] = []
    @Published var cutStructArray: [cutStruct] = []
    @Published var cutShowArray : [Int] = []
    
    let detectModel = try! detect_0903()
    let horizontalShuffleDetectModel = try! detect_20260915_texas()
    let horizontalShuffleModel = try! cls_20260917_texas()
    let clsModel_h = try! cls_1215_h()
    let clsModel_v = try! cls_1215_v()
//    let clsModel_h = try! cls_0715_h_trans()
//    let clsModel_v = try! cls_0727_v_trans()
    
    let riffleDetectModel = try! riffle_detect_1111()
    let riffleModel_h = try! riffle_cls_h_1107()
    let riffleModel_v = try! riffle_cls_v_1107()
    
    var originSize : [Float] = [1920, 1080] //相机图像大小
    var imageSize : [Float] = [569, 320] //target area 截图大小
    var originImageSize : [Float] = [569, 320] //target area 原始截图大小
    var inputSize : [Int] = [320, 320] //分类尺寸
    var detectSize : [Int] = [640, 640] //检测尺寸
    
    var startAudioRC: AVAudioPlayer?
    var successAudioRC: AVAudioPlayer?
    var failAudioRC: AVAudioPlayer?
    private let commandCenter = MPRemoteCommandCenter.shared()
    
    // 创建一个后台队列
    let backgroundQueue = DispatchQueue(label: "actionQueue", attributes: .concurrent)
    let saveImageQueue = DispatchQueue(label: "saveImageQueue", qos: .userInteractive, attributes: .concurrent)
    let detectionQueue = DispatchQueue(label: "detectionQueue", attributes: .concurrent)
    private var recognitionGeneration = 0
    private var remoteAwaitingShuffle = false
    private var requiresPairForNextRecognition = false
    private var remoteRecomputableDeck: [Int] = []
    
    let lock = NSLock()
    
    
    public var state : String = "idle"
    public var shuffleMode : [Int] = [1,0]
    public var cutMode : [Int] = [0,0]
    public var rcNum: Int = 0
    public var dealNum: Int = 0
    public var coloringType: Int = 0
    public var dealType: Int = 0
    public var diyDealNum: [Int] = []
    public var diyDealStatus: [[Bool]] = []
    public var calModeArgs : [[Int]] = [[0, 0], [0, 0]]
    public var cutNumSetting: Int = 0
    public var cutNumRangeSetting: [Int] = [2,10]
    public var consecutiveReport: Int = 0
    public var reportNumber: Int = 0
    public var voiceReport: Int = 0
    public var ruleIndex : Int = 0
    public var args : [Int] = []
    public var rankRules : [Int] = []
    public var suitRules : [Int] = [3,2,1,0]
    public var allSingleFeatureIndex : [Int] = Array(0...51)
    public var minSingleFeatureNum : Int = 0
    public var recgReport : Bool = false
    public var specialCard:[Int] = [0,0]
    public var currentRoundID: Int = 0
    
    //测试用的定时器
    public var ding: Int = 0
    public var ciimageQueue: [CIImage] = []
    
    //存图用的记录顺序
    var saveOrderIndex: Int = 0
    
    let idleRate = 30
    var taskImageArray : [String] = []
    
    var isSavedImage : Bool = true
    var saveCount: Int = -1
    var saveFlag: Bool = false
    var isEmptyFrame : Bool = true
    var taskIndex : Int = 0
    var currentTask: Int = 0
    
    var detectResultList : [Int : [DetectionResult]] = [:]
    var centerPos : [Float] = [0.5, 0.5]
    var lastBoxes : [[Float]] = [[0.02, 0.02, 0.01, 0.05], [0.98, 0.98, 0.01, 0.01]]
    var targetArea : [Float] = [0, 0, 0, 0]
    var initTargetArea: [Float] = [0, 0, 0, 0]
    var isTargetArea : Bool = false
    var isDetect: Bool = false
    private var activeTargetAreaScenario: TargetAreaScenario = .standard
    
    //显示帧率
    private var frameCount = 0
    private var timestamp: Double = 0
    private var frameRateLabel: UILabel! // 用于显示帧率的标签
    
    var captureDevice: AVCaptureDevice!
    var captureDeviceInput: AVCaptureDeviceInput!
    let session = AVCaptureSession()
    private var requests = [VNRequest]()
    
    private var stateCounter : Int = 0
    private var shuffleStartCounter : Int = 0
    private var shuffleResetCounter : Int = 0
    private var stateSingleFeature : [Int] = [-1, -1]
    
    private var laplacianDic: [[Int:Float]] = [[:],[:]]
    
    var shuffleOrRiffle: Int = 0 //-1未知 0洗牌 1拨牌
    
    let singlefeatureLabelDic : [Int:String] = [
        0: "♠️A ", 1: "♠️2", 2: "♠️3", 3: "♠️4", 4: "♠️5 ", 5: "♠️6 ", 6: "♠️7 ", 7: "♠️8 ", 8: "♠️9 ", 9: "♠️10 ",
        10: "♠️J ", 11: "♠️Q ", 12: "♠️K ", 13: "♥️A ", 14: "♥️2 ", 15: "♥️3 ", 16: "♥️4 ", 17: "♥️5 ", 18: "♥️6 ",
        19: "♥️7 ", 20: "♥️8 ", 21: "♥️9 ", 22: "♥️10 ", 23: "♥️J ", 24: "♥️Q ", 25: "♥️K ", 26: "♣️A ", 27: "♣️2 ",
        28: "♣️3 ", 29: "♣️4 ", 30: "♣️5 ", 31: "♣️6 ", 32: "♣️7 ", 33: "♣️8 ", 34: "♣️9 ", 35: "♣️10 ", 36: "♣️J ",
        37: "♣️Q ", 38: "♣️K ", 39: "♦️A ", 40: "♦️2 ", 41: "♦️3 ", 42: "♦️4 ", 43: "♦️5 ", 44: "♦️6", 45: "♦️7",
        46: "♦️8 ", 47: "♦️9 ", 48: "♦️10 ", 49: "♦️J ", 50: "♦️Q ", 51: "♦️K ", 52: "none", 53: "小王", 54: "大王"
    ]
    
    @Published var isBlack: Bool = false
    
    @Published var isBackCamera: Bool = false
    @Published var isCameraHorizon: Bool = true
    @Published var isHighHz:Bool = true
    @Published var isMaxLightness:Bool = false
    @Published var volumeUp: Int = 0
    @Published var volumeDown: Int = 0
    @Published var blackMode: Int = 0
    @Published var voiceDevice: Int = 0
    @Published var timeMode: Int = 0
    @Published var addCardMode: Int = 1
    @Published var volumeValue: Float = 0.5
    @Published var voiceRate: Float = 0.5
    @Published var zoomFactor: Float = 0
    @Published var focusFactor: Float = 0.6
    @Published var blackFactor: Float = 0
    
    @Published var currentDate: Date = Date()
    @Published var timeModeText: String = ""
    
    var setFrameRate: Float64 = 120.0
    var cameraFrameRate: Int = 0
    let maxZoomScale: Float = 3
    
    var testCVPixelBuffer : CVPixelBuffer?
    var selectedSaveIndex : Int = 0
    var isWorking: Bool = true
    
    let speechPerformer = SpeechPerformer()
    
    var detectSet: Set<Int> = []
    
    //单次识别是否等待识别切牌
    var detectNeedToCut : Bool = false
    
    var startSoundURL: URL?
    var successSoundURL: URL?
    var failSoundURL: URL?
    var hintVoiceIndex: Int = -1
    
    var displayTimer: Timer?
    var latestFrame: CVPixelBuffer?
    var combinedTransform: CGAffineTransform!
    
    var timeModeTimer: Timer?

    // Maintain a single reference to the current audio player
    private var currentAudioPlayer: AVAudioPlayer?
    
    private var soundURLs: [URL?]?
    
    private var showTimeModeText: Bool = false
    private var timerWorkItem: DispatchWorkItem?
    
    var isProcessNeedToCut: Bool = false
    var reloadingTime: Double = 0
    
    var continueCutTimeCounter: Float = 10
    var continueMaxCutTime: Float = 10
    
    var configType: Int = 0
    

    override init(){
        
        super.init()
        
        // Load data from config.json
        if let configData = readConfigJSON() {
            let boolDict = configData["Bool"] as! [String : Bool]
            self.isBackCamera = boolDict["isBackCamera"]!
            self.isCameraHorizon = boolDict["isCameraHorizon"]!
            self.isHighHz = boolDict["isHighHz"]!
            self.isMaxLightness = boolDict["isMaxLightness"]!
            
            let intDict = configData["Int"] as! [String : Int]
            self.volumeUp = intDict["volumeUp"]!
            self.volumeDown = intDict["volumeDown"]!
            self.blackMode = intDict["blackMode"]!
            self.voiceDevice = intDict["voiceDevice"]!
            self.timeMode = RemoteRecognitionPolicy.localResultDisplayEnabled ? intDict["timeMode"]! : 0
            self.addCardMode = intDict["addCardMode"]!
            
            
            let floatDict = configData["Float"] as! [String : Float]
            self.volumeValue = floatDict["volumeValue"]!
            self.voiceRate = floatDict["voiceRate"]!
            self.zoomFactor = floatDict["zoomFactor"]!
            self.focusFactor = floatDict["focusFactor"]!
            self.blackFactor = floatDict["blackFactor"]!
        }
        
        self.isWorking = true
        
        self.speechPerformer.voiceRate = self.voiceRate
        
        self.isHighHz = true
        
        if RemoteRecognitionPolicy.localAudioEnabled && self.isHeadphonesConnected(){
            self.voiceDevice = 1
            self.updateConfigJSON()
        }
    }
    
    func initialize(saveRuleIndex: Int, configType: Int) {
        self.configType = configType
        setupAVCapture()
        if RemoteRecognitionPolicy.localAudioEnabled {
            configureAudioSession()
        }
        initializeTransform()
        
        self.loadSaveRule(saveRuleIndex: saveRuleIndex)
        self.initShuffle()
        self.initDetectResult()
        self.initBoxes()
        
        if self.shuffleMode[0] != 0{
            shuffleOrRiffle = 0
        }
        else if self.shuffleMode[1] != 0 {
            shuffleOrRiffle = 1
        }
    }

    @MainActor
    func startRemoteSourceIfEnabled() {
        guard RemotePreferences.sourceEnabled else { return }
        if remoteSourceBridge == nil {
            let bridge = RemoteSourceBridge()
            bridge.onStatusChange = { [weak self] state, receiver, desktop in
                guard let self else { return }
                switch state {
                case .connected: self.remoteServerPresence = .online
                case .connecting, .reconnecting: self.remoteServerPresence = .reconnecting
                case .idle, .failed: self.remoteServerPresence = .offline
                }
                self.remoteReceiverPresence = receiver
                self.remoteDesktopPresence = desktop
            }
            bridge.onAwaitShuffleCommand = { [weak self] in
                self?.resetToAwaitingShuffle()
            }
            bridge.onRecomputeCutCommand = { [weak self] cutCard in
                self?.recomputeRemoteResult(cutCard: cutCard)
            }
            bridge.onRecognitionPausedCommand = { [weak self] paused in
                self?.setRecognitionPaused(paused)
            }
            remoteSourceBridge = bridge
            bridge.updateControlState(recognitionPaused: !isWorking, awaitingShuffle: remoteAwaitingShuffle)
        }
        remoteSourceBridge?.startIfEnabled()
    }

    /// Starts every recognition-screen visit as a fresh, actively running session.
    /// This also clears a previous desktop-requested awaiting-shuffle marker when
    /// SwiftUI reuses the same view model after navigating back to this screen.
    @MainActor
    func prepareForRecognitionScreenEntry() {
        isWorking = true
        remoteAwaitingShuffle = false
        isShowSingleFeature = false
        isCamereSetting = false
        recognitionGeneration += 1
        remoteSourceBridge?.updateControlState(recognitionPaused: false, awaitingShuffle: false)
    }

    /// Resets only the current recognition session and keeps the selected rule/camera configuration.
    @MainActor
    func resetToAwaitingShuffle() {
        stopCurrentAudio()
        speechPerformer.stopSpeechSynthesis()
        isWorking = true
        isShowSingleFeature = false
        isCamereSetting = false
        reloadingTime = 0
        detectNeedToCut = false
        requiresPairForNextRecognition = true
        remoteAwaitingShuffle = true
        remoteRecomputableDeck = []
        initShuffle()
        initDetectResult()
        initBoxes()
        recognitionGeneration += 1
        state = "idle"
        remoteSourceBridge?.updateControlState(recognitionPaused: false, awaitingShuffle: true)
        changeCameraFrameRate(to: idleRate)
        RemoteDiagnostics.record(.success, category: "source", message: "识别端已切换为待洗牌", toast: true)
    }

    /// Replaces the most recent visually recognized cut card and reruns the
    /// existing rule/report pipeline from the untouched recognized deck.
    @MainActor
    func recomputeRemoteResult(cutCard: Int) {
        guard RemotePreferences.sourceEnabled else { return }
        guard ((0...51).contains(cutCard) || cutCard == 53 || cutCard == 54),
              let cutIndex = remoteRecomputableDeck.firstIndex(of: cutCard) else {
            RemoteDiagnostics.record(.error, category: "source", message: "无法更正切牌：牌不在当前识别牌序中", toast: true)
            return
        }

        stopCurrentAudio()
        speechPerformer.stopSpeechSynthesis()
        singlefeatureArray = remoteRecomputableDeck

        let configuredCutMode = cutMode[shuffleOrRiffle]
        let corrected: cutStruct
        switch configuredCutMode {
        case 2, 5:
            let topIndex = cutIndex == 0 ? singlefeatureArray.count - 1 : cutIndex - 1
            corrected = cutStruct(cutcardIndex: singlefeatureArray[topIndex], cutMode: 1)
        case 4:
            corrected = cutStruct(cutcardIndex: cutCard, cutMode: 4)
        case 6, 7:
            corrected = cutStruct(cutcardIndex: cutCard, cutMode: 5)
        default:
            let existingMode = cutStructArray.last?.cutMode ?? 0
            corrected = cutStruct(cutcardIndex: cutCard, cutMode: existingMode)
        }

        if cutStructArray.isEmpty { cutStructArray = [corrected] }
        else { cutStructArray[cutStructArray.count - 1] = corrected }
        if cutShowArray.isEmpty { cutShowArray = [cutCard] }
        else { cutShowArray[cutShowArray.count - 1] = cutCard }

        computeWinnerRC(isReset: true)
        RemoteDiagnostics.record(.success, category: "source", message: "已按更正切牌重新计算并发送结果", toast: true)
    }

    @MainActor
    func setRecognitionPaused(_ paused: Bool) {
        guard isWorking == paused else {
            remoteSourceBridge?.updateControlState(recognitionPaused: !isWorking, awaitingShuffle: remoteAwaitingShuffle)
            return
        }
        isWorking = !paused
        if paused {
            // Discard any inference that began before the pause command. Video
            // publishing continues because it occurs before the isWorking gate.
            recognitionGeneration += 1
        }
        remoteSourceBridge?.updateControlState(recognitionPaused: paused, awaitingShuffle: remoteAwaitingShuffle)
        RemoteDiagnostics.record(.success, category: "source", message: paused ? "识别已暂停" : "识别已开始", toast: true)
    }

    @MainActor
    func stopRemoteSource() {
        remoteSourceBridge?.stop()
        remoteSourceBridge = nil
        remoteServerPresence = .offline
        remoteReceiverPresence = .offline
        remoteDesktopPresence = .offline
    }
    
    // 在初始化时预计算变换矩阵
    func initializeTransform() {
        
        let scaleTransform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        let rotationTransform = CGAffineTransform(rotationAngle: -.pi / 2)
        let xOffset = self.originSize[1] * 0.4
        let translationTransform = CGAffineTransform(translationX: CGFloat(xOffset), y: 0)
        
        // 合并所有变换操作
        combinedTransform = rotationTransform
            .concatenating(scaleTransform)
            .concatenating(translationTransform)
    }

    
    private func initDetectResult(){
        detectResultList.removeAll()
        stateCounter = 0
        shuffleStartCounter = 0
        shuffleResetCounter = 0
        isDetect = false
        detectSet.removeAll()
    }
    
    private func initShuffle(){
        //初始化reportmanager flag
        ReportManager.isFirstReport = true
        
        self.continueCutTimeCounter = self.continueMaxCutTime
        self.currentRoundID = 1
        singlefeatureArray = []
        cutStructArray = []
        cutShowArray = []
        self.leftSingleFeatures = []
        self.usedSingleFeatures = []
        multipleDatasetRCInfos = ReportManager.MultipleReportResultInfo()
        
        if (self.shuffleMode[0] != 0 && (self.cutMode[0] != 0 || self.specialCard[0] != 0))
            || (self.shuffleMode[1] != 0 && (self.cutMode[1] != 0 || self.specialCard[1] != 0)){
            self.isProcessNeedToCut = true
        }
        else{
            self.isProcessNeedToCut = false
        }
    }
    
    private func initBoxes(){
        centerPos = [0.5, 0.5]
        lastBoxes = [[0.02, 0.02, 0.01, 0.01], [0.98, 0.98, 0.02, 0.02]]
        targetArea = [0,0,0,0]
        initTargetArea = [0, 0, 0, 0]
        activeTargetAreaScenario = .standard
        imageSize[0] = min(originSize[0], originImageSize[0] * (1 + self.zoomFactor * self.maxZoomScale))
        imageSize[1] = min(originSize[1], originImageSize[1] * (1 + self.zoomFactor * self.maxZoomScale))
        isTargetArea = false
    }
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            // print("Failed to set up audio session: \(error)")
        }
        
        self.startSoundURL = Bundle.main.url(forResource: "start_voice", withExtension: "mp3")
        self.successSoundURL = Bundle.main.url(forResource: "success_voice", withExtension: "mp3")
        self.failSoundURL = Bundle.main.url(forResource: "fail_voice", withExtension: "mp3")
        self.soundURLs = [startSoundURL, successSoundURL, failSoundURL]
    }
    
    func setupAVCapture(){
        
        if self.isBackCamera{
            self.captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            self.setFrameRate = 240.0
        }
        else{
            self.captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            self.setFrameRate = 120.0
        }
        
        
        do {
            self.captureDeviceInput = try AVCaptureDeviceInput(device: self.captureDevice)
            
            session.beginConfiguration()
            
            // 移除所有的输入
            for input in session.inputs {
                session.removeInput(input)
            }

            // 移除所有的输出
            for output in session.outputs {
                session.removeOutput(output)
            }

            session.addInput(captureDeviceInput!)
            
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            session.addOutput(output)
            
            guard let format = self.captureDevice.formats.first(where: { format in
                let ranges = format.videoSupportedFrameRateRanges
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                return dimensions.width == 1920
                && ranges.contains { range in
                    return range.maxFrameRate >= self.setFrameRate
                }
            }) else {
                // print("不支持\(setFrameRate)帧的摄像头格式")
                return
            }
            do {
                try self.captureDevice.lockForConfiguration()
                
                self.captureDevice.activeFormat = format
                self.captureDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(format.videoSupportedFrameRateRanges.first!.maxFrameRate))
                self.captureDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(format.videoSupportedFrameRateRanges.first!.maxFrameRate))
                
                self.captureDevice.exposureMode = .continuousAutoExposure
                
                self.captureDevice.unlockForConfiguration()
            } catch {
                // print("设置帧率时发生错误: \(error)")
            }
            
            updateFocusFactor()
            updateZoomFactor()
            
            session.commitConfiguration()
            
            changeCameraFrameRate(to: idleRate)
        } catch {
            // print("配置前置摄像头时发生错误: \(error)")
        }
    }
    
    
    func updateZoomFactor(){
        do{
            // print("zoomFactor: \(zoomFactor), minZoomFactor: \(captureDevice.minAvailableVideoZoomFactor)")
            try self.captureDevice.lockForConfiguration()
            
            let minzoomfactor = captureDevice.minAvailableVideoZoomFactor
            self.captureDevice.videoZoomFactor = minzoomfactor + CGFloat(self.maxZoomScale * self.zoomFactor)
            
            self.captureDevice.unlockForConfiguration()
        }
        catch{
            
        }
    }
    
    func updateFocusFactor(){
        do{
            // print("focusFactor: \(focusFactor)")
            try self.captureDevice.lockForConfiguration()
            
            
            if captureDevice.isFocusPointOfInterestSupported && self.captureDevice.isFocusModeSupported(.locked){
                self.captureDevice.focusMode = .locked
                self.captureDevice.setFocusModeLocked(lensPosition: self.focusFactor)
                // print("对焦模式：手动对焦")
                
            }
            else if self.captureDevice.isFocusModeSupported(.continuousAutoFocus){
                self.captureDevice.focusMode = .continuousAutoFocus
                // print("对焦模式：自动对焦")
            }
            
            self.captureDevice.unlockForConfiguration()
        }
        catch{
            
        }
    }
    
    func prestartCamera() {
        session.startRunning()
        changeCameraFrameRate(to: Int(self.setFrameRate))
        stopCamera()
        startCamera()
    }
    
    func startCamera() {
        session.startRunning()
        changeCameraFrameRate(to: self.idleRate)
        startDisplayTimer()
        
        if self.timeMode != 0 && self.blackMode != 0{
            startTimeModeTimer()
        }
    }
    
    func stopCamera() {
        timerWorkItem?.cancel()
        print("timer work item cancel")

        session.stopRunning()
        stopDisplayTimer()
        timerWorkItem?.cancel()
        if self.timeMode != 0 && self.blackMode != 0{
            stopTimeModeTimer()
        }
    }
    
    func changeCameraFrameRate(to frameRate: Int) {
        guard let device = self.captureDevice else {
            // print("相机设备未初始化")
            return
        }
        
        do{
            try device.lockForConfiguration()
            let format = device.activeFormat
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(frameRate))
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(frameRate))
            
            let highHz = 240
            let lowHz = self.setFrameRate
            
            if frameRate == idleRate{
                //detectneedtocut
                if (self.isProcessNeedToCut || self.recgReport) && self.singlefeatureArray.count > 0{
                    device.exposureMode = .custom
                    
                    if self.isHighHz && self.isMaxLightness{
                        device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(highHz)), iso: device.activeFormat.maxISO)
                    }
                    else if !self.isHighHz && self.isMaxLightness{
                        device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(lowHz)), iso: device.activeFormat.maxISO)
                    }
                    else if self.isHighHz && !self.isMaxLightness{
                        device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(highHz)), iso: AVCaptureDevice.currentISO)
                    }
                    else if !self.isHighHz && !self.isMaxLightness{
                        device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(lowHz)), iso: AVCaptureDevice.currentISO)
                    }
                }
                else{
                    if self.isHighHz && self.isMaxLightness{
                        device.exposureMode = .custom
                        device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(highHz)), iso: device.activeFormat.maxISO)
                    }
                    else if !self.isHighHz && self.isMaxLightness{
                        device.exposureMode = .custom
                        device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(lowHz)), iso: device.activeFormat.maxISO)
                    }
                    else if self.isHighHz && !self.isMaxLightness{
                        device.exposureMode = .continuousAutoExposure
                        device.setExposureTargetBias(0)
                    }
                    else if !self.isHighHz && !self.isMaxLightness{
                        device.exposureMode = .continuousAutoExposure
                        device.setExposureTargetBias(0)
                    }
                }
            }
            else{
                device.exposureMode = .custom
                if self.isHighHz && self.isMaxLightness{
                    device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(highHz)), iso: device.activeFormat.maxISO)
                }
                else if !self.isHighHz && self.isMaxLightness{
                    device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(lowHz)), iso: device.activeFormat.maxISO)
                }
                else if self.isHighHz && !self.isMaxLightness{
                    device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(highHz)), iso: AVCaptureDevice.currentISO)
                }
                else if !self.isHighHz && !self.isMaxLightness{
                    device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(lowHz)), iso: AVCaptureDevice.currentISO)
                }
            }
            
            device.unlockForConfiguration()
            cameraFrameRate = frameRate
            // print("设置帧率为: \(frameRate)")
            
            updateZoomFactor()
            updateFocusFactor()
        }catch {
            // print("设置帧率时发生错误: \(error)")
        }
    }
    
    // 启动定时器以每秒 1 次的频率更新日期
    func startTimeModeTimer() {
        timeModeTimer?.invalidate() // 确保之前的定时器被取消
        timeModeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCurrentDate()
        }
    }

    // 停止定时器
    func stopTimeModeTimer() {
        print("停止定时器")
        timeModeTimer?.invalidate()
        timeModeTimer = nil
    }
    
    func updateCurrentDate(){
        self.currentDate = Date()
        if !self.showTimeModeText{
            if self.timeMode == 1{
                self.timeModeText = TimeModeFormatter.timeFormatter1.string(from: self.currentDate)
            }
            else if self.timeMode == 2{
                self.timeModeText = TimeModeFormatter.timeFormatter2.string(from: self.currentDate)
            }
        }
    }
    
    func scheduleHideTimeModeText() {
        // 取消之前的定时任务（如果存在）
        
        // 创建新的定时任务
        let workItem = DispatchWorkItem { [weak self] in
            self?.showTimeModeText = false
        }

        // 保存新的定时任务
        self.timerWorkItem = workItem
        
        // 调度新的定时任务
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }
    
    // 启动定时器以每秒 30 次的频率更新图像
    func startDisplayTimer() {
        displayTimer?.invalidate() // 确保之前的定时器被取消
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.displayLatestFrame()
        }
    }

    // 停止定时器
    func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }
    
    func displayLatestFrame() {
        guard let frame = latestFrame else {
            return
        }

        if !self.isBlack && !self.isShowSingleFeature && self.isWorking {
            backgroundQueue.async {
                do {
//                    var rectList : [[Float]] = []
//                    rectList.append(self.lastBoxes[0])
//                    rectList.append(self.lastBoxes[1])
//                    rectList.append(self.targetArea)
//                    let drawcvpixelbuffer = drawRectanglesOnPixelBuffer(pixelBuffer: frame, rectList: rectList)!
//                    let ciImage = CIImage(cvPixelBuffer: drawcvpixelbuffer)
                    
                    let ciImage = CIImage(cvPixelBuffer: frame)

                    // 使用预先计算的变换矩阵
                    let translatedImage = ciImage.transformed(by: self.combinedTransform)

                    guard let outputCGImage = CurrentVisionObjectRecognitionViewModel.context.createCGImage(translatedImage, from: translatedImage.extent) else {
                        return
                    }

                    // 更新 UI 在主线程
                    DispatchQueue.main.async {
                        self.cameraImage = outputCGImage
                    }
                } catch {
                    // 错误处理
                }
            }
        }
    }

    
    // MARK: capture output
    // AVCaptureVideoDataOutputSampleBufferDelegate 方法
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let currentTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        
        // 计算时间差
        let deltaTime = currentTimestamp - self.timestamp
        frameCount += 1
        // 更新时间戳
        // 每秒更新一次帧率
        if deltaTime >= 1.0 {
            let frameRate = Double(frameCount) / deltaTime
            print("实时帧率\(frameRate)fps \(self.captureDevice.iso)iso")
            timestamp = currentTimestamp
            // 重置计数器
            frameCount = 0
            
            if self.continueCutTimeCounter < self.continueMaxCutTime{
                self.continueCutTimeCounter += 1
            }
        }
        
        if self.state != "idle"{
            self.taskIndex += 1
        }
        else{
            self.taskIndex = -1
        }
        
        let myIndex = self.taskIndex
        
        // 处理视频帧数据
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let remoteTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let remoteDelta = lastRemoteFrameTimestamp.isValid ? CMTimeSubtract(remoteTimestamp, lastRemoteFrameTimestamp).seconds : .infinity
        let remoteVideoInterval = 1.0 / Double(RemotePreferences.videoFPS)
        if RemotePreferences.sourceEnabled && (!lastRemoteFrameTimestamp.isValid || remoteDelta < 0 || remoteDelta >= remoteVideoInterval) {
            lastRemoteFrameTimestamp = remoteTimestamp
            let remoteFrame = RemoteVideoFrame(pixelBuffer: pixelBuffer, timestamp: remoteTimestamp)
            Task { @MainActor [weak self] in self?.remoteSourceBridge?.offerVideoFrame(remoteFrame) }
        }
        
        // 保存最新的一帧
        latestFrame = pixelBuffer
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let isTargetArea = self.isTargetArea
        let targetArea = Array(self.targetArea)
        let targetAreaScenario = self.activeTargetAreaScenario
        let isCameraHorizon = self.isCameraHorizon
        let recognitionGeneration = self.recognitionGeneration
    
        
        if self.isWorking{
            
            self.detectionQueue.async {
                
                if targetArea.count == 4{
                    if isTargetArea{
                        let cvPixelBuffer = createCVPixelBuffer(ciImage: ciImage, targetSize: CGSize(width: self.inputSize[0], height: self.inputSize[1]), targetArea: targetArea)!
                        
                        self.processImageOrigin(
                            cvPixelBuffer,
                            taskIndex: myIndex,
                            isTargetArea: isTargetArea,
                            targetArea: targetArea,
                            targetAreaScenario: targetAreaScenario,
                            isCameraHorizon: isCameraHorizon,
                            recognitionGeneration: recognitionGeneration
                        )
                    }
                    else{
                        let cvPixelBuffer = createCVPixelBuffer(ciImage: ciImage, targetSize: CGSize(width: self.detectSize[0], height: self.detectSize[1]), targetArea: targetArea)!
                        
                        self.processImageOrigin(
                            cvPixelBuffer,
                            taskIndex: myIndex,
                            isTargetArea: isTargetArea,
                            targetArea: targetArea,
                            targetAreaScenario: targetAreaScenario,
                            isCameraHorizon: isCameraHorizon,
                            recognitionGeneration: recognitionGeneration
                        )
                    }
                }
            }
        }
        
        
    }
    
    private func processImageOrigin(
        _ pixelBuffer: CVPixelBuffer,
        taskIndex: Int,
        isTargetArea: Bool,
        targetArea: [Float],
        targetAreaScenario: TargetAreaScenario,
        isCameraHorizon: Bool,
        recognitionGeneration: Int
    ){
        
        let detectConfidenceThreshold:Float = 0.8
        let detectConfidenceMinThreshold:Float = 0.5
        let riffleDetectConfidenceThreshold:Float = 0.7
        
        var confidenceThreshold: Float = 0
        if !isTargetArea{
            confidenceThreshold = 0.7
        }
        else{
            confidenceThreshold = 0.3
        }
        
        var iou: Double = 0.2
        var singlefeatureResult : [DetectionResult]
        var uniqueNum : Int
        if !isTargetArea{
            if self.shuffleMode[0] == 1{
                let result = try! self.detectModel.prediction(image: pixelBuffer, iouThreshold: iou, confidenceThreshold: Double(confidenceThreshold))
                (singlefeatureResult, uniqueNum) = getSingleFeature(
                    from: result.confidence,
                    from: result.coordinates,
                    from: pixelBuffer,
                    from: false,
                    isCameraHorizon: isCameraHorizon
                )
            }
            else if self.shuffleMode[0] == 2 {
                let result = try! self.horizontalShuffleDetectModel.prediction(image: pixelBuffer, iouThreshold: iou, confidenceThreshold: Double(confidenceThreshold))
                (singlefeatureResult, uniqueNum) = getSingleFeature(
                    from: result.confidence,
                    from: result.coordinates,
                    from: pixelBuffer,
                    from: false,
                    isCameraHorizon: isCameraHorizon
                )
            }
            else{
                let result = try! self.riffleDetectModel.prediction(image: pixelBuffer, iouThreshold: iou, confidenceThreshold: Double(confidenceThreshold))
                (singlefeatureResult, uniqueNum) = getSingleFeature(
                    from: result.confidence,
                    from: result.coordinates,
                    from: pixelBuffer,
                    from: false,
                    isCameraHorizon: isCameraHorizon
                )
            }
        }
        else if self.shuffleMode[0] == 2 {
            let result = try! self.horizontalShuffleModel.prediction(image: pixelBuffer, iouThreshold: iou, confidenceThreshold: 0.05)
            (singlefeatureResult, uniqueNum) = getSingleFeature(
                from: result.confidence,
                from: result.coordinates,
                from: pixelBuffer,
                from: true,
                isCameraHorizon: isCameraHorizon
            )
        }
        else if isCameraHorizon{
            if self.shuffleMode[0] != 0{
                let result = try! self.clsModel_h.prediction(image: pixelBuffer, iouThreshold: iou, confidenceThreshold: 0.05)
                (singlefeatureResult, uniqueNum) = getSingleFeature(
                    from: result.confidence,
                    from: result.coordinates,
                    from: pixelBuffer,
                    from: true,
                    isCameraHorizon: isCameraHorizon
                )
            }
            else{
                let result = try! self.riffleModel_h.prediction(image: pixelBuffer, iouThreshold: iou, confidenceThreshold: 0.05)
                (singlefeatureResult, uniqueNum) = getSingleFeature(
                    from: result.confidence,
                    from: result.coordinates,
                    from: pixelBuffer,
                    from: true,
                    isCameraHorizon: isCameraHorizon
                )
            }
        }
        else{
            if self.shuffleMode[0] != 0{
                let result = try! self.clsModel_v.prediction(image: pixelBuffer, iouThreshold: iou, confidenceThreshold: 0.05)
                (singlefeatureResult, uniqueNum) = getSingleFeature(
                    from: result.confidence,
                    from: result.coordinates,
                    from: pixelBuffer,
                    from: true,
                    isCameraHorizon: isCameraHorizon
                )
            }
            else{
                let result = try! self.riffleModel_v.prediction(image: pixelBuffer, iouThreshold: iou, confidenceThreshold: 0.05)
                (singlefeatureResult, uniqueNum) = getSingleFeature(
                    from: result.confidence,
                    from: result.coordinates,
                    from: pixelBuffer,
                    from: true,
                    isCameraHorizon: isCameraHorizon
                )
            }
        }
        
//        // 创建输入
//        let input = try! DetectionInput(image: pixelBuffer,iouThreshold: iou,confidenceThreshold: 0.05)
//        // 进行预测
//        let prediction = try! riffleModel_h.prediction(from: input)
//        // 处理预测结果
//        let confidence = prediction.featureValue(for: "confidence")!.multiArrayValue!
//        let coordinates = prediction.featureValue(for: "coordinates")!.multiArrayValue!
//        singlefeatureResult = getSingleFeature(from: confidence, from: coordinates, from: pixelBuffer)
        
        DispatchQueue.main.async{ [self] in
            guard recognitionGeneration == self.recognitionGeneration else { return }
            // Concurrent inference may finish after the user/session has
            // switched orientation or after ROI routing moved to another
            // scenario. Such a frame was produced by a different geometry
            // contract and must not mutate the current recognition state.
            guard isCameraHorizon == self.isCameraHorizon else {
                return
            }
            if isTargetArea
                && targetAreaScenario != self.activeTargetAreaScenario {
                return
            }
            
            if self.state == "idle"{
                if singlefeatureResult[0].singlefeatureIndex[0] == self.stateSingleFeature[0]
                    && singlefeatureResult[1].singlefeatureIndex[0] == self.stateSingleFeature[1]{
                    self.stateCounter += 1
                }
                else{
                    self.stateCounter = 0
                }
            }
            
            self.stateSingleFeature[0] = singlefeatureResult[0].singlefeatureIndex[0]
            self.stateSingleFeature[1] = singlefeatureResult[1].singlefeatureIndex[0]
            
            if singlefeatureResult[0].singlefeatureIndex[0] != -1 && singlefeatureResult[1].singlefeatureIndex[0] != -1{
                self.centerPos = [(singlefeatureResult[0].coordinate[0] + singlefeatureResult[1].coordinate[0])/2, (singlefeatureResult[0].coordinate[1] + singlefeatureResult[1].coordinate[1])/2]
            }
            self.lastBoxes = [singlefeatureResult[0].coordinate,singlefeatureResult[1].coordinate]
            
            var detectNum = 0
            if singlefeatureResult[0].singlefeatureIndex[0] != -1{
                detectNum += 1
            }
            if singlefeatureResult[1].singlefeatureIndex[0] != -1{
                detectNum += 1
            }
            
            if self.state == "reloading"{
                
            }
            else if self.state == "idle" && !self.isTargetArea && !isTargetArea{
                
                if (self.isProcessNeedToCut || self.recgReport) && self.singlefeatureArray.count > 0{
                    self.detectNeedToCut = true
                }
                else{
                    self.detectNeedToCut = false
                }
                let entryMatchesRequestedTarget = self.requiresPairForNextRecognition
                    ? (detectNum == 2 && self.shuffleMode[0] != 0)
                    : ((detectNum == 1 && (self.shuffleMode[1] != 0
                                        || self.detectNeedToCut
                                        || self.shuffleMode[0] == 2))
                       || (detectNum == 2 && (self.shuffleMode[0] != 0 || self.detectNeedToCut)))
                if entryMatchesRequestedTarget && stateCounter >= 1{
                    
                    self.reloadingTime = 0.2
                    
                    print("状态：进入识别")
                    
                    self.stateCounter = 0
                    
                    var stateResult : [[Float]] = []
                    if singlefeatureResult[0].singlefeatureIndex[0] != -1{
                        stateResult.append(singlefeatureResult[0].coordinate)
                    }
                    if singlefeatureResult[1].singlefeatureIndex[0] != -1{
                        stateResult.append(singlefeatureResult[1].coordinate)
                    }
                    
                    self.activeTargetAreaScenario = self.resolveTargetAreaScenario(boxCount: stateResult.count)
                    self.targetArea = self.computeTargetArea(
                        stateResult: stateResult,
                        scenario: self.activeTargetAreaScenario,
                        isCameraHorizon: isCameraHorizon
                    )
                    guard self.targetArea[2] > 0, self.targetArea[3] > 0 else {
                        // Geometry could not produce a valid crop. Stay on
                        // full-frame Detect rather than silently clipping a
                        // target in the classifier input.
                        self.activeTargetAreaScenario = .standard
                        return
                    }
                    self.isTargetArea = true
                    
                    if(detectNum == 2 && self.shuffleMode[0] != 0){
                        //防止切牌语音被重进识别打断
                        //如果两个框距离小于一定范围，不直接响，等洗牌判定再响
                        //这个范围需要够大，使切牌不响
                        //这个范围需要够小，能识别出正常洗牌
                        //即切牌两个框范围<判定范围<洗牌正常识别范围
                        if !self.judgeCutRange(
                            stateResult: stateResult,
                            isCameraHorizon: isCameraHorizon
                        ){
                            self.initTargetArea = self.targetArea
                            self.speakText(input: 0)
                            self.speechPerformer.stopSpeechSynthesis()
                        }
                    }
                    
                    self.requiresPairForNextRecognition = false
                    self.state = "detecting"
                    self.remoteAwaitingShuffle = false
                    self.remoteSourceBridge?.updateControlState(recognitionPaused: false, awaitingShuffle: false)
                    
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                }
            }
            else if isTargetArea && self.isTargetArea{
                
                var leftDetectSingleFeature = -1
                var leftConfidence:Float = -1
                var rightDetectSingleFeature = -1
                var rightConfidence:Float = -1
                
                var detectSingleFeature = -1
                var detectConfidence:Float = -1
                var minDetectConfidence: Float = -1
                
                let isSame = singlefeatureResult[0].singlefeatureIndex[0] != -1 &&
                singlefeatureResult[0].singlefeatureIndex[0] == singlefeatureResult[1].singlefeatureIndex[0]
                
                if singlefeatureResult[0].singlefeatureIndex[0] != -1{
                    leftDetectSingleFeature = singlefeatureResult[0].singlefeatureIndex[0]
                    leftConfidence = singlefeatureResult[0].confidence[0]
                }
                if singlefeatureResult[1].singlefeatureIndex[0] != -1{
                    rightDetectSingleFeature = singlefeatureResult[1].singlefeatureIndex[0]
                    rightConfidence = singlefeatureResult[1].confidence[0]
                }
                
                
                if leftConfidence > rightConfidence{
                    detectConfidence = leftConfidence
                    detectSingleFeature = leftDetectSingleFeature
                    minDetectConfidence = rightConfidence
                }
                else if leftConfidence < rightConfidence{
                    detectConfidence = rightConfidence
                    detectSingleFeature = rightDetectSingleFeature
                    minDetectConfidence = leftConfidence
                }
                
                if case .horizontalShuffle = targetAreaScenario,
                    self.state == "detecting"{
                    // A reliable first pile is the anchor used to search for
                    // the other horizontal-shuffle pile. Do not discard this
                    // ROI merely because the second pile has not appeared yet.
                    if detectNum == 0 || detectConfidence < confidenceThreshold {
                        self.stateCounter += 1
                    }
                    else {
                        self.stateCounter = 0
                    }
                }
                else if self.shuffleMode[0] != 0
                    && self.shuffleMode[1] == 0
                    && (detectNum < 2 || minDetectConfidence < confidenceThreshold)
                    && self.state == "detecting"{
                    self.stateCounter += 1
                }
                else if self.shuffleMode[1] != 0
                    && (detectNum < 1 || detectConfidence < confidenceThreshold)
                    && self.state == "detecting"{
                    self.stateCounter += 1
                }
                else if self.state != "detecting"
                    && (detectNum == 0 || detectConfidence < confidenceThreshold){
                    self.stateCounter += 1
                   
//                    let modelCIImage = CIImage(cvPixelBuffer: pixelBuffer)
//                    let cgImage = CIContext().createCGImage(modelCIImage, from: modelCIImage.extent)
//                    let savedUIImage = UIImage(cgImage: cgImage!)
//                    UIImageWriteToSavedPhotosAlbum(savedUIImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                else{
                    self.stateCounter = 0
                }
                
                var stateResult : [[Float]] = []
                if singlefeatureResult[0].singlefeatureIndex[0] != -1{
                    stateResult.append(singlefeatureResult[0].coordinate)
                }
                if singlefeatureResult[1].singlefeatureIndex[0] != -1{
                    stateResult.append(singlefeatureResult[1].coordinate)
                }
                let nextTargetArea = self.updateTargetArea(
                    coordinates: stateResult,
                    targetArea: targetArea,
                    scenario: targetAreaScenario,
                    isCameraHorizon: isCameraHorizon
                )
                guard nextTargetArea[2] > 0, nextTargetArea[3] > 0 else {
                    self.targetArea = [0, 0, 0, 0]
                    self.isTargetArea = false
                    self.activeTargetAreaScenario = .standard
                    return
                }
                self.targetArea = nextTargetArea
                
                let isShuffle = detectNum == 2 && self.shuffleMode[0] != 0 && !isSame
                let isRiffle = detectNum == 1 && self.shuffleMode[1] != 0
                
                let isCut = detectNum == 1
                    && uniqueNum == 1
                    && detectConfidence >= detectConfidenceThreshold
                    && self.detectNeedToCut
                
                if isCut{
                    self.initTargetArea = [0,0,0,0]
                    self.detectNeedToCut = false
                    
                    if self.usedSingleFeatures.contains(detectSingleFeature)
                        && self.recgReport
                        && (![3, 5, 7].contains(self.cutMode[self.shuffleOrRiffle]) || self.continueCutTimeCounter >= self.continueMaxCutTime)
                        && self.specialCard[self.shuffleOrRiffle] == 0{
//                        self.stateCounter = 100
//                        self.state = "waitingEnd"
//                        print("状态：等待结束")
                        self.reloadingTime = 0.2
                        self.computeNextRound()
                    }
                    else if self.singlefeatureArray.contains(detectSingleFeature){
                        self.stopCurrentAudio()
                        
                        var cutIndex = self.singlefeatureArray.firstIndex(of: detectSingleFeature)!
                        var isCutDone = false
                        
                        if self.cutMode[self.shuffleOrRiffle] == 0{
                            
                        }
                        else if self.cutMode[self.shuffleOrRiffle] == 1{
                            //看底
                            if self.cutStructArray.count == 0{
                                self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 0))
                                isCutDone = true
                                self.cutShowArray.append(detectSingleFeature)
                                
                                if self.specialCard[self.shuffleOrRiffle] == 0{
                                    self.isProcessNeedToCut = false
                                }
                            }
                        }
                        else if self.cutMode[self.shuffleOrRiffle] == 2{
                            //看顶
                            if self.cutStructArray.count == 0{
                                cutIndex -= 1
                                if cutIndex < 0 {
                                    cutIndex = self.singlefeatureArray.count - 1
                                }
                                self.cutStructArray.append(cutStruct(cutcardIndex: self.singlefeatureArray[cutIndex], cutMode: 1))
                                isCutDone = true
                                self.cutShowArray.append(detectSingleFeature)
                                
                                if self.specialCard[self.shuffleOrRiffle] == 0{
                                    self.isProcessNeedToCut = false
                                }
                            }
                        }
                        else if self.cutMode[self.shuffleOrRiffle] == 3{
                            //连续切牌
                            self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 0))
                            isCutDone = true
                            self.cutShowArray.append(detectSingleFeature)
                            
                            self.continueCutTimeCounter = 0
                        }
                        else if self.cutMode[self.shuffleOrRiffle] == 5{
                            // 连续看顶：每次照到的牌都指向它在当前牌序中的前一张。
                            cutIndex -= 1
                            if cutIndex < 0 {
                                cutIndex = self.singlefeatureArray.count - 1
                            }
                            self.cutStructArray.append(cutStruct(cutcardIndex: self.singlefeatureArray[cutIndex], cutMode: 1))
                            isCutDone = true
                            self.cutShowArray.append(detectSingleFeature)
                            self.continueCutTimeCounter = 0
                        }
                        else if self.cutMode[self.shuffleOrRiffle] == 6{
                            //照顶去牌：照到的牌本身不参与后续发牌及牌堆显示。
                            if self.cutStructArray.count == 0{
                                self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 5))
                                isCutDone = true
                                self.cutShowArray.append(detectSingleFeature)
                                if self.specialCard[self.shuffleOrRiffle] == 0{
                                    self.isProcessNeedToCut = false
                                }
                            }
                        }
                        else if self.cutMode[self.shuffleOrRiffle] == 7{
                            //连续照顶去牌：每次照到的顶牌都从原始牌序中移除。
                            self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 5))
                            isCutDone = true
                            self.cutShowArray.append(detectSingleFeature)
                            self.continueCutTimeCounter = 0
                        }
                        else if self.cutMode[self.shuffleOrRiffle] == 4{
                            //看手牌（切牌）
                            if self.cutStructArray.count == 0{
                                self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 4))
                                isCutDone = true
                                self.cutShowArray.append(detectSingleFeature)
                                
                                if self.specialCard[self.shuffleOrRiffle] == 0{
                                    self.isProcessNeedToCut = false
                                }
                            }
                        }
                        
                        if !isCutDone{
//                            if self.specialCard[self.shuffleOrRiffle] == 1{
//                                var cnt = 0
//                                for lastCutStrucht in self.cutStructArray{
//                                    if lastCutStrucht.cutMode == 3{
//                                        cnt += 1
//                                    }
//                                }
//                                //看手
//                                if cnt == 0{
//                                    self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 3))
//                                    isCutDone = true
//                                    self.cutShowArray.append(detectSingleFeature)
//                                    self.isProcessNeedToCut = false
//                                }
//                            }
//                            else if self.specialCard[self.shuffleOrRiffle] == 2{
//                                //看色
//                                var cnt = 0
//                                for lastCutStrucht in self.cutStructArray{
//                                    if lastCutStrucht.cutMode == 2{
//                                        cnt += 1
//                                    }
//                                }
//                                if cnt < self.getWatchColorNumber(){
//                                    self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 2))
//                                    isCutDone = true
//                                    cnt += 1
//                                }
//                                if cnt == self.getWatchColorNumber(){
//                                    self.isProcessNeedToCut = false
//                                }
//                            }
                            //连续看手
                            if self.specialCard[self.shuffleOrRiffle] == 1{
                                self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 3))
                                self.cutShowArray.append(detectSingleFeature)
                                isCutDone = true
                            }
                            //连续看色
                            else if self.specialCard[self.shuffleOrRiffle] == 2{
                                self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 2))
                                isCutDone = true
                            }
                        }
                        
                        if isCutDone{
//                            if self.recgReport{
//                                self.stateCounter = 100
//                                self.reloadingTime = 0.2
//                                self.state = "waitingEnd"
//                            }
                            self.computeWinnerRC(isReset: true)
                        }
                        
                    }
                }
                
                //Mod riffleDetectConfidenceThreshold -> detectConfidenceMinThreshold
                else if !self.isDetect && detectConfidence >= detectConfidenceMinThreshold
                            && isRiffle && uniqueNum == 1{
                    self.isDetect = true
                    self.state = "riffle"
                    self.speakText(input: 0)
                }
                
                //Mod detectConfidenceThreshold -> detectConfidenceMinThreshold
                else if !self.isDetect && minDetectConfidence >= detectConfidenceMinThreshold && isShuffle{
                    if leftDetectSingleFeature == self.stateSingleFeature[0]
                        && rightDetectSingleFeature == self.stateSingleFeature[1]
                        && uniqueNum == 2
                        && shufflePostureJudge(
                            coordinates: [singlefeatureResult[0].coordinate, singlefeatureResult[1].coordinate],
                            coordinateTargetArea: targetArea,
                            scenario: targetAreaScenario,
                            isCameraHorizon: isCameraHorizon
                        ){
                        self.shuffleStartCounter += 1
                    }
                    else{
                        self.shuffleStartCounter = 0
                    }
                    
                    if self.shuffleStartCounter >= 3{
                        self.isDetect = true
                        self.detectNeedToCut = false
                        if self.shuffleMode[0] == 2 {
                            self.activeTargetAreaScenario = .horizontalShuffle
                        }
                        self.state = "shuffle"
                        print("状态：进入洗牌")
                        
                        if self.targetAreaMove(
                            initTargetArea: self.initTargetArea,
                            targetArea: targetArea,
                            isCameraHorizon: isCameraHorizon
                        ){
                            self.speakText(input: 0)
                            self.speechPerformer.stopSpeechSynthesis()
                        }
                        
                        self.initTargetArea = targetArea
                    }
                }
                
                if self.isDetect && self.state == "shuffle" && self.targetAreaMove(
                    initTargetArea: self.initTargetArea,
                    targetArea: targetArea,
                    isCameraHorizon: isCameraHorizon
                ) && self.detectSet.count < 5{
                    self.shuffleResetCounter += 1
                }
                else if self.isDetect && self.state == "shuffle" && (detectNum != 2 || minDetectConfidence < confidenceThreshold) && self.detectSet.count < 5{
                    self.shuffleResetCounter += 1
                }
                else if self.isDetect && self.state == "shuffle"{
                    self.shuffleResetCounter = 0
                }
                
                      
                if self.stateCounter >= 5{
                    self.isTargetArea = false
                    self.targetArea = [0,0,0,0]
                    self.stateCounter = 0
                    print("状态：切换为检测")
                }
                else if self.shuffleResetCounter > 5{
                    self.initDetectResult()
                }
                
                //识别过程
                else if taskIndex >= 0 && self.isDetect{
                    if minDetectConfidence >= detectConfidenceThreshold
                        && isShuffle
                        && self.state == "riffle"
                        && leftDetectSingleFeature == self.stateSingleFeature[0]
                        && rightDetectSingleFeature == self.stateSingleFeature[1]{
                        if self.shuffleMode[0] == 2 {
                            self.activeTargetAreaScenario = .horizontalShuffle
                        }
                        self.state = "shuffle"
                    }
                    
                    if (self.state == "riffle" && leftConfidence > 0.7 && detectNum == 1) || (self.state == "shuffle" && leftConfidence > 0.5){
                        self.detectSet.insert(leftDetectSingleFeature)
                    }
                    if (self.state == "riffle" && rightConfidence > 0.7 && detectNum == 1) || (self.state == "shuffle" && rightConfidence > 0.5){
                        self.detectSet.insert(rightDetectSingleFeature)
                    }
                    
                    if self.detectSet.count >= 5
                    {
                        self.initTargetArea = self.targetArea
                    }
                    if self.detectSet.count >= 8
                    {
                        self.speechPerformer.stopSpeechSynthesis()
                    }
                    
                    self.detectResultList[taskIndex] = singlefeatureResult
                    
                    var stateResult : [[Float]] = []
                    
                    if self.state == "shuffle" && leftDetectSingleFeature != -1 && rightDetectSingleFeature != -1{
                        stateResult.append(singlefeatureResult[0].coordinate)
                        stateResult.append(singlefeatureResult[1].coordinate)
                        let nextTargetArea = self.updateTargetArea(
                            coordinates: stateResult,
                            targetArea: targetArea,
                            scenario: targetAreaScenario,
                            isCameraHorizon: isCameraHorizon
                        )
                        guard nextTargetArea[2] > 0, nextTargetArea[3] > 0 else {
                            self.targetArea = [0, 0, 0, 0]
                            self.isTargetArea = false
                            self.activeTargetAreaScenario = .standard
                            return
                        }
                        self.targetArea = nextTargetArea
                    }
                    else if self.state == "riffle" && detectConfidence >= detectConfidenceMinThreshold{
                        if leftDetectSingleFeature != -1{
                            stateResult.append(singlefeatureResult[0].coordinate)
                        }
                        if rightDetectSingleFeature != -1{
                            stateResult.append(singlefeatureResult[1].coordinate)
                        }
                        
                        let nextTargetArea = self.updateTargetArea(
                            coordinates: stateResult,
                            targetArea: targetArea,
                            scenario: targetAreaScenario,
                            isCameraHorizon: isCameraHorizon
                        )
                        guard nextTargetArea[2] > 0, nextTargetArea[3] > 0 else {
                            self.targetArea = [0, 0, 0, 0]
                            self.isTargetArea = false
                            self.activeTargetAreaScenario = .standard
                            return
                        }
                        self.targetArea = nextTargetArea
                    }
                }
            }
            else if !self.isTargetArea && !isTargetArea{
                if self.stateCounter >= 5{
                    print("状态：退出检测")
                    
                    let detectState = self.handleDetecResultList(targetDetecResultList: self.detectResultList)
                    
                    if !detectState.isSingle && !detectState.isShort && self.shuffleMode[0] != 0{
                        //洗牌
                        self.shuffleOrRiffle = 0
                        self.initShuffle()
                        self.singlefeatureArray = detectState.detectionResult
                        self.remoteRecomputableDeck = detectState.detectionResult
                        
                        if self.singlefeatureArray.count == self.allSingleFeatureIndex.count{
                            self.speakText(input: 1)
                        }
                        else{
                            self.speakText(input: 2)
                        }
                        
                        if self.cutMode[0] == 0  && self.specialCard[0] == 0{
//                            if self.recgReport{
//                                self.reloadingTime = 1
//                            }
                            self.computeWinnerRC(isReset: true)
                        }
                        else{
                            self.emitRemoteDeckPreview()
                            showShuffleTimeText()
                        }
                    }
                    else if detectState.isSingle && !detectState.isShort && self.shuffleMode[1] != 0{
                        //拨牌
                        self.shuffleOrRiffle = 1
                        self.initShuffle()
                        self.singlefeatureArray = detectState.detectionResult
                        self.remoteRecomputableDeck = detectState.detectionResult
                        
                        if self.shuffleMode[1] == 1{
                            //拨到顶
                            if self.cutMode[1] != 0 || self.specialCard[1] != 0{
                                if self.singlefeatureArray.count == self.allSingleFeatureIndex.count{
                                    self.speakText(input: 1)
                                }
                                else{
                                    self.speakText(input: 2)
                                }
                            }
                        }
                        
                        else if self.shuffleMode[1] == 2 && self.singlefeatureArray.count - 1 >= self.minSingleFeatureNum{
                            //拨中间
                            if self.singlefeatureArray.count > 0{
                                self.singlefeatureArray.append(self.singlefeatureArray[0])
                                self.singlefeatureArray.remove(at: 0)
                            }
                            
                            if self.cutMode[1] != 0 || self.specialCard[1] != 0{
                                if self.singlefeatureArray.count == self.allSingleFeatureIndex.count{
                                    self.speakText(input: 1)
                                }
                                else{
                                    self.speakText(input: 2)
                                }
                            }
                        }
                        
                        
                        if self.cutMode[1] == 0 && self.specialCard[1] == 0{
//                            if self.recgReport{
//                                self.reloadingTime = 1
//                            }
                            self.computeWinnerRC(isReset: true)
                        }
                        else{
                            self.emitRemoteDeckPreview()
                            showShuffleTimeText()
                        }
                    }
                    
                    if !detectState.isShort && self.reloadingTime == 0{
                        self.reloadingTime = 0.2
                    }
                    
                    self.quitDetect(reloadingTime: self.reloadingTime)
                }
                else if ((detectNum == 1 && (self.shuffleMode[1] != 0
                                             || self.detectNeedToCut
                                             || self.shuffleMode[0] == 2))
                    || (detectNum == 2 && self.shuffleMode[0] != 0))
                    && self.state != "waitingEnd"{
                    
                    var stateResult : [[Float]] = []
                    if singlefeatureResult[0].singlefeatureIndex[0] != -1{
                        stateResult.append(singlefeatureResult[0].coordinate)
                    }
                    if singlefeatureResult[1].singlefeatureIndex[0] != -1{
                        stateResult.append(singlefeatureResult[1].coordinate)
                    }
                    
                    self.activeTargetAreaScenario = self.resolveTargetAreaScenario(boxCount: stateResult.count)
                    self.targetArea = self.computeTargetArea(
                        stateResult: stateResult,
                        scenario: self.activeTargetAreaScenario,
                        isCameraHorizon: isCameraHorizon
                    )
                    guard self.targetArea[2] > 0, self.targetArea[3] > 0 else {
                        self.activeTargetAreaScenario = .standard
                        return
                    }
                    self.isTargetArea = true

                    if (detectNum == 2 && self.shuffleMode[0] != 0)
                    && self.targetAreaMove(
                        initTargetArea: self.initTargetArea,
                        targetArea: self.targetArea,
                        isCameraHorizon: isCameraHorizon
                    ){
                        //防止切牌语音被重进识别打断
                        //如果两个框距离小于一定范围，不直接响，等洗牌判定再响
                        //这个范围需要够大，使切牌不响
                        //这个范围需要够小，能识别出正常洗牌
                        //即切牌两个框范围<判定范围<洗牌正常识别范围
                        if !self.judgeCutRange(
                            stateResult: stateResult,
                            isCameraHorizon: isCameraHorizon
                        ){
                            self.speakText(input: 0)
                            self.speechPerformer.stopSpeechSynthesis()
                            self.initTargetArea = self.targetArea
                        }
                    }
                    
                    self.initDetectResult()
                    
                    self.state = "detecting"
                    self.remoteAwaitingShuffle = false
                    self.remoteSourceBridge?.updateControlState(recognitionPaused: false, awaitingShuffle: false)
                    print("状态：重新进入识别")
                }
                else{
                    if detectNum == 0{
                        self.stateCounter += 1
                    }
                    else{
                        self.stateCounter = 0
                    }
                }
            }
        }
        
//        if self.state == "riffle" {
//            let modelCIImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let cgImage = CIContext().createCGImage(modelCIImage, from: modelCIImage.extent)
//            let savedUIImage = UIImage(cgImage: cgImage!)
//            UIImageWriteToSavedPhotosAlbum(savedUIImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
//            print("image task \(taskIndex) saved \(self.saveOrderIndex)")
//            self.saveOrderIndex += 1
//        }
    }
    
    private func quitDetect(reloadingTime: Double){
        self.stateCounter = 0
        self.changeCameraFrameRate(to: self.idleRate)
        self.initBoxes()
        self.initDetectResult()
        
        if reloadingTime == 0{
            self.state = "idle"
        }
        else{
            self.state = "reloading"
            DispatchQueue.main.asyncAfter(deadline: .now() + reloadingTime) {
                if(self.state == "reloading"){
                    self.state = "idle"
                }
            }
        }
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            // print("保存图片到相册失败: \(error)")
        } else {
            // print("图片保存成功")
        }
    }
    
    
    // MARK: handle result list
    func handleDetecResultList(targetDetecResultList: [Int : [DetectionResult]]) -> DetectionState{
        
        var confidenceDic : [Int:Float] = [:]
        for key in self.allSingleFeatureIndex {
            confidenceDic[key] = 0
        }
        
        var sortedKeys = targetDetecResultList.keys.sorted()
        let blurThreshold : Float = 0.75
        let longHeadIndex = 2
        
        // print("检测sortedKeys \(sortedKeys)")
        
        if sortedKeys.count <= 1{
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }
        
        var longestIndex: Int = -1
        
        var deleteKeys:[Int] = []
        //去除重复帧
        for keyIndex in 0..<sortedKeys.count-1{
            
            let detectResultListIndex = sortedKeys[keyIndex]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let nowLaplacian = targetDetecResultList[detectResultListIndex]![numIndex].laplacianVariance
                let nextLaplacian = targetDetecResultList[nextDetectResultListIndex]![numIndex].laplacianVariance
                let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                let nextNum = targetDetecResultList[nextDetectResultListIndex]![numIndex].singlefeatureIndex[0]
                
                if abs(nowLaplacian - nextLaplacian) <= 0.000000001 && nowNum == nextNum{
                    deleteKeys.append(detectResultListIndex)
                }
            }
            
//            let nowConfidence0 = targetDetecResultList[detectResultListIndex]![0].confidence[0]
//            let nowConfidence1 = targetDetecResultList[detectResultListIndex]![1].confidence[0]
//            if nowConfidence0 < 0.1 && nowConfidence1 < 0.1{
//                deleteKeys.append(detectResultListIndex)
//            }
            
            
            
            let dRNode0 = targetDetecResultList[detectResultListIndex]![0]
            let dRNode1 = targetDetecResultList[detectResultListIndex]![1]
            
            let nowN0 = dRNode0.singlefeatureIndex[0]
            let nowN1 = dRNode1.singlefeatureIndex[0]
            
//                        print("index ", detectResultListIndex,
//                              singlefeatureLabelDic[nowN0] ?? "none", dRNode0.nodeType, dRNode0.laplacianVariance, dRNode0.confidence[0], detectResultListIndex,
//                              singlefeatureLabelDic[nowN1] ?? "none", dRNode1.nodeType, dRNode1.laplacianVariance, dRNode1.confidence[0])
        }
        
        sortedKeys = sortedKeys.filter { !deleteKeys.contains($0) }
        
        var beginIndex = 2
        var endIndex = sortedKeys.count-3
        
        
        if beginIndex >= endIndex{
            print("return1")
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                if nowNum != -1
                    && targetDetecResultList[nextDetectResultListIndex]![numIndex].singlefeatureIndex[0] == nowNum
                    && confidenceDic.keys.contains(nowNum){
                    targetDetecResultList[detectResultListIndex]![numIndex].nodeType += 1
                    targetDetecResultList[nextDetectResultListIndex]![numIndex].nodeType += 2
                }
            }
        }
        
        var leftSideSet = Set<Int>()
        var rightSideSet = Set<Int>()
        
        var leftFirstHead = -1
        var rightFirstHead = -1
        
        var leftLastTail = -1
        var rightLastTail = -1
        
        var leftTailCnt = 0
        var rightTailCnt = 0
        
        var leftTailLong = -1
        var rightTailLong = -1
        
        var singleCnt = 0
        var doubleCnt = 0
        
        endIndex += 1
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let lastDetectResultListIndex = sortedKeys[keyIndex-1]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            let nextnextDetectResultListIndex = sortedKeys[keyIndex+2]
            
            let detectResultNode0 = targetDetecResultList[detectResultListIndex]![0]
            let detectResultNode1 = targetDetecResultList[detectResultListIndex]![1]
            
            let lastDetectResultNode0 = targetDetecResultList[lastDetectResultListIndex]![0]
            let lastDetectResultNode1 = targetDetecResultList[lastDetectResultListIndex]![1]
            
            let nextDetectResultNode0 = targetDetecResultList[nextDetectResultListIndex]![0]
            let nextDetectResultNode1 = targetDetecResultList[nextDetectResultListIndex]![1]
            
            let nextnextDetectResultNode0 = targetDetecResultList[nextnextDetectResultListIndex]![0]
            let nextnextDetectResultNode1 = targetDetecResultList[nextnextDetectResultListIndex]![1]
            
            let nowNum0 = targetDetecResultList[detectResultListIndex]![0].singlefeatureIndex[0]
            let nodeType0 = targetDetecResultList[detectResultListIndex]![0].nodeType
            let nowNum1 = targetDetecResultList[detectResultListIndex]![1].singlefeatureIndex[0]
            let nodeType1 = targetDetecResultList[detectResultListIndex]![1].nodeType
            
            //            print("index ", keyIndex,
            //                  singlefeatureLabelDic[nowNum0] ?? "none", detectResultNode0.nodeType, detectResultNode0.laplacianVariance, detectResultNode0.confidence[0], detectResultListIndex,
            //                  singlefeatureLabelDic[nowNum1] ?? "none", detectResultNode1.nodeType, detectResultNode1.laplacianVariance, detectResultNode1.confidence[0])
            
            if targetDetecResultList[detectResultListIndex]![0].singlefeatureIndex[0] != -1
                && targetDetecResultList[detectResultListIndex]![1].singlefeatureIndex[0] != -1{
                doubleCnt += 1
            }
            else{
                singleCnt += 1
            }
            
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                
                if detectResultNode.nodeType == 1{
                    if numIndex == 0{
                        leftSideSet.insert(detectResultNode.singlefeatureIndex[0])
                    }
                    else{
                        rightSideSet.insert(detectResultNode.singlefeatureIndex[0])
                    }
                }
                
                if detectResultNode.nodeType == 3{
                    if numIndex == 0{
                        if leftFirstHead == -1 && keyIndex > longHeadIndex{
                            leftFirstHead = keyIndex
                        }
                        leftTailCnt += 1
                    }
                    if numIndex == 1{
                        if rightFirstHead == -1 && keyIndex > longHeadIndex{
                            rightFirstHead = keyIndex
                        }
                        rightTailCnt += 1
                    }
                }
                
                if detectResultNode.nodeType == 2{
                    if numIndex == 0{
                        leftLastTail = keyIndex
                        if leftTailCnt >= 3{
                            leftTailLong = keyIndex
                        }
                        leftTailCnt = 0
                    }
                    if numIndex == 1{
                        rightLastTail = keyIndex
                        if rightTailCnt >= 2{
                            rightTailLong = keyIndex
                        }
                        rightTailCnt = 0
                    }
                }
            }
        }
        
        var leftSideCnt = leftSideSet.count
        var rightSideCnt = rightSideSet.count
        
        var isSingle = true
        if  doubleCnt > singleCnt{
            isSingle = false
        }
        
        var isShort = true
        if leftSideCnt + rightSideCnt >= min(minSingleFeatureNum, 15){
            isShort = false
        }
        
        if !isShort{
            //如果两侧都有 则要找到两侧都是链的时候开始 即两侧都是3
            //Mod add targetDetecResultList[detectResultListIndex]![0].confidence[0] >= 0.8
            if !isSingle
            {
                beginIndex = longHeadIndex
                for keyIndex in beginIndex..<endIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    if targetDetecResultList[detectResultListIndex]![0].nodeType == 3
                        && targetDetecResultList[detectResultListIndex]![1].nodeType == 3
                        && targetDetecResultList[detectResultListIndex]![0].confidence[0] >= 0.8
                        && targetDetecResultList[detectResultListIndex]![1].confidence[0] >= 0.8{
                        beginIndex = keyIndex
                        break
                    }
                }
                
                print("tail \(leftLastTail) \(rightLastTail)")
                endIndex = max(leftLastTail, rightLastTail) + 1
            }
            else if leftSideCnt > rightSideCnt && leftFirstHead != -1{
                beginIndex = leftFirstHead
                endIndex = leftTailLong + 1
            }
            else if leftSideCnt < rightSideCnt && rightFirstHead != -1{
                beginIndex = rightFirstHead
                endIndex = rightTailLong + 1
            }
        }
        
        if beginIndex >= endIndex{
            print("return2")
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                if (detectResultNode.nodeType == 1 ||
                    detectResultNode.nodeType == 2 ||
                    detectResultNode.nodeType == 3)
                    && detectResultNode.confidence[0] > 0.7{
                    confidenceDic[detectResultNode.singlefeatureIndex[0]] = 100
                }
            }
        }
        
        for _ in 0..<3{
            for key in confidenceDic.keys{
                
                if confidenceDic[key] == 100{
                    for numIndex in 0..<2{
                        
                        var end = -1
                        var head = -1
                        
                        for keyIndex in beginIndex..<endIndex{
                            let detectResultListIndex = sortedKeys[keyIndex]
                            let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                            if nowNum == key && targetDetecResultList[detectResultListIndex]![numIndex].nodeType == 2{
                                end = keyIndex
                            }
                            else if nowNum == key
                                        && targetDetecResultList[detectResultListIndex]![numIndex].nodeType == 1
                                        && end != -1{
                                head = keyIndex
                                
                                let isClose = head - end <= 3
                                
                                var isSameNum = head - end <= 5
                                var middleNum = -1
                                for updateIndex in end+1...head-1{
                                    let updateNodeIndex = sortedKeys[updateIndex]
                                    let currentMiddleNum = targetDetecResultList[updateNodeIndex]![numIndex].singlefeatureIndex[0]
                                    if currentMiddleNum != -1{
                                        middleNum = currentMiddleNum
                                        break
                                    }
                                }
                                for updateIndex in end+1...head-1{
                                    let updateNodeIndex = sortedKeys[updateIndex]
                                    let currentMiddleNum = targetDetecResultList[updateNodeIndex]![numIndex].singlefeatureIndex[0]
                                    if currentMiddleNum != -1 && currentMiddleNum != middleNum{
                                        isSameNum = false
                                        break
                                    }
                                }
                                
                                if isClose || isSameNum{
                                    for updateIndex in end...head{
                                        let updateNodeIndex = sortedKeys[updateIndex]
                                        targetDetecResultList[updateNodeIndex]![numIndex].singlefeatureIndex[0] = nowNum
                                        targetDetecResultList[updateNodeIndex]![numIndex].nodeType = 3
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        for key in confidenceDic.keys{
            if confidenceDic[key] == 100{
                var isChain = false
                for keyIndex in beginIndex..<endIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                        let nodeType = targetDetecResultList[detectResultListIndex]![numIndex].nodeType
                        if nowNum == key && nodeType == 2 {
                            isChain = true
                        }
                    }
                    if isChain{
                        break
                    }
                }
                if !isChain{
                    confidenceDic[key] = 0
                }
            }
        }
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                
                if detectResultNode.nodeType == 0
                    && detectResultNode.singlefeatureIndex[0] != -1{
                    
                    var newSingleFeatureIndex : [Int] = []
                    var newConfidence : [Float] = []
                    for i in 0..<detectResultNode.singlefeatureIndex.count{
                        let currentNum = detectResultNode.singlefeatureIndex[i]
                        if confidenceDic.keys.contains(currentNum){
                            if confidenceDic[currentNum] == 0{
                                newSingleFeatureIndex.append(detectResultNode.singlefeatureIndex[i])
                                newConfidence.append(detectResultNode.confidence[i])
                            }
                        }
                    }
                    
                    if newSingleFeatureIndex.count == 0{
                        newSingleFeatureIndex.append(-1)
                        newConfidence.append(1)
                        detectResultNode.nodeType = 5
                    }
                    
                    detectResultNode.singlefeatureIndex = newSingleFeatureIndex
                    detectResultNode.confidence = newConfidence
                }
            }
        }
        
        leftLastTail = -1
        rightLastTail = -1
        
        leftTailCnt = 0
        rightTailCnt = 0
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                
                if detectResultNode.nodeType == 2{
                    if numIndex == 0{
                        leftLastTail = keyIndex
                    }
                    if numIndex == 1{
                        rightLastTail = keyIndex
                    }
                }
            }
        }
        
        var addEndIndex = 0
        
        if !isSingle{
            endIndex = max(leftLastTail, rightLastTail) + 1
            addEndIndex = min(leftLastTail, rightLastTail)
        }
        else if leftSideCnt > rightSideCnt{
            endIndex = leftTailLong + 1
            addEndIndex = leftTailLong
        }
        else if leftSideCnt < rightSideCnt{
            endIndex = rightTailLong + 1
            addEndIndex = rightTailLong
        }
        
        if beginIndex >= endIndex{
            print("return3")
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }
        
        if addEndIndex <= beginIndex{
            addEndIndex = beginIndex + 1
        }
        
        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                var nodeIndex : [Int] = []
                for keyIndex in beginIndex..<addEndIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    
                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                        let confidence = targetDetecResultList[detectResultListIndex]![numIndex].confidence[0]
                        if nowNum == key && confidence > confidenceDic[nowNum]! {
                            confidenceDic[nowNum] = confidence
                            nodeIndex = [detectResultListIndex, numIndex]
                        }
                    }
                }
                if nodeIndex.count > 0 && (addCardMode==1 || confidenceDic[key]! > 0.7){
                    targetDetecResultList[nodeIndex[0]]![nodeIndex[1]].nodeType = 4
                }
            }
        }
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                
                if detectResultNode.nodeType == 0
                    && detectResultNode.singlefeatureIndex[0] != -1{
                    
                    var newSingleFeatureIndex : [Int] = []
                    var newConfidence : [Float] = []
                    for i in 0..<detectResultNode.singlefeatureIndex.count{
                        if confidenceDic[i] == 0{
                            newSingleFeatureIndex.append(detectResultNode.singlefeatureIndex[i])
                            newConfidence.append(detectResultNode.confidence[i])
                        }
                    }
                    
                    if newSingleFeatureIndex.count == 0{
                        newSingleFeatureIndex.append(-1)
                        newConfidence.append(1)
                        detectResultNode.nodeType = 5//所有可能的数字去除，标记为融合牌
                    }
                    
                    detectResultNode.singlefeatureIndex = newSingleFeatureIndex
                    detectResultNode.confidence = newConfidence
                }
            }
        }
        
        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                var nodeIndex : [Int] = []
                for keyIndex in beginIndex..<addEndIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    
                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                        let confidence = targetDetecResultList[detectResultListIndex]![numIndex].confidence[0]
                        if nowNum == key && confidence > confidenceDic[nowNum]! {
                            confidenceDic[nowNum] = confidence
                            nodeIndex = [detectResultListIndex, numIndex]
                        }
                    }
                }
                if nodeIndex.count > 0 && (addCardMode==1 || confidenceDic[key]! > 0.7){
                    targetDetecResultList[nodeIndex[0]]![nodeIndex[1]].nodeType = 4
                }
            }
        }
        
        let isCut = isShort && isSingle
        
        //统计标准模糊度(非切牌下）
        if !isCut{
            for keyIndex in beginIndex..<endIndex{
                let detectResultListIndex = sortedKeys[keyIndex]
                for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                    let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                    if detectResultNode.nodeType == 3{
                        if self.laplacianDic[numIndex][detectResultNode.singlefeatureIndex[0]] == 0{
                            self.laplacianDic[numIndex][detectResultNode.singlefeatureIndex[0]] = detectResultNode.laplacianVariance
                        }
                        else{
                            self.laplacianDic[numIndex][detectResultNode.singlefeatureIndex[0]]! += detectResultNode.laplacianVariance
                            self.laplacianDic[numIndex][detectResultNode.singlefeatureIndex[0]]! /= 2
                        }
                    }
                }
            }
        }
        
        let isShuffle = self.shuffleMode[0] != 0 && !isSingle && !isShort
        
        var lostNum = 0
        var addNum = 0
        
        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                lostNum += 1
            }
        }
        
        //补牌
        if addCardMode==1 && isShuffle && beginIndex < addEndIndex && lostNum <= 2{
            
            let numIndexList : [Int] = [0, 1]
            
            for key in confidenceDic.keys{
                if confidenceDic[key] == 0{
                    
                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        let nextDetectResultListIndex = sortedKeys[keyIndex+1]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                            if detectResultNode.nodeType == 5 && nextDetectResultNode.nodeType == 5{
                                detectResultNode.singlefeatureIndex[0] = key
                                nextDetectResultNode.singlefeatureIndex[0] = key
                                detectResultNode.nodeType = 1
                                nextDetectResultNode.nodeType = 2
                                confidenceDic[key] = 1
                                break
                            }
                        }
                        
                        if confidenceDic[key] != 0{
                            break
                        }
                    }
                    
                    if confidenceDic[key] != 0{
                        addNum += 1
                        continue
                    }
                    
                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        let nextDetectResultListIndex = sortedKeys[keyIndex+1]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                            if (detectResultNode.nodeType == 0 || nextDetectResultNode.nodeType == 5)
                                && (detectResultNode.nodeType == 5 || nextDetectResultNode.nodeType == 0){
                                detectResultNode.singlefeatureIndex[0] = key
                                nextDetectResultNode.singlefeatureIndex[0] = key
                                detectResultNode.nodeType = 1
                                nextDetectResultNode.nodeType = 2
                                confidenceDic[key] = 1
                                break
                            }
                        }
                        
                        if confidenceDic[key] != 0{
                            break
                        }
                    }
                    
                    if confidenceDic[key] != 0{
                        addNum += 1
                        continue
                    }
                    
                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        let nextDetectResultListIndex = sortedKeys[keyIndex+1]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                            if detectResultNode.nodeType == 5{
                                detectResultNode.singlefeatureIndex[0] = key
                                detectResultNode.nodeType = 4
                                confidenceDic[key] = 1
                                break
                            }
                        }
                        
                        if confidenceDic[key] != 0{
                            break
                        }
                    }
                    
                    if confidenceDic[key] != 0{
                        addNum += 1
                        continue
                    }
                    
                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        let nextDetectResultListIndex = sortedKeys[keyIndex+1]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                            if detectResultNode.nodeType == 0{
                                detectResultNode.singlefeatureIndex[0] = key
                                detectResultNode.nodeType = 4
                                confidenceDic[key] = 1
                                break
                            }
                        }
                        
                        if confidenceDic[key] != 0{
                            break
                        }
                    }
                    
                    if confidenceDic[key] != 0{
                        addNum += 1
                        continue
                    }
                }
            }
        }
        
        //补链头尾
        for keyIndex in beginIndex..<addEndIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let lastDetectResultListIndex = sortedKeys[keyIndex-1]
            let lastlastDetectResultListIndex = sortedKeys[keyIndex-2]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            let nextnextDetectResultListIndex = sortedKeys[keyIndex+2]

            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                let sideDetectResultNode = targetDetecResultList[detectResultListIndex]![1-numIndex]
                let lastDetectResultNode = targetDetecResultList[lastDetectResultListIndex]![numIndex]
                let lastlastDetectResultNode = targetDetecResultList[lastlastDetectResultListIndex]![numIndex]
                let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                let nextnextDetectResultNode = targetDetecResultList[nextnextDetectResultListIndex]![numIndex]

                if (detectResultNode.nodeType == 5 || detectResultNode.nodeType == 0)
                    && sideDetectResultNode.nodeType == 2
                    && detectResultNode.laplacianVariance < lastDetectResultNode.laplacianVariance{

                    if lastDetectResultNode.nodeType == 2
                        && lastDetectResultNode.laplacianVariance / lastlastDetectResultNode.laplacianVariance > blurThreshold
                        && detectResultNode.laplacianVariance / lastDetectResultNode.laplacianVariance < blurThreshold{
                        lastDetectResultNode.nodeType = 3
                        detectResultNode.nodeType = 2
                        detectResultNode.singlefeatureIndex[0] = lastDetectResultNode.singlefeatureIndex[0]

                    }

                    else if lastDetectResultNode.nodeType == 4{
                        lastDetectResultNode.nodeType = 1
                        detectResultNode.nodeType = 2
                        detectResultNode.singlefeatureIndex[0] = lastDetectResultNode.singlefeatureIndex[0]
                    }

                }

                if (detectResultNode.nodeType == 5 || detectResultNode.nodeType == 0)
                    && sideDetectResultNode.nodeType == 1
                    && detectResultNode.laplacianVariance < nextDetectResultNode.laplacianVariance{

                    if nextDetectResultNode.nodeType == 1
                        && nextDetectResultNode.laplacianVariance / nextnextDetectResultNode.laplacianVariance > blurThreshold
                        && detectResultNode.laplacianVariance / nextDetectResultNode.laplacianVariance < blurThreshold{
                        nextDetectResultNode.nodeType = 3
                        detectResultNode.nodeType = 1
                        detectResultNode.singlefeatureIndex[0] = nextDetectResultNode.singlefeatureIndex[0]

                    }

                    else if nextDetectResultNode.nodeType == 4{
                        nextDetectResultNode.nodeType = 2
                        detectResultNode.nodeType = 1
                        detectResultNode.singlefeatureIndex[0] = nextDetectResultNode.singlefeatureIndex[0]
                    }

                }
            }
        }
        
        var detectSingleFeatureArray : [InsertCard] = []
        
        var noneCnt = 0
        var headCnt = 0
        var tailCnt = 0
        
        // print("isSingle:\(isSingle) isShort:\(isShort) leftHead:\(leftFirstHead) rightHead:\(rightFirstHead)  leftTail:\(leftLastTail) rightTail:\(rightLastTail) endIndex:\(endIndex)")
        
        var chainConfidence0:Float = 0
        var chainConfidence1:Float = 0
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let lastDetectResultListIndex = sortedKeys[keyIndex-1]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            let nextnextDetectResultListIndex = sortedKeys[keyIndex+2]
            if targetDetecResultList[detectResultListIndex]!.count == 2{
                
                
                let detectResultNode0 = targetDetecResultList[detectResultListIndex]![0]
                let detectResultNode1 = targetDetecResultList[detectResultListIndex]![1]
                
                let lastDetectResultNode0 = targetDetecResultList[lastDetectResultListIndex]![0]
                let lastDetectResultNode1 = targetDetecResultList[lastDetectResultListIndex]![1]
                
                let nextDetectResultNode0 = targetDetecResultList[nextDetectResultListIndex]![0]
                let nextDetectResultNode1 = targetDetecResultList[nextDetectResultListIndex]![1]
                
                let nextnextDetectResultNode0 = targetDetecResultList[nextnextDetectResultListIndex]![0]
                let nextnextDetectResultNode1 = targetDetecResultList[nextnextDetectResultListIndex]![1]
                
                let nowNum0 = targetDetecResultList[detectResultListIndex]![0].singlefeatureIndex[0]
                let nodeType0 = targetDetecResultList[detectResultListIndex]![0].nodeType
                let nowNum1 = targetDetecResultList[detectResultListIndex]![1].singlefeatureIndex[0]
                let nodeType1 = targetDetecResultList[detectResultListIndex]![1].nodeType
                
                print("index ", detectResultListIndex,
                      singlefeatureLabelDic[nowNum0] ?? "none", "type\(detectResultNode0.nodeType)", detectResultNode0.laplacianVariance, detectResultNode0.confidence[0], detectResultNode0.singlefeatureIndex.count, "     ",
                      singlefeatureLabelDic[nowNum1] ?? "none", "type\(detectResultNode1.nodeType)", detectResultNode1.laplacianVariance, detectResultNode1.confidence[0], detectResultNode1.singlefeatureIndex.count)
                
                chainConfidence0 = max(chainConfidence0, detectResultNode0.confidence[0])
                chainConfidence1 = max(chainConfidence1, detectResultNode1.confidence[0])
                
                var insertCard0 = InsertCard(cardIndex: nowNum0, confidence: chainConfidence0)
                var insertCard1 = InsertCard(cardIndex: nowNum1, confidence: chainConfidence1)
                
                if nodeType0 != 1 && nodeType0 != 3{
                    chainConfidence0 = 0
                }
                
                if nodeType1 != 1 && nodeType1 != 3{
                    chainConfidence1 = 0
                }
                
                if isSingle{
                    if nodeType0 == 2{
                        detectSingleFeatureArray.insert(insertCard0, at: 0)
                    }
                    else if nodeType0 == 4
                            && nowNum0 != -1
                            && detectResultNode0.confidence[0] > 0.75
                            && detectResultNode0.confidence.count <= 6
                    {
                        detectSingleFeatureArray.insert(insertCard0, at: 0)
                    }
//                    else if (nodeType0 == 0 || nodeType0 == 4)
//                                && nowNum0 != -1
//                                && detectResultNode0.confidence[0] > 0.7
//                    {
//                        var confidenceFlag = 0
//                        var blurFlag = 0
//
//                        if detectResultNode0.laplacianVariance < lastDetectResultNode0.laplacianVariance * 0.5
//                            && detectResultNode0.laplacianVariance < nextDetectResultNode0.laplacianVariance * 0.5{
//                            blurFlag += 1
//                        }
//
//                        if detectResultNode0.confidence[0] > lastDetectResultNode0.confidence[0] && detectResultNode0.laplacianVariance > lastDetectResultNode0.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode0.confidence[0] > nextDetectResultNode0.confidence[0]
//                            && detectResultNode0.laplacianVariance > nextDetectResultNode0.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if lastDetectResultNode0.confidence[0] < 0.7 && lastDetectResultNode0.nodeType != 2{
//                            confidenceFlag += 1
//                        }
//                        if nextDetectResultNode0.confidence[0] < 0.7 && nextDetectResultNode0.nodeType != 1{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode0.laplacianVariance > lastDetectResultNode0.laplacianVariance
//                            && detectResultNode0.laplacianVariance > nextDetectResultNode0.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode0.confidence[0] > lastDetectResultNode0.confidence[0]
//                            && detectResultNode0.confidence[0] > nextDetectResultNode0.confidence[0]
//                            && blurFlag == 0{
//                            confidenceFlag += 1
//                        }
//
//                        if confidenceFlag >= 1{
//                            detectSingleFeatureArray.insert(insertCard0, at: 0)
//                        }
//                    }
                    
                    if nodeType1 == 2 || nodeType1 == 4{
                        detectSingleFeatureArray.insert(insertCard1, at: 0)
                    }
                    else if nodeType1 == 4
                            && nowNum1 != -1
                            && detectResultNode1.confidence[0] > 0.7
                            && detectResultNode1.confidence.count <= 10
                    {
                        detectSingleFeatureArray.insert(insertCard1, at: 0)
                    }
//                    else if (nodeType1 == 0 || nodeType1 == 4)
//                                && nowNum1 != -1
//                                && detectResultNode1.confidence[0] > 0.7
//                    {
//                        var confidenceFlag = 0
//                        var blurFlag = 0
//
//                        if detectResultNode1.laplacianVariance < lastDetectResultNode1.laplacianVariance * 0.5
//                            && detectResultNode1.laplacianVariance < nextDetectResultNode1.laplacianVariance * 0.5{
//                            blurFlag += 1
//                        }
//
//                        if detectResultNode1.confidence[0] > lastDetectResultNode1.confidence[0] && detectResultNode1.laplacianVariance > lastDetectResultNode1.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode1.confidence[0] > nextDetectResultNode1.confidence[0]
//                            && detectResultNode1.laplacianVariance > nextDetectResultNode1.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if lastDetectResultNode1.confidence[0] < 0.7 && lastDetectResultNode1.nodeType != 2{
//                            confidenceFlag += 1
//                        }
//                        if nextDetectResultNode1.confidence[0] < 0.7 && nextDetectResultNode1.nodeType != 1{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode1.laplacianVariance > lastDetectResultNode1.laplacianVariance
//                            && detectResultNode1.laplacianVariance > nextDetectResultNode1.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode1.confidence[0] > lastDetectResultNode1.confidence[0]
//                            && detectResultNode1.confidence[0] > nextDetectResultNode1.confidence[0]
//                            && blurFlag == 0{
//                            confidenceFlag += 1
//                        }
//
//                        if confidenceFlag >= 1{
//                            detectSingleFeatureArray.insert(insertCard1, at: 0)
//                        }
//                    }
                }
                else{
                    if (nodeType0 == 2 || nodeType0 == 4)
                        && (nodeType1 == 2 || nodeType1 == 4){
                        
                        var leftLaplacianPercent : Float = 1
                        var rightLaplacianPercent : Float = 1
                        
                        if nodeType0 == 2{
                            leftLaplacianPercent = detectResultNode0.laplacianVariance / lastDetectResultNode0.laplacianVariance
                        }
                        else if nodeType0 == 4 && self.laplacianDic[0][nowNum0] != 0{
                            leftLaplacianPercent = detectResultNode0.laplacianVariance / self.laplacianDic[0][nowNum0]!
                        }
                        
                        if nodeType1 == 2{
                            rightLaplacianPercent = detectResultNode1.laplacianVariance / lastDetectResultNode1.laplacianVariance
                        }
                        else if nodeType1 == 4 && self.laplacianDic[1][nowNum1] != 0{
                            rightLaplacianPercent = detectResultNode1.laplacianVariance / self.laplacianDic[1][nowNum1]!
                        }
                        
                        if nextDetectResultNode0.nodeType == 5 && nextDetectResultNode1.nodeType != 5{
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                        }
                        else if nextDetectResultNode0.nodeType != 5 && nextDetectResultNode1.nodeType == 5{
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                        }
                        else if nextDetectResultNode0.nodeType == 0 && nextDetectResultNode1.nodeType != 0{
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                        }
                        else if nextDetectResultNode0.nodeType != 0 && nextDetectResultNode1.nodeType == 0{
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                        }
                        else if leftLaplacianPercent < blurThreshold && rightLaplacianPercent >= blurThreshold{
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                        }
                        else if rightLaplacianPercent < blurThreshold && leftLaplacianPercent >= blurThreshold{
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                        }
                        else{
                            var leftNextLaplacianPercent : Float = 1
                            var rightNextLaplacianPercent : Float = 1
                            
                            if nextDetectResultNode0.nodeType == 1{
                                leftNextLaplacianPercent = nextDetectResultNode0.laplacianVariance / nextnextDetectResultNode0.laplacianVariance
                            }
                            else if nextDetectResultNode0.nodeType == 0{
                                leftNextLaplacianPercent = nextDetectResultNode0.laplacianVariance / nextnextDetectResultNode0.laplacianVariance
                            }
                            else if nextDetectResultNode0.nodeType == 4 && self.laplacianDic[0][nextDetectResultNode0.singlefeatureIndex[0]] != 0{
                                leftNextLaplacianPercent = nextDetectResultNode0.laplacianVariance / self.laplacianDic[0][nextDetectResultNode0.singlefeatureIndex[0]]!
                            }
                            
                            if nextDetectResultNode1.nodeType == 1{
                                rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / nextnextDetectResultNode1.laplacianVariance
                            }
                            else if nextDetectResultNode1.nodeType == 0{
                                rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / nextnextDetectResultNode1.laplacianVariance
                            }
                            else if nextDetectResultNode1.nodeType == 4 && self.laplacianDic[1][nextDetectResultNode1.singlefeatureIndex[0]] != 0{
                                rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / self.laplacianDic[1][nextDetectResultNode1.singlefeatureIndex[0]]!
                            }
                            
                            if leftNextLaplacianPercent < blurThreshold && rightNextLaplacianPercent >= blurThreshold{
                                detectSingleFeatureArray.insert(insertCard1, at: 0)
                                detectSingleFeatureArray.insert(insertCard0, at: 0)
                            }
                            else if rightNextLaplacianPercent < blurThreshold && leftNextLaplacianPercent >= blurThreshold{
                                detectSingleFeatureArray.insert(insertCard0, at: 0)
                                detectSingleFeatureArray.insert(insertCard1, at: 0)
                            }
                            //上一张和下一张两边都不模糊 直接比较上一张两边模糊程度
                            else if leftLaplacianPercent < blurThreshold && rightLaplacianPercent < blurThreshold{
                                if leftLaplacianPercent < rightLaplacianPercent{
                                    detectSingleFeatureArray.insert(insertCard0, at: 0)
                                    detectSingleFeatureArray.insert(insertCard1, at: 0)
                                }
                                else{
                                    detectSingleFeatureArray.insert(insertCard1, at: 0)
                                    detectSingleFeatureArray.insert(insertCard0, at: 0)
                                }
                            }
                            else{
                                if leftNextLaplacianPercent < rightNextLaplacianPercent{
                                    detectSingleFeatureArray.insert(insertCard1, at: 0)
                                    detectSingleFeatureArray.insert(insertCard0, at: 0)
                                }
                                else{
                                    detectSingleFeatureArray.insert(insertCard0, at: 0)
                                    detectSingleFeatureArray.insert(insertCard1, at: 0)
                                }
                            }
                            
                        }
                    }
                    
                    else{
                        if nodeType0 == 4 || nodeType0 == 2{
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                        }
                        if nodeType1 == 4 || nodeType1 == 2{
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                        }
                    }
                }
            }
        }
        
        var uniqueArray: [Int] = []
        for singlefeature in detectSingleFeatureArray {
            if let existIndex = uniqueArray.firstIndex(of: singlefeature.cardIndex){
                if singlefeature.confidence > confidenceDic[singlefeature.cardIndex] ?? 0{
                    confidenceDic[singlefeature.cardIndex] = singlefeature.confidence
                    uniqueArray.append(singlefeature.cardIndex)
                    uniqueArray.remove(at: existIndex)
                    print("delete chain \(singlefeature.cardIndex) \(existIndex)/\(uniqueArray.count) \(singlefeatureLabelDic[singlefeature.cardIndex]!)")
                }
            }
            else if singlefeature.confidence >= 0.5{
                confidenceDic[singlefeature.cardIndex] = singlefeature.confidence
                uniqueArray.append(singlefeature.cardIndex)
            }
        }
        
        isShort = uniqueArray.count < min(minSingleFeatureNum,10)
        
        print("handle result \(uniqueArray.count) \(minSingleFeatureNum) isShort\(isShort)")
        
        let result = DetectionState(detectionResult: uniqueArray, isSingle: isSingle, isShort: isShort, longestIndex: longestIndex)
        return result
    }
    
    func cutSingleFeatureArray(index : Int){
        if index < singlefeatureArray.count - 1{
            let elementsToMove = singlefeatureArray[(index+1)...]
            singlefeatureArray.removeSubrange((index+1)...)
            singlefeatureArray.insert(contentsOf: elementsToMove, at: 0)
        }
    }
    
    func judgeCutRange(stateResult: [[Float]], isCameraHorizon: Bool) -> Bool{
        if isCameraHorizon{
            let xDistance = abs(stateResult[0][0] - stateResult[1][0]) - (stateResult[0][2] - stateResult[1][2])/2
            let maxX = max(stateResult[0][2], stateResult[1][2])
            if xDistance < 3 * maxX{
                return true
            }
            else{
                return false
            }
        }
        else{
            let yDistance = abs(stateResult[0][1] - stateResult[1][1]) - (stateResult[0][3] - stateResult[1][3])/2
            let maxY = max(stateResult[0][3], stateResult[1][3])
            
            if yDistance < 3 * maxY{
                return true
            }
            else{
                return false
            }
        }
    }
    
    // MARK: compute targetArea
    /// Horizontal shuffle and its follow-up cut actions share the same dynamic
    /// Texas model: 16:9/9:16 ROI, single area 70× and pair span 1.5×. `detectNeedToCut`
    /// remains the immediate runtime signal; the saved configuration is also
    /// checked so a transient reset cannot make an ongoing cut use standard geometry.
    private func isHorizontalShuffleCutROIPhase() -> Bool {
        guard self.shuffleMode[0] == 2 else {
            return false
        }

        // When shuffle and riffle are both enabled, a deck produced by riffle
        // must keep the standard riffle/cut distribution. Slot 0 geometry only
        // applies to a deck produced by shuffle.
        if !self.singlefeatureArray.isEmpty && self.shuffleOrRiffle != 0 {
            return false
        }

        if self.detectNeedToCut {
            return true
        }

        guard !self.singlefeatureArray.isEmpty else {
            return false
        }

        let hasHorizontalShuffleCutAction = self.cutMode[0] != 0
            || self.specialCard[0] != 0
            || self.recgReport
        return self.isProcessNeedToCut && hasHorizontalShuffleCutAction
    }

    private func resolveTargetAreaScenario(boxCount _: Int) -> TargetAreaScenario {
        guard self.shuffleMode[0] == 2 else {
            return .standard
        }

        if self.isHorizontalShuffleCutROIPhase() {
            return .horizontalShuffleCut
        }

        // A pending cut from a riffle-produced deck belongs to slot 1 and must
        // retain standard riffle/cut geometry even when horizontal shuffle is
        // also enabled.
        if !self.singlefeatureArray.isEmpty
            && self.shuffleOrRiffle != 0
            && (self.detectNeedToCut || self.isProcessNeedToCut || self.recgReport) {
            return .standard
        }

        // A single box is a horizontal-shuffle search anchor even when riffle
        // is also enabled. It uses the wide single-box ROI to preserve the
        // possible second pile; the state machine may consume it as riffle.
        return .horizontalShuffle
    }

    func computeTargetArea(stateResult: [[Float]]) -> [Float] {
        let scenario = resolveTargetAreaScenario(boxCount: stateResult.count)
        return computeTargetArea(
            stateResult: stateResult,
            scenario: scenario,
            isCameraHorizon: self.isCameraHorizon
        )
    }

    private func computeTargetArea(
        stateResult: [[Float]],
        scenario: TargetAreaScenario,
        isCameraHorizon: Bool
    ) -> [Float] {
        switch scenario {
        case .standard:
            return computeStandardTargetArea(
                stateResult: stateResult,
                isCameraHorizon: isCameraHorizon
            )
        case .horizontalShuffle, .horizontalShuffleCut:
            return computeHorizontalShuffleTargetArea(
                stateResult: stateResult,
                isCameraHorizon: isCameraHorizon
            )
        }
    }

    private func computeHorizontalShuffleTargetArea(
        stateResult: [[Float]],
        isCameraHorizon: Bool
    ) -> [Float] {
        let sourceBoxes = Array(stateResult.prefix(2))
        guard !sourceBoxes.isEmpty else {
            return [0, 0, 0, 0]
        }

        let pixelBoxes = sourceBoxes.map { box -> HorizontalShufflePixelBox in
            if isCameraHorizon {
                return HorizontalShufflePixelBox(
                    centerAlong: box[0] * self.originSize[0],
                    centerCross: box[1] * self.originSize[1],
                    sizeAlong: box[2] * self.originSize[0],
                    sizeCross: box[3] * self.originSize[1]
                )
            }
            return HorizontalShufflePixelBox(
                centerAlong: box[1] * self.originSize[1],
                centerCross: box[0] * self.originSize[0],
                sizeAlong: box[3] * self.originSize[1],
                sizeCross: box[2] * self.originSize[0]
            )
        }

        let centerAlong: Float
        let centerCross: Float
        if pixelBoxes.count == 1 {
            centerAlong = pixelBoxes[0].centerAlong
            centerCross = pixelBoxes[0].centerCross
        }
        else {
            centerAlong = (pixelBoxes[0].centerAlong + pixelBoxes[1].centerAlong) / 2
            centerCross = (pixelBoxes[0].centerCross + pixelBoxes[1].centerCross) / 2
        }

        let alongLength: Float
        if pixelBoxes.count == 1 {
            let box = pixelBoxes[0]
            alongLength = sqrt(horizontalShuffleROIAreaFactor
                * box.sizeAlong * box.sizeCross * horizontalShuffleROIAspect)
        } else {
            // Full outer-edge span, centered on the two box centers' midpoint.
            // Do not reuse the old area-based pair baseline or 90% expansion.
            let minAlong = pixelBoxes.map { $0.centerAlong - $0.sizeAlong / 2 }.min()!
            let maxAlong = pixelBoxes.map { $0.centerAlong + $0.sizeAlong / 2 }.max()!
            alongLength = (maxAlong - minAlong) * horizontalShuffleROIPairSpanFactor
        }
        let crossLength = alongLength / horizontalShuffleROIAspect

        guard alongLength > 0, crossLength > 0 else {
            return [0, 0, 0, 0]
        }

        let result = makeHorizontalShuffleTargetArea(
            centerAlong: centerAlong,
            centerCross: centerCross,
            alongLength: alongLength,
            crossLength: crossLength,
            isCameraHorizon: isCameraHorizon
        )

        // The statistical size is never changed by the screen. The origin is
        // shifted toward real pixels and any unavoidable overflow is filled
        // gray by createCVPixelBuffer, matching the training generator.
        if !horizontalShuffleTargetArea(result, contains: sourceBoxes) {
            return [0, 0, 0, 0]
        }
        return result
    }

    private func makeHorizontalShuffleTargetArea(
        centerAlong: Float,
        centerCross: Float,
        alongLength: Float,
        crossLength: Float,
        isCameraHorizon: Bool
    ) -> [Float] {
        let targetWidth = isCameraHorizon ? alongLength : crossLength
        let targetHeight = isCameraHorizon ? crossLength : alongLength
        let requestedCenterX = isCameraHorizon ? centerAlong : centerCross
        let requestedCenterY = isCameraHorizon ? centerCross : centerAlong

        // Clamp the ROI origin, not the center with an extra inset. This also
        // handles an along length equal to the full screen without inverted
        // center bounds or a two-pixel overflow.
        let originX = fittedHorizontalShuffleOrigin(
            desired: requestedCenterX - targetWidth / 2,
            roiSize: targetWidth,
            frameSize: self.originSize[0]
        )
        let originY = fittedHorizontalShuffleOrigin(
            desired: requestedCenterY - targetHeight / 2,
            roiSize: targetHeight,
            frameSize: self.originSize[1]
        )
        return [
            (originX + targetWidth / 2) / self.originSize[0],
            (originY + targetHeight / 2) / self.originSize[1],
            targetWidth / self.originSize[0],
            targetHeight / self.originSize[1]
        ]
    }

    private func fittedHorizontalShuffleOrigin(
        desired: Float,
        roiSize: Float,
        frameSize: Float
    ) -> Float {
        if roiSize <= frameSize {
            return max(0, min(desired, frameSize - roiSize))
        }
        return max(frameSize - roiSize, min(desired, 0))
    }

    private func horizontalShuffleTargetArea(
        _ targetArea: [Float],
        contains boxes: [[Float]]
    ) -> Bool {
        let epsilon: Float = 0.000_01
        let targetMinX = targetArea[0] - targetArea[2] / 2
        let targetMaxX = targetArea[0] + targetArea[2] / 2
        let targetMinY = targetArea[1] - targetArea[3] / 2
        let targetMaxY = targetArea[1] + targetArea[3] / 2
        return boxes.allSatisfy { box in
            targetMinX <= box[0] - box[2] / 2 + epsilon
                && targetMaxX + epsilon >= box[0] + box[2] / 2
                && targetMinY <= box[1] - box[3] / 2 + epsilon
                && targetMaxY + epsilon >= box[1] + box[3] / 2
        }
    }

    private func computeStandardTargetArea(
        stateResult: [[Float]],
        isCameraHorizon: Bool
    ) -> [Float]{
        
        let originBoxes = stateResult
        var targetArea:[Float] = [0,0,0,0]
        
        let w = self.imageSize[0]
        let h = self.imageSize[1]
        
        var boxfactor:Float = 1.5
        
        if originBoxes.count == 1{
            
            let minX = self.originSize[0] * (originBoxes[0][0] - originBoxes[0][2] / 2)
            let maxX = self.originSize[0] * (originBoxes[0][0] + originBoxes[0][2] / 2)
            let minY = self.originSize[1] * (originBoxes[0][1] - originBoxes[0][3] / 2)
            let maxY = self.originSize[1] * (originBoxes[0][1] + originBoxes[0][3] / 2)
            
            var minW = (maxX - minX)
            var minH = (maxY - minY)
            
            if isCameraHorizon{
                
                //如果不洗牌 只拨牌
                if self.shuffleMode[0] == 0 && self.shuffleMode[1] != 0{
                    boxfactor = 2.5
                }
                //如果不拨牌 只洗牌
                else if self.shuffleMode[0] != 0 && self.shuffleMode[1] == 0{
                    if detectNeedToCut{
                        boxfactor = 5
                    }
                    else{
                        boxfactor = 7.5
                    }
                }
                //要洗或拨
                else{
                    boxfactor = 5
                }
                
                minW = max(minW,minH/h*w) * boxfactor
                minW = min(minW, self.originSize[0] - 10)
                
                targetArea[2] = minW
                targetArea[3] = minW / w * h
                
                let centerX = (minX + maxX)/2
                let centerY = (minY + maxY)/2
                
                if centerX + targetArea[2]/2 >= self.originSize[0]{
                    targetArea[0] = self.originSize[0] - targetArea[2] / 2 - 2
                }
                else if centerX - targetArea[2]/2 <= 0{
                    targetArea[0] = targetArea[2]/2 + 2
                }
                else{
                    targetArea[0] = centerX
                }
                
                if centerY + targetArea[3]/2 >= self.originSize[1]{
                    targetArea[1] = self.originSize[1] - targetArea[3] / 2 - 2
                }
                else if centerY - targetArea[3]/2 <= 0{
                    targetArea[1] = targetArea[3]/2 + 2
                }
                else{
                    targetArea[1] = centerY
                }
            }
            
            else{
                //如果不洗牌 只拨牌
                if self.shuffleMode[0] == 0 && self.shuffleMode[1] != 0{
                    boxfactor = 2.5
                }
                //如果不拨牌 只洗牌
                else if self.shuffleMode[0] != 0 && self.shuffleMode[1] == 0{
                    if detectNeedToCut{
                        boxfactor = 5
                    }
                    else{
                        boxfactor = 7.5
                    }
                }
                //要要洗或拨
                else{
                    boxfactor = 5
                }
                
                minH = max(minW/h*w,minH) * boxfactor
                minH = min(minH, self.originSize[1] - 10)
                
                targetArea[2] = minH / w * h
                targetArea[3] = minH
                
                let centerX = (minX + maxX)/2
                let centerY = (minY + maxY)/2
                
                if centerX + targetArea[2]/2 >= self.originSize[0]{
                    targetArea[0] = self.originSize[0] - targetArea[2] / 2 - 2
                }
                else if centerX - targetArea[2]/2 <= 0{
                    targetArea[0] = targetArea[2]/2 + 2
                }
                else{
                    targetArea[0] = centerX
                }
                
                if centerY + targetArea[3]/2 >= self.originSize[1]{
                    targetArea[1] = self.originSize[1] - targetArea[3] / 2 - 2
                }
                else if centerY - targetArea[3]/2 <= 0{
                    targetArea[1] = targetArea[3]/2 + 2
                }
                else{
                    targetArea[1] = centerY
                }
            }
            
        }
        
        else if originBoxes.count == 2{
            // 两框的包围区域不依赖左右/上下顺序；ROI 比例始终跟随手机方向。
            let minX = self.originSize[0] * min(originBoxes[0][0] - originBoxes[0][2] / 2, originBoxes[1][0] - originBoxes[1][2] / 2)
            let maxX = self.originSize[0] * max(originBoxes[0][0] + originBoxes[0][2] / 2, originBoxes[1][0] + originBoxes[1][2] / 2)
            let minY = self.originSize[1] * min(originBoxes[0][1] - originBoxes[0][3] / 2, originBoxes[1][1] - originBoxes[1][3] / 2)
            let maxY = self.originSize[1] * max(originBoxes[0][1] + originBoxes[0][3] / 2, originBoxes[1][1] + originBoxes[1][3] / 2)
            let centerX = (minX + maxX)/2
            let centerY = (minY + maxY)/2
            
            if isCameraHorizon{
                
                var minW = (maxX - minX)*boxfactor
                minW = min(minW, self.originSize[0] - 10)
                
                var minH = (maxY - minY)*boxfactor
                minH = min(minH, self.originSize[1] - 10)
                
                targetArea[2] = max(minW, minH / h * w)
                targetArea[3] = max(minH, minW / w * h)
            }
            else{
                var minW = (maxX - minX)*boxfactor
                var minH = (maxY - minY)*boxfactor
                
                minH = max(minH, minW)
                minH = min(minH, self.originSize[1] - 10)
                
                minW = max((maxX - minX), minH / w * h)
                
                targetArea[2] = minW
                targetArea[3] = minH
            }

            if centerX + targetArea[2]/2 >= self.originSize[0]{
                targetArea[0] = self.originSize[0] - targetArea[2] / 2 - 2
            }
            else if centerX - targetArea[2]/2 <= 0{
                targetArea[0] = targetArea[2]/2 + 2
            }
            else{
                targetArea[0] = centerX
            }

            if centerY + targetArea[3]/2 >= self.originSize[1]{
                targetArea[1] = self.originSize[1] - targetArea[3] / 2 - 2
            }
            else if centerY - targetArea[3]/2 <= 0{
                targetArea[1] = targetArea[3]/2 + 2
            }
            else{
                targetArea[1] = centerY
            }
        }
        
        
        targetArea[0] /= originSize[0]
        targetArea[1] /= originSize[1]
        targetArea[2] /= originSize[0]
        targetArea[3] /= originSize[1]
        
        return targetArea
    }
    
    private func updateTargetArea(
        coordinates: [[Float]],
        targetArea: [Float],
        scenario: TargetAreaScenario,
        isCameraHorizon: Bool
    ) -> [Float]{
        let targetX = targetArea[0] * self.originSize[0]
        let targetY = targetArea[1] * self.originSize[1]
        let targetW = targetArea[2] * self.originSize[0]
        let targetH = targetArea[3] * self.originSize[1]
        
        var stateResult : [[Float]] = []
        
        if targetW != 0{
            for coordinate in coordinates {
                let x = (coordinate[0] * targetW + targetX - targetW / 2) / originSize[0]
                let y = (coordinate[1] * targetH + targetY - targetH / 2) / originSize[1]
                let w = (coordinate[2] * targetW) / originSize[0]
                let h = (coordinate[3] * targetH) / originSize[1]
                stateResult.append([x,y,w,h])
            }
        }
        else{
            for coordinate in coordinates {
                let x = coordinate[0]
                let y = coordinate[1]
                let w = coordinate[2]
                let h = coordinate[3]
                stateResult.append([x,y,w,h])
            }
        }

        // Single-box search/cut ROI is established by the full-frame entry
        // paths. A missing pile must never shrink a shuffle crop. Use the most
        // recent crop, not this possibly older concurrent frame's snapshot.
        // Explicit riffle keeps its existing single-target tracking behavior.
        switch scenario {
        case .horizontalShuffle, .horizontalShuffleCut:
            if stateResult.isEmpty || (stateResult.count == 1 && self.state != "riffle") {
                return self.targetArea
            }
        case .standard:
            break
        }

        let nextTargetArea = computeTargetArea(
            stateResult: stateResult,
            scenario: scenario,
            isCameraHorizon: isCameraHorizon
        )
        if nextTargetArea[2] == 0 || nextTargetArea[3] == 0 {
            switch scenario {
            case .horizontalShuffle, .horizontalShuffleCut:
                return nextTargetArea
            case .standard:
                return targetArea
            }
        }
        return nextTargetArea
    }
    
    func targetAreaMove(
        initTargetArea: [Float],
        targetArea: [Float],
        isCameraHorizon: Bool
    ) -> Bool{
        if isCameraHorizon{
            if abs(initTargetArea[0] - targetArea[0]) > (initTargetArea[2] + targetArea[2]) / 5
                || abs(initTargetArea[1] - targetArea[1]) > (initTargetArea[3] + targetArea[3]) / 2.5
                || targetArea[2] / initTargetArea[2] > 1.5
                || initTargetArea[2] / targetArea[2] > 1.5{
                return true
            }
            else{
                return false
            }
        }
        else{
            if abs(initTargetArea[0] - targetArea[0]) > (initTargetArea[2] + targetArea[2]) / 2.5
                || abs(initTargetArea[1] - targetArea[1]) > (initTargetArea[3] + targetArea[3]) / 5
                || targetArea[3] / initTargetArea[3] > 1.5
                || initTargetArea[3] / targetArea[3] > 1.5{
                return true
            }
            else{
                return false
            }
        }
    }
    
    private func shufflePostureJudge(
        coordinates:[[Float]],
        coordinateTargetArea: [Float],
        scenario: TargetAreaScenario,
        isCameraHorizon: Bool
    ) -> Bool{
        let w = self.imageSize[0]
        let h = self.imageSize[1]
        let usesHorizontalShuffleROI: Bool
        switch scenario {
        case .horizontalShuffle, .horizontalShuffleCut:
            usesHorizontalShuffleROI = true
        case .standard:
            usesHorizontalShuffleROI = false
        }
        // Classification coordinates are normalized inside the active crop.
        // Horizontal-shuffle axes are independently data-derived instead of
        // using the legacy 569:320 canvas. Restore posture distances with the
        // crop that produced this frame, not the next frame's recomputed crop.
        let xScale = usesHorizontalShuffleROI
            ? coordinateTargetArea[2] * self.originSize[0]
            : (isCameraHorizon ? w : h)
        let yScale = usesHorizontalShuffleROI
            ? coordinateTargetArea[3] * self.originSize[1]
            : (isCameraHorizon ? h : w)

        // The legacy standard-shuffle gate allows a cross-axis centre offset
        // below half the mean cross-axis box size. That threshold rejects 732
        // of the 1,631 reviewed horizontal-shuffle pairs, so only the dedicated
        // horizontal-shuffle scenarios use the calibrated 1.5 multiplier.
        let crossOffsetLimit = usesHorizontalShuffleROI
            ? horizontalShufflePostureCrossOffsetLimit
            : 0.5

        if isCameraHorizon{
            let alongGap = abs(coordinates[0][0] - coordinates[1][0]) * xScale
            let minimumAlongGap = max(
                (coordinates[0][2] + coordinates[1][2]) * xScale * 1.1 / 2,
                coordinates[0][3] * yScale,
                coordinates[1][3] * yScale
            )
            let crossGap = abs(coordinates[0][1] - coordinates[1][1]) * yScale
            let meanCrossSize = (coordinates[0][3] + coordinates[1][3]) * yScale / 2
            return alongGap > minimumAlongGap
                && crossGap < meanCrossSize * crossOffsetLimit
        }

        let alongGap = abs(coordinates[0][1] - coordinates[1][1]) * yScale
        let minimumAlongGap = max(
            (coordinates[0][3] + coordinates[1][3]) * yScale * 1.1 / 2,
            coordinates[0][2] * xScale,
            coordinates[1][2] * xScale
        )
        let crossGap = abs(coordinates[0][0] - coordinates[1][0]) * xScale
        let meanCrossSize = (coordinates[0][2] + coordinates[1][2]) * xScale / 2
        return alongGap > minimumAlongGap
            && crossGap < meanCrossSize * crossOffsetLimit
    }

    func getSingleFeature(
        from singlefeatureArray: MLMultiArray,
        from boxArray: MLMultiArray,
        from pixelBuffer: CVPixelBuffer,
        from iscls: Bool,
        isCameraHorizon: Bool
    ) -> ([DetectionResult], Int) {
        let cnt : Int = Int(singlefeatureArray.shape[0])
        let n : Int = Int(singlefeatureArray.shape[1])
        var result : [DetectionResult] = []
        
        
        if !iscls{
            for i in 0..<cnt {
                var maxVal: Float32 = singlefeatureArray[i * n].floatValue
                var confidenceSum : Float = 0
                var singlefeatureIndex : [Int] = []
                var confidence : [Float] = []
                for j in 0..<n {
                    let index = i * n + j
                    let value = singlefeatureArray[index].floatValue
                    confidenceSum += value
                }
                for j in 0..<n {
                    let index = i * n + j
                    let value = singlefeatureArray[index].floatValue
                    
                    let trueIndex = j == 52 ? 54 : j
                    
                    if value > 0{
                        
                        if (value/confidenceSum>=0) {
                            singlefeatureIndex.append(j)
                            confidence.append(value)
                        }
                        
                        if value > maxVal {
                            maxVal = value
                        }
                    }
                }
                
                singlefeatureIndex.sort{singlefeatureArray[$0 + i*n].floatValue > singlefeatureArray[$1 + i*n].floatValue}
                confidence.sort{ $0 > $1 }
                
                let centerX = boxArray[i*4].floatValue
                let centerY = boxArray[i*4+1].floatValue
                let widthX = boxArray[i*4+2].floatValue
                let heightY = boxArray[i*4+3].floatValue
                
                let coordinate = [centerX, centerY, widthX, heightY]
                
                if singlefeatureIndex.count > 0{
                    if let index = result.firstIndex(where: {
                        abs($0.coordinate[0] - coordinate[0]) < ($0.coordinate[2] + coordinate[2]) / 2
                         && abs($0.coordinate[1] - coordinate[1]) < ($0.coordinate[3] + coordinate[3]) / 2
                    }) {
                        
                        if maxVal > result[index].confidence[0] {
                            result[index].singlefeatureIndex = singlefeatureIndex + result[index].singlefeatureIndex
                            result[index].confidence = confidence + result[index].confidence
                        }
                        else{
                            result[index].singlefeatureIndex = result[index].singlefeatureIndex + singlefeatureIndex
                            result[index].confidence = result[index].confidence + confidence
                        }
                    }
                    else{
                        result.append(DetectionResult(singlefeatureIndex: singlefeatureIndex, confidence: confidence, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: 0))
                    }
                }
            }
            
            var uniqueNum = result.count
            
            if result.count > 2{
                result.sort{$0.confidence[0] > $1.confidence[0]}
                result.removeLast(result.count - 2)
            }
            
            
            if result.count == 2{
                if isCameraHorizon && result[0].coordinate[0] > result[1].coordinate[0]{
                        result.swapAt(0, 1)
                    }
            else if !isCameraHorizon && result[0].coordinate[1] > result[1].coordinate[1]{
                        result.swapAt(0, 1)
                    }
            }
            else if result.count == 1{
                result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: result[0].coordinate, laplacianVariance: 0), at: 1)
            }
            else if result.count == 0{
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0))
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0))
            }
            
            for resultIndex in 0..<result.count{
                result[resultIndex].singlefeatureIndex = result[resultIndex].singlefeatureIndex.map { $0 == 52 ? 54 : $0 }
            }
            return (result, uniqueNum)
        }
        
        else{
            
            let newCIImage = CIImage(cvImageBuffer: pixelBuffer)
            let cgImage = CurrentVisionObjectRecognitionViewModel.context.createCGImage(newCIImage, from: newCIImage.extent)!
            
            /// The 8-bit-per-channel, 4-channel source pixel buffer.
            let sourceBuffer8 = try! vImage.PixelBuffer<vImage.Interleaved8x4>(
                cgImage: cgImage,
                cgImageFormat: &BlurDetector_8.sourceFormat8)
            
            
            /// The 8-bit planar destination pixel buffer.
            let destinationBuffer8 = vImage.PixelBuffer<vImage.Planar8>(width: sourceBuffer8.width,
                                                                        height: sourceBuffer8.height)
            
            let divisor: Int = 0x1000
            let fDivisor = Float(divisor)
            
            sourceBuffer8.multiply(by: (0,
                                        Int(BlurDetector_8.defaultRedCoefficient * fDivisor),
                                        Int(BlurDetector_8.defaultGreenCoefficient * fDivisor),
                                        Int(BlurDetector_8.defaultBlueCoefficient * fDivisor)),
                                   divisor: divisor,
                                   preBias: (0, 0, 0, 0),
                                   postBias: 0,
                                   destination: destinationBuffer8)
            
            for i in 0..<cnt {
                var maxVal: Float32 = singlefeatureArray[i * n].floatValue
                var confidenceSum : Float = 0
                var singlefeatureIndex : [Int] = []
                var confidence : [Float] = []
                for j in 0..<n {
                    let index = i * n + j
                    let value = singlefeatureArray[index].floatValue
                    confidenceSum += value
                }
                for j in 0..<n {
                    let index = i * n + j
                    let value = singlefeatureArray[index].floatValue
                    
                    let trueIndex = j == 52 ? 54 : j
                    
                    if value > 0 && self.allSingleFeatureIndex.contains(trueIndex){
                        
                        if (value/confidenceSum>=0) {
                            singlefeatureIndex.append(j)
                            confidence.append(value)
                        }
                        
                        if value > maxVal {
                            maxVal = value
                        }
                    }
                }
                
                singlefeatureIndex.sort{singlefeatureArray[$0 + i*n].floatValue > singlefeatureArray[$1 + i*n].floatValue}
                confidence.sort{ $0 > $1 }
                
                let centerX = boxArray[i*4].floatValue
                let centerY = boxArray[i*4+1].floatValue
                let widthX = boxArray[i*4+2].floatValue
                let heightY = boxArray[i*4+3].floatValue
                
                let coordinate = [centerX, centerY, widthX, heightY]
                
                if singlefeatureIndex.count > 0{
                    if self.state == "shuffle" || self.state == "riffle"{
                        if let index = result.firstIndex(where: {
                            abs($0.coordinate[0] - coordinate[0]) < ($0.coordinate[2] + coordinate[2]) / 2
                            && abs($0.coordinate[1] - coordinate[1]) < ($0.coordinate[3] + coordinate[3]) / 2
                        }) {
                            
                            if maxVal > result[index].confidence[0] {
                                result[index].singlefeatureIndex = singlefeatureIndex + result[index].singlefeatureIndex
                                result[index].confidence = confidence + result[index].confidence
                            }
                            else{
                                result[index].singlefeatureIndex = result[index].singlefeatureIndex + singlefeatureIndex
                                result[index].confidence = result[index].confidence + confidence
                            }
                        }
                        else{
                            result.append(DetectionResult(singlefeatureIndex: singlefeatureIndex, confidence: confidence, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: 0))
                        }
                    }
                    else{
                        result.append(DetectionResult(singlefeatureIndex: singlefeatureIndex, confidence: confidence, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: 0))
                    }
                }
            }
            
            if result.count > 2{
                var uniqueSingleFeatureIndexes = Set<Int>()
                
                result = result.filter {
                    let singlefeatureIndex0 = $0.singlefeatureIndex[0]
                    if uniqueSingleFeatureIndexes.contains(singlefeatureIndex0) {
                        return false
                    } else {
                        uniqueSingleFeatureIndexes.insert(singlefeatureIndex0)
                        return true
                    }
                }
            }
            
            let uniqueNum = result.count
            
            if result.count > 2{
                result.sort{$0.confidence[0] > $1.confidence[0]}
                result.removeLast(result.count - 2)
            }
            
            
            if result.count == 2{
                //横向排列
                if isCameraHorizon && result[0].coordinate[0] > result[1].coordinate[0]{
                        result.swapAt(0, 1)
                    }
                //纵向排列
                else if !isCameraHorizon && result[0].coordinate[1] > result[1].coordinate[1]{
                        result.swapAt(0, 1)
                    }
            }
            else if result.count == 1{
                if self.state == "shuffle"{
                    if isCameraHorizon{
                        if result[0].coordinate[0] > self.centerPos[0]{
                            result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0), at: 0)
                        }
                        else{
                            result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0), at: 1)
                        }
                    }
                    else{
                        if result[0].coordinate[1] > self.centerPos[1]{
                            result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0), at: 0)
                        }
                        else{
                            result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0), at: 1)
                        }
                    }
                }
                else{
                    result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: result[0].coordinate, laplacianVariance: 0), at: 1)
                }
            }
            else if result.count == 0{
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0))
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0))
            }
            
            
            
            for resultIndex in 0..<result.count{
                result[resultIndex].singlefeatureIndex = result[resultIndex].singlefeatureIndex.map { $0 == 52 ? 54 : $0 }
            }
            
            for resultIndex in 0..<result.count{
                result[resultIndex].laplacianVariance = ComputeROILaplacianVariance(box: result[resultIndex].coordinate, destinationBuffer8: destinationBuffer8)
            }
            return (result, uniqueNum)
        }
    }
    
    //MARK: generate test result
    func generateTestResult(){
        self.currentRoundID = 1
        ReportManager.isFirstReport = true
        var testArray:[Int] = []
        for i in self.allSingleFeatureIndex{
            testArray.append(i)
        }
        
        testArray.shuffle()
        self.singlefeatureArray = testArray
//        self.singlefeatureArray = [2,2,2,2,2,2,2,2,2,2,2,2]
        
        self.cutStructArray = []
        self.cutShowArray = []
        
        //返回数组[最大切牌次数, 最大看色次数]
        let maxCutTimes = getWatchColorNumber()
        
        var cutSingleFeature : Int = self.singlefeatureArray.randomElement()!
        var cutIndex = self.singlefeatureArray.firstIndex(of: cutSingleFeature)!
        
        if self.cutMode[self.shuffleOrRiffle] == 1{
            self.cutStructArray.append(cutStruct(cutcardIndex: cutSingleFeature, cutMode: 0))
            self.cutShowArray.append(cutSingleFeature)
        }
        else if self.cutMode[self.shuffleOrRiffle] == 2{
            cutIndex -= 1
            if cutIndex < 0 {
                cutIndex = self.singlefeatureArray.count - 1
            }
            self.cutStructArray.append(cutStruct(cutcardIndex: self.singlefeatureArray[cutIndex], cutMode: 1))
            self.cutShowArray.append(cutSingleFeature)
        }
        else if self.cutMode[self.shuffleOrRiffle] == 3{
            self.cutStructArray.append(cutStruct(cutcardIndex: cutSingleFeature, cutMode: 0))
            self.cutShowArray.append(cutSingleFeature)
        }
        else if self.cutMode[self.shuffleOrRiffle] == 4{
            self.cutStructArray.append(cutStruct(cutcardIndex: cutSingleFeature, cutMode: 4))
            self.cutShowArray.append(cutSingleFeature)
        }
        else if self.cutMode[self.shuffleOrRiffle] == 5{
            cutIndex -= 1
            if cutIndex < 0 {
                cutIndex = self.singlefeatureArray.count - 1
            }
            self.cutStructArray.append(cutStruct(cutcardIndex: self.singlefeatureArray[cutIndex], cutMode: 1))
            self.cutShowArray.append(cutSingleFeature)
        }
        else if self.cutMode[self.shuffleOrRiffle] == 6 || self.cutMode[self.shuffleOrRiffle] == 7{
            self.cutStructArray.append(cutStruct(cutcardIndex: cutSingleFeature, cutMode: 5))
            self.cutShowArray.append(cutSingleFeature)
        }
        
        if self.specialCard[self.shuffleOrRiffle] == 1{
            self.cutStructArray.append(cutStruct(cutcardIndex: cutSingleFeature, cutMode: 3))
            self.cutShowArray.append(cutSingleFeature)
        }
        else if self.specialCard[self.shuffleOrRiffle] == 2{
            for _ in 0..<maxCutTimes {
                cutSingleFeature = self.singlefeatureArray.randomElement()!
                self.cutStructArray.append(cutStruct(cutcardIndex: cutSingleFeature, cutMode: 2))
            }
        }
        
        computeWinnerRC(isReset: true, isTest: true)
    }
    
    func getWatchColorNumber() -> Int{
        
        if let reportRule = DetectSettingArgs.allPreSetReportRules[self.calModeArgs[self.shuffleOrRiffle][0]] {
            
            switch reportRule.cutSingleFeatureProcession {
            //看手牌
            case 0:
                return 0
            // 看色两次
            case 1, 6:
                return 2
            //看色一次
            case 2...5:
                return 1
            //不看
            default:
                return 0
            }

        } else {
            return 0
        }
    }
    
    func computeWinnerRC(isReset: Bool, isTest: Bool = false) {
        if singlefeatureArray.count >= minSingleFeatureNum {
            
            var m_consecutiveReport = consecutiveReport;
            if !isTest && self.recgReport{
                m_consecutiveReport = 1
            }
            
            print("计算前的singlefeaturearray \(self.singlefeatureArray)")
            multipleDatasetRCInfos = ClassifierSettingArgs.selectDataset(DatasetIndex: ruleIndex, inputSingleFeatures: singlefeatureArray, rcNum: (ClassifierSettingArgs.targetSetting[ruleIndex]?.rcNum[rcNum])!, args: args, rankRules: rankRules, suitRules: suitRules,dealNum: dealNum, coloringType: coloringType, dealType: dealType, diyDealNum: diyDealNum,diyDealStatus: diyDealStatus, calModeArgs: calModeArgs[self.shuffleOrRiffle], cutNumSetting: cutNumSetting, cutNumRangeSetting: cutNumRangeSetting, consecutiveReport: m_consecutiveReport, minSingleFeatureNum: minSingleFeatureNum, cutStructList: cutStructArray, currentRoundID: self.currentRoundID)
            
            self.singlefeatureArray = multipleDatasetRCInfos.returnSingleFeatureArray
            computeSingleFeatures(isReset: isReset)
            
            print("计算后的singlefeaturearray \(self.singlefeatureArray)")
            print("计算后的leftSingleFeatures \(self.leftSingleFeatures)")
            
            //摆牌
            if self.ruleIndex == 15{
                for resultIndex in 0..<multipleDatasetRCInfos.singleResultList.count{
                    for posIndex in 0..<multipleDatasetRCInfos.singleResultList[resultIndex].RCReturnInfoList.count{
                        multipleDatasetRCInfos.singleResultList[resultIndex].RCReturnInfoList[posIndex].RCSingleFeatures = CBDataset.sortSingleFeatures(originSingleFeatures: multipleDatasetRCInfos.singleResultList[resultIndex].RCReturnInfoList[posIndex].RCSingleFeatures, args: [dealNum, dealType] + [rcNum] + args, rankRules: rankRules, suitRules: suitRules)
                    }
                }
            }
            else if self.ruleIndex == 16{
                for resultIndex in 0..<multipleDatasetRCInfos.singleResultList.count{
                    for posIndex in 0..<multipleDatasetRCInfos.singleResultList[resultIndex].RCReturnInfoList.count{
                        multipleDatasetRCInfos.singleResultList[resultIndex].RCReturnInfoList[posIndex].RCSingleFeatures = TWDataset.sortSingleFeatures(originSingleFeatures: multipleDatasetRCInfos.singleResultList[resultIndex].RCReturnInfoList[posIndex].RCSingleFeatures, args: [dealNum, dealType] + [rcNum] + args, rankRules: rankRules, suitRules: suitRules)
                    }
                }
            }
            
            speakText(input: multipleDatasetRCInfos.reportResult, isCut: cutStructArray.count == 0, repeatCnt: multipleDatasetRCInfos.repeatCnt)
        }
    }
    
    func computeSingleFeatures(isReset: Bool){
        if self.singlefeatureArray.count >= self.minSingleFeatureNum {
            self.leftSingleFeatures = multipleDatasetRCInfos.leftSingleFeatures
            let usedNum = self.singlefeatureArray.count - self.leftSingleFeatures.count
            if usedNum == 0 || self.leftSingleFeatures.count == 0{
                self.usedSingleFeatures = []
            }
            else if isReset{
                self.usedSingleFeatures = Array(self.singlefeatureArray[0...(usedNum - 1)])
            }
            else{
                self.usedSingleFeatures = Array(self.singlefeatureArray[0...(usedNum - 1)])
            }
            
            print("上一轮使用的牌 \(self.usedSingleFeatures)")
        }
    }
    
    func computeNextRound(){
        if ReportManager.baodanzhang.contains(self.calModeArgs[self.shuffleOrRiffle][0]) && self.singlefeatureArray.count > 0{
            print("计算报单张的下一轮")
            self.singlefeatureArray = self.leftSingleFeatures
            self.currentRoundID += 1
            self.cutStructArray.append(cutStruct(cutcardIndex: self.singlefeatureArray[self.singlefeatureArray.count - 1], cutMode: 0))
            computeWinnerRC(isReset: false)
        } else if ReportManager.baozuidacida.contains(self.calModeArgs[self.shuffleOrRiffle][0]) && self.leftSingleFeatures.count > 0{
            
            print("计算最大次大的下一轮")
            self.singlefeatureArray = self.leftSingleFeatures
            self.currentRoundID += 1
            self.cutStructArray.append(cutStruct(cutcardIndex: self.singlefeatureArray[self.singlefeatureArray.count - 1], cutMode: 0))
            computeWinnerRC(isReset: false)
            
        } else if (self.leftSingleFeatures.count > 0){
            print("开始计算下一轮")
            self.singlefeatureArray = self.leftSingleFeatures
            self.currentRoundID += 1
            computeWinnerRC(isReset: false)
        }
    }
    
    func speakText(input: Int) {
        if let prompt = input == 0 ? RemotePromptKind.start : input == 1 ? .success : input == 2 ? .failure : nil {
            Task { @MainActor [weak self] in self?.remoteSourceBridge?.emitPrompt(prompt) }
        }
        guard RemoteRecognitionPolicy.localAudioEnabled else { return }
        let isSpeak = (!self.isHeadphonesConnected() && self.voiceDevice == 0)
                    || (self.isHeadphonesConnected() && self.voiceDevice == 1)
        
        if isSpeak {
            stopCurrentAudio()
            
            guard input >= 0 && input < soundURLs!.count, let url = soundURLs![input] else {
                print("Invalid input or sound URL")
                return
            }
            
            do {
                // Reuse existing player if possible
                if let player = currentAudioPlayer {
                    player.stop()
                }
                
                currentAudioPlayer = try AVAudioPlayer(contentsOf: url)
                currentAudioPlayer?.volume = 0.5
                currentAudioPlayer?.delegate = self
                currentAudioPlayer?.prepareToPlay()
                currentAudioPlayer?.play()
                
                hintVoiceIndex = input
                
                print("hint:\(input == 0 ? "play" : input == 1 ? "success" : "fail")!")
            } catch {
                print("Error initializing audio player: \(error)")
            }
        }
    }

    private func emitRemoteDeckPreview() {
        guard RemotePreferences.sourceEnabled else { return }
        let deck = self.singlefeatureArray
        Task { @MainActor [weak self] in self?.remoteSourceBridge?.emitDeckPreview(deck) }
    }

    private func stopCurrentAudio() {
        currentAudioPlayer?.stop()
        currentAudioPlayer = nil
    }
    
    func isOnlyDigits(_ input: String) -> Bool {
        let digitsPattern = "^[0-9\\s]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", digitsPattern)
        return predicate.evaluate(with: input)
    }


    func speakText(input: [[SpeakResultStruct]], isCut: Bool, repeatCnt: Int) {
        let isSpeak = RemoteRecognitionPolicy.localAudioEnabled
                    && ((!self.isHeadphonesConnected() && self.voiceDevice == 0)
                    || (self.isHeadphonesConnected() && self.voiceDevice == 1)
                    )
        
        if isSpeak{
            self.speechPerformer.performSpeechSynthesis(speakResultStruct: input, repeatCnt: repeatCnt, isSeparate: ReportManager.kanshoupai.contains(self.calModeArgs[self.shuffleOrRiffle][0])
            )
        }
        if self.timeMode != 0{
//            var reportTextList : [String] = []
//            for (turnIndex, turnResult) in input.enumerated() {
//                for (reportIndex, reportResult) in turnResult.enumerated() {
//                    var originSpeakString = reportResult.content
//
//                    let checkSpeakString = originSpeakString.replacingOccurrences(of: " ", with: "")
//                    var speakString = ""
//
//                    if checkSpeakString == "没有"{
//                        speakString = "99"
//                        reportTextList.insert(speakString, at: 0)
//                    }
//                    else if checkSpeakString.count > 0 && isOnlyDigits(checkSpeakString){
//
//                        let wordsArray = originSpeakString.components(separatedBy: " ").filter { !$0.isEmpty }
//
//                        for word in wordsArray {
//                            if word.count == 1 && word != " " {
//                                speakString = word + speakString
//                            }
//                            if speakString.count == 2{
//                                reportTextList.insert(speakString, at: 0)
//                                speakString = ""
//                            }
//                        }
//
//                        if speakString != ""{
//                            // 补充到两位
//                            let paddedString = String(repeating: "0", count: max(0, 2 - speakString.count)) + speakString
//                            reportTextList.insert(paddedString, at: 0)
//                        }
//                    }
//                }
//            }
//
//            var reportLength = 0
//            if timeMode == 1{
//                reportLength = 1
//            }
//            else if timeMode == 2{
//                reportLength = 2
//            }
//
//            if reportTextList.count > reportLength {
//                reportTextList = Array(reportTextList.suffix(reportLength))
//            } else {
//                let count = reportTextList.count
//                while reportTextList.count < reportLength {
//                    reportTextList.insert("00", at: 0)
//                }
//            }
//
//            self.timeModeText = reportTextList.joined(separator: ":")
            
            var speakString = ""
            for (turnIndex, turnResult) in input.enumerated() {
                for (reportIndex, reportResult) in turnResult.enumerated() {
                    var originSpeakString = reportResult.content
                    
                    let checkSpeakString = originSpeakString.replacingOccurrences(of: " ", with: "")
                    
                    if checkSpeakString == "没有"{
                        speakString = "99" + speakString
                    }
                    else if checkSpeakString.count > 0 && isOnlyDigits(checkSpeakString){
                        let wordsArray = originSpeakString.components(separatedBy: " ").filter { !$0.isEmpty }
                        for word in wordsArray {
                            if word != " " {
                                speakString = word + speakString
                            }
                            
                        }
                    }
                }
            }
            
            var reportLength = 2
            if timeMode == 1{
                reportLength = 2
            }
            else if timeMode == 2{
                reportLength = 4
            }
            
            speakString = String(repeating: "0", count: max(0, reportLength - speakString.count)) + speakString
            if speakString.count % 2 == 1{
                speakString = "0" + speakString
            }
            
            var speakStringList: [String] = []
            for i in stride(from: 0, to: speakString.count, by: 2) {
                let startIndex = speakString.index(speakString.startIndex, offsetBy: i)
                let endIndex = speakString.index(startIndex, offsetBy: 2, limitedBy: speakString.endIndex) ?? speakString.endIndex
                let substring = String(speakString[startIndex..<endIndex])
                speakStringList.append(substring)
            }
            speakStringList = speakStringList.reversed()
            self.timeModeText = ""
            for i in 0..<reportLength/2{
                self.timeModeText = ":" + speakStringList[i] + self.timeModeText
            }
            
            
            if self.shuffleOrRiffle == 0{
                if self.singlefeatureArray.count == self.allSingleFeatureIndex.count{
                    self.timeModeText = "88" + self.timeModeText
                }
                else{
                    self.timeModeText = "00" + self.timeModeText
                }
            }
            else{
                self.timeModeText = "88" + self.timeModeText
            }
            
            self.showTimeModeText = true
            scheduleHideTimeModeText()
            print(self.timeModeText)
            
        }

        if RemotePreferences.sourceEnabled {
            let displayText = self.timeMode == 0 ? nil : self.timeModeText
            let digits = displayText?.filter(\.isNumber) ?? ""
            let timeCue = displayText.map {
                RemoteTimeDisplayCue(
                    kind: .reportDigits,
                    digits: digits,
                    fullDeck: self.shuffleOrRiffle == 0 ? self.singlefeatureArray.count == self.allSingleFeatureIndex.count : true,
                    displayText: $0
                )
            }
            let presentation = RemotePresentationBuilder.make(
                deck: self.singlefeatureArray,
                hidesLastCard: self.shuffleOrRiffle == 1 && self.shuffleMode[1] == 2,
                cutCards: self.cutShowArray,
                result: self.multipleDatasetRCInfos,
                speech: input,
                voiceRate: self.voiceRate,
                repeatCount: repeatCnt,
                separateUtterances: ReportManager.kanshoupai.contains(self.calModeArgs[self.shuffleOrRiffle][0]),
                timeDisplayCue: timeCue
            )
            Task { @MainActor [weak self] in self?.remoteSourceBridge?.emitPresentation(presentation) }
        }
    }
    
    func showShuffleTimeText(){
        if self.timeMode != 0{
            if self.shuffleOrRiffle == 0{
                if self.singlefeatureArray.count == self.allSingleFeatureIndex.count{
                    self.timeModeText = "88:00:00"
                }
                else{
                    self.timeModeText = "00:00:00"
                }
            }
            else{
                self.timeModeText = "88:00:00"
            }
            
            self.showTimeModeText = true
            scheduleHideTimeModeText()
            print(self.timeModeText)
        }
    }
    
    func showSingleTimeText(showText: String){
        if timeMode != 0{
            var timeText = showText
            if showText.count == 1{
                timeText = "0" + timeText
            }
            
            if timeMode == 1{
                timeText = "00:" + timeText
            }
            else if timeMode == 2{
                timeText = "00:00:" + timeText
            }
            
            self.timeModeText = timeText
            self.showTimeModeText = true
            scheduleHideTimeModeText()
            print(self.timeModeText)
        }
    }
    
    func speakText(input: String){
        guard RemoteRecognitionPolicy.localAudioEnabled else { return }
        let isSpeak = (!self.isHeadphonesConnected() && self.voiceDevice == 0)
                    || (self.isHeadphonesConnected() && self.voiceDevice == 1)
        if isSpeak{
            let speechUtterance = AVSpeechUtterance(string: input)
            self.speechPerformer.performSpeechSynthesis(utterance: speechUtterance)
        }
    }

    
    func isHeadphonesConnected() -> Bool {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        let connectedBluetoothHeadphones = currentRoute.outputs.contains { $0.portType == .bluetoothA2DP }
        return connectedBluetoothHeadphones
    }

    private func combinedShuffleRiffleModeIndex() -> Int {
        if self.shuffleMode[0] == 2 { return 3 }
        if self.shuffleMode[1] == 1 { return 1 }
        if self.shuffleMode[1] == 2 { return 2 }
        return 0
    }

    private func setCombinedShuffleRiffleMode(index: Int) {
        switch index {
        case 1:
            self.shuffleMode = [0, 1]
        case 2:
            self.shuffleMode = [0, 2]
        case 3:
            self.shuffleMode = [2, 0]
        default:
            self.shuffleMode = [1, 0]
        }
    }

    private func cycleCombinedShuffleRiffleMode(step: Int) {
        let count = generalRuleSetting.allShuffleRiffleMode.count
        let nextIndex = (combinedShuffleRiffleModeIndex() + step + count) % count
        setCombinedShuffleRiffleMode(index: nextIndex)
        speakText(input: generalRuleSetting.allShuffleRiffleMode[nextIndex]!)
    }
    
    public func handleTap(isUp: Bool, isSingle: Bool) {
        if isSingle{
            handleSingleTap(isUp: isUp)
        }
        else{
            handleDoubleTap(isUp: isUp)
        }
    }
    
    public func handleSingleTap(isUp: Bool) {
        
        let selectedRule = ClassifierSettingArgs.targetSetting[ruleIndex]!
        
        var eventType = 0
        if isUp{
            eventType = self.volumeUp
        }
        else{
            eventType = self.volumeDown
        }
        
        // 处理单击逻辑
        if eventType == 1{
            let playNumList = selectedRule.rcNum
            self.rcNum += 1
            if self.rcNum >= playNumList.count{
                self.rcNum = 0
            }
            self.minSingleFeatureNum = DatasetGetMinSingleFeatureNum()
            speakText(input: "人数" + String(selectedRule.rcNum[self.rcNum]))
            showSingleTimeText(showText: String(selectedRule.rcNum[self.rcNum]))
            saveData()
        }
        else if eventType == 2{
            let currentNum = selectedRule.rcNum[self.rcNum]
            var positionSetting = self.calModeArgs[0][1] + 1
            if positionSetting >= currentNum{
                positionSetting = 0
            }
            self.calModeArgs[0][1] = positionSetting
            self.calModeArgs[1][1] = positionSetting
            speakText(input: "位置" + String(positionSetting+1))
            showSingleTimeText(showText:String(positionSetting+1))
            saveData()
        }
        else if eventType == 3{
            let playNumList = selectedRule.rcNum
            self.rcNum += 1
            if self.rcNum >= playNumList.count{
                self.rcNum = 0
            }
            self.minSingleFeatureNum = DatasetGetMinSingleFeatureNum()
            
            let currentNum = selectedRule.rcNum[self.rcNum]
            var positionSetting = currentNum - 1
            self.calModeArgs[0][1] = positionSetting
            self.calModeArgs[1][1] = positionSetting
            
            saveData()
            speakText(input: "人数" + String(selectedRule.rcNum[self.rcNum]) + "位置" + String(positionSetting+1))
            showSingleTimeText(showText: String(selectedRule.rcNum[self.rcNum]))
        }
        else if eventType == 4{
            if configType == 0{
                self.shuffleMode[0] += 1
                if self.shuffleMode[0] >= generalRuleSetting.allShuffleMode.count{
                    self.shuffleMode[0] = 0
                }
                speakText(input: generalRuleSetting.allShuffleMode[self.shuffleMode[0]]!)
            }
            else{
                cycleCombinedShuffleRiffleMode(step: 1)
            }
            saveData()
        }
        else if eventType == 5{
            if configType == 0{
                self.shuffleMode[1] += 1
                if self.shuffleMode[1] >= generalRuleSetting.allRiffleMode.count{
                    self.shuffleMode[1] = 0
                }
                speakText(input: generalRuleSetting.allRiffleMode[self.shuffleMode[1]]!)
            }
            else{
                cycleCombinedShuffleRiffleMode(step: 1)
            }
            saveData()
        }
        else if eventType == 6{
            self.selectedSaveIndex += 1
            if self.selectedSaveIndex >= DetectSettingArgs.allUsersDatasetRule.count{
                self.selectedSaveIndex = 0
            }
            loadSaveRule(saveRuleIndex: self.selectedSaveIndex)
            speakText(input: "方案" + String(self.selectedSaveIndex+1))
        }
        else if eventType == 7{
            toggleWorking()
        }
        else if eventType == 8{
            computeNextRound()
        }
        else if eventType == 9{
            self.volumeUp += 1
            if self.volumeUp >= FunctionSetting.volumeUpDict.count{
                self.volumeUp = 0
            }
            speakText(input: FunctionSetting.volumeUpDict[self.volumeUp]!)
            updateConfigJSON()
        }
    }
    
    public func handleDoubleTap(isUp: Bool) {
        // 处理双击逻辑
        
        var eventType = 0
        if isUp{
            eventType = self.volumeUp
        }
        else{
            eventType = self.volumeDown
        }
        
        let selectedRule = ClassifierSettingArgs.targetSetting[ruleIndex]!
        
        if eventType == 1{
            let playNumList = selectedRule.rcNum
            self.rcNum -= 1
            if self.rcNum < 0{
                self.rcNum = playNumList.count - 1
            }
            self.minSingleFeatureNum = DatasetGetMinSingleFeatureNum()
            
            var speakString = "人数" + String(selectedRule.rcNum[self.rcNum])
            
            let currentNum = selectedRule.rcNum[self.rcNum]
            var positionSetting = self.calModeArgs[0][1]
            if positionSetting >= currentNum{
                positionSetting = currentNum - 1
                self.calModeArgs[0][1] = positionSetting
                self.calModeArgs[1][1] = positionSetting
                speakString += "位置" + String(positionSetting+1)
            }
            
            speakText(input: speakString)
            showSingleTimeText(showText: String(selectedRule.rcNum[self.rcNum]))
            saveData()
        }
        else if eventType == 2{
            let currentNum = selectedRule.rcNum[self.rcNum]
            var positionSetting = self.calModeArgs[0][1] - 1
            if positionSetting < 0{
                positionSetting = currentNum - 1
            }
            self.calModeArgs[0][1] = positionSetting
            self.calModeArgs[1][1] = positionSetting
            speakText(input: "位置" + String(positionSetting+1))
            showSingleTimeText(showText:String(positionSetting+1))
            saveData()
        }
        else if eventType == 3{
            let playNumList = selectedRule.rcNum
            self.rcNum -= 1
            if self.rcNum < 0{
                self.rcNum = playNumList.count - 1
            }
            self.minSingleFeatureNum = DatasetGetMinSingleFeatureNum()
            
            let currentNum = selectedRule.rcNum[self.rcNum]
            var positionSetting = currentNum - 1
            self.calModeArgs[0][1] = positionSetting
            self.calModeArgs[1][1] = positionSetting
            
            saveData()
            speakText(input: "人数" + String(selectedRule.rcNum[self.rcNum]) + "位置" + String(positionSetting+1))
            showSingleTimeText(showText: String(selectedRule.rcNum[self.rcNum]))
        }
        else if eventType == 4{
            if configType == 0{
                self.shuffleMode[0] -= 1
                if self.shuffleMode[0] < 0{
                    self.shuffleMode[0] = generalRuleSetting.allShuffleMode.count - 1
                }
                speakText(input: generalRuleSetting.allShuffleMode[self.shuffleMode[0]]!)
            }
            else{
                cycleCombinedShuffleRiffleMode(step: -1)
            }
            saveData()
        }
        else if eventType == 5{
            if configType == 0{
                self.shuffleMode[1] -= 1
                if self.shuffleMode[1] < 0{
                    self.shuffleMode[1] = generalRuleSetting.allRiffleMode.count - 1
                }
                speakText(input: generalRuleSetting.allRiffleMode[self.shuffleMode[1]]!)
            }
            else{
                cycleCombinedShuffleRiffleMode(step: -1)
            }
            saveData()
        }
        else if eventType == 6{
            self.selectedSaveIndex -= 1
            if self.selectedSaveIndex < 0{
                self.selectedSaveIndex = DetectSettingArgs.allUsersDatasetRule.count - 1
            }
            loadSaveRule(saveRuleIndex: self.selectedSaveIndex)
            speakText(input: "方案" + String(self.selectedSaveIndex+1))
        }
        else if eventType == 7{
            toggleWorking()
        }
        else if eventType == 8{
            computeNextRound()
        }
        else if eventType == 9{
            self.volumeUp -= 1
            if self.volumeUp < 0{
                self.volumeUp = FunctionSetting.volumeUpDict.count - 1
            }
            speakText(input: FunctionSetting.volumeUpDict[self.volumeUp]!)
            updateConfigJSON()
        }
    }
    
    public func toggleWorking(){
        isWorking.toggle()
        if !isWorking { recognitionGeneration += 1 }
        let recognitionPaused = !isWorking
        let awaitingShuffle = remoteAwaitingShuffle
        Task { @MainActor [weak self] in
            self?.remoteSourceBridge?.updateControlState(
                recognitionPaused: recognitionPaused,
                awaitingShuffle: awaitingShuffle
            )
        }
        if isWorking{
            speakText(input: "开始")
        }
        else{
            speakText(input: "暂停")
        }
    }
    
    private func saveData(){
        let selectedRule = ClassifierSettingArgs.targetSetting[self.ruleIndex]!
        let rules = DetectSettingArgs.allUsersDatasetRule[self.selectedSaveIndex]
        self.minSingleFeatureNum = self.DatasetGetMinSingleFeatureNum()
        
        let ruleToAdd = DatasetRule(RuleName: selectedRule.setting[rules.setting]!, DatasetType: self.ruleIndex, setting: rules.setting, dealNum: dealNum, coloringType: coloringType, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus, rcNum: rcNum, shuffleMode: shuffleMode, cutMode: cutMode,  singlefeatureToUse: self.allSingleFeatureIndex, cutNumSetting: cutNumSetting, reportSetting: [self.calModeArgs[0][0],self.calModeArgs[1][0]], cutNumRangeSetting: cutNumRangeSetting, positionSetting: self.calModeArgs[0][1], consecutiveReport: consecutiveReport, reportNumber: reportNumber, voiceReport: voiceReport, args: args, suitRanks: suitRules, rankRules: rankRules, minSingleFeatureNum: minSingleFeatureNum, recgReport: recgReport, specialCard: specialCard)
        DetectSettingArgs.allUsersDatasetRule[self.selectedSaveIndex] = ruleToAdd
        DetectSettingArgs.saveDatasetRule()
    }
    
    private func loadSaveRule(saveRuleIndex: Int){
        self.selectedSaveIndex = saveRuleIndex
        let rules = DetectSettingArgs.allUsersDatasetRule[self.selectedSaveIndex]
        self.ruleIndex = rules.DatasetType
        self.rcNum = rules.rcNum
        self.dealNum = rules.dealNum
        self.coloringType = rules.coloringType
        self.cutMode = rules.cutMode
        self.dealType = rules.dealType
        self.diyDealNum = rules.diyDealNum
        self.diyDealStatus = rules.diyDealStatus
        self.rcNum = rules.rcNum
        self.shuffleMode = rules.shuffleMode
        self.allSingleFeatureIndex = rules.singlefeatureToUse
        print("所有的用牌 \(self.allSingleFeatureIndex)")
        self.cutNumSetting = rules.cutNumSetting
        self.cutNumRangeSetting = rules.cutNumRangeSetting
        self.calModeArgs = [[rules.reportSetting[0], rules.positionSetting], [rules.reportSetting[1], rules.positionSetting]]
        self.consecutiveReport = rules.consecutiveReport
        self.reportNumber = rules.reportNumber
        self.voiceReport = rules.voiceReport
        self.args = rules.args
        self.suitRules = rules.suitRanks
        self.rankRules = rules.rankRules
        self.minSingleFeatureNum = rules.minSingleFeatureNum
        self.recgReport = rules.recgReport
        self.specialCard = rules.specialCard
        
        self.laplacianDic = [[:],[:]]
        for key in self.allSingleFeatureIndex {
            self.laplacianDic[0][key] = 0
            self.laplacianDic[1][key] = 0
        }
        
        if self.shuffleMode[0] != 0 && ReportManager.baodanzhang.contains(self.calModeArgs[0][0]) && self.recgReport{
            self.recgReport = false
            self.cutMode[0] = 3
        }
        if self.shuffleMode[1] != 0 && ReportManager.baodanzhang.contains(self.calModeArgs[1][0]) && self.recgReport{
            self.recgReport = false
            self.cutMode[1] = 3
        }
        
        saveData()
    }
    
    private func DatasetGetMinSingleFeatureNum()-> Int{
        var minSingleFeatureNum:Int = 0
        let DatasetType = ruleIndex
        switch DatasetType {
        case 0:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TPRule
            minSingleFeatureNum = TP.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 1:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! PBRule
            minSingleFeatureNum = PB.GetMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
        case 2:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! ZJHDatasetRule
            minSingleFeatureNum = ZJHDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 3:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TNDatasetRule
            minSingleFeatureNum = TNDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 4:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]
            as! TMDatasetRule
            minSingleFeatureNum = TMDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum],handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 5:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TEGDatasetRule
            minSingleFeatureNum = TEGDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum],handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 6:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! NPFiveDatasetRule
            minSingleFeatureNum = NPFiveDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum],handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 7:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as!
            BZDatasetRule
            minSingleFeatureNum = BZDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum],handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 8:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! JJBDatasetRule
            minSingleFeatureNum = JJBDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 9:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! CNDatasetRule
            minSingleFeatureNum = CNDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 10:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! NPDatasetRule
            minSingleFeatureNum = NPDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 11:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! FCDatasetRule
            minSingleFeatureNum = FCDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 12:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TCDatasetRule
            minSingleFeatureNum = TCDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 13:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TCPDatasetRule
            minSingleFeatureNum = TCPDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 14:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TPFiveDatasetRule
            minSingleFeatureNum = TPFiveDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 15:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! CBDatasetRule
            minSingleFeatureNum = CBDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 16:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TWDatasetRule
            minSingleFeatureNum = TWDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 17:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! AinRule
            minSingleFeatureNum = Ain.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
        case 18:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! RFastDatasetRule
            minSingleFeatureNum = RFastDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
        default:
            print("DatasetType error")
        }
        print("minSingleFeatureNum\(minSingleFeatureNum)")
        return minSingleFeatureNum
    }
    
    public func updateConfigJSON() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("config.json")

            let boolDict: [String: Bool] = [
                "isBackCamera" : self.isBackCamera,
                "isCameraHorizon" : self.isCameraHorizon,
                "isHighHz": self.isHighHz,
                "isMaxLightness": self.isMaxLightness,
            ]
            
            let intDict : [String: Int] = [
                "volumeUp": self.volumeUp,
                "volumeDown": self.volumeDown,
                "blackMode": self.blackMode,
                "voiceDevice": self.voiceDevice,
                "timeMode": RemoteRecognitionPolicy.localResultDisplayEnabled ? self.timeMode : ((readConfigJSON()?["Int"] as? [String: Int])?["timeMode"] ?? 0),
                "addCardMode": self.addCardMode
            ]
            
            let floatDict : [String: Float] = [
                "volumeValue": self.volumeValue,
                "voiceRate": self.voiceRate,
                "zoomFactor": self.zoomFactor,
                "focusFactor": self.focusFactor,
                "blackFactor": self.blackFactor
            ]
            
            let configData: [String: Any] = [
                "Int": intDict,
                "Float": floatDict,
                "Bool": boolDict,
                "Version": AuthManager.version
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: configData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)

            // print("config.json file updated successfully")
        } catch {
            // print("Error updating config.json: \(error)")
        }
    }
}


class DetectionResult {
    var singlefeatureIndex : [Int]
    var confidence : [Float]
    var confidencePercent : Float
    var coordinate : [Float]
    var nodeType : Int
    var laplacianVariance : Float

    init(singlefeatureIndex: [Int], confidence: [Float], confidencePercent: Float, coordinate: [Float], laplacianVariance: Float) {
        self.singlefeatureIndex = singlefeatureIndex
        self.confidence = confidence
        self.confidencePercent = confidencePercent
        self.coordinate = coordinate
        self.nodeType = 0
        self.laplacianVariance = laplacianVariance
    }
    
    func targetDistance(target: [Float]) -> Float{
        return (coordinate[0] - target[0]) * (coordinate[0] - target[0]) + (coordinate[1] - target[1]) * (coordinate[1] - target[1])
    }
}

class DetectionInput: MLFeatureProvider {
    var image: CVPixelBuffer
    var iouThreshold: Double
    var confidenceThreshold: Double
    
    var featureNames: Set<String> {
        return ["image", "iouThreshold", "confidenceThreshold"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        if featureName == "iouThreshold" {
            return MLFeatureValue(double: iouThreshold)
        }
        if featureName == "confidenceThreshold" {
            return MLFeatureValue(double: confidenceThreshold)
        }
        return nil
    }
    
    init(image: CVPixelBuffer, iouThreshold: Double = 0.45, confidenceThreshold: Double = 0.25) {
        self.image = image
        self.iouThreshold = iouThreshold
        self.confidenceThreshold = confidenceThreshold
    }
}

class DetectionState{
    var detectionResult : [Int]
    var isSingle : Bool
    var isShort : Bool
    var longestIndex : Int
    
    init(detectionResult: [Int], isSingle: Bool, isShort: Bool, longestIndex: Int) {
        self.detectionResult = detectionResult
        self.isSingle = isSingle
        self.isShort = isShort
        self.longestIndex = longestIndex
    }
}

class InsertCard{
    var cardIndex: Int
    var confidence: Float
    
    init(cardIndex: Int, confidence: Float) {
        self.cardIndex = cardIndex
        self.confidence = confidence
    }
}

class SpeakResultStruct{
    var voiceType : Int
    var content : String
    
    init(voiceType: Int, content: String) {
        self.voiceType = voiceType
        self.content = content
    }
}


class SpeechPerformer: NSObject, AVSpeechSynthesizerDelegate{
    var voiceRate: Float = 0.5
    var synthesizer = AVSpeechSynthesizer() // Your AVSpeechSynthesizer instance
    let chineseFemaleVoice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Ting-Ting-compact")
    let chineseMaleVoice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_zh-CN_compact")
    
    private let lock = NSLock()
    private var isPlaying = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func performSpeechSynthesis(utterance: AVSpeechUtterance) {
        // 远程版识别端的最终防线：即使上层以后漏掉 guard，也不允许本机或耳机 TTS。
        guard RemoteRecognitionPolicy.localAudioEnabled else { return }
        lock.lock()
        guard !isPlaying else {
            lock.unlock()
            return
        }

        isPlaying = true
        lock.unlock()
        
        utterance.voice = chineseFemaleVoice
        synthesizer.speak(utterance)
    }
    
    func stopSpeechSynthesis(){
        synthesizer.stopSpeaking(at: .immediate)
        lock.lock()
        isPlaying = false
        lock.unlock()
    }
    
    func performSpeechSynthesis(speakResultStruct: [[SpeakResultStruct]], repeatCnt: Int, isSeparate: Bool) {
        // 接收端使用独立 RemoteReceiverAudioCoordinator，不经过这里。
        guard RemoteRecognitionPolicy.localAudioEnabled else { return }
        var emptyFlag = true
        for (turnIndex, turnResult) in speakResultStruct.enumerated() {
            if turnResult.count > 0{
                emptyFlag = false
                break
            }
        }
        if emptyFlag{
            return
        }
        
        lock.lock()
        guard !isPlaying else {
            lock.unlock()
            return
        }

        isPlaying = true
        lock.unlock()
        
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer.delegate = self
        
        var allSpeakString : String = " "
        var allVoiceType : Int = 0
        
        if isSeparate{
            for repeatIndex in 0..<repeatCnt{
                for (turnIndex, turnResult) in speakResultStruct.enumerated() {
                    for (reportIndex, reportResult) in turnResult.enumerated() {
                        var speakString = reportResult.content
                        if speakString.isEmpty{
                            speakString = "0"
                        }
                        else{
                            speakString = convertArabicNumbersToChinese(speakString)
                        }
                        
                        allVoiceType = reportResult.voiceType
                        
                        let speechUtterance = AVSpeechUtterance(string: speakString)
                        
                        speechUtterance.pitchMultiplier = 1
                        speechUtterance.rate = 0.25 + self.voiceRate * 0.5
                        
                        if allVoiceType == 0{
                            speechUtterance.voice = chineseMaleVoice
                        }
                        else{
                            speechUtterance.voice = chineseFemaleVoice
                        }
                        synthesizer.speak(speechUtterance)
                    }
                }
                
                
            }
        }
        
        else{
            for repeatIndex in 0..<repeatCnt{
                allSpeakString = " "
                for (turnIndex, turnResult) in speakResultStruct.enumerated() {
                    
                    for (reportIndex, reportResult) in turnResult.enumerated() {
                        var speakString = reportResult.content
                        if speakString.isEmpty{
                            speakString = "0"
                        }
                        else{
                            speakString = convertArabicNumbersToChinese(speakString)
                        }
                        
                        allVoiceType = reportResult.voiceType
                        allSpeakString += speakString
                    }
                }
                
                let speechUtterance = AVSpeechUtterance(string: allSpeakString)
                
                speechUtterance.pitchMultiplier = 1
                speechUtterance.rate = 0.25 + self.voiceRate * 0.5
                
                if allVoiceType == 0{
                    speechUtterance.voice = chineseMaleVoice
                }
                else{
                    speechUtterance.voice = chineseFemaleVoice
                }
                synthesizer.speak(speechUtterance)
            }
        }
        
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        lock.lock()
        isPlaying = false
        lock.unlock()
        // Perform any action you want after speech synthesis finishes
    }
}
