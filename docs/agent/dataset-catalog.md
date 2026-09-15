# 数据集目录与稳定映射

`DatasetIndex` 是持久化协议。已有方案把整数写入 UserDefaults，因此不可重新排序或复用旧 ID。

| ID | 显示名 | 文件 | Rule | 数据集入口 | 手牌求值器 | 主要可配置维度 |
|---:|---|---|---|---|---|---|
| 0 | 德州 | `TPok.swift` | `TPRule` | `TP` | `HandAnalyst` | 花色比较、A 顺子、最小点、手牌/公牌使用数 |
| 1 | 牛牛 | `PBul.swift` | `PBRule` | `PB` | `BullHandAnalyst` | 发牌、花色、五小、炸弹/特殊牛、JQK/王点值、牌型规则 |
| 2 | 炸金花 | `ZJHua.swift` | `ZJHDatasetRule` | `ZJHDataset` | `ZJHDatasetHandAnalyst` | 手牌数、最小点、比花色、A 顺子、特殊头牌/大小王 |
| 3 | 小九 | `TNin.swift` | `TNDatasetRule` | `TNDataset` | `TNDatasetHandAnalyst` | 大小王点值、同点比较、花色 |
| 4 | 三公 | `TMen.swift` | `TMDatasetRule` | `TMDataset` | `TMDatasetHandAnalyst` | 点数/同点、A 作公、花色、三牌/混公比较 |
| 5 | 二八杠 | `TEGan.swift` | `TEGDatasetRule` | `TEGDataset` | `TEGDatasetHandAnalyst` | 同点、花色、JQK 点值、点数比较 |
| 6 | 九点半 | `NPFive.swift` | `NPFiveDatasetRule` | `NPFiveDataset` | `NPFiveDatasetHandAnalyst` | JQK/王点值、同点、对子等级与要求 |
| 7 | 宝子 | `BZi.swift` | `BZDatasetRule` | `BZDataset` | `BZDatasetHandAnalyst` | JQK/A/王点值、同点/花色、单牌/对子优先级 |
| 8 | 佳佳宝 | `JJBao.swift` | `JJBDatasetRule` | `JJBDataset` | `JJBDatasetHandAnalyst` | 同点、牌点序、JQK/王、手牌数、花色 |
| 9 | 牌九 | `CNin.swift` | `CNDatasetRule` | `CNDataset` | `CNDatasetHandAnalyst` | JQK/A/王、点数/同点、对子/单牌等级、手牌数 |
| 10 | 九点 | `NPoi.swift` | `NPDatasetRule` | `NPDataset` | `NPDatasetHandAnalyst` | JQK/王、同点、花色、手牌数、单牌等级 |
| 11 | 四张 | `FCar.swift` | `FCDatasetRule` | `FCDataset` | `FCDatasetHandAnalyst` | JQK/王、点数/同点、单牌等级 |
| 12 | 两张 | `TCar.swift` | `TCDatasetRule` | `TCDataset` | `TCDatasetHandAnalyst` | JQK/王、点数/同点、单牌等级 |
| 13 | 三张 | `TCPoi.swift` | `TCPDatasetRule` | `TCPDataset` | `TCPDatasetHandAnalyst` | JQK/王、同点、花色、点数 |
| 14 | 十点半 | `TPFive.swift` | `TPFiveDatasetRule` | `TPFiveDataset` | `TPFiveDatasetHandAnalyst` | JQK/王、同点、花色、点数、单牌等级 |
| 15 | 比鸡 | `CBat.swift` | `CBDatasetRule` | `CBDataset` | `CBDatasetHandAnalyst` | 胜负条件、A 顺子下限、特殊牌变换、三墩规则 |
| 16 | 十三水 | `TWat.swift` | `TWDatasetRule` | `TWDataset` | `TWDatasetHandAnalyst` | 胜负条件、A 顺子下限、打枪/双倍等规则 |
| 17 | 梭哈 | `Ain.swift` | `AinRule` | `Ain` | `AinHandAnalyst` | 与德州类似的花色、A 顺子、最小点、用牌数 |
| 18 | 跑的快 | `RFast.swift` | `RFastDatasetRule` | `RFastDataset` | `RFastDatasetHandAnalyst` | JQK/王、同点、花色、12/16 张、单牌等级与组合型 |

## 每个数据集的内部模板

虽然命名不完全一致，大多数文件遵循：

```text
*Rule
  ├─ option dictionaries / rcNum / setting / rankRules / ruleInfo
  └─ init registers presets visible to UI

*Dataset or short facade
  ├─ FindWinner
  ├─ getMinSingleFeatureNum
  ├─ getAllSingleFeatureIndex
  ├─ deal/default/custom dealing helpers
  └─ return DatasetReturnRCInfo[] + left deck

*HandAnalyst
  ├─ evalHand
  ├─ rule-specific eval_* methods
  └─ comparison/rank conversion helpers
```

`SingleFeature` 的通用定义位于 `CUtils.swift`：`suit` 是花色优先列表，`rank` 是用于当前规则比较的点数，`singlefeatureIndex` 是稳定牌编码，`originalRank` 保留原始点数。

## 发牌契约

- `inputSingleFeatures` 的顺序是实际牌堆顺序，数组头部通常先发。
- 默认发牌与自定义发牌都必须返回未消费的尾部牌。
- `diyDealStatus[i]` 的三列语义由 UI 的 `TurnSettingView` 管理：派牌、公牌、去牌。
- `args` 在 `ReportManager` 前加上 `[dealNum, dealType, actualRcNum]` 成为 `newArgs`；数据集自身收到的仍是原始约定数组（具体调用路径要以函数签名和解包代码为准）。
- `getMinSingleFeatureNum` 必须与 `FindWinner` 消耗量一致，否则视觉层可能提前计算或永远认为牌数不足。

## 新增数据集需要同步的位置

1. 新建 `DatasetPkg/<Name>.swift` 并实现统一接口。
2. `ClassifierSettingArgs.targetSetting` 注册新的稳定 ID。
3. `generalRuleSetting.allDatasetType`（旧显示表，当前 Picker 主要用 `targetSetting`）。
4. `LoadAllPresetRules` 添加预设。
5. `ReportManager.DatasetReporter.DatasetFunctions`。
6. `ReportManager.DatasetReporter.minSingleFeatureFunctions`。
7. `SettingRecordConfigView.DatasetGetAllSingleFeatureIndex`。
8. 两个设置页的 `DatasetGetMinSingleFeatureNum`。
9. `CurrentVisionObjectRecognitionViewModel.DatasetGetMinSingleFeatureNum`。
10. 如结果展示需特殊排序，扩展 `computeWinnerRC` 的特殊分支。
11. 更新本表，迁移持久化并添加测试。

不要把新项插入 0...18 中间；使用下一个未占用 ID。
