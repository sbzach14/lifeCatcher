# lifeCatcher 面向智能体的层级化文档

这套文档的目标不是替代源码，而是让后续智能体先建立稳定的系统模型，再精确下钻到需要修改的符号。文档按“全局 → 链路 → 子系统 → 文件 → 修改方法”分层。

## 层级 0：仓库约束

- [`AGENTS.md`](../../AGENTS.md)：任务路由、必须保持的不变量、最低验证要求。

## 层级 1：全局模型

- [`architecture.md`](architecture.md)：系统边界、分层、启动过程、依赖方向和两条业务主线。
- [`glossary-and-invariants.md`](glossary-and-invariants.md)：代码术语、整数编码、跨模块协议、风险点。

任何功能修改都应先读这两篇。

## 层级 2：核心运行链路

- [`runtime-flows.md`](runtime-flows.md)：从页面操作到识别、规则计算、语音/结果展示的端到端时序。
- [`vision-pipeline.md`](vision-pipeline.md)：AVCapture、模型选择、ROI、状态机、跨帧结果归并、清晰度计算。
- [`rule-engine.md`](rule-engine.md)：方案、发牌、数据集、切牌/看牌、报法、跨轮计算的数据流。
- [`dataset-catalog.md`](dataset-catalog.md)：19 个 `DatasetIndex` 的稳定映射与每个数据集的实现入口。

## 层级 3：外围子系统

- [`configuration-and-storage.md`](configuration-and-storage.md)：`DatasetRule`、预设、UserDefaults、Documents JSON、Keychain、资源文件。
- [`ui-auth-and-collection.md`](ui-auth-and-collection.md)：页面导航、普通采集历史、登录/注册/激活、音量键控制。
- [`remote-system.md`](remote-system.md)：手机1/手机2、业务协议、WebRTC 视频、重连、顺序与播放抢占。
- [`remote-implementation-audit.md`](remote-implementation-audit.md)：远程链路已关闭风险、验证证据和仅剩真机/部署性能项。

## 层级 4：查找与修改

- [`file-index.md`](file-index.md)：按目录、职责和关键符号建立的源码索引。
- [`change-playbook.md`](change-playbook.md)：常见需求的影响面、修改顺序和验证清单。

## 快速任务路由

| 任务 | 首先读取 | 主要代码 |
|---|---|---|
| 调整识别阈值、ROI、帧率 | `vision-pipeline.md` | `CurrentVisionObjectRecognitionViewModel.swift` |
| 更换/增加 Core ML 模型 | `vision-pipeline.md`、`configuration-and-storage.md` | `Resources/*.mlmodel`、当前/普通识别 ViewModel |
| 修复牌序或漏牌/重复牌 | `vision-pipeline.md` | `getSingleFeature`、`handleDetecResultList` |
| 在 Mac 上用视频回放视觉链路 | `vision-pipeline.md`、`../../tools/video-replay/README.md` | `tools/video-replay/` |
| 新增玩法/修改牌型大小 | `dataset-catalog.md`、`rule-engine.md` | 对应 `DatasetPkg/*.swift` |
| 新增报法 | `rule-engine.md` | `AllBaseSettingArgs.swift`、`ExtraArgsClass.swift` |
| 修改方案字段或默认值 | `configuration-and-storage.md` | `DatasetRule`、两个配置页、运行时 `loadSaveRule` |
| 修改相机设置 | `configuration-and-storage.md`、`vision-pipeline.md` | `SettingViewModel`、当前识别 ViewModel、`config.json` |
| 修改采集历史 | `ui-auth-and-collection.md` | `OriginVisionObjectRecognitionViewModel.swift`、History Views |
| 修改登录/授权 | `ui-auth-and-collection.md` | `MainView.swift`、`LoginView.swift`、`AManager.swift` |
| 修改音量键行为 | `ui-auth-and-collection.md`、`runtime-flows.md` | `ButtonViewController`、`handleSingleTap`/`handleDoubleTap` |
| 修改远程连接、接收端或桌面协议 | `remote-system.md`、`../protocol/remote-v1.md` | `lifeCatcher/Remote/`、两个同级仓库 |

## 事实来源优先级

1. 当前编译进 target 的 Swift 源码与 Xcode project 配置。
2. 本目录文档。
3. 代码注释和 deprecated 文件。

当文档与代码冲突时，以代码为准并更新文档。`Deprecated*`、`SettingRecordConfigView_leishen.swift` 等文件仍可能通过导航可达，不能仅凭文件名判断为死代码。
