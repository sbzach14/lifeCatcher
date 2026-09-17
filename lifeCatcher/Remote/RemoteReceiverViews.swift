import SwiftUI

struct RemotePresenceItem: Identifiable {
    let label: String
    let state: RemotePresenceState

    var id: String { label }
}

struct RemotePresenceStatusBar: View {
    let items: [RemotePresenceItem]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(items) { item in
                HStack(spacing: 4) {
                    Image(systemName: item.state.statusIcon)
                    Text("\(item.label) \(item.state.statusTitle)")
                }
                .foregroundColor(item.state.statusColor)
            }
        }
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.68))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
    }
}

private extension RemotePresenceState {
    var statusTitle: String {
        switch self {
        case .online: return "在线"
        case .reconnecting: return "重连中"
        case .offline: return "离线"
        }
    }

    var statusIcon: String {
        switch self {
        case .online: return "checkmark.circle.fill"
        case .reconnecting: return "arrow.triangle.2.circlepath.circle.fill"
        case .offline: return "circle.fill"
        }
    }

    var statusColor: Color {
        switch self {
        case .online: return .green
        case .reconnecting: return .orange
        case .offline: return .secondary
        }
    }
}

struct RemoteReceiverConnectView: View {
    @StateObject private var viewModel = RemoteReceiverViewModel()
    @AppStorage(RemotePreferenceKeys.receiverRegion) private var regionValue = RemoteRegion.cn.rawValue
    @AppStorage(RemotePreferenceKeys.receiverLastSerial) private var serial = ""
    @State private var connectionTask: Task<Void, Never>?

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
        .onDisappear {
            connectionTask?.cancel()
            connectionTask = nil
            viewModel.disconnect()
        }
    }

    private var connectionForm: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 58))
                .foregroundColor(.white)
            Text("加入远程会话")
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
                    connectionTask?.cancel()
                    connectionTask = Task { await viewModel.connect(region: region, serial: serial) }
                } label: {
                    Text(viewModel.connectionState == .connecting ? "正在连接…" : "开始连接")
                        .frame(maxWidth: .infinity).padding(12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!region.isConfigured || !(8...128).contains(serial.trimmingCharacters(in: .whitespacesAndNewlines).count) || viewModel.connectionState == .connecting)

                NavigationLink {
                    RemoteReceiverSettingsView()
                } label: {
                    Label("功能设置", systemImage: "gearshape.fill")
                        .frame(maxWidth: .infinity).padding(10)
                }
                .buttonStyle(.bordered)
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
        ZStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            if !isDisguiseVisible {
                RemotePresenceStatusBar(items: [
                    RemotePresenceItem(label: "服务器", state: viewModel.serverPresence),
                    RemotePresenceItem(label: "手机1", state: viewModel.sourcePresence),
                    RemotePresenceItem(label: "桌面端", state: viewModel.desktopPresence)
                ])
                .padding(.top, 8)
            }
        }
        .toolbar(isDisguiseVisible ? .hidden : .visible, for: .navigationBar)
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
            if mode == .black { UIScreen.main.brightness = CGFloat(viewModel.blackFactor) }
            else { UIScreen.main.brightness = previousBrightness }
        }
        .onDisappear {
            UIScreen.main.brightness = previousBrightness
            UIApplication.shared.isIdleTimerDisabled = previousIdleTimerDisabled
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
                if viewModel.blackMode != 0 { viewModel.setDisplayMode(.black) }
            }
        case .black:
            disguiseContent
                .onTapGesture(count: 2) { viewModel.setDisplayMode(.video) }
        }
    }

    private var isDisguiseVisible: Bool {
        viewModel.displayMode == .black
    }

    @ViewBuilder private var disguiseContent: some View {
        ZStack(alignment: .top) {
            Color.black
            if viewModel.timeMode != 0 {
                VStack(spacing: 0) {
                    Text("\(TimeModeFormatter.dateFormatter.string(from: viewModel.currentDate).replacingOccurrences(of: "星期", with: "周")) · \(TimeModeFormatter.lunarDateString(from: viewModel.currentDate))")
                        .font(.system(size: 22))
                        .bold()
                        .padding(.top, 40)
                    Text(viewModel.timeText)
                        .font(.system(size: viewModel.timeMode == 1 ? 100 : 70))
                        .bold()
                    Spacer()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .contentShape(Rectangle())
        .ignoresSafeArea()
    }
}

struct RemoteReceiverSettingsView: View {
    var audioOnly = false
    @AppStorage(RemotePreferenceKeys.receiverSoundEnabled) private var soundEnabled = true
    @AppStorage(RemotePreferenceKeys.receiverVolume) private var volume: Double = 0.5
    @AppStorage(RemotePreferenceKeys.receiverVoiceRate) private var voiceRate: Double = 0.5
    @AppStorage(RemotePreferenceKeys.receiverVoiceDevice) private var voiceDevice = 0
    @AppStorage(RemotePreferenceKeys.receiverBlackMode) private var blackMode = 0
    @AppStorage(RemotePreferenceKeys.receiverTimeMode) private var timeMode = 0
    @AppStorage(RemotePreferenceKeys.receiverBrightness) private var brightness: Double = 0.1

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Toggle("播放提示音和结果播报", isOn: $soundEnabled)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .frame(minHeight: 50)
                Divider().colorInvert()

                settingPickerRow("播放设备", selection: $voiceDevice) {
                    Text("扬声器").tag(0)
                    Text("耳机").tag(1)
                }
                Divider().colorInvert()

                settingSliderRow("音量", value: $volume)
                Divider().colorInvert()

                settingSliderRow("语速", value: $voiceRate)
                Divider().colorInvert()

                if !audioOnly {
                    settingPickerRow("屏幕显示", selection: $blackMode) {
                        Text("无").tag(0)
                        Text("正常黑屏（双击进入）").tag(1)
                        Text("黑屏点击（双击进入，单击暂停）").tag(2)
                    }
                    Divider().colorInvert()

                    settingPickerRow("时间模式", selection: $timeMode) {
                        Text("无").tag(0)
                        Text("HH:MM").tag(1)
                        Text("HH:MM:SS").tag(2)
                    }
                    Divider().colorInvert()

                    settingSliderRow("黑屏亮度", value: $brightness)
                    Divider().colorInvert()
                }
            }
        }
        .background(Image("Newbg2").resizable().scaledToFill().ignoresSafeArea())
        .navigationTitle(audioOnly ? "接收声音设置" : "接收端功能设置")
        .navigationBarTitleDisplayMode(.automatic)
        .onChange(of: soundEnabled) { _, value in RemotePreferences.receiverSoundEnabled = value }
        .onChange(of: volume) { _, value in RemotePreferences.receiverVolume = Float(value) }
        .onChange(of: voiceRate) { _, value in RemotePreferences.receiverVoiceRate = Float(value) }
        .onChange(of: voiceDevice) { _, value in RemotePreferences.receiverVoiceDevice = value }
        .onChange(of: blackMode) { _, value in RemotePreferences.receiverBlackMode = value }
        .onChange(of: timeMode) { _, value in RemotePreferences.receiverTimeMode = value }
        .onChange(of: brightness) { _, value in RemotePreferences.receiverBrightness = Float(value) }
    }

    private func settingPickerRow<Selection: Hashable, Content: View>(
        _ title: String,
        selection: Binding<Selection>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Text(title).foregroundColor(.white)
            Spacer()
            Picker(title, selection: selection, content: content)
                .pickerStyle(.menu)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 50)
    }

    private func settingSliderRow(_ title: String, value: Binding<Double>) -> some View {
        HStack {
            Text("\(title) \(String(format: "%.2f", value.wrappedValue))")
                .foregroundColor(.white)
                .frame(width: 115, alignment: .leading)
            Slider(value: value, in: 0...1, step: 0.01)
                .accentColor(.white)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 50)
    }
}

struct RemoteReceiverAudioSettingsView: View {
    var body: some View { RemoteReceiverSettingsView(audioOnly: true) }
}
