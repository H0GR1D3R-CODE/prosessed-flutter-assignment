"""Summarises coverage/lcov.info (written by `flutter test --coverage`), skipping generated code.

Usage: python tool/coverage_summary.py
"""

import collections
import pathlib
import sys

LCOV = pathlib.Path("coverage/lcov.info")
IGNORED = ("lib/l10n/generated/",)


def read():
    files = {}
    current = None
    for line in LCOV.read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            current = line[3:].replace("\\", "/")
            files[current] = [0, 0]
        elif line.startswith("LF:") and current:
            files[current][0] = int(line[3:])
        elif line.startswith("LH:") and current:
            files[current][1] = int(line[3:])
    return {f: v for f, v in files.items() if not f.startswith(IGNORED)}


def layer(path):
    parts = path.split("/")
    if parts[:2] == ["lib", "core"]:
        return f"core/{parts[2]}" if len(parts) > 3 else "core"
    if parts[:2] == ["lib", "features"]:
        return f"features/{parts[2]}/{parts[3]}" if len(parts) > 4 else f"features/{parts[2]}"
    return "app"


def main():
    if not LCOV.exists():
        sys.exit("Run `flutter test --coverage` first.")
    files = read()
    groups = collections.defaultdict(lambda: [0, 0])
    for path, (found, hit) in files.items():
        groups[layer(path)][0] += found
        groups[layer(path)][1] += hit
    total_found = sum(v[0] for v in files.values())
    total_hit = sum(v[1] for v in files.values())
    for name in sorted(groups):
        found, hit = groups[name]
        print(f"{name:32} {hit:5}/{found:<5} {100 * hit / found:5.1f}%")
    print("-" * 52)
    print(f"{'TOTAL':32} {total_hit:5}/{total_found:<5} {100 * total_hit / total_found:5.1f}%")


main()
