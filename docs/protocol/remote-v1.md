# lifeCatcher Remote Protocol v1

## 传输与区域

- admission：`POST /v1/connect`，当前固定 IP 测试环境为 HTTP JSON；
- 业务流：`/v1/ws?token=...`，当前固定 IP 测试环境为 WS JSON；
- 媒体凭据：`POST /v1/media-token`，Bearer resume token；
- 视频：LiveKit WebRTC room，由识别端选择 1280×720 或 1920×1080，以及 30 或 60fps；source 只能发布 camera，receiver/desktop 只能订阅。

两个区域运行完全独立的同版本部署。`region` 只能为 `cn` 或 `sg`，服务器拒绝与自身区域不符的 admission。

当前明文 HTTP/WS 仅用于固定 IP 测试。绑定域名后必须迁移到 HTTPS/WSS
并启用可信证书；协议消息结构不因此改变。

## 连接标识

| 字段 | 含义 |
|---|---|
| `serial` | 手机1现有 Keychain UUID 字符串；当前唯一监听凭据 |
| `clientInstanceId` | 每个安装生成的稳定 UUID，用于断线恢复同一角色槽 |
| `connectionId` | 服务器角色槽 ID |
| `sourceSessionId` | 一次 source 服务器会话 UUID |
| `resumeToken` | 短期签名令牌，绑定 region/role/serial/client/connection |

角色为 `source`、`receiver`、`desktop`。每个 `(region, serial)` 各角色最多一台，任意角色都可先创建等待房间，不要求 source 先上线。

welcome 同时返回 `sourceOnline/receiverOnline/desktopOnline` 兼容布尔值和 `sourcePresence/receiverPresence/desktopPresence` 三态。增量消息为：

```text
source.presence   { online, state, sourceSessionId? }
receiver.presence { online, state }
desktop.presence  { online, state }
```

`state` 为 `online | reconnecting | offline`。reconnecting 表示角色槽处于断线租约宽限期，`online` 兼容字段此时为 false；客户端 UI 使用三态，但只有 online 可看实时画面或接收新命令。

识别端在连接及控制状态变化后发送：

```json
{"type":"source.state","state":{"recognitionPaused":false,"awaitingShuffle":true}}
```

服务器把该状态推送桌面端，并在后续 desktop welcome 的可选 `sourceControlState` 字段中恢复。`source.command` 的 ACK 只表示服务器已转交；桌面必须以 `source.state` 作为手机实际执行暂停、继续或进入待洗牌的权威确认。识别端进入稳定双框识别后将 `awaitingShuffle` 置回 false。

## SourceEvent

```json
{
  "schemaVersion": 1,
  "eventId": "uuid",
  "operationId": "uuid",
  "sourceSessionId": "uuid",
  "sourceEventSeq": 1,
  "createdAtMs": 0,
  "expiresAtMs": 5000,
  "payload": { "kind": "prompt", "prompt": "start" }
}
```

payload 为 `prompt {start|success|failure}` 或 `presentation`。同 sourceSession 的序号必须从 welcome 的 `nextSourceEventSeq` 开始严格加一。eventId 幂等；重复事件不重复投递。

prompt 的 `expiresAtMs-createdAtMs` 表示相对 TTL（最长5秒）。手机1先在本地 outbox 清除过期项；服务器从收到事件时重新计算短期投递期限，以免手机与服务器绝对时钟偏差造成误丢。时间戳不用于新旧排序。

## PresentationSnapshot

只传 ShowResult 所需的已计算结果和播放计划：

```text
schemaVersion
visibleDeck[]
cutCard?
rounds[]
  roundNumber
  colorCards[]
  communityCards[]
  positions[] { positionNumber, rank, handType, cards[] }
playbackPlan
  utterances[] { text, voiceIntent: male|female }
  voiceRate: 0...1
  repeatCount: 1...10
  playbackMode: joined|separate
timeDisplayCue? { kind, digits, fullDeck?, displayText? }
```

稳定牌编码为 0...51、53、54；52 不允许进入协议。不传方案、shuffleOrRiffle、规则参数、当前轮内部状态或 `ReportManager` 对象。

## ReceiverDelivery

```json
{
  "type": "receiver.delivery",
  "deliverySeq": 1,
  "origin": "automatic",
  "operationId": "uuid",
  "sourceEventSeq": 4,
  "command": { "kind": "presentation", "presentation": {} }
}
```

command 可为 `speakText`、`prompt` 或 `presentation`。桌面手动 prompt 只允许 success/failure。automatic 受 forwardingEnabled 控制；manual 不受控制。

桌面 `forwarding.set` 可同时设置 `cutResultDelaySeconds`（0...60，默认 0）。仅带 `cutCard` 的 automatic presentation 延迟投递，使手机2播报与 UI 一起延后；prompt 和无切牌结果不延迟。

服务器在手机2角色租约期内保留未 `delivery.ack` 的命令并在重连后重发；手机2按 `deliverySeq` 去重。新的 manual 或不同 operation 的 automatic 会替换旧待确认队列，同 operation 的提示与结果保持队列顺序。自动转发关闭时清除待确认 automatic；过期 prompt 不重播。

手机2的新投递要求 desktop 当前在线。desktop 离线或处于重连宽限期时，手机1事件仍进入桌面历史，但服务器不创建 automatic receiver delivery；desktop 断线会立即清除待发与未确认 automatic，恢复后不补播离线期间结果。

## 桌面历史补传

服务器只为 presentation 分配单调 `historySeq`，并在 welcome 返回频道 `historyEpoch`。桌面只在 epoch 相同时沿用旧游标；epoch 变化时先将游标归零，再发送 `{ "type": "desktop.sync", "afterHistorySeq": 0 }`，避免服务器重启后新序号被旧游标跳过。服务器每批最多返回50条 `replayed: true` 的缺失 presentation，再发 `desktop.sync.complete`；桌面完成该批落盘后才请求下一批。桌面以 eventId 去重，将事件和最新游标在 IndexedDB 同一事务中保存，删除超过 30 天的记录；replayed 事件不播放声音。

## 控制与心跳

- `forwarding.set`：desktop 改变手机2自动转发；
- `presence.update`：receiver/desktop 上报展示模式及 videoWanted；
- `source.control`：服务器将观看端 videoWanted 做 OR 后通知 source；
- `source.command`：desktop 发送带 `requestId` 的 `awaitShuffle` 或带稳定牌编码 `cutCard` 的 `recomputeCut`。服务器验证手机1在线后转发给 source 并返回 ACK。前者清空当前会话并只等待稳定双框进入识别；后者以最近一次原始识别牌序替换切牌、按当前方案重新计算，并通过正常 presentation 链路发送新结果；
- `delivery.ack`：手机2确认收到；
- `ping/pong`：业务心跳；
- `client.goodbye`：主动释放角色槽。

错误必须带稳定 `code` 和可显示 `message`。客户端对未知或结构不合法消息应拒绝处理。

pong 可带新的 `resumeToken`。客户端收到后同时替换后续 admission 恢复令牌和 `/v1/media-token` Bearer；`invalid_resume` 时清空旧 token 并自动重试一次。
