/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's main view model.
*/

import SwiftUI
import CreateMLComponents
import AsyncAlgorithms
import AVFoundation

import Python
import PythonKit

/// - Tag: ViewModel
class ViewModel: ObservableObject {
    
    
    
    @Published var cameraImage : CGImage?
    
    // cardArray
    @Published var cardArray :  [Int] = Array(0...51)
    @Published var winnerPlayer: [Int] = []

    public var state : Int = 0
    public var playerNum : Int = 2
    public var ruleIndex : Int = 0
    public var args : [Int] = []
    
    
    private var displayCameraTask: Task<Void, Error>?
    
    /// The camera configuration to define the basic camera position, pixel format, and resolution to use.
    private var configuration = VideoReader.CameraConfiguration()

    // MARK: - View Controller Events

    /// Configures the main view after it loads.
    /// Starts the video-processing pipeline.
    func initialize(playerNum : Int, ruleIndex: Int, args : [Int] ) {
        toggleCameraSelection()
        
        // Restart the video processing.
        startVideoProcessingPipeline()
        
        self.ruleIndex = ruleIndex
        self.playerNum = playerNum
        self.args = args
                
        // Python 初始化
        print("pythonInitialize")
        guard let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil) else { return }
        guard let libDynloadPath = Bundle.main.path(forResource: "python-stdlib/lib-dynload", ofType: nil) else { return }

        setenv("PYTHONHOME", stdLibPath, 1)
        setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath)", 1)

        Py_Initialize()
    }


    // MARK: - Helper methods

    /// Change the camera toggle positions.
    func toggleCameraSelection() {
        configuration.position = .front
        configuration.frameRate = 120
    }
    
    /// Start the video-processing pipeline by displaying the poses in the camera frames and
    /// starting the action repetition count prediction stream.
    func startVideoProcessingPipeline() {

        if let displayCameraTask = displayCameraTask {
            displayCameraTask.cancel()
        }

        displayCameraTask = Task {
            // Display poses on top of each camera frame.
            try await self.displayPoseInCamera()
        }
    }

    /// Display poses on top of each camera frame.
    func displayPoseInCamera() async throws {
        // Start reading the camera.
        let frameSequence = try await VideoReader.readCamera(
            configuration: configuration
        )
        var lastTime = CFAbsoluteTimeGetCurrent()

        for try await frame in frameSequence {

            if Task.isCancelled {
                return
            }
            
            if let cgImage = CIContext()
                .createCGImage(frame.feature, from: frame.feature.extent){
                await display(image: cgImage)
            }
            
            var nowState = 0
            
            //TODO: 这里视频帧流逐张图传入模型之中，替换模型
            // cardArray, nowState = try await model.applied(to: frame.feature)
            
            switch nowState{
            case 0:
                //idle
                if state == 1 || state == 2{
                    computeWinnerPlayer()
                    speakText(input: winnerPlayer)
                }
            case 1:
                //cut
                print("cut")
            case 2:
                //shuffle
                print("shuffle")
            default:
                //error
                print("error")
            }
            
            self.state = nowState

            // Frame rate debug information.
            print(String(format: "Frame rate %2.2f fps", 1 / (CFAbsoluteTimeGetCurrent() - lastTime)))
            lastTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    /// Updates the user interface's image view with the rendered poses.
    /// - Parameters:
    ///   - image: The image frame from the camera.
    ///   - poses: The detected poses to render onscreen.
    /// - Tag: display
    @MainActor func display(image: CGImage) {
        self.cameraImage = image
    }
    
    func computeWinnerPlayer() {
        winnerPlayer = GameManager.selectGame(gameIndex: ruleIndex, inputCards: cardArray, playerNum: playerNum, args: args)
        
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
