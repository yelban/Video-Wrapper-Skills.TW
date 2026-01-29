#!/bin/bash
# ============================================================================
# localize-zh-tw.sh - 繁體中文（台灣）本地化腳本
# ============================================================================
# 用途：將專案從簡體中文轉換為繁體中文（台灣用語）
# 依賴：opencc (brew install opencc)
# 設計：冪等性 - 可安全重複執行
# ============================================================================

set -e  # 遇到錯誤時停止

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERMS_FILE="$PROJECT_ROOT/zh-tw-terms.txt"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

cd "$PROJECT_ROOT"

# ============================================================================
# Phase 1: 檢查依賴
# ============================================================================
log_info "檢查依賴..."

if ! command -v opencc &> /dev/null; then
    log_error "opencc 未安裝。請執行: brew install opencc"
    exit 1
fi

if [[ ! -f "$TERMS_FILE" ]]; then
    log_error "找不到詞彙對照表: $TERMS_FILE"
    exit 1
fi

# ============================================================================
# Phase 2: 轉換 Markdown 檔案
# ============================================================================
log_info "轉換 Markdown 檔案 (OpenCC s2twp)..."

find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" | while read -r f; do
    # 建立臨時檔案
    tmp_file=$(mktemp)
    opencc -c s2twp -i "$f" -o "$tmp_file"
    mv "$tmp_file" "$f"
    log_info "  轉換: $f"
done

# ============================================================================
# Phase 3: 套用自訂詞彙對照
# ============================================================================
log_info "套用台灣用語詞彙對照..."

# 讀取詞彙對照表，跳過註解和空行
while IFS=$'\t' read -r src dst || [[ -n "$src" ]]; do
    # 跳過註解和空行
    [[ "$src" =~ ^#.*$ ]] && continue
    [[ -z "$src" ]] && continue
    [[ -z "$dst" ]] && continue

    # 對所有 .md 檔案進行替換
    find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" -print0 | \
        xargs -0 sed -i '' "s/${src}/${dst}/g" 2>/dev/null || true
done < "$TERMS_FILE"

# ============================================================================
# Phase 4: 更新 Python 字體路徑
# ============================================================================
log_info "更新 Python 字體路徑..."

# 定義要添加的繁體中文字體（優先順序：蘋方 > 微軟正黑 > 思源黑體）
ZH_TW_FONTS='"/System/Library/Fonts/PingFang.ttc",  # macOS 蘋方（繁體首選）
            "/Library/Fonts/Microsoft JhengHei.ttf",  # macOS 微軟正黑
            "C:\\\\Windows\\\\Fonts\\\\msjh.ttc",  # Windows 微軟正黑
            "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",  # Linux Noto Sans CJK
            "/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc",  # Linux Noto Sans CJK (alt path)'

# fancy_text.py - 檢查是否已有蘋方字體
if ! grep -q "PingFang.ttc" src/fancy_text.py 2>/dev/null; then
    # 在 self.font_paths = [ 後面插入新字體
    sed -i '' '/self\.font_paths = \[/a\
            "/System/Library/Fonts/PingFang.ttc",  # macOS 蘋方（繁體首選）\
            "/Library/Fonts/Microsoft JhengHei.ttf",  # macOS 微軟正黑\
            "C:\\\\Windows\\\\Fonts\\\\msjh.ttc",  # Windows 微軟正黑\
            "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",  # Linux Noto Sans CJK
' src/fancy_text.py
    log_info "  更新: src/fancy_text.py"
fi

# term_card.py - 檢查是否已有蘋方字體
if ! grep -q "PingFang.ttc" src/term_card.py 2>/dev/null; then
    sed -i '' '/self\.font_paths_zh = \[/a\
            "/System/Library/Fonts/PingFang.ttc",  # macOS 蘋方（繁體首選）\
            "/Library/Fonts/Microsoft JhengHei.ttf",  # macOS 微軟正黑\
            "C:\\\\Windows\\\\Fonts\\\\msjh.ttc",  # Windows 微軟正黑\
            "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",  # Linux Noto Sans CJK
' src/term_card.py
    log_info "  更新: src/term_card.py"
fi

# ============================================================================
# Phase 5: 更新 CSS 字體宣告
# ============================================================================
log_info "更新 CSS 字體宣告..."

# 繁體中文字體列表
ZH_TW_CSS_FONTS='"PingFang TC", "Microsoft JhengHei", "Noto Sans TC"'

# 更新 effects.css 和所有 theme-*.css
for css_file in static/css/effects.css static/css/theme-*.css; do
    if [[ -f "$css_file" ]]; then
        # 檢查是否已有 PingFang TC
        if ! grep -q "PingFang TC" "$css_file" 2>/dev/null; then
            # 在 font-family: 後面插入繁體中文字體
            sed -i '' 's/font-family: "/font-family: "PingFang TC", "Microsoft JhengHei", "Noto Sans TC", "/g' "$css_file"
            # 處理沒有引號的情況
            sed -i '' 's/font-family: \([^"]\)/font-family: "PingFang TC", "Microsoft JhengHei", "Noto Sans TC", \1/g' "$css_file"
            log_info "  更新: $css_file"
        fi
    fi
done

# ============================================================================
# Phase 6: 更新 HTML 字體宣告
# ============================================================================
log_info "更新 HTML 字體宣告..."

for html_file in templates/*.html; do
    if [[ -f "$html_file" ]]; then
        # 檢查是否已有 PingFang TC
        if ! grep -q "PingFang TC" "$html_file" 2>/dev/null; then
            # 更新 font-family 宣告
            sed -i '' 's/font-family: "/font-family: "PingFang TC", "Microsoft JhengHei", "Noto Sans TC", "/g' "$html_file"
            log_info "  更新: $html_file"
        fi
    fi
done

# ============================================================================
# Phase 7: 添加 README 繁體中文聲明
# ============================================================================
log_info "檢查 README 繁體中文聲明..."

README_NOTICE='> 🇹🇼 **繁體中文版**
>
> 這是 [op7418/Video-Wrapper-Skills](https://github.com/op7418/Video-Wrapper-Skills) 的繁體中文（台灣）版本。
> 使用 OpenCC s2twp 轉換並加入台灣常用詞彙對照。'

if ! grep -q "繁體中文版" README.md 2>/dev/null; then
    # 在第一個 # 標題後插入聲明
    # 使用 awk 來處理多行插入
    awk -v notice="$README_NOTICE" '
        /^# / && !done {
            print
            print ""
            print notice
            print ""
            done=1
            next
        }
        {print}
    ' README.md > README.md.tmp && mv README.md.tmp README.md
    log_info "  添加 README 繁體中文聲明"
else
    log_info "  README 已有繁體中文聲明，跳過"
fi

# ============================================================================
# Phase 8: 自動 Commit
# ============================================================================
log_info "檢查變更並 commit..."

if [[ -n $(git status --porcelain) ]]; then
    git add -A
    git commit -m "chore: apply zh-TW localization

- Convert markdown files using OpenCC s2twp
- Apply Taiwan-preferred terminology
- Add Traditional Chinese font support (PingFang, Microsoft JhengHei, Noto Sans TC)
- Add zh-TW version notice to README

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
    log_info "變更已 commit"
else
    log_info "沒有變更需要 commit"
fi

# ============================================================================
# 完成
# ============================================================================
echo ""
log_info "=========================================="
log_info "繁體中文化完成！"
log_info "=========================================="
echo ""
log_info "上游同步流程："
echo "  git fetch upstream"
echo "  git merge upstream/main"
echo "  ./scripts/localize-zh-tw.sh"
echo ""
