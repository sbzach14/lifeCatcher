

import SwiftUI
import CreateMLComponents
import AsyncAlgorithms
import AVFoundation
import CoreMedia
import MobileCoreServices
import Foundation
import Python
//import PythonKit
import Vision
import Foundation
import CoreML
import Photos
import Accelerate
import AudioToolbox
import MediaPlayer


/// - Tag: ViewModel
class ViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVAudioPlayerDelegate {
    
    @Published var cameraImage : CGImage?
    @Published var isShowCard : Bool = false
    @Published var isCamereSetting : Bool = false
    
    // cardArray, 装有所有poker的array
    @Published var cardArray :  [Int] = []
    @Published var winnerPlayer: [[SpeakResultStruct]] = []
    @Published var winnerPlayerShow: String = ""
    @Published var multipleGamePlayerInfos: ReportManager.MultipleReportResultInfo = ReportManager.MultipleReportResultInfo()
    @Published var leftCards: [Int] = []
    @Published var cutArray : [Int] = []
    @Published var cutShowArray : [Int] = []
    
    let fastModel = try! cardDetection_0422_scale_40()
    let slowModel = try! cardDetection_0422_scale_40()
    
    var imageSize : [Float] = [853, 480]
    var originSize : [Float] = [1920, 1080]
    var inputSize : [Int] = [640, 480]
    
    var startAudioPlayer: AVAudioPlayer?
    var successAudioPlayer: AVAudioPlayer?
    var failAudioPlayer: AVAudioPlayer?
    private let commandCenter = MPRemoteCommandCenter.shared()
    
    // 创建一个后台队列
    let videoProcessingQueue = DispatchQueue(label: "com.example.videoProcessing", qos: .userInitiated)
    // 创建一个后台队列
    let backgroundQueue = DispatchQueue(label: "actionQueue", attributes: .concurrent)
    let saveImageQueue = DispatchQueue(label: "saveImageQueue", qos: .userInteractive, attributes: .concurrent)
    let detectionQueue = DispatchQueue(label: "detectionQueue", attributes: .concurrent)
    let captureQueue = DispatchQueue(label: "com.example.captureQueue", qos: .background)
    
    let lock = NSLock()
    

    public var state : String = "idle" //
    public var shuffleMode : Int = 0 //0shuffle 1riffleTop 2riffleCenter
    public var cutMode : Int = 0//0 no cut  1 bot   2 top   3 cut   4  hand
    public var playerNum: Int = 0
    public var dealNum: Int = 0
    public var coloringType: Int = 0
    public var dealType: Int = 0
    public var diyDealNum: [Int] = []
    public var diyDealStatus: [[Bool]] = []
    public var calModeArgs : [Int] = [0, 0, 1]
    public var cutNumSetting: Int = 0
    public var cutNumRangeSetting: [Int] = [2,10]
    public var consecutiveReport: Int = 0
    public var reportNumber: Int = 0
    public var voiceReport: Int = 0
    public var ruleIndex : Int = 0
    public var args : [Int] = []
    public var rankRules : [Int] = []
    public var suitRules : [Int] = [3,2,1,0]
    public var allCardIndex : [Int] = Array(0...51)
    public var minCardNum : Int = 0
    
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
    var lastBoxes : [[Float]] = [[0.3, 0.5, 0.05, 0.05], [0.7, 0.5, 0.05, 0.05]]
    var isHorizon : Bool = true
    var targetArea : [Float] = [0, 0, 0, 0]
    
    //显示帧率
    private var frameCount = 0
    private var timestamp: Double = 0
    private var frameRateLabel: UILabel! // 用于显示帧率的标签
    
    var captureDevice: AVCaptureDevice!
    var captureDeviceInput: AVCaptureDeviceInput!
    let session = AVCaptureSession()
    private var requests = [VNRequest]()
    
    private var stateCounter : Int = 0
    private var stateCard : [Int] = [-1, -1]
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    private var laplacianDic: [[Int:Float]] = [[:],[:]]
    
    let cardLabelDic : [Int:String] = [
        0: "♠️A ", 1: "♠️2", 2: "♠️3", 3: "♠️4", 4: "♠️5 ", 5: "♠️6 ", 6: "♠️7 ", 7: "♠️8 ", 8: "♠️9 ", 9: "♠️10 ",
        10: "♠️J ", 11: "♠️Q ", 12: "♠️K ", 13: "♥️A ", 14: "♥️2 ", 15: "♥️3 ", 16: "♥️4 ", 17: "♥️5 ", 18: "♥️6 ",
        19: "♥️7 ", 20: "♥️8 ", 21: "♥️9 ", 22: "♥️10 ", 23: "♥️J ", 24: "♥️Q ", 25: "♥️K ", 26: "♣️A ", 27: "♣️2 ",
        28: "♣️3 ", 29: "♣️4 ", 30: "♣️5 ", 31: "♣️6 ", 32: "♣️7 ", 33: "♣️8 ", 34: "♣️9 ", 35: "♣️10 ", 36: "♣️J ",
        37: "♣️Q ", 38: "♣️K ", 39: "♦️A ", 40: "♦️2 ", 41: "♦️3 ", 42: "♦️4 ", 43: "♦️5 ", 44: "♦️6", 45: "♦️7",
        46: "♦️8 ", 47: "♦️9 ", 48: "♦️10 ", 49: "♦️J ", 50: "♦️Q ", 51: "♦️K ", 52: "none", 53: "小王", 54: "大王"
    ]
    
    @Published var isBlack: Bool = false
    @Published var isMute: Bool = false
    @Published var isBackCamera: Bool = true
    @Published var isRemote: Bool = false
    @Published var isFast: Bool = true
    @Published var isActive: Bool = false
    @Published var isAutoFocus: Bool = false
    @Published var activeDate: String = ""
    @Published var uniqueID: String = ""
    @Published var volumeUp: Int = 0
    @Published var volumeDown: Int = 0
    @Published var volumeValue: Float = 0.5
    @Published var zoomFactor: Float = 0.2
    @Published var focusFactor: Float = 0.5
    
    var setFrameRate: Float64 = 120.0
    var cameraFrameRate: Int = 0
    
    
    var testCVPixelBuffer : CVPixelBuffer?
    var selectedSaveIndex : Int = 0
    var isWorking: Bool = true
    
    var viewController: MyViewController?
    
    let chineseFemaleVoice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_zh-CN_compact")
    let chineseMaleVoice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_zh-CN_compact")
    
    var cutDone : Bool = true
    var detectSet : Set<Int> = []
    

    func initialize(saveRuleIndex: Int) {
        
        print("viewmodel init")
        
        self.loadSaveRule(saveRuleIndex: saveRuleIndex)
        
        for key in self.allCardIndex {
            self.laplacianDic[0][key] = 0
            self.laplacianDic[1][key] = 0
        }
        self.initShuffle()
        self.initDetectResult()
        
        // Load data from config.json
        if let configData = readConfigJSON() {
            let boolDict = configData["Bool"] as! [String : Bool]
            self.isBlack = boolDict["isBlack"]!
            self.isMute = boolDict["isMute"]!
            self.isBackCamera = boolDict["isBackCamera"]!
            self.isRemote = boolDict["isRemote"]!
            self.isFast = boolDict["isFast"]!
            self.isActive = boolDict["isActive"]!
            self.isAutoFocus = boolDict["isAutoFocus"]!
            
            let intDict = configData["Int"] as! [String : Int]
            self.volumeUp = intDict["volumeUp"]!
            self.volumeDown = intDict["volumeDown"]!
            
            let floatDict = configData["Float"] as! [String : Float]
            self.volumeValue = floatDict["volumeValue"]!
            self.zoomFactor = floatDict["zoomFactor"]!
            self.focusFactor = floatDict["focusFactor"]!
        }
        
        let startSoundURL = Bundle.main.url(forResource: "start_tip", withExtension: "mp3")
        let successSoundURL = Bundle.main.url(forResource: "success_tip", withExtension: "mp3")
        let failSoundURL = Bundle.main.url(forResource: "fail_tip", withExtension: "mp3")
        do {
            startAudioPlayer = try AVAudioPlayer(contentsOf: startSoundURL!)
            startAudioPlayer?.delegate = self
            successAudioPlayer = try AVAudioPlayer(contentsOf: successSoundURL!)
            successAudioPlayer?.delegate = self
            failAudioPlayer = try AVAudioPlayer(contentsOf: failSoundURL!)
            failAudioPlayer?.delegate = self
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
        
        self.isWorking = true
        
        setupAVCapture()

//      规则测试代码
//        print("calArgs \(calModeArgs[1])")
//        for i in 0..<1{
//            print("测试用例 ",i + 1,"")
//            var randomCardArray = Array(0...51)
//            randomCardArray.shuffle()
//            //切断
//            randomCardArray = Array(randomCardArray.prefix(35))
//            self.cardArray = randomCardArray
//
//            self.cardArray = [4,18,32, 4,6,0, 0,12,10, 1,2,4, 4,17,30, 13,12,10, 1,15,4, 5,4,6, 18,30,6, 53,54,3, 53,4,5, 54,6,20, 53,4,0, 54,7,22, 8,32,41]
//
//            var cardString:String = "当前牌库："
//            for cardIndex in cardArray{
//                cardString += cardLabelDic[cardIndex]! + " "
//            }
//            print(cardArray)
//            print(cardString)
//
//            self.computeWinnerPlayer()
//        }

    }
    
    private func initDetectResult(){
        detectResultList = [:]
        stateCounter = 0
        winnerPlayer = []
        winnerPlayerShow = ""
        detectSet = []
    }
    
    private func initShuffle(){
        cardArray = []
        cutArray = []
        cutShowArray = []
        self.leftCards = []
        if self.cutMode != 0{
            self.cutDone = false
        }
        else{
            self.cutDone = true
        }
    }
    
    private func initBoxes(){
        centerPos = [0.5, 0.5]
        lastBoxes = [[0.1, 0.5, 0.05, 0.05], [0.9, 0.5, 0.05, 0.05]]
        isHorizon = true
        targetArea = [0,0,0,0]
        imageSize[0] = min(originSize[0], 853 * (1 + self.zoomFactor * 2))
        imageSize[1] = min(originSize[1], 480 * (1 + self.zoomFactor * 2))
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
            
            print("设定识别帧率: \(self.setFrameRate)")

            
            guard let format = self.captureDevice.formats.first(where: { format in
                let ranges = format.videoSupportedFrameRateRanges
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                return dimensions.width == 1920
                    && ranges.contains { range in
                    return range.maxFrameRate >= self.setFrameRate
                }
            }) else {
                print("不支持\(setFrameRate)帧的摄像头格式")
                return
            }
            do {
                try self.captureDevice.lockForConfiguration()
                self.captureDevice.activeFormat = format
                self.captureDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(format.videoSupportedFrameRateRanges.first!.maxFrameRate))
                self.captureDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(format.videoSupportedFrameRateRanges.first!.maxFrameRate))
                
                self.captureDevice.unlockForConfiguration()
            } catch {
                print("设置帧率时发生错误: \(error)")
            }
            
            updateFocusFactor()
            updateZoomFactor()
            
            session.commitConfiguration()
            
            // 获取当前帧率
            let videoFrameRate = format.videoSupportedFrameRateRanges.first!.maxFrameRate
            print("设定帧率: \(videoFrameRate)")
            changeCameraFrameRate(to: idleRate)
        } catch {
            print("配置前置摄像头时发生错误: \(error)")
        }
    }
    
    
    func updateZoomFactor(){
        do{
            print("zoomFactor: \(zoomFactor)")
            try self.captureDevice.lockForConfiguration()
            
            let minzoomfactor = captureDevice.minAvailableVideoZoomFactor
            self.captureDevice.videoZoomFactor = minzoomfactor + 3 * CGFloat(self.zoomFactor)
            
            self.captureDevice.unlockForConfiguration()
        }
        catch{
            
        }
    }
    
    func updateFocusFactor(){
        do{
            print("focusFactor: \(focusFactor)")
            try self.captureDevice.lockForConfiguration()
            
            if !self.isAutoFocus && self.captureDevice.isLockingFocusWithCustomLensPositionSupported{
                self.captureDevice.focusMode = .locked
                self.captureDevice.setFocusModeLocked(lensPosition: self.focusFactor)
                print("对焦模式：手动对焦    设定焦距：", self.captureDevice.lensPosition)
            }
            else{
                self.captureDevice.focusMode = .continuousAutoFocus
                print("对焦模式：自动对焦")
            }
            self.captureDevice.unlockForConfiguration()
        }
        catch{
            
        }
    }
    
    func startCamera() {
        session.startRunning()
        changeCameraFrameRate(to: idleRate)
        print("开启相机")
    }
    
    func stopCamera() {
        session.stopRunning()
        print("关闭相机")
    }
    
    func changeCameraFrameRate(to frameRate: Int) {
        guard let device = captureDevice else {
            print("相机设备未初始化")
            return
        }
        
        do{
            try device.lockForConfiguration()
            let format = device.activeFormat
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(frameRate))
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(frameRate))
            device.unlockForConfiguration()
            cameraFrameRate = frameRate
            print("设置帧率为: \(frameRate)")
        }catch {
            print("设置帧率时发生错误: \(error)")
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
        
        if !self.isBlack && (self.cameraFrameRate <= idleRate || self.taskIndex % indexGap == 0){
            backgroundQueue.async {
                do{
//                    let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent)!
//                    let cgImageFormat = vImage_CGImageFormat(
//                        bitsPerComponent: UInt32(cgImage.bitsPerComponent),
//                        bitsPerPixel: UInt32(cgImage.bitsPerPixel),
//                        colorSpace: Unmanaged.passUnretained(cgImage.colorSpace!),
//                        bitmapInfo: cgImage.bitmapInfo,
//                        version: 0,
//                        decode: nil,
//                        renderingIntent: cgImage.renderingIntent)
//                    
//                    // 创建 vImage_Buffer
//                    var vImageBuffer = try vImage_Buffer(cgImage: cgImage)
//                    
//                    var outputCGImage : CGImage
//                    
//                    // 进行顺时针旋转90度
//                    var rotatedBuffer = try! vImage_Buffer(width: Int(vImageBuffer.height),
//                                                           height: Int(vImageBuffer.width),
//                                                           bitsPerPixel: 32) // 32 bits for ARGB
//                    vImageRotate90_ARGB8888(&vImageBuffer, &rotatedBuffer, UInt8(kRotate90DegreesClockwise), [0], vImage_Flags(kvImageNoFlags))
//                    
//                    if !self.isBackCamera{
//                        vImageHorizontalReflect_ARGB8888(&rotatedBuffer, &rotatedBuffer, vImage_Flags(kvImageNoFlags))
//                    }
//                        
//                    
//                    outputCGImage = try rotatedBuffer.createCGImage(format: cgImageFormat)
//                    rotatedBuffer.free()
//                    vImageBuffer.free()
                    
                    let rotationTransform = CGAffineTransform(rotationAngle: -.pi / 2)  // 顺时针旋转90度
                    let rotatedImage = ciImage.transformed(by: rotationTransform)
                    
                    let xOffset = ciImage.extent.size.height
                    let translationTransform = CGAffineTransform(translationX: xOffset, y: CGFloat(0))
                    let translatedImage = rotatedImage.transformed(by: translationTransform)
                    let outputCGImage = self.context.createCGImage(translatedImage, from: translatedImage.extent)
                    
                    
                    
                    DispatchQueue.main.async {
                        self.cameraImage = outputCGImage
                    }
                }
                
                catch{
                    print("Error: \(error)")
                }
            }
        }
        
        if !self.isShowCard && !isCamereSetting && self.isWorking{
            
            self.detectionQueue.async {
                let cvPixelBuffer = createCVPixelBuffer(ciImage: ciImage, targetSize: CGSize(width: self.inputSize[0], height: self.inputSize[1]), targetArea: self.targetArea)!
                self.processImageOrigin(cvPixelBuffer, taskIndex: myIndex)
            }
        }
            
        // 释放视频帧资源
        CMSampleBufferInvalidate(sampleBuffer)
    }
    

    private func saveImageOrigin(_ originCIImage: CIImage, taskIndex: Int){
        // 将 CIImage 转换为 UIImage
        let ciImage = originCIImage.resize(to: CGSize(width: 960, height: 544))
        let uiImage = UIImage(ciImage: originCIImage)
        let imageName = "task_\(taskIndex).jpeg"
        self.taskImageArray.append(imageName)
        
        let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
        let savedUIImage = UIImage(cgImage: cgImage!)
        UIImageWriteToSavedPhotosAlbum(savedUIImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        
        if let data = uiImage.jpegData(compressionQuality: 0.8) {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName)
            do{
                try data.write(to: fileURL!)
                print("文件\(imageName)保存成功")
            }
            catch {
                print("文件\(imageName)保存失败: \(error)")
            }
        }

    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            print("保存图片到相册失败: \(error)")
        } else {
            print("图片保存成功")
        }
    }
    
    private func readImageOrigin(index: Int) -> CIImage?{
        let imageName = self.taskImageArray[index]
        // 从文件中读取图像并转换为 CIImage
        if let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName){
            if let data = try? Data(contentsOf: fileURL){
                let uiImage = UIImage(data: data)
                let ciImage = CIImage(image: uiImage!)
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("文件\(imageName)删除成功")
                } catch {
                    print("文件\(imageName)删除失败: \(error)")
                }
                return ciImage
            }
        }
        return nil
    }
    
    // MARK: process image origin
    func processImageOrigin(_ pixelBuffer: CVPixelBuffer, taskIndex: Int){
        
        var confidenceThreshold = 0.6
        if self.state == "idle"{
            confidenceThreshold = 0.7
        }
        else{
            confidenceThreshold = 0.1
        }
        
        var cardResult : [DetectionResult]
        if self.isFast{
            let result = try! fastModel.prediction(image: pixelBuffer, iouThreshold: 0.45, confidenceThreshold: confidenceThreshold)
            cardResult = getCard(from: result.confidence, from: result.coordinates, from: pixelBuffer)
        }
        else{
            let result = try! slowModel.prediction(image: pixelBuffer, iouThreshold: 0.45, confidenceThreshold: confidenceThreshold)
            cardResult = getCard(from: result.confidence, from: result.coordinates, from: pixelBuffer)
        }
         
        if cardResult[0].cardIndex[0] == self.stateCard[0] && cardResult[1].cardIndex[0] == self.stateCard[1]{
            stateCounter = min(stateCounter + 1, 600)
        }
        else if self.isRemote && cardResult[0].cardIndex[0] != -1 && cardResult[1].cardIndex[0] != -1{
            stateCounter = min(stateCounter + 1, 600)
        }
        else{
            stateCounter = 0
        }
        
        self.stateCard[0] = cardResult[0].cardIndex[0]
        self.stateCard[1] = cardResult[1].cardIndex[0]
        
        
        if state == "idle"{
            if (self.stateCard[0] != -1 || self.stateCard[1] != -1) && stateCounter >= 2{
                
                print("动作：开始识别 ", self.setFrameRate)
                DispatchQueue.main.async{
                    self.state = "shuffle"
                    self.speakText(input: 0)
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                    self.initDetectResult()
                    if self.isRemote{
                        self.computeTargetArea(stateResult: self.lastBoxes)
                    }
                    
                    var cutCard = -1
                    if self.stateCard[0] == -1{
                        cutCard = self.stateCard[1]
                    }
                    else if self.stateCard[1] == -1{
                        cutCard = self.stateCard[0]
                    }
                    if !self.cutDone && cutCard != -1 && self.cardArray.count > 0{
                        //切牌
                        print("切牌之前的牌库 \(self.cardArray)")
                        
                        if !self.cardArray.contains(cutCard){
                            //self.speakText(input: 2)
                        }
                        
                        else {
                            var cutIndex = self.cardArray.firstIndex(of: cutCard)!
                            if self.cutMode == 1{
                                //看底
                                self.cutCardArray(index: cutIndex)
                                self.cutDone = true
                            }
                            else if self.cutMode == 2{
                                //看顶
                                cutIndex -= 1
                                if cutIndex < 0{
                                    cutIndex = self.cardArray.count - 1
                                }
                                self.cutCardArray(index: cutIndex)
                                self.cutDone = true
                            }
                            else if self.cutMode == 3{
                                //连续切牌
                                self.cutArray.append(cutCard)
                            }
                            else if self.cutMode == 4{
                                //看手
                                self.cutArray.append(cutCard)
                                self.cutDone = true
                            }
                            
                            self.cutShowArray.append(cutCard)
                            self.detectSet.insert(cutCard)
                            //self.speakText(input: 1)
                            self.computeWinnerPlayer()
                        }
                    }
                }
            }
        }
        else if state == "shuffle"{
            if self.stateCard[0] == -1 && self.stateCard[1] == -1 && stateCounter >= 5{

                print("动作：识别完成 ", self.setFrameRate)
                DispatchQueue.main.async{
                    self.stateCounter = 0
                    self.state = "idle"
                    self.changeCameraFrameRate(to: self.idleRate)
                    let detectState = self.handleDetecResultList(targetDetecResultList: self.detectResultList)
                    self.initBoxes()
                    
                    //根据detect result list判别洗牌、拨牌、洗牌
                    //2侧或1侧 长或短
                    
                    var errorFlag = false
                    
                    if !detectState.isSingle && !detectState.isShort
                        && (self.shuffleMode == 0 || self.shuffleMode == 3 || self.shuffleMode == 4){
                        //洗牌
                        self.initShuffle()
                        self.cardArray = detectState.detectionResult
                    
                        if self.cardArray.count == self.allCardIndex.count{
                            self.speakText(input: 1)
                        }
                        else{
                            self.speakText(input: 2)
                        }
                        
                        self.computeWinnerPlayer()
                    }
                    else if detectState.isSingle && !detectState.isShort
                        && (self.shuffleMode == 1 || self.shuffleMode == 2 || self.shuffleMode == 3 || self.shuffleMode == 4){
                        //拨牌
                        self.initShuffle()
                        self.cardArray = detectState.detectionResult
                        
                        if(self.shuffleMode == 1 || self.shuffleMode == 3){
                            //拨到顶
                            if self.cardArray.count == self.allCardIndex.count{
                                self.speakText(input: 1)
                            }
                            else{
                                self.speakText(input: 2)
                            }
                        }
                        
                        else if(self.shuffleMode == 2 || self.shuffleMode == 4){
                            //拨中间
                            if self.cardArray.count > 0{
                                self.cardArray.remove(at: 0)
                            }
                            self.speakText(input: 1)
                        }
                        
                        self.computeWinnerPlayer()
                    }
                    
                    
                    print("result  isShort:\(detectState.isShort)  isSingle:\(detectState.isSingle)  cardArray:\(self.cardArray)")
                }
            }
            else{
                DispatchQueue.main.async{
                    self.detectResultList[taskIndex] = cardResult
                    
                    //check cut or shuffle
                    if self.detectSet.count > 5{
                        self.detectSet = []
                        self.speechSynthesizer.stopSpeaking(at: .immediate)
                    }
                    else if self.detectSet.count > 0{
                        self.detectSet.insert(cardResult[0].cardIndex[0])
                        self.detectSet.insert(cardResult[1].cardIndex[0])
                    }
                    
                    if self.isRemote{
                        //updateTargetArea(coordinates: self.lastBoxes)
                    }
                }
            }
        }

//            let modelCIImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let cgImage = CIContext().createCGImage(modelCIImage, from: modelCIImage.extent)
//            let savedUIImage = UIImage(cgImage: cgImage!)
//            UIImageWriteToSavedPhotosAlbum(savedUIImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)

//            print("检测结果：[\(cardLabelDic[cardResult[0].cardIndex[0]] ?? "none"),Confidence: \(cardResult[0].confidence),ConfidencePercent: \(cardResult[0].confidencePercent),\(cardLabelDic[cardResult[1].cardIndex[0]] ?? "none"), Confidence: \(cardResult[1].confidence), ConfidencePercent: \(cardResult[1].confidencePercent)]")
    }
    
    
    // MARK: handle result list
    func handleDetecResultList(targetDetecResultList: [Int : [DetectionResult]]) -> DetectionState{
        
        var confidenceDic : [Int:Float] = [:]
        for key in self.allCardIndex {
            confidenceDic[key] = 0
        }
        
        var sortedKeys = targetDetecResultList.keys.sorted()
        let blurThreshold : Float = 0.8
        let longHeadIndex = 10
        
        print("检测sortedKeys \(sortedKeys)")

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
                
                if abs(nowLaplacian - nextLaplacian) <= 0.000000001{
                    deleteKeys.append(detectResultListIndex)
                }
            }
        }
        
        sortedKeys = sortedKeys.filter { !deleteKeys.contains($0) }
        
        var beginIndex = 2
        var endIndex = sortedKeys.count-3
        
        if beginIndex >= endIndex{
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }
        
        //TODO清理单侧结尾(连续多个none视作结尾）？
        
        
        //求出所有链路，链上数字confidence=100
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].cardIndex[0]
                if nowNum != -1
                    && targetDetecResultList[nextDetectResultListIndex]![numIndex].cardIndex[0] == nowNum{
                    targetDetecResultList[detectResultListIndex]![numIndex].nodeType += 1
                    targetDetecResultList[nextDetectResultListIndex]![numIndex].nodeType += 2
                }
            }
        }
        
        var leftSideCnt = 0
        var rightSideCnt = 0
        var leftFirstHead = -1
        var rightFirstHead = -1
        var leftLastTail = -1
        var rightLastTail = -1
        
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                
                if detectResultNode.nodeType == 1{
                    if numIndex == 0{
                        leftSideCnt += 1
                    }
                    else{
                        rightSideCnt += 1
                    }
                }
                
                if detectResultNode.nodeType == 3{
                    if numIndex == 0{
                        if leftFirstHead == -1 && keyIndex > longHeadIndex{
                            leftFirstHead = keyIndex
                        }
                    }
                    if numIndex == 1{
                        if rightFirstHead == -1 && keyIndex > longHeadIndex{
                            rightLastTail = keyIndex
                        }
                    }
                }
                
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
        
        var isSingle = true
        if leftSideCnt > 1 && rightSideCnt > 1{
            isSingle = false
        }
        
        var isShort = true
        if leftSideCnt + rightSideCnt > 10{
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
            }
            else if leftSideCnt > rightSideCnt && leftFirstHead != -1{
                beginIndex = leftFirstHead
            }
            else if leftSideCnt < rightSideCnt && rightFirstHead != -1{
                beginIndex = rightFirstHead
            }
        }
        
        if !isSingle{
            endIndex = min(leftLastTail, rightLastTail) + 3
            let detectResultListIndex = sortedKeys[endIndex-1]
            if targetDetecResultList[detectResultListIndex]![0].nodeType == 3{
                targetDetecResultList[detectResultListIndex]![0].nodeType = 2
            }
            else if targetDetecResultList[detectResultListIndex]![1].nodeType == 3{
                targetDetecResultList[detectResultListIndex]![1].nodeType = 2
            }
            if targetDetecResultList[detectResultListIndex]![0].nodeType != 2{
                targetDetecResultList[detectResultListIndex]![0].nodeType = 0
            }
            else if targetDetecResultList[detectResultListIndex]![1].nodeType != 2{
                targetDetecResultList[detectResultListIndex]![1].nodeType = 0
            }
        }
        
        if beginIndex >= endIndex{
            let result = DetectionState(detectionResult: [], isSingle: false, isShort: false, longestIndex: -1)
            return result
        }
        
        //为链添加置信度
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                if detectResultNode.nodeType == 1{
                    confidenceDic[detectResultNode.cardIndex[0]] = 100
                }
            }
        }
        
        //整理同一个数字的多条链路
        //整理两次
        for _ in 0..<3{
            for key in confidenceDic.keys{
                
                if confidenceDic[key] == 100{
                    for numIndex in 0..<targetDetecResultList[0]!.count{
                        
                        var end = -1
                        var head = -1
                        
                        for keyIndex in beginIndex..<endIndex{
                            let detectResultListIndex = sortedKeys[keyIndex]
                            let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].cardIndex[0]
                            if nowNum == key && targetDetecResultList[detectResultListIndex]![numIndex].nodeType == 2{
                                end = detectResultListIndex
                            }
                            else if nowNum == key
                                        && targetDetecResultList[detectResultListIndex]![numIndex].nodeType == 1
                                        && end != -1{
                                head = detectResultListIndex
                                
                                let isClose = head - end <= 5

                                var isSameNum = head - end <= 10
                                var middleNum = -1
                                for updateIndex in end+1...head-1{
                                    let currentMiddleNum = targetDetecResultList[updateIndex]![numIndex].cardIndex[0]
                                    if currentMiddleNum != -1{
                                        middleNum = currentMiddleNum
                                        break
                                    }
                                }
                                for updateIndex in end+1...head-1{
                                    let currentMiddleNum = targetDetecResultList[updateIndex]![numIndex].cardIndex[0]
                                    if currentMiddleNum != -1 && currentMiddleNum != middleNum{
                                        isSameNum = false
                                        break
                                    }
                                }
                                
                                if isClose || isSameNum{
                                    for updateIndex in end...head{
                                        targetDetecResultList[updateIndex]![numIndex].cardIndex[0] = nowNum
                                        targetDetecResultList[updateIndex]![numIndex].nodeType = 3
                                    }
                                    print("合并链 " + cardLabelDic[nowNum]!)
                                }
                                else{
                                    for updateIndex in head..<endIndex{
                                        if targetDetecResultList[updateIndex]![numIndex].cardIndex[0] == nowNum{
                                            targetDetecResultList[updateIndex]![numIndex].nodeType = 0
                                        }
                                        else{
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        //检查是否有数字唯一链被删除
        for key in confidenceDic.keys{
            if confidenceDic[key] == 100{
                var isChain = false
                for keyIndex in beginIndex..<endIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].cardIndex[0]
                        let nodeType = targetDetecResultList[detectResultListIndex]![numIndex].nodeType
                        if nowNum == key && nodeType == 1 {
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

        //去除所有单独节点的cardindex中已有数字
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]

                if detectResultNode.nodeType == 0
                    && detectResultNode.cardIndex[0] != -1{

                    var newCardIndex : [Int] = []
                    var newConfidence : [Float] = []
                    for i in 0..<detectResultNode.cardIndex.count{
                        if confidenceDic[i] == 0{
                            newCardIndex.append(detectResultNode.cardIndex[i])
                            newConfidence.append(detectResultNode.confidence[i])
                        }
                    }

                    if newCardIndex.count == 0{
                        newCardIndex.append(-1)
                        newConfidence.append(1)
                        detectResultNode.nodeType = 5//所有可能的数字去除，标记为融合牌
                    }

                    detectResultNode.cardIndex = newCardIndex
                    detectResultNode.confidence = newConfidence
                }
            }
        }
        
        //找到所有不在链上但在单独节点的数字
        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                var nodeIndex : [Int] = []
                for keyIndex in beginIndex..<endIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    
                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].cardIndex[0]
                        let confidence = targetDetecResultList[detectResultListIndex]![numIndex].confidence[0]
                        if nowNum == key && confidence > confidenceDic[nowNum]! {
                            confidenceDic[nowNum] = confidence
                            nodeIndex = [detectResultListIndex, numIndex]
                        }
                    }
                }
                if nodeIndex.count > 0{
                    targetDetecResultList[nodeIndex[0]]![nodeIndex[1]].nodeType = 4
                }
            }
        }

        //去除所有单独节点的cardindex中已有数字
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]

                if detectResultNode.nodeType == 0
                    && detectResultNode.cardIndex[0] != -1{

                    var newCardIndex : [Int] = []
                    var newConfidence : [Float] = []
                    for i in 0..<detectResultNode.cardIndex.count{
                        if confidenceDic[i] == 0{
                            newCardIndex.append(detectResultNode.cardIndex[i])
                            newConfidence.append(detectResultNode.confidence[i])
                        }
                    }

                    if newCardIndex.count == 0{
                        newCardIndex.append(-1)
                        newConfidence.append(1)
                        detectResultNode.nodeType = 5//所有可能的数字去除，标记为融合牌
                    }

                    detectResultNode.cardIndex = newCardIndex
                    detectResultNode.confidence = newConfidence
                }
            }
        }

        //再找一次所有不在链上但在单独节点的数字
        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                var nodeIndex : [Int] = []
                for keyIndex in beginIndex..<endIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    
                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].cardIndex[0]
                        let confidence = targetDetecResultList[detectResultListIndex]![numIndex].confidence[0]
                        if nowNum == key && confidence > confidenceDic[nowNum]! {
                            confidenceDic[nowNum] = confidence
                            nodeIndex = [detectResultListIndex, numIndex]
                            print("二次补牌：\(cardLabelDic[nowNum]!)")
                            
                        }
                    }
                }
                if nodeIndex.count > 0{
                    targetDetecResultList[nodeIndex[0]]![nodeIndex[1]].nodeType = 4
                }
            }
        }
        

        //统计标准模糊度
        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                if detectResultNode.nodeType == 3{
                    if self.laplacianDic[numIndex][detectResultNode.cardIndex[0]] == 0{
                        self.laplacianDic[numIndex][detectResultNode.cardIndex[0]] = detectResultNode.laplacianVariance
                    }
                    else{
                        self.laplacianDic[numIndex][detectResultNode.cardIndex[0]]! += detectResultNode.laplacianVariance
                        self.laplacianDic[numIndex][detectResultNode.cardIndex[0]]! /= 2
                    }
                }
            }
        }
        
        let isRiffleCenter = self.shuffleMode == 2 || (self.shuffleMode == 4 && isSingle)
        let isCut = isSingle && isShort
        let addEndIndex = endIndex - 3
        
        var lostNum = 0
        var addNum = 0
        //找所有遗漏的数字
        
        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                lostNum += 1
            }
        }
        
        //补牌
        if !isRiffleCenter && !isCut && beginIndex < addEndIndex && lostNum <= 3{
            
            var numIndexList : [Int] = []
            if !isSingle{
                numIndexList = [0, 1]
            }
            else if leftSideCnt > rightSideCnt{
                numIndexList = [0]
            }
            else if rightSideCnt > leftSideCnt{
                numIndexList = [1]
            }
            
            for key in confidenceDic.keys{
                if confidenceDic[key] == 0{
                    print("补牌：\(cardLabelDic[key]!)")
                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[detectResultListIndex + 1]![numIndex]
                            if detectResultNode.nodeType == 5 && nextDetectResultNode.nodeType == 5{
                                detectResultNode.cardIndex[0] = key
                                nextDetectResultNode.cardIndex[0] = key
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
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[detectResultListIndex + 1]![numIndex]
                            if (detectResultNode.nodeType == 0 || nextDetectResultNode.nodeType == 5)
                                && (detectResultNode.nodeType == 5 || nextDetectResultNode.nodeType == 0){
                                detectResultNode.cardIndex[0] = key
                                nextDetectResultNode.cardIndex[0] = key
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
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[detectResultListIndex + 1]![numIndex]
                            if detectResultNode.nodeType == 5{
                                detectResultNode.cardIndex[0] = key
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
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[detectResultListIndex + 1]![numIndex]
                            if detectResultNode.nodeType == 0{
                                detectResultNode.cardIndex[0] = key
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
        
        print("缺牌数量:\(addNum)    补牌数量:\(lostNum)")
        
        //补充链尾链头
        for keyIndex in beginIndex..<endIndex{
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
                        print("变形 ", detectResultListIndex, cardLabelDic[detectResultNode.cardIndex[0]] ?? "none", cardLabelDic[lastDetectResultNode.cardIndex[0]] ?? "none")
                        lastDetectResultNode.nodeType = 3
                        detectResultNode.nodeType = 2
                        detectResultNode.cardIndex[0] = lastDetectResultNode.cardIndex[0]
                        
                    }
                    
                    else if lastDetectResultNode.nodeType == 4{
                        print("变形 ", detectResultListIndex, cardLabelDic[detectResultNode.cardIndex[0]] ?? "none", cardLabelDic[lastDetectResultNode.cardIndex[0]] ?? "none")
                        lastDetectResultNode.nodeType = 1
                        detectResultNode.nodeType = 2
                        detectResultNode.cardIndex[0] = lastDetectResultNode.cardIndex[0]
                    }
                    
                }
                
                if (detectResultNode.nodeType == 5 || detectResultNode.nodeType == 0)
                    && sideDetectResultNode.nodeType == 1
                    && detectResultNode.laplacianVariance < nextDetectResultNode.laplacianVariance{
                    
                    if nextDetectResultNode.nodeType == 1
                        && nextDetectResultNode.laplacianVariance / nextnextDetectResultNode.laplacianVariance > blurThreshold
                        && detectResultNode.laplacianVariance / nextDetectResultNode.laplacianVariance < blurThreshold{
                        print("变形 ", detectResultListIndex, cardLabelDic[detectResultNode.cardIndex[0]] ?? "none", cardLabelDic[nextDetectResultNode.cardIndex[0]] ?? "none")
                        nextDetectResultNode.nodeType = 3
                        detectResultNode.nodeType = 1
                        detectResultNode.cardIndex[0] = nextDetectResultNode.cardIndex[0]
                        
                    }
                    
                    else if nextDetectResultNode.nodeType == 4{
                        print("变形 ", detectResultListIndex, cardLabelDic[detectResultNode.cardIndex[0]] ?? "none", cardLabelDic[nextDetectResultNode.cardIndex[0]] ?? "none")
                        nextDetectResultNode.nodeType = 2
                        detectResultNode.nodeType = 1
                        detectResultNode.cardIndex[0] = nextDetectResultNode.cardIndex[0]
                    }
                    
                }
            }
        }
        
        var detectCardArray : [Int] = []
        
        var noneCnt = 0
        var headCnt = 0
        var tailCnt = 0
        
        //插入牌堆
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
                    
                let nowNum0 = targetDetecResultList[detectResultListIndex]![0].cardIndex[0]
                let nodeType0 = targetDetecResultList[detectResultListIndex]![0].nodeType
                let nowNum1 = targetDetecResultList[detectResultListIndex]![1].cardIndex[0]
                let nodeType1 = targetDetecResultList[detectResultListIndex]![1].nodeType
                
                print("index ", detectResultListIndex,
                      cardLabelDic[nowNum0] ?? "none", detectResultNode0.nodeType, detectResultNode0.laplacianVariance, detectResultNode0.confidence[0], detectResultListIndex,
                      cardLabelDic[nowNum1] ?? "none", detectResultNode1.nodeType, detectResultNode1.laplacianVariance, detectResultNode1.confidence[0])
                               
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
                        print("左边下一张融合怪 右边先落下")
                        detectCardArray.insert(nowNum1, at: 0)
                        detectCardArray.insert(nowNum0, at: 0)
                    }
                    else if nextDetectResultNode0.nodeType != 5 && nextDetectResultNode1.nodeType == 5{
                        print("右边下一张融合怪 左边先落下")
                        detectCardArray.insert(nowNum0, at: 0)
                        detectCardArray.insert(nowNum1, at: 0)
                    }
                    else if nextDetectResultNode0.nodeType == 0 && nextDetectResultNode1.nodeType != 0{
                        print("左边下一张未识别 右边先落下")
                        detectCardArray.insert(nowNum1, at: 0)
                        detectCardArray.insert(nowNum0, at: 0)
                    }
                    else if nextDetectResultNode0.nodeType != 0 && nextDetectResultNode1.nodeType == 0{
                        print("右边下一张未识别 左边先落下")
                        detectCardArray.insert(nowNum0, at: 0)
                        detectCardArray.insert(nowNum1, at: 0)
                    }
                    else if leftLaplacianPercent < blurThreshold && rightLaplacianPercent >= blurThreshold{
                        print("左边糊了")
                        detectCardArray.insert(nowNum0, at: 0)
                        detectCardArray.insert(nowNum1, at: 0)
                    }
                    else if rightLaplacianPercent < blurThreshold && leftLaplacianPercent >= blurThreshold{
                        print("右边糊了")
                        detectCardArray.insert(nowNum1, at: 0)
                        detectCardArray.insert(nowNum0, at: 0)
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
                        else if nextDetectResultNode0.nodeType == 4 && self.laplacianDic[0][nextDetectResultNode0.cardIndex[0]] != 0{
                            leftNextLaplacianPercent = nextDetectResultNode0.laplacianVariance / self.laplacianDic[0][nextDetectResultNode0.cardIndex[0]]!
                        }
                        
                        if nextDetectResultNode1.nodeType == 1{
                            rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / nextnextDetectResultNode1.laplacianVariance
                        }
                        else if nextDetectResultNode1.nodeType == 0{
                            rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / nextnextDetectResultNode1.laplacianVariance
                        }
                        else if nextDetectResultNode1.nodeType == 4 && self.laplacianDic[1][nextDetectResultNode1.cardIndex[0]] != 0{
                            rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / self.laplacianDic[1][nextDetectResultNode1.cardIndex[0]]!
                        }
                        
                        if leftNextLaplacianPercent < blurThreshold && rightNextLaplacianPercent >= blurThreshold{
                            print("下一张左边糊了")
                            detectCardArray.insert(nowNum1, at: 0)
                            detectCardArray.insert(nowNum0, at: 0)
                        }
                        else if rightNextLaplacianPercent < blurThreshold && leftNextLaplacianPercent >= blurThreshold{
                            print("下一张右边糊了")
                            detectCardArray.insert(nowNum0, at: 0)
                            detectCardArray.insert(nowNum1, at: 0)
                        }
                        //上一张和下一张两边都不模糊 直接比较上一张两边模糊程度
                        else if leftLaplacianPercent < blurThreshold && rightLaplacianPercent < blurThreshold{
                            if leftLaplacianPercent < rightLaplacianPercent{
                                print("左边更糊")
                                detectCardArray.insert(nowNum0, at: 0)
                                detectCardArray.insert(nowNum1, at: 0)
                            }
                            else{
                                print("右边更糊")
                                detectCardArray.insert(nowNum1, at: 0)
                                detectCardArray.insert(nowNum0, at: 0)
                            }
                        }
                        else{
                            if leftNextLaplacianPercent < rightNextLaplacianPercent{
                                print("下一张左边更糊")
                                detectCardArray.insert(nowNum1, at: 0)
                                detectCardArray.insert(nowNum0, at: 0)
                            }
                            else{
                                print("下一张右边更糊")
                                detectCardArray.insert(nowNum0, at: 0)
                                detectCardArray.insert(nowNum1, at: 0)
                            }
                        }
                        
                    }
                }

                //单个插入
                else{
                    if (nodeType0 == 4 && !isRiffleCenter) || nodeType0 == 2{
                        
                        detectCardArray.insert(nowNum0, at: 0)
                        
//                        //暂时不用：判断下一张是否才是真正队尾
//                        var leftLaplacianPercent : Float = 1
//
//                        if nodeType0 == 2{
//                            leftLaplacianPercent = detectResultNode0.laplacianVariance / lastDetectResultNode0.laplacianVariance
//                        }
//                        else if nodeType0 == 4 && self.laplacianDic[0][nowNum0] != 0{
//                            leftLaplacianPercent = detectResultNode0.laplacianVariance / self.laplacianDic[0][nowNum0]!
//                        }
//
//                        if leftLaplacianPercent > blurThreshold
//                            && nextDetectResultNode0.nodeType == 0
//                            && nextDetectResultNode1.nodeType == 2{
//
//                            let nextLeftLaplacianPercent = nextDetectResultNode0.laplacianVariance / detectResultNode0.laplacianVariance
//                            let nextRightLaplacianPercent = nextDetectResultNode1.laplacianVariance / detectResultNode1.laplacianVariance
//
//                            if nextLeftLaplacianPercent < nextRightLaplacianPercent{
//                                detectCardArray.insert(nowNum0, at: 0)
//                            }
//                            else{
//                                detectCardArray.insert(nowNum1, at: 0)
//                                detectCardArray.insert(nowNum0, at: 0)
//                                nextDetectResultNode1.nodeType = 0
//                            }
//                        }
//                        else{
//                            detectCardArray.insert(nowNum0, at: 0)
//                        }
                    }
                    if (nodeType1 == 4 && !isRiffleCenter) || nodeType1 == 2{
                        
                        detectCardArray.insert(nowNum1, at: 0)
                        
//                        //暂时不用：判断下一张是否才是真正队尾
//                        var rightLaplacianPercent : Float = 1
//
//                        if nodeType1 == 2{
//                            rightLaplacianPercent = detectResultNode1.laplacianVariance / lastDetectResultNode1.laplacianVariance
//                        }
//                        else if nodeType1 == 4 && self.laplacianDic[1][nowNum1] != 0{
//                            rightLaplacianPercent = detectResultNode1.laplacianVariance / self.laplacianDic[1][nowNum1]!
//                        }
//
//                        if rightLaplacianPercent > blurThreshold
//                            && nextDetectResultNode1.nodeType == 0
//                            && nextDetectResultNode0.nodeType == 2{
//
//                            let nextLeftLaplacianPercent = nextDetectResultNode0.laplacianVariance / detectResultNode0.laplacianVariance
//                            let nextRightLaplacianPercent = nextDetectResultNode1.laplacianVariance / detectResultNode1.laplacianVariance
//
//                            if nextLeftLaplacianPercent < nextRightLaplacianPercent{
//                                detectCardArray.insert(nowNum0, at: 0)
//                                detectCardArray.insert(nowNum1, at: 0)
//                                nextDetectResultNode0.nodeType = 0
//                            }
//                            else{
//                                detectCardArray.insert(nowNum1, at: 0)
//                            }
//                        }
//                        else{
//                            detectCardArray.insert(nowNum1, at: 0)
//                        }
                    }
                }
            }
        }
        
        print("nonecnt:\(noneCnt)  headCnt:\(headCnt)  tailcnt:\(tailCnt)")
        
        //去除相同的牌
        var uniqueArray: [Int] = []
        for card in detectCardArray {
            if !uniqueArray.contains(card) {
                uniqueArray.append(card)
            }
        }
        
        let result = DetectionState(detectionResult: uniqueArray, isSingle: isSingle, isShort: isShort, longestIndex: longestIndex)
        return result
    }
    
    func cutCardArray(index : Int){
        if index < cardArray.count - 1{
            let elementsToMove = cardArray[(index+1)...]
            cardArray.removeSubrange((index+1)...)
            cardArray.insert(contentsOf: elementsToMove, at: 0)
        }
    }

    
    // MARK: compute targetArea
    func computeTargetArea(stateResult: [[Float]]){
        
        var originBoxes = stateResult
        
        
        if self.isHorizon
        {
            if originBoxes[0][0] > originBoxes[1][0]{
                originBoxes.swapAt(0, 1)
            }
            
            let minX = self.originSize[0] * (originBoxes[0][0] - originBoxes[0][2] / 2)
            let maxX = self.originSize[0] * (originBoxes[1][0] + originBoxes[1][2] / 2)
            let minY = self.originSize[1] * min(originBoxes[0][1] - originBoxes[0][3] / 2, originBoxes[1][1] - originBoxes[1][3] / 2)
            let maxY = self.originSize[1] * max(originBoxes[0][1] + originBoxes[0][3] / 2, originBoxes[1][1] + originBoxes[1][3] / 2)
            
            if minX + Float(self.imageSize[0]) >= self.originSize[0]{
                self.targetArea[0] = self.originSize[0] - Float(self.imageSize[0] / 2) - 1
                self.targetArea[2] = Float(self.imageSize[0])
            }
            else if maxX - Float(self.imageSize[0]) <= 0{
                self.targetArea[0] = Float(self.imageSize[0] / 2) + 1
                self.targetArea[2] = Float(self.imageSize[0])
            }
            else{
                self.targetArea[0] = (maxX + minX) / 2
                self.targetArea[2] = max(maxX - minX + 100, Float(self.imageSize[0]))
            }
            
            self.targetArea[3] = min(self.originSize[1] - 2, self.targetArea[2] / Float(self.imageSize[0]) * Float(self.imageSize[1]))
            
            if self.targetArea[3] == self.originSize[1] - 2{
                self.targetArea[1] = self.originSize[1] / 2
            }
            else if minY + self.targetArea[3] >= self.originSize[1]{
                self.targetArea[1] = self.originSize[1] - self.targetArea[3] / 2 - 1
            }
            else if maxY - self.targetArea[3] <= 0{
                self.targetArea[1] = self.targetArea[3] / 2 + 1
            }
            else{
                self.targetArea[1] = (maxY + minY) / 2
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
            
            if minY + Float(self.imageSize[0]) >= self.originSize[1]{
                self.targetArea[1] = self.originSize[1] - Float(self.imageSize[0] / 2) - 1
                self.targetArea[3] = Float(self.imageSize[0])
            }
            else if maxY - Float(self.imageSize[0]) <= 0{
                self.targetArea[1] = Float(self.imageSize[0] / 2) + 1
                self.targetArea[3] = Float(self.imageSize[0])
            }
            else{
                self.targetArea[1] = (maxY + minY) / 2
                self.targetArea[3] = max(maxY - minY + 100, Float(self.imageSize[0]))
            }
            
            self.targetArea[2] = min(self.originSize[0] - 2, self.targetArea[3] / Float(self.imageSize[0]) * Float(self.imageSize[1]))
            
            if self.targetArea[2] == self.originSize[0] - 2{
                self.targetArea[0] = self.originSize[0] / 2
            }
            else if minX + self.targetArea[2] >= self.originSize[0]{
                self.targetArea[0] = self.originSize[0] - self.targetArea[2] / 2 - 1
            }
            else if maxX - self.targetArea[2] <= 0{
                self.targetArea[0] = self.targetArea[2] / 2 + 1
            }
            else{
                self.targetArea[0] = (maxX + minX) / 2
            }
        }
    }
    
    // MARK: update targetArea
    func updateTargetArea(coordinates:[[Float]]){
        if self.isHorizon{
            let targetX = self.targetArea[0]
            let targetY = self.targetArea[1]
            let targetW = self.targetArea[2]
            let targetH = self.targetArea[3]
            let x0 = (coordinates[0][0] * targetW + targetX - targetW / 2) / originSize[0]
            let y0 = (coordinates[0][1] * targetH + targetY - targetH / 2) / originSize[1]
            let w0 = (coordinates[0][2] * targetW) / originSize[0]
            let h0 = (coordinates[0][3] * targetH) / originSize[1]
            let x1 = (coordinates[1][0] * targetW + targetX - targetW / 2) / originSize[0]
            let y1 = (coordinates[1][1] * targetH + targetY - targetH / 2) / originSize[1]
            let w1 = (coordinates[1][2] * targetW) / originSize[0]
            let h1 = (coordinates[1][3] * targetH) / originSize[1]
            computeTargetArea(stateResult: [[x0,y0,w0,h0],[x1,y1,w1,h1]])
        }
        else{
            let targetX = self.targetArea[0]
            let targetY = self.targetArea[1]
            let targetW = self.targetArea[2]
            let targetH = self.targetArea[3]
            let x0 = ((1 - coordinates[0][1]) * targetW + targetX - targetW / 2) / originSize[0]
            let y0 = (coordinates[0][0] * targetH + targetY - targetH / 2) / originSize[1]
            let w0 = (coordinates[0][3] * targetW) / originSize[0]
            let h0 = (coordinates[0][2] * targetH) / originSize[1]
            let x1 = ((1 - coordinates[1][1]) * targetW + targetX - targetW / 2) / originSize[0]
            let y1 = (coordinates[1][0] * targetH + targetY - targetH / 2) / originSize[1]
            let w1 = (coordinates[1][3] * targetW) / originSize[0]
            let h1 = (coordinates[1][2] * targetH) / originSize[1]
            computeTargetArea(stateResult: [[x0,y0,w0,h0],[x1,y1,w1,h1]])
        }
    }

    // MARK: get card
    //返回检测到的目标类别，n当前设定为最多两个，后续可根据置信度进行排序输出或全部输出
    func getCard(from cardArray: MLMultiArray, from boxArray : MLMultiArray, from pixelBuffer : CVPixelBuffer) -> [DetectionResult] {
        let cnt : Int = Int(cardArray.shape[0])
        let n : Int = Int(cardArray.shape[1])
        var result : [DetectionResult] = []
        
        
        if self.state == "idle"{
            for i in 0..<cnt {
                var maxVal: Float32 = cardArray[i * n].floatValue
                var confidenceSum : Float = 0
                var cardIndex : [Int] = []
                var confidence : [Float] = []
                for j in 0..<n {
                    let index = i * n + j
                    let value = cardArray[index].floatValue
                    confidenceSum += value
                }
                for j in 0..<n {
                    let index = i * n + j
                    let value = cardArray[index].floatValue
                    
                    let trueIndex = j == 52 ? 54 : j
                    
                    if value > 0 && self.allCardIndex.contains(trueIndex){
                        
                        if (value/confidenceSum>=0) {
                            cardIndex.append(j)
                            confidence.append(value)
                        }
                        
                        if value > maxVal {
                            maxVal = value
                        }
                    }
                }
                // 对 cardIndex 进行排序
                cardIndex.sort{cardArray[$0 + i*n].floatValue > cardArray[$1 + i*n].floatValue}
                confidence.sort{ $0 > $1 }
                
                let centerX = boxArray[i*4].floatValue
                let centerY = boxArray[i*4+1].floatValue
                let widthX = boxArray[i*4+2].floatValue
                let heightY = boxArray[i*4+3].floatValue
                
                let coordinate = [centerX, centerY, widthX, heightY]
                
                if cardIndex.count > 0{
                    if let index = result.firstIndex(where: { ($0.targetDistance(target: coordinate)) < 0.01 }) {
                        
                        if maxVal > result[index].confidence[0] {
                            result[index].cardIndex = cardIndex + result[index].cardIndex
                            result[index].confidence = confidence + result[index].confidence
                        }
                        else{
                            result[index].cardIndex = result[index].cardIndex + cardIndex
                            result[index].confidence = result[index].confidence + confidence
                        }
                    }
                    else{
                        result.append(DetectionResult(cardIndex: cardIndex, confidence: confidence, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: 0))
                    }
                }
            }
            
            //先删除相同的
            if result.count > 2{
                // 使用 Set 来去除重复元素
                var uniqueCardIndexes = Set<Int>()
                
                result = result.filter {
                    let cardIndex0 = $0.cardIndex[0]
                    if uniqueCardIndexes.contains(cardIndex0) {
                        return false // 已经存在相同的 cardIndex[0]
                    } else {
                        uniqueCardIndexes.insert(cardIndex0)
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
                if abs(result[0].coordinate[0] - result[1].coordinate[0]) > abs(result[0].coordinate[1] - result[1].coordinate[1]){
                    isHorizon = true
                    if result[0].coordinate[0] > self.centerPos[0]{
                        result.swapAt(0, 1) //x坐标小的在左边
                    }
                }
                //纵向排列
                else{
                    isHorizon = false
                    if result[0].coordinate[1] > self.centerPos[1]{
                        result.swapAt(0, 1) //y坐标小的在左边
                    }
                }
            }
            else if result.count == 1{
                if isHorizon{
                    if result[0].coordinate[0] > self.centerPos[0]{
                        result.insert(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0), at: 0)
                    }
                    else{
                        result.insert(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0), at: 1)
                    }
                }
                else{
                    if result[0].coordinate[1] > self.centerPos[1]{
                        result.insert(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0), at: 0)
                    }
                    else{
                        result.insert(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0), at: 1)
                    }
                }
            }
            else if result.count == 0{
                result.append(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0))
                result.append(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0))
            }
            
            for resultIndex in 0..<result.count{
                result[resultIndex].cardIndex = result[resultIndex].cardIndex.map { $0 == 52 ? 54 : $0 }
            }
            
            self.centerPos = [(result[0].coordinate[0] + result[1].coordinate[0])/2, (result[0].coordinate[1] + result[1].coordinate[1])/2]
            self.lastBoxes = [result[0].coordinate,result[1].coordinate]
            
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
                var maxVal: Float32 = cardArray[i * n].floatValue
                var confidenceSum : Float = 0
                var cardIndex : [Int] = []
                var confidence : [Float] = []
                for j in 0..<n {
                    let index = i * n + j
                    let value = cardArray[index].floatValue
                    confidenceSum += value
                }
                for j in 0..<n {
                    let index = i * n + j
                    let value = cardArray[index].floatValue
                    
                    let trueIndex = j == 52 ? 54 : j
                    
                    if value > 0 && self.allCardIndex.contains(trueIndex){
                        
                        if (value/confidenceSum>=0) {
                            cardIndex.append(j)
                            confidence.append(value)
                        }
                        
                        if value > maxVal {
                            maxVal = value
                        }
                    }
                }
                // 对 cardIndex 进行排序
                cardIndex.sort{cardArray[$0 + i*n].floatValue > cardArray[$1 + i*n].floatValue}
                confidence.sort{ $0 > $1 }
                
                let centerX = boxArray[i*4].floatValue
                let centerY = boxArray[i*4+1].floatValue
                let widthX = boxArray[i*4+2].floatValue
                let heightY = boxArray[i*4+3].floatValue
                
                let coordinate = [centerX, centerY, widthX, heightY]
                
                if cardIndex.count > 0{
                    if let index = result.firstIndex(where: { ($0.targetDistance(target: coordinate)) < 0.01 }) {
                        
                        if maxVal > result[index].confidence[0] {
                            result[index].cardIndex = cardIndex + result[index].cardIndex
                            result[index].confidence = confidence + result[index].confidence
                        }
                        else{
                            result[index].cardIndex = result[index].cardIndex + cardIndex
                            result[index].confidence = result[index].confidence + confidence
                        }
                    }
                    else{
                        result.append(DetectionResult(cardIndex: cardIndex, confidence: confidence, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: 0))
                    }
                }
            }
            
            //先删除相同的
            if result.count > 2{
                // 使用 Set 来去除重复元素
                var uniqueCardIndexes = Set<Int>()
                
                result = result.filter {
                    let cardIndex0 = $0.cardIndex[0]
                    if uniqueCardIndexes.contains(cardIndex0) {
                        return false // 已经存在相同的 cardIndex[0]
                    } else {
                        uniqueCardIndexes.insert(cardIndex0)
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
                if abs(result[0].coordinate[0] - result[1].coordinate[0]) > abs(result[0].coordinate[1] - result[1].coordinate[1]){
                    isHorizon = true
                    if result[0].coordinate[0] > self.centerPos[0]{
                        result.swapAt(0, 1) //x坐标小的在左边
                    }
                }
                //纵向排列
                else{
                    isHorizon = false
                    if result[0].coordinate[1] > self.centerPos[1]{
                        result.swapAt(0, 1) //y坐标小的在左边
                    }
                }
            }
            else if result.count == 1{
                if isHorizon{
                    if result[0].coordinate[0] > self.centerPos[0]{
                        result.insert(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0), at: 0)
                    }
                    else{
                        result.insert(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0), at: 1)
                    }
                }
                else{
                    if result[0].coordinate[1] > self.centerPos[1]{
                        result.insert(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0), at: 0)
                    }
                    else{
                        result.insert(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0), at: 1)
                    }
                }
            }
            else if result.count == 0{
                result.append(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0))
                result.append(DetectionResult(cardIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0))
            }
            
            
            
            for resultIndex in 0..<result.count{
                result[resultIndex].cardIndex = result[resultIndex].cardIndex.map { $0 == 52 ? 54 : $0 }
            }
            
            self.centerPos = [(result[0].coordinate[0] + result[1].coordinate[0])/2, (result[0].coordinate[1] + result[1].coordinate[1])/2]
            self.lastBoxes = [result[0].coordinate,result[1].coordinate]
            
            for resultIndex in 0..<result.count{
                result[resultIndex].laplacianVariance = ComputeROILaplacianVariance(box: lastBoxes[resultIndex], destinationBuffer8: destinationBuffer8)
            }
            
            
            return result
        }
    }
    
    //MARK: generate test result
    func generateTestResult(){
        var testArray:[Int] = []
        for i in self.allCardIndex{
            testArray.append(i)
        }
        
        testArray.shuffle()
        self.cardArray = testArray
        
        self.cutArray = []
        self.cutShowArray = []
        
        if self.cutMode != 0{
            let cutCard : Int = self.cardArray.randomElement()!
            var cutIndex = self.cardArray.firstIndex(of: cutCard)!
            if self.cutMode == 1{
                //看底
                self.cutCardArray(index: cutIndex)
            }
            else if self.cutMode == 2{
                //看顶
                cutIndex -= 1
                if cutIndex < 0{
                    cutIndex = self.cardArray.count - 1
                }
                self.cutCardArray(index: cutIndex)
            }
            else if self.cutMode == 3{
                //切牌
                self.cutArray.append(cutCard)
            }
            else if self.cutMode == 4{
                //看手
                self.cutArray.append(cutCard)
            }
            self.cutShowArray.append(cutCard)
        }
        
        computeWinnerPlayer()
    }
    
    //MARK: comupute winner
    func computeWinnerPlayer() {
        print("计算信息")
        print("切牌 \(self.cutArray)")
        print("测试游戏：\(String(describing: generalRuleSetting.allGameType[ruleIndex])), 游戏人数 \((GameManager.gameRules[ruleIndex]?.playerNum[playerNum])!), args：\(args), 牌型顺序：\(rankRules) 花色顺序：\(suitRules), 发牌定制: \(dealNum), 打色模式: \(coloringType) 正发反发: \(dealType),  自定义发牌类型和发牌数量：\(diyDealStatus), \(diyDealNum), 打色模式：\(calModeArgs[0]), 目标位置：\(calModeArgs[1]), 打色点数设置: \(cutNumSetting), 打色范围：\(cutNumRangeSetting[0])- \(cutNumRangeSetting[1]), 连报轮数：\(consecutiveReport)")
                
        print("开始需要的最少牌数 \(minCardNum)")
        if cardArray.count >= minCardNum && cardArray.count > cutNumRangeSetting[0] && cardArray.count > cutNumRangeSetting[1] - minCardNum{
            multipleGamePlayerInfos = GameManager.selectGame(gameIndex: ruleIndex, inputCards: cardArray, playerNum: (GameManager.gameRules[ruleIndex]?.playerNum[playerNum])!, args: args, rankRules: rankRules, suitRules: suitRules,dealNum: dealNum, coloringType: coloringType, dealType: dealType, diyDealNum: diyDealNum,diyDealStatus: diyDealStatus, calModeArgs: calModeArgs, cutNumSetting: cutNumSetting, cutNumRangeSetting: cutNumRangeSetting, consecutiveReport: consecutiveReport, minCardNum: minCardNum, cutCardIndexArray: cutArray)
            
            self.cardArray = multipleGamePlayerInfos.returnCardArray
            self.leftCards = multipleGamePlayerInfos.leftCards
            
            speakText(input: multipleGamePlayerInfos.reportResult)
        }
    }
    
    func speakText(input: Int){
        let isSpeak = self.isHeadphonesConnected() == self.isMute
        
        if isSpeak{
            speechSynthesizer.stopSpeaking(at: .immediate)
            if input == 0{
                self.startAudioPlayer?.play()
            }
            else if input == 1{
                self.successAudioPlayer?.play()
            }
            else if input == 2{
                self.failAudioPlayer?.play()
            }
        }
    }

    func speakText(input: [[SpeakResultStruct]]) {
        let isSpeak = self.isHeadphonesConnected() == self.isMute
        
        if isSpeak{
            speechSynthesizer.stopSpeaking(at: .immediate)
            for (_, turnResult) in input.enumerated() {
                for (reportIndex, reportResult) in turnResult.enumerated() {
                    print("播报的input \(reportResult)")
                    let speakString = reportResult.content
                    if speakString != ""{
                        let speechUtterance = AVSpeechUtterance(string: speakString)
                        speechUtterance.postUtteranceDelay = 0.1
                        if reportResult.voiceType == 0{
                            speechUtterance.voice = chineseMaleVoice
                        }
                        if reportResult.voiceType == 1{
                            speechUtterance.voice = chineseFemaleVoice
                        }
                        
                        if reportIndex == 0{
                            speechUtterance.preUtteranceDelay = 0.2
                        }
                        else{
                            speechUtterance.preUtteranceDelay = 0
                        }
                        speechSynthesizer.speak(speechUtterance)
                    }
                }
            }
        }
    }
    
    func speakText(input: String){
        let isSpeak = self.isHeadphonesConnected() == self.isMute
        if isSpeak{
            let speechUtterance = AVSpeechUtterance(string: input)
            speechSynthesizer.stopSpeaking(at: .immediate)
            speechSynthesizer.speak(speechUtterance)
        }
    }

    
    func isHeadphonesConnected() -> Bool {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        let connectedBluetoothHeadphones = currentRoute.outputs.contains { $0.portType == .bluetoothA2DP }
        return connectedBluetoothHeadphones
    }
    
    
    public func handleVolumeIncrease() {
        
        let selectedRule = GameManager.gameRules[ruleIndex]!
        
        // 处理音量增加事件的逻辑
        if self.volumeUp == 1{
            let playNumList = selectedRule.playerNum
            self.playerNum += 1
            if self.playerNum >= playNumList.count{
                self.playerNum = 0
            }
            speakText(input: "人数" + String(selectedRule.playerNum[self.playerNum]))
        }
        else if self.volumeUp == 2{
            let currentNum = selectedRule.playerNum[self.playerNum]
            var positionSetting = self.calModeArgs[1] + 1
            if positionSetting >= currentNum{
                positionSetting = 0
            }
            self.calModeArgs[1] = positionSetting
            speakText(input: "位置" + String(positionSetting+1))
        }
        else if self.volumeUp == 3{
            self.shuffleMode += 1
            if self.shuffleMode >= generalRuleSetting.allShuffleMode.count{
                self.shuffleMode = 0
            }
            speakText(input: generalRuleSetting.allShuffleMode[self.shuffleMode]!)
        }
        else if self.volumeUp == 4{
            self.selectedSaveIndex += 1
            if self.selectedSaveIndex >= RuleManager.allUsersGameRule.count{
                self.selectedSaveIndex = 0
            }
            loadSaveRule(saveRuleIndex: self.selectedSaveIndex)
            speakText(input: "方案" + String(self.selectedSaveIndex+1))
        }
        else if self.volumeUp == 5{
            isWorking.toggle()
            if isWorking{
                speakText(input: "开始")
            }
            else{
                speakText(input: "暂停")
            }
        }
        else if self.volumeUp == 6{
            self.cardArray = self.leftCards
            computeWinnerPlayer()
        }
    }
    
    public func handleVolumeDecrease() {
        // 处理音量减少事件的逻辑
        
        let selectedRule = GameManager.gameRules[ruleIndex]!
        
        if self.volumeDown == 1{
            let playNumList = selectedRule.playerNum
            self.playerNum -= 1
            if self.playerNum < 0{
                self.playerNum = playNumList.count - 1
            }
            speakText(input: "人数" + String(selectedRule.playerNum[self.playerNum]))
        }
        else if self.volumeDown == 2{
            let currentNum = selectedRule.playerNum[self.playerNum]
            var positionSetting = self.calModeArgs[1] - 1
            if positionSetting < 0{
                positionSetting = currentNum - 1
            }
            self.calModeArgs[1] = positionSetting
            speakText(input: "位置" + String(positionSetting+1))
        }
        else if self.volumeDown == 3{
            self.shuffleMode -= 1
            if self.shuffleMode < 0{
                self.shuffleMode = generalRuleSetting.allShuffleMode.count - 1
            }
            speakText(input: generalRuleSetting.allShuffleMode[self.shuffleMode]!)
        }
        else if self.volumeDown == 4{
            self.selectedSaveIndex -= 1
            if self.selectedSaveIndex < 0{
                self.selectedSaveIndex = RuleManager.allUsersGameRule.count - 1
            }
            loadSaveRule(saveRuleIndex: self.selectedSaveIndex)
            speakText(input: "方案" + String(self.selectedSaveIndex+1))
        }
        else if self.volumeDown == 5{
            isWorking.toggle()
            if isWorking{
                speakText(input: "开始")
            }
            else{
                speakText(input: "暂停")
            }
        }
        else if self.volumeDown == 6{
            self.cardArray = self.leftCards
            computeWinnerPlayer()
        }
        else if self.volumeDown == 7{
            self.volumeUp += 1
            if self.volumeUp >= volumeSetting.volumeUpDict.count{
                self.volumeUp = 0
            }
            speakText(input: volumeSetting.volumeUpDict[self.volumeUp]!)
        }
    }
    
    private func loadSaveRule(saveRuleIndex: Int){
        self.selectedSaveIndex = saveRuleIndex
        let rules = RuleManager.allUsersGameRule[self.selectedSaveIndex]
        self.ruleIndex = rules.gameType
        self.playerNum = rules.playerNum
        self.dealNum = rules.dealNum
        self.coloringType = rules.coloringType
        self.cutMode = rules.cutMode
        self.dealType = rules.dealType
        self.diyDealNum = rules.diyDealNum
        self.diyDealStatus = rules.diyDealStatus
        self.playerNum = rules.playerNum
        self.shuffleMode = rules.shuffleMode
        self.allCardIndex = rules.cardToUse
        self.cutNumSetting = rules.cutNumSetting
        self.cutNumRangeSetting = rules.cutNumRangeSetting
        self.calModeArgs = [rules.reportSetting, rules.positionSetting]
        self.consecutiveReport = rules.consecutiveReport
        self.reportNumber = rules.reportNumber
        self.voiceReport = rules.voiceReport
        self.args = rules.args
        self.suitRules = rules.suitRanks
        self.rankRules = rules.rankRules
        self.minCardNum = rules.minCardNum
        print("self.rankRules \(self.rankRules)")
    }
    
    public func updateConfigJSON() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("config.json")

            let boolDict: [String: Bool] = [
                "isBlack": self.isBlack,
                "isMute": self.isMute,
                "isBackCamera" : self.isBackCamera,
                "isRemote" : self.isRemote,
                "isFast": self.isFast,
                "isActive": self.isActive,
                "isAutoFocus": self.isAutoFocus
            ]
            
            let intDict : [String: Int] = [
                "volumeUp": self.volumeUp,
                "volumeDown": self.volumeDown
            ]
            
            let floatDict : [String: Float] = [
                "volumeValue": self.volumeValue,
                "zoomFactor": self.zoomFactor,
                "focusFactor": self.focusFactor
            ]
            
            let configData: [String: Any] = [
                "Int": intDict,
                "Float": floatDict,
                "Bool": boolDict
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: configData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)

            print("config.json file updated successfully")
        } catch {
            print("Error updating config.json: \(error)")
        }
    }
}


class DetectionResult {
    var cardIndex : [Int]
    var confidence : [Float]
    var confidencePercent : Float
    var coordinate : [Float]
    var nodeType : Int //0未知 1链头 2链尾 3链体 4单个节点 5融合牌
    var laplacianVariance : Float

    init(cardIndex: [Int], confidence: [Float], confidencePercent: Float, coordinate: [Float], laplacianVariance: Float) {
        self.cardIndex = cardIndex
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

class SpeakResultStruct{
    var voiceType : Int //0男 1女
    var content : String
    
    init(voiceType: Int, content: String) {
        self.voiceType = voiceType
        self.content = content
    }
}
