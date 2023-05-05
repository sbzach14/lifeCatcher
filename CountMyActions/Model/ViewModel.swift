/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's main view model.
*/

import SwiftUI
import CreateMLComponents
import AsyncAlgorithms

/// - Tag: ViewModel
class ViewModel: ObservableObject {
    
    @Published var cameraImage : CGImage?
    
    // cardArray
    @Published var cardArray : Array<Int> = []
    
    private var displayCameraTask: Task<Void, Error>?
    
    /// The camera configuration to define the basic camera position, pixel format, and resolution to use.
    private var configuration = VideoReader.CameraConfiguration()
    

    // MARK: - View Controller Events

    /// Configures the main view after it loads.
    /// Starts the video-processing pipeline.
    func initialize() {
        toggleCameraSelection()
        
        cardArray = Array(0...51)

        // Restart the video processing.
        startVideoProcessingPipeline()
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

            //TODO: 这里视频帧流逐张图传入模型之中，替换模型
            // cardArray = try await model.applied(to: frame.feature)
            
            //TODO: compute rule result

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
}
