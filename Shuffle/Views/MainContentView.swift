import SwiftUI

struct MainContentView: View {
    var playerNum:Int
    var shuffleMode: Int
    var cutMode: Int
    var dealType: Int
    var diyDealType: Int
    var diyDealNum: [Int]
    var diyDealStatus: [[Bool]]
    var calModeArgs: [Int]
    var cutNumSetting: Int
    var cutNumRangeSetting: [Int]
    var consecutiveReport: Int
    var reportNumber: Int
    var voiceReport: Int
    var ruleIndex: Int
    var args: [Int]
    var rankRules: [Int]
    var suitRules: [Int]
    var allCardIndex: [Int]
    var minCardNum : Int
    @StateObject var viewModel = ViewModel()
    var body: some View {
        ZStack {
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
            } else {
                ZStack {
                    ShowCardView().environmentObject(viewModel)
                }
                .background {
                    if let image = viewModel.cameraImage {
                        CameraView(cameraImage: image)
                            .ignoresSafeArea()
                    }
                }
            }
        }
        .onAppear {
            viewModel.initialize(playerNum: playerNum, shuffleMode: shuffleMode, cutMode: cutMode, dealType: dealType, diyDealType: diyDealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus, calModeArgs: calModeArgs, cutNumSetting: cutNumSetting, cutNumRangeSetting: cutNumRangeSetting, consecutiveReport: consecutiveReport, reportNumber: reportNumber, voiceReport: voiceReport, ruleIndex: ruleIndex, args: args, rankRules: rankRules, suitRules: suitRules, allCardIndex: allCardIndex, minCardNum: minCardNum)
        }
        .onDisappear {
            viewModel.stopCamera()
        }
    }
}



//struct MainContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainContentView(ruleIndex: 0, args: [0, 0, 1, 0, 1, 2, 0, 0], rankRules: [1,2,3], suitRules: [3,2,1,0], allCardIndex: Array(0...51))
//    }
//}


