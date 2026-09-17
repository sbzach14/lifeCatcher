# 系统架构

## 1. 技术与运行边界

- 平台：iOS，Swift 5，SwiftUI + 少量 UIKit bridge。
- target：`lifeCatcher`，scheme：`lifeCatcher`，工程文件：`lifeCatcher.xcodeproj`。
- target 的 Deployment Target 是 iOS 17.6；project 级设置中仍能看到 16.0，但 target 级值覆盖它。
- 主要系统框架：AVFoundation、Vision、CoreML、CoreImage、Accelerate/vImage、MediaPlayer、Photos、CryptoKit、DeviceCheck、Security。
- Swift Package：Localize-Swift、swift-collections、swift-algorithms、swift-async-algorithms、swift-crypto、CryptoSwift、LiveKit。部分包只被少量或遗留代码引用。
- 没有测试 target；scheme 开启自动测试计划但仓库没有测试源码。

## 2. 顶层分层

```text
App / Views
  ├─ 普通采集 UI ───────────────┐
  ├─ 方案设置 UI ───────────┐    │
  ├─ 核心识别 UI ───────┐   │    │
  └─ 登录/历史/信息 UI  │   │    │
                        ▼   ▼    ▼
ViewModels             当前识别  设置  普通采集/记录
                        │        │
                        ▼        ▼
UtilPkg              视觉工具 / 配置注册 / 报法引擎 / 存储 / 授权 / 语音
                        │
                        ▼
DatasetPkg           19 套规则：发牌 → 手牌求值 → 玩家排序 → 剩余牌
                        │
                        ▼
Resources            Core ML 模型、音频、图片、本地化资源
```

依赖方向大体从 View → ViewModel → Util/Rule → Dataset。当前实现大量使用全局静态状态和整数数组，编译器无法替代文档约束这些协议。

## 3. 启动与全局初始化

入口是 `App/MyApp.swift` 的 `@main MyApp`。

1. `AppDelegate.didFinishLaunching` 清空 Documents 下的 `model/` 临时目录。历史的模型解密/解压代码已注释。
2. `MainMenuView.onAppear` 触发：
   - 设置 Localize-Swift 当前语言；
   - 请求网络时间；
   - `initFile()` 初始化本地数据和全局规则。
3. `initFile()` 顺序很重要：
   - `createParaJSON()`：确保设备 UUID 已写 Keychain，并创建 `para.json`；
   - `createConfigJSON()`：创建/按版本重置 `config.json`；
   - `createRecordHistoryJSON()`：从 `cls_main` 的 class labels 建立历史索引；
   - 从 UserDefaults 读取 `DetectSettingArgs.allUsersDatasetRule`；
   - `LoadAllPresetRules()` 构建 19 套玩法的默认位置参数数组；
   - `LoadAllReportRules()` 注册报法 ID → `ReportClass`。
4. `MainMenuView` 同时尝试自动登录。

全局静态表必须先初始化，方案配置页和核心识别页才可安全使用。直接在 Preview、测试或新入口中实例化这些页面时，需要先模拟上述初始化。

## 4. 两条视觉业务线

### 4.1 普通采集线

入口：`MainMenuView` 的 “Collect” → `OriginVisionObjectRecognitionView`。

- 后置相机 + Vision 的 `VNCoreMLRequest`。
- 单一模型 `cls_main`，输出分类字符串。
- 用户点击保存后，将当前帧 JPEG 写入 Documents/recordHistory，并把文件名追加到 `recordHistory.json` 对应分类。
- `HistoryView`/`HistoryItemView` 读取并展示这些记录。

这条链路不调用 `DatasetPkg`、`DatasetRule`、`ReportManager`，也不还原整副牌顺序。

### 4.2 核心规则线

入口：授权后的 `DeprecatedMainView` → 方案列表/设置 → `CurrentVisionObjectRecognitionView`。

- 前/后置相机，高帧率捕获。
- 检测模型先定位一侧或两侧牌；分类模型在动态 ROI 内识别牌面。
- `CurrentVisionObjectRecognitionViewModel` 的字符串状态机管理 idle/detecting/shuffle/riffle/waitingEnd/reloading。
- `handleDetecResultList` 把多帧左右两条识别链合并为有序牌数组。
- 保存方案决定玩法、人数、发牌方式、切牌/看牌方式、报法和语音。
- `ClassifierSettingArgs.selectDataset` → `ReportManager.DatasetReporter` → 对应数据集 `FindWinner`。
- 输出包括每轮各玩家结果、剩余牌、语音片段与下一轮状态。

核心入口提供识别端、接收端、识别-接收端；ModeSwitch/Auth 归档方案还提供本地端。相机权限延迟到识别页面申请；纯接收端不申请相机权限，也不实例化核心识别 ViewModel。识别-接收端在本机相机识别和发送的同时，以同一序列号接收桌面转发的语音，不订阅本机视频。远程子系统通过输出桥接层旁路业务事件和按设置发送的 720p/1080p、30/60 FPS 视频，详情见 [`remote-system.md`](remote-system.md)。

## 5. 核心模块职责

### App

- `MyApp.swift`：进程入口、外观、权限、全局初始化。
- `AppDelegate.swift`：临时模型目录生命周期；旧模型解密逻辑保留为注释。
- `Info.plist`：允许任意网络加载，定义相机/照片权限和全屏竖屏行为。

### Views

- 只应负责导航、绑定和轻量 UI 行为，但当前设置页也承担方案组装与校验。
- `CurrentObjectRegView.swift` 包含 UIKit 的音量键桥接，不能当成纯 SwiftUI View。

### ViewModels

- `CurrentVisionObjectRecognitionViewModel`：系统最重的编排器，横跨相机、模型、状态机、规则、语音和设置持久化。
- `Remote/`：独立的业务连接、媒体、接收端、纯结果展示和持久 outbox；接收端依赖该层而不依赖识别 ViewModel。
- `OriginVisionObjectRecognitionViewModel`：独立的普通采集分类器。
- `SettingViewModel`：全局相机/音频/显示设置与授权展示值。
- `AppViewModel`、`RecordViewModel`：登录页面状态与历史索引的薄封装。

### UtilPkg

- `AllBaseSettingArgs.swift`：数据集注册、预设、方案结构、规则调度入口。
- `ExtraArgsClass.swift`：报法定义与约 270 种报法的核心搜索/变换/输出逻辑。
- `JsonIOUtils.swift`：Documents JSON 初始化与读取。
- `VisionUtils.swift`、`CurrentBlurDetector.swift`、`OriginBlurDetector.swift`：图像裁剪、绘制、直方图/模糊度计算。
- `AManager.swift`、`KeychainHelper.swift`、`TimeAuthUtils.swift`：授权、加密、设备标识与网络时间。
- `CUtils.swift`：跨数据集复用的 `SingleFeature`、`RC`、组合工具和 `cutStruct`。

### DatasetPkg

每个文件通常包含三层：

1. `*Rule : Rule`：玩法名称、人数、参数选项、牌型规则 ID。
2. `*Dataset`/短名类：牌集生成、发牌、`FindWinner`、最少牌数。
3. `*HandAnalyst`：把手牌计算为可比较 rank/type/suit。

## 6. 共享状态与生命周期

- `DetectSettingArgs.allUsersDatasetRule`：从 UserDefaults 加载的内存方案数组。
- `DetectSettingArgs.allPreSetRules`：启动时生成的预设参数表。
- `DetectSettingArgs.allPreSetReportRules`：报法 ID 注册表。
- `ClassifierSettingArgs.targetSetting`：固定 19 个数据集规则实例。
- `ReportManager.isFirstReport`、`recordedMaxIndex`：跨调用静态状态；开始新洗/拨牌时会重置部分状态。
- `AuthManager`：全静态登录/激活状态。

这些状态不具备隔离性。并行运行多个核心识别 ViewModel、测试并发调用报法、或在不同 Scene 中同时修改方案都可能相互影响。

## 7. 主要架构债务

- 核心 ViewModel 与报法引擎体积过大，UI/硬件/领域逻辑未隔离。
- `args: [Int]`、双槽数组、报法字段大量依赖位置和 magic number。
- 设置页和运行时分别维护近似相同的 19 路 switch，新增数据集极易漏改。
- 网络请求、加密与状态更新存在重复实现。
- 多处 `try!`、强制解包和数组下标假设会把配置/模型不匹配变成崩溃。
- 相机回调使用并发队列，但多个可变属性缺乏统一串行化；只有少量锁实际生效。

修改时优先保持行为兼容；重构和功能变化最好分开提交。
