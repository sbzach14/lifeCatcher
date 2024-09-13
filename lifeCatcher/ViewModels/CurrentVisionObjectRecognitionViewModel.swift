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
    
    @Published var cameraImage : CGImage?
    @Published var isShowSingleFeature : Bool = false
    @Published var isCamereSetting : Bool = false
    
    @Published var singlefeatureArray :  [Int] = []
    @Published var multipleDatasetRCInfos: ReportManager.MultipleReportResultInfo = ReportManager.MultipleReportResultInfo()
    @Published var leftSingleFeatures: [Int] = []
    @Published var usedSingleFeatures: [Int] = []
    @Published var cutStructArray: [cutStruct] = []
    @Published var cutShowArray : [Int] = []
    
    let detectModel = try! detect_0903_copy()
    let clsModel_h = try! cls_0715_h_trans_copy()
    let clsModel_v = try! cls_0727_v_trans_copy()
//    let detectModel = try! detect_0903()
//    let clsModel_h = try! cls_0715_h_trans()
//    let clsModel_v = try! cls_0727_v_trans()
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
    public var isAddCard: Bool = false
    
    //测试用的定时器
    public var ding: Int = 0
    public var ciimageQueue: [CIImage] = []
    
    let idleRate = 30
    let context = CIContext()
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
    @Published var volumeUp: Int = 0
    @Published var volumeDown: Int = 0
    @Published var blackMode: Int = 0
    @Published var voiceDevice: Int = 0
    @Published var volumeValue: Float = 0.5
    @Published var voiceRate: Float = 0.5
    @Published var zoomFactor: Float = 0
    @Published var focusFactor: Float = 0.6
    
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
    
    override init(){
        
        super.init()
        
        // Load data from config.json
        if let configData = readConfigJSON() {
            let boolDict = configData["Bool"] as! [String : Bool]
            self.isBackCamera = boolDict["isBackCamera"]!
            self.isCameraHorizon = boolDict["isCameraHorizon"]!
            
            let intDict = configData["Int"] as! [String : Int]
            self.volumeUp = intDict["volumeUp"]!
            self.volumeDown = intDict["volumeDown"]!
            self.blackMode = intDict["blackMode"]!
            self.voiceDevice = intDict["voiceDevice"]!
            
            let floatDict = configData["Float"] as! [String : Float]
            self.volumeValue = floatDict["volumeValue"]!
            self.voiceRate = floatDict["voiceRate"]!
            self.zoomFactor = floatDict["zoomFactor"]!
            self.focusFactor = floatDict["focusFactor"]!
        }
        
        self.isWorking = true
        
        if self.blackMode == 1{
            self.isBlack = true
        }
        
        self.speechPerformer.voiceRate = self.voiceRate
        
    }
    
    func initialize(saveRuleIndex: Int) {
        
        setupAVCapture()
        configureAudioSession()
        
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
    
    private func initDetectResult(){
        detectResultList.removeAll()
        stateCounter = 0
        shuffleStartCounter = 0
        shuffleResetCounter = 0
        isDetect = false
        detectSet.removeAll()
    }
    
    private func initShuffle(){
        singlefeatureArray = []
        cutStructArray = []
        cutShowArray = []
        self.leftSingleFeatures = []
        self.usedSingleFeatures = []
        multipleDatasetRCInfos = ReportManager.MultipleReportResultInfo()
    }
    
    private func initBoxes(){
        centerPos = [0.5, 0.5]
        lastBoxes = [[0.02, 0.02, 0.01, 0.01], [0.98, 0.98, 0.02, 0.02]]
        targetArea = [0,0,0,0]
        initTargetArea = [0, 0, 0, 0]
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
        //        do {
        //            startAudioRC = try AVAudioPlayer(contentsOf: startSoundURL!)
        //            startAudioRC?.delegate = self
        //            startAudioRC?.prepareToPlay()
        //            successAudioRC = try AVAudioPlayer(contentsOf: successSoundURL!)
        //            successAudioRC?.delegate = self
        //            successAudioRC?.prepareToPlay()
        //            failAudioRC = try AVAudioPlayer(contentsOf: failSoundURL!)
        //            failAudioRC?.delegate = self
        //            failAudioRC?.prepareToPlay()
        //        } catch {
        //            // print("Error playing sound: \(error.localizedDescription)")
        //        }
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
            
            // 获取当前帧率
            let videoFrameRate = format.videoSupportedFrameRateRanges.first!.maxFrameRate
            // print("设定帧率: \(videoFrameRate)")
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
        // print("开启相机")
    }
    
    func startCamera() {
        session.startRunning()
        changeCameraFrameRate(to: self.idleRate)
        // print("开启相机")
    }
    
    func stopCamera() {
        session.stopRunning()
        // print("关闭相机")
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
            
            
            if frameRate == idleRate{
                //device.exposureMode = .continuousAutoExposure
                device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(60)), iso: device.activeFormat.maxISO/4)
                //device.setExposureTargetBias(0)
            }
            else{
                //self.captureDevice.exposureMode = .autoExpose
                
                //不拨牌 且是前置
                if frameRate == 120{
                    device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(180)), iso: device.activeFormat.maxISO)
                }
                else{
                    device.setExposureModeCustom(duration: CMTime(value: 1, timescale: Int32(frameRate)), iso: device.activeFormat.maxISO)
                }
                //device.setExposureTargetBias(1.5)
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
            print("实时帧率\(frameRate)fps")
            timestamp = currentTimestamp
            // 重置计数器
            frameCount = 0
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
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        var indexGap = 4
        if self.isBackCamera{
            indexGap = 8
        }
        
        let isTargetArea = self.isTargetArea
        var targetArea = Array(self.targetArea)
        
        if self.isWorking{
            
            self.detectionQueue.async {
                
                if targetArea.count == 4{
                    if isTargetArea{
                        let cvPixelBuffer = createCVPixelBuffer(ciImage: ciImage, targetSize: CGSize(width: self.inputSize[0], height: self.inputSize[1]), targetArea: targetArea)!
                        
                        self.processImageOrigin(cvPixelBuffer, taskIndex: myIndex, isTargetArea: isTargetArea, targetArea: targetArea)
                    }
                    else{
                        let cvPixelBuffer = createCVPixelBuffer(ciImage: ciImage, targetSize: CGSize(width: self.detectSize[0], height: self.detectSize[1]), targetArea: targetArea)!
                        
                        self.processImageOrigin(cvPixelBuffer, taskIndex: myIndex, isTargetArea: isTargetArea, targetArea: targetArea)
                    }
                }
            }
        }
        
        if !self.isBlack
            && !self.isShowSingleFeature
            && self.isWorking
            && (self.cameraFrameRate <= idleRate || self.taskIndex % indexGap == 0){
            backgroundQueue.async {
                do{
//                    var rectList : [[Float]] = []
//                    rectList.append(self.lastBoxes[0])
//                    rectList.append(self.lastBoxes[1])
//                    rectList.append(self.targetArea)
//                    let drawcvpixelbuffer = drawRectanglesOnPixelBuffer(pixelBuffer: pixelBuffer, rectList: rectList)!
//                    ciImage = CIImage(cvPixelBuffer: drawcvpixelbuffer)
                
                    let transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    
                    let rotationTransform = CGAffineTransform(rotationAngle: -.pi / 2)  // 顺时针旋转90度
                    
                    let xOffset = ciImage.extent.size.height * 0.5
                    let translationTransform = CGAffineTransform(translationX: xOffset, y: CGFloat(0))
                    
                    let combinedTransform = rotationTransform.concatenating(translationTransform)
                    
                    let translatedImage = ciImage.transformed(by: combinedTransform)
                    
                    let outputCGImage = self.context.createCGImage(translatedImage, from: translatedImage.extent)
                    
                    DispatchQueue.main.async {
                        self.cameraImage = outputCGImage
                    }
                }
                
                catch{
                    // print("Error: \(error)")
                }
            }
        }
        
        // 释放视频帧资源
        CMSampleBufferInvalidate(sampleBuffer)
        
    }
    
    func processImageOrigin(_ pixelBuffer: CVPixelBuffer, taskIndex: Int, isTargetArea: Bool, targetArea: [Float]){
        
        let detectConfidenceThreshold:Float = 0.8
        let detectConfidenceMinThreshold:Float = 0.5
        
        var confidenceThreshold: Float = 0
        if self.state == "idle"{
            confidenceThreshold = 0.7
        }
        else{
            confidenceThreshold = 0.2
        }
        
        var singlefeatureResult : [DetectionResult]
        if !isTargetArea{
            let result = try! self.detectModel.prediction(image: pixelBuffer, iouThreshold: 0.01, confidenceThreshold: Double(confidenceThreshold))
            singlefeatureResult = getSingleFeature(from: result.confidence, from: result.coordinates, from: pixelBuffer, iscls: false)
        }
        else if self.isCameraHorizon{
            let result = try! self.clsModel_h.prediction(image: pixelBuffer, iouThreshold: 0.01, confidenceThreshold: Double(confidenceThreshold))
            singlefeatureResult = getSingleFeature(from: result.confidence, from: result.coordinates, from: pixelBuffer)
        }
        else{
            let result = try! self.clsModel_v.prediction(image: pixelBuffer, iouThreshold: 0.01, confidenceThreshold: Double(confidenceThreshold))
            singlefeatureResult = getSingleFeature(from: result.confidence, from: result.coordinates, from: pixelBuffer)
        }
        
        
        
        //            // 创建输入
        //            let input = try! DetectionInput(image: pixelBuffer,
        //                                           iouThreshold: 0.45,
        //                                           confidenceThreshold: confidenceThreshold)
        //
        //            // 进行预测
        //            let prediction = try! mlmodel.prediction(from: input)
        //
        //            // 处理预测结果
        //            let confidence = prediction.featureValue(for: "confidence")!.multiArrayValue!
        //            let coordinates = prediction.featureValue(for: "coordinates")!.multiArrayValue!
        //            singlefeatureResult = getSingleFeature(from: confidence, from: coordinates, from: pixelBuffer)
        
        
        
        DispatchQueue.main.async{
            
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
            
            
            if self.state == "idle"{
                if detectNum > 0 && self.stateCounter >= 1{
                    
                    // print("进入识别")
                    
                    self.stateCounter = 0
                    self.state = "detecting"//cut or riffle
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                    //self.changeCameraFrameRate(to: Int(30))
                    var stateResult : [[Float]] = []
                    if singlefeatureResult[0].singlefeatureIndex[0] != -1{
                        stateResult.append(singlefeatureResult[0].coordinate)
                    }
                    if singlefeatureResult[1].singlefeatureIndex[0] != -1{
                        stateResult.append(singlefeatureResult[1].coordinate)
                    }
                    
                    self.targetArea = self.computeTargetArea(stateResult: stateResult)
                    self.isTargetArea = true
                    
                    if self.cutMode[self.shuffleOrRiffle] != 0
                        || self.specialCard[self.shuffleOrRiffle] != 0
                        || self.recgReport{
                        self.detectNeedToCut = true
                    }
                }
            }
            
            if self.state != "idle" && isTargetArea && self.isTargetArea{
                
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
                
                if detectNum == 0 || detectConfidence < confidenceThreshold{
                    self.stateCounter += 1
                }
                else{
                    self.stateCounter = 0
                }
                
                let isShuffle = detectNum == 2 && self.shuffleMode[0] != 0 && !isSame
                let isRiffle = detectNum == 1 && self.shuffleMode[1] != 0
                
                //一边够大，另一边小或者一样
                let isCut = detectConfidence >= detectConfidenceThreshold
                && self.detectNeedToCut
                //&& (minDetectConfidence < detectConfidenceMinThreshold || isSame)
                
                
                if !self.isDetect && detectConfidence >= detectConfidenceThreshold{
                    if isRiffle{
                        self.isDetect = true
                        self.speakText(input: 0)
                    }
                    else if minDetectConfidence >= detectConfidenceMinThreshold && isShuffle {
                        if leftDetectSingleFeature == self.stateSingleFeature[0]
                            && rightDetectSingleFeature == self.stateSingleFeature[1]{
                            self.shuffleStartCounter += 1
                        }
                        else{
                            self.shuffleStartCounter = 0
                        }
                        
                        if self.shuffleStartCounter >= 5{
                            self.isDetect = true
                            self.speechPerformer.stopSpeechSynthesis()
                            self.detectNeedToCut = false
                            self.speakText(input: 0)
                            self.state = "shuffle"
                            self.initTargetArea = self.updateTargetArea(coordinates: [singlefeatureResult[0].coordinate, singlefeatureResult[1].coordinate], targetArea: targetArea)
                            
                        }
                    }
                }
                
                if self.isDetect && self.state == "shuffle" && self.targetAreaMove(initTargetArea: self.initTargetArea, targetArea: targetArea) && self.detectSet.count < 10{
                    self.shuffleResetCounter += 1
                }
                else if self.isDetect && self.state == "shuffle" && (detectNum != 2 || minDetectConfidence < confidenceThreshold) && self.detectSet.count < 10{
                    self.shuffleResetCounter += 1
                }
                else if self.isDetect && self.state == "shuffle"{
                    self.shuffleResetCounter = 0
                }
                
                
                if self.shuffleResetCounter > 5{
                    self.initDetectResult()
                }
                
//                print("\(self.singlefeatureLabelDic[leftDetectSingleFeature] ?? "null")  \(leftConfidence)  \(self.singlefeatureLabelDic[rightDetectSingleFeature] ?? "null")  \(rightConfidence) detectNeedToCut\(self.detectNeedToCut)")
                
                if isCut{
                    
                    self.detectNeedToCut = false
                    
                    if self.usedSingleFeatures.contains(detectSingleFeature) && self.recgReport {
                        self.computeNextRound()
                    }
                    else if self.singlefeatureArray.contains(detectSingleFeature){
                        
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
                            }
                        }
                        else if self.cutMode[self.shuffleOrRiffle] == 3{
                            //连续切牌
                            self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 0))
                            isCutDone = true
                            self.cutShowArray.append(detectSingleFeature)
                        }
                        
                        if !isCutDone{
                            if self.specialCard[self.shuffleOrRiffle] == 1{
                                var cnt = 0
                                for lastCutStrucht in self.cutStructArray{
                                    if lastCutStrucht.cutMode == 3{
                                        cnt += 1
                                    }
                                }
                                //看手
                                if cnt == 0{
                                    self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 3))
                                    isCutDone = true
                                    self.cutShowArray.append(detectSingleFeature)
                                }
                            }
                            else if self.specialCard[self.shuffleOrRiffle] == 2{
                                //看色
                                var cnt = 0
                                for lastCutStrucht in self.cutStructArray{
                                    if lastCutStrucht.cutMode == 2{
                                        cnt += 1
                                    }
                                }
                                if cnt < self.getWatchColorNumber(){
                                    self.cutStructArray.append(cutStruct(cutcardIndex: detectSingleFeature, cutMode: 2))
                                    isCutDone = true
                                }
                            }
                        }
                        
                        if isCutDone{
                            self.computeWinnerRC(isReset: true)
                        }
                        
                    }
                }
                
                if self.stateCounter >= 5{
                    
                    self.stateCounter = 0
                    self.state = "idle"
                    self.changeCameraFrameRate(to: self.idleRate)
                    let detectState = self.handleDetecResultList(targetDetecResultList: self.detectResultList)
                    self.initBoxes()
                    self.initDetectResult()
                    
                    if !detectState.isSingle && !detectState.isShort && self.shuffleMode[0] != 0{
                        //洗牌
                        self.shuffleOrRiffle = 0
                        self.initShuffle()
                        self.singlefeatureArray = detectState.detectionResult
                        
                        if self.singlefeatureArray.count == self.allSingleFeatureIndex.count{
                            self.speakText(input: 1)
                        }
                        else{
                            self.speakText(input: 2)
                        }
                        
                        if self.cutMode[0] == 0  && self.specialCard[0] == 0{
                            self.computeWinnerRC(isReset: true)
                        }
                    }
                    else if detectState.isSingle && !detectState.isShort && self.shuffleMode[1] != 0{
                        //拨牌
                        self.shuffleOrRiffle = 1
                        self.initShuffle()
                        self.singlefeatureArray = detectState.detectionResult
                        
                        if self.shuffleMode[1] == 1{
                            //拨到顶
                            if self.singlefeatureArray.count >= self.minSingleFeatureNum{
                                //self.speakText(input: 1)
                            }
                            else{
                                //self.speakText(input: 2)
                            }
                        }
                        
                        else if self.shuffleMode[1] == 2{
                            //拨中间
                            if self.singlefeatureArray.count > 0{
                                self.singlefeatureArray.remove(at: 0)
                            }
                            
                            if self.singlefeatureArray.count >= self.minSingleFeatureNum{
                                //self.speakText(input: 1)
                            }
                            else{
                                //self.speakText(input: 2)
                            }
                        }
                        
                        
                        if self.cutMode[1] == 0 && self.specialCard[1] == 0{
                            self.computeWinnerRC(isReset: true)
                        }
                    }
                }
                
                //识别过程
                else if taskIndex >= 0 && self.isDetect{
                    
                    if leftConfidence > detectConfidenceMinThreshold{
                        self.detectSet.insert(leftDetectSingleFeature)
                    }
                    if rightConfidence > detectConfidenceMinThreshold{
                        self.detectSet.insert(rightDetectSingleFeature)
                    }
                    
                    if self.detectSet.count >= 10
                    {
                        self.initTargetArea = self.targetArea
                    }
                    
                    self.detectResultList[taskIndex] = singlefeatureResult
                    
                    var stateResult : [[Float]] = []
                    
                    if self.state == "shuffle" && leftDetectSingleFeature != -1 && rightDetectSingleFeature != -1{
                        stateResult.append(singlefeatureResult[0].coordinate)
                        stateResult.append(singlefeatureResult[1].coordinate)
                        self.targetArea = self.updateTargetArea(coordinates: stateResult, targetArea: targetArea)
                    }
                    else{
                        if singlefeatureResult[0].singlefeatureIndex[0] != -1{
                            stateResult.append(singlefeatureResult[0].coordinate)
                        }
                        if singlefeatureResult[1].singlefeatureIndex[0] != -1{
                            stateResult.append(singlefeatureResult[1].coordinate)
                        }
                        self.targetArea = self.updateTargetArea(coordinates: stateResult, targetArea: targetArea)
                    }
                }
            }
        }
        
        //        let modelCIImage = CIImage(cvPixelBuffer: pixelBuffer)
        //        let cgImage = CIContext().createCGImage(modelCIImage, from: modelCIImage.extent)
        //        let savedUIImage = UIImage(cgImage: cgImage!)
        //        UIImageWriteToSavedPhotosAlbum(savedUIImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
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
        let longHeadIndex = 5
        
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
            
            let nowConfidence0 = targetDetecResultList[detectResultListIndex]![0].confidence[0]
            let nowConfidence1 = targetDetecResultList[detectResultListIndex]![1].confidence[0]
            if nowConfidence0 < 0.1 && nowConfidence1 < 0.1{
                deleteKeys.append(detectResultListIndex)
            }
            
            
            
            let dRNode0 = targetDetecResultList[detectResultListIndex]![0]
            let dRNode1 = targetDetecResultList[detectResultListIndex]![1]
            
            let nowN0 = dRNode0.singlefeatureIndex[0]
            let nowN1 = dRNode1.singlefeatureIndex[0]
            
            //            print("index ", detectResultListIndex,
            //                  singlefeatureLabelDic[nowN0] ?? "none", dRNode0.nodeType, dRNode0.laplacianVariance, dRNode0.confidence[0], detectResultListIndex,
            //                  singlefeatureLabelDic[nowN1] ?? "none", dRNode1.nodeType, dRNode1.laplacianVariance, dRNode1.confidence[0])
        }
        
        sortedKeys = sortedKeys.filter { !deleteKeys.contains($0) }
        
        var beginIndex = 2
        var endIndex = sortedKeys.count-3
        
        if beginIndex >= endIndex{
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
        if leftSideCnt + rightSideCnt >= self.minSingleFeatureNum{
            isShort = false
        }
        
        if !isShort{
            //如果两侧都有 则要找到两侧都是链的时候开始 即两侧都是3
            if !isSingle
            {
                beginIndex = longHeadIndex
                for keyIndex in beginIndex..<endIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    if targetDetecResultList[detectResultListIndex]![0].nodeType == 3
                        && targetDetecResultList[detectResultListIndex]![1].nodeType == 3{
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
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                if detectResultNode.nodeType == 2{
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
            addEndIndex = leftTailLong
        }
        
        if beginIndex >= endIndex{
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
                if nodeIndex.count > 0 && (isAddCard || confidenceDic[key]! > 0.7){
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
                if nodeIndex.count > 0 && (isAddCard || confidenceDic[key]! > 0.7){
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
        if isAddCard && isShuffle && beginIndex < addEndIndex && lostNum <= 2{
            
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
                      singlefeatureLabelDic[nowNum0] ?? "none", "type\(detectResultNode0.nodeType)", detectResultNode0.laplacianVariance, detectResultNode0.confidence[0], detectResultListIndex,
                      singlefeatureLabelDic[nowNum1] ?? "none", "type\(detectResultNode1.nodeType)", detectResultNode1.laplacianVariance, detectResultNode1.confidence[0])
                
                var insertCard0 : InsertCard
                var insertCard1 : InsertCard
                
                if nodeType0 == 2{
                    insertCard0 = InsertCard(cardIndex: nowNum0, confidence: max(lastDetectResultNode0.confidence[0], detectResultNode0.confidence[0]))
                }
                else{
                    insertCard0 = InsertCard(cardIndex: nowNum0, confidence: detectResultNode0.confidence[0])
                }
                
                if nodeType1 == 2{
                    insertCard1 = InsertCard(cardIndex: nowNum1, confidence: max(lastDetectResultNode1.confidence[0], detectResultNode1.confidence[0]))
                }
                else{
                    insertCard1 = InsertCard(cardIndex: nowNum1, confidence: detectResultNode1.confidence[0])
                }
                
                if isSingle{
                    if nodeType0 == 2{
                        detectSingleFeatureArray.insert(insertCard0, at: 0)
                    }
                    else if (nodeType0 == 0 || nodeType0 == 4) && nowNum0 != -1 && detectResultNode0.confidence[0] > 0.75{
                        detectSingleFeatureArray.insert(insertCard0, at: 0)
                    }
                    
                    if nodeType1 == 2{
                        detectSingleFeatureArray.insert(insertCard1, at: 0)
                    }
                    else if (nodeType1 == 0 || nodeType1 == 4) && nowNum1 != -1 && detectResultNode1.confidence[0] > 0.75{
                        detectSingleFeatureArray.insert(insertCard1, at: 0)
                    }
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
        print(detectSingleFeatureArray.count)
        for singlefeature in detectSingleFeatureArray {
            if let existIndex = uniqueArray.firstIndex(of: singlefeature.cardIndex){
                if singlefeature.confidence > confidenceDic[singlefeature.cardIndex] ?? 0{
                    confidenceDic[singlefeature.cardIndex] = singlefeature.confidence
                    uniqueArray.append(singlefeature.cardIndex)
                    uniqueArray.remove(at: existIndex)
                    print("delete chain \(detectSingleFeatureArray._index(at: singlefeature.cardIndex)) \(existIndex)/\(uniqueArray.count) \(singlefeatureLabelDic[singlefeature.cardIndex]!)")
                }
            }
            else {
                confidenceDic[singlefeature.cardIndex] = singlefeature.confidence
                uniqueArray.append(singlefeature.cardIndex)
            }
        }
        
        isShort = uniqueArray.count < self.minSingleFeatureNum
        
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
    
    
    // MARK: compute targetArea
    func computeTargetArea(stateResult: [[Float]])-> [Float]{
        
        var originBoxes = stateResult
        var targetArea:[Float] = [0,0,0,0]
        
        var w = self.imageSize[0]
        var h = self.imageSize[1]
        
        var boxfactor:Float = 1.5
        
        if originBoxes.count == 1{
            
            let minX = self.originSize[0] * (originBoxes[0][0] - originBoxes[0][2] / 2)
            let maxX = self.originSize[0] * (originBoxes[0][0] + originBoxes[0][2] / 2)
            let minY = self.originSize[1] * (originBoxes[0][1] - originBoxes[0][3] / 2)
            let maxY = self.originSize[1] * (originBoxes[0][1] + originBoxes[0][3] / 2)
            
            var minW = (maxX - minX)
            var minH = (maxY - minY)
            
            if self.isCameraHorizon{
                
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
                
                minW = max(minW,minH) * boxfactor
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
                
                minH = max(minW,minH) * boxfactor
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
            
            if self.isCameraHorizon
            {
                if originBoxes[0][0] > originBoxes[1][0]{
                    originBoxes.swapAt(0, 1)
                }
                
                let minX = self.originSize[0] * (originBoxes[0][0] - originBoxes[0][2] / 2)
                let maxX = self.originSize[0] * (originBoxes[1][0] + originBoxes[1][2] / 2)
                let minY = self.originSize[1] * min(originBoxes[0][1] - originBoxes[0][3] / 2, originBoxes[1][1] - originBoxes[1][3] / 2)
                let maxY = self.originSize[1] * max(originBoxes[0][1] + originBoxes[0][3] / 2, originBoxes[1][1] + originBoxes[1][3] / 2)
                
                
                var minW = (maxX - minX)*boxfactor
                minW = min(minW, self.originSize[0] - 10)
                
                var minH = (maxY - minY)*boxfactor
                minH = min(minH, self.originSize[1] - 10)
                
                targetArea[2] = max(minW, minH / h * w)
                targetArea[3] = max(minH, minW / w * h)
                
                
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
                
                if originBoxes[0][1] > originBoxes[1][1]{
                    originBoxes.swapAt(0, 1)
                }
                
                let minY = self.originSize[1] * (originBoxes[0][1] - originBoxes[0][3] / 2)
                let maxY = self.originSize[1] * (originBoxes[1][1] + originBoxes[1][3] / 2)
                let minX = self.originSize[0] * min(originBoxes[0][0] - originBoxes[0][2] / 2, originBoxes[1][0] - originBoxes[1][2] / 2)
                let maxX = self.originSize[0] * max(originBoxes[0][0] + originBoxes[0][2] / 2, originBoxes[1][0] + originBoxes[1][2] / 2)
                
                var minW = (maxX - minX)*boxfactor
                var minH = (maxY - minY)*boxfactor
                
                minH = max(minH, minW / h * w)
                minH = min(minH, self.originSize[1] - 10)
                
                minW = max((maxX - minX), minH / w * h)
                
                targetArea[2] = minW
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
        
        
        targetArea[0] /= originSize[0]
        targetArea[1] /= originSize[1]
        targetArea[2] /= originSize[0]
        targetArea[3] /= originSize[1]
        
        return targetArea
    }
    
    func updateTargetArea(coordinates:[[Float]], targetArea:[Float]) -> [Float]{
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
        
        return computeTargetArea(stateResult: stateResult)
    }
    
    func targetAreaMove(initTargetArea: [Float], targetArea: [Float]) -> Bool{
        if abs(initTargetArea[0] - targetArea[0]) > (initTargetArea[2] + targetArea[2]) / 5
            || abs(initTargetArea[1] - targetArea[1]) > (initTargetArea[3] + targetArea[3]) / 2.5
    || targetArea[1] / initTargetArea[1] > 1.5{
            return true
        }
        else{
            return false
        }
    }

    func getSingleFeature(from singlefeatureArray: MLMultiArray, from boxArray : MLMultiArray, from pixelBuffer : CVPixelBuffer, iscls : Bool = true) -> [DetectionResult] {
        let cnt : Int = Int(singlefeatureArray.shape[0])
        let n : Int = Int(singlefeatureArray.shape[1])
        var result : [DetectionResult] = []
        
        
        if self.state == "idle"{
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
                    
                    if value > 0 && (self.allSingleFeatureIndex.contains(trueIndex) || !iscls){
                        
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
            
            if result.count > 2 && iscls{
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
            
            if result.count > 2{
                result.sort{$0.confidence[0] > $1.confidence[0]}
                result.removeLast(result.count - 2)
            }
            
            
            if result.count == 2{
                if self.isCameraHorizon && result[0].coordinate[0] > self.centerPos[0]{
                        result.swapAt(0, 1)
                    }
            else if !self.isCameraHorizon && result[0].coordinate[1] > self.centerPos[1]{
                        result.swapAt(0, 1)
                    }
            }
            else if result.count == 1{
                if self.isCameraHorizon{
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
            else if result.count == 0{
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0))
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0))
            }
            
            for resultIndex in 0..<result.count{
                result[resultIndex].singlefeatureIndex = result[resultIndex].singlefeatureIndex.map { $0 == 52 ? 54 : $0 }
            }
            
            return result
        }
        
        else{
            
            let newCIImage = CIImage(cvImageBuffer: pixelBuffer)
            let cgImage = CIContext().createCGImage(newCIImage, from: newCIImage.extent)!
            
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
                    
                    if value > 0 && (self.allSingleFeatureIndex.contains(trueIndex) || !iscls){
                        
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
            
            if result.count > 2 && iscls{
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
            
            if result.count > 2{
                result.sort{$0.confidence[0] > $1.confidence[0]}
                result.removeLast(result.count - 2)
            }
            
            
            if result.count == 2{
                //横向排列
                if self.isCameraHorizon && result[0].coordinate[0] > self.centerPos[0]{
                        result.swapAt(0, 1)
                    }
                //纵向排列
            else if !self.isCameraHorizon && result[0].coordinate[1] > self.centerPos[1]{
                        result.swapAt(0, 1)
                    }
            }
            else if result.count == 1{
                if self.isCameraHorizon{
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
            
            
            return result
        }
    }
    
    //MARK: generate test result
    func generateTestResult(){
        var testArray:[Int] = []
        for i in self.allSingleFeatureIndex{
            testArray.append(i)
        }
        
        testArray.shuffle()
        self.singlefeatureArray = testArray
        
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
        
        if self.cutMode[self.shuffleOrRiffle] != 3{
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
        }
        
        computeWinnerRC(isReset: true)
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
    
    func computeWinnerRC(isReset: Bool) {
        if singlefeatureArray.count >= minSingleFeatureNum && singlefeatureArray.count > cutNumRangeSetting[0] && singlefeatureArray.count > cutNumRangeSetting[1] - minSingleFeatureNum{
            multipleDatasetRCInfos = ClassifierSettingArgs.selectDataset(DatasetIndex: ruleIndex, inputSingleFeatures: singlefeatureArray, rcNum: (ClassifierSettingArgs.targetSetting[ruleIndex]?.rcNum[rcNum])!, args: args, rankRules: rankRules, suitRules: suitRules,dealNum: dealNum, coloringType: coloringType, dealType: dealType, diyDealNum: diyDealNum,diyDealStatus: diyDealStatus, calModeArgs: calModeArgs[self.shuffleOrRiffle], cutNumSetting: cutNumSetting, cutNumRangeSetting: cutNumRangeSetting, consecutiveReport: consecutiveReport, minSingleFeatureNum: minSingleFeatureNum, cutStructList: cutStructArray)
            
            self.singlefeatureArray = multipleDatasetRCInfos.returnSingleFeatureArray
            computeSingleFeatures(isReset: isReset)
            
            print("计算后的singlefeaturearray \(self.singlefeatureArray)")
            print("计算后的leftSingleFeatures \(self.leftSingleFeatures)")
            
            speakText(input: multipleDatasetRCInfos.reportResult)
        }
    }
    
    func computeSingleFeatures(isReset: Bool){
        if self.singlefeatureArray.count >= self.minSingleFeatureNum && self.singlefeatureArray.count > self.cutNumRangeSetting[0] && self.singlefeatureArray.count > self.cutNumRangeSetting[1] - self.minSingleFeatureNum{
            self.leftSingleFeatures = multipleDatasetRCInfos.leftSingleFeatures
            let usedNum = self.singlefeatureArray.count - self.leftSingleFeatures.count
            if usedNum == 0{
                self.usedSingleFeatures = []
            } 
            else if isReset{
                self.usedSingleFeatures = Array(self.singlefeatureArray[0...(usedNum - 1)])
            }
            else{
                self.usedSingleFeatures += Array(self.singlefeatureArray[0...(usedNum - 1)])
            }
            
        }
    }
    
    func computeNextRound(){
        if (self.leftSingleFeatures.count > 0){
            self.singlefeatureArray = self.leftSingleFeatures
            computeWinnerRC(isReset: false)
        }
    }
    
    func speakText(input: Int){
        let isSpeak = (!self.isHeadphonesConnected() && self.voiceDevice == 0)
                    || (self.isHeadphonesConnected() && self.voiceDevice == 1)
        
        if isSpeak{
            if hintVoiceIndex == 0{
                self.startAudioRC?.stop()
            }
            else if hintVoiceIndex == 1{
                self.successAudioRC?.stop()
            }
            else if hintVoiceIndex == 2{
                self.failAudioRC?.stop()
            }
            else{
                self.startAudioRC?.stop()
                self.successAudioRC?.stop()
                self.failAudioRC?.stop()
            }
            
            do{
                if input == 0{
                    self.startAudioRC = try AVAudioPlayer(contentsOf: startSoundURL!)
                    self.startAudioRC?.delegate = self
                    self.startAudioRC?.prepareToPlay()
                    self.startAudioRC?.play()
                    print("hint:play!")
                }
                else if input == 1{
                    self.successAudioRC = try AVAudioPlayer(contentsOf: successSoundURL!)
                    self.successAudioRC?.delegate = self
                    self.successAudioRC?.prepareToPlay()
                    self.successAudioRC?.play()
                    print("hint:success!")
                }
                else if input == 2{
                    self.failAudioRC = try AVAudioPlayer(contentsOf: failSoundURL!)
                    self.failAudioRC?.delegate = self
                    self.failAudioRC?.prepareToPlay()
                    self.failAudioRC?.play()
                    print("hint:fail!")
                }
                
                hintVoiceIndex = input
            }
            catch{
                
            }
        }
    }

    func speakText(input: [[SpeakResultStruct]]) {
        let isSpeak = (!self.isHeadphonesConnected() && self.voiceDevice == 0)
                    || (self.isHeadphonesConnected() && self.voiceDevice == 1)
        
        if isSpeak{
            self.speechPerformer.performSpeechSynthesis(speakResultStruct: input)
        }
    }
    
    func speakText(input: String){
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
    
    
    public func handleVolumeIncrease() {
        
        let selectedRule = ClassifierSettingArgs.targetSetting[ruleIndex]!
        
        // 处理音量增加事件的逻辑
        if self.volumeUp == 1{
            let playNumList = selectedRule.rcNum
            self.rcNum += 1
            if self.rcNum >= playNumList.count{
                self.rcNum = 0
            }
            self.minSingleFeatureNum = DatasetGetMinSingleFeatureNum()
            speakText(input: "人数" + String(selectedRule.rcNum[self.rcNum]))
        }
        else if self.volumeUp == 2{
            let currentNum = selectedRule.rcNum[self.rcNum]
            var positionSetting = self.calModeArgs[0][1] + 1
            if positionSetting >= currentNum{
                positionSetting = 0
            }
            self.calModeArgs[0][1] = positionSetting
            self.calModeArgs[1][1] = positionSetting
            speakText(input: "位置" + String(positionSetting+1))
        }
        else if self.volumeUp == 3{
            self.shuffleMode[0] += 1
            if self.shuffleMode[0] >= generalRuleSetting.allShuffleMode.count{
                self.shuffleMode[0] = 0
            }
            speakText(input: generalRuleSetting.allShuffleMode[self.shuffleMode[0]]!)
        }
        else if self.volumeUp == 4{
            self.selectedSaveIndex += 1
            if self.selectedSaveIndex >= DetectSettingArgs.allUsersDatasetRule.count{
                self.selectedSaveIndex = 0
            }
            loadSaveRule(saveRuleIndex: self.selectedSaveIndex)
            speakText(input: "方案" + String(self.selectedSaveIndex+1))
        }
        else if self.volumeUp == 5{
            toggleWorking()
        }
        else if self.volumeUp == 6{
            computeNextRound()
        }
    }
    
    public func handleVolumeDecrease() {
        // 处理音量减少事件的逻辑
        
        let selectedRule = ClassifierSettingArgs.targetSetting[ruleIndex]!
        
        if self.volumeDown == 1{
            let playNumList = selectedRule.rcNum
            self.rcNum -= 1
            if self.rcNum < 0{
                self.rcNum = playNumList.count - 1
            }
            self.minSingleFeatureNum = DatasetGetMinSingleFeatureNum()
            speakText(input: "人数" + String(selectedRule.rcNum[self.rcNum]))
        }
        else if self.volumeDown == 2{
            let currentNum = selectedRule.rcNum[self.rcNum]
            var positionSetting = self.calModeArgs[0][1] - 1
            if positionSetting < 0{
                positionSetting = currentNum - 1
            }
            self.calModeArgs[0][1] = positionSetting
            self.calModeArgs[1][1] = positionSetting
            speakText(input: "位置" + String(positionSetting+1))
        }
        else if self.volumeDown == 3{
            self.shuffleMode[1] -= 1
            if self.shuffleMode[1] < 0{
                self.shuffleMode[1] = generalRuleSetting.allRiffleMode.count - 1
            }
            speakText(input: generalRuleSetting.allRiffleMode[self.shuffleMode[1]]!)
        }
        else if self.volumeDown == 4{
            self.selectedSaveIndex -= 1
            if self.selectedSaveIndex < 0{
                self.selectedSaveIndex = DetectSettingArgs.allUsersDatasetRule.count - 1
            }
            loadSaveRule(saveRuleIndex: self.selectedSaveIndex)
            speakText(input: "方案" + String(self.selectedSaveIndex+1))
        }
        else if self.volumeDown == 5{
            toggleWorking()
        }
        else if self.volumeDown == 6{
            computeNextRound()
        }
        else if self.volumeDown == 7{
            self.volumeUp += 1
            if self.volumeUp >= FunctionSetting.volumeUpDict.count{
                self.volumeUp = 0
            }
            speakText(input: FunctionSetting.volumeUpDict[self.volumeUp]!)
        }
    }
    
    public func toggleWorking(){
        isWorking.toggle()
        if isWorking{
            speakText(input: "开始")
        }
        else{
            speakText(input: "暂停")
        }
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
        
        // print(self.allSingleFeatureIndex.count)
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
        default:
            print("DatasetType error")
        }
        return minSingleFeatureNum
    }
    
    public func updateConfigJSON() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("config.json")

            let boolDict: [String: Bool] = [
                "isBackCamera" : self.isBackCamera,
                "isCameraHorizon" : self.isCameraHorizon
            ]
            
            let intDict : [String: Int] = [
                "volumeUp": self.volumeUp,
                "volumeDown": self.volumeDown,
                "blackMode": self.blackMode,
                "voiceDevice": self.voiceDevice
            ]
            
            let floatDict : [String: Float] = [
                "volumeValue": self.volumeValue,
                "voiceRate": self.voiceRate,
                "zoomFactor": self.zoomFactor,
                "focusFactor": self.focusFactor
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
    
    func performSpeechSynthesis(speakResultStruct: [[SpeakResultStruct]]) {
        lock.lock()
        guard !isPlaying else {
            lock.unlock()
            return
        }

        isPlaying = true
        lock.unlock()
        
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer.delegate = self
        
        for repeatIndex in 0..<2{
            for (turnIndex, turnResult) in speakResultStruct.enumerated() {
                
                for (reportIndex, reportResult) in turnResult.enumerated() {
                    var speakString = reportResult.content
                    if speakString.isEmpty{
                        speakString = "0"
                    }
                        
                    let speechUtterance = AVSpeechUtterance(string: speakString)
                    if reportResult.voiceType == 0{
                        speechUtterance.voice = chineseMaleVoice
                    }
                    if reportResult.voiceType == 1{
                        speechUtterance.voice = chineseFemaleVoice
                    }
                    
                    if repeatIndex != 0 && turnIndex == 0 && reportIndex == 0{
                        speechUtterance.preUtteranceDelay = 0.05
                    }
                    speechUtterance.postUtteranceDelay = 0
                    
                    // print("播报的input \(reportResult.content)")
                    
                    speechUtterance.pitchMultiplier = 1
                    speechUtterance.rate = self.voiceRate
                    
                    synthesizer.speak(speechUtterance)
                }
            }
        }
        let emptySpeechUtterance = AVSpeechUtterance(string: " ")
        synthesizer.speak(emptySpeechUtterance)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        lock.lock()
        isPlaying = false
        lock.unlock()
        // Perform any action you want after speech synthesis finishes
    }
}

