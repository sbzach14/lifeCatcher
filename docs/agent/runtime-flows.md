# 端到端运行链路

## 1. 应用启动

```text
MyApp
  → MainMenuView.onAppear
    → Localize.setCurrentLanguage
    → requestPermissions
    → initFile
      → para.json / config.json / recordHistory.json
      → load DatasetRule[] from UserDefaults
      → build preset game rules
      → build report rules
    → AutoLogin
```

注意：`MyApp` 初始将语言设为 `en`，随后 `MainMenuView` 再用 `@AppStorage("appLanguage")` 覆盖。

## 2. 普通采集与历史

```text
Collect
  → OriginVisionObjectRecognitionView.onAppear
  → initialize
    → camera authorization
    → setupAVCapture(back camera)
    → setupVision(cls_main)
    → startCaptureSession
  → each frame
    → VNImageRequestHandler.perform
    → first classification identifier
    → detectedObjects + cameraImage
  → user taps Save
    → JPEG to Documents/recordHistory/<timestamp>.jpeg
    → append filename in recordHistory.json[class]
    → success sound + speech
```

`createRecordHistoryJSON` 用 `cls_main` 的 class labels 初始化键。若替换模型但保留已有 JSON，新 label 不会自动补入，因为文件存在时函数直接跳过。

## 3. 方案创建/编辑/启动

```text
DeprecatedMainView
  → SettingRecordView(configType 0 or 1)
  → SettingRecordConfigView[_leishen]
    → SetUpAll
      → new: load preset args/suit/rank rules
      → edit: load DatasetRule from global array
    → saveData
      → normalize specialCard/cutMode relations
      → calculate minSingleFeatureNum
      → append/replace DatasetRule
      → JSONEncoder → UserDefaults
    → CurrentVisionObjectRecognitionView(saveRuleIndex, configType)
```

`configType == 0` 是完整方案界面；`configType == 1` 是 `leishen` 简化界面，它将洗牌/拨牌合并成单选并把槽位 0 的切牌、特殊牌、报法复制到槽位 1。

## 4. 核心识别启动

```text
CurrentVisionObjectRecognitionView.onAppear
  → viewModel.initialize(saveRuleIndex, configType)
    → setupAVCapture
    → configureAudioSession
    → initializeTransform
    → loadSaveRule
    → initShuffle / initDetectResult / initBoxes
  → prestartCamera
    → briefly run at max configured rate
    → restart at idleRate (30)
  → install volume-button observer through ButtonViewController
```

`loadSaveRule` 把持久化 `DatasetRule` 展开成 ViewModel 的运行时字段，并对部分“识别任意牌报下一轮”与特殊报法组合做纠正，随后会再次 `saveData()` 写回方案。

## 5. 从视频帧到有序牌堆

```text
captureOutput
  → store latestFrame for 30 FPS display
  → crop full frame or current ROI to model input
  → processImageOrigin
    → detector or classifier model prediction
    → getSingleFeature
      → merge overlapping boxes
      → keep at most two ordered sides
      → filter by allowed card set
      → compute ROI Laplacian variance
    → state machine
      → detect start / shuffle / riffle / cut / end
      → accumulate detectResultList[frameIndex]
  → after disappearance/end
    → handleDetecResultList
      → remove duplicate frames
      → form left/right temporal chains
      → infer head/tail and ordering
      → confidence/blur-based insertions
      → de-duplicate into ordered [Int]
```

完整细节见 `vision-pipeline.md`。

## 6. 从牌堆到规则结果

```text
singlefeatureArray
  → computeWinnerRC
    → ClassifierSettingArgs.selectDataset
      → ReportManager.DatasetReporter
        → optional cut/look/color transformation
        → choose DatasetFunctions[DatasetIndex]
        → one or more calls to Dataset.FindWinner
          → deal cards
          → evaluate every RC hand
          → sort / tie metadata
          → return DatasetReturnRCInfo[] + left cards
        → search target dictated by ReportClass
        → reportStringGenerator
    → MultipleReportResultInfo
      → update normalized deck
      → update left/used cards
      → optional CB/TW display sorting
      → speech synthesis
```

`computeNextRound` 将 `leftSingleFeatures` 作为新牌堆、增加 `currentRoundID`，然后再次计算。特定报法会额外用剩余牌最后一张构造 `cutStruct`。

## 7. 输出链路

规则输出同时进入三处：

- `SpeechPerformer`：按 `SpeakResultStruct.voiceType` 选男/女中文语音，通常重复两次，报单张类只重复一次。
- `ShowResultView`：展示牌堆、切牌/色牌/公牌、每轮位置、排名、牌型与手牌。
- 黑屏时间伪装：`timeMode != 0` 时把纯数字播报结果编码进 `timeModeText`，短时替代当前时间。

提示音 `start_voice/success_voice/fail_voice` 与最终 TTS 是两套输出。`voiceDevice` 决定声音只在当前路由符合配置时播放。

## 8. 音量键控制

`ButtonViewController` 观察私有通知名 `SystemVolumeDidChange`，区分音量上/下与 0.5 秒内单击/双击，然后调用 ViewModel。

事件编号来自 `config.json` 的 `volumeUp`/`volumeDown`：

| eventType | 单击 | 双击 |
|---|---|---|
| 0 | 无动作 | 无动作 |
| 1 | 人数索引增加 | 人数索引减少 |
| 2 | 位置增加 | 位置减少 |
| 3 | 人数增加并选最后位置 | 人数减少并选最后位置 |
| 4 | 洗牌模式向前 | 洗牌模式向后 |
| 5 | 拨牌模式向前 | 拨牌模式向后 |
| 6 | 下一方案 | 上一方案 |
| 7 | 开始/暂停 | 开始/暂停 |
| 8 | 计算下一轮 | 计算下一轮 |
| 9 | 修改 `volumeUp` 自身映射 | 反向修改 `volumeUp` 自身映射 |

所有会改变方案的操作最终调用 `saveData()`，会立即覆盖 UserDefaults 中当前方案。
