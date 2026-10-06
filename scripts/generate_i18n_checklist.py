#!/usr/bin/env python3
"""Generate i18n article/animation checklists and allowlists for JoyPhysics.

Usage:
  python3 scripts/generate_i18n_checklist.py
"""

from __future__ import annotations

import json
import re
from collections import defaultdict
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
DOCS = ROOT / "docs"
TEST_L10N = ROOT / "test" / "l10n"

JP_RE = re.compile(r"[\u3040-\u30ff\u4e00-\u9fff]")
STR_RE = re.compile(r"'([^'\\]*(?:\\.[^'\\]*)*)'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\"")
CTOR_START_RE = re.compile(r"(?:createWaveVideo|Video)\s*\(")
ANIM_WRAPPER_RE = re.compile(
    r"animL\s*\(\s*(?:'([^'\\]*(?:\\.[^'\\]*)*)'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\")\s*,\s*"
    r"(?:'([^'\\]*(?:\\.[^'\\]*)*)'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\")\s*\)"
    r"|animUi(?:ForLang)?\s*\([^;]*?ja\s*:\s*(?:'([^'\\]*(?:\\.[^'\\]*)*)'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\")"
    r"[^;]*?en\s*:\s*(?:'([^'\\]*(?:\\.[^'\\]*)*)'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\")",
    re.S,
)


def strip_line_comments(text: str) -> str:
    return re.sub(r"//.*?$", "", text, flags=re.M)


def _mask_paren_block(text: str, open_paren_index: int) -> str:
    depth = 0
    in_str = None
    escape = False
    for j in range(open_paren_index, len(text)):
        ch = text[j]
        if in_str:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == in_str:
                in_str = None
            continue
        if ch in ("'", '"'):
            in_str = ch
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return (
                    text[:open_paren_index]
                    + (" " * (j - open_paren_index + 1))
                    + text[j + 1 :]
                )
    return text


def strip_article_ctors(text: str) -> str:
    out = text
    while True:
        m = CTOR_START_RE.search(out)
        if not m:
            break
        open_i = out.find("(", m.start())
        if open_i < 0:
            break
        nxt = _mask_paren_block(out, open_i)
        if nxt == out:
            break
        out = nxt
    return out


def mask_bilingual_wrappers(text: str) -> str:
    """Mask animL(...)/animUi(...) calls via balanced parentheses (handles ${...})."""
    out = text
    for name in ("animL", "animUiForLang", "animUi"):
        start_re = re.compile(rf"\b{name}\s*\(")
        while True:
            m = start_re.search(out)
            if not m:
                break
            open_i = out.find("(", m.start())
            nxt = _mask_paren_block(out, open_i)
            if nxt == out:
                break
            out = nxt
    # Also drop article-like HTML situation companions (latex HTML not in Video ctor).
    out = re.sub(
        r"'[^']*common-box[^']*'|\"[^\"]*common-box[^\"]*\"",
        lambda m: " " * len(m.group(0)),
        out,
    )
    out = re.sub(
        r"'[^']*<div[^']*'|\"[^\"]*<div[^\"]*\"",
        lambda m: " " * len(m.group(0)),
        out,
        flags=re.I,
    )
    return out


def extract_ctor_block(text: str, start: int) -> str:
    """Extract balanced parentheses block starting at '(' after ctor name."""
    i = text.find("(", start)
    if i < 0:
        return ""
    depth = 0
    in_str = None
    escape = False
    for j in range(i, len(text)):
        ch = text[j]
        if in_str:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == in_str:
                in_str = None
            continue
        if ch in ("'", '"'):
            # raw strings r''' / r"""
            in_str = ch
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return text[i + 1 : j]
    return ""


def field_string(block: str, name: str) -> str | None:
    m = re.search(
        rf"{name}\s*:\s*(?:r)?(?:'''([\s\S]*?)'''|\"\"\"([\s\S]*?)\"\"\"|'((?:\\'|[^'])*)'|\"((?:\\\"|[^\"])*)\")",
        block,
    )
    if not m:
        return None
    for g in m.groups():
        if g is not None:
            return g
    return None


def field_bool(block: str, name: str) -> bool | None:
    m = re.search(rf"{name}\s*:\s*(true|false)", block)
    if not m:
        return None
    return m.group(1) == "true"


def field_list_len(block: str, name: str) -> int:
    m = re.search(rf"{name}\s*:\s*\[([\s\S]*?)\]", block)
    if not m:
        return 0
    body = m.group(1).strip()
    if not body:
        return 0
    return len(re.findall(r"'[^']*'|\"[^\"]*\"", body))


def substantial(text: str | None, min_chars: int = 50) -> bool:
    if not text:
        return False
    return len(text.strip()) >= min_chars


def _count_math(text: str) -> int:
    return len(
        re.findall(
            r"\$\$[\s\S]+?\$\$|\$[^$]+\$|\\\([\s\S]+?\\\)|\\\[[\s\S]+?\\\]",
            text,
        )
    )


def parse_definitions() -> dict[str, dict]:
    defs: dict[str, dict] = {}
    patterns = [
        ("experiment", re.compile(r"final\s+(\w+)\s*=\s*Video\s*\(")),
        ("experiment", re.compile(r"final\s+(\w+)\s*=\s*createWaveVideo\s*\(")),
        ("theory", re.compile(r"final\s+(\w+)\s*=\s*TheoryTopic\s*\(")),
    ]
    for path in LIB.rglob("*.dart"):
        if path.name == "model.dart":
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        rel = str(path.relative_to(ROOT))
        for kind, pat in patterns:
            for m in pat.finditer(text):
                article_id = m.group(1)
                block = extract_ctor_block(text, m.start())
                title = field_string(block, "title") or article_id
                if kind == "theory":
                    latex = field_string(block, "latexContent") or ""
                    latex_en = field_string(block, "latexContentEn")
                    title_en = field_string(block, "titleEn")
                    prep = field_bool(block, "inPreparation") is True
                    needs_body = substantial(latex)
                    complete = bool(title_en and title_en.strip()) and (
                        (not needs_body) or bool(latex_en and latex_en.strip())
                    )
                    defs[article_id] = {
                        "id": article_id,
                        "kind": "theory",
                        "title": title,
                        "file": rel,
                        "inPreparation": prep,
                        "needsBody": needs_body,
                        "needsEquipment": False,
                        "hasTitleEn": bool(title_en and title_en.strip()),
                        "hasLatexEn": bool(latex_en and latex_en.strip()),
                        "hasEquipmentEn": True,
                        "titleEn": (title_en or "").strip(),
                        "latexJaChars": len(latex.strip()),
                        "latexEnChars": len((latex_en or "").strip()),
                        "mathJa": _count_math(latex),
                        "mathEn": _count_math(latex_en or ""),
                        "latexEn": latex_en or "",
                        "complete": complete,
                    }
                else:
                    latex = field_string(block, "latex") or ""
                    latex_en = field_string(block, "latexEn")
                    title_en = field_string(block, "titleEn")
                    prep = field_bool(block, "inPreparation") is True
                    equip_n = field_list_len(block, "equipment")
                    equip_en_n = field_list_len(block, "equipmentEn")
                    needs_body = substantial(latex)
                    needs_equip = equip_n > 0
                    complete = (
                        bool(title_en and title_en.strip())
                        and ((not needs_body) or bool(latex_en and latex_en.strip()))
                        and ((not needs_equip) or equip_en_n == equip_n)
                    )
                    defs[article_id] = {
                        "id": article_id,
                        "kind": "experiment",
                        "title": title,
                        "file": rel,
                        "inPreparation": prep,
                        "needsBody": needs_body,
                        "needsEquipment": needs_equip,
                        "hasTitleEn": bool(title_en and title_en.strip()),
                        "hasLatexEn": bool(latex_en and latex_en.strip()),
                        "hasEquipmentEn": (not needs_equip) or equip_en_n == equip_n,
                        "titleEn": (title_en or "").strip(),
                        "latexJaChars": len(latex.strip()),
                        "latexEnChars": len((latex_en or "").strip()),
                        "mathJa": _count_math(latex),
                        "mathEn": _count_math(latex_en or ""),
                        "latexEn": latex_en or "",
                        "complete": complete,
                    }
    return defs


def listed_ids_from_file(path: Path, list_key: str) -> list[str]:
    text = strip_line_comments(path.read_text(encoding="utf-8", errors="ignore"))
    ids: list[str] = []
    for m in re.finditer(rf"{list_key}\s*:\s*\[([\s\S]*?)\]", text):
        for line in m.group(1).splitlines():
            item = line.strip().rstrip(",")
            if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", item):
                ids.append(item)
    return ids


def listed_theory_ids() -> list[str]:
    return listed_ids_from_file(LIB / "theory" / "theoryData.dart", "topics")


def listed_experiment_ids() -> list[str]:
    ids = listed_ids_from_file(LIB / "experiment" / "categoriesData.dart", "videos")
    # sensor articles
    sensor = LIB / "experiment" / "sensorArticlesData.dart"
    if sensor.exists():
        text = strip_line_comments(sensor.read_text(encoding="utf-8", errors="ignore"))
        for m in re.finditer(r"\[\s*([\s\S]*?)\]", text):
            for line in m.group(1).splitlines():
                item = line.strip().rstrip(",")
                if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", item):
                    ids.append(item)
    # unique preserve order
    seen = set()
    out = []
    for i in ids:
        if i not in seen:
            seen.add(i)
            out.append(i)
    return out


def jp_literal_files() -> list[dict]:
    """Animation files with untranslated Japanese UI (excl. article ctors / animL)."""
    anim_root = LIB / "experiment"
    rows = []
    for path in sorted(anim_root.rglob("**/animations/**/*.dart")):
        text = path.read_text(encoding="utf-8", errors="ignore")
        text = strip_line_comments(text)
        text = strip_article_ctors(text)
        text = mask_bilingual_wrappers(text)
        lits = []
        for m in STR_RE.finditer(text):
            s = m.group(1) if m.group(1) is not None else m.group(2)
            if s and JP_RE.search(s) and len(s.strip()) >= 1:
                # skip pure import paths
                if s.startswith("package:") or s.startswith("assets/"):
                    continue
                lits.append(s)
        if lits:
            rel = str(path.relative_to(ROOT))
            rows.append(
                {
                    "file": rel,
                    "jpLiteralCount": len(lits),
                    "samples": lits[:5],
                }
            )
    return rows


def write_article_checklist(articles: list[dict]) -> None:
    DOCS.mkdir(parents=True, exist_ok=True)
    done = sum(1 for a in articles if a["complete"])
    lines = [
        "# JoyPhysics article i18n checklist",
        "",
        f"Generated: {date.today().isoformat()}",
        f"Progress: **{done}/{len(articles)}** complete",
        "",
        "Done when: `titleEn` present; body EN if JA body is substantial; "
        "`equipmentEn` same length when equipment is non-empty. "
        "Theory prep/empty body: `titleEn` only.",
        "",
        "| Done | ID | Kind | Title | Body? | Notes |",
        "|---|---|---|---|---|---|",
    ]
    by_kind = defaultdict(list)
    for a in articles:
        by_kind[a["kind"]].append(a)
    for kind in ("experiment", "theory"):
        for a in by_kind.get(kind, []):
            mark = "x" if a["complete"] else " "
            notes = []
            if a["inPreparation"]:
                notes.append("prep")
            if a["needsBody"] and not a["hasLatexEn"]:
                notes.append("needs latexEn")
            if a["needsEquipment"] and not a["hasEquipmentEn"]:
                notes.append("needs equipmentEn")
            if not a["hasTitleEn"]:
                notes.append("needs titleEn")
            lines.append(
                f"| [{mark}] | `{a['id']}` | {a['kind']} | {a['title']} | "
                f"{'yes' if a['needsBody'] else 'no'} | {', '.join(notes) or '-'} |"
            )
    (DOCS / "i18n_article_checklist.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


SHARED_ANIMATION_UI = (
    "lib/experiment/waves/animations/fields/wave_fields.dart",
    "lib/experiment/thermoDynamics/animations/common.dart",
    "lib/experiment/dynamics/animations/energy_gauge.dart",
)


def _uses_anim_helper(rel: str) -> bool:
    path = ROOT / rel
    if not path.exists():
        return False
    text = path.read_text(encoding="utf-8", errors="ignore")
    return "animL(" in text or "animUi(" in text or "animUiForLang(" in text


def write_animation_checklist(articles: list[dict], unwrapped_rows: list[dict]) -> None:
    """One row per simulation article. Unwrapped JP files stay on the allowlist."""
    DOCS.mkdir(parents=True, exist_ok=True)
    sims = [a for a in articles if "/animations/" in a.get("file", "").replace("\\", "/")]
    done = 0
    body = []
    for a in sims:
        uses = _uses_anim_helper(a["file"])
        if uses:
            done += 1
        title = a["title"].replace("|", "\\|")
        ui = "animL" if uses else "no animL"
        body.append(
            f"| [{'x' if uses else ' '}] | `{a['id']}` | {title} | `{a['file']}` | {ui} |"
        )
    lines = [
        "# JoyPhysics animation UI i18n checklist",
        "",
        f"Generated: {date.today().isoformat()}",
        f"Progress: **{done}/{len(sims)}** simulation articles",
        "",
        "Done when the article file's interactive labels go through `animL` / `animUi`.",
        "`animL` uses only the primary device locale: English stays English when Japanese",
        "is installed as a secondary locale. Article `Video` / `createWaveVideo` HTML is out of scope.",
        "",
        "Shared widgets are not their own articles. Every `animL` pair under `animations/`,",
        "including these, is checked by `test/l10n/animation_animl_pairs_test.dart`:",
        "",
    ]
    for rel in SHARED_ANIMATION_UI:
        lines.append(f"- `{rel}`")
    if unwrapped_rows:
        lines += [
            "",
            "Files that still have Japanese UI outside `animL` / `animUi`:",
            "",
        ]
        for r in unwrapped_rows:
            lines.append(f"- `{r['file']}` ({r['jpLiteralCount']})")
    lines += [
        "",
        "| Done | ID | Title | File | UI |",
        "|---|---|---|---|---|",
        *body,
    ]
    (DOCS / "i18n_animation_ui_checklist.md").write_text(
        "\n".join(lines) + "\n", encoding="utf-8"
    )


def write_allowlists(articles: list[dict], anim_rows: list[dict]) -> None:
    TEST_L10N.mkdir(parents=True, exist_ok=True)
    incomplete = [a["id"] for a in articles if not a["complete"]]
    article_path = TEST_L10N / "untranslated_allowlist.txt"
    article_path.write_text(
        "# Auto-generated by scripts/generate_i18n_checklist.py\n"
        "# Remove an ID when its English fields are complete.\n"
        + "\n".join(incomplete)
        + ("\n" if incomplete else ""),
        encoding="utf-8",
    )
    anim_path = TEST_L10N / "untranslated_animation_allowlist.txt"
    anim_path.write_text(
        "# Auto-generated by scripts/generate_i18n_checklist.py\n"
        "# Remove a path when its Japanese UI literals are gone.\n"
        + "\n".join(r["file"] for r in anim_rows)
        + ("\n" if anim_rows else ""),
        encoding="utf-8",
    )


def write_inventory(articles: list[dict], anim_rows: list[dict]) -> None:
    TEST_L10N.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated": date.today().isoformat(),
        "articles": articles,
        "animationFiles": anim_rows,
    }
    (TEST_L10N / "article_inventory.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    defs = parse_definitions()
    listed = []
    for article_id in listed_experiment_ids():
        if article_id in defs:
            listed.append(defs[article_id])
        else:
            listed.append(
                {
                    "id": article_id,
                    "kind": "experiment",
                    "title": article_id,
                    "file": "?",
                    "inPreparation": False,
                    "needsBody": True,
                    "needsEquipment": False,
                    "hasTitleEn": False,
                    "hasLatexEn": False,
                    "hasEquipmentEn": True,
                    "titleEn": "",
                    "latexJaChars": 0,
                    "latexEnChars": 0,
                    "mathJa": 0,
                    "mathEn": 0,
                    "latexEn": "",
                    "complete": False,
                    "unresolved": True,
                }
            )
    for article_id in listed_theory_ids():
        if article_id in defs:
            listed.append(defs[article_id])
        else:
            listed.append(
                {
                    "id": article_id,
                    "kind": "theory",
                    "title": article_id,
                    "file": "?",
                    "inPreparation": True,
                    "needsBody": False,
                    "needsEquipment": False,
                    "hasTitleEn": False,
                    "hasLatexEn": False,
                    "hasEquipmentEn": True,
                    "titleEn": "",
                    "latexJaChars": 0,
                    "latexEnChars": 0,
                    "mathJa": 0,
                    "mathEn": 0,
                    "latexEn": "",
                    "complete": False,
                    "unresolved": True,
                }
            )

    anim_rows = jp_literal_files()
    write_article_checklist(listed)
    write_animation_checklist(listed, anim_rows)
    write_allowlists(listed, anim_rows)
    write_inventory(listed, anim_rows)

    done = sum(1 for a in listed if a["complete"])
    print(
        f"articles: {done}/{len(listed)} complete; "
        f"animation JP files: {len(anim_rows)}"
    )
    print(f"wrote {DOCS / 'i18n_article_checklist.md'}")
    print(f"wrote {DOCS / 'i18n_animation_ui_checklist.md'}")
    print(f"wrote {TEST_L10N / 'untranslated_allowlist.txt'}")
    print(f"wrote {TEST_L10N / 'untranslated_animation_allowlist.txt'}")
    print(f"wrote {TEST_L10N / 'article_inventory.json'}")


if __name__ == "__main__":
    main()
