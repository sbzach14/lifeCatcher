import SwiftUI

struct MainContentView: View {
    var ruleIndex : Int
    var playerNum : Int
    var args : [Int]
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
            viewModel.initialize(playerNum: playerNum, ruleIndex: ruleIndex, args : args)
            //test code
            viewModel.cardArray = [37, 47, 21, 25, 38, 13, 10, 33, 22, 23, 51, 0, 35, 46, 7, 39, 26, 36, ]
            viewModel.computeWinnerPlayer()
        }
    }
}



struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(ruleIndex: 0, playerNum: 5, args: [1])
    }
}


