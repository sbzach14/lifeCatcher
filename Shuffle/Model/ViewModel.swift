/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's main view model.
*/

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

/// - Tag: ViewModel
class ViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var cameraImage : CGImage?
    @Published var isShowCard : Bool = false
    
    // cardArray, 装有所以poker的array
    @Published var cardArray :  [Int] = []
    @Published var winnerPlayer: [Int] = []

    let model = try! cardDetection_s_1014()
    


    
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
    public var calModeArgs : [Int] = [0, 0, 1]
    
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
    var isEmptyFrame : Bool = true
    var taskIndex : Int = 0
    var currentTask: Int = 0
    
    var tempCardArray : [[Int]] = []
    var detectResultList : [[DetectionResult]] = []
    var centerX : Float = 0.5
    
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
    private var frameCounter : Int = 0
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    private var confidenceDic : [Int:Float] = [:]
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
    var setFrameRate: Float64 = 120.0
    var isContrastAug: Bool = false
    var cameraFrameRate: Int = 0
    
    var testCVPixelBuffer : CVPixelBuffer?


    func initialize(shuffleMode : Int, calModeArgs : [Int], ruleIndex: Int, args : [Int], rankRules : [Int], suitRules : [Int], allCardIndex : [Int], minCardNum : Int) {
        
        self.shuffleMode = shuffleMode
        self.calModeArgs = calModeArgs
        
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
        
        self.initCardArray()
        
        // Load data from config.json
        if let configData = readConfigJSON() {
            self.isBlack = configData["isBlack"]!
            self.isMute = configData["isMute"]!
            self.isBackCamera = configData["isBackCamera"]!
            self.isContrastAug = configData["isContrastAug"]!
        } else {
            // If config.json is not found or invalid, set default values
            self.isBlack = false
            self.isMute = false
            self.isBackCamera = false
            self.isContrastAug = false
        }
        
        setupAVCapture()

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
        frameCounter = 0
        tempCardArray = []
        detectResultList = []
        centerX = 0.5
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
            //session.sessionPreset = .iFrame960x540
            session.addInput(captureDeviceInput!)
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            session.addOutput(output)
            
            
            // 设置帧率为120帧
            print("设定识别帧率: \(self.setFrameRate)")

            
            guard let format = self.captureDevice.formats.first(where: { format in
                let ranges = format.videoSupportedFrameRateRanges
                return ranges.contains { range in
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

                captureDevice.exposureMode = .continuousAutoExposure

                self.captureDevice.unlockForConfiguration()
            } catch {
                print("设置帧率时发生错误: \(error)")
            }
            
            session.commitConfiguration()
            
            // 获取当前帧率
            let videoFrameRate = format.videoSupportedFrameRateRanges.first!.maxFrameRate
            print("设定帧率: \(videoFrameRate)")
            changeCameraFrameRate(to: 240)
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
        
        let myIndex = self.taskIndex
        self.taskIndex += 1
        self.taskIndex %= 10000
        
        // 处理视频帧数据
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        backgroundQueue.async {
            var indexGap = 4
            if self.isBackCamera{
                indexGap = 8
            }
            if !self.isBlack && (self.cameraFrameRate < 60 || self.taskIndex % indexGap == 0){
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
                    
                    
//                    // 创建目标 vImage_Buffer
//                    var destinationBuffer = try! vImage_Buffer(width: 960,
//                                                               height: 544,
//                                                               bitsPerPixel: 32) // 32 bits for ARGB
//
//                    // 进行图像缩放
//                    vImageScale_ARGB8888(&vImageBuffer, &destinationBuffer, nil, vImage_Flags(0))
                    
                    
//                    // 进行直方图均衡
//                    vImageEqualization_ARGB8888(&destinationBuffer,
//                                                &destinationBuffer,
//                                                vImage_Flags(kvImageNoFlags))
                    
                    
                    // 进行高斯滤波
//                    let convolutionKernel: [Int16] = [1, 2, 1,
//                                                      2, 4, 2,
//                                                      1, 2, 1]
//                    vImageConvolve_ARGB8888(&destinationBuffer, &destinationBuffer, nil, 0, 0, convolutionKernel, 3, 3, 16, [0], vImage_Flags(kvImageEdgeExtend))
                    
                    
                    var outputCGImage : CGImage
                    if ciImage.extent.size.width > ciImage.extent.size.height{
                        // 进行顺时针旋转90度
                        var rotatedBuffer = try! vImage_Buffer(width: Int(vImageBuffer.height),
                                                               height: Int(vImageBuffer.width),
                                                               bitsPerPixel: 32) // 32 bits for ARGB
                        vImageRotate90_ARGB8888(&vImageBuffer, &rotatedBuffer, UInt8(kRotate90DegreesClockwise), [0], vImage_Flags(kvImageNoFlags))
                        
                        outputCGImage = try rotatedBuffer.createCGImage(format: cgImageFormat)
                        rotatedBuffer.free()
                    }
                    else{
                        outputCGImage = try vImageBuffer.createCGImage(format: cgImageFormat)
                    }
                    
                    DispatchQueue.main.async {
                        self.cameraImage = outputCGImage
                    }
                    
                    
                    vImageBuffer.free()
                    //destinationBuffer.free()
                    
                }
                
                catch{
                    print("Error: \(error)")
                }
                
            }
            
//            if !self.isBlack{
//                    var translatedImage = ciImage
//                    if ciImage.extent.size.width > ciImage.extent.size.height{
//                        let rotationTransform = CGAffineTransform(rotationAngle: -.pi / 2)  // 顺时针旋转90度
//                        let rotatedImage = ciImage.transformed(by: rotationTransform)
//
//                        let xOffset = ciImage.extent.size.height
//                        let translationTransform = CGAffineTransform(translationX: xOffset, y: CGFloat(0))
//                        translatedImage = rotatedImage.transformed(by: translationTransform)
//                    }
//                    let cgImage = self.context.createCGImage(translatedImage, from: translatedImage.extent)
//                    DispatchQueue.main.async {
//                        self.cameraImage = cgImage
//                    }
//            }
                
            if !self.isShowCard{
                
                self.detectionQueue.async {
                    let cvPixelBuffer = createCVPixelBuffer(ciImage: ciImage, targetSize: CGSize(width: 640, height: 480))!
                    self.processImageOrigin(cvPixelBuffer, taskIndex: myIndex)
//                        if self.testCVPixelBuffer == nil{
//                            self.testCVPixelBuffer = createCVPixelBuffer(ciImage: ciImage, targetSize: CGSize(width: 960, height: 544))!
//                        }
//                        self.processImageOrigin(self.testCVPixelBuffer!, taskIndex: myIndex)
                    
                    
                    
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
    
    private func processImageOrigin(_ pixelBuffer: CVPixelBuffer, taskIndex: Int){
        
        if state != "idle" && self.isContrastAug{
            frameCounter += 1
            
            if frameCounter == 600{
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: 60)
                }
                return
            }
            
            else if frameCounter > 600 && frameCounter < 800{
                return
            }
            
            else if frameCounter == 800{
                
                DispatchQueue.main.async{
                    self.state = "idle"
                    self.initCardArray()
                }
                
                return
            }
            
        }
        
        
        
        let result = try! model.prediction(image: pixelBuffer, iouThreshold: 0.45, confidenceThreshold: 0.25)
        let cardResult = getCard(from: result.confidence, from: result.coordinates)
        
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
                && stateCounter > 5
                && shuffleMode == 0{
                state = "shuffle"
                print("动作：开始洗牌 ", self.setFrameRate)
                speakText(input: "开始洗牌")
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                    self.initCardArray()
                }
            }
            else if (self.stateCard[0] == -1 || self.stateCard[1] == -1) && self.stateCard[0] != self.stateCard[1]
                && stateCounter > 5
                && shuffleMode != 0{
                state = "shuffle"
                print("动作：开始拨牌")
                speakText(input: "开始拨牌")
                
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                    self.initCardArray()
                }
                
            }
            else if (self.stateCard[0] != -1 && self.stateCard[0] == self.stateCard[1])
                        && self.cardArray.contains(self.stateCard[0])
                        && stateCounter > 5{
                state = "cut"
                print("动作：开始切牌")
                speakText(input: "开始切牌")
                DispatchQueue.main.async{
                    self.frameCounter = 0
                    self.changeCameraFrameRate(to: Int(self.setFrameRate))
                    self.cutCardArray(cardResult: cardResult, taskIndex: taskIndex)
                }
            }
        }
        else if state == "cut"{
            if self.stateCard[0] == -1 && self.stateCard[1] == -1 && stateCounter > 10{
                state = "idle"
                print("动作：切牌完成")
                speakText(input: "切牌完成")
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: 60)
                    self.computeWinnerPlayer()
                }
            }
        }
        else if state == "shuffle"{
            if self.stateCard[0] == -1 && self.stateCard[1] == -1 && stateCounter > 10{
                state = "idle"
                print("动作：洗牌完成 ", self.setFrameRate)
                speakText(input: "洗牌完成")
                DispatchQueue.main.async{
                    self.changeCameraFrameRate(to: 60)
//                    self.handleShuffleResult()
                    self.handleDetecResultList()
                    self.centerX = 0
                    
                    if self.shuffleMode == 2 && self.cardArray.count > 0{
                        self.cardArray.remove(at: 0)
                    }
                        
                    self.computeWinnerPlayer()
                }
            }
            else{
//                self.appendCardToCardArray(cardResult: cardResult, taskIndex: taskIndex)
                self.detectResultList.append(cardResult)
            }
        }
        
//        if self.state == "shuffle"{
//            let modelCIImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let cgImage = CIContext().createCGImage(modelCIImage, from: modelCIImage.extent)
//            let savedUIImage = UIImage(cgImage: cgImage!)
//            UIImageWriteToSavedPhotosAlbum(savedUIImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
//            print("检测结果：[\(cardLabelDic[cardResult[0].cardIndex[0]] ?? "none"),Confidence: \(cardResult[0].confidence),ConfidencePercent: \(cardResult[0].confidencePercent),\(cardLabelDic[cardResult[1].cardIndex[0]] ?? "none"), Confidence: \(cardResult[1].confidence), ConfidencePercent: \(cardResult[1].confidencePercent)]")
//        }
            print("检测结果：[\(cardLabelDic[cardResult[0].cardIndex[0]] ?? "none"),Confidence: \(cardResult[0].confidence),ConfidencePercent: \(cardResult[0].confidencePercent),\(cardLabelDic[cardResult[1].cardIndex[0]] ?? "none"), Confidence: \(cardResult[1].confidence), ConfidencePercent: \(cardResult[1].confidencePercent)]")
    }
    
    
    func handleDetecResultList(){
        
        //求出所有链路，链上数字confidence=100
        for detectResultListIndex in 0..<self.detectResultList.count - 1{
            for numIndex in 0..<self.detectResultList[detectResultListIndex].count{
                let nowNum = self.detectResultList[detectResultListIndex][numIndex].cardIndex[0]
                if nowNum != -1
                    && self.detectResultList[detectResultListIndex + 1][numIndex].cardIndex[0] == nowNum{
                    //if self.confidenceDic[nowNum] != 100 || self.detectResultList[detectResultListIndex][numIndex].nodeType != 0{
                        self.detectResultList[detectResultListIndex][numIndex].nodeType += 1
                        self.detectResultList[detectResultListIndex + 1][numIndex].nodeType += 2
                    //}
                    self.confidenceDic[nowNum] = 100
                }
            }
        }
        
        //整理同一个数字的多条链路
        for key in self.confidenceDic.keys{
            
            var deleteFlag = false
            if self.confidenceDic[key] == 100{
                for numIndex in 0..<self.detectResultList[0].count{
                    
                    var end = -1
                    var head = -1
                    
                    for detectResultListIndex in 0..<self.detectResultList.count - 1{
                        let nowNum = self.detectResultList[detectResultListIndex][numIndex].cardIndex[0]
                        if nowNum == key && self.detectResultList[detectResultListIndex][numIndex].nodeType == 2{
                            end = detectResultListIndex
                        }
                        else if nowNum == key
                                    && self.detectResultList[detectResultListIndex][numIndex].nodeType == 1
                                    && end != -1{
                            head = detectResultListIndex
                            
                            var isSameNum = head - end <= 2
//                            var middleNum = self.detectResultList[end+1][numIndex].cardIndex[0]
//                            for updateIndex in end+1...head-1{
//                                if self.detectResultList[updateIndex][numIndex].cardIndex[0] != middleNum{
//                                    isSameNum = false
//                                    break;
//                                }
//                            }
                            
                            if isSameNum{
                                for updateIndex in end...head{
                                    self.detectResultList[updateIndex][numIndex].cardIndex[0] = nowNum
                                    self.detectResultList[updateIndex][numIndex].nodeType = 3
                                }
                                print("合并链 " + cardLabelDic[nowNum]!)
                            }
                            else{
                                deleteFlag = true
                                print("删除链 " + cardLabelDic[nowNum]!)
                            }
                        }
                        
                        if nowNum == key && deleteFlag{
                            self.detectResultList[detectResultListIndex][numIndex].nodeType = 0
                        }
                    }
                }
            }
        }
        
        
        //找到所有不在链上但在单独节点的数字
        for key in self.confidenceDic.keys{
            if self.confidenceDic[key] == 0{
                var nodeIndex : [Int] = []
                for detectResultListIndex in 0..<self.detectResultList.count{
                    for numIndex in 0..<self.detectResultList[detectResultListIndex].count{
                        let nowNum = self.detectResultList[detectResultListIndex][numIndex].cardIndex[0]
                        let confidence = self.detectResultList[detectResultListIndex][numIndex].confidence
                        if nowNum == key && confidence > self.confidenceDic[nowNum]! {
                            self.confidenceDic[nowNum] = confidence
                            nodeIndex = [detectResultListIndex, numIndex]
                        }
                    }
                }
                if nodeIndex.count > 0{
                    self.detectResultList[nodeIndex[0]][nodeIndex[1]].nodeType = 4
                }
            }
        }
        
        //剩下的节点都是融合牌，可能是已有的牌之间融合，也有可能是已有的牌和未出现的牌融合
        //找到所有遗漏数字最有可能的位置,他们都只出现了单独模糊的一帧，即不是第一个选项
        var lostNumCnt = 0
        for key in self.confidenceDic.keys{
            if self.confidenceDic[key] == 0{
                lostNumCnt += 1
                for detectResultListIndex in 0..<self.detectResultList.count{
                    for numIndex in 0..<self.detectResultList[detectResultListIndex].count{
                        let node = self.detectResultList[detectResultListIndex][numIndex]
                        if node.nodeType == 0{
                            //判断上下
                        }
                    }
                }
            }
        }
        print("lostNumCnt \(lostNumCnt)")
        
        //todo 利用未知节点和变形
        //todo 使用上下
        
        //插入牌堆
        for detectResultListIndex in 0..<self.detectResultList.count - 1{
            if self.detectResultList[detectResultListIndex].count == 1{
                var nowNum = self.detectResultList[detectResultListIndex][0].cardIndex[0]
                var nodeType = self.detectResultList[detectResultListIndex][0].nodeType
                if nodeType == 2 || nodeType == 4{
                    self.cardArray.insert(nowNum, at: 0)
                }
            }
            else if self.detectResultList[detectResultListIndex].count == 2{
                    
                //通过下个节点判断同时落下情况
                let nowNum0 = self.detectResultList[detectResultListIndex][0].cardIndex[0]
                let nodeType0 = self.detectResultList[detectResultListIndex][0].nodeType
                let nowNum1 = self.detectResultList[detectResultListIndex][1].cardIndex[0]
                let nodeType1 = self.detectResultList[detectResultListIndex][1].nodeType
                
                let nextNodeType0 = self.detectResultList[detectResultListIndex + 1][0].nodeType
                let nextNodeType1 = self.detectResultList[detectResultListIndex + 1][1].nodeType
                
                
                //当前点决定当前点插入的置信度 4<2
                //下一个点决定当前点先插入的置信度 1<4<0 (不可能是23）
                //小的先插入
                print("iNdex ",detectResultListIndex," 牌 ", cardLabelDic[nowNum0], " ", nodeType0," ", cardLabelDic[nowNum1], " ", nodeType1)
                
                //同时插入
                if (nodeType0 == 2 || nodeType0 == 4) && (nodeType1 == 2 || nodeType1 == 4){
                    //取连续四帧

                    let firstNode1 = self.detectResultList[detectResultListIndex - 1][0]
                    let firstNode2 = self.detectResultList[detectResultListIndex - 1][1]
                    
                    let detectResultNode1 = self.detectResultList[detectResultListIndex][0]
                    let detectResultNode2 = self.detectResultList[detectResultListIndex][1]
                    let thirdNode1 = self.detectResultList[detectResultListIndex + 1][0]
                    let thirdNode2 = self.detectResultList[detectResultListIndex + 1][1]
                    let forthNode1 = self.detectResultList[detectResultListIndex + 2][0]
                    let forthNode2 = self.detectResultList[detectResultListIndex + 2][1]
                    
                    
                    
                    var isLeftclear:Bool = true
                    var isRightclear:Bool = true
                    var isNextLeftclear:Bool = true
                    var isNextRightclear:Bool = true
                    
                    if (detectResultNode1.confidence <= 0.8 && (firstNode1.confidence -  detectResultNode1.confidence >= 0.05)) || detectResultNode1.confidence <= 0.7 {
                        if detectResultNode1.nodeType == 2 || detectResultNode1.nodeType == 0{
                            print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                            print("左边糊了")
                            isLeftclear = false
                        }
                        
                    }
                    if (detectResultNode2.confidence <= 0.8 && (firstNode2.confidence - detectResultNode2.confidence >= 0.05)) || detectResultNode2.confidence <= 0.7 {
                        if detectResultNode2.nodeType == 2 || detectResultNode2.nodeType == 0{
                            print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                            print("右边糊了")
                            isRightclear = false

                        }
                    }
                    
                    if (thirdNode1.confidence <= 0.8 && (forthNode1.confidence - thirdNode1.confidence >= 0.05)) || thirdNode1.confidence <= 0.7{
                        if thirdNode1.nodeType == 1 || thirdNode1.nodeType == 0{
                            print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                            print("下一张左边糊了")
                            isNextLeftclear = false
                        }
                    }
                    
                    if (thirdNode2.confidence <= 0.8 && (forthNode2.confidence - thirdNode2.confidence >= 0.05)) || thirdNode2.confidence <= 0.7{
                        if thirdNode2.nodeType == 1 || thirdNode2.nodeType == 0{
                            print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                            print("下一张右边糊了")
                            isNextRightclear = false
                
                        }
                    }
                    
                    if isLeftclear == false && isRightclear == true{
                        self.cardArray.insert(nowNum0, at: 0)
                        self.cardArray.insert(nowNum1, at: 0)
                    } else if isLeftclear == true && isRightclear == false{
                        self.cardArray.insert(nowNum1, at: 0)
                        self.cardArray.insert(nowNum0, at: 0)
                    } else if isLeftclear == false && isRightclear == false{
                        if firstNode1.confidence -  detectResultNode1.confidence > firstNode2.confidence - detectResultNode2.confidence{
                            print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                            print("左边比右边更糊，左边先落下")
                            self.cardArray.insert(nowNum0, at: 0)
                            self.cardArray.insert(nowNum1, at: 0)
                        } else if firstNode1.confidence -  detectResultNode1.confidence < firstNode2.confidence - detectResultNode2.confidence{
                            print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                            print("右边的更糊，右边先落下")
                            self.cardArray.insert(nowNum1, at: 0)
                            self.cardArray.insert(nowNum0, at: 0)
                        }
                    // dou qing xi
                    }else if isLeftclear == true && isRightclear == true{
                        if isNextLeftclear == false && isNextRightclear == true{
                            self.cardArray.insert(nowNum1, at: 0)
                            self.cardArray.insert(nowNum0, at: 0)
                        } else if isNextLeftclear == true && isNextRightclear == false{
                            self.cardArray.insert(nowNum0, at: 0)
                            self.cardArray.insert(nowNum1, at: 0)
                        } else if isNextLeftclear == false && isNextRightclear == false{
                            if forthNode1.confidence - thirdNode1.confidence >= forthNode2.confidence - thirdNode2.confidence{
                                print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                                print("下一张的左边更糊，左边后落下")
                                self.cardArray.insert(nowNum1, at: 0)
                                self.cardArray.insert(nowNum0, at: 0)
                            }else if forthNode1.confidence - thirdNode1.confidence < forthNode2.confidence - thirdNode2.confidence{
                                print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                                print("下一张的右边更糊，右边后落下")
                                self.cardArray.insert(nowNum0, at: 0)
                                self.cardArray.insert(nowNum1, at: 0)
                            }
                        } else if Double.random(in: 0..<1) < 0.5{
                            print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                            print("没有牌糊了，随即落下")
                            self.cardArray.insert(nowNum0, at: 0)
                            self.cardArray.insert(nowNum1, at: 0)
                        } else{
                            print("同时落下：[\(cardLabelDic[detectResultNode1.cardIndex[0]] ?? "none"),Confidence: \(detectResultNode1.confidence),ConfidencePercent: \(detectResultNode1.confidencePercent),\(cardLabelDic[detectResultNode2.cardIndex[0]] ?? "none"), Confidence: \(detectResultNode2.confidence), ConfidencePercent: \(detectResultNode2.confidencePercent)], \(detectResultNode1.nodeType), \(detectResultNode2.nodeType)")
                            print("没有牌糊了，随即落下")

                            self.cardArray.insert(nowNum1, at: 0)
                            self.cardArray.insert(nowNum0, at: 0)
                        }
                    }
                    
//                    let nowRank0 = [4,2].firstIndex(of: nodeType0)!
//                    let nowRank1 = [4,2].firstIndex(of: nodeType1)!
//                    let nextRank0 = [1,4,0].firstIndex(of: nextNodeType0)!
//                    let nextRank1 = [1,4,0].firstIndex(of: nextNodeType1)!
//
//                    if nextRank0 < nextRank1{
//                        self.cardArray.insert(nowNum0, at: 0)
//                        self.cardArray.insert(nowNum1, at: 0)
//                    }
//                    else if nextRank0 > nextRank1{
//                        self.cardArray.insert(nowNum1, at: 0)
//                        self.cardArray.insert(nowNum0, at: 0)
//                    }
//                    else if nowRank0 < nowRank0{
//                        self.cardArray.insert(nowNum0, at: 0)
//                        self.cardArray.insert(nowNum1, at: 0)
//                    }
//                    else if nowRank0 > nowRank1{
//                        self.cardArray.insert(nowNum1, at: 0)
//                        self.cardArray.insert(nowNum0, at: 0)
//                    }
//                    else if Double.random(in: 0..<1) < 0.5{
//                        self.cardArray.insert(nowNum0, at: 0)
//                        self.cardArray.insert(nowNum1, at: 0)
//                    }
//                    else{
//                        self.cardArray.insert(nowNum1, at: 0)
//                        self.cardArray.insert(nowNum0, at: 0)
//                    }
                    
                    
                }
                //单个插入
                else{
                    if nodeType0 == 4 || nodeType0 == 2{
                        self.cardArray.insert(nowNum0, at: 0)
                    }
                    if nodeType1 == 4 || nodeType1 == 2{
                        self.cardArray.insert(nowNum1, at: 0)
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
    
    
    //每一次单图分类任务或者是上下detect任务完成，在主线程中调用此函数，每一次调用，主线程都会循环将已经分类好的任务和图片进行一次判断和处理，然后将结果加入到cardarray中
    func appendCardToCardArray(cardResult : [DetectionResult], taskIndex : Int){
        var nextCards : [[Int]] = []
        var lastCards : [[Int]] = self.lastCards
        
        
        
        for detectionResultIndex in 0..<cardResult.count{
            
            var detectionResult : DetectionResult = cardResult[detectionResultIndex]
            
            if detectionResult.cardIndex[0] == -1{
                nextCards.append([-1])
                continue
            }
            //如果连续两帧在同样位置有相同的牌，则固定该牌置信度
            else if (lastCards[detectionResultIndex][0] == detectionResult.cardIndex[0]){
                detectionResult.confidence = 100
            }
            
            //如果已在array中存在 (-1不会进入牌堆）
            if let existIndex = tempCardArray.firstIndex(where: {$0[0] == detectionResult.cardIndex[0]}){
                //如果当前置信度高或当前卡片在上一帧存在，替换删除array中的卡片，并将当前手牌作为nextCards
                if detectionResult.confidence > confidenceDic[detectionResult.cardIndex[0]]! {
                    
                    if lastCards.contains(where: {$0[0] == detectionResult.cardIndex[0]}){
                        confidenceDic[detectionResult.cardIndex[0]] = 100
                    }
                    
                    var isDelete : Bool = true
                    
                    
//                    for cardCandicate in tempCardArray[existIndex]{
//                        
//                        var sameCardNumberList : [Int] = []
//                        
//                        if cardCandicate<52{
//                            let cardNumber = cardCandicate%13
//                            for suit in 0...3{
//                                let cardIndex = suit * 13 + cardNumber
//                                if cardIndex != cardCandicate  && self.allCardIndex.contains(cardIndex){
//                                    sameCardNumberList.append(cardIndex)
//                                }
//                            }
//                        }
//                        
//                        for newCardIndex in sameCardNumberList{
//                            if !tempCardArray.contains(where: {$0[0] == newCardIndex}) && !cardResult.contains(where: {$0.cardIndex[0] == newCardIndex}) && !lastCards.contains(where: {$0[0] == newCardIndex}){
//                                tempCardArray[existIndex].insert(newCardIndex, at: 0)
//                                isDelete = false
//                                print("result 删除已有的\(cardLabelDic[detectionResult.cardIndex[0]])替换为\(cardLabelDic[newCardIndex])index\(taskIndex)")
//                                break
//                            }
//                        }
//                        
//                        if !isDelete{
//                            break
//                        }
//                    }
                    
                    
                    if isDelete{
                        tempCardArray.remove(at: existIndex)
                        print("result 删除已有的\(cardLabelDic[detectionResult.cardIndex[0]]) index\(taskIndex)")
                    }
                    
                    confidenceDic[detectionResult.cardIndex[0]] = detectionResult.confidence
                    nextCards.append(detectionResult.cardIndex)
                }
                //如果牌堆置信度高，替换或删除手中的卡片
                else{
                    
                    var isDelete : Bool = true
                    
//                    for cardCandicate in detectionResult.cardIndex{
//
//                        var sameCardNumberList : [Int] = []
//
//                        if cardCandicate<52{
//                            let cardNumber = cardCandicate%13
//                            for suit in 0...3{
//                                let cardIndex = suit * 13 + cardNumber
//                                if cardIndex != cardCandicate && self.allCardIndex.contains(cardIndex){
//                                    sameCardNumberList.append(cardIndex)
//                                }
//                            }
//                        }
//
//                        for newCardIndex in sameCardNumberList{
//                            if !tempCardArray.contains(where: {$0[0] == newCardIndex}) && !cardResult.contains(where: {$0.cardIndex[0] == newCardIndex}) && !lastCards.contains(where: {$0[0] == newCardIndex}){
//                                detectionResult.cardIndex.insert(newCardIndex, at: 0)
//                                detectionResult.confidence = 0
//                                isDelete = false
//                                print("result 删除现在的\(cardLabelDic[tempCardArray[existIndex][0]])替换为\(cardLabelDic[newCardIndex])index\(taskIndex)")
//                                break
//                            }
//                        }
//
//                        if !isDelete{
//                            break
//                        }
//                    }
                    
                    if isDelete{
                        nextCards.append([-1])
                        print("result 删除现在的\(cardLabelDic[tempCardArray[existIndex][0]]) index\(taskIndex)")
                    }
                    else{
                        nextCards.append(detectionResult.cardIndex)
                    }
                }
            }
            else{
                if detectionResult.confidence > confidenceDic[detectionResult.cardIndex[0]]!{
                    confidenceDic[detectionResult.cardIndex[0]] = detectionResult.confidence
                }
                nextCards.append(detectionResult.cardIndex)
            }
            
        }
        
        //避免在另一边预测出来的情况
        if nextCards[0][0] == lastCards[1][0] && nextCards[0][0] != -1{
            //比较当前置信度和最高置信度
            //如果当前是最高置信度，则修改lastcard
            if cardResult[0].confidence >= confidenceDic[nextCards[0][0]]! {
                lastCards[1] = [-1]
            }
            //否则修改nextcard
            else{
                nextCards[0] = [-1]
            }
        }
        if nextCards[1][0] == lastCards[0][0] && nextCards[1][0] != -1{
            //比较当前置信度和最高置信度
            //如果当前是最高置信度，则修改lastcard
            if cardResult[1].confidence >= confidenceDic[nextCards[1][0]]!{
                lastCards[0] = [-1]
            }
            //否则修改nextcard
            else{
                nextCards[1] = [-1]
            }
        }
            
        print("result 检测结果\(nextCards) index\(taskIndex)")
        
        var left : Bool = false
        var right : Bool = false
        
        //左边前后不同，且前一张有牌
        if lastCards[0][0] != nextCards[0][0] && lastCards[0][0] != -1{
            left = true
        }
        
        //右边前后不同，且前一张有牌
        if lastCards[1][0] != nextCards[1][0] && lastCards[1][0] != -1{
            right = true
        }
        
        //左右都需要进牌堆，即前一张都有牌
        if left && right{
            tempCardArray.insert(lastCards[0], at: 0)
            tempCardArray.insert(lastCards[1], at: 0)
            print("result 先后: 放入牌堆\(cardLabelDic[lastCards[0][0]]) 放入牌堆\(cardLabelDic[lastCards[1][0]]) index\(taskIndex)")
        }
        
        else if left{
            tempCardArray.insert(lastCards[0], at: 0)
            print("result 放入牌堆\(cardLabelDic[lastCards[0][0]]) index\(taskIndex)")
        }
        
        else if right{
            tempCardArray.insert(lastCards[1], at: 0)
            print("result 放入牌堆\(cardLabelDic[lastCards[1][0]]) index\(taskIndex)")
        }
        
        
        self.lastCards = nextCards
    }
    

    
    //返回检测到的目标类别，n当前设定为最多两个，后续可根据置信度进行排序输出或全部输出
    func getCard(from cardArray: MLMultiArray, from boxArray : MLMultiArray) -> [DetectionResult] {
        let cnt : Int = Int(cardArray.shape[0])
        let n : Int = Int(cardArray.shape[1])
        var result : [DetectionResult] = []
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
            
            let x_coordinate = boxArray[4 * i].floatValue
            
            if cardIndex.count > 0{
                if let index = result.firstIndex(where: { abs($0.x_coordinate - x_coordinate) < 0.1 }) {
                    if maxVal > result[index].confidence {
                        result[index].cardIndex = cardIndex + result[index].cardIndex
                        result[index].confidence = maxVal
                    }
                    else{
                        result[index].cardIndex = result[index].cardIndex + cardIndex
                    }
                }
                else{
                    result.append(DetectionResult(cardIndex: cardIndex, confidence: maxVal, confidencePercent: maxVal/confidenceSum, x_coordinate: x_coordinate))
                }
            }
            
        }
        
        
        
        if result.count > 2{
            result.sort{$0.confidence > $1.confidence}
            result.removeLast(result.count - 2)
        }
        
        
        if result.count == 2{
            if result[0].x_coordinate > result[1].x_coordinate{
                result.swapAt(0, 1) //x坐标小的在左边
            }
            self.centerX = (result[0].x_coordinate + result[1].x_coordinate)/2
        }
        else if result.count == 0{
            result.append(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, x_coordinate: 0))
            result.append(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 1, x_coordinate: 0))
        }
        else if result.count == 1{
            if result[0].x_coordinate > self.centerX{
                result.insert(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, x_coordinate: 0), at: 0)
            }
            else{
                result.insert(DetectionResult(cardIndex: [-1], confidence: 0, confidencePercent: 0, x_coordinate: 1), at: 1)
            }
        }
        return result
    }
    
    
    func computeWinnerPlayer() {
        
        if cardArray.count >= minCardNum{
            winnerPlayer = [GameManager.selectGame(gameIndex: ruleIndex, inputCards: cardArray, args: args, rankRules: rankRules, suitRules: suitRules, calModeArgs: calModeArgs, minCardNum: minCardNum)]
            
            speakText(input: winnerPlayer)
        }
        else{
            speakText(input: "检测错误")
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
    var x_coordinate : Float
    var nodeType : Int //0未知 1链头 2链尾 3链体 4单个节点

    init(cardIndex: [Int], confidence: Float, confidencePercent: Float, x_coordinate: Float) {
        self.cardIndex = cardIndex
        self.confidence = confidence
        self.confidencePercent = confidencePercent
        self.x_coordinate = x_coordinate
        self.nodeType = 0
    }
}
