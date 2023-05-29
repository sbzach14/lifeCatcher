import SwiftUI

struct MainContentView: View {
    var ruleIndex : Int
    var playerNum : Int
    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack {
            ShowCardView(cards: viewModel.cardArray, winners: viewModel.winnerPlayer)
        }
        .background{
            if let image = viewModel.cameraImage{
                CameraView(cameraImage: image)
                .ignoresSafeArea()
            }
        }
        .onAppear {
            viewModel.initialize(playerNum: playerNum, ruleIndex: ruleIndex)
        }
    }
}



struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(ruleIndex: 0, playerNum: 0)
    }
}


