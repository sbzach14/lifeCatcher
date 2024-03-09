import SwiftUI

struct MainContentView: View {
    var saveRuleIndex : Int
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
            viewModel.initialize(saveRuleIndex : saveRuleIndex)
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


