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
    
    // cardArray, 装有所以poker的array
    @Published var cardArray :  [Int] = []
    @Published var winnerPlayer: [Int] = []
    let testModel = YOLOv3Tiny()
    let model = try! cardDetection()
    let cardClsModel = cardClassification()
    let actionClsModel = actionClassification()
    // 创建一个后台队列
    let videoProcessingQueue = DispatchQueue(label: "com.example.videoProcessing", qos: .userInitiated)
    // 创建一个后台队列
    let backgroundQueue = DispatchQueue(label: "actionQueue", attributes: .concurrent)
    let saveImageQueue = DispatchQueue(label: "saveImageQueue", qos: .userInteractive, attributes: .concurrent)
    let detectionQueue = DispatchQueue(label: "detectionQueue", attributes: .concurrent)
    let captureQueue = DispatchQueue(label: "com.example.captureQueue", qos: .background)
    
    let lock = NSLock()

    public var state : String = "idle" //0cut 1idle 2shuffle
    public var ruleIndex : Int = 0
    public var args : [Int] = []
    public var rankRules : [Int] = []
    public var suitRules : [Int] = [3,2,1,0]
    var lastCards : [Int] = []

    
    var session = AVCaptureSession()
    let context = CIContext()
    var taskImageArray : [String] = []
    
    var isSavedImage : Bool = true
    var isEmptyFrame : Bool = true
    var taskIndex : Int = 0
    var currentTask: Int = 0
    var todoResultDictionary: [Int : [Int]] = [:]
    var addedResultDictionary: [Int : [Int]] = [:]
    
    //显示帧率
    private var frameCount = 0
    private var timestamp: Double = 0
    private var frameRateLabel: UILabel! // 用于显示帧率的标签
    
    private var startShuffleCounter : Int = 0
    private var confidenceDic : [Int:Float] = [:]
    let cardLabelDic : [Int:String] = [
        0: "As", 1: "2s", 2: "3s", 3: "4s", 4: "5s", 5: "6s", 6: "7s", 7: "8s", 8: "9s", 9: "10s",
        10: "Js", 11: "Qs", 12: "Ks", 13: "Ah", 14: "2h", 15: "3h", 16: "4h", 17: "5h", 18: "6h",
        19: "7h", 20: "8h", 21: "9h", 22: "10h", 23: "Jh", 24: "Qh", 25: "Kh", 26: "Ac", 27: "2c",
        28: "3c", 29: "4c", 30: "5c", 31: "6c", 32: "7c", 33: "8c", 34: "9c", 35: "10c", 36: "Jc",
        37: "Qc", 38: "Kc", 39: "Ad", 40: "2d", 41: "3d", 42: "4d", 43: "5d", 44: "6d", 45: "7d",
        46: "8d", 47: "9d", 48: "10d", 49: "Jd", 50: "Qd", 51: "Kd", 52: "none", 53: "black_J", 54: "red_j"
    ]

    override init(){
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
        
        self.startCamera()
    }

    func initialize(ruleIndex: Int, args : [Int], rankRules : [Int], suitRules : [Int] ) {
        
        self.ruleIndex = ruleIndex
        self.args = args
        self.rankRules = rankRules
        self.suitRules = suitRules
        
        
    }
    
    
    
    
    func startCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("无法获取前置摄像头设备")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            session.beginConfiguration()
            session.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            session.addOutput(output)
            
            
            // 设置帧率为120帧
            guard let format = device.formats.first(where: { format in
                let ranges = format.videoSupportedFrameRateRanges
                return ranges.contains { range in
                    return range.maxFrameRate >= 120
                }
            }) else {
                print("不支持120帧的前置摄像头格式")
                return
            }
            do {
                try device.lockForConfiguration()
                device.activeFormat = format
                device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(format.videoSupportedFrameRateRanges.first!.maxFrameRate))
                device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(format.videoSupportedFrameRateRanges.first!.maxFrameRate))
                device.unlockForConfiguration()
            } catch {
                print("设置帧率时发生错误: \(error)")
            }
            
            session.commitConfiguration()
            session.startRunning()
            
            // 获取当前帧率
            let videoFrameRate = format.videoSupportedFrameRateRanges.first!.maxFrameRate
            print("设定帧率: \(videoFrameRate)")

            
        } catch {
            print("配置前置摄像头时发生错误: \(error)")
        }
    }
    
    func stopCamera() {
        session.stopRunning()
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
            
            if self.taskIndex < 500 {
                saveImageQueue.async {
                    self.saveImageOrigin(ciImage, taskIndex: myIndex)

                }
            }

            else if self.taskIndex == 500{
                backgroundQueue.async {
                    for i in 0..<self.taskImageArray.count{
                        if let readCIImage = self.readImageOrigin(index: i){
                            self.processImageOrigin(readCIImage, taskIndex: i)
                        }
                    }
                }
            }
            
            backgroundQueue.async {
                //self.StateClassifier(ciImage, taskIndex: myIndex)
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
    
    private func StateClassifier(_ originCIImage: CIImage, taskIndex: Int){
        if let pixelBuffer = createCVPixelBuffer(ciImage: originCIImage, targetSize: CGSize(width: 960, height: 540)){
            
            //预测单张图片的结果放在result中
            let result = try! self.actionClsModel.prediction(image: pixelBuffer)
            let actionResult = result.classLabel
            print("result \(actionResult) index \(taskIndex)")
            
            if state == "cut"{
                if actionResult == "idle"{
                    //切牌完成
                    print("动作：切牌完成")
                }
            }
            else if state == "idle"{
                if actionResult == "cut"{
                    //开始切牌
                    print("动作：开始切牌")
                }
                else if actionResult == "shuffle"{
                    //开始洗牌
                    print("动作：开始洗牌")
                }
            }
            else if state == "shuffle"{
                if actionResult == "idle"{
                    //洗牌完成
                    print("动作：洗牌完成")
                }
            }
            state = actionResult
        }
        
    }
    
    private func initCardArray(){
        for key in 0...54 {
            confidenceDic[key] = 0
        }
        
        cardArray = []
        lastCards = []
        winnerPlayer = []
        startShuffleCounter = 0
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
            
                self.appendCardToCardArray(cardResult: cardResult, taskIndex: taskIndex, originCIImage: originCIImage)
            }
    }
    
    
    //每一次单图分类任务或者是上下detect任务完成，在主线程中调用此函数，每一次调用，主线程都会循环将已经分类好的任务和图片进行一次判断和处理，然后将结果加入到cardarray中
    func appendCardToCardArray(cardResult : [DetectionResult], taskIndex : Int, originCIImage: CIImage)
    {
        var isCardCls : Bool = false
//        if self.addedResultDictionary.count == 0{
//            self.addedResultDictionary[taskIndex] = cardResult
//        } else {
//            self.todoResultDictionary[taskIndex] = cardResult
//        }
//        var todoKeyList = self.todoResultDictionary.keys.sorted()
//        var addedResultKeylist = self.addedResultDictionary.keys.sorted()
        //如果当前未完成的最近任务的上一个任务已经完成
        
//        while(todoKeyList.count != 0 && todoKeyList[0] - 1 == addedResultKeylist.last){
            //待办的第一个元素
        
        var nextCards : [Int] = []
        
        cardResult.forEach { detectionResult in
            //如果已在array中存在
            if cardArray.contains(where: {$0 == detectionResult.cardIndex}){
                //如果当前置信度高，删除array中的卡片，并作为nextCards
                if detectionResult.confidence > confidenceDic[detectionResult.cardIndex]! {
                    cardArray.removeAll {$0 == detectionResult.cardIndex}
                    confidenceDic[detectionResult.cardIndex] = detectionResult.confidence
                    nextCards.append(detectionResult.cardIndex)
                    print("result 删除已有的\(cardLabelDic[detectionResult.cardIndex]) index\(taskIndex)")
                }
                else{
                    print("result 删除现在的\(cardLabelDic[detectionResult.cardIndex]) index\(taskIndex)")
                }
            }
            else{
                if detectionResult.confidence > confidenceDic[detectionResult.cardIndex]!{
                    confidenceDic[detectionResult.cardIndex] = detectionResult.confidence
                }
                nextCards.append(detectionResult.cardIndex)
            }
        }
        
        let lastCards : [Int] = self.lastCards
        
        if startShuffleCounter < 50 && lastCards.count == 2 && nextCards.count == 2{
            if lastCards[0] == nextCards[0] && lastCards[1] == nextCards[1]{
                startShuffleCounter += 1
            }
            else{
                startShuffleCounter = 0
            }
        }
        else if startShuffleCounter < 50{
            startShuffleCounter = 0
        }
            
        else{
            print("result 检测结果\(nextCards) index\(taskIndex)")
            
            if lastCards.count == 1{
                if nextCards.count == 0{
                    self.cardArray.append(lastCards[0])
                    print("result 放入牌堆\(cardLabelDic[lastCards[0]])")
                }
                else if !nextCards.contains(lastCards[0]){
                    self.cardArray.append(lastCards[0])
                    print("result 放入牌堆\(cardLabelDic[lastCards[0]])")
                }
            }
            else if lastCards.count == 2{
                if nextCards.count == 0{
                    isCardCls = true
                }
                else if nextCards.count == 1{
                    if lastCards[0] == nextCards[0]{
                        self.cardArray.append(lastCards[1])
                        print("result 放入牌堆\(cardLabelDic[lastCards[1]])")
                    }else if lastCards[1] == nextCards[0]{
                        self.cardArray.append(lastCards[0])
                        print("result 放入牌堆\(cardLabelDic[lastCards[0]])")
                    }else{
                        isCardCls = true
                    }
                }
                else if nextCards.count == 2{
                    if(lastCards[0] == nextCards[0] && lastCards[1] != nextCards[1]){
                        self.cardArray.append(lastCards[1])
                        print("result 放入牌堆\(cardLabelDic[lastCards[1]])")
                    }
                    else if(lastCards[0] != nextCards[0] && lastCards[1] == nextCards[1]){
                        self.cardArray.append(lastCards[0])
                        print("result 放入牌堆\(cardLabelDic[lastCards[0]])")
                    }
                    else if(lastCards[0] != nextCards[0] && lastCards[1] != nextCards[1]){
                        isCardCls = true
                    }
                }
            }
            //两张牌同时变化判定上下关系
            if isCardCls{
                if let pixelBufferCardCls = createCVPixelBuffer(ciImage: originCIImage, targetSize: CGSize(width: 960, height: 540)){
                    let cardClsResult = try! cardClsModel.prediction(image: pixelBufferCardCls)
                    if(cardClsResult.var_379[0].floatValue < cardClsResult.var_379[1].floatValue){
                        self.cardArray.append(lastCards[0])
                        self.cardArray.append(lastCards[1])
                        print("result 先后: 放入牌堆\(cardLabelDic[lastCards[0]]) 放入牌堆\(cardLabelDic[lastCards[1]])")
                    }
                    else{
                        self.cardArray.append(lastCards[1])
                        self.cardArray.append(lastCards[0])
                        print("result 先后: 放入牌堆\(cardLabelDic[lastCards[1]]) 放入牌堆\(cardLabelDic[lastCards[0]])")
                    }
                }
            }
        }
        
        if nextCards.count <= 2{
            self.lastCards = nextCards
        }

            //刷新列表
//            print("todo list count \(todoKeyList.count) card array \(self.cardArray.count)")
//            addedResultKeylist.append(todoKeyList[0])
//            self.addedResultDictionary[todoKeyList[0]] = nextCards
//            self.todoResultDictionary.removeValue(forKey: todoKeyList[0])
//            todoKeyList.remove(at: 0)
//        }
    }
    
    
    func getActionResult(from resultArray: MLMultiArray) -> Int{
        var maxVal : Float = 0
        var maxValIndex : Int = 0
        let n = Int(resultArray.shape[0])
        for i in 0..<n{
            let value = resultArray[i].floatValue
            if value > maxVal {
                maxVal = value
                maxValIndex = i
            }
        }
        return maxValIndex
    }
    
    
    
    //返回检测到的目标类别，n当前设定为最多两个，后续可根据置信度进行排序输出或全部输出
    func getCard(from cardArray: MLMultiArray, from boxArray : MLMultiArray) -> [DetectionResult] {
        let cnt : Int = Int(cardArray.shape[0])
        let n : Int = Int(cardArray.shape[1])
        var result : [DetectionResult] = []
        for i in 0..<cnt {
            var maxVal: Float32 = cardArray[i * n].floatValue
            var maxValIndex : Int = 0
            var confidenceSum : Float = 0
            for j in 1..<n {
                let index = i * n + j
                let value = cardArray[index].floatValue
                confidenceSum += value
                if value > maxVal {
                    maxVal = value
                    maxValIndex = j
                }
            }
            if !result.contains(where: { $0.cardIndex == maxValIndex }) && maxVal / confidenceSum > 0.9  {
                result.append(DetectionResult(cardIndex: maxValIndex, confidence: maxVal, x_coordinate: boxArray[4 * i].floatValue))
            }
        }
        
        //当目标数量为2时左右的判断，模型调整后可能需要根据单图测试的坐标结果进行修改
        if result.count == 2{
            if result[0].x_coordinate > result[1].x_coordinate{
                result.swapAt(0, 1) //x坐标小的在左边
            }
        }
        return result
    }

    
    //单张图片检测，处理后的图片保存显示
    func detectionTest(at url: URL) async{
        //detection test  目标size以model/prediction/input中显示的为准
        // Get the image path
        guard let imageURL = Bundle.main.url(forResource: "000074.jpg", withExtension: nil) else {
            print("Unable to get image path")
            return
        }
        
        // Load the image as a CIImage
        guard let originCiImage = CIImage(contentsOf: imageURL) else {
            print("Unable to load image as CIImage")
            return
        }
        
        let context = CIContext()
        
        if let pixelBuffer = createCVPixelBuffer(ciImage: originCiImage, targetSize: CGSize(width: 544, height: 960), isSavedImage: true){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent){
                await display(image: cgImage)
            }
            
            print("image generated")
            
        }
        else
        {
            print("无法生成 CVPixelBuffer")
        }
    }
    

    
    //单段视频测试
    func processVideoFile(at url: URL) async throws{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            print("视频文件存在")
        } else {
            print("视频文件不存在")
        }
        
        // 创建 AVAsset
        let asset = AVURLAsset(url: url)
        
        var lastCards : [Int] = []
        self.cardArray = []
        
        // 创建 AVAssetReader
        guard let reader = try? AVAssetReader(asset: asset) else {
            print("无法创建 AVAssetReader")
            return
        }
        
        let outputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        // 获取视频轨道
        guard let videoTrack = try! await asset.loadTracks(withMediaType: .video).first else {
            print("无法获取视频轨道")
            return
        }
        
        // 创建视频轨道输出
        let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
        reader.add(videoOutput)
        
        // 启动读取器
        reader.startReading()
        let context = CIContext()
        
        var lastTime = CFAbsoluteTimeGetCurrent()
        
        // 读取并处理每个视频帧
        while let sampleBuffer = videoOutput.copyNextSampleBuffer() {
            // 处理视频帧数据
            if let originPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                // 在这里访问和处理视频帧的像素数据
                
                let originCIImage = CIImage(cvPixelBuffer: originPixelBuffer)
                
                if let pixelBuffer = createCVPixelBuffer(ciImage: originCIImage, targetSize: CGSize(width: 960, height: 544)){


                    //显示当前帧
                    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                    
                    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent){
                        await display(image: cgImage)
                    }
                    
                    
                 }
            }
            // 释放视频帧资源
            CMSampleBufferInvalidate(sampleBuffer)
        }
        // 完成读取后的清理操作
        reader.cancelReading()
    }
    

    @MainActor func display(image: CGImage) {
        self.cameraImage = image
    }
    
    func computeWinnerPlayer() {
        winnerPlayer = GameManager.selectGame(gameIndex: ruleIndex, inputCards: cardArray, args: args, rankRules: rankRules, suitRules: suitRules)
        
        speakText(input: winnerPlayer)
    }
    

    func speakText(input: [Int]) {
        let speechSynthesizer = AVSpeechSynthesizer()

        if input.isEmpty {
            let speechUtterance = AVSpeechUtterance(string: "无")
            speechSynthesizer.speak(speechUtterance)
        } else {
            let speechStrings = input.map { String($0) }
            let joinedSpeech = speechStrings.joined(separator: "和")
            let speechUtterance = AVSpeechUtterance(string: joinedSpeech)
            speechSynthesizer.speak(speechUtterance)
        }
    }
    
    //TODO return all cards
    func speakText(input:[String:Int]){
        
    }
}


class DetectionResult {
    let cardIndex : Int
    let confidence : Float
    let x_coordinate : Float

    init(cardIndex: Int, confidence: Float, x_coordinate: Float) {
        self.cardIndex = cardIndex
        self.confidence = confidence
        self.x_coordinate = x_coordinate
    }
}
