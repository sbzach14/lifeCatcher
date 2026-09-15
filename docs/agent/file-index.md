# 源码文件索引

## App

| 文件 | 关键符号 | 职责 |
|---|---|---|
| `lifeCatcher/App/MyApp.swift` | `MyApp`, `initFile` | 入口、全局 UI 外观、网络时间、规则/文件初始化；不再启动即请求相机 |
| `lifeCatcher/App/AppDelegate.swift` | `AppDelegate` | 临时模型目录；历史模型解密注释 |
| `lifeCatcher/App/Info.plist` | ATS/权限/全屏设置 | Bundle 运行配置 |
| `lifeCatcher/lifeCatcher.entitlements` | app groups 空数组 | 签名 entitlement |

## 核心 ViewModels

| 文件 | 关键符号/区段 | 职责 |
|---|---|---|
| `ViewModels/CurrentVisionObjectRecognitionViewModel.swift` | `initialize`, `setupAVCapture` | 核心识别生命周期和相机 |
| 同上 | `captureOutput`, `processImageOrigin` | 每帧推理与字符串状态机 |
| 同上 | `getSingleFeature` | 模型输出标准化、过滤、模糊度 |
| 同上 | `handleDetecResultList` | 跨帧牌序还原 |
| 同上 | `computeWinnerRC`, `computeNextRound` | 规则入口与轮次 |
| 同上 | `handleSingleTap`, `handleDoubleTap` | 音量键业务事件 |
| 同上 | `loadSaveRule`, `saveData` | 运行时方案展开/覆盖 |
| 同上 | `DetectionResult`, `DetectionState`, `SpeechPerformer` | 视觉与语音辅助类型 |
| `ViewModels/OriginVisionObjectRecognitionViewModel.swift` | `setupVision`, `recordScreen` | 普通采集分类、图片历史 |
| `ViewModels/AllSettingViewModel.swift` | `SettingViewModel` | config.json 映射与授权信息显示 |
| `ViewModels/AppViewModel.swift` | `AppViewModel` | 登录页面状态与验证码 |
| `ViewModels/RecordViewModel.swift` | `RecordViewModel` | 历史 JSON 薄封装 |

## 关键 Views

| 文件 | 关键符号 | 职责 |
|---|---|---|
| `Views/MainView.swift` | `MainMenuView`, `AutoLogin`, `DeprecatedMainView` | 根导航、自动登录、核心入口 |
| `Views/CurrentObjectRegView.swift` | `CurrentVisionObjectRecognitionView` | 核心相机/黑屏/结果容器 |
| 同上 | `ButtonViewController` | 系统音量键/耳机路由桥接 |
| `Views/SettingRecordView.swift` | `SettingRecordView` | 方案列表与删除 |
| `Views/SettingRecordConfigView.swift` | `generalRuleSetting`, `SettingRecordConfigView` | 完整方案设置/保存/启动 |
| `Views/SettingRecordConfigView_leishen.swift` | `SettingRecordConfigView_leishen` | 简化方案设置 |
| `Views/ReportSettingView.swift` | `ReportSettingView` | 报法筛选选择 |
| `Views/UsedFeatureSelectView.swift` | `UsedFeatureSelectView` | 可用牌筛选 |
| `Views/DeprecatedComponentView.swift` | `TurnSettingView`, `NumRangeSettingView` | 当前仍在用的自定义发牌/范围设置 |
| `Views/ShowResultView.swift` | `ShowResultView` | 结构化规则结果展示 |
| `Views/OriginObjectRegView.swift` | `OriginVisionObjectRecognitionView` | 普通采集相机页 |
| `Views/HistoryView.swift` | `HistoryView` | 分类历史索引 |
| `Views/HistoryItemView.swift` | `HistoryItemView` | 历史图片详情 |
| `Views/LoginView.swift` | `LoginView`, `loginUser`, `registerUser` | 登录/注册/激活 UI |
| `Views/RegisterView.swift` | `RegisterView` | 另一份注册页面 |
| `Views/InformationView.swift` | `InfoView`, `DeprecatedInfoView`, `FunctionSetting` | 信息与全局功能设置 |
| `Views/AuthTestView.swift` | `AuthTestView` | 管理 API 测试工具，主入口已注释 |
| `Views/CustomUIComponent.swift` | toggle/search/icon/loading | 共用 SwiftUI 样式 |
| `Views/CameraImageView.swift` | `CameraImageView` | CGImage 预览 |

## UtilPkg

| 文件 | 关键符号 | 职责 |
|---|---|---|
| `UtilPkg/AllBaseSettingArgs.swift` | `ClassifierSettingArgs` | 牌编码表、19 数据集注册、规则入口 |
| 同上 | `DetectSettingArgs` | 方案持久化、报法/玩法预设注册 |
| 同上 | `Rule`, `DatasetRule` | 玩法元数据与用户方案 schema |
| `UtilPkg/ExtraArgsClass.swift` | `ReportClass`, `ReportManager` | 报法参数、搜索/变换、结果/语音生成 |
| `UtilPkg/CUtils.swift` | `SingleFeature`, `RC`, `cutStruct` | 通用领域模型和组合算法 |
| `UtilPkg/JsonIOUtils.swift` | create/read JSON functions | Documents 文件初始化/读取 |
| `UtilPkg/VisionUtils.swift` | `createCVPixelBuffer`, CIImage helpers | ROI 裁剪/resize/图像处理 |
| `UtilPkg/CurrentBlurDetector.swift` | `ComputeROILaplacianVariance` | 当前视觉 ROI 清晰度 |
| `UtilPkg/OriginBlurDetector.swift` | `BlurDetector_8` 等 | vImage 格式/模糊检测基础 |
| `UtilPkg/AManager.swift` | `AuthManager` | 授权全局状态、加密、UUID/key |
| `UtilPkg/KeychainHelper.swift` | `KeychainHelper` | Keychain CRUD |
| `UtilPkg/TimeAuthUtils.swift` | 网络时间、`TimeModeFormatter` | 授权时间和黑屏日期/时间 |
| `UtilPkg/SpeechUtils.swift` | 数字转中文 | TTS 文本预处理 |
| `UtilPkg/ExtraArgsClass.swift` | `SpeakResultStruct` 的消费者 | 注意类型本身定义在当前识别 VM |

## DatasetPkg

完整 ID/文件/类型映射见 [`dataset-catalog.md`](dataset-catalog.md)。按任务查找时优先搜索：

```bash
rg 'FindWinner|getMinSingleFeatureNum|evalHand|rankRules' lifeCatcher/DatasetPkg/<file>.swift
```

## 资源与工程

| 路径 | 内容 |
|---|---|
| `lifeCatcher/Resources/*.mlmodel` | 普通与核心视觉模型 |
| `lifeCatcher/Resources/*.mp3` | 三个提示音 |
| `lifeCatcher/Resources/IC.xcassets` | 图标/示例图 |
| `lifeCatcher/Resources/BG.xcassets` | 背景 |
| `lifeCatcher/App/*.lproj/Localizable.strings` | 中英文文本 |
| `lifeCatcher.xcodeproj/project.pbxproj` | target、资源、包依赖、签名与部署版本 |
| `lifeCatcher.xcodeproj/xcshareddata/xcschemes/lifeCatcher.xcscheme` | 共享 build scheme |
| `tools/video-replay/` | 独立 macOS 视频逐帧 Core ML/状态机回放工具，不属于 iOS target |

## Remote

远程目录逐文件职责、协议同步规则和精确接入点见 [`remote-system.md`](remote-system.md)。人类产品行为见 [`../product/remote-feature.md`](../product/remote-feature.md)，wire schema 见 [`../protocol/remote-v1.md`](../protocol/remote-v1.md)。

## 常用精确检索

```bash
# 某个报法 ID 的全部分支
rg '\b268\b' lifeCatcher/UtilPkg lifeCatcher/Views

# 某个 DatasetIndex 的所有调度位置
rg 'case 18:|18:' lifeCatcher/UtilPkg lifeCatcher/Views lifeCatcher/ViewModels

# 一个方案字段从 UI 到运行时的全链路
rg '\brecgReport\b' lifeCatcher --glob '*.swift'

# 所有网络端点
rg 'URL\(string:' lifeCatcher --glob '*.swift'

# 当前实际实例化的模型
rg 'try! [A-Za-z0-9_]+\(\)|VNCoreMLModel' lifeCatcher/ViewModels
```
