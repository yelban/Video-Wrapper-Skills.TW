# 架構檔案

## 系統概覽

訪談影片處理器基於分離的渲染後端架構，支援兩種視覺效果生成方式：
- **Browser Backend**: HTML/CSS/Anime.js + Playwright 瀏覽器自動化（推薦）
- **PIL Backend**: Python PIL 純 Python 實現（備選方案）

典型的資料流如下：
```
影片檔案 + 字幕檔案
    ↓
內容分析器（提取建議）
    ↓
使用者核准設定
    ↓
渲染引擎（生成幀序列）
    ├→ Browser: HTML → Playwright → 截圖
    └→ PIL: Python → PIL 繪製
    ↓
影片合成器（MoviePy）
    ↓
輸出影片
```

## 核心模組

### 1. video_processor.py
主入口和協調器，負責：
- 命令列引數解析
- 設定檔案載入驗證
- 渲染器選擇（自動或手動指定）
- 多種元件型別的分發處理
- 影片合成和匯出

關鍵函式：
- `process_video()`: 主處理流程
- `_generate_clips_browser()`: 使用瀏覽器渲染器生成圖層
- `_generate_clips_pil()`: 使用 PIL 渲染器生成圖層

### 2. browser_renderer.py
Playwright 瀏覽器自動化渲染器，負責：
- Playwright 瀏覽器例項管理
- HTML 模板載入與渲染
- 動畫狀態管理（透過 seek 控制當前幀）
- 截圖捕獲和影像輸出

關鍵類和方法：
- `BrowserRenderer`: 主類，生命週期管理
- `render_fancy_text_frames()`: 綜藝字卡渲染
- `render_term_card_frames()`: 術語解釋字卡渲染
- `render_lower_third_frames()`: 人物條渲染
- 以及其他 8 個元件的渲染方法

工作原理：
```
載入 HTML 模板
    ↓
注入設定引數（JSON）
    ↓
呼叫 JavaScript initAnimation()
    ↓
迴圈：
  - 計算當前幀時間
  - 呼叫 JavaScript seek(t)
  - Playwright 截圖
  - 儲存為 PNG
```

### 3. content_analyzer.py
內容分析引擎，負責：
- 從字幕檔案提取資訊
- 分析內容，識別：
  - 來賓資訊（人物條）
  - 話題切換點（章節標題）
  - 關鍵觀點（綜藝字卡短語）
  - 專業術語（術語解釋字卡）
  - 精彩言論（金句字卡）
  - 數字資料（數字字卡）
  - 核心要點（重點列表）
  - 社交媒體資訊（社交條）

包含多個 Dataclass 定義建議型別：
- `LowerThirdSuggestion`
- `ChapterTitleSuggestion`
- `FancyTextSuggestion`
- `TermCardSuggestion`
- `QuoteCalloutSuggestion`
- `AnimatedStatsSuggestion`
- `BulletPointsSuggestion`
- `SocialBarSuggestion`

### 4. fancy_text.py（PIL 備選方案）
純 Python PIL 實現的綜藝字卡生成器：
- PIL 文字渲染與描邊
- 陰影效果實現
- 旋轉和縮放變換
- Spring 動畫應用

### 5. term_card.py（PIL 備選方案）
純 Python PIL 實現的術語解釋字卡生成器：
- 圓角矩形繪製
- 漸變邊框（Pillow 模擬）
- 文字佈局和自動換行
- 動畫效果（滑入、淡出）

### 6. animations.py
動畫工具函式庫（用於 PIL 後端）：
- `spring()`: Spring 物理引擎實現
  - 引數：frame, fps, from_value, to_value, damping, stiffness
  - 模擬 Remotion 風格彈性動畫
- `interpolate()`: 線性插值函式
  - 支援任意輸入/輸出範圍對映
  - 支援超出範圍處理（clamp/extend/wrap）

## 模板系統

9 個 HTML 模板位於 `templates/` 目錄，每個對應一種元件：

| 模板 | 元件型別 | 用途 |
|------|---------|------|
| fancy-text.html | 綜藝字卡 | 概括觀點短語 |
| term-card.html | 術語解釋字卡 | 解釋專業術語 |
| lower-third.html | 人物條 | 顯示來賓資訊 |
| chapter-title.html | 章節標題 | 話題切換標題 |
| quote-callout.html | 金句字卡 | 突出精彩言論 |
| animated-stats.html | 數字字卡 | 展示數字資料 |
| bullet-points.html | 重點列表 | 總結核心要點 |
| social-bar.html | 社交條 | 社交媒體引導 |
| video-config.json.template | 設定模板 | JSON 設定示例 |

### 模板特點：
- 獨立的 HTML 結構，可單獨測試
- JavaScript `initAnimation(config)` 函式接收設定
- `seek(timeMs)` 方法用於幀控制（Playwright 呼叫）
- CSS 變數支援主題切換
- Anime.js 動畫庫支援

## 主題系統

CSS 主題在 `static/css/` 目錄：

| 主題 | 檔案 | 特點 | 場景 |
|------|------|------|------|
| notion | theme-notion.css | 溫暖知識風，柔和漸變 | 教育、知識分享 |
| cyberpunk | theme-cyberpunk.css | 霓虹未來感，鮮豔對比 | 科技、前瞻議題 |
| apple | theme-apple.css | 極簡優雅，中性色系 | 商務、專業訪談 |
| aurora | theme-aurora.css | 漸變流光，炫彩效果 | 創意、藝術內容 |

每個主題透過 CSS 變數定義：
```css
:root[data-theme="notion"] {
  --primary-color: #f5b041;
  --secondary-color: #3498db;
  --accent-color: #e74c3c;
  /* ... */
}
```

模板透過 `data-theme` 屬性啟用主題。

## 動畫引擎

### Anime.js 整合
- 用於瀏覽器後端的幀動畫
- 支援 Spring 物理、緩動曲線等高階效果
- 透過 `seek()` 方法實現幀級控制

### Spring 動畫原理
```python
x(t) = to_value - (to_value - from_value) * exp(-damping*t) * cos(stiffness*t)
```
透過調整 `damping` 和 `stiffness` 引數實現不同的彈性效果。

## 設定檔案格式

JSON 設定包含以下頂級欄位：

```json
{
  "theme": "notion",           # 選擇主題
  "lowerThirds": [...],        # 人物條陣列
  "chapterTitles": [...],      # 章節標題陣列
  "keyPhrases": [...],         # 綜藝字卡陣列
  "termDefinitions": [...],    # 術語解釋字卡陣列
  "quotes": [...],             # 金句字卡陣列
  "stats": [...],              # 數字字卡陣列
  "bulletPoints": [...],       # 重點列表陣列
  "socialBars": [...]          # 社交條陣列
}
```

## 資料流詳解

### 1. 設定階段
```
使用者提供影片 + 字幕
    ↓
ContentAnalyzer.analyze_subtitle() 讀取 .srt
    ↓
返回 8 種型別的建議物件列表
    ↓
使用者編輯或確認建議
    ↓
生成或修改 config.json
```

### 2. 渲染階段（Browser 後端）
```
video_processor 載入設定
    ↓
對每個元件：
  - 確定時間範圍
  - 建立 BrowserRenderer 例項
  - 載入對應 HTML 模板
  - 透過 JavaScript 注入設定
  - 迴圈渲染幀：
    * 計算當前時間
    * 呼叫 seek(timeMs)
    * Playwright 截圖
    * 儲存 PNG 序列
  - 使用 MoviePy ImageClip 構建影片層
    ↓
合併所有層（原影片 + 效果層）
    ↓
匯出最終影片
```

### 3. 渲染階段（PIL 後端）
```
video_processor 載入設定
    ↓
對每個元件：
  - 確定時間範圍和幀數
  - 迴圈渲染幀：
    * 呼叫 fancy_text.py / term_card.py
    * 應用 animations.py 動畫函式
    * 使用 PIL 繪製到記憶體
    * 儲存 PNG 序列
  - 使用 MoviePy ImageClip 構建影片層
    ↓
合併所有層（原影片 + 效果層）
    ↓
匯出最終影片
```

## 檔案依賴關係

```
video_processor.py （主）
├── browser_renderer.py
│   ├── templates/*.html
│   └── static/css/*.css
│       ├── effects.css
│       └── theme-*.css
├── fancy_text.py （PIL 備選）
│   └── animations.py
├── term_card.py （PIL 備選）
│   └── animations.py
├── content_analyzer.py
├── moviepy
│   ├── VideoFileClip
│   ├── CompositeVideoClip
│   └── ImageClip
└── 設定檔案
    └── config.json
```

## 擴充套件指南

### 新增新元件

#### 1. 建立 HTML 模板
在 `templates/` 目錄建立 `your-component.html`，包含：
```html
<script>
function initAnimation(config) {
  // 初始化：使用 config 引數設定 DOM 元素
  // 返回 totalMs：動畫總時長
}

function seek(timeMs) {
  // 關鍵幀：根據 timeMs 設定動畫狀態
  // 由 Playwright 呼叫
}
</script>
```

#### 2. 新增渲染方法
在 `BrowserRenderer` 類中新增：
```python
def render_your_component_frames(self, config, output_dir=None):
    # 類似 render_fancy_text_frames 的實現
    pass
```

#### 3. 在 video_processor.py 中註冊
在 `_generate_clips_browser()` 中新增分支處理新元件。

#### 4. 更新 content_analyzer.py
新增對應的 Suggestion dataclass。

#### 5. 新增設定驗證
在設定載入時驗證新元件的必需欄位。

### 新增新主題

#### 1. 建立 CSS 檔案
在 `static/css/` 目錄建立 `theme-yourtheme.css`：
```css
:root[data-theme="yourtheme"] {
  --primary-color: #...;
  --secondary-color: #...;
  --accent-color: #...;
  --bg-color: #...;
  /* ... */
}
```

#### 2. 在模板中引用
```html
<link rel="stylesheet" href="../static/css/theme-yourtheme.css">
```

#### 3. 更新檔案
在 SKILL.md 中列出新主題。

## 效能考慮

### Browser 後端效能
- 優點：高質量輸出，支援複雜 CSS/動畫
- 缺點：需要 Chromium，較慢（但可控）
- 最佳化：
  - 使用 `--headless` 模式
  - 預熱瀏覽器例項
  - 批次渲染多元件時複用例項

### PIL 後端效能
- 優點：快速，無額外依賴
- 缺點：效果有限，不支援複雜動畫
- 最佳化：
  - 預計算變換矩陣
  - 使用 NumPy 加速計算

## 依賴分析

### 核心依賴
- `moviepy>=1.0.3`: 影片合成
- `pillow>=10.0.0`: 影像處理（兩個後端都需要）
- `numpy>=1.24.0`: 數值計算
- `pysrt>=1.1.2`: SRT 字幕解析
- `playwright>=1.40.0`: 瀏覽器自動化（可選）

### 依賴大小
- 總計：約 100-150MB（包括 Playwright + Chromium）
- 僅 PIL 後端：約 50-80MB

## 故障排除

### Playwright/Chromium 問題
```bash
# 手動安裝
pip install playwright
playwright install chromium

# 驗證
playwright codegen --browser chromium
```

### MoviePy 依賴問題
```bash
# macOS
brew install ffmpeg

# Ubuntu
sudo apt-get install ffmpeg

# 驗證
moviepy-script --version
```

### 記憶體問題
- 長影片：分段處理或降低解析度
- 多元件：批次處理時控制併發

## 測試策略

### 單元測試
- 動畫函式：spring(), interpolate()
- 設定解析和驗證
- 渲染器初始化

### 整合測試
- 完整工作流：輸入 → 渲染 → 輸出
- 兩個後端對比（視覺一致性）
- 不同主題的渲染

### 效能測試
- 幀渲染速度
- 記憶體使用
- 長影片處理

