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
import PythonKit
import Vision
import Foundation
import CoreML
import Photos

/// - Tag: ViewModel
class ViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var cameraImage : CGImage?
    @Published var isShowCard : Bool = false
    
    // cardArray, 装有所以poker的array
    @Published var cardArray :  [Int] = []
    @Published var winnerPlayer: [Int] = []

    let model = try! CardDetect()
    
    // 创建一个后台队列
    let videoProcessingQueue = DispatchQueue(label: "com.example.videoProcessing", qos: .userInitiated)
    // 创建一个后台队列
    let backgroundQueue = DispatchQueue(label: "actionQueue", attributes: .concurrent)
    let saveImageQueue = DispatchQueue(label: "saveImageQueue", qos: .userInteractive, attributes: .concurrent)
    let detectionQueue = DispatchQueue(label: "detectionQueue", attributes: .concurrent)
    let captureQueue = DispatchQueue(label: "com.example.captureQueue", qos: .background)
    
    let lock = NSLock()

    public var state : String = "idle" //
    public var ruleIndex : Int = 0
    public var args : [Int] = []
    public var rankRules : [Int] = []
    public var suitRules : [Int] = [3,2,1,0]
    public var allCardIndex : [Int] = Array(0...51)
    
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
    
    private var stateCounter : Int = 0
    private var stateCard : [Int] = [-1, -1]
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    private var confidenceDic : [Int:Float] = [:]
    let cardLabelDic : [Int:String] = [
        0: "As", 1: "2s", 2: "3s", 3: "4s", 4: "5s", 5: "6s", 6: "7s", 7: "8s", 8: "9s", 9: "10s",
        10: "Js", 11: "Qs", 12: "Ks", 13: "Ah", 14: "2h", 15: "3h", 16: "4h", 17: "5h", 18: "6h",
        19: "7h", 20: "8h", 21: "9h", 22: "10h", 23: "Jh", 24: "Qh", 25: "Kh", 26: "Ac", 27: "2c",
        28: "3c", 29: "4c", 30: "5c", 31: "6c", 32: "7c", 33: "8c", 34: "9c", 35: "10c", 36: "Jc",
        37: "Qc", 38: "Kc", 39: "Ad", 40: "2d", 41: "3d", 42: "4d", 43: "5d", 44: "6d", 45: "7d",
        46: "8d", 47: "9d", 48: "10d", 49: "Jd", 50: "Qd", 51: "Kd", 52: "none", 53: "black_J", 54: "red_j"
    ]
    
    var isBlack: Bool = false
    var isMute: Bool = false
    var isBackCamera: Bool = false

    override init() {
        super.init()
        
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
        } else {
            // If config.json is not found or invalid, set default values
            self.isBlack = false
            self.isMute = false
            self.isBackCamera = false
        }
    }

    func initialize(ruleIndex: Int, args : [Int], rankRules : [Int], suitRules : [Int], allCardIndex : [Int]) {
        self.ruleIndex = ruleIndex
        self.args = args
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.allCardIndex = allCardIndex
        self.initCardArray()
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
    
    
    func startCamera() {
        
        if self.isBackCamera{
            self.captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        else{
            self.captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
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
            guard let format = self.captureDevice.formats.first(where: { format in
                let ranges = format.videoSupportedFrameRateRanges
                return ranges.contains { range in
                    return range.maxFrameRate >= 120
                }
            }) else {
                print("不支持120帧的前置摄像头格式")
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
            
            session.commitConfiguration()
            session.startRunning()
            
            // 获取当前帧率
            let videoFrameRate = format.videoSupportedFrameRateRanges.first!.maxFrameRate
            print("设定帧率: \(videoFrameRate)")

            changeCameraFrameRate(to: 30)
        } catch {
            print("配置前置摄像头时发生错误: \(error)")
        }
    }
    
    func stopCamera() {
        session.stopRunning()
    }
    
    func changeCameraFrameRate(to frameRate: Float) {
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
        
        
        // 处理视频帧数据
        if let ciImage = imageFromSampleBuffer(sampleBuffer) {
            
            let rotationTransform = CGAffineTransform(rotationAngle: -.pi / 2)  // 顺时针旋转90度
            let rotatedImage = ciImage.transformed(by: rotationTransform)
            
            let xOffset = ciImage.extent.size.height
            let translationTransform = CGAffineTransform(translationX: xOffset, y: CGFloat(0))
            let translatedImage = rotatedImage.transformed(by: translationTransform)
            let cgImage = context.createCGImage(translatedImage, from: translatedImage.extent)
            self.cameraImage = cgImage
            
            
            let myIndex = self.taskIndex
            self.taskIndex += 1
            self.taskIndex %= 10000
            
            if !self.isShowCard{
                backgroundQueue.async {
                    self.processImageOrigin(ciImage, taskIndex: myIndex)
                }
            }
        }
        // 释放视频帧资源
        CMSampleBufferInvalidate(sampleBuffer)
    }
    
    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        return ciImage
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
    
    private func processImageOrigin(_ originCIImage: CIImage, taskIndex: Int){
        if let pixelBuffer = createCVPixelBuffer(ciImage: originCIImage, targetSize: CGSize(width: 960, height: 544)){
            
            let result = try! model.prediction(image: pixelBuffer, iouThreshold: 0.45, confidenceThreshold: 0.25)
            let cardResult = getCard(from: result.confidence, from: result.coordinates)
            
            
            if cardResult[0].cardIndex[0] == self.stateCard[0] && cardResult[1].cardIndex[0] == self.stateCard[1]{
                stateCounter = min(stateCounter + 1, 120)
            }
            else{
                stateCounter = 0
            }
            
            self.stateCard[0] = cardResult[0].cardIndex[0]
            self.stateCard[1] = cardResult[1].cardIndex[0]
            
            
            if state == "idle"{
                if self.stateCard[0] != -1 && self.stateCard[1] != -1 && self.stateCard[0] != self.stateCard[1] && stateCounter > 10{
                    state = "shuffle"
                    print("动作：开始洗牌")
                    speakText(input: "开始洗牌")
                    DispatchQueue.main.async{
                        self.changeCameraFrameRate(to: 120)
                        self.initCardArray()
                    }
                }
                else if (self.stateCard[0] != -1 || self.stateCard[1] != -1) && self.cardArray.count > 0 && stateCounter > 10{
                    state = "cut"
                    print("动作：开始切牌")
                    speakText(input: "开始切牌")
                    DispatchQueue.main.async{
                        self.changeCameraFrameRate(to: 120)
                        self.cutCardArray(cardResult: cardResult, taskIndex: taskIndex)
                    }
                }
            }
            else if state == "cut"{
                if self.stateCard[0] != -1 && self.stateCard[1] != -1 && self.stateCard[0] != self.stateCard[1] && stateCounter > 10{
                    state = "shuffle"
                    print("动作：开始洗牌")
                    speakText(input: "开始洗牌")
                    DispatchQueue.main.async{
                        self.changeCameraFrameRate(to: 120)
                        self.initCardArray()
                    }
                }
                else if self.stateCard[0] == -1 && self.stateCard[1] == -1 && stateCounter > 50{
                    state = "idle"
                    print("动作：切牌完成")
                    speakText(input: "切牌完成")
                    DispatchQueue.main.async{
                        self.changeCameraFrameRate(to: 30)
                        self.computeWinnerPlayer()
                    }
                }
            }
            else if state == "shuffle"{
                if self.stateCard[0] == -1 && self.stateCard[1] == -1 && stateCounter > 50{
                    state = "idle"
                    print("动作：洗牌完成")
                    speakText(input: "洗牌完成")
                    DispatchQueue.main.async{
                        self.changeCameraFrameRate(to: 30)
                        self.handleShuffleResult()
                        self.centerX = 0
                        self.computeWinnerPlayer()
                    }
                }
                else{
                    self.appendCardToCardArray(cardResult: cardResult, taskIndex: taskIndex, originCIImage: originCIImage)
                }
            }
        }
    }
    
    
    func handleDetecResultList(){
        //求出所有链路，链上数字confidence=100
        for detectResultListIndex in 0..<self.detectResultList.count - 1{
            for numIndex in 0..<self.detectResultList[detectResultListIndex].count{
                let nowNum = self.detectResultList[detectResultListIndex][numIndex].cardIndex[0]
                if self.detectResultList[detectResultListIndex + 1][numIndex].cardIndex[0] == nowNum{
                    self.confidenceDic[nowNum] = 100
                    self.detectResultList[detectResultListIndex][numIndex].nodeType += 1
                    self.detectResultList[detectResultListIndex + 1][numIndex].nodeType += 2
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
        
        //找到所有遗漏数字最有可能的位置,他们都只出现了单独模糊的一帧，
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
        
        for detectResultListIndex in 0..<self.detectResultList.count{
            for numIndex in 0..<self.detectResultList[detectResultListIndex].count{
                var nowNum = self.detectResultList[detectResultListIndex][numIndex].cardIndex[0]
                var nodeType = self.detectResultList[detectResultListIndex][numIndex].nodeType
                if nodeType == 2{
                    self.cardArray.append(nowNum)
                }
            }
        }
        
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
    func appendCardToCardArray(cardResult : [DetectionResult], taskIndex : Int, originCIImage: CIImage){
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
                    
                    
                    for cardCandicate in tempCardArray[existIndex]{
                        
                        var sameCardNumberList : [Int] = []
                        
                        if cardCandicate<52{
                            let cardNumber = cardCandicate%13
                            for suit in 0...3{
                                let cardIndex = suit * 13 + cardNumber
                                if cardIndex != cardCandicate  && self.allCardIndex.contains(cardIndex){
                                    sameCardNumberList.append(cardIndex)
                                }
                            }
                        }
                        
                        for newCardIndex in sameCardNumberList{
                            if !tempCardArray.contains(where: {$0[0] == newCardIndex}) && !cardResult.contains(where: {$0.cardIndex[0] == newCardIndex}) && !lastCards.contains(where: {$0[0] == newCardIndex}){
                                tempCardArray[existIndex].insert(newCardIndex, at: 0)
                                isDelete = false
                                print("result 删除已有的\(cardLabelDic[detectionResult.cardIndex[0]])替换为\(cardLabelDic[newCardIndex])index\(taskIndex)")
                                break
                            }
                        }
                        
                        if !isDelete{
                            break
                        }
                    }
                    
                    
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
                    
                    for cardCandicate in detectionResult.cardIndex{
                        
                        var sameCardNumberList : [Int] = []
                        
                        if cardCandicate<52{
                            let cardNumber = cardCandicate%13
                            for suit in 0...3{
                                let cardIndex = suit * 13 + cardNumber
                                if cardIndex != cardCandicate && self.allCardIndex.contains(cardIndex){
                                    sameCardNumberList.append(cardIndex)
                                }
                            }
                        }
                        
                        for newCardIndex in sameCardNumberList{
                            if !tempCardArray.contains(where: {$0[0] == newCardIndex}) && !cardResult.contains(where: {$0.cardIndex[0] == newCardIndex}) && !lastCards.contains(where: {$0[0] == newCardIndex}){
                                detectionResult.cardIndex.insert(newCardIndex, at: 0)
                                detectionResult.confidence = 0
                                isDelete = false
                                print("result 删除现在的\(cardLabelDic[tempCardArray[existIndex][0]])替换为\(cardLabelDic[newCardIndex])index\(taskIndex)")
                                break
                            }
                        }
                        
                        if !isDelete{
                            break
                        }
                    }
                    
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
        winnerPlayer = GameManager.selectGame(gameIndex: ruleIndex, inputCards: cardArray, args: args, rankRules: rankRules, suitRules: suitRules)
        
        speakText(input: winnerPlayer)
    }
    

    func speakText(input: [Int]) {
        if !self.isMute{
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
