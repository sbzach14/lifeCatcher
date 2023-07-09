import SwiftUI

struct MainContentView: View {
    var ruleIndex : Int
    var args : [Int]
    var rankRules : [Int]
    var suitRules : [Int]
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
            viewModel.initialize(ruleIndex: ruleIndex, args : args, rankRules : rankRules, suitRules: suitRules)
            //test code
            //viewModel.cardArray = [37, 47, 21, 25, 38, 13, 10, 33, 22, 23, 51, 0, 35, 46, 7, 39, 26, 36, ]
            //viewModel.computeWinnerPlayer()
        }
        // 视图消失时停止相机采集
        .onDisappear {
            viewModel.stopCamera()
        }
    }
    
    
}



struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(ruleIndex: 0, args: [0, 0, 1, 0, 1, 2, 0, 0], rankRules: [1,2,3], suitRules: [3,2,1,0])
    }
}


