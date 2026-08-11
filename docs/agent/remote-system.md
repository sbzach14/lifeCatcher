# 远程识别子系统（智能体入口）

## 1. 边界与不变量

远程功能只属于核心规则链路，不属于普通 `cls_main` 采集链路。手机角色在进入“幻影”后选择：

- 识别端（手机1）：继续使用原核心识别链路，进入识别页即建立业务连接，不提供关闭开关。识别端固定本机静音、时间模式为“无”，且不提供本地结果页入口。
- 接收端（手机2）：只建立网络、视频、结果展示和播放对象；严禁实例化 `CurrentVisionObjectRecognitionViewModel`，因此不会加载六个 Core ML 模型、创建 `AVCaptureSession` 或运行规则引擎。

必须保持以下不变量：

1. 识别、牌序恢复、`ClassifierSettingArgs.selectDataset` 和 `ReportManager` 的既有调用顺序不因网络成功或失败改变；识别端的所有本地提示音与 TTS 则固定禁用。
2. 网络只监听三个既有输出边界：`speakText(input: Int)` 的开始/成功/失败、最终 `speakText(input:[[SpeakResultStruct]],...)`、`captureOutput` 的原始帧旁路。
3. 业务事件写入持久 outbox 后异步发送；网络异常不能阻塞识别线程。
4. 大陆与新加坡是完全隔离的域和会话空间。outbox 项记录 region + serial，禁止切换区域后跨区补发。
5. 权限模型仅为“知道当前序列号即可连接”，不要在本子系统自行增加账号、配对码或设备证明。
6. 同一识别端在一个区域最多一个手机接收端和一个桌面端。
7. 视频固定 1280×720、30fps、约 1.8Mbps；只有接收端或桌面端当前需要画面时才发布。

## 2. 源码分层

| 文件 | 职责 |
|---|---|
| `RemoteProtocol.swift` | v1 DTO、可辨识 union 编解码；必须与服务器和桌面协议同步 |
| `RemoteServerProfile.swift` | 两个隔离区域、从 Info.plist 各读取一个固定 IPv4、独立 UserDefaults 键 |
| `RemoteDiagnostics.swift` | 统一错误翻译、终端日志与全局 toast；不记录序列号或 token |
| `RemoteBusinessClient.swift` | HTTP admission、WebSocket、10秒建连超时、恢复令牌、带抖动指数退避、媒体令牌 |
| `RemoteOutboxStore.swift` | 识别端未确认事件的 Application Support 原子 JSON outbox |
| `RemoteSourceBridge.swift` | 操作 ID、严格单飞序号、ACK 去重、视频需求控制 |
| `RemoteVideoPublisher.swift` | 1080p 相机旁路缩放为 720p30，并以 LiveKit buffer track 发布 |
| `RemoteVideoSubscriber.swift` | 手机2 LiveKit 订阅与 UIKit `VideoView` SwiftUI bridge |
| `RemotePresentationBuilder.swift` | 把已计算、已排序的本地结果映射为纯展示快照 |
| `RemoteReceiverViewModel.swift` | 手机2业务状态、delivery 去重、画面需求、时间覆盖 |
| `RemoteReceiverAudioCoordinator.swift` | 两类抢占规则和同操作串行播放 |
| `RemoteResultContentView.swift` | 不依赖识别 ViewModel 的纯结果 UI；手机1/手机2复用 |
| `RemoteReceiverViews.swift` | 区域+序列号连接页和视频/黑屏/时间/结果四种展示模式 |

## 3. 识别端接入点

### 提示音

`CurrentVisionObjectRecognitionViewModel.speakText(input: Int)` 先建立远程事件：0/1/2 映射 start/success/failure，然后由远程分支固定策略拦截本地播放。因此连接本机耳机也不会听到识别端提示音。

### 最终结果

`computeWinnerRC` 仍先完成数据集计算、牌数组回写、特殊玩法手牌排序，再调用原 `speakText(input:[[SpeakResultStruct]],...)`。该函数不在识别端执行本地 TTS，时间模式固定为 0；它仍使用同一份牌序、切牌、`singleResultList`、`reportResult`、语速和重复次数构建 `RemotePresentationSnapshot`。不传 `shuffleOrRiffle`、当前轮索引、方案或其他规则设置。

### 视频

`captureOutput` 从同一个 `CMSampleBuffer` 旁路给桥接层，随后原检测仍读取 pixel buffer。不要重新引入 `CMSampleBufferInvalidate`；异步消费者依赖 Core Foundation 对 pixel buffer 的引用生命周期。媒体层在主线程先限流/单飞，再在独立 utility 队列缩放，识别队列不等待它。

## 4. 顺序、去重和重连

- `operationId`：一次识别尝试。start 开启新操作；后续 success/failure/presentation 归入当前操作。
- `eventId`：业务幂等键，写入 outbox 时生成，重连不改变。
- `sourceSessionId + sourceEventSeq`：服务器会话内严格连续序号。服务器 welcome 返回 `nextSourceEventSeq`。
- `RemoteSourceBridge` 同时只发送一个未 ACK 事件，避免多个 `Task` 乱序。
- ACK accepted/duplicate 都以服务器返回的最后序号推进；“服务器已收、客户端未收 ACK”时进程终止也不会造成序号缺口。
- 永久协议错误只隔离并删除对应远程 outbox 项，避免坏快照阻塞后续远程事件；会话或序号错误不丢事件，而是重连后按新 welcome 重派。两种路径都不回调或中断本地识别链。
- start/success/failure 有 5 秒有效期；过期提示从 outbox 清理。presentation 不过期。
- `RemoteBusinessClient` 使用 0.5 秒起、最高 30 秒的指数退避；同 `clientInstanceId` 在服务器租约内恢复同一角色槽。
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

手机2进入接收会话时临时禁止系统自动锁屏，退出会话恢复进入前的 idle timer 状态；不申请后台相机、后台音频或后台持续联网能力。

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

相机旁路、720p 帧率、前后台、扬声器/蓝牙和网络切换仍必须真机验证。固定 IP 在线不代表 UDP/TURN 媒体可用，必须分别验证业务与视频路径。
