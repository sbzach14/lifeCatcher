# 功能修改手册

## 1. 通用工作流

1. 用 `file-index.md` 找主入口与所有重复实现。
2. 用 `rg` 沿字段/ID/符号全局追踪，不只看调用点。
3. 写下改动前不变量：牌序、索引空间、数组长度、持久化兼容、线程归属。
4. 先改领域/底层，再改编排和 UI；每层保持统一接口。
5. 更新本目录对应文档。
6. 运行无签名通用 iOS 构建。
7. 对硬件或规则变更执行针对性手工/真机验证。

## 2. 修改现有玩法的牌型规则

影响面：

1. 对应 `*Rule` 中选项字典、`setting`、`rankRules`、`ruleInfo`。
2. `LoadAllPresetRules` 里的 positional `args` 和默认 rank rule 顺序。
3. `*HandAnalyst.evalHand` 与对应 `eval_*`。
4. `FindWinner` 如何创建 `DatasetReturnRCInfo`。
5. 平局时 `rcRank` 是否保持完全相同。
6. 结果页牌型文字和报法对子/平点统计。

验证至少包含新旧牌型、同型比较、平局、花色开关、王/A 边界、牌数不足。

## 3. 新增玩法

按 `dataset-catalog.md` 的 11 点清单完成所有分发表。优先复制结构最相近的数据集，但不要复制其 magic args 后只改名称。

建议先写纯规则测试（即使仓库当前无测试 target，也可以新建），输入固定牌编码并断言：

- `getAllSingleFeatureIndex`；
- `getMinSingleFeatureNum`；
- `FindWinner` 的玩家顺序/牌型/剩余牌；
- 自定义发牌与公牌；
- reportID 0/1 的最大最小基本输出。

## 4. 新增报法

按 `rule-engine.md` 的完整报法清单逐项实现。最容易漏的是：

- 名称存在但 `ReportClass` 未注册；
- 搜索结果有了但 `reportStringGenerator` 无 case；
- 需要视觉看手/看色，却未加入 special report 集合；
- 下一轮应复用变换后的牌，却写错 `returnSingleFeatureArray`/`leftSingleFeatures`；
- 多轮时未重置 `ReportManager.recordedMaxIndex` 或 `isFirstReport`。

## 5. 增加/修改方案字段

必须同步：

1. `DatasetRule` 定义、init、Codable 迁移。
2. `SettingRecordConfigView` 的 state、SetUpAll、saveData、UI。
3. leishen 设置页同一组位置。
4. `CurrentVisionObjectRecognitionViewModel` 的运行时属性、loadSaveRule、saveData。
5. 若属于全局相机设置，还要同步 `createConfigJSON`、`SettingViewModel` 和当前识别 VM 的两份 updateConfigJSON。
6. 文档与旧数据迁移测试。

## 6. 更换 Core ML 模型

检查：

- Xcode target membership 与生成类名；
- 输入尺寸、pixel format、方向；
- feature 名、shape、类别数与标签顺序；
- 52/53/54 映射；
- 检测框坐标约定；
- confidence/IOU 阈值；
- 横/竖、洗/拨模型是否成套；
- `createRecordHistoryJSON` 的 label 初始化（若是 `cls_main`）；
- 真机帧率、发热、内存与相机曝光。

不要把新模型效果问题与大规模状态机重构合成一个改动。

## 7. 修复识别顺序、漏牌或重复牌

先定位层级：

1. 模型输出是否已经错：在 `getSingleFeature` 前后观察候选、box、confidence。
2. ROI/方向是否错：检查 `computeTargetArea`、`updateTargetArea` 与横纵排序。
3. 状态机是否错过开始/结束：检查 stateCounter/shuffleStartCounter/shuffleResetCounter。
4. 跨帧链是否错：检查 nodeType、有效 begin/end、Laplacian 比值。
5. 最终去重是否丢牌：检查 `InsertCard` confidence 与 allowed set。

调试输出应以结构化、可关闭方式加入；当前每帧已有大量 print，继续增加会影响高帧率时序。

## 8. 修改登录/授权

先抽取或同时修改重复请求：`MainView.AutoLogin`、`LoginView.loginUser`、注册页、AuthManager 激活、AuthTest 管理接口。

安全要求：

- 不在日志打印 token、authkey、密文原文或密码；
- UI state 回主线程；
- 校验 HTTP status、JSON shape、解密字段数量；
- 异步函数使用 completion/async 返回，不同步伪返回；
- 若切 HTTPS/新域名，同步 ATS、服务端证书与错误提示；
- 保持旧授权 key 兼容，除非有明确迁移方案。

## 9. 修改历史采集

同步考虑：模型 labels、首次/已有 `recordHistory.json` schema、图片命名冲突、原子写入、删除、悬空文件、无分类结果时保存、HistoryView 刷新。

普通采集链路不要引入 `DatasetRule`，除非产品明确要求两条业务线合并。

## 10. 构建与验证

基础命令：

```bash
xcodebuild \
  -project lifeCatcher.xcodeproj \
  -scheme lifeCatcher \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

按改动追加：

- 规则：固定牌数组的自动化断言。
- 视觉：真机相机矩阵，模拟器不能验证帧率/焦距/音量键。
- 存储：全新安装、已有旧 config、已有旧 DatasetRule。
- 授权：离线、超时、畸形响应、正式/测试/未激活。
- UI：中英文、空方案、删除最后方案、快速进入/退出相机。

视觉视频回归可先在 Mac 上运行独立工具：

```bash
swift test --package-path tools/video-replay
swift run -c release --package-path tools/video-replay lifecatcher-video-replay \
  --video /absolute/path/cards.mp4 --fps 120 --mode both --orientation horizontal \
  --frames-output /absolute/path/annotated-frames
```

离线回放只能锁定模型、ROI、状态机和牌序聚合行为，不能替代曝光、焦距、真实 120/240 FPS 吞吐及硬件交互的真机验证。

## 11. 适合后续重构但不应顺手完成的事项

- 用 enum/struct 替代 state 字符串、magic number 与 `[Int] args`。
- 统一 `Dataset` protocol 和数据集注册表，消除三份 19 路 switch。
- 将相机/推理/帧聚合/规则/TTS 拆成服务或 actor。
- 统一网络客户端和授权状态机。
- 为配置增加 schema version 与迁移。
- 建立规则单元测试和视觉录制帧回放测试。

这些改造价值高，但会大幅扩大回归面；应先用测试锁定现有行为。
