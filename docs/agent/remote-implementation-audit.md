# 远程功能实施审计

审计基线：2026-08-11。范围仅为“幻影”核心识别链、手机2接收端和远程旁路；普通 `cls_main` 采集链未接入远程功能。

## 已关闭的逻辑风险

- 角色入口先分识别端/接收端；手机2不创建 `CurrentVisionObjectRecognitionViewModel`、Core ML 或相机会话。
- 远程关闭时不创建 bridge、业务连接或 LiveKit 对象。开启后的网络和720p30缩放均为现有识别输出的异步旁路，不参与 ROI、检测、牌序恢复、规则计算或本地语音返回值。
- 结果只在既有规则计算、排序和本地报法生成结束后映射为 ShowResult 展示快照；不远传玩法设置、轮次内部状态或规则对象。
- 提示与 presentation 使用持久 outbox、eventId 去重、严格单飞 sourceEventSeq；永久坏快照只从远程 outbox 隔离，会话错误保留事件并重连。
- HTTP/首条 welcome 有10秒超时；业务连接、初次媒体连接和媒体断线均带抖动指数退避。短期 token 在 pong 中刷新，过期恢复 token 自动清除后重试一次。
- 手机2以 deliverySeq 去重，执行“manual 总是抢占、不同 automatic operation 抢占、同 operation 排队”；UI 先刷新，音频随后执行。接收会话禁止自动锁屏，退出恢复原状态。
- 自动转发关闭由服务器阻断全部 automatic delivery；静默当前快照只发生在开启状态的首次连接、重连或重新开启转发。
- 全局 toast 与分层终端日志覆盖 admission、WebSocket、重连、心跳、outbox、媒体和接收投递；提示不包含序列号、token或播报正文。

## 已执行验证

```bash
xcodebuild -project lifeCatcher.xcodeproj -scheme lifeCatcher -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

结果：成功；新增 `lifeCatcher/Remote/` 文件无 Swift 并发告警。仓库当前没有 iOS 测试 target，因此协议状态机的自动化测试主要位于同级 server/desktop 仓库。

## 仅剩实施/性能验证

- 用真实 iPhone 验证前后摄像头方向、镜像、720p30持续帧率、识别高帧率同时编码时的温度/电量/内存与本地识别准确率。
- 当前大陆固定 EIP 需要做 Wi-Fi、蜂窝、VPN、网络切换和20秒租约内外的端到端验证；新加坡仍未配置。绑定域名后补 TLS/TURN-TLS 验证并移除明文直连放宽。
- 验证各 iOS 中文声音下男女声意图、语速、重复次数和蓝牙 A2DP 路由；不同系统音色本来不要求一致。
- 用预期最长离线时长和识别频率测量 source presentation outbox 的磁盘量与重连补发耗时，再据真实容量决定是否需要产品化保留上限。

序列号作为唯一监听凭据、以及服务器单点/持久化，均按产品决定明确不纳入本阶段风险整改。
