# 核心视觉识别实现

## 1. 两阶段模型组

`CurrentVisionObjectRecognitionViewModel` 在初始化属性时直接 `try!` 创建 8 个生成类：

| 用途 | 普通洗牌 | 横洗 | 拨牌 |
|---|---|---|---|
| 全帧定位/检测 | `detect_0903` | `detect_20260915_texas` | `riffle_detect_1111` |
| 横屏 ROI 分类 | `cls_1215_h` | `cls_20260915_texas` | `riffle_cls_h_1107` |
| 竖屏 ROI 分类 | `cls_1215_v` | `cls_20260915_texas` | `riffle_cls_v_1107` |

Texas 分类模型为 52 类、RGB 320×320、内置 NMS 的 pipeline，横竖屏共用同一模型。
模型 SHA-256：`cf324b25b857385a5bea45488506cb4e923ab11f86fd7cc976c8de03e2cbe078`。
Xcode 与现有模型一样使用 `detect_0903.mlmodelkey` 编译加密。

横洗检测模型 `detect_20260915_texas` 为单类 `card_corner`、RGB 640×640、内置 NMS 的 pipeline，输出 N×1 confidence 与 N×4 归一化中心坐标。来源、SHA-256 与下载步骤见 [`model-server.md`](model-server.md)。

普通采集使用另一个 `cls_main`，不属于本表。

模型编译生成的 Swift 类型名来自 `.mlmodel` 文件名；改名或替换模型时既要更新 resource membership，也要更新直接实例化的类型及输出特征名 `image`、`iouThreshold`、`confidenceThreshold`、`confidence`、`coordinates`。

## 2. 相机配置

- 前置：期望 1920 宽、最高至少 120 FPS。
- 后置：期望 1920 宽、最高至少 240 FPS。
- `setupAVCapture` 将 sample buffer delegate 放在主队列；每帧再提交到并发 `detectionQueue`。
- 非识别状态使用 `idleRate = 30`，识别期间切换到 `setFrameRate`。
- 显示固定用 30 FPS Timer 从 `latestFrame` 读取，不等于推理帧率。
- `initializeTransform` 预计算旋转 -90°、0.4 缩放和位移，用于屏幕预览。
- `isBackCamera`、`isCameraHorizon`、`isHighHz`、`isMaxLightness`、`zoomFactor`、`focusFactor` 来自 `config.json`。

`changeCameraFrameRate` 同时改变曝光策略。只改帧率会影响亮度、运动模糊和后续 Laplacian 阈值，必须联动真机验证。

## 3. 图像尺寸与坐标

- 原始逻辑尺寸：`originSize = [1920, 1080]`。
- 普通流程 ROI 名义比例：`originImageSize = [569, 320]`，缩放后写入 `imageSize`；横洗使用独立的固定 `Along:Cross = 16:9` 合同。
- 分类输入：320×320。
- 检测输入：640×640。
- box 统一表示为归一化 `[centerX, centerY, width, height]`。
- `targetArea` 也使用全帧归一化中心/宽高。
- 普通双目标 ROI 先用两个框的全局 `min/max` 求联合包围区域，不依赖左右/上下顺序，再按手机方向扩展为当前的大 ROI；普通流程仍沿用约 `569:320` 及其纵向轴交换。
- `TargetAreaScenario` 把普通流程、横洗和横洗后切牌拆成独立场景。横洗横屏以 X 为 Along、Y 为 Cross；竖屏交换两轴。牌角姿态不改变轴。固定比例为 `R=16/9`，单框面积因子 `K=70`，双框沿轴外边缘跨度倍率为 `1.5`。
- 横洗单框 ROI 只在全帧 Detect 进入/重新进入识别时建立：`A=sqrt(R×70×boxArea)`、`C=A/R`，中心取框中心，横屏 16:9、竖屏 9:16。
- 横洗双框 ROI 中心取两框中心连线的中点。横屏宽度为两框最外侧 X 边缘总跨度的 1.5 倍，高度=宽度×9/16；竖屏高度为最外侧 Y 边缘总跨度的 1.5 倍，宽度=高度×9/16。中心不取联合包围框中心。不使用旧的最大面积框基准、4.5:1 或 90% 等比扩展。
- 屏幕尺寸不再缩小统计 ROI。ROI 能放进画面时只向内平移；任一轴大于画面时仍保持原尺寸并尽量覆盖真实像素，超出部分在模型输入中填充 RGB `(114,114,114)`。检测框本身必须完整处于相机画面且完整落入 ROI。

`createCVPixelBuffer` 负责按 ROI 裁剪、resize、平移到原点并生成 32ARGB buffer。`updateTargetArea` 把 ROI 内局部 box 反算到全帧坐标，再调用 `computeTargetArea` 重新包围。

## 4. 模型选择逻辑

`processImageOrigin(pixelBuffer, taskIndex, isTargetArea, targetArea, targetAreaScenario, isCameraHorizon)`：

- `isTargetArea == false`：用检测模型，confidence threshold 约 0.7。
- ROI 内普通模式且横屏：用横向分类模型；竖屏用纵向分类模型。
- `shuffleMode[0] == 2` 为横洗：全帧使用 `detect_20260915_texas`，ROI 分类横竖屏均使用 `cls_20260915_texas`。方向仍决定 ROI 及节点排列，横屏按 X、竖屏按 Y。
- `shuffleMode[0] == 1` 保留普通洗牌组；`== 0` 保留拨牌组。横洗与拨牌同时开启时保留原来的洗牌槽优先模型路由，使用 Texas 分类。
- 模型 IOU 固定约 0.2；分类调用传 0.05 的 confidence threshold，代码再做二次阈值判断。

## 5. `getSingleFeature` 的标准化契约

输入是模型的 confidence 多数组、coordinates 多数组、原始 pixel buffer，以及是否为分类阶段。

输出固定为 `([DetectionResult], uniqueNum)`：

- `DetectionResult` 最终总是补齐到左右两个节点；无牌用索引 `-1`、极小置信度表示。
- 多个重叠检测框会合并候选索引和置信度。
- 只保留置信度最高的两个非重叠目标。
- 不论普通洗牌还是横洗，横屏牌堆按 X 从小到大、竖屏牌堆按 Y 从小到大排序；同一个 `isCameraHorizon` 同时决定节点排序、分类模型和 ROI 拉伸比例。
- 分类阶段只保留 `allSingleFeatureIndex` 允许的牌。
- 模型类别 52 被映射到牌编码 54。
- 分类阶段对每个 box 调用 `ComputeROILaplacianVariance`，把清晰度写入 `laplacianVariance`。

后续算法假定数组恰好有两个节点，并频繁访问 `[0]`、`[1]`。任何重构必须保持这个契约或同步整个状态机。

## 6. 状态机

`state` 是字符串而非 enum。主要状态：

| 状态 | 含义 |
|---|---|
| `idle` | 30 FPS 全帧检测，等待稳定出现一侧/两侧目标 |
| `detecting` | 已建立 ROI，判断动作是切牌、洗牌还是拨牌 |
| `shuffle` | 两侧连续牌链识别 |
| `riffle` | 单侧连续牌链识别 |
| `waitingEnd` | 等待识别动作结束；当前代码仅在少量/注释路径出现 |
| `reloading` | 一次识别结束后的短暂防重入期 |

核心转移：

1. idle 中目标连续稳定后，计算 ROI，切高帧率，进入 detecting。
2. 已有牌堆且方案需要切牌/看牌时，单张高置信目标优先走切牌分支。
3. 两个分离目标、姿态合理、连续稳定 ≥3 帧 → shuffle。
4. 单个目标、置信度/uniqueNum 合格 → riffle。
5. 识别中把每帧两个 `DetectionResult` 存入 `detectResultList[taskIndex]`。
6. 目标消失累计约 5 帧，退出 ROI；随后 `handleDetecResultList` 汇总。
7. `quitDetect` 清理 ROI/临时结果并进入 idle 或短暂 reloading。

`detectSet.count` 用于判断已积累足够不同牌，达到 5 后稳定 ROI，达到 8 后停止开始提示语音。

## 7. 洗牌、拨牌与切牌

- 洗牌：期望同时看到两个不同牌面，最后将双侧链合并。
- 横洗：仍是双目标洗牌，保存编码是 `shuffleMode[0] == 2`。一个稳定全帧目标即可先建立动态横洗 ROI 并等待另一侧出现，但只有两个不同目标满足姿态且连续稳定 ≥3 帧才进入 `shuffle`；单框不会被当作横洗结果提交。它与普通洗牌使用相同的手机方向协议，业务状态机不额外旋转或重排图像。
- 同时开启横洗和拨牌时，未明确进入切牌的单框仍优先采用横洗 70 倍面积 ROI，以免漏掉随后出现的第二堆；该单框之后仍可由现有状态机消费为 `riffle`。这是对“寻找未知第二框”的显式取舍；未开启横洗的普通拨牌/普通洗牌仍走原 `standard` 几何。
- `activeTargetAreaScenario` 在横洗搜索/洗牌时为 `.horizontalShuffle`，在已有牌序、该牌序来源为洗牌槽且明确需要看底、看顶、连续看底、连续看顶、照顶去牌、连续照顶去牌、看手牌、特殊牌或报牌识别时为 `.horizontalShuffleCut`。拨牌槽产生的牌序及其后续切牌保持标准几何，不会因同时启用横洗而套用横洗切牌 ROI。明确切牌仍保留 `confidence >= 0.8` 的优先级，但只有 `detectNum == 1 && uniqueNum == 1` 的唯一单框才能提交，双框不能被切牌分支抢先消费。
- 横洗搜索和洗牌阶段：只有双框更新 ROI，零/单框保持最近一次 ROI（并发旧帧也不把 ROI 回滚到旧快照）。单框搜索 ROI 不因当前单框变小而逐帧缩小；获得双框后按双框公式更新。正式 `shuffle` 短暂缺侧不进入单框算法，沿用原有早期重置与连续空帧退出计数。显式进入 `riffle` 后仍保留单目标跟踪；普通流程不受此横洗专用保持分支影响。
- `shufflePostureJudge` 在横洗场景使用产生本帧模型坐标的 `targetArea` 快照真实像素宽高还原局部坐标，不能使用为下一帧刚重算的 ROI，也不能继续用普通流程的569×320尺度。横洗专用跨轴门槛为 `abs(crossCenterDelta) < 1.5×meanCrossBoxSize`：1,631 组 0813/0814 非王 M2 双框在手机轴 canonicalize 后，该无量纲比值 P90/P95/P99/max 分别为 `0.7626/0.8729/1.0811/1.3247`，`1.5` 比观测 max 保留约 13% 余量并覆盖 100% 正样本。沿轴门槛保持不变，全部正样本的沿轴余量比最小为 `2.1856`；普通洗牌仍使用旧的 `0.5×meanCrossBoxSize` 跨轴门槛。
- 横洗把整个 16:9/9:16 ROI 非等比缩放到 320×320。边界平移与灰填充保留现有实现，不改变统计尺寸。如果指定几何不能完整包含目标，返回无效 ROI，继续现有退出/全帧重新检测流程，不额外扩大以偏离训练公式。新模型与真机准确率仍需相机验证。
- 拨牌：期望单侧目标；`shuffleMode[1] == 1` 表示拨到顶，`== 2` 表示拨中间，后者完成后会把首元素轮转到末尾。
- 是否需要切牌由 `isProcessNeedToCut`、`detectNeedToCut`、`cutMode`、`specialCard`、`recgReport` 共同决定。
- `cutStruct(cutcardIndex, cutMode)` 是视觉层与报法层之间的协议：
  - 0 看底/从该牌后切开；
  - 1 看顶；
  - 2 看色；
  - 3 连续看手；
  - 4 按目标位置对齐看手牌。
  - 5 照顶去牌：以照到牌为当前顶牌，将其移除并从下一张继续。

视觉 ViewModel 中 `generalRuleSetting.allCutMode` 的 UI 编号与 `cutStruct.cutMode` 不是同一个编号空间，保存方案后会在识别时转换。不要混用。

方案 UI 的 `cutMode == 5` 为连续看顶。每次唯一单框稳定触发时，用照到牌在当前牌序中的前一张建立 `cutStruct(cutMode: 1)`；牌序首张的前一张循环到末张。它沿用连续看底的约一秒防重复窗口并保留多次切牌记录。看色报法仍只允许无、看底、看顶，保存旧的非法连续值时会降级为看底。

方案 UI 的 `cutMode == 6/7` 分别为照顶去牌和连续照顶去牌，二者写入 `cutStruct(cutMode: 5)`。识别到的顶牌会在任何发牌/报法计算前从牌序中移除，移除后的下一张成为新顶牌；连续模式累积多次有效单框并逐张移除。`returnSingleFeatureArray`、结果页牌堆和远程 presentation 均使用移除后的牌序。

桌面端 `awaitShuffle` 指令会终止当前播报并清空当前牌序、切牌、ROI 与临时检测，回到运行中的全帧等待状态。该等待带一次性“双框门”：单框不建立 ROI，只有洗牌槽已启用且稳定双框才进入 `detecting`；进入后清除门控，继续原洗牌状态机。命令前已提交的并发推理用 generation 丢弃，不能重新污染已复位状态。

桌面端 `recomputeCut` 指令不会重新跑视觉模型。它只接受最近一次识别牌序中存在的稳定牌编码，以该牌替换当前结果的最后一条切牌记录；看顶类模式继续采用其前一张并循环首尾的既有语义，然后调用同一 `computeWinnerRC` 规则与远程输出链。

## 8. 跨帧还原 `handleDetecResultList`

这是最敏感的算法区域。高层步骤：

1. 建立允许牌的置信度字典。
2. 按 frame key 排序，删除牌号与 Laplacian 完全相同的重复帧。
3. 去掉头尾不稳定帧，给相邻同牌节点累加 `nodeType`：
   - 0 未归类；
   - 1 链头/起始；
   - 2 链尾/结束；
   - 3 链中连续节点；
   - 4 作为孤立高置信候选补入；
   - 5 none/被排除。
4. 统计左右唯一集合和单双侧帧比例，判定 `isSingle` 与 `isShort`。
5. 根据长链头尾截取有效帧区间。
6. 对链间小缺口做同牌填补；去掉已被稳定链占用的错误候选。
7. 从未成链牌中按最高置信度选择孤立补牌，`addCardMode` 决定补牌激进程度。
8. 利用前后帧 Laplacian 比值判断双侧牌的先后顺序。
9. 逆向插入 `InsertCard`，再按牌号去重并保留更可信链。
10. 返回 `DetectionState(detectionResult, isSingle, isShort, longestIndex)`。

阈值既包括置信度（0.5/0.7/0.75/0.8 等）也包括模糊比 `blurThreshold = 0.75`。它们与模型、帧率、曝光、方向强耦合。

## 9. 并发与线程注意事项

- sample buffer delegate 在主队列，推理被派发到 concurrent `detectionQueue`，结果再回主队列。
- `taskIndex`、`state`、`targetArea`、`detectResultList`、`latestFrame` 会跨队列访问。
- 每帧提交推理时会同时快照 `isTargetArea`、`targetArea`、`activeTargetAreaScenario` 和 `isCameraHorizon`。该帧的模型方向、检测框排序、ROI 回算、移动与姿态判断必须全部使用这些快照；回主线程时若方向已变化，或 ROI 帧所属场景已变化，则丢弃该过期结果。
- `NSLock` 属性存在但主状态机没有系统性使用。
- 多帧推理可能乱序完成；帧级几何快照避免旧 ROI 帧套用新场景/方向，但状态转移仍按完成顺序执行。字典 key 保存原始 taskIndex，汇总时重新排序只缓解了牌链顺序问题。
- 不要简单把更多工作并行化。若修并发，优先考虑专用串行 actor/queue，并以行为回归为前提。

## 10. 真机验证矩阵

视觉改动至少覆盖：

- 前置 120 FPS / 后置 240 FPS；
- 横向/纵向；
- 洗牌双侧 / 拨到顶 / 拨中间；
- 完整 52/54 张与不完整牌集；
- 自动/最大亮度、不同焦距与缩放；
- 新手/熟手补牌模式；
- 需要切牌、连续切牌、看手、看色与无需切牌；
- 目标短暂消失、重复帧、蓝牙耳机插拔。

## 11. macOS 离线视频回放

`tools/video-replay/` 是额外测试流程，不在 iOS target 中，不修改相机、UI、方案或持久化代码。它在 Mac 上使用 `AVAssetReader` 逐帧解码视频，直接加载正式 `.mlmodel`，并保持以下正式协议和算法：

- 全帧 640×640 检测与 ROI 320×320 分类；
- 正式模型组选择、阈值、类别 52 → 54 映射；
- `getSingleFeature` 的双节点归一化与 Laplacian；
- idle/detecting/shuffle/riffle/reloading 状态推进；
- `handleDetecResultList` 跨帧牌序汇总。

视频源 FPS 被忽略。每个解码帧只映射成一个逻辑帧，逻辑时间按 `frameIndex / 120` 或 `frameIndex / 240` 计算；既不插帧也不丢帧。推理串行执行以保证结果可复现，因此“120/240 FPS”指业务状态机看到的逻辑时间轴，不保证墙钟吞吐量。

工具默认 `--mode horizontal-shuffle`，对应正式编码 `[2,0]`。`--orientation` 描述规范化相机画面中牌堆的实际横/纵方向，并统一决定 ROI 形变与排列逻辑（Texas 横竖共用）；横洗不会反选方向。显式传入 `--mode shuffle` 可继续运行普通洗牌。

离线回放逐帧串行完成裁剪、推理和状态处理，不存在 iOS `detectionQueue` 的乱序回调，因此不需要额外的帧级场景快照；其单帧内仍使用同一个固定 `--orientation` 和当前 ROI 场景。

工具的 `--rotation` 默认 `none`，不会擅自改变视频像素方向；已摆正的视频使用 `none`，需要旋转时显式传 `clockwise`、`counterclockwise`，也可按需选择竖屏源启发式 `auto`。旋转与 `--orientation` 相互独立，调用者必须保证旋转后的画面方向与 `--orientation` 一致。

传入 `--frames-output <专用目录>` 时，工具会严格按 `--rotation` 参数处理源帧，并保持处理后的自然分辨率保存 PNG；`none` 不旋转，显式旋转 720×1280 时才输出 1280×720。模型推理本身仍使用正式的 1920×1080 相机帧。青框为当帧 ROI，红框为全帧 `detect` 结果，黄框为 ROI 内 `cls` 结果。分类标签使用稳定编码映射 `♠️A-K`、`♥️A-K`、`♣️A-K`、`♦️A-K`，分数使用正式状态机实际消费的首选置信度。`frames.jsonl` 保存相同信息及相对导出帧左上角的归一化坐标；结尾用于触发退出逻辑的合成黑帧不写入该目录。

同一个 `--frames-output` 目录重跑时会先清除旧的工具生成帧和索引，避免短视频覆盖长视频后遗留尾帧。清理器仅接受由 `frame_*.png`、`frames.jsonl`、工具所有权标记及 Finder 元数据组成的专用目录；遇到未知文件、子目录或符号链接会在删除前失败。调用方不得把桌面、仓库根目录或混合用途目录作为逐帧输出目录。

工具不会执行玩法/报表、TTS、相机曝光/焦距或读取手机保存方案。方案中影响视觉的允许牌、最少牌数、洗/拨和补牌模式必须通过 CLI 参数传入。完整用法见 `tools/video-replay/README.md`。
