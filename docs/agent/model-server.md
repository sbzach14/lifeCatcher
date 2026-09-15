# 模型文件处理服务器

## 定位与访问

来源：Card 项目 `docs/nine-source-fivefold-20260911.md` 的“所有数据处理”记录。
本机 Card 工作目录：`/Users/macbookair/Desktop/Card`。

- AWS EC2 实例：`i-0032bef13212b8e2a`。
- Region：`us-east-1`。
- AWS CLI profile：`lifecatcher-sg`（名称含 sg，但该实例在 us-east-1）。
- 2026-09-15 实测公网 IP：`3.239.148.180`；IP 可能变化，应按实例 ID 查询。
- 文件根目录：`/home/ubuntu/card-data/`。
- 访问方式：现有 AWS 身份通过 Systems Manager（SSM）执行文件查询；不是公开 HTTP 下载站。
- 模型交接桶：`s3://lifecatcher-card-training-429583250861-us-east-1/horizontal-shuffle/v1/handoffs/`。

查询当前地址：

```bash
aws ec2 describe-instances --profile lifecatcher-sg --region us-east-1 \
  --instance-ids i-0032bef13212b8e2a \
  --query 'Reservations[].Instances[].{State:State.Name,IP:PublicIpAddress}' --output json
```

用 `aws ssm send-command`（`AWS-RunShellScript`）读取文件清单与 SHA-256，
用 `get-command-invocation` 确认执行成功。下载可通过同一账户的 S3 交接目录中转，
本地 `aws s3 cp` 完成后必须核对远端 SHA-256。不要将凭据写入仓库。

此服务器属于模型/训练数据处理链路，不是手机远程识别的 LiveKit/业务服务器；
替换模型不修改 App 服务地址。

## 2026-09-15 横洗检测模型

- 远端源：`/home/ubuntu/card-data/detect640-coreml-20260915/normalized/detect-20260915-texas.mlmodel`。
- S3：`s3://lifecatcher-card-training-429583250861-us-east-1/horizontal-shuffle/v1/handoffs/detect-coreml-20260915/detect-20260915-texas.mlmodel`。
- App 资源：`lifeCatcher/Resources/detect_20260915_texas.mlmodel`；本地文件名用下划线以生成 Swift 类型 `detect_20260915_texas`，模型内容不变。
- SHA-256：`0e111dd26f8ddd65f2e18a4ee769ebcd7f351107bab05fe76d849b05c49fa1fe`（远端与本地一致）。
- 协议：RGB 640×640，单类 `card_corner`，pipeline 内置 NMS；输入 `image`、`iouThreshold`、`confidenceThreshold`，输出 `confidence`（N×1）、`coordinates`（N×4，归一化中心 XYWH）。
- 路由：仅 `shuffleMode[0] == 2` 的全帧检测使用新模型；横洗 ROI 分类仍为 `cls_20260915_texas`。
- 编译沿用现有 `detect_0903.mlmodelkey` 加密设置；模型默认阈值由运行时现有 IOU 0.2 / confidence 0.7 覆盖。

在仓库根目录下载：

```bash
aws s3 cp \
  s3://lifecatcher-card-training-429583250861-us-east-1/horizontal-shuffle/v1/handoffs/detect-coreml-20260915/detect-20260915-texas.mlmodel \
  lifeCatcher/Resources/detect_20260915_texas.mlmodel \
  --profile lifecatcher-sg --region us-east-1 --only-show-errors
shasum -a 256 lifeCatcher/Resources/detect_20260915_texas.mlmodel
```
