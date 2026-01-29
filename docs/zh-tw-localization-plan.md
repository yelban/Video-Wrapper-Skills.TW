# Plan: Traditional Chinese (zh-TW) Localization

**Generated**: 2026-01-29
**Estimated Complexity**: Medium

## Overview
This plan localizes all documentation and UI-facing text from Simplified Chinese to Traditional Chinese (Taiwan), adds Taiwan-preferred terms via a custom OpenCC phrase list, and standardizes font fallbacks across Python renderers, CSS, and HTML templates. A single idempotent bash script will apply conversions, patch font declarations, and auto-commit changes so future upstream merges can be re-localized with one command.

## Prerequisites
- `opencc` installed and available in PATH (already installed via Homebrew)
- Git configured with upstream remote (e.g., `git remote add upstream <url>`) and write access for commits
- Bash available (`/bin/bash`)

## Phase 1: Setup Foundation

### Task 1.1: Create `zh-tw-terms.txt`
- Location: `./zh-tw-terms.txt`
- Content: OpenCC user phrases format (one mapping per line, `source<TAB>target`)
- Include common Taiwan-preferred mappings (extend as needed):
  ```text
  影片	影片
  影片	影片
  音訊	音訊
  音訊	音訊
  資料	資料
  資料庫	資料庫
  介面	介面
  智慧	智慧
  預設	預設
  檔案	檔案
  目錄	目錄
  網路	網路
  程式	程式
  使用者	使用者
  賬號	帳號
  日誌	紀錄
  備份	備份
  伺服器	伺服器
  螢幕	螢幕
  模型	模型
  訓練	訓練
  編碼	編碼
  設定	設定
  元件	元件
  軟體	軟體
  影片	影片
  影片效果	影片效果
  ```
- Idempotency: file content is deterministic; re-running script will overwrite or ensure content unchanged.

### Task 1.2: Create localization script
- Location: `./scripts/localize-zh-tw.sh`
- Description: Main automation script; applies OpenCC conversion, term mapping, font updates, README header, and commits
- Idempotency rules:
  - Only insert README header if missing
  - Use in-place, deterministic replacements
  - Avoid duplicate font entries
  - Auto-commit only when there are changes

## Phase 2: Text Conversion

### Task 2.1: Convert `.md` files
- Use `opencc -c s2twp` to convert all markdown files under repo root.
- Example (in script):
  ```bash
  find . -name "*.md" -print0 | while IFS= read -r -d '' f; do
    opencc -c s2twp -i "$f" -o "$f"
  done
  ```
- Idempotency: repeated conversion produces stable output.

### Task 2.2: Apply custom term mapping
- Apply `zh-tw-terms.txt` on all `.md` files after OpenCC conversion.
- Use `sed` to replace terms from the mapping file (tab-delimited):
  ```bash
  while IFS=$'\t' read -r src dst; do
    [[ -z "$src" ]] && continue
    find . -name "*.md" -print0 | xargs -0 sed -i '' -e "s/${src}/${dst}/g"
  done < ./zh-tw-terms.txt
  ```
- Idempotency: deterministic replacements (no cumulative effects).

## Phase 3: Font Configuration

### Task 3.1: Update Python font paths
- Files:
  - `src/fancy_text.py` (lines ~16-24, `self.font_paths` list)
  - `src/term_card.py` (lines ~21-29, `font_paths_zh` list)
- Insert new entries *before* existing entries:
  ```python
  "/System/Library/Fonts/PingFang.ttc",
  "C:\\Windows\\Fonts\\msjh.ttc",
  "/System/Library/Fonts/PingFangTC-Regular.ttf",
  "/Library/Fonts/Microsoft JhengHei.ttf",
  "/Library/Fonts/NotoSansTC-Regular.otf",
  "/usr/share/fonts/opentype/noto/NotoSansTC-Regular.otf",
  "/usr/share/fonts/noto/NotoSansTC-Regular.otf",
  "/usr/share/fonts/truetype/noto/NotoSansTC-Regular.ttf",
  ```
- Use a script block to detect if entries exist; prepend only missing items.

### Task 3.2: Update CSS `font-family`
- File: `static/css/effects.css`
- Locations: font-family declarations (lines ~21, 114, 130)
- Update to prioritized list (prepend new fonts to existing list):
  ```css
  font-family: "PingFang TC", "Microsoft JhengHei", "Noto Sans TC", /* existing fonts... */;
  ```
- Use `sed` or `perl` to ensure the three fonts appear at the start of each `font-family` list without duplicates.

### Task 3.3: Update HTML `font-family`
- Files: `templates/*.html`
- For each inline or embedded `font-family` declaration, prepend:
  ```css
  "PingFang TC", "Microsoft JhengHei", "Noto Sans TC",
  ```
- Apply the same update to `static/css/theme-*.css` (all four files).
- Ensure no duplicate entries if the script is re-run.

## Phase 4: Documentation

### Task 4.1: Add README zh-TW notice
- File: `README.md`
- Insert after the title line (first Markdown heading):
  ```markdown
  > 🇹🇼 **繁體中文版**
  >
  > 這是 [op7418/Video-Wrapper-Skills](https://github.com/op7418/Video-Wrapper-Skills) 的繁體中文（臺灣）版本。
  > 使用 OpenCC s2twp 轉換並加入臺灣常用詞彙對照。
  ```
- Only insert if the notice block is not already present.

## Testing Strategy
- Dry-run validation:
  - Run `./scripts/localize-zh-tw.sh`
  - Verify no errors from OpenCC or sed
- Idempotency checks:
  - Run the script twice; second run should produce no changes (`git status` clean)
- Spot checks:
  - Confirm font lists include new priorities in `src/fancy_text.py`, `src/term_card.py`, `static/css/effects.css`, `static/css/theme-*.css`, `templates/*.html`
  - Confirm README notice is present once

## Rollback Plan
- If changes are incorrect after running the script:
  ```bash
  git reset --hard HEAD~1
  ```
- If multiple commits were made:
  ```bash
  git log --oneline
  git reset --hard <commit-sha>
  ```

## Automation Script Outline (for reference)
- File: `scripts/localize-zh-tw.sh`
- High-level flow:
  1. Convert `.md` files via OpenCC s2twp
  2. Apply `zh-tw-terms.txt` replacements
  3. Patch font paths in Python lists
  4. Patch CSS/HTML font-family declarations
  5. Add README zh-TW notice if missing
  6. Auto-commit with message `chore: apply zh-TW localization` if `git diff` shows changes

## Upstream Sync Workflow
```bash
git fetch upstream
git merge upstream/main
./scripts/localize-zh-tw.sh
```
