import SwiftUI

struct MainContentView: View {

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

