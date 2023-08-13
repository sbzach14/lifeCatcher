import SwiftUI

struct VisionObjectRecognitionView: View {
    @StateObject var viewModel = VisionObjectRecognitionViewModel()

    var body: some View {
        
        
        if viewModel.isBlack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .opacity(1.0)
            }
            .onAppear {
                UIScreen.main.brightness = 0.0
            }
            .onDisappear {
                UIScreen.main.brightness = 1.0
            }
            .navigationBarBackButtonHidden(true)
        }
        else{
            VStack {
                Text(viewModel.detectedObjects.map { $0.cls }.joined(separator: " "))
                    .font(.title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // Handle the tap action here
                    // For example, you can capture and save the image
                    viewModel.recordScreen()
                }) {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .padding(.bottom, 20) // Add some padding to position the button at the bottom
            }
            .background{
                if let image = viewModel.cameraImage{
                    CameraView(cameraImage: image)
                        .ignoresSafeArea()
                }
            }
            .onAppear {
                viewModel.initialize()
            }
            // 视图消失时停止相机采集
            .onDisappear {
                viewModel.stopCamera()
            }
        }
    }
}


// 添加预览
struct VisionObjectRecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        VisionObjectRecognitionView()
    }
}
