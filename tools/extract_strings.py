#!/usr/bin/env python3
"""按 Swift 的字符串字面量语义提取中文串，得到运行时真实值。

Swift 多行字符串 (\"\"\") 的规则：
- 开头 \"\"\" 后的第一个换行不算内容
- 结尾 \"\"\" 所在行的缩进，会从每一行前面剥掉
- 结尾 \"\"\" 前的最后一个换行不算内容
"""
import re, json, glob, sys

def extract_file(path):
    src = open(path).read()
    lines = src.split('\n')
    out = []          # (value, kind)
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        # 多行字符串起始：本行以 """ 结尾
        m = re.search(r'"""\s*$', line)
        if m and not line.strip().startswith('//'):
            body = []
            j = i + 1
            closing_indent = None
            while j < n:
                mc = re.match(r'^(\s*)"""', lines[j])
                if mc:
                    closing_indent = len(mc.group(1))
                    break
                body.append(lines[j])
                j += 1
            if closing_indent is not None:
                dedented = [l[closing_indent:] if len(l) >= closing_indent and l[:closing_indent].strip() == '' else l.lstrip()
                            for l in body]
                value = '\n'.join(dedented)
                if re.search(r'[一-鿿]', value):
                    out.append((value, 'multi'))
                i = j + 1
                continue
        # 单行字符串（跳过注释行、print 行）
        st = line.strip()
        if not st.startswith('//') and not re.search(r'\bprint\s*\(', line):
            for sm in re.finditer(r'"((?:[^"\\\n]|\\.)*)"', line):
                raw = sm.group(1)
                if not re.search(r'[一-鿿]', raw):
                    continue
                # 还原转义
                val = raw.replace('\\"', '"').replace('\\n', '\n').replace('\\\\', '\\')
                out.append((val, 'single'))
        i += 1
    return out

def main():
    root = sys.argv[1] if len(sys.argv) > 1 else 'lifeCatcher'
    result = {}
    for f in sorted(glob.glob(f'{root}/**/*.swift', recursive=True)):
        for val, kind in extract_file(f):
            result.setdefault(val, {'kind': kind, 'files': []})
            if f not in result[val]['files']:
                result[val]['files'].append(f)
    json.dump(result, open('runtime_cn_strings.json', 'w'), ensure_ascii=False, indent=1)
    multi = [k for k, v in result.items() if v['kind'] == 'multi']
    print("运行时中文串总数:", len(result))
    print("  多行（规则说明）:", len(multi))
    print("  单行:", len(result) - len(multi))

if __name__ == '__main__':
    main()
