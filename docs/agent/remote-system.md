# 远程识别子系统（智能体入口）

## 1. 边界与不变量

远程功能只属于核心规则链路，不属于普通 `cls_main` 采集链路。手机角色在进入“幻影”后选择：

- 识别端（手机1）：使用原核心识别链路，进入识别页即连接、本机静音、时间模式为“无”，隐藏本地结果入口。
- 识别-接收端：同一识别页面以本机序列号分别连接 source 和 receiver 角色；继续识别并发送结果，同时播放桌面端转发给 receiver 的提示音、结果或文字。不额外订阅本机视频，不显示牌序结果页；识别设置的屏幕显示仍提供相机图像，接收声音控件直接位于功能设置中并独立保存。识别画面的“识别端”和“接收端”分别反映本机 source 与 receiver 的业务服务器连接状态，含义与两个单独入口的“服务器”状态一致。它占用该序列号唯一的 receiver 槽，因此不能与另一台纯接收端同时连接到同一序列号。
- 本地端：仅在 ModeSwitch/Auth 归档方案中显示，与识别端并列；不连接远程服务器，使用原本地音频、时间和结果显示。
- 接收端（手机2）：只建立网络、视频、结果展示和播放对象；严禁实例化 `CurrentVisionObjectRecognitionViewModel`，因此不会加载七个 Core ML 模型、创建 `AVCaptureSession` 或运行规则引擎。

必须保持以下不变量：

1. 识别、牌序恢复、`ClassifierSettingArgs.selectDataset` 和 `ReportManager` 的既有调用顺序不因网络成功或失败改变；远程模式下识别端的所有本地提示音与 TTS 禁用，本地模式按原播报设备设置输出。
2. 网络输出只监听三个既有边界：`speakText(input: Int)` 的开始/成功/失败、最终 `speakText(input:[[SpeakResultStruct]],...)`、`captureOutput` 的原始帧旁路；输入侧接收桌面端 `awaitShuffle` 会话复位与 `recomputeCut` 切牌重算命令。
3. 业务事件写入持久 outbox 后异步发送；网络异常不能阻塞识别线程。
4. 大陆与新加坡是完全隔离的域和会话空间。outbox 项记录 region + serial，禁止切换区域后跨区补发。
5. 权限模型仅为“知道当前序列号即可连接”，不要在本子系统自行增加账号、配对码或设备证明。
6. 同一识别端在一个区域最多一个手机接收端和一个桌面端。
7. 视频分辨率由识别端远程设置选择 1280×720 或 1920×1080，送帧率选择 30 或 60 FPS；编码最高码率按 720p30/60 与 1080p30/60 分别设为 2.5/4/5/8Mbps，开启“低功耗传输”后上限减半，WebRTC 仍根据实时带宽和拥塞向下自适应。这些设置只影响 LiveKit，不改变识别帧率。正常识别只有接收端或桌面端当前需要画面时才发布；用户主动进入帧率测试时直接发布用于测量。

## 2. 源码分层

| 文件 | 职责 |
|---|---|
| `RemoteProtocol.swift` | v1 DTO、可辨识 union 编解码；必须与服务器和桌面协议同步 |
| `RemoteServerProfile.swift` | 两个隔离区域、从 Info.plist 各读取一个固定 IPv4、独立 UserDefaults 键 |
| `RemoteDiagnostics.swift` | 统一错误翻译、终端日志与全局 toast；不记录序列号或 token |
| `RemoteBusinessClient.swift` | HTTP admission、WebSocket、10秒建连超时、恢复令牌、带抖动指数退避、媒体令牌 |
| `RemoteOutboxStore.swift` | 识别端未确认事件的 Application Support 原子 JSON outbox |
| `RemoteSourceBridge.swift` | 操作 ID、严格单飞序号、ACK 去重、视频需求控制、手机2/桌面端 presence；只写日志/toast，不调用音频 API |
| `RemoteVideoPublisher.swift` | 相机旁路按设置缩放为 720p/1080p、30/60 FPS，并以 LiveKit buffer track 发布 |
| `FrameRateTestView.swift` | 独立高速相机、Texas CLS、LiveKit 帧率测试；不实例化识别 VM、不读写方案或 outbox |
| `RemoteVideoSubscriber.swift` | 手机2 LiveKit 订阅与 UIKit `VideoView` SwiftUI bridge |
| `RemotePresentationBuilder.swift` | 把已计算、已排序的本地结果映射为纯展示快照 |
| `RemoteReceiverViewModel.swift` | 手机2业务状态、delivery 去重、画面需求、时间覆盖 |
| `RemoteReceiverAudioCoordinator.swift` | 两类抢占规则和同操作串行播放 |
| `RemoteResultContentView.swift` | 不依赖识别 ViewModel 的纯结果 UI；仅本地识别结果页复用 |
| `RemoteReceiverViews.swift` | 区域+序列号连接页，以及实时画面与黑屏/时间伪装显示 |

## 3. 识别端接入点

### 提示音

`CurrentVisionObjectRecognitionViewModel.speakText(input: Int)` 先建立远程事件：0/1/2 映射 start/success/failure，远程模式拦截本地播放，本地模式使用原提示音与音频路由；本地模式不建立远程桥接。

### 最终结果

`computeWinnerRC` 仍先完成数据集计算、牌数组回写、特殊玩法手牌排序，再调用原 `speakText(input:[[SpeakResultStruct]],...)`。远程模式不执行本地 TTS，运行时的时间模式为 0（写配置时保留用户保存值）；本地模式执行原 TTS 和时间显示。远程模式使用同一份牌序、切牌、`singleResultList`、`reportResult`、语速和重复次数构建 `RemotePresentationSnapshot`。不传 `shuffleOrRiffle`、当前轮索引、方案或其他规则设置。

识别完成但方案仍需切牌或照顶时，手机1先发送带 `isPreview=true` 的牌堆预览。服务器只把预览实时发给桌面端，不写历史、不转发手机2、不播放语音；切牌完成后的正式 presentation 覆盖预览并沿用原计算、历史、延时和转发链路。

### 视频

`captureOutput` 从同一个 `CMSampleBuffer` 旁路给桥接层，随后原检测仍读取 pixel buffer。不要重新引入 `CMSampleBufferInvalidate`；异步消费者依赖 Core Foundation 对 pixel buffer 的引用生命周期。媒体层在主线程先限流/单飞，再在独立 utility 队列缩放，识别队列不等待它。

### 桌面端待洗牌指令

桌面端发送 `source.command { command: "awaitShuffle" }`，服务器只允许当前 desktop 角色调用，并要求同序列号手机1在线；服务器转发为同名 `source.command` 后向桌面请求返回 ACK。识别端收到后执行会话级复位，并等待稳定双框才重新进入识别。该指令不转发给手机2、不进入结果 outbox、不改变方案或相机设置。

桌面端还可针对当前 presentation 发送 `source.command { command: "recomputeCut", cutCard }`。识别端保留最近一次完成识别时的原始牌序，按当前切牌模式替换最后一条切牌记录并重新调用既有规则计算；计算结果仍由标准 presentation outbox 发送，因此桌面端会更新当前结果，开启自动转发时手机2也会收到重算结果。历史结果不能触发该命令。

桌面端的识别开关发送 `source.command { command: "setRecognitionPaused", paused }`。暂停只关闭检测/分类处理并递增识别代次，使已排队的旧推理结果不能回写；相机采集和 LiveKit 画面继续运行。恢复后沿用暂停前的识别状态和已有结果继续处理。

暂停/继续与待洗牌控制均由识别端在实际执行后发送 `source.state`，包含 `recognitionPaused` 和 `awaitingShuffle`。服务器按 source 会话保存最后确认状态、实时推送桌面端，并在桌面重连的 welcome 中恢复；桌面不以命令已转交的 ACK 代替执行成功。首次或重新进入识别界面时，识别端处于运行且待洗牌状态，必须等稳定双框才能开始本轮识别，并向桌面同步 `recognitionPaused: false`、`awaitingShuffle: true`；进入稳定双框识别后再自动把 `awaitingShuffle` 改回 false。旧识别端不发送该消息时，桌面显示“状态待确认”并禁用控制，避免凭本地默认值误报状态。

## 4. 顺序、去重和重连

- `operationId`：一次识别尝试。start 开启新操作；后续 success/failure/presentation 归入当前操作。
- `eventId`：业务幂等键，写入 outbox 时生成，重连不改变。
- `sourceSessionId + sourceEventSeq`：服务器会话内严格连续序号。服务器 welcome 返回 `nextSourceEventSeq`。
- `RemoteSourceBridge` 同时只发送一个未 ACK 事件，避免多个 `Task` 乱序。
- ACK accepted/duplicate 都以服务器返回的最后序号推进；“服务器已收、客户端未收 ACK”时进程终止也不会造成序号缺口。
- 永久协议错误只隔离并删除对应远程 outbox 项，避免坏快照阻塞后续远程事件；会话或序号错误不丢事件，而是重连后按新 welcome 重派。两种路径都不回调或中断本地识别链。
- start/success/failure 有 5 秒有效期；过期提示从 outbox 清理。presentation 不过期。
- `RemoteBusinessClient` 使用 0.5 秒起、最高 30 秒的指数退避；同 `clientInstanceId` 在服务器租约内恢复同一角色槽。
- 识别页重复出现不会重复启动 source/receiver 连接；退出页会取消尚未完成的连接，并在关闭 WebSocket 前尝试发送 `client.goodbye`，及时释放服务器角色槽。接收端业务连接断开或桌面端转为非 online 时停止本机待播内容，投递若在状态变化后抵达则确认并丢弃，不在桌面离线时补播。
- LiveKit SDK 负责短时媒体网络重连；重连后若本地发布轨道没有恢复，或房间仍在线但 publication 已失去 track，手机1会清理旧发布并重新创建 buffer track。该恢复只重建视频发送，不重启识别状态机。
- 手机1、手机2、桌面端可按任意顺序加入同一 `(region, serial)` 等待房间。welcome 给出三角色完整三态，后续 presence 用 online/reconnecting/offline 增量更新；reconnecting 不能当作在线投递或可用视频。
- HTTP admission、媒体令牌和首条 WebSocket welcome 均有10秒超时；已连会话用15秒 ping、45秒无 pong 主动重连。
- 服务器会在 pong 周期刷新短期 resume/media Bearer；过期恢复令牌会被丢弃并自动进行一次无 token admission，避免长时前台运行在 TTL 后失去视频。
- `sourceSessionId` 变化表示 LiveKit 房间也变化；手机1、手机2和桌面端必须断开旧媒体 room，再用当前业务连接的新媒体令牌加入。相同 session 内的网络抖动不重建房间。
- 手机2收到 delivery 后立即发送累计 ACK；服务器在 receiver 租约期内重发未确认命令，手机2以 `deliverySeq` 去重。新手机2首次连接仍只静默同步当前 UI。

## 5. 手机2播放规则

服务器 `receiver.delivery` 已分为 automatic/manual：

- manual：新命令立即清空当前和待播内容。
- automatic 且 operationId 变化：新识别操作立即抢占旧操作。
- automatic 且 operationId 相同：严格排队，因此 success 提示结束后才播放同一结果的 TTS。

presentation 的 UI 在收到命令时立即刷新，不等待音频结束。自动转发关闭时服务器不向手机2发送任何 automatic delivery，所以 UI、牌组、提示音、报牌均不更新；桌面手动命令仍可发送。

手机2只有在桌面端 online 时才接收新消息。桌面离线或 reconnecting 时，手机1结果仍保存到桌面历史，但不转发手机2；桌面断线会清除待发和未确认 automatic，恢复后不补播离线期间结果。

桌面可设置 0...60 秒的切牌结果延时，默认 0。服务器只延迟包含 `cutCard` 的 automatic presentation，手机2的结果 UI 与该结果播报同时延后；开始/成功/失败提示及无切牌结果保持即时。手动文字命令支持男声/女声、重复次数与语速。

手机2进入接收会话时临时禁止系统自动锁屏，退出会话恢复进入前的 idle timer 状态；不申请后台相机、后台音频或后台持续联网能力。

接收端连接页提供独立功能设置：可启停提示音/结果播报，选择扬声器或耳机，调整本地音量与语速，并设置视频/黑屏交互、时间模式和黑屏亮度。连接后的会话右上角只有断开按钮。设置保存到接收端专用 UserDefaults 键，只影响 receiver 音频/显示，不改写识别端方案或桌面转发配置。接收会话不提供结果页或常驻显示模式切换按钮；与原识别页一致，屏幕显示设为“无”时双击无动作，启用黑屏模式后从实时画面双击进入黑屏，配置时间模式时黑屏内显示日期和时间，再次双击返回实时画面。黑屏/时间伪装期间隐藏连接状态、导航栏与断开入口，仅保留全屏黑色或时间内容。

接收端连接任务由整个接收页面持有，返回角色选择页时会取消未完成的 admission 并主动释放 receiver 槽；连接取消不进入失败状态。业务断开由接收页面统一负责，内部会话视图因状态刷新消失时不会误断连接。主动停止或切换 LiveKit 会话不显示“画面中断”也不安排重试，只有仍需要视频时的意外断开才进入重试。

手机2首次连接、重连或自动转发从关闭变为开启时，服务器会补发“当前 presentation”的静默快照（播放列表为空）以恢复 UI，但不会重播旧声音；自动转发保持关闭时不做这次同步。

## 6. 区域配置

两个区域各只使用一个 Info.plist 参数：`LifeCatcherRemoteCNIP` 与 `LifeCatcherRemoteSGIP`。业务入口统一派生为 `http://IP:8080`；`0.0.0.0` 表示该区域未配置并禁止连接。WebSocket 与媒体地址仍由当前区域服务器返回，客户端不自行拼接额外地址。

当前固定 IP 方案使用明文 HTTP/WS，Info.plist 暂时允许任意网络加载，只适用于测试阶段。绑定域名并启用可信 TLS 后，应改回 HTTPS/WSS 并移除该放宽项。

## 7. 修改与验证

协议字段变化必须同步本仓库 `RemoteProtocol.swift`、`../lifeCatcher-server/src/protocol/schema.ts`、`../lifeCatcher-desktop/src/shared/protocol.ts`，以及三端协议文档和测试样例。

最低验证：

```bash
xcodebuild -project lifeCatcher.xcodeproj -scheme lifeCatcher -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

相机旁路、720p 帧率、前后台、远程模式手机1扬声器/蓝牙静音、本地模式结果和音频恢复、手机2音频和网络切换仍必须真机验证。固定 IP 在线不代表 UDP/TURN 媒体可用，必须分别验证业务与视频路径。

## 8. 帧率测试

功能设置 → 帧率测试。独立会话使用前置 120 / 后置 240 FPS，优先选择 1920 宽的受支持格式；不支持时提示设备实际最大值，不伪报目标帧率。当前测试分类器为 `cls_20260917_texas`，全帧缩放到 320×320，仅测量 CLS 负载，不运行 ROI 搜索、洗牌状态机和规则报法。与正式识别一致，每个相机回调都把一次推理提交到并发队列，不因已有推理而跳帧；页面分别显示相机采集 FPS、成功完成推理 FPS 和当前待完成帧数，用于观察吞吐是否追上输入以及是否产生积压。

远程模式测试通过独立业务客户端取得媒体令牌，并按远程设置选择的 720p/1080p、30/60 FPS 和低功耗码率选项主动发布视频，无需接收端先请求画面，不发送识别结果和提示事件、不读取或清空 outbox，也不修改当前本地/远程模式。分辨率、送帧率和码率上限只作用于 LiveKit 旁路，不改变相机、CLS、Detect、ROI 或识别状态机帧率。相机回调在原队列内提取并持有 `CVPixelBuffer` 后才交给 MainActor 和媒体缩放队列，不跨任务传递 `CMSampleBuffer`。本地模式完全不创建业务客户端、LiveKit publisher 或网络计时器，只显示相机采集和 CLS 完成帧率。LiveKit 送帧统计计数实际交给 BufferCapturer 的图像；编码 FPS 来自 SDK outbound RTP 统计，缺失显示“暂无统计”，均不代表接收端实际显示 FPS。没有订阅者时 SDK 可能暂停编码；实测网络编码吞吐应同时打开接收端画面。

页面用明确的 appear/disappear 生命周期启动和停止；返回、后台或切换摄像头会停止旧相机、定时器和网络会话，异步任务使用运行标识屏蔽过期回调。主动退出造成的 admission 取消属于正常清理，不记录为远端错误。重新开始按钮可在回到前台或失败后重试。真实 120/240 FPS、发热降频与编码负载须真机测量。

全局远程 toast 的可观察状态只归 `RemoteToastHost` 持有，App 根节点不直接观察它。否则连接状态 toast 会使承载旧式 `NavigationView` 的根内容整体失效并丢失导航栈，表现为测试页闪回角色选择页，随后页面清理逻辑主动取消 admission。
