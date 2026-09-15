# 配置、持久化与资源

## 1. 存储总表

| 位置 | 内容 | 读写入口 |
|---|---|---|
| UserDefaults `allUsersDatasetRule` | `[DatasetRule]` 用户方案 | `DetectSettingArgs.load/saveDatasetRule` |
| Documents/config.json | 相机、音频、黑屏/时间显示设置 | `create/readConfigJSON`、两个 Setting ViewModel |
| Documents/para.json | 激活时间、uniqueID、authKey 的旧/本地镜像 | `create/readParaJSON`、`SettingViewModel`、`AuthManager.authLocal` |
| Keychain `com.lifeCatcher.uniqueUUID` | 持久设备 UUID | `AuthManager.store/retrieveUUID` |
| Keychain `com.lifeCatcher.uniqueKey` | 授权 key | `AuthManager.store/retrieveAuthKey` |
| Documents/recordHistory.json | 分类 → 图片文件名数组 | JsonIO + 普通采集 ViewModel |
| Documents/recordHistory/ | 普通采集 JPEG | 普通采集 ViewModel/历史详情 |
| Documents/model/ | 临时模型目录，目前启动/退出清空 | `AppDelegate` |
| Bundle Resources | 模型、音频、图片、本地化 | Xcode target resource phase |

## 2. `config.json`

结构：

```json
{
  "Int": {
    "volumeUp": 0,
    "volumeDown": 0,
    "blackMode": 0,
    "voiceDevice": 0,
    "timeMode": 0,
    "addCardMode": 1
  },
  "Float": {
    "volumeValue": 0.5,
    "voiceRate": 0.5,
    "zoomFactor": 0,
    "focusFactor": 0.6,
    "blackFactor": 0
  },
  "Bool": {
    "isBackCamera": true,
    "isCameraHorizon": false,
    "isHighHz": true,
    "isMaxLightness": false
  },
  "Version": "2.0.5"
}
```

`createConfigJSON` 若发现文件中的 Version 与 `AuthManager.version` 不同，会整文件覆盖为默认值，不做字段迁移。所有读取都大量使用 `as!` 和 `!`；增加字段时必须同步默认创建和所有写出实现，否则旧文件会崩溃。

写入实现有两份：`SettingViewModel.updateConfigJSON` 与当前识别 ViewModel 的同名方法。字段必须保持一致。

## 3. 用户方案生命周期

启动：

```text
UserDefaults Data
  → JSONDecoder [DatasetRule]
  → DetectSettingArgs.allUsersDatasetRule
```

编辑：设置页将方案字段复制到 `@State`，玩法/预设变更时从 `allPreSetRules` 重建 `args`、`suitRules`、`rankRules` 和可用牌。

保存：创建新的 `DatasetRule`，追加或替换全局数组，再 JSONEncoder 写回 UserDefaults。

运行：`CurrentVisionObjectRecognitionViewModel.loadSaveRule` 将方案复制到运行时属性；音量键修改部分字段后 `saveData` 会重新构造并覆盖方案。

## 4. 方案中的索引和值

最常见错误是混淆“选项索引”和“业务值”：

- `DatasetType`：直接业务 ID。
- `setting`：`Rule.setting` 的键/索引。
- `rcNum`：`Rule.rcNum` 数组索引；实际人数需再次索引。
- `reportSetting`：直接 reportID，不是列表位置。
- `rankRules`：直接规则 ID 数组。
- `suitRanks`：直接花色优先级值。
- `args`：大多是选项索引，数据集通过自己的字典/逻辑解释。

## 5. 双槽设置

下列字段固定长度应为 2：

```text
index 0 = shuffle/洗牌
index 1 = riffle/拨牌

shuffleMode[0]  0/1/2
shuffleMode[1]  0/1/2
cutMode[0...1]
reportSetting[0...1]
specialCard[0...1]
```

`shuffleMode[0]` 中 0 表示不洗、1 表示普通洗牌、2 表示横洗；横洗不新增槽位，仍使用洗牌的切牌/报法设置。完整设置页允许洗牌与拨牌同时开启；leishen 页提供普通洗牌、拨到顶、拨中间、横洗四选一。运行时通过 `shuffleOrRiffle` 选择对应槽位。

`cutMode` 的 UI 稳定编码为：0 无、1 看底、2 看顶、3 连续看底、4 看手牌、5 连续看顶、6 照顶去牌、7 连续照顶去牌。模式 6/7 将照到的顶牌从当前牌堆移除后再进入发牌与报法计算，结果页和远程 presentation 的牌堆也使用移除后的数组。看色报法仍只允许 0/1/2。

横洗不改变方向协议，也没有新增方向字段。全局 `isCameraHorizon` 同时决定分类模型、ROI 形变和两堆牌排列：普通流程横屏使用横向模型/ROI并按 X 轴处理，纵屏使用纵向模型/ROI并按 Y 轴处理；横洗横竖屏共用 `cls_20260915_texas`，ROI 比例分别为 16:9 与 9:16。`shuffleMode[0] == 2` 只区分横洗业务模式。

## 6. 牌资源编码

- 0...12：黑桃 A...K。
- 13...25：红桃 A...K。
- 26...38：梅花 A...K。
- 39...51：方片 A...K。
- 52：模型标签中的 none/特殊占位，不应进入规则牌堆。
- 53：小王。
- 54：大王。

通用计算：`rank = index % 13`，`suit = index / 13` 仅适用于 0...51；王必须单独处理。

Core ML 输出在当前视觉代码中把类别 52 映射为 54。模型训练标签、历史分类标签与规则牌编码并非完全同一协议，更换模型时必须逐项核对。

## 7. Core ML 资源

核心运行使用：

- `detect_0903.mlmodel`
- `detect_20260915_texas.mlmodel`（横洗检测）
- `cls_20260915_texas.mlmodel`（横洗分类）
- `cls_1215_h.mlmodel`
- `cls_1215_v.mlmodel`
- `riffle_detect_1111.mlmodel`
- `riffle_cls_h_1107.mlmodel`
- `riffle_cls_v_1107.mlmodel`

普通采集使用 `cls_main.mlmodel`。

`cls_0715_h_trans`、`cls_0727_v_trans` 及 `.mlmodelkey` 是历史/备用资源，当前实例化代码已注释。`AppDelegate` 仍保留整段历史模型解密方案，但不执行。

下载地址与访问方式见 [`model-server.md`](model-server.md)。

## 8. 音频与图片资源

- 提示音：`start_voice.mp3`、`success_voice.mp3`、`fail_voice.mp3`。
- `Assets.xcassets`：应用图标、AccentColor。
- `Resources/IC.xcassets`：按钮与展示图标。
- `Resources/BG.xcassets`：背景图。
- `en.lproj` 与 `zh-Hans.lproj`：Localize-Swift 字符串。

SwiftUI 中大量资源按字符串查找，Xcode 不会在编译期验证拼写。

## 9. 数据迁移建议

当前仓库没有显式 schema version。若必须更改结构：

1. 先为新字段提供自定义 `Decodable` 默认值。
2. 读取旧配置后规范化双槽数组长度、rcNum 范围和 reportID 存在性。
3. 不要依赖 App 版本不一致直接清空用户方案；UserDefaults 方案目前也不会随 `config.json` Version 重置。
4. 增加迁移后的写回和最小构建/单元测试。

## 本地/远程识别模式

`RemotePreferences.recognitionMode` 使用 UserDefaults 的 `recognition.mode`，值为 `remote` / `local`；缺失或无效值默认为远程，兼容现有安装。仅决定识别端连接、本地音频与结果显示，不改变方案、接收端或 ROI/规则参数。功能设置提供切换；本地模式读取原 `config.json` 的音频与时间配置，远程运行时强制 timeMode=0，但两份设置写入流程不会把原保存的时间模式覆盖为 0。
