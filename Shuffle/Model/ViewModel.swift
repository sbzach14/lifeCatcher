

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


/// - Tag: ViewModel
class ViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var cameraImage : CGImage?
    @Published var isShowCard : Bool = false
    
    // cardArray, 装有所以poker的array
    @Published var cardArray :  [Int] = []
    @Published var winnerPlayer: [Int] = []

    let model = try! cardDetection_s_0114()
    let imageSize : [Int] = [640, 480]
    var originSize : [Float] = [0,0]
    


    
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
    public var playerNum: Int = 0
    public var dealType: Int = 0
    public var diyDealType: Int = 0
    public var diyDealNum: [Int] = []
    public var diyDealStatus: [[Bool]] = []
    public var calModeArgs : [Int] = [0, 0, 1]
    public var cutNumSetting: Int = 0
    public var cutNumRangeSetting: [Int] = [2,10]
    public var consecutiveReport: Int = 0
    public var cutSetting: Int = 0
    public var reportNumber: Int = 0
    public var voiceReport: Int = 0
    public var ruleIndex : Int = 0
    public var args : [Int] = []
    public var rankRules : [Int] = []
    public var suitRules : [Int] = [3,2,1,0]
    public var allCardIndex : [Int] = Array(0...51)
    public var minCardNum : Int = 0
    
    var lastCards : [[Int]] = []

    
    let context = CIContext()
    var taskImageArray : [String] = []
    
    var isSavedImage : Bool = true
    var saveCount: Int = -1
    var saveFlag: Bool = false
    var isEmptyFrame : Bool = true
    var taskIndex : Int = 0
    var currentTask: Int = 0
    
    var tempCardArray : [[Int]] = []
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
    
    private var confidenceDic : [Int:Float] = [:]
    private var laplacianDic: [[Int:Float]] = [[:],[:]]
    
    let cardLabelDic : [Int:String] = [
        0: "♠️A ", 1: "♠️2", 2: "♠️3", 3: "♠️4", 4: "♠️5 ", 5: "♠️6 ", 6: "♠️7 ", 7: "♠️8 ", 8: "♠️9 ", 9: "♠️10 ",
        10: "♠️J ", 11: "♠️Q ", 12: "♠️K ", 13: "♥️A ", 14: "♥️2 ", 15: "♥️3 ", 16: "♥️4 ", 17: "♥️5 ", 18: "♥️6 ",
        19: "♥️7 ", 20: "♥️8 ", 21: "♥️9 ", 22: "♥️10 ", 23: "♥️J ", 24: "♥️Q ", 25: "♥️K ", 26: "♣️A ", 27: "♣️2 ",
        28: "♣️3 ", 29: "♣️4 ", 30: "♣️5 ", 31: "♣️6 ", 32: "♣️7 ", 33: "♣️8 ", 34: "♣️9 ", 35: "♣️10 ", 36: "♣️J ",
        37: "♣️Q ", 38: "♣️K ", 39: "♦️A ", 40: "♦️2 ", 41: "♦️3 ", 42: "♦️4 ", 43: "♦️5 ", 44: "♦️6", 45: "♦️7",
        46: "♦️8 ", 47: "♦️9 ", 48: "♦️10 ", 49: "♦️J ", 50: "♦️Q ", 51: "♦️K ", 52: "none", 53: "小王", 54: "大王"
    ]
    
    var isBlack: Bool = false
    var isMute: Bool = false
    var isBackCamera: Bool = false
    var isRemote: Bool = false
    var setFrameRate: Float64 = 120.0
    var cameraFrameRate: Int = 0
    
    var testCVPixelBuffer : CVPixelBuffer?


    func initialize(playerNum: Int, shuffleMode : Int, dealType: Int, diyDealType: Int, diyDealNum: [Int], diyDealStatus: [[Bool]], calModeArgs : [Int],cutNumSetting: Int, cutNumRangeSetting:[Int], consecutiveReport: Int, cutSetting:Int, reportNumber: Int, voiceReport:Int, ruleIndex: Int, args : [Int], rankRules : [Int], suitRules : [Int], allCardIndex : [Int], minCardNum : Int) {
        
        self.playerNum = (GameManager.gameRules[ruleIndex]?.playerNum[playerNum])!
        self.shuffleMode = shuffleMode
        self.dealType = dealType
        self.diyDealType = diyDealType
        self.diyDealNum = diyDealNum
        self.diyDealStatus = diyDealStatus
        self.calModeArgs = calModeArgs
        self.consecutiveReport = consecutiveReport
        self.cutNumSetting = cutNumSetting
        self.cutNumRangeSetting = cutNumRangeSetting
        self.cutSetting = cutSetting
        self.reportNumber = reportNumber
        self.voiceReport = voiceReport
        
        self.ruleIndex = ruleIndex
        self.args = args
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.allCardIndex = allCardIndex
        self.minCardNum = minCardNum
        self.initCardArray()
        
        // Python 初始化
        print("pythonInitialize")
        guard let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil) else { return }
        guard let libDynloadPath = Bundle.main.path(forResource: "python-stdlib/lib-dynload", ofType: nil) else { return }

        setenv("PYTHONHOME", stdLibPath, 1)
        setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath)", 1)

        Py_Initialize()
        print("pythonInitialize done")
        
        for key in self.allCardIndex {
            self.laplacianDic[0][key] = 0
            self.laplacianDic[1][key] = 0
        }
        self.initCardArray()
        
        // Load data from config.json
        if let configData = readConfigJSON() {
            self.isBlack = configData["isBlack"]!
            self.isMute = configData["isMute"]!
            self.isBackCamera = configData["isBackCamera"]!
            self.isRemote = configData["isRemote"]!
        } else {
            // If config.json is not found or invalid, set default values
            self.isBlack = false
            self.isMute = false
            self.isBackCamera = false
            self.isRemote = false
        }
        
        setupAVCapture()
        
        //规则测试代码
//        for i in 0..<1{
//            print("测试用例 ",i + 1,"")
//            var randomCardArray = Array(0...51)
//            randomCardArray.shuffle()
//            self.cardArray = randomCardArray
//
//            var cardString:String = "当前牌库："
//            for cardIndex in cardArray{
//                cardString += cardLabelDic[cardIndex]! + " "
//            }
//            print(cardString)
//            self.computeWinnerPlayer()
//        }

    }
    
    private func initCardArray(){
        
        confidenceDic.removeAll()
        for key in self.allCardIndex {
            confidenceDic[key] = 0
        }
        
        cardArray = []
        lastCards = [[-1], [-1]]
        winnerPlayer = []
        stateCounter = 0
        stateCard = [-1, -1]
        tempCardArray = []
        detectResultList = [:]
    }
    
    private func initBoxes(){
        centerPos = [0.5, 0.5]
        lastBoxes = [[0.3, 0.5, 0.05, 0.05], [0.7, 0.5, 0.05, 0.05]]
        isHorizon = true
        targetArea = [0,0,0,0]
    }
    
    func showCardToggle() {
        if self.isShowCard{
            self.isShowCard = false
        }
        else{
            self.isShowCard = true
        }
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
            session.addInput(captureDeviceInput!)
            
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            session.addOutput(output)
            
            
            // 设置帧率为120帧
            print("设定识别帧率: \(self.setFrameRate)")

            
            guard let format = self.captureDevice.formats.first(where: { format in
                let ranges = format.videoSupportedFrameRateRanges
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                self.originSize = [1920, 1080]
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
                
                // 设置更短的曝光时间（更快的快门速度）
                //let desiredExposureDuration: CMTime = CMTimeMake(value: 1, timescale: 200) // 1/1000 秒

                //captureDevice.exposureMode = .continuousAutoExposure

                self.captureDevice.unlockForConfiguration()
            } catch {
                print("设置帧率时发生错误: \(error)")
            }
            
            session.commitConfiguration()
            
            // 获取当前帧率
            let videoFrameRate = format.videoSupportedFrameRateRanges.first!.maxFrameRate
            print("设定帧率: \(videoFrameRate)")
            changeCameraFrameRate(to: 30)
        } catch {
            print("配置前置摄像头时发生错误: \(error)")
        }
    }
    
    func startCamera() {
        
        session.startRunning()
        print("开启相机")
    }
    
    func stopCamera() {
        if let inputs = session.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                session.removeInput(input)
            }
        }
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
        
//        let modelCIImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let cgImage = CIContext().createCGImage(modelCIImage, from: modelCIImage.extent)
//        let savedUIImage = UIImage(cgImage: cgImage!)
//        UIImageWriteToSavedPhotosAlbum(savedUIImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        backgroundQueue.async {
            var indexGap = 4
            if self.isBackCamera{
                indexGap = 8
            }
            if !self.isBlack && (self.cameraFrameRate <= 30 || self.taskIndex % indexGap == 0){
                do{
                    let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent)!
                    let cgImageFormat = vImage_CGImageFormat(
                        bitsPerComponent: UInt32(cgImage.bitsPerComponent),
                        bitsPerPixel: UInt32(cgImage.bitsPerPixel),
                        colorSpace: Unmanaged.passUnretained(cgImage.colorSpace!),
                        bitmapInfo: cgImage.bitmapInfo,
                        version: 0,
                        decode: nil,
                        renderingIntent: cgImage.renderingIntent)
                    
                    // 创建 vImage_Buffer
                    var vImageBuffer = try vImage_Buffer(cgImage: cgImage)
                    
                    var outputCGImage : CGImage
                    
                    // 进行顺时针旋转90度
                    var rotatedBuffer = try! vImage_Buffer(width: Int(vImageBuffer.height),
                                                           height: Int(vImageBuffer.width),
                                                           bitsPerPixel: 32) // 32 bits for ARGB
                    vImageRotate90_ARGB8888(&vImageBuffer, &rotatedBuffer, UInt8(kRotate90DegreesClockwise), [0], vImage_Flags(kvImageNoFlags))
                    
                    outputCGImage = try rotatedBuffer.createCGImage(format: cgImageFormat)
                    rotatedBuffer.free()
                    
                    
                    DispatchQueue.main.async {
                        self.cameraImage = outputCGImage
                    }
                    
                    
                    vImageBuffer.free()
                }
                
                catch{
                    print("Error: \(error)")
                }
            }
                
            if !self.isShowCard{
                
                self.detectionQueue.async {
                    let cvPixelBuffer = createCVPixelBuffer(ciImage: ciImage, targetSize: CGSize(width: self.imageSize[0], height: self.imageSize[1]), targetArea: self.targetArea)!
                    self.processImageOrigin(cvPixelBuffer, taskIndex: myIndex)
                }
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
        
        let result = try! model.prediction(image: pixelBuffer, iouThreshold: 0.45, confidenceThreshold: 0.7)
        let cardResult = getCard(from: result.confidence, from: result.coordinates, from: pixelBuffer)
        
        
        
        if cardResult[0].cardIndex[0] == self.stateCard[0] && cardResult[1].cardIndex[0] == self.stateCard[1]{
            stateCounter = min(stateCounter + 1, 600)
        }
        else{
            stateCounter = 0
        }
        
        self.stateCard[0] = cardResult[0].cardIndex[0]
        self.stateCard[1] = cardResult[1].cardIndex[0]
        
        
        if state == "idle"{
            if self.stateCard[0] != -1 && self.stateCard[1] != -1 && self.stateCard[0] != self.stateCard[1]
                && stateCounter > 3
                && shuffleMode == 0{
                state = "shuffle"
                print("动作：开始洗牌 ", self.setFrameRate)
                speakText(input: 0)
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                    self.initCardArray()
                    if self.isRemote{
                        self.computeTargetArea(stateResult: self.lastBoxes)
                    }
                }
            }
            else if (self.stateCard[0] == -1 || self.stateCard[1] == -1) && self.stateCard[0] != self.stateCard[1]
                && stateCounter > 3
                && shuffleMode != 0{
                state = "shuffle"
                print("动作：开始拨牌")
                speakText(input: 0)
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                    self.initCardArray()
                    if self.isRemote{
                        self.computeTargetArea(stateResult: self.lastBoxes)
                    }
                }
                
            }
            else if (self.stateCard[0] != -1 && self.stateCard[0] == self.stateCard[1])
                        && self.cardArray.contains(self.stateCard[0])
                        && stateCounter > 3{
                state = "cut"
                print("动作：开始切牌")
                speakText(input: 0)
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                    if self.isRemote{
                        self.computeTargetArea(stateResult: self.lastBoxes)
                    }
                }
            }
        }
        else if state == "cut"{
            if self.stateCard[0] == -1 && self.stateCard[1] == -1 && stateCounter > 10{
                state = "idle"
                print("动作：切牌完成")
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: 30)
                    self.cutCardArray(cardResult: cardResult, taskIndex: taskIndex)
                    self.computeWinnerPlayer()
                    self.initBoxes()
                }
            }
            else{
                if self.isRemote{
                    updateTargetArea(coordinates: self.lastBoxes)
                }
            }
        }
        else if state == "shuffle"{
            if self.stateCard[0] == -1 && self.stateCard[1] == -1 && stateCounter > 10{
                state = "idle"
                print("动作：洗牌完成 ", self.setFrameRate)
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: 30)
                    self.handleDetecResultList()
                    self.initBoxes()
                    
                    if self.shuffleMode == 2 && self.cardArray.count > 0{
                        self.cardArray.remove(at: 0)
                    }
                        
                    self.computeWinnerPlayer()
                }
            }
            else{
                self.detectResultList[taskIndex] = cardResult
                
                if self.isRemote{
                    updateTargetArea(coordinates: self.lastBoxes)
                }
            }
        }
        
        
//        if self.state == "shuffle" || self.saveFlag == true {
//            self.saveCount += 1
//            if self.saveFlag == false{
//                self.saveFlag = true
//            }
//            if self.saveCount >= 120 {
//                self.saveCount = -1
//                self.saveFlag = false
//                self.initBoxes()
//            }
//            let modelCIImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let cgImage = CIContext().createCGImage(modelCIImage, from: modelCIImage.extent)
//            let savedUIImage = UIImage(cgImage: cgImage!)
//            UIImageWriteToSavedPhotosAlbum(savedUIImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
//
//        }
            print("检测结果：[\(cardLabelDic[cardResult[0].cardIndex[0]] ?? "none"),Confidence: \(cardResult[0].confidence),ConfidencePercent: \(cardResult[0].confidencePercent),\(cardLabelDic[cardResult[1].cardIndex[0]] ?? "none"), Confidence: \(cardResult[1].confidence), ConfidencePercent: \(cardResult[1].confidencePercent)]")
    }
    
    
    // MARK: handle result list
    func handleDetecResultList(){
        
        
        var sortedKeys = self.detectResultList.keys.sorted()
        let blurThreshold : Float = 0.8
        
        if sortedKeys.count < 10{
            return
        }
        
        var deleteKeys:[Int] = []
        //去除重复帧
        for keyIndex in 2..<sortedKeys.count - 3{
            let detectResultListIndex = sortedKeys[keyIndex]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            for numIndex in 0..<self.detectResultList[detectResultListIndex]!.count{
                let nowLaplacian = self.detectResultList[detectResultListIndex]![numIndex].laplacianVariance
                let nextLaplacian = self.detectResultList[nextDetectResultListIndex]![numIndex].laplacianVariance
                
                if abs(nowLaplacian - nextLaplacian) <= 0.000000001{
                    deleteKeys.append(detectResultListIndex)
                }
            }
        }
        
        sortedKeys = sortedKeys.filter { !deleteKeys.contains($0) }

        
        //求出所有链路，链上数字confidence=100
        for keyIndex in 2..<sortedKeys.count - 3{
            let detectResultListIndex = sortedKeys[keyIndex]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            for numIndex in 0..<self.detectResultList[detectResultListIndex]!.count{
                let nowNum = self.detectResultList[detectResultListIndex]![numIndex].cardIndex[0]
                if nowNum != -1
                    && self.detectResultList[nextDetectResultListIndex]![numIndex].cardIndex[0] == nowNum{
                    //if self.confidenceDic[nowNum] != 100 || self.detectResultList[detectResultListIndex][numIndex].nodeType != 0{
                    self.detectResultList[detectResultListIndex]![numIndex].nodeType += 1
                    self.detectResultList[nextDetectResultListIndex]![numIndex].nodeType += 2
                    //}
                    self.confidenceDic[nowNum] = 100
                }
            }
        }
        
        //整理同一个数字的多条链路
        //整理两次
        for _ in 0..<2{
            for key in self.confidenceDic.keys{
                
                var deleteFlag = false
                if self.confidenceDic[key] == 100{
                    for numIndex in 0..<self.detectResultList[0]!.count{
                        
                        var end = -1
                        var head = -1
                        
                        for keyIndex in 2..<sortedKeys.count - 3{
                            let detectResultListIndex = sortedKeys[keyIndex]
                            let nowNum = self.detectResultList[detectResultListIndex]![numIndex].cardIndex[0]
                            if nowNum == key && self.detectResultList[detectResultListIndex]![numIndex].nodeType == 2{
                                end = detectResultListIndex
                            }
                            else if nowNum == key
                                        && self.detectResultList[detectResultListIndex]![numIndex].nodeType == 1
                                        && end != -1{
                                head = detectResultListIndex
                                
                                var isSameNum = head - end <= 5
                                //                            var middleNum = self.detectResultList[end+1][numIndex].cardIndex[0]
                                //                            for updateIndex in end+1...head-1{
                                //                                if self.detectResultList[updateIndex][numIndex].cardIndex[0] != middleNum{
                                //                                    isSameNum = false
                                //                                    break;
                                //                                }
                                //                            }
                                
                                if isSameNum{
                                    for updateIndex in end...head{
                                        self.detectResultList[updateIndex]![numIndex].cardIndex[0] = nowNum
                                        self.detectResultList[updateIndex]![numIndex].nodeType = 3
                                    }
                                    print("合并链 " + cardLabelDic[nowNum]!)
                                }
                                else{
                                    deleteFlag = true
                                    print("删除链 " + cardLabelDic[nowNum]!)
                                }
                            }
                            
                            if nowNum == key && deleteFlag{
                                self.detectResultList[detectResultListIndex]![numIndex].nodeType = 0
                            }
                        }
                    }
                }
            }
        }
        
        //找到所有不在链上但在单独节点的数字
        for key in self.confidenceDic.keys{
            if self.confidenceDic[key] == 0{
                var nodeIndex : [Int] = []
                for keyIndex in 2..<sortedKeys.count - 3{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    
                    for numIndex in 0..<self.detectResultList[detectResultListIndex]!.count{
                        let nowNum = self.detectResultList[detectResultListIndex]![numIndex].cardIndex[0]
                        let confidence = self.detectResultList[detectResultListIndex]![numIndex].confidence
                        if nowNum == key && confidence > self.confidenceDic[nowNum]! {
                            self.confidenceDic[nowNum] = confidence
                            nodeIndex = [detectResultListIndex, numIndex]
                        }
                    }
                }
                if nodeIndex.count > 0{
                    self.detectResultList[nodeIndex[0]]![nodeIndex[1]].nodeType = 4
                }
            }
        }
        
        //剩下的节点都是融合牌，可能是已有的牌之间融合，也有可能是已有的牌和未出现的牌融合
        for keyIndex in 2..<sortedKeys.count - 3{
            let detectResultListIndex = sortedKeys[keyIndex]
            let lastDetectResultListIndex = sortedKeys[keyIndex-1]
            let lastlastDetectResultListIndex = sortedKeys[keyIndex-2]
            for numIndex in 0..<self.detectResultList[detectResultListIndex]!.count{
                let detectResultNode = self.detectResultList[detectResultListIndex]![numIndex]
                let lastDetectResultNode = self.detectResultList[lastDetectResultListIndex]![numIndex]
                let lastlastDetectResultNode = self.detectResultList[lastlastDetectResultListIndex]![numIndex]
                
                if detectResultNode.nodeType == 0 
                    && detectResultNode.cardIndex[0] != -1
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
            }
        }
    
        
        for keyIndex in 2..<sortedKeys.count - 3{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<self.detectResultList[detectResultListIndex]!.count{
                let detectResultNode = self.detectResultList[detectResultListIndex]![numIndex]
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
        
        
        var lostNumCnt = 0
        for key in self.confidenceDic.keys{
            if self.confidenceDic[key] == 0{
                lostNumCnt += 1
            }
        }
        print("lostNumCnt \(lostNumCnt)")
        
        
        
        //插入牌堆
        for keyIndex in 2..<sortedKeys.count - 3{
            let detectResultListIndex = sortedKeys[keyIndex]
            let lastDetectResultListIndex = sortedKeys[keyIndex-1]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            let nextnextDetectResultListIndex = sortedKeys[keyIndex+2]
            if self.detectResultList[detectResultListIndex]!.count == 1{
                var nowNum = self.detectResultList[detectResultListIndex]![0].cardIndex[0]
                var nodeType = self.detectResultList[detectResultListIndex]![0].nodeType
                print("index ",detectResultListIndex," 牌 count = 1", cardLabelDic[nowNum], " ", nodeType)

                if nodeType == 2 || nodeType == 4{
                    self.cardArray.insert(nowNum, at: 0)
                }
            }
            else if self.detectResultList[detectResultListIndex]!.count == 2{
                
                let detectResultNode0 = self.detectResultList[detectResultListIndex]![0]
                let detectResultNode1 = self.detectResultList[detectResultListIndex]![1]
                
                let lastDetectResultNode0 = self.detectResultList[lastDetectResultListIndex]![0]
                let lastDetectResultNode1 = self.detectResultList[lastDetectResultListIndex]![1]
                
                let nextDetectResultNode0 = self.detectResultList[nextDetectResultListIndex]![0]
                let nextDetectResultNode1 = self.detectResultList[nextDetectResultListIndex]![1]
                
                let nextnextDetectResultNode0 = self.detectResultList[nextnextDetectResultListIndex]![0]
                let nextnextDetectResultNode1 = self.detectResultList[nextnextDetectResultListIndex]![1]
                    
                let nowNum0 = self.detectResultList[detectResultListIndex]![0].cardIndex[0]
                let nodeType0 = self.detectResultList[detectResultListIndex]![0].nodeType
                let nowNum1 = self.detectResultList[detectResultListIndex]![1].cardIndex[0]
                let nodeType1 = self.detectResultList[detectResultListIndex]![1].nodeType
                
                print("index ",detectResultListIndex, cardLabelDic[nowNum0] ?? "none",  detectResultNode0.laplacianVariance,detectResultNode0.confidence, detectResultNode0.confidencePercent,cardLabelDic[nowNum1] ?? "none",  detectResultNode1.laplacianVariance,detectResultNode1.confidence, detectResultNode1.confidencePercent)
                
                if (nodeType0 == 2 || nodeType0 == 4) && (nodeType1 == 2 || nodeType1 == 4){
                    
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
                    
                    
                    if leftLaplacianPercent < blurThreshold && rightLaplacianPercent >= blurThreshold{
                        print("左边糊了")
                        self.cardArray.insert(nowNum0, at: 0)
                        self.cardArray.insert(nowNum1, at: 0)
                    }
                    else if rightLaplacianPercent < blurThreshold && leftLaplacianPercent >= blurThreshold{
                        print("右边糊了")
                        self.cardArray.insert(nowNum1, at: 0)
                        self.cardArray.insert(nowNum0, at: 0)
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
                            self.cardArray.insert(nowNum1, at: 0)
                            self.cardArray.insert(nowNum0, at: 0)
                        }
                        else if rightNextLaplacianPercent < blurThreshold && leftNextLaplacianPercent >= blurThreshold{
                            print("下一张右边糊了")
                            self.cardArray.insert(nowNum0, at: 0)
                            self.cardArray.insert(nowNum1, at: 0)
                        }
                        //上一张和下一张两边都不模糊 直接比较上一张两边模糊程度
                        else if leftLaplacianPercent < blurThreshold && rightLaplacianPercent < blurThreshold{
                            if leftLaplacianPercent < rightLaplacianPercent{
                                print("左边更糊")
                                self.cardArray.insert(nowNum0, at: 0)
                                self.cardArray.insert(nowNum1, at: 0)
                            }
                            else{
                                print("右边更糊")
                                self.cardArray.insert(nowNum1, at: 0)
                                self.cardArray.insert(nowNum0, at: 0)
                            }
                        }
                        else{
                            if leftNextLaplacianPercent < rightNextLaplacianPercent{
                                print("下一张左边更糊")
                                self.cardArray.insert(nowNum1, at: 0)
                                self.cardArray.insert(nowNum0, at: 0)
                            }
                            else{
                                print("下一张右边更糊")
                                self.cardArray.insert(nowNum0, at: 0)
                                self.cardArray.insert(nowNum1, at: 0)
                            }
                        }
                        
                    }
                }

                //单个插入
                else{
                    if nodeType0 == 4 || nodeType0 == 2{
                        
                        var leftLaplacianPercent : Float = 1
                        
                        if nodeType0 == 2{
                            leftLaplacianPercent = detectResultNode0.laplacianVariance / lastDetectResultNode0.laplacianVariance
                        }
                        else if nodeType0 == 4 && self.laplacianDic[0][nowNum0] != 0{
                            leftLaplacianPercent = detectResultNode0.laplacianVariance / self.laplacianDic[0][nowNum0]!
                        }
                        
                        if leftLaplacianPercent > blurThreshold
                            && nextDetectResultNode0.nodeType == 0
                            && nextDetectResultNode1.nodeType == 2{
                            
                            var nextLeftLaplacianPercent = nextDetectResultNode0.laplacianVariance / detectResultNode0.laplacianVariance
                            var nextRightLaplacianPercent = nextDetectResultNode1.laplacianVariance / detectResultNode1.laplacianVariance
                            
                            if nextLeftLaplacianPercent < nextRightLaplacianPercent{
                                self.cardArray.insert(nowNum0, at: 0)
                            }
                            else{
                                self.cardArray.insert(nowNum1, at: 0)
                                self.cardArray.insert(nowNum0, at: 0)
                                nextDetectResultNode1.nodeType = 0
                            }
                        }
                        else{
                            self.cardArray.insert(nowNum0, at: 0)
                        }
                    }
                    if nodeType1 == 4 || nodeType1 == 2{
                        var rightLaplacianPercent : Float = 1
                        
                        if nodeType1 == 2{
                            rightLaplacianPercent = detectResultNode1.laplacianVariance / lastDetectResultNode1.laplacianVariance
                        }
                        else if nodeType1 == 4 && self.laplacianDic[1][nowNum1] != 0{
                            rightLaplacianPercent = detectResultNode1.laplacianVariance / self.laplacianDic[1][nowNum1]!
                        }
                        
                        if rightLaplacianPercent > blurThreshold
                            && nextDetectResultNode1.nodeType == 0
                            && nextDetectResultNode0.nodeType == 2{
                            
                            var nextLeftLaplacianPercent = nextDetectResultNode0.laplacianVariance / detectResultNode0.laplacianVariance
                            var nextRightLaplacianPercent = nextDetectResultNode1.laplacianVariance / detectResultNode1.laplacianVariance
                            
                            if nextLeftLaplacianPercent < nextRightLaplacianPercent{
                                self.cardArray.insert(nowNum0, at: 0)
                                self.cardArray.insert(nowNum1, at: 0)
                                nextDetectResultNode0.nodeType = 0
                            }
                            else{
                                self.cardArray.insert(nowNum1, at: 0)
                            }
                        }
                        else{
                            self.cardArray.insert(nowNum1, at: 0)
                        }
                    }
                }
            }
        }
        
        //去除相同的牌
        var uniqueArray: [Int] = []
        for card in self.cardArray {
            if !uniqueArray.contains(card) {
                uniqueArray.append(card)
            }
        }
        self.cardArray = uniqueArray
    }
    
    func cutCardArray(cardResult : [DetectionResult], taskIndex : Int){
        var cutCardIndex = -1
        if cardResult[0].cardIndex[0] != -1{
            cutCardIndex = cardResult[0].cardIndex[0]
        }
        else{
            cutCardIndex = cardResult[1].cardIndex[0]
        }
        
        if let index = cardArray.firstIndex(of: cutCardIndex){
            if index < cardArray.count - 1{
                let elementsToMove = cardArray[(index+1)...]
                cardArray.removeSubrange((index+1)...)
                cardArray.insert(contentsOf: elementsToMove, at: 0)
            }
        }
    }
    
    func handleShuffleResult(){
        for cardIndexList in self.tempCardArray{
            self.cardArray.append(cardIndexList[0])
        }
    }
    
    
//    // MARK: compute targetArea
//    func computeTargetArea(){
//        
//        if self.isHorizon
//        {
//            let minX = self.originSize[0] * (self.lastBoxes[0][0] - self.lastBoxes[0][2] / 2)
//            let maxX = self.originSize[0] * (self.lastBoxes[1][0] + self.lastBoxes[1][2] / 2)
//            let minY = self.originSize[1] * min(self.lastBoxes[0][1] - self.lastBoxes[0][3] / 2, self.lastBoxes[1][1] - self.lastBoxes[1][3] / 2)
//            let maxY = self.originSize[1] * max(self.lastBoxes[0][1] + self.lastBoxes[0][3] / 2, self.lastBoxes[1][1] + self.lastBoxes[1][3] / 2)
//            
//            if minX + Float(self.imageSize[0]) >= self.originSize[0]{
//                self.targetArea[0] = self.originSize[0] - Float(self.imageSize[0] / 2) - 1
//                self.targetArea[2] = Float(self.imageSize[0])
//            }
//            else if maxX - Float(self.imageSize[0]) <= 0{
//                self.targetArea[0] = Float(self.imageSize[0] / 2) + 1
//                self.targetArea[2] = Float(self.imageSize[0])
//            }
//            else{
//                self.targetArea[0] = (maxX + minX) / 2
//                self.targetArea[2] = max(maxX - minX + 100, Float(self.imageSize[0]))
//            }
//            
//            self.targetArea[3] = min(self.originSize[1] - 2, self.targetArea[2] / Float(self.imageSize[0]) * Float(self.imageSize[1]))
//            
//            if self.targetArea[3] == self.originSize[1] - 2{
//                self.targetArea[1] = self.originSize[1] / 2
//            }
//            else if minY + self.targetArea[3] >= self.originSize[1]{
//                self.targetArea[1] = self.originSize[1] - self.targetArea[3] / 2 - 1
//            }
//            else if maxY - self.targetArea[3] <= 0{
//                self.targetArea[1] = self.targetArea[3] / 2 + 1
//            }
//            else{
//                self.targetArea[1] = (maxY + minY) / 2
//            }
//        }
//        else{
//            let minY = self.originSize[1] * (self.lastBoxes[0][1] - self.lastBoxes[0][3] / 2)
//            let maxY = self.originSize[1] * (self.lastBoxes[1][1] + self.lastBoxes[1][3] / 2)
//            let minX = self.originSize[0] * min(self.lastBoxes[0][0] - self.lastBoxes[0][2] / 2, self.lastBoxes[1][0] - self.lastBoxes[1][2] / 2)
//            let maxX = self.originSize[0] * max(self.lastBoxes[0][0] + self.lastBoxes[0][2] / 2, self.lastBoxes[1][0] + self.lastBoxes[1][2] / 2)
//            
//            if minY + Float(self.imageSize[0]) >= self.originSize[1]{
//                self.targetArea[1] = self.originSize[1] - Float(self.imageSize[0] / 2) - 1
//                self.targetArea[3] = Float(self.imageSize[0])
//            }
//            else if maxY - Float(self.imageSize[0]) <= 0{
//                self.targetArea[1] = Float(self.imageSize[0] / 2) + 1
//                self.targetArea[3] = Float(self.imageSize[0])
//            }
//            else{
//                self.targetArea[1] = (maxY + minY) / 2
//                self.targetArea[3] = max(maxY - minY + 100, Float(self.imageSize[0]))
//            }
//            
//            self.targetArea[2] = min(self.originSize[0] - 2, self.targetArea[3] / Float(self.imageSize[0]) * Float(self.imageSize[1]))
//            
//            if self.targetArea[2] == self.originSize[0] - 2{
//                self.targetArea[0] = self.originSize[0] / 2
//            }
//            else if minX + self.targetArea[2] >= self.originSize[0]{
//                self.targetArea[0] = self.originSize[0] - self.targetArea[2] / 2 - 1
//            }
//            else if maxX - self.targetArea[2] <= 0{
//                self.targetArea[0] = self.targetArea[2] / 2 + 1
//            }
//            else{
//                self.targetArea[0] = (maxX + minX) / 2
//            }
//        }
//    }
    
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
            var targetX = self.targetArea[0]
            var targetY = self.targetArea[1]
            var targetW = self.targetArea[2]
            var targetH = self.targetArea[3]
            var x0 = (coordinates[0][0] * targetW + targetX) / originSize[0]
            var y0 = (coordinates[0][1] * targetH + targetY) / originSize[1]
            var w0 = (coordinates[0][2] * targetW) / originSize[0]
            var h0 = (coordinates[0][3] * targetH) / originSize[1]
            var x1 = (coordinates[1][0] * targetW + targetX) / originSize[0]
            var y1 = (coordinates[1][1] * targetH + targetY) / originSize[1]
            var w1 = (coordinates[1][2] * targetW) / originSize[0]
            var h1 = (coordinates[1][3] * targetH) / originSize[1]
            computeTargetArea(stateResult: [[x0,y0,w0,h0],[x1,y1,w1,h1]])
        }
        else{
            var targetX = self.targetArea[0]
            var targetY = self.targetArea[1]
            var targetW = self.targetArea[2]
            var targetH = self.targetArea[3]
            var x0 = ((1 - coordinates[0][1]) * targetW + targetX) / originSize[0]
            var y0 = (coordinates[0][0] * targetH + targetY) / originSize[1]
            var w0 = (coordinates[0][3] * targetW) / originSize[0]
            var h0 = (coordinates[0][2] * targetH) / originSize[1]
            var x1 = ((1 - coordinates[1][1]) * targetW + targetX) / originSize[0]
            var y1 = (coordinates[1][0] * targetH + targetY) / originSize[1]
            var w1 = (coordinates[1][3] * targetW) / originSize[0]
            var h1 = (coordinates[1][2] * targetH) / originSize[1]
            computeTargetArea(stateResult: [[x0,y0,w0,h0],[x1,y1,w1,h1]])
        }
    }

    // MARK: get card
    //返回检测到的目标类别，n当前设定为最多两个，后续可根据置信度进行排序输出或全部输出
    func getCard(from cardArray: MLMultiArray, from boxArray : MLMultiArray, from pixelBuffer : CVPixelBuffer) -> [DetectionResult] {
        let cnt : Int = Int(cardArray.shape[0])
        let n : Int = Int(cardArray.shape[1])
        var result : [DetectionResult] = []
        
        let newCIImage = CIImage(cvImageBuffer: pixelBuffer)
        let cgImage = CIContext().createCGImage(newCIImage, from: newCIImage.extent)!
        
        /// The 8-bit-per-channel, 4-channel source pixel buffer.
        let sourceBuffer8 = try! vImage.PixelBuffer<vImage.Interleaved8x4>(
            cgImage: cgImage,
            cgImageFormat: &BlurDetector_8.sourceFormat8)
        
        
        /// The 8-bit planar destination pixel buffer.
        var destinationBuffer8 = vImage.PixelBuffer<vImage.Planar8>(width: sourceBuffer8.width,
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
            for j in 0..<n {
                let index = i * n + j
                let value = cardArray[index].floatValue
                confidenceSum += value
            }
            for j in 0..<n {
                let index = i * n + j
                let value = cardArray[index].floatValue
                if value > 0 && self.allCardIndex.contains(j){
                    
                    if (value/confidenceSum>=0) {
                        cardIndex.append(j)
                    }
                    
                    if value > maxVal {
                        maxVal = value
                    }
                }
            }
            // 对 cardIndex 进行排序
            cardIndex.sort{cardArray[$0 + i*n].floatValue > cardArray[$1 + i*n].floatValue}
            
            let centerX = boxArray[i*4].floatValue
            let centerY = boxArray[i*4+1].floatValue
            let widthX = boxArray[i*4+2].floatValue
            let heightY = boxArray[i*4+3].floatValue
            
            let coordinate = [centerX, centerY, widthX, heightY]
            
            if cardIndex.count > 0{
                if let index = result.firstIndex(where: { ($0.targetDistance(target: coordinate)) < 0.01 }) {
                    //print("重叠框", cardIndex[0])
                    if maxVal > result[index].confidence {
                        result[index].cardIndex = cardIndex + result[index].cardIndex
                        result[index].confidence = maxVal
                    }
                    else{
                        result[index].cardIndex = result[index].cardIndex + cardIndex
                    }
                }
                else{
                    result.append(DetectionResult(cardIndex: cardIndex, confidence: maxVal, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: ComputeROILaplacianVariance(box: coordinate, destinationBuffer8: destinationBuffer8)))
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
            result.sort{$0.confidence > $1.confidence}
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
            if state == "shuffle" && shuffleMode != 0{
                result.insert(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: ComputeROILaplacianVariance(box: lastBoxes[0], destinationBuffer8: destinationBuffer8)), at: 1)
            }
            else if isHorizon{
                if result[0].coordinate[0] > self.centerPos[0]{
                    result.insert(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: ComputeROILaplacianVariance(box: lastBoxes[0], destinationBuffer8: destinationBuffer8)), at: 0)
                }
                else{
                    result.insert(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: ComputeROILaplacianVariance(box: lastBoxes[1], destinationBuffer8: destinationBuffer8)), at: 1)
                }
            }
            else{
                if result[0].coordinate[1] > self.centerPos[1]{
                    result.insert(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: ComputeROILaplacianVariance(box: lastBoxes[0], destinationBuffer8: destinationBuffer8)), at: 0)
                }
                else{
                    result.insert(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: ComputeROILaplacianVariance(box: lastBoxes[1], destinationBuffer8: destinationBuffer8)), at: 1)
                }
            }
        }
        else if result.count == 0{
            result.append(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: ComputeROILaplacianVariance(box: lastBoxes[0], destinationBuffer8: destinationBuffer8)))
            result.append(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 1, coordinate: lastBoxes[1], laplacianVariance: ComputeROILaplacianVariance(box: lastBoxes[1], destinationBuffer8: destinationBuffer8)))
        }
        
        self.centerPos = [(result[0].coordinate[0] + result[1].coordinate[0])/2, (result[0].coordinate[1] + result[1].coordinate[1])/2]
        self.lastBoxes = [result[0].coordinate,result[1].coordinate]
        
        return result
    }
    
    //MARK: comupute winner
    func computeWinnerPlayer() {
        print("计算信息")
        
        print("测试游戏：\(generalRuleSetting.allGameType[ruleIndex]), 游戏人数 \(playerNum), args：\(args), 花色顺序：\(suitRules), 发牌模式: \(dealType), 自定义发牌模式: \(diyDealType), 自定义发牌类型和发牌数量：\(diyDealStatus), \(diyDealNum), 打色模式：\(calModeArgs[0]), 打色目标，\(calModeArgs[1]), 目标位置：\(calModeArgs[2]), 打色点数设置: \(cutNumSetting), 打色范围：\(cutNumRangeSetting[0])- \(cutNumRangeSetting[1]), 连报轮数：\(consecutiveReport)")
        
        if cardArray.count == self.allCardIndex.count{
            speakText(input: 0)
        }
        else{
            speakText(input: 1)
        }
        
        if cardArray.count >= minCardNum{
            winnerPlayer = GameManager.selectGame(gameIndex: ruleIndex, inputCards: cardArray, playerNum: playerNum, args: args, rankRules: rankRules, suitRules: suitRules, dealType: dealType, diyDealType: diyDealType, diyDealNum: diyDealNum,diyDealStatus: diyDealStatus, calModeArgs: calModeArgs, cutNumSetting: cutNumSetting, cutNumRangeSetting: cutNumRangeSetting, consecutiveReport: consecutiveReport, cutSetting: cutSetting, minCardNum: minCardNum)
            if calModeArgs[0] == 0{
                print("每轮游戏胜者 \(winnerPlayer)")
            } else if calModeArgs[0] == 1{
                print("每轮切第几张最大 \(winnerPlayer)")
            } else if calModeArgs[1] == 2{
                print("每轮切第几张最小 \(winnerPlayer)")
            }
            speakText(input: winnerPlayer)
        }
        else{
            //speakText(input: "检测错误")
        }
    }
    
    func speakText(input: Int){
        if input == 0{
            AudioServicesPlaySystemSound(SystemSoundID(1000))
        }
        else if input == 1{
            AudioServicesPlaySystemSound(SystemSoundID(1003))
        }
                
    }
    

    func speakText(input: [Int]) {
        if !self.isMute{
            speechSynthesizer.stopSpeaking(at: .immediate)
            if input.isEmpty {
                let speechUtterance = AVSpeechUtterance(string: "无")
                speechSynthesizer.speak(speechUtterance)
            } else {
                let speechStrings = input.map { String($0 + 1) }
                let joinedSpeech = speechStrings.joined(separator: "和")
                let speechUtterance = AVSpeechUtterance(string: joinedSpeech)
                speechSynthesizer.speak(speechUtterance)
            }
        }
    }

    
    func speakText(input: String){
        if !self.isMute{
            //speechSynthesizer.stopSpeaking(at: .immediate)
            let speechUtterance = AVSpeechUtterance(string: input)
            speechSynthesizer.speak(speechUtterance)
        }
    }
}


class DetectionResult {
    var cardIndex : [Int]
    var confidence : Float
    var confidencePercent : Float
    var coordinate : [Float]
    var nodeType : Int //0未知 1链头 2链尾 3链体 4单个节点
    var laplacianVariance : Float

    init(cardIndex: [Int], confidence: Float, confidencePercent: Float, coordinate: [Float], laplacianVariance: Float) {
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
