#!/usr/bin/env python3
"""校验 en.lproj 对「运行时真实字符串」的覆盖率。

上一版失误就是没做这一步：key 带着 Swift 会剥掉的缩进，
运行时全部匹配不上，界面看着像没翻译。
"""
import json, re, sys, glob

def unesc(x):
    return x.replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')

def load_strings(path):
    s = open(path).read()
    out = {}
    for m in re.finditer(r'^\s*"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)";', s, re.M):
        out[unesc(m.group(1))] = unesc(m.group(2))
    return out

def has_cn(t):
    return any('一' <= c <= '鿿' for c in t)

def main():
    runtime = json.load(open('runtime_cn_strings.json'))
    default_en = glob.glob('**/en.lproj/Localizable.strings', recursive=True)
    if len(sys.argv) > 1:
        en_path = sys.argv[1]
    elif default_en:
        en_path = default_en[0]
    else:
        print("找不到 en.lproj/Localizable.strings，请把路径作为参数传进来")
        return 1
    print(f"词条文件: {en_path}")
    en = load_strings(en_path)

    miss = [k for k in runtime if k not in en]
    cn_left = [k for k in runtime if k in en and has_cn(en[k])]

    print(f"运行时中文串 : {len(runtime)}")
    print(f"词条命中     : {len(runtime) - len(miss)}")
    print(f"未命中       : {len(miss)}")
    print(f"译文残留中文 : {len(cn_left)}")

    if miss:
        print("\n未命中样例:")
        for k in miss[:6]:
            print("  ", repr(k[:70]))
    if cn_left:
        print("\n残留中文样例:")
        for k in cn_left[:6]:
            print("  ", repr(en[k][:70]))

    # 行数结构校验
    bad_lines = [k for k in runtime
                 if k in en and k.count('\n') != en[k].count('\n')]
    print(f"行数结构不一致: {len(bad_lines)}")
    for k in bad_lines[:4]:
        print("  ", repr(k[:50]), "->", repr(en[k][:50]))

    ok = not miss and not cn_left and not bad_lines
    print("\n结论:", "全部通过" if ok else "有问题，需修复")
    return 0 if ok else 1

if __name__ == '__main__':
    sys.exit(main())
