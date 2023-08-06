import SwiftUI

struct MainContentView: View {
    var ruleIndex: Int
    var args: [Int]
    var rankRules: [Int]
    var suitRules: [Int]
    var allCardIndex: [Int]
    @StateObject var viewModel: ViewModel
    
    // 初始化器中初始化 viewModel
    init(ruleIndex: Int, args: [Int], rankRules: [Int], suitRules: [Int], allCardIndex: [Int]) {
        self.ruleIndex = ruleIndex
        self.args = args
        self.rankRules = rankRules
        self.suitRules = suitRules
        self.allCardIndex = allCardIndex
        _viewModel = StateObject(wrappedValue: ViewModel())
        viewModel.initialize(ruleIndex: ruleIndex, args: args, rankRules: rankRules, suitRules: suitRules, allCardIndex: allCardIndex)
    }
    
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
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
    }
}



struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(ruleIndex: 0, args: [0, 0, 1, 0, 1, 2, 0, 0], rankRules: [1,2,3], suitRules: [3,2,1,0], allCardIndex: Array(0...51))
    }
}


