# lifeCatcher 智能体工作入口

本文件是智能体进入仓库后的第一层索引。先阅读本页，再按任务类型读取 `docs/agent/` 中的专题文档；不要从 4,000～6,000 行的大文件盲目开始。

## 项目一句话定义

这是一个 iOS 17.6+ SwiftUI 应用，包含两条视觉链路：

1. 普通采集链路：用 `cls_main` 对相机画面分类，将截图按分类写入本地历史。
2. 核心规则链路：用 Core ML 检测/分类牌面，跨帧还原牌序，按用户保存的方案进入 19 套牌类规则和报法引擎，再以语音与结果页反馈。

源码中的 `singlefeature` 实际表示“单张牌”，`RC` 表示规则引擎中的玩家/位置。修改时沿用现有命名，除非任务明确要求系统性重构。

## 必读顺序

1. [文档总索引](docs/agent/README.md)
2. [系统架构](docs/agent/architecture.md)
3. 根据任务选择专题：
   - 相机、Core ML、识别顺序：`vision-pipeline.md`
   - 玩法、发牌、胜负、报法：`rule-engine.md` 与 `dataset-catalog.md`
   - 方案设置、JSON、UserDefaults、Keychain：`configuration-and-storage.md`
   - 页面、授权、历史采集：`ui-auth-and-collection.md`
   - 远程识别、接收端、WebRTC：`remote-system.md` 与 `docs/protocol/remote-v1.md`
   - 寻找具体文件/符号：`file-index.md`
   - 下载远端模型、文件处理服务器：`model-server.md`
   - 实施修改：`change-playbook.md`
   - 名词、编码、不变量、已知风险：`glossary-and-invariants.md`

## 修改前硬性检查

- 先确定改动属于“采集链路”还是“核心规则链路”，二者 ViewModel、模型和持久化完全不同。
- 涉及 `DatasetRule.args`、`rankRules`、`suitRanks` 时，必须同时核对：预设生成、设置页读写、对应数据集 `FindWinner`/`evalHand`、运行时加载。
- 涉及新玩法时，必须同步所有以 `DatasetIndex` 为键的 19 路映射；完整清单见 `dataset-catalog.md`。
- 涉及报法时，不能只加名称；还要同步 `ReportClass` 注册、`DatasetReporter` 行为、`reportStringGenerator` 输出以及特殊报法集合。
- `DatasetRule.rcNum` 保存的是 `Rule.rcNum` 的索引，不是实际人数。实际人数是 `Rule.rcNum[rule.rcNum]`。
- `shuffleMode`、`cutMode`、`reportSetting`、`specialCard` 都是双槽数组：索引 0 对应洗牌，索引 1 对应拨牌。
- `shuffleMode[0]` 的稳定编码为 0 不洗、1 普通洗牌、2 横洗；横洗仍是双目标洗牌，但不再反转方向。ROI 形变、两堆牌的排序、姿态、距离和移动判断全部取 `isCameraHorizon`。普通模式分类仍按横竖选择 `cls_*_h`/`cls_*_v`；横洗检测用 `detect_20260915_texas`，横竖分类共用 `cls_20260915_texas`。横洗入口单框面积×70，双框沿轴外边缘跨度×1.5、两中心中点，横屏16:9/竖屏9:16；洗牌中缺侧保持双框 ROI 至原退出条件。
- 牌编码是稳定协议：`0...51` 为四花色 52 张，`53` 小王，`54` 大王，`52` 是模型侧 none，并在识别后映射为 `54`。不要擅自重排。
- 当前没有测试 target。至少运行 `xcodebuild` 的通用 iOS 构建；视觉/相机行为仍需真机验证。
- 离线视频回放使用 `tools/video-replay/` 的独立 macOS Swift Package；它不属于 iOS target，也不得反向读取或改写手机端配置。
- 不要顺手修改硬编码服务地址、加密兼容逻辑、模型阈值或帧率。它们都是高耦合行为，应作为独立任务处理。

## 推荐验证命令

```bash
xcodebuild -project lifeCatcher.xcodeproj -scheme lifeCatcher -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

若只改文档，至少检查链接、路径与代码符号仍存在：

```bash
rg --files docs/agent
rg 'class CurrentVisionObjectRecognitionViewModel|static func DatasetReporter|struct DatasetRule' lifeCatcher
```

离线验证扑克牌视频时见 `tools/video-replay/README.md`，入口示例：

```bash
swift run -c release --package-path tools/video-replay lifecatcher-video-replay --video /absolute/path/cards.mp4 --fps 120
```

## 文档维护约定

代码改动若改变模块职责、主调用链、持久化结构、枚举/整数协议或新增数据集，必须在同一改动中更新对应 `docs/agent/` 文档。文档描述以代码当前行为为准；对明显缺陷使用“已知风险”措辞，不把期望行为写成现状。
