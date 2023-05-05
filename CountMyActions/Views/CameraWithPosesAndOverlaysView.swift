import SwiftUI

struct CameraWithPosesAndOverlaysView: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack {
            OverlayView(cards: viewModel.cardArray)
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
    }
}

