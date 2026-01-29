<div align="center">

# 🎬 Video Wrapper

> 🇹🇼 **繁體中文版**
>
> 這是 [op7418/Video-Wrapper-Skills](https://github.com/op7418/Video-Wrapper-Skills) 的繁體中文（臺灣）版本。
> 使用 OpenCC s2twp 轉換並加入臺灣常用詞彙對照。

**為訪談/播客影片新增綜藝風格視覺包裝**

AI 智慧分析字幕內容，自動生成特效建議，一鍵渲染專業級視覺效果

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Claude Skills](https://img.shields.io/badge/Claude-Skills-blueviolet.svg)](https://claude.ai)

[快速開始](#-快速開始) • [功能特性](#-功能特性) • [效果展示](#-效果展示) • [使用場景](#-使用場景) • [架構檔案](./ARCHITECTURE.md)

</div>

---

## ✨ 功能特性

<table>
<tr>
<td width="50%">

### 🎨 8 種視覺元件
- **綜藝字卡高亮** - 短語概括核心觀點
- **人物條** - 顯示來賓姓名職位
- **章節標題** - 話題切換標題卡
- **術語解釋字卡** - 專業術語解釋
- **金句字卡** - 精彩言論突出
- **數字字卡** - 數字動態展示
- **重點列表** - 核心觀點總結
- **社交條** - 關注引導資訊

</td>
<td width="50%">

### 🎭 4 種視覺主題
- **Notion** 🟡 - 溫暖知識風格
- **Cyberpunk** 💜 - 霓虹未來感
- **Apple** ⚪ - 極簡商務風格
- **Aurora** 🌈 - 漸變流光效果

### 🤖 智慧工作流
1. 📝 AI 分析字幕內容
2. 💡 自動生成特效建議
3. ✅ 使用者審批確認
4. 🎬 一鍵渲染影片

</td>
</tr>
</table>

### 🛠️ 雙渲染引擎

| 引擎 | 技術棧 | 特點 |
|------|--------|------|
| **Browser** 🌐 | Playwright + HTML/CSS/Anime.js | 高質量，支援複雜動畫（推薦） |
| **PIL** 🎨 | Python PIL | 純 Python，無需瀏覽器 |

---

## 🚀 快速開始

### 安裝 Skill

**方式一：一鍵安裝（推薦）**

```bash
npx skills add https://github.com/op7418/Video-Wrapper-Skills
```

**方式二：手動安裝**

```bash
# 克隆到 Claude Skills 目錄
cd ~/.claude/skills/
git clone https://github.com/op7418/Video-Wrapper-Skills.git video-wrapper
cd video-wrapper

# 安裝依賴
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
playwright install chromium
```

### 使用

**在 Claude Code 中**

```bash
/video-wrapper interview.mp4 subtitles.srt
```

Claude 會：
1. 📊 分析字幕，識別關鍵資訊
2. 💡 生成特效建議（人物條、綜藝字卡、術語解釋字卡等）
3. 📝 展示 Markdown 格式建議供審批
4. ✅ 確認後自動渲染輸出影片

**命令列使用**

```bash
# 有設定檔案時直接渲染
python src/video_processor.py video.mp4 subs.srt config.json output.mp4

# 指定渲染器
python src/video_processor.py video.mp4 subs.srt config.json -r browser  # 瀏覽器渲染
python src/video_processor.py video.mp4 subs.srt config.json -r pil      # PIL 渲染
```

---

## 🎥 效果展示

> 💡 以下展示不同主題和元件的視覺效果

### 主題風格對比

<table>
<tr>
<td align="center" width="25%"><strong>Notion 主題</strong><br/>溫暖知識風</td>
<td align="center" width="25%"><strong>Cyberpunk 主題</strong><br/>霓虹未來感</td>
<td align="center" width="25%"><strong>Apple 主題</strong><br/>極簡優雅</td>
<td align="center" width="25%"><strong>Aurora 主題</strong><br/>漸變流光</td>
</tr>
<tr>
<td align="center">🟡 教育/知識分享</td>
<td align="center">💜 科技/前沿話題</td>
<td align="center">⚪ 商務/專業訪談</td>
<td align="center">🌈 創意/藝術內容</td>
</tr>
</table>

### 元件效果示例

| 元件 | 效果預覽 | 使用場景 |
|------|---------|----------|
| 🏷️ **綜藝字卡** | _[效果圖佔位]_ | 來賓說到"通用人工智慧"時，螢幕上方顯示"AI發展是平滑曲線" |
| 👤 **人物條** | _[效果圖佔位]_ | 影片開始時展示"Dario Amodei · CEO · Anthropic" |
| 📖 **術語解釋字卡** | _[效果圖佔位]_ | 首次提到"摩爾定律"時，自動彈出解釋卡片 |
| 💬 **金句** | _[效果圖佔位]_ | 精彩觀點"AI的發展是一個非常平滑的指數曲線"突出顯示 |

---

## 📋 使用場景

<table>
<tr>
<td width="33%">

### 🎓 教育內容
- 知識分享影片
- 課程錄製
- 線上講座
- 術語解釋需求多

</td>
<td width="33%">

### 🎙️ 訪談播客
- 人物專訪
- 圓桌討論
- 行業對話
- 需要來賓資訊展示

</td>
<td width="33%">

### 📱 社交媒體
- YouTube 長影片
- B站 UP主內容
- 播客節目
- 需要精彩片段突出

</td>
</tr>
</table>

---

## 🎨 主題系統

根據內容風格選擇合適主題：

```json
{
  "theme": "notion"  // 或 "cyberpunk", "apple", "aurora"
}
```

| 主題 | 色系 | 特點 | 適用內容 |
|------|------|------|----------|
| **Notion** | 暖黃 + 藍色 | 柔和漸變，知識感 | 教育、知識分享、課程 |
| **Cyberpunk** | 霓虹紫 + 青色 | 高對比，科技感 | 技術、科幻、前沿話題 |
| **Apple** | 黑白灰 | 極簡，專業感 | 商務、企業、正式訪談 |
| **Aurora** | 漸變彩虹 | 流光溢彩，藝術感 | 創意、設計、藝術內容 |

---

## 🧩 元件設定

### 完整設定示例

<details>
<summary>展開檢視完整 JSON 設定</summary>

```json
{
  "theme": "notion",

  "lowerThirds": [
    {
      "name": "張三",
      "role": "首席科學家",
      "company": "AI 研究院",
      "startMs": 1000,
      "durationMs": 5000
    }
  ],

  "chapterTitles": [
    {
      "number": "Part 1",
      "title": "AI 的發展歷程",
      "subtitle": "The History of AI Development",
      "startMs": 0,
      "durationMs": 4000
    }
  ],

  "keyPhrases": [
    {
      "text": "AI 發展是平滑曲線",
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
      "author": "— 張三",
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
  ],

  "socialBars": [
    {
      "platform": "twitter",
      "label": "關注我們",
      "handle": "@ai_research",
      "startMs": 52000,
      "durationMs": 8000
    }
  ]
}
```

</details>

### 元件引數速查

| 元件 | 必需引數 | 可選引數 | 說明 |
|------|---------|---------|------|
| 人物條 | name, role, company, startMs | durationMs (預設5s) | 顯示來賓資訊 |
| 章節標題 | number, title, startMs | subtitle, durationMs | 話題分段 |
| 綜藝字卡 | text, startMs, endMs | style, position | **text 必須是短語** |
| 術語解釋字卡 | chinese, english, firstAppearanceMs | description, displayDurationSeconds | 術語解釋 |
| 金句 | text, author, startMs | durationMs, position | 精彩觀點 |
| 資料 | number, label, startMs | prefix, unit, durationMs | 數字展示 |
| 要點 | title, points, startMs | durationMs | 列表總結 |
| 社交條 | platform, handle, startMs | label, durationMs | 關注引導 |

> ⚠️ **綜藝字卡使用規範**：text 必須是短語（如"AI發展是平滑曲線"），不能是單詞（如"人工智慧"）。單詞應使用術語解釋字卡。

---

## 🗂️ 專案結構

```
video-wrapper/
├── 📄 SKILL.md                  # Claude Skill 定義
├── 📄 README.md                 # 本檔案
├── 📄 ARCHITECTURE.md           # 詳細架構說明
├── 📄 requirements.txt          # Python 依賴
├── 📁 src/                      # 原始碼
│   ├── video_processor.py       # 主處理流程
│   ├── browser_renderer.py      # Playwright 渲染器
│   ├── content_analyzer.py      # AI 內容分析
│   ├── fancy_text.py            # PIL 綜藝字卡渲染
│   ├── term_card.py             # PIL 卡片渲染
│   └── animations.py            # 動畫函式庫
├── 📁 templates/                # HTML 模板
│   ├── fancy-text.html
│   ├── term-card.html
│   ├── lower-third.html
│   ├── chapter-title.html
│   ├── quote-callout.html
│   ├── animated-stats.html
│   ├── bullet-points.html
│   ├── social-bar.html
│   └── video-config.json.template
└── 📁 static/                   # 靜態資源
    ├── css/                     # 主題樣式
    │   ├── effects.css
    │   ├── theme-notion.css
    │   ├── theme-cyberpunk.css
    │   ├── theme-apple.css
    │   └── theme-aurora.css
    └── js/
        └── anime.min.js         # 動畫引擎
```

---

## ❓ 常見問題

<details>
<summary><strong>Q: Playwright 安裝失敗？</strong></summary>

```bash
# 確保 Python 版本 >= 3.8
pip install playwright
playwright install chromium

# macOS 可能需要移除隔離標記
xattr -r -d com.apple.quarantine ~/.cache/ms-playwright

# 驗證安裝
playwright --version
```

</details>

<details>
<summary><strong>Q: 處理速度太慢？</strong></summary>

**最佳化建議**：
1. 使用 PIL 渲染器：`-r pil`（效果略簡單但速度快 2-3 倍）
2. 降低影片解析度（從 1080p 降至 720p）
3. 分段處理長影片（每次處理 5-10 分鐘）
4. 減少元件數量（只保留必要的）

</details>

<details>
<summary><strong>Q: 記憶體不足？</strong></summary>

**解決方案**：
1. 關閉其他應用釋放記憶體
2. 分段處理長影片
3. 使用更低的解析度（720p 或 480p）
4. 減少同時渲染的元件數量
5. 使用 PIL 渲染器（記憶體佔用更小）

</details>

<details>
<summary><strong>Q: 字型顯示異常？</strong></summary>

確保系統已安裝中文字型：

```bash
# macOS - 自帶 PingFang SC
# 無需額外安裝

# Ubuntu/Debian
sudo apt-get install fonts-noto-cjk

# CentOS/RHEL
sudo yum install google-noto-sans-cjk-fonts

# 驗證字型
fc-list :lang=zh
```

</details>

<details>
<summary><strong>Q: 如何自定義主題？</strong></summary>

1. 複製現有主題 CSS 檔案
2. 修改 CSS 變數
3. 在設定中指定新主題名

詳見 [ARCHITECTURE.md](./ARCHITECTURE.md#新增新主題)

</details>

---

## 🔧 技術棧

| 層級 | 技術 | 說明 |
|------|------|------|
| **視覺渲染** | HTML + CSS + Anime.js | 透過 Playwright 瀏覽器截圖 |
| **影片合成** | MoviePy | Python 影片編輯庫 |
| **動畫引擎** | Anime.js | Spring 物理動畫 |
| **備用渲染** | Python PIL | 純 Python 影像處理 |
| **內容分析** | AI 分析 | 自動識別關鍵資訊 |

詳細架構說明請檢視 [ARCHITECTURE.md](./ARCHITECTURE.md)

---

## 📚 相關資源

- [Claude Skills 檔案](https://docs.anthropic.com/claude/docs)
- [MoviePy 檔案](https://zulko.github.io/moviepy/)
- [Playwright 檔案](https://playwright.dev/python/)
- [Anime.js 檔案](https://animejs.com/)

---

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

在提交 PR 前，請確保：
- ✅ 程式碼風格符合專案規範
- ✅ 添加了必要的測試
- ✅ 更新了相關檔案

---

## 📄 許可證

[MIT License](./LICENSE)

---

<div align="center">

**由 [Claude](https://claude.ai) 強力驅動**

如果覺得有用，請給個 ⭐️ Star！

</div>
