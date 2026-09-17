# 术语、编码、不变量与风险

## 1. 术语映射

| 源码术语 | 实际含义 |
|---|---|
| `singlefeature` / `SingleFeature` | 牌 / 一张牌 |
| `singlefeatureIndex` | 稳定牌编码 |
| `RC` | 玩家、门或位置；具体文案依玩法而异 |
| `rcNum` | 人数；在 `DatasetRule` 中是人数选项索引 |
| `Dataset` | 一套牌类玩法及胜负规则，不是机器学习数据集 |
| `Rule` | 玩法元数据与可配置项 |
| `rankRules` | 牌型求值规则 ID 列表，顺序可能有意义 |
| `suitRules` | 花色比较顺序 |
| `report` / 报法 | 基于胜负结果搜索并语音输出的策略 |
| `color` / 打色 | 由某张牌点数/花色驱动的牌堆变换/报法条件 |
| `shuffle` / 洗牌 | 视觉上双侧同时过牌 |
| `riffle` / 拨牌 | 视觉上单侧过牌；不是英文 riffle shuffle 的通常含义 |
| `cutStruct` | 一次看底/看顶/看色/看手所携带的牌与模式 |
| `leftSingleFeatures` | 一轮发牌/搜索后剩余牌，下一轮输入 |
| `usedSingleFeatures` | 当前轮已消耗牌，用于识别任意牌触发下一轮 |

## 2. 必须保持的不变量

### 牌编码

- 0...51 的顺序不可改。
- 53/54 是大小王。
- -1 只用于视觉缺失节点。
- 52 在不同模型/显示字典中存在 none 语义，进入规则前必须处理。

### 方案

- `DatasetType` 永久稳定。
- 双槽数组长度至少 2。
- `rcNum` 必须在当前 `Rule.rcNum.indices` 内。
- `positionSetting < actualRcNum`。
- `singlefeatureToUse` 应与当前预设/模型类别兼容。
- `minSingleFeatureNum` 应等于当前发牌配置的真实最小消耗量。

### 视觉

- `getSingleFeature` 返回恰好两个节点。
- coordinates 为中心点式归一化 box。
- `detectResultList` 的 key 是帧 taskIndex，可排序。
- `singlefeatureArray` 的顺序代表牌序，不是集合。

### 规则

- 所有 Dataset 都能通过统一 `FindWinner` 签名调度。
- 返回的 left deck 必须与实际消费一致。
- reportID 必须存在于 `allPreSetReportRules` 才能完整计算。
- `SpeakResultStruct.voiceType` 0 男声、其他通常女声。

## 3. Magic number 快表

### `cutMode`（方案 UI）

- 0 无
- 1 看底
- 2 看顶
- 3 连续看底
- 4 看手牌
- 5 连续看顶

### `cutStruct.cutMode`（运行协议）

- 0 看底
- 1 看顶
- 2 看色
- 3 连续看手
- 4 按位置对齐看手

### `specialCard`

- 0 无
- 1 看手牌
- 2 看色牌

### `shuffleMode`

- 槽 0：0 不洗、1 普通洗牌、2 横洗
- 槽 1：0 不拨、1 拨到顶、2 拨中间

横洗仍走双目标洗牌业务链；检测用 `detect_20260915_texas`，横竖分类共用 `cls_20260917_texas`。ROI、节点排序、姿态、距离和移动判断仍取 `isCameraHorizon`，不按牌角姿态换轴。横洗及其洗牌来源切牌使用独立 `TargetAreaScenario`：单框入口面积=框面积×70；双框以两中心的中点为中心，沿手机排列轴的外边缘总跨度×1.5，横屏 16:9、竖屏 9:16。边界只平移或灰填充，不缩小 ROI；无法包含检测框则按无效 ROI 处理，不增加旧的 90% 扩展。搜索/洗牌仅双框更新，零/单框保持最近 ROI，直到现有重置/退出条件；显式拨牌仍保留单目标跟踪。必须稳定双框才能进入 `shuffle`，切牌仍须唯一单框及原置信度条件。横洗姿态跨轴门槛保留 `1.5×meanCrossBoxSize`，普通洗牌保留 `0.5×`。拨牌来源切牌保留 standard 几何，普通洗牌/拨牌模型、ROI、阈值及报法链路不随本次横洗变更调整。

### `DetectionResult.nodeType`

- 0 未归类
- 1 链起始
- 2 链结束
- 3 链中
- 4 孤立补牌候选
- 5 none/排除

## 4. 高风险实现点

- Core ML 模型均 `try!` 初始化；资源/类型不匹配会在 ViewModel 创建时崩溃。
- JSON 与 UserDefaults 解码失败往往被吞掉，随后强制解包或空数组下标才崩。
- `SettingRecordConfigView.SetUpAll` 默认把 `rcNum = 2` 当索引，要求每个 Rule 至少三个可选人数。
- `OriginVisionObjectRecognitionViewModel.recordScreen` 假定已有分类结果。
- `AuthManager.timeCheck` 与 `activeAccount` 将异步结果同步返回。
- 自动登录在异步回调中直接修改 SwiftUI `@State`，不总是显式切主线程。
- 网络响应解密后直接访问 `stringArray[0]`/`[1]`。
- 当前视觉推理并发执行，共享状态没有完整同步。
- `ReportManager` 使用静态可变状态，多个识别实例不隔离。
- `TimeLimitations` 只检查 `now-active <= 365 days`，未来日期也会通过负数条件。
- Info.plist 允许任意 HTTP；服务地址硬编码且请求无统一超时/错误模型。
- 私有音量通知不是稳定 API。
- 页面和工具中存在重复逻辑，修一处不代表全局生效。

## 5. Deprecated 不等于不可达

- `DeprecatedMainView` 是当前授权后进入方案设置的实际入口。
- `DeprecatedInfoView` 从该页面可达。
- `DeprecatedComponentView.swift` 的 `TurnSettingView`、`NumRangeSettingView` 被当前配置页使用。
- `SettingRecordConfigView_leishen.swift` 被 configType 1 使用。

真正删除前必须先全局 `rg` 所有符号引用和 Xcode target membership。

## 6. 文档中的“当前行为”原则

遇到看似错误的代码，文档记录实际行为与风险，不自动推断产品意图。例如：History 按钮路由、52→54 映射、本地授权同步返回、黑屏时间编码都应按代码现状理解。功能修复时再由任务明确目标行为。
