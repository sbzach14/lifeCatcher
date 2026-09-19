# 规则与报法引擎

## 1. 三层概念

### 玩法（Dataset）

由 `DatasetIndex` 0...18 唯一标识，决定发牌与手牌比较算法。注册表是 `ClassifierSettingArgs.targetSetting`。

### 方案（DatasetRule）

用户保存的一个完整运行配置：选择哪个玩法/预设、人数、发牌方式、可用牌、洗/拨牌、切/看牌、报法和底层参数。存于 UserDefaults。

### 报法（ReportClass）

报法不是玩法。它在某个玩法已经能计算每家强弱的基础上，定义如何变换牌堆、搜索切牌位置/多轮条件，以及最终播报哪些结果。由 `reportID` 唯一标识。

## 2. `DatasetRule` 字段协议

| 字段 | 语义 |
|---|---|
| `RuleName` | 当前预设的显示名称 |
| `DatasetType` | 玩法 ID 0...18 |
| `setting` | 该玩法 `Rule.setting` 的预设索引 |
| `dealNum` | 历史字段，随方案传入 |
| `coloringType` | 0 正面打色、1 反面打色、2 不打色（引擎内按 0 处理） |
| `dealType` | 0 默认逐轮每家一张，1 自定义发牌 |
| `diyDealNum` | 自定义每段发牌/公牌/去牌数量 |
| `diyDealStatus` | 与 `diyDealNum` 对齐的状态矩阵 |
| `rcNum` | 人数选项的索引，不是人数值 |
| `shuffleMode` | `[洗牌模式, 拨牌模式]` |
| `cutMode` | 洗牌/拨牌各自的 UI 切牌模式 |
| `singlefeatureToUse` | 允许识别/参与规则的牌编码 |
| `cutNumSetting` | 打色点数换算模式 |
| `reportSetting` | 洗牌/拨牌各自的 reportID |
| `cutNumRangeSetting` | 报法搜索区间 X/Y |
| `positionSetting` | 目标玩家位置，0-based |
| `consecutiveReport` | 连续计算轮数 |
| `reportNumber` | 保留字段，当前运行主链使用很少 |
| `voiceReport` | 保留/旧语音开关，实际发声还受全局设置控制 |
| `args` | 对当前 Dataset 特定的 positional Int 参数 |
| `suitRanks` | 花色优先序/规则参数 |
| `rankRules` | 启用的牌型规则 ID，通常顺序也表示优先级 |
| `minSingleFeatureNum` | 当前人数/发牌设置一轮至少所需牌数 |
| `recgReport` | 识别任意牌后计算下一轮 |
| `specialCard` | 洗/拨牌各自 0 无、1 看手、2 看色 |

新增字段必须考虑旧 UserDefaults 数据的 Codable 迁移；当前所有字段无默认解码策略，直接增加非 Optional 字段会让旧方案整体解码失败并返回空数组。

## 3. 预设参数

`DetectSettingArgs.LoadAllPresetRules()` 构造：

```text
allPreSetRules[datasetID][settingID] = [
  args,
  suitRules,
  rankRules,
  rankRuleChecked
]
```

四个数组的位置是固定协议。配置页用 `rankRuleChecked` 从候选 `rankRules` 过滤出实际启用项。

`args` 的字段顺序由对应 `*Rule` 的选项与 `FindWinner`/`evalHand` 解包共同定义。不要在一个位置插入参数而不迁移所有预设和已保存方案。

## 4. 数据集统一接口

`ReportManager.DatasetReporter` 维护两个以 DatasetIndex 为键的函数表：

```swift
FindWinner(
  diyDealStatus: [[Bool]],
  diyDealNum: [Int],
  inputSingleFeatures: [Int],
  args: [Int],
  rankRules: [Int],
  suitRules: [Int]
) -> ([DatasetReturnRCInfo], [Int])
```

返回值第一项是每个玩家/位置的信息，第二项是发牌后的剩余牌。

另一个统一接口是：

```swift
getMinSingleFeatureNum(
  rcNum: Int,
  handNum: Int,
  communityNum: Int,
  dealType: Int,
  diyDealNum: [Int],
  diyDealStatus: [[Bool]]
) -> Int
```

PB 的方法名是大写 `GetMinSingleFeatureNum`，其余多数为小写；映射表已适配这个差异。

## 5. `DatasetReturnRCInfo`

每个玩家的标准结果：

- `rcID`：0-based 玩家位置。
- `rcRank`：用于跨玩家比较/分组的主 rank。
- `rcDatasetRank`：展示用排名。
- `rcSingleFeaturesType`：牌型/点数文字。
- `rcSingleFeaturesSuit`：花色文字。
- `isPair`：对子标识，供报法统计。
- `RCSingleFeatures`：玩家实际手牌，元素为 `SingleFeature`。
- `communitySingleFeature`：该玩家计算时使用的公牌。

数据集应返回按引擎预期排序或包含足够 rank 信息的结果；`ReportManager.extractWinnerSet` 依赖相邻相同 `rcRank` 表示平局组。

## 6. `ReportClass` 是行为参数对象

一个报法由多个整数开关组合，而不是独立类。关键维度：

- `rankReport`：最大、最大次大、前三、最小、排名等；值 8 表示只报第一名分组中的所有并列最大玩家。
- `aliveDeathReport`：活门/半活门/死门的输出。
- `pairReport`、`DrawPointReport`、`NPReport`：对子、平点、九点统计。
- `reportCutRange`：遍历上/下多少张、固定位置、范围切牌等。
- `reportTarget`：保某位置最大/最小、两位置、活门、牛牛等搜索目标。
- `singlefeaturesTransformation`：留色、去色、补底、指定牌切顶/底、看手等牌堆变换。
- `consecutiveReport`：多轮聚合条件。
- `positionToReport`：目标位置输出方式。
- `colorSingleFeaturePos`：哪张牌提供打色数值。
- `specifiedRCHand`：是否播报指定/赢家手牌。
- `differentDeal`、`dealFormation`：特殊发牌变换。
- `cutSingleFeatureProcession`：视觉看牌序列应如何解释。

值 `-1` 通常代表关闭/不适用。详细整数含义已写在 `ReportClass` 属性上方的源码注释中，添加新值时必须同步注释和本文。

## 7. `DatasetReporter` 阶段

高层处理顺序：

1. 根据 reportID 取 `ReportClass`，根据 DatasetIndex 取函数。
2. 解析 `newArgs = [dealNum, dealType, actualRcNum] + datasetArgs`。
3. 根据 `cutStructList` 预处理看底、看顶、照顶去牌、看手或看色；照顶去牌会先从牌序删除所有已识别顶牌。
4. 处理特殊看手/看色的连续输入完整性；未收集足够牌时可提前返回。
5. 按 `reportCutRange` 生成候选切牌/去牌位置。
6. 对每个候选应用 `singlefeaturesTransformation` 与打色规则。
7. 调用数据集 `FindWinner` 得到一轮标准结果。
8. 计算目标玩家集合、平局、对子、平点、活门、颜色牌等 `SingleReportResultInfo`。
9. 对多轮报法保存/比较 `multiRoundInfo`。
10. `reportStringGenerator` 把结构化结果转为二维 `SpeakResultStruct`。
11. 决定 `leftSingleFeatures` 与 `returnSingleFeatureArray`，供 UI 和下一轮继续使用。

这个函数既是搜索器又是状态转换器。修改某个报法前应先用 reportID 在以下位置全局搜索：注册表、名称表、说明表、特殊集合、DatasetReporter switch、reportStringGenerator switch。

## 8. 输出结构

`MultipleReportResultInfo` 的主要字段：

- `singleResultList`：每轮结构化结果。
- `reportResult`：每轮语音片段数组。
- `returnSingleFeatureArray`：切/变换后应成为当前牌堆的数组。
- `leftSingleFeatures`：完成计算后用于下一轮的牌。
- `repeatCnt`：TTS 重复次数。
- `multiRoundInfo`、`rcWinTimes`、`winRoundIndex`：多轮搜索中间/最终数据。

`SingleReportResultInfo` 保存一轮的目标位置、各玩家结果、色牌、公牌、对子/平点/活门以及特定复杂报法的中间值。结果页只读取其中一部分；语音生成器读取更多。

## 9. 添加/修改报法的完整清单

1. 在 `LoadAllReportRules` 注册唯一 reportID 和 `ReportClass`。
2. 在 `ReportManager.allReportName` 添加用户可见名称。
3. 如需要，在 `allReportInfo` 添加说明。
4. 判断是否加入 `baodanzhang`、`kanshoupai`、`baozuidacida`、`allHandSpecialCardReport`、`allColorSpecialCardReport`。
5. 在 `DatasetReporter` 实现搜索/牌堆变换与结构化字段。
6. 在 `reportStringGenerator` 实现语音结构。
7. 校验 `ReportSettingView` 的过滤逻辑能展示它。
8. 校验两个设置页保存后 `specialCard`/`cutMode` 归一化正确。
9. 用完整牌、短牌、平局、目标不存在、多轮与下一轮场景测试。
