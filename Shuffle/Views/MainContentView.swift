import SwiftUI

struct MainContentView: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack {
            ShowCardView(cards: viewModel.cardArray)
            ShowRuleView().environmentObject(viewModel)
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


struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}


