import SwiftUI

struct RemoteReceiverConnectView: View {
    @StateObject private var viewModel = RemoteReceiverViewModel()
    @AppStorage(RemotePreferenceKeys.receiverRegion) private var regionValue = RemoteRegion.cn.rawValue
    @AppStorage(RemotePreferenceKeys.receiverLastSerial) private var serial = ""

    private var region: RemoteRegion {
        get { RemoteRegion(rawValue: regionValue) ?? .cn }
        nonmutating set { regionValue = newValue.rawValue }
    }

    var body: some View {
        Group {
            switch viewModel.connectionState {
            case .connected, .reconnecting:
                RemoteReceiverSessionView(viewModel: viewModel)
            default:
                connectionForm
            }
        }
        .navigationTitle("接收端")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var connectionForm: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 58))
                .foregroundColor(.white)
            Text("连接手机1")
                .font(.title2).bold().foregroundColor(.white)

            VStack(spacing: 14) {
                Picker("服务器", selection: Binding(get: { region }, set: { region = $0 })) {
                    ForEach(RemoteRegion.allCases) { item in Text(item.title).tag(item) }
                }
                .pickerStyle(.segmented)

                HStack {
                    Image(systemName: region.isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    Text(region.isConfigured ? "连接地址：\(region.endpointDescription)" : "该区域 IP 尚未配置")
                }
                .font(.caption)
                .foregroundColor(region.isConfigured ? .green : .orange)

                TextField("输入手机1序列号", text: $serial)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(.white.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    Task { await viewModel.connect(region: region, serial: serial) }
                } label: {
                    Text(viewModel.connectionState == .connecting ? "正在连接…" : "开始连接")
                        .frame(maxWidth: .infinity).padding(12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!region.isConfigured || !(8...128).contains(serial.trimmingCharacters(in: .whitespacesAndNewlines).count) || viewModel.connectionState == .connecting)
            }
            .padding()
            .background(.black.opacity(0.38))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage).foregroundColor(.red).multilineTextAlignment(.center).padding(.horizontal)
            }
            Spacer()
        }
        .background(Image("Newbg2").resizable().scaledToFill().ignoresSafeArea())
    }
}

struct RemoteReceiverSessionView: View {
    @ObservedObject var viewModel: RemoteReceiverViewModel
    @State private var previousBrightness = UIScreen.main.brightness
    @State private var previousIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            HStack(spacing: 8) {
                modeButton("画面", .video, "video.fill")
                modeButton("黑屏", .black, "moon.fill")
                modeButton("时间", .time, "clock.fill")
                modeButton("结果", .result, "rectangle.grid.1x2.fill")
            }
            .padding(8)
            .background(.black.opacity(0.62))
            .clipShape(Capsule())
            .padding(.bottom, 14)
        }
        .overlay(alignment: .top) {
            Text(statusText)
                .font(.caption).foregroundColor(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(.black.opacity(0.55)).clipShape(Capsule()).padding(.top, 8)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("断开") { viewModel.disconnect() }
            }
        }
        .onAppear {
            previousIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onChange(of: viewModel.displayMode) { _, mode in
            if mode == .black || mode == .time { UIScreen.main.brightness = CGFloat(viewModel.blackFactor) }
            else { UIScreen.main.brightness = previousBrightness }
        }
        .onDisappear {
            UIScreen.main.brightness = previousBrightness
            UIApplication.shared.isIdleTimerDisabled = previousIdleTimerDisabled
            viewModel.disconnect()
        }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.displayMode {
        case .video:
            ZStack {
                Color.black
                RemoteVideoSurface(subscriber: viewModel.videoSubscriber)
                if viewModel.videoSubscriber.track == nil {
                    Text(viewModel.sourceOnline ? "正在建立实时画面…" : "等待手机1上线")
                        .foregroundColor(.white)
                }
            }
            .onTapGesture(count: 2) {
                if viewModel.blackMode != 0 { viewModel.setDisplayMode(viewModel.timeMode == 0 ? .black : .time) }
            }
            .gesture(DragGesture(minimumDistance: 50).onEnded { value in
                if value.translation.width < 0 { viewModel.setDisplayMode(.result) }
            })
        case .black:
            Color.black.contentShape(Rectangle()).onTapGesture { viewModel.setDisplayMode(.result) }
        case .time:
            VStack(spacing: 12) {
                Text("\(TimeModeFormatter.dateFormatter.string(from: viewModel.currentDate).replacingOccurrences(of: "星期", with: "周")) · \(TimeModeFormatter.lunarDateString(from: viewModel.currentDate))")
                    .font(.system(size: 22)).bold()
                Text(viewModel.timeText)
                    .font(.system(size: viewModel.timeMode == 1 ? 100 : 70)).bold()
                Spacer()
            }
            .padding(.top, 42)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .contentShape(Rectangle())
            .onTapGesture { viewModel.setDisplayMode(.result) }
        case .result:
            RemoteResultContentView(presentation: viewModel.presentation)
                .gesture(DragGesture(minimumDistance: 50).onEnded { value in
                    if value.translation.width > 0 { viewModel.setDisplayMode(.video) }
                })
        }
    }

    private func modeButton(_ title: String, _ mode: RemoteReceiverViewModel.DisplayMode, _ icon: String) -> some View {
        Button { viewModel.setDisplayMode(mode) } label: {
            Label(title, systemImage: icon).labelStyle(.iconOnly)
                .frame(width: 32, height: 28)
                .foregroundColor(viewModel.displayMode == mode ? .blue : .white)
        }
    }

    private var statusText: String {
        if viewModel.connectionState == .reconnecting { return "网络中断，正在自动重连" }
        return viewModel.sourceOnline ? "手机1在线" : "等待手机1"
    }
}
