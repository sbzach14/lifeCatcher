import SwiftUI

struct MainContentView: View {
    var shuffleMode: Int
    var calModeArgs: [Int]
    var ruleIndex: Int
    var args: [Int]
    var rankRules: [Int]
    var suitRules: [Int]
    var allCardIndex: [Int]
    var minCardNum : Int
    @ObservedObject var viewModel = ViewModel()
    
    
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
            viewModel.initialize(shuffleMode: shuffleMode, calModeArgs: calModeArgs, ruleIndex: ruleIndex, args: args, rankRules: rankRules, suitRules: suitRules, allCardIndex: allCardIndex, minCardNum: minCardNum)
            viewModel.startCamera()
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


