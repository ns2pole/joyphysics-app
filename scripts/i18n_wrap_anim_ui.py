#!/usr/bin/env python3
"""Wrap Japanese UI string literals in animation files with animL(ja, en).

Usage:
  python3 scripts/i18n_wrap_anim_ui.py
  python3 scripts/i18n_wrap_anim_ui.py --dry-run
  python3 scripts/i18n_wrap_anim_ui.py --only dynamics

Requires scripts/anim_ui_en_map.json (ja → en). Builds it from
scripts/_anim_ui_en_part_{a,b,c,d}.json (+ seed) if the merged map is missing.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib" / "experiment"
MAP_PATH = ROOT / "scripts" / "anim_ui_en_map.json"
IMPORT_LINE = "import 'package:joyphysics/l10n/anim_ui.dart';\n"

JP_RE = re.compile(r"[\u3040-\u30ff\u4e00-\u9fff]")
CTOR_START_RE = re.compile(r"(?:createWaveVideo|Video)\s*\(")
# Single-line / ordinary strings only. Triple-quoted article HTML is skipped.
STR_RE = re.compile(
    r"(?<![\w$])(r)?('([^'\\]*(?:\\.[^'\\]*)*)'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\")"
)
TRIPLE_RE = re.compile(r"(?<![\w$])r?(?:'''|\"\"\")")


def _normalize_map_text(s: str) -> str:
    """JSON parts often store newline as the two chars \\ n.

    Do NOT rewrite \\t — that would corrupt LaTeX like \\theta / \\text.
    """
    return s.replace("\\n", "\n")


def load_map() -> dict[str, str]:
    parts: dict[str, str] = {}
    seed = ROOT / "scripts" / "_anim_ui_en_seed.json"
    if seed.exists():
        parts.update(json.loads(seed.read_text(encoding="utf-8")))
    extra = ROOT / "scripts" / "_anim_ui_en_extra.json"
    if extra.exists():
        parts.update(json.loads(extra.read_text(encoding="utf-8")))
    for part in "abcd":
        p = ROOT / "scripts" / f"_anim_ui_en_part_{part}.json"
        if p.exists():
            parts.update(json.loads(p.read_text(encoding="utf-8")))
    if MAP_PATH.exists() and not parts:
        parts = json.loads(MAP_PATH.read_text(encoding="utf-8"))
    if not parts and MAP_PATH.exists():
        parts = json.loads(MAP_PATH.read_text(encoding="utf-8"))

    # Prefer freshly merged parts; always refresh map file when parts exist.
    norm: dict[str, str] = {}
    for k, v in parts.items():
        kn = _normalize_map_text(k)
        vn = _normalize_map_text(v)
        norm[k] = vn
        norm[kn] = vn
        # Also keep raw body form with escaped newlines as keys
        norm[kn.replace("\n", "\\n")] = vn
    MAP_PATH.write_text(
        json.dumps({k: v for k, v in parts.items()}, ensure_ascii=False, indent=2)
        + "\n",
        encoding="utf-8",
    )
    return norm


def ctor_ranges(text: str) -> list[tuple[int, int]]:
    """Balanced ranges for Video(...) / createWaveVideo(...), incl. triple quotes."""
    ranges: list[tuple[int, int]] = []
    for m in CTOR_START_RE.finditer(text):
        i = text.find("(", m.start())
        if i < 0:
            continue
        depth = 0
        j = i
        while j < len(text):
            if text.startswith(("r\"\"\"", "r'''"), j):
                q = text[j + 1 : j + 4]
                end = text.find(q, j + 4)
                if end < 0:
                    break
                j = end + 3
                continue
            if text.startswith(("\"\"\"", "'''"), j):
                q = text[j : j + 3]
                end = text.find(q, j + 3)
                if end < 0:
                    break
                j = end + 3
                continue
            ch = text[j]
            if ch in ("'", '"'):
                q = ch
                j += 1
                while j < len(text):
                    if text[j] == "\\":
                        j += 2
                        continue
                    if text[j] == q:
                        j += 1
                        break
                    j += 1
                continue
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0:
                    ranges.append((m.start(), j + 1))
                    break
            j += 1
    return ranges


def triple_ranges(text: str) -> list[tuple[int, int]]:
    """Ranges of r'''...''' / '''...''' / r\"\"\"...\"\"\" to skip entirely."""
    ranges: list[tuple[int, int]] = []
    i = 0
    while i < len(text):
        m = TRIPLE_RE.search(text, i)
        if not m:
            break
        quote = text[m.end() - 1] * 3
        start = m.start()
        end = text.find(quote, m.end())
        if end < 0:
            break
        ranges.append((start, end + 3))
        i = end + 3
    return ranges


def in_ranges(pos: int, ranges: list[tuple[int, int]]) -> bool:
    return any(a <= pos < b for a, b in ranges)


def dart_escape(s: str, quote: str) -> str:
    out = []
    for ch in s:
        if ch == "\\" or ch == quote:
            out.append("\\" + ch)
        elif ch == "\n":
            out.append("\\n")
        elif ch == "\r":
            out.append("\\r")
        else:
            out.append(ch)
    return "".join(out)


def unescape_body(body: str) -> str:
    return (
        body.replace(r"\\", "\0")
        .replace(r"\'", "'")
        .replace(r"\"", '"')
        .replace(r"\n", "\n")
        .replace(r"\r", "\r")
        .replace("\0", "\\")
    )


def already_wrapped(text: str, lit_start: int) -> bool:
    prefix = text[max(0, lit_start - 12) : lit_start]
    return bool(re.search(r"animL\s*\(\s*$", prefix))


def lookup_en(en_map: dict[str, str], ja: str, body: str) -> str | None:
    for key in (ja, body, ja.replace("\n", "\\n"), body.replace("\n", "\\n")):
        if key in en_map:
            return en_map[key]
    return None


def should_skip_ja(ja: str) -> bool:
    if ja.startswith("package:") or ja.startswith("assets/"):
        return True
    # Article HTML kept on Video.latex / companion consts — not animL UI.
    if "common-box" in ja or "<div" in ja or "<p>" in ja:
        return True
    if "const String" in ja or "void _" in ja or "Canvas canvas" in ja:
        return True
    return False


def _mask_ranges_with_spaces(text: str, ranges: list[tuple[int, int]]) -> str:
    """Replace ranges with spaces so STR_RE cannot cross them (same length)."""
    if not ranges:
        return text
    chars = list(text)
    for a, b in ranges:
        for i in range(a, min(b, len(chars))):
            chars[i] = " " if chars[i] != "\n" else "\n"
    return "".join(chars)


def _interpolation_ranges(text: str) -> list[tuple[int, int]]:
    """Ranges of ${...} (balanced braces) that break naive string regexes."""
    ranges: list[tuple[int, int]] = []
    i = 0
    while True:
        j = text.find("${", i)
        if j < 0:
            break
        depth = 0
        k = j + 1  # at '{'
        while k < len(text):
            ch = text[k]
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    ranges.append((j, k + 1))
                    i = k + 1
                    break
            k += 1
        else:
            break
        if k >= len(text):
            break
    return ranges


def collect_matches(
    text: str, skip: list[tuple[int, int]]
) -> list[tuple[int, int, str, str, str]]:
    """Return list of (start, end, ja, body, quote) for wrappable literals."""
    # Mask triples / article ctors / ${...} so STR_RE does not desync quotes.
    scan = _mask_ranges_with_spaces(
        text, skip + _interpolation_ranges(text)
    )
    out: list[tuple[int, int, str, str, str]] = []
    for m in STR_RE.finditer(scan):
        if in_ranges(m.start(), skip):
            continue
        # Immediately after a triple-quote opener residue — ignore empty ''
        if m.group(0) in ("''", '""', "r''", 'r""'):
            continue
        # Read body from the original text (scan only used for boundaries).
        full = text[m.start() : m.end()]
        raw_prefix = full.startswith("r'") or full.startswith('r"')
        quote = full[1] if raw_prefix else full[0]
        body = full[(2 if raw_prefix else 1) : -1]
        if body is None:
            continue
        ja = unescape_body(body)
        if not JP_RE.search(ja):
            continue
        if should_skip_ja(ja):
            continue
        # Nested quotes inside ${...} break naive literal matching — skip.
        if "${" in body and (
            "['" in body
            or '["' in body
            or (body.count("'") > 0 and "params[" in body)
        ):
            # If the extracted body looks truncated at params[, skip.
            if (
                body.rstrip().endswith("params[")
                or "params['" in body
                or 'params["' in body
            ):
                continue
        if already_wrapped(text, m.start()):
            continue
        line_start = text.rfind("\n", 0, m.start()) + 1
        line_prefix = text[line_start : m.start()].lstrip()
        if line_prefix.startswith("//"):
            continue
        # Skip raw prefix only if it is a normal single-quoted raw string; still wrap.
        out.append((m.start(), m.end(), ja, body, quote))
    return out


def merge_adjacent(
    text: str, matches: list[tuple[int, int, str, str, str]]
) -> list[tuple[int, int, list[str], str]]:
    """Merge adjacent string-literal concatenations.

    Returns (start, end, ja_segments, quote).
    """
    if not matches:
        return []
    groups: list[tuple[int, int, list[str], str]] = []
    i = 0
    while i < len(matches):
        start, end, ja, _body, quote = matches[i]
        segs = [ja]
        j = i + 1
        while j < len(matches):
            gap = text[end : matches[j][0]]
            if gap.strip() != "":
                break
            # only whitespace / newlines between literals → Dart concatenation
            segs.append(matches[j][2])
            end = matches[j][1]
            j += 1
        groups.append((start, end, segs, quote))
        i = j
    return groups


def wrap_file(path: Path, en_map: dict[str, str], dry_run: bool) -> tuple[int, list[str]]:
    original = path.read_text(encoding="utf-8")
    text = original
    skip = ctor_ranges(text) + triple_ranges(text)
    matches = collect_matches(text, skip)
    groups = merge_adjacent(text, matches)

    replacements: list[tuple[int, int, str]] = []
    missing: list[str] = []
    wrapped_names: set[str] = set()

    for start, end, segs, quote in groups:
        en_segs: list[str] = []
        ok = True
        for ja_seg in segs:
            en_seg = lookup_en(en_map, ja_seg, ja_seg.replace("\n", "\\n"))
            if en_seg is None:
                missing.append(ja_seg)
                ok = False
                break
            en_segs.append(en_seg)
        if not ok:
            continue
        ja = "".join(segs)
        en = "".join(en_segs)

        use_quote = quote
        if use_quote == "'" and ("'" in en or "'" in ja):
            use_quote = '"'
        elif use_quote == '"' and ('"' in en or '"' in ja):
            use_quote = "'"

        ja_lit = use_quote + dart_escape(ja, use_quote) + use_quote
        en_lit = use_quote + dart_escape(en, use_quote) + use_quote
        repl = f"animL({ja_lit}, {en_lit})"
        replacements.append((start, end, repl))

        before = text[max(0, start - 220) : start]
        mname = re.search(
            r"(?:const\s+)?String\s+(\w+)\s*=\s*[\s\S]*$",
            before,
        )
        if mname:
            wrapped_names.add(mname.group(1))

    if missing:
        print(f"MISSING {len(missing)} in {path.relative_to(ROOT)}")
        for s in missing[:6]:
            print("  ", repr(s)[:120])

    if not replacements:
        return 0, missing

    out = text
    for start, end, repl in sorted(replacements, key=lambda t: t[0], reverse=True):
        out = out[:start] + repl + out[end:]

    # Drop `const` only when it qualifies a call/decl that directly uses animL
    # on the same line (avoid stripping unrelated `const gap = ...` etc.).
    fixed_lines: list[str] = []
    for line in out.splitlines(keepends=True):
        if "animL(" in line and re.search(r"\bconst\b", line):
            line = re.sub(
                r"\bconst\s+(?=(?:String\s+\w+\s*=\s*)?animL\s*\()",
                "",
                line,
            )
            line = re.sub(
                r"\bconst\s+(?=(?:FormulaDisplay|Text|TextSpan|Padding)\s*\()",
                "",
                line,
            )
        fixed_lines.append(line)
    out = "".join(fixed_lines)

    # Drop `const` from `const String name =` when initializer uses animL.
    out = re.sub(
        r"const\s+(String\s+\w+\s*=\s*\n(?:\s*animL\())",
        r"\1",
        out,
    )
    out = re.sub(
        r"const\s+(String\s+\w+\s*=\s*animL\()",
        r"\1",
        out,
    )

    # Drop const on Text/ widgets whose first positional arg is a wrapped name.
    for name in wrapped_names:
        out = re.sub(
            rf"\bconst\s+(Text\s*\(\s*{name}\b)",
            r"\1",
            out,
        )

    if IMPORT_LINE not in out and "animL(" in out:
        lines = out.splitlines(keepends=True)
        insert_at = 0
        for i, line in enumerate(lines):
            if line.startswith("import "):
                insert_at = i + 1
        lines.insert(insert_at, IMPORT_LINE)
        out = "".join(lines)

    if not dry_run and out != original:
        path.write_text(out, encoding="utf-8")
    return len(replacements), missing


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument(
        "--only",
        choices=["dynamics", "thermoDynamics", "waves", "all"],
        default="all",
    )
    args = ap.parse_args()
    en_map = load_map()
    total = 0
    files = 0
    all_missing: list[str] = []

    roots = {
        "dynamics": [LIB / "dynamics" / "animations"],
        "thermoDynamics": [LIB / "thermoDynamics" / "animations"],
        "waves": [LIB / "waves" / "animations"],
        "all": [LIB],
    }[args.only]

    paths: list[Path] = []
    for root in roots:
        paths.extend(sorted(root.rglob("**/animations/**/*.dart" if root == LIB else "**/*.dart")))
    # de-dupe
    seen: set[Path] = set()
    uniq_paths: list[Path] = []
    for p in paths:
        if p in seen:
            continue
        if "animations" not in p.parts:
            continue
        seen.add(p)
        uniq_paths.append(p)

    for path in uniq_paths:
        n, missing = wrap_file(path, en_map, args.dry_run)
        all_missing.extend(missing)
        if n:
            files += 1
            total += n
            print(f"{n:4d}  {path.relative_to(ROOT)}")
    print(f"wrapped {total} literals in {files} files (map size {len(en_map)})")
    if all_missing:
        uniq = list(dict.fromkeys(all_missing))
        print(f"still missing {len(uniq)} unique strings")
        (ROOT / "scripts" / "_anim_ui_still_missing.json").write_text(
            json.dumps(uniq, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


if __name__ == "__main__":
    main()
