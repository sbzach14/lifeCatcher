

import SwiftUI

struct ShowResultView: View {
    @EnvironmentObject var viewModel : CurrentVisionObjectRecognitionViewModel

    private var presentation: RemotePresentationSnapshot {
        RemotePresentationBuilder.make(
            deck: viewModel.singlefeatureArray,
            hidesLastCard: viewModel.shuffleOrRiffle == 1 && viewModel.shuffleMode[1] == 2,
            cutCards: viewModel.cutShowArray,
            result: viewModel.multipleDatasetRCInfos,
            speech: [],
            voiceRate: viewModel.voiceRate,
            repeatCount: 1,
            separateUtterances: false
        )
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            RemoteResultContentView(presentation: presentation)
            
            Spacer()
            
            HStack{
                Spacer()
                
                Button {
                    viewModel.generateTestResult()
                } label: {
                    Image("icon_test").resizable().frame(width: 150, height: 60)
                }
                
                Spacer()
                
                Button {
                    viewModel.isShowSingleFeature = false
                } label: {
                    Image("icon_back").resizable().frame(width: 150, height: 60)
                }
                
                Spacer()
            }.frame(height: 60, alignment: .bottom)
        }
        .background(Image("Newbg2").resizable()
            .scaledToFill()
            .ignoresSafeArea())
        .gesture(
            DragGesture(minimumDistance: 50)
                .onChanged { value in
                    if value.translation.width > 0 {
                        // 左滑
                        viewModel.isShowSingleFeature = false
                    }
                }
        )
    }
    
}
