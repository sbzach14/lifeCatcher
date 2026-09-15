# UI、授权与普通采集

## 1. 导航图

```text
MainMenuView
  ├─ Collect → OriginVisionObjectRecognitionView
  ├─ History 按钮
  │   ├─ 未连登录服务 → LoginView
  │   ├─ AuthManager.isActive → DeprecatedMainView
  │   │   ├─ SettingRecordView(configType: 0)
  │   │   ├─ SettingRecordView(configType: 1)
  │   │   └─ DeprecatedInfoView
  │   └─ 已登录但未 active → HistoryView
  ├─ Information → InfoView
  └─ Account → LoginView

SettingRecordView
  → SettingRecordConfigView / _leishen
    → ReportSettingView / UsedFeatureSelectView / TurnSettingView / NumRangeSettingView
    → CurrentVisionObjectRecognitionView
      → ShowResultView overlay
```

“History” 按钮实际上同时充当授权后的核心功能入口，命名与导航逻辑不直观。不要仅根据按钮名判断页面职责。

## 2. 页面职责

- `MainMenuView`：根导航、语言、自动登录和基于授权状态的路由。
- `InfoView`：设备/版本与入口信息；`DeprecatedInfoView` 隐藏本地/远程模式切换并在进入时固定为远程模式，显示服务器、LiveKit 720p/1080p、30/60 FPS 与远程帧率测试入口。详见 `remote-system.md` 第 8 节。
- `LoginView`：账号登录、注册 UI、激活/状态展示；包含与 MainView 重复的登录实现。
- `RegisterView`：独立注册页实现，当前主登录页也自带注册逻辑。
- `SettingRecordView`：用户方案列表、删除、新增/编辑。
- `SettingRecordConfigView`：完整方案编辑。
- `SettingRecordConfigView_leishen`：简化方案编辑。
- `CurrentVisionObjectRecognitionView`：相机/黑屏/结果三种表面状态与相机设置 overlay。
- `ShowResultView`：结构化规则结果展示和随机测试入口。
- `AuthTestView`：管理接口测试页面，主菜单入口已注释，但源码仍编译。

## 3. 普通采集历史细节

`OriginVisionObjectRecognitionViewModel`：

- 后置相机，选择支持 1920 宽/240 FPS 的 format，但激活帧率设为 30。
- session preset 又设置为 VGA 640×480；实际 bufferSize 取 activeFormat。
- 每帧执行 `cls_main` 的 Vision 分类，并取第一个 observation。
- identifier 遇到逗号只保留逗号前部分。
- 保存文件名包含 `yyyy-MM-dd HH:mm:ss.jpeg`。
- 保存前假定 `detectedObjects[0]` 存在，模型尚未产出时点击可能越界。

`HistoryView` 只在创建 `RecordViewModel` 时读取一次索引；`HistoryItemView.imagePaths` 每次计算直接读 JSON。没有删除图片/清理悬空索引的功能。

## 4. 授权状态

`AuthManager` 的关键静态字段：

- `isLoginServer`：是否收到成功登录状态。
- `loginStatus`：0 未激活、1 正式版、2 测试版（代码注释与部分变量名 accountStatus/loginStatus 混用）。
- `isActive`：是否允许进入核心方案界面。
- `activeDate`：服务端过期时间格式化后的显示值。
- `version = "2.0.5"`：同时参与服务请求与 config 重置。

## 5. 登录协议

MainView 和 LoginView 都实现了近似流程：

1. 通过 `DCDevice.current.generateToken` 获取 App Attest/DeviceCheck token。
2. 组成 `timestamp_UUID_token`。
3. 用字符串 `_isCameraSetting` 的 MD5 bytes 生成对称 key，AES-GCM 加密。
4. POST `/login`，发送 username、password、encryptString、version。
5. 解密响应 `activated_code`，取得服务端 timestamp 与 authkey。
6. 校验账号状态、时间戳和 `AuthManager.authOnline`。
7. 更新全局静态状态；测试版还调用 `autoQuit`，5 分钟后挂起/退出。

服务基址目前硬编码为明文 HTTP，Info.plist 通过 `NSAllowsArbitraryLoads` 放行。修改网络层应同时处理 MainView、LoginView、RegisterView、AuthTestView、AManager 和 TimeAuthUtils。

## 6. 本地授权

- UUID 与 auth key 实际存 Keychain。
- `hashWithSalt` 使用两个经字符替换的 salt，SHA-512 计算设备相关 key。
- `authOnline` 优先校验已有 Keychain key，否则校验服务端返回 key。
- `authLocal` 读取 `para.json` 的 activeTime/uniqueID/authKey，并结合网络时间判断。
- `timeCheck`/`activeAccount` 目前用异步网络回调修改局部变量却同步返回，返回值很可能在回调之前产生。这是现状风险，不应在文档中假设本地校验可靠。

## 7. 相机页面的三种显示态

`CurrentVisionObjectRecognitionView`：

- `isBlack == true`：全黑/时间伪装页面，可隐藏返回按钮并按 blackMode 响应点击。
- `isShowSingleFeature == true`：显示 `ShowResultView`。
- 否则：显示实时 `cameraImage`，可展开相机设置。

页面 onDisappear 会停止 session 与 TTS。亮度在进入黑屏时直接改 `UIScreen.main.brightness`，没有明确恢复原值的集中逻辑。

## 8. UIKit 音量键桥接

SwiftUI 通过 `ButtonViewControllerWrapper` 嵌入无可见 UI 的 `ButtonViewController`：

- 添加屏幕外 `MPVolumeView`，把系统音量重置到配置的中间值。
- 观察 `SystemVolumeDidChange` 和音频路由变化。
- 0.1 秒内变化被忽略，0.5 秒窗口区分单击/双击。
- 蓝牙只检测 `.bluetoothA2DP`，有线耳机、HFP、AirPlay 不算。
- 耳机断开时可能停止发声并把系统音量设 0。

该实现依赖非公开通知字段 `Volume`、`Reason`、`SequenceNumber`，系统版本变化可能破坏行为。
