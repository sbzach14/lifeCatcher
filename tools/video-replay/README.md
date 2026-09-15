# lifeCatcher macOS 视频回放识别器

这是独立于 iOS App 的离线测试工具。它不启动相机、不读写 App 的 UserDefaults/JSON，也不改动正式 ViewModel。工具使用正式 `.mlmodel`，复刻正式链路中的 ROI、检测/分类、识别状态机和 `handleDetecResultList` 跨帧牌序汇总。

## 时间语义

- 视频原始 FPS 不参与识别时间轴。
- 解码得到的每一帧依次映射成一个逻辑帧。
- `--fps 120` 时，第 N 帧逻辑时间为 `N / 120` 秒；`--fps 240` 同理。
- 推理串行执行，只有上一帧完成模型和状态处理后才处理下一帧，确保离线结果可复现。
- 因此 iOS 并发推理使用的帧级 ROI 场景/方向快照在本工具中没有乱序对象；单帧始终使用固定 `--orientation` 和当前场景完成模型、排序、ROI 与姿态处理。
- 这模拟的是 120/240 FPS 的逻辑输入序列，不承诺模型推理在墙钟时间内达到每秒 120/240 次。
- 视频结束后默认补 16 个黑帧，模拟牌离开画面，让正式的连续空帧退出逻辑能够汇总结果。

一张视频帧只对应一张逻辑帧，不按原视频 FPS 插帧或丢帧。

## 运行

在仓库根目录执行：

```bash
swift run -c release \
  --package-path tools/video-replay \
  lifecatcher-video-replay \
  --video /absolute/path/to/cards.mp4 \
  --fps 120 \
  --mode horizontal-shuffle \
  --orientation horizontal \
  --rotation none \
  --frames-output /absolute/path/to/annotated-frames \
  --output /absolute/path/to/result.json
```

后置 240 FPS 逻辑回放：

```bash
swift run -c release \
  --package-path tools/video-replay \
  lifecatcher-video-replay \
  --video /absolute/path/to/cards.mov \
  --fps 240 \
  --mode shuffle \
  --orientation horizontal \
  --trace
```

查看全部参数：

```bash
swift run --package-path tools/video-replay lifecatcher-video-replay --help
```

### 横洗 ROI 校准状态

iOS 与本工具均为横洗选择 `riffle_detect_1111` + `cls_20260915_texas`，后者横竖共用。
单框入口按框面积×90 建 ROI；双框以两个框中心连线中点为中心，以最外侧沿轴边缘总跨度×1.5
确定长轴。横屏 X 为长轴、比例 16:9，竖屏 Y 为长轴、比例 9:16。边界只平移或填 RGB 114，
不改变训练尺寸，不使用旧的 4.5:1、最大面积参考框或 90% 包含扩展。

横洗单框只在进入/重新进入识别时建立搜索 ROI；搜索与洗牌阶段只有双框更新，零/单框
保持最近 ROI，直到原有重置/退出条件。显式拨牌仍按单目标跟踪。普通洗牌的模型、ROI 和
状态分支保持原样。无法包住目标的训练 ROI 返回无效，继续原有重新检测流程。
姿态跨轴 limit 保留 1.5，普通洗牌保留 0.5。

测试覆盖面积、外边缘跨度、不等尺寸框的中心、横竖轴交换、边界平移/填充、单框入口→双框
洗牌→单侧遮挡→恢复→退出，以及原有早期缺框重置。模型冒烟测试在 Mac 原生 Core ML 中
编译、加载并分别执行 640×640 Detect 和 320×320 Texas 分类；不能替代真机准确率验证。
离线回放从空牌序开始，不执行结果后的切牌业务，但切牌场景使用相同几何。

## 训练数据工具边界

视频候选帧筛选、模糊/重影 QA、旧标签抽样校验、YOLO 数据集生成和类别映射已迁移
到独立的 [Card 训练仓库](https://github.com/banana45/Card)。本目录只保留使用正式
Core ML 和状态机进行离线回放验证的 Swift Package。

## 关键选项

| 选项 | 含义 |
|---|---|
| `--mode horizontal-shuffle` | 横洗，默认值；使用 `riffle_detect_1111` + `cls_20260915_texas`；ROI 与排列取 `--orientation` |
| `--mode shuffle` | 只允许洗牌结果，使用 `detect_0903` 与 `cls_1215_*` |
| `--mode riffle` | 只允许拨牌结果，使用 `riffle_detect_1111` 与 `riffle_cls_*` |
| `--mode both` | 对应正式代码 `[1,1]`，仍按正式选择顺序使用洗牌模型组 |
| `--orientation horizontal/vertical` | 旋转后的实际牌堆方向；横屏按 X 处理左右牌堆，纵屏按 Y 处理上下牌堆 |
| `--rotation none/clockwise/counterclockwise/auto` | 输入像素旋转，默认 `none`；`auto` 仅对竖屏源逆时针旋转，不确定时应显式指定 |
| `--allowed-cards 0-51,53-54` | 指定正式分类过滤集合；52 是模型 none，不能加入 |
| `--min-cards 10` | 对应 `minSingleFeatureNum`，正式算法最多按 10 张判断短结果 |
| `--add-card-mode 0/1/2` | 对应正式跨帧孤立补牌设置 |
| `--flush-frames 16` | 结尾送入模型的黑帧数量；设为 0 可关闭 |
| `--skip-frames` / `--max-frames` | 仅用于快速复现某个视频区间；正式全量回放不要设置 |
| `--single-roi-area-factor <n>` | 横洗单框 ROI 面积倍数，默认 90；可显式传其他值做离线对照，不会修改 iOS 配置 |
| `--force-single-entry left|right` | 诊断单框入口：全帧检测阶段只保留指定侧框；进入 ROI 后恢复真实检测结果 |
| `--frames-output <directory>` | 保存旋转后、保持自然尺寸的标注 PNG 和 `frames.jsonl`；重跑前自动彻底删除该目录中的旧工具输出 |
| `--trace` | 输出每个逻辑帧的状态、ROI、候选牌和置信度 |

## 输出

JSON 包含：

- 视频原始元数据与实际解码帧数；
- 强制逻辑 FPS 和逻辑时长；
- 所有状态转移及对应逻辑帧号；
- 每次跨帧汇总得到的牌编码、可读标签、洗/拨判定和短结果状态；
- 视频结束后的最终状态。

启用 `--frames-output` 后，每个 `frame_NNNNNN.png` 严格使用 `--rotation` 指定的像素方向，并保持旋转后的自然分辨率；只有显式旋转 720×1280 输入时才会导出为 1280×720，`--rotation none` 则保持 720×1280。模型推理仍使用正式的 1920×1080 相机帧。青色框是当帧 ROI，红色框表示 `detect` 模型目标，黄色框表示 `cls` 模型牌面分类。标题同时记录帧号、模型阶段、状态变化和逻辑 FPS。`cls` 类别严格按稳定编码显示为 `♠️A-K`、`♥️A-K`、`♣️A-K`、`♦️A-K`；检测模型的 class 0 显示为 `target`，不会误写成 `♠️A`。同目录的 `frames.jsonl` 提供逐帧机器可读索引，`cameraROI` 和 `cameraBox` 均为相对导出帧左上角的归一化坐标。

每次重跑同一个 `--frames-output` 目录时，工具会先删除原有 `frame_*.png`、`frames.jsonl` 和工具标记，再从第 0 帧重新生成，避免旧帧或缩短后残留的尾帧占用空间。为防止误删，自动清理只接受纯工具输出目录；若发现未知文件、子目录或符号链接，运行会报错并保留全部内容。不要把桌面、仓库根目录或包含个人文件的目录直接传给此选项。

牌编码沿用正式协议：`0...51` 为四花色，`53` 小王，模型类别 `52` 会转换为大王 `54`。

## 与正式链路的边界

该工具覆盖“视频帧 → Core ML → ROI → 状态机 → 跨帧有序牌堆”。它不会执行相机曝光/焦距控制、音量键、TTS、登录、页面展示，也不会加载某台手机上的保存方案和玩法报表。需要模拟某个方案时，应把该方案的允许牌集合、最少牌数、洗/拨模式和补牌模式通过命令行传入。

## 维护映射

为了不影响正式 App，工具没有让 iOS ViewModel 依赖 macOS target。维护时必须保持下列映射：

| macOS 工具 | 正式实现来源 |
|---|---|
| `DetectionNormalization.swift` | `getSingleFeature` |
| `RecognitionGeometry.swift` | `judgeCutRange`、ROI 与姿态辅助方法 |
| `FrameAggregation.swift` | `handleDetecResultList` |
| `RecognitionEngine.swift` | `processImageOrigin` 中首次洗/拨识别的状态推进 |

前三项当前与正式方法保持逐行语义一致；唯一非行为差异是把正式代码中不可跨模块调用的调试 `_index` 换成等价的 `firstIndex`。修改正式视觉算法时，应在同一改动中同步这里并重新运行单元测试与真实视频回放。
