import SwiftUI

struct OriginVisionObjectRecognitionView: View {
    @StateObject var viewModel = OriginVisionObjectRecognitionViewModel()
    
    var body: some View {

        VStack {
            Text(viewModel.detectedObjects.map { $0.cls }.joined(separator: " "))
                .font(.title)
                .foregroundColor(.primary)
            
            Spacer()
            
            
            Button(action: {
                viewModel.recordScreen()
            }) {
                Image("save").resizable().frame(width: 150, height: 150).clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
            .padding(.bottom, 20)
        }
        .background{
            if let image = viewModel.cameraImage{
                CameraImageView(cameraImage: image)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            viewModel.initialize()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("相机权限被拒绝"),
                message: Text("请在设置中启用相机权限以使用此功能。"),
                dismissButton: .default(Text("确定")) {
                    exit(0)
                }
            )
        }
        .toolbarBackground(.hidden)
        .navigationTitle("")
    }
}
