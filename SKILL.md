---
name: video-wrapper
description: 為訪談影片新增綜藝特效（綜藝字卡、卡片、人物條、章節標題等）。支援 4 種視覺主題，先分析字幕內容生成建議供使用者審批，再渲染影片。
argument-hint: <video-file> <subtitle-file> [config.json] [output.mp4]
user-invocable: true
allowed-tools: Bash, Read, Write
context: fork
agent: general-purpose
---

# 訪談影片處理器

基於 Python + Playwright + MoviePy 的影片特效處理工具，使用 HTML/CSS/Anime.js 渲染高質量視覺效果。

## 工作流程

### 第一步：分析字幕內容

當使用者提供影片和字幕檔案時，先分析字幕內容，生成特效建議：

1. 讀取字幕檔案 (.srt)
2. 分析內容，識別：
   - 來賓資訊（用於人物條）
   - 話題切換點（用於章節標題）
   - 關鍵詞和術語（用於綜藝字卡）
   - 專業名詞（用於術語解釋字卡）
   - 精彩觀點（用於金句字卡）
   - 數字資料（用於數字字卡）
   - 核心要點（用於重點列表）
3. 生成建議列表，展示給使用者稽核

### 第二步：使用者稽核

將建議以 Markdown 格式展示給使用者：

```
## 視覺特效建議

**主題**: notion

### 1. 人物條 (Lower Third)
- **姓名**: Dario Amodei
- **職位**: CEO
- **公司**: Anthropic
- **出現時間**: 1000ms

### 2. 綜藝字卡高亮 (Fancy Text)
1. **通用人工智慧** (emphasis)
   時間: 2630ms - 5500ms
   原因: 核心概念首次提及

...
```

使用者可以：
- 確認全部建議
- 修改部分建議
- 刪除不需要的元件
- 新增新的元件

### 第三步：生成設定並渲染

根據使用者審批後的建議生成 config.json，然後渲染影片。

## 可用元件

| 元件 | 用途 | 設定欄位 |
|------|------|----------|
| 人物條 (lower_third) | 顯示來賓資訊 | name, role, company, startMs, durationMs |
| 章節標題 (chapter_title) | 話題切換標題 | number, title, subtitle, startMs, durationMs |
| 綜藝字卡 (fancy_text) | 概括當前觀點 | text, style, startMs, endMs, position |
| 術語解釋字卡 (term_card) | 解釋術語 | chinese, english, description, firstAppearanceMs |
| 金句字卡 (quote_callout) | 突出精彩觀點 | text, author, startMs, durationMs, position |
| 數字字卡 (animated_stats) | 展示數字 | prefix, number, unit, label, startMs |
| 重點列表 (bullet_points) | 總結核心要點 | title, points[], startMs, durationMs |
| 社群追蹤條 (social_bar) | 關注引導 | platform, label, handle, startMs, durationMs |

### 綜藝字卡使用規範

⚠️ **重要**：綜藝字卡必須遵循以下規範：

1. **必須是短語**：用簡短的句子概括說話人當時的觀點
   - ✅ 正確：「AI發展是平滑曲線」「智慧增長類似摩爾定律」
   - ❌ 錯誤：「人工智慧」「摩爾定律」（這些是單詞，應該用術語解釋字卡）

2. **與術語解釋字卡互補**：
   - 綜藝字卡：概括觀點（如「智慧每年翻倍增長」）
   - 術語解釋字卡：解釋術語（如「摩爾定律：積體電路電晶體數量每18-24個月翻一番」）

3. **位置在上方**：預設顯示在螢幕上方區域（字幕上方），避免遮擋人臉

### 社群追蹤條使用規範

- 預設顯示時長：8 秒（比其他元件更長，給使用者足夠時間記住）
- 通常在影片結尾出現
- 支援平臺：twitter, weibo, youtube

## 主題系統

支援 4 種視覺主題：

| 主題 | 風格 | 適用場景 |
|------|------|----------|
| `notion` | 溫暖知識風 | 教育、知識分享 |
| `cyberpunk` | 霓虹未來感 | 科技、前瞻議題 |
| `apple` | 極簡優雅 | 商務、專業訪談 |
| `aurora` | 漸變流光 | 創意、藝術內容 |

## 設定檔案格式

```json
{
  "theme": "notion",
  "lowerThirds": [
    {
      "name": "Dario Amodei",
      "role": "CEO",
      "company": "Anthropic",
      "startMs": 1000,
      "durationMs": 5000
    }
  ],
  "chapterTitles": [
    {
      "number": "Part 1",
      "title": "指數增長的本質",
      "subtitle": "The Nature of Exponential Growth",
      "startMs": 0,
      "durationMs": 4000
    }
  ],
  "keyPhrases": [
    {
      "text": "通用人工智慧",
      "style": "emphasis",
      "startMs": 2630,
      "endMs": 5500
    }
  ],
  "termDefinitions": [
    {
      "chinese": "摩爾定律",
      "english": "Moore's Law",
      "description": "積體電路電晶體數量每18-24個月翻一番",
      "firstAppearanceMs": 37550,
      "displayDurationSeconds": 6
    }
  ],
  "quotes": [
    {
      "text": "AI 的發展是一個非常平滑的指數曲線",
      "author": "— Dario Amodei",
      "startMs": 30000,
      "durationMs": 5000
    }
  ],
  "stats": [
    {
      "prefix": "增長率 ",
      "number": 240,
      "unit": "%",
      "label": "計算能力年增長",
      "startMs": 45000,
      "durationMs": 4000
    }
  ],
  "bulletPoints": [
    {
      "title": "核心觀點",
      "points": [
        "AI 發展是平滑的指數曲線",
        "類似摩爾定律的智慧增長",
        "沒有突然的奇點時刻"
      ],
      "startMs": 50000,
      "durationMs": 6000
    }
  ]
}
```

## 依賴安裝

```bash
# 進入虛擬環境
cd ~/.claude/skills/video-wrapper
source venv/bin/activate

# 安裝依賴
pip install -r requirements.txt

# 安裝 Playwright 瀏覽器
playwright install chromium
```

## 命令列使用

```bash
# 使用瀏覽器渲染器（推薦）
python src/video_processor.py video.mp4 subs.srt config.json output.mp4

# 指定渲染器
python src/video_processor.py video.mp4 subs.srt config.json -r browser
python src/video_processor.py video.mp4 subs.srt config.json -r pil
```

## 技術實現

- **視覺渲染**: HTML + CSS + Anime.js (透過 Playwright 截圖)
- **影片合成**: MoviePy
- **動畫引擎**: Anime.js (Spring 物理動畫)
- **備用渲染**: Python PIL

## 檔案結構

```
~/.claude/skills/video-wrapper/
├── src/
│   ├── video_processor.py    # 主處理指令碼
│   ├── browser_renderer.py   # Playwright 渲染器
│   ├── content_analyzer.py   # 內容分析器
│   ├── fancy_text.py         # PIL 綜藝字卡（備用）
│   └── term_card.py          # PIL 卡片（備用）
├── templates/
│   ├── fancy-text.html       # 綜藝字卡模板
│   ├── term-card.html        # 術語解釋字卡模板
│   ├── lower-third.html      # 人物條模板
│   ├── chapter-title.html    # 章節標題模板
│   ├── quote-callout.html    # 金句字卡模板
│   ├── animated-stats.html   # 數字字卡模板
│   └── bullet-points.html    # 重點列表模板
├── static/
│   ├── css/
│   │   ├── effects.css       # 基礎效果
│   │   ├── theme-notion.css  # Notion 主題
│   │   ├── theme-cyberpunk.css
│   │   ├── theme-apple.css
│   │   └── theme-aurora.css
│   └── js/
│       └── anime.min.js      # Anime.js
└── requirements.txt
```

## 注意事項

- 影片處理需要較長時間，請耐心等待
- 確保有足夠的磁碟空間儲存輸出影片
- Playwright 渲染效果更好，但需要安裝 Chromium
- 如果 Playwright 不可用，會自動回退到 PIL 渲染
