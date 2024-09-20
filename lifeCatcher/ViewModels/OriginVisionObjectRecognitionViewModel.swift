import UIKit
import AVFoundation
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import Accelerate

class OriginVisionObjectRecognitionViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate  {
    
    var bufferSize: CGSize = .zero
    let context = CIContext()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let session = AVCaptureSession()
    private var requests = [VNRequest]()
    @Published var detectedObjects: [DetectedObject] = []
    @Published var cameraImage : CGImage?
    @Published var showAlert: Bool = false
    private var speechSynthesizer = AVSpeechSynthesizer()
    @Published var isCameraSetting : Bool = false
    var successAudioRC: AVAudioPlayer?
    
    func initialize(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupAVCapture()
            setupVision()
            startCaptureSession()
            configureAudioSession()
        @unknown default:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupAVCapture()
                        self.setupVision()
                        self.startCaptureSession()
                    } else {
                        self.showAlert = true
                    }
                }
            }
        }
        
    }
    
    // MARK: - Public Methods
    
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        var videoDevice: AVCaptureDevice
        
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
        var setFrameRate:Float64 = 240
        
        for format in videoDevice.formats {
            // 获取支持的帧率范围
            for range in format.videoSupportedFrameRateRanges {
                // 检查是否支持 240 帧
                if range.maxFrameRate >= 240 {
                    // 获取支持的图像尺寸
                    let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                    // print(dimensions)
                }
            }
        }
        
        guard let format = videoDevice.formats.first(where: { format in
            let ranges = format.videoSupportedFrameRateRanges
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            return dimensions.width == 1920
                && ranges.contains { range in
                    return range.maxFrameRate >= setFrameRate && format.supportedColorSpaces.count == 1
            }
        }) else {
            // print("不支持\(setFrameRate)帧的摄像头格式")
            return
        }
        do {
            try videoDevice.lockForConfiguration()
            // 设置帧率为 30 帧
            videoDevice.activeFormat = format
            videoDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 30)
            videoDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 30)
            
            let dimension = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
            // print(dimension.width, dimension.height)
            
            videoDevice.unlockForConfiguration()
        } catch {
            // print("设置帧率时发生错误: \(error)")
        }
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            // print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        guard session.canAddInput(deviceInput) else {
            // print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            // print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        do {
            try videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice.activeFormat.formatDescription))
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch {
            // print(error)
        }
        session.commitConfiguration()
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    func stopCamera() {
        session.stopRunning()

    }
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            // print("Failed to set up audio session: \(error)")
        }
        
        guard let soundURL = Bundle.main.url(forResource: "success_voice", withExtension: "mp3") else {
            // print("Sound file not found")
            return
        }

        do {
            successAudioRC = try AVAudioPlayer(contentsOf: soundURL)
            successAudioRC!.prepareToPlay()
        } catch {
            // print("Failed to play sound: \(error)")
        }
    }
    
    // MARK: - Vision Setup
    
    func setupVision() {
        guard let modelURL = Bundle.main.url(forResource: "cls_main", withExtension: "mlmodelc") else {
            // print("Model file is missing")
            return
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            // Get the screen size in points
            let screenWidthInPoints = UIScreen.main.bounds.width
            let screenHeightInPoints = UIScreen.main.bounds.height

            // Get the scale factors to convert the detectedObject's bounds to screen coordinates
            let scaleX = screenWidthInPoints / self.bufferSize.height
            let scaleY = screenHeightInPoints / self.bufferSize.width
            
            let objectRecognition = VNCoreMLRequest(model: visionModel) { request, error in
                DispatchQueue.main.async {
                    if let results = request.results as? [VNClassificationObservation] {
                        var resultString = results[0].identifier
                        if let firstCommaIndex = resultString.firstIndex(of: ","){
                            let substring = resultString[..<firstCommaIndex]
                            resultString = String(substring)
                        }
                        self.detectedObjects = [DetectedObject(cls: resultString, bounds: CGRect())]
                    }
                }
            }
            self.requests = [objectRecognition]
        } catch let error as NSError {
            // print("Model loading went wrong: \(error)")
        }
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            // print(error)
        }
        
        

        // 处理视频帧数据
        if let ciImage = imageFromSampleBuffer(sampleBuffer) {
            
            let outputImage = ciImage
            
            let rotationTransform = CGAffineTransform(rotationAngle: -.pi / 2)  // 顺时针旋转90度
            let rotatedImage = outputImage.transformed(by: rotationTransform)
            
            let xOffset = ciImage.extent.size.height
            let translationTransform = CGAffineTransform(translationX: xOffset, y: CGFloat(0))
            let translatedImage = rotatedImage.transformed(by: translationTransform)
            let cgImage = context.createCGImage(translatedImage, from: translatedImage.extent)
            
            
            DispatchQueue.main.async {
                self.cameraImage = cgImage
            }
        }
    }
    
    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        return ciImage
    }
    

    public func recordScreen() {
        guard let cameraImage = self.cameraImage else {
            // print("Camera image is nil.")
            return
        }
        
        
//        let timestamp = Int(CACurrentMediaTime()*1000) // Get the current timestamp
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: date)

        let imageName = "\(timestamp).jpeg" // Use the timestamp as the image name

        let uiImage = UIImage(cgImage: cameraImage)
        
        // Save the image to the document directory with the current timestamp as the file name
        if let data = uiImage.jpegData(compressionQuality: 0.8),
           let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let recordHistoryURL = documentsURL.appendingPathComponent("recordHistory")
            let fileURL = recordHistoryURL.appendingPathComponent(imageName)

            // Write the image data to the file
            do {
                try data.write(to: fileURL)
                // print("File \(imageName) saved successfully")

                // Add the image name to the corresponding key in the recordHistory.json dictionary
                var recordDict = loadRecordHistory()
                recordDict[self.detectedObjects[0].cls]?.append(imageName)
                saveRecordHistory(recordDict: recordDict)
                
                speakText(input: "Collect Done")

            } catch {
                // print("Failed to save file \(imageName): \(error)")
            }
        }
    }

    private func loadRecordHistory() -> [String: [String]] {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recordHistory.json")

        do {
            let jsonData = try Data(contentsOf: fileURL)
            let recordDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [String]] ?? [:]
            return recordDict
        } catch {
            // print("Error loading recordHistory.json: \(error)")
            return [:]
        }
    }

    private func saveRecordHistory(recordDict: [String: [String]]) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recordHistory.json")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: recordDict, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
        } catch {
            // print("Error saving recordHistory.json: \(error)")
        }
    }
    
    func speakText(input: String){
        successAudioRC!.play()
        let speechUtterance = AVSpeechUtterance(string: input)
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(speechUtterance)
    }
        
}

struct DetectedObject {
    let cls: String
    let bounds: CGRect
}


