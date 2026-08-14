# i18n 工具

改完界面文案后跑一遍，确认英文词条没漏、没对不上。

```bash
cd <仓库根目录>
python3 tools/extract_strings.py lifeCatcher     # 提取代码里的中文（运行时真实值）
python3 tools/verify_i18n.py                     # 校验 en.lproj 覆盖率
```

`verify_i18n.py` 报「未命中」就说明有文案在英文下会显示成中文，补 `en.lproj` 即可。

## 为什么要专门做这个校验

Swift 的多行字符串（`"""`）在编译时会把结尾 `"""` 那一行的缩进从每行前面剥掉。
如果直接从源码里连着缩进抄成 `Localizable.strings` 的 key，运行时就永远匹配不上，
界面看起来像没翻译。`extract_strings.py` 按 Swift 的规则还原运行时真实值，避免这个坑。
