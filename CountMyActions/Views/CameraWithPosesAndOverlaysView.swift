struct CameraWithPosesAndOverlaysView: View {

    @StateObject var viewModel = ViewModel()
    @State var showCardView = false

    var body: some View {
        ZStack {
            if showCardView {
                CardView(cards: viewModel.cards)
            }
            OverlayView(count: viewModel.uiCount) {
                viewModel.onCameraButtonTapped()
            }
        }
        .background {
            if viewModel.isShowCardArray {
                // 如果当前有 CardView，则删除
                if showCardView {
                    showCardView = false
                }
                // 创建一个新的 CardView
                showCardView = true
            } else {
                // 如果当前有 CardView，则删除
                if showCardView {
                    showCardView = false
                }
            }
        }
        .onAppear {
            viewModel.initialize()
        }

        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: {
                    viewModel.onCardArrayButtonTapped()
                }, label: {
                    Text("cardArray Button")
                })
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct CameraWithOverlaysView_Previews: PreviewProvider {
    static var previews: some View {
        CameraWithPosesAndOverlaysView()
    }
}
