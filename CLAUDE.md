# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案概述

這是一個 Claude Code Skill，為訪談/播客影片新增綜藝風格視覺包裝（綜藝字卡、術語解釋字卡、人物條等）。使用 Playwright + HTML/CSS/Anime.js 渲染高品質特效，MoviePy 合成影片。

## 常用指令

```bash
# 安裝依賴（使用 uv）
uv sync

# 安裝 Playwright 瀏覽器
uv run playwright install chromium

# 處理影片（瀏覽器渲染器，推薦）
uv run python src/video_processor.py video.mp4 subs.srt config.json output.mp4

# 指定渲染器
uv run python src/video_processor.py video.mp4 subs.srt config.json -r browser
uv run python src/video_processor.py video.mp4 subs.srt config.json -r pil
```

## 架構

```
影片 + 字幕 → ContentAnalyzer 分析 → 使用者審批 → 渲染引擎 → MoviePy 合成 → 輸出影片
```

**雙渲染引擎**：
- `browser_renderer.py`：Playwright + HTML 模板（高品質，推薦）
- `fancy_text.py` / `term_card.py`：PIL 純 Python（備選）

**核心模組**：
- `src/video_processor.py` - 主入口，協調渲染和合成
- `src/browser_renderer.py` - Playwright 渲染，管理 HTML 模板的 `initAnimation()` 和 `seek(timeMs)` 呼叫
- `src/content_analyzer.py` - 字幕分析，產生 8 種元件建議（Dataclass 定義）
- `src/animations.py` - `spring()` 和 `interpolate()` 動畫函式（PIL 後端用）

**模板系統**（`templates/`）：
每個 HTML 模板需實作 `initAnimation(config)` 和 `seek(timeMs)` 讓 Playwright 控制動畫幀。

**主題系統**（`static/css/theme-*.css`）：
透過 CSS 變數和 `data-theme` 屬性切換主題（notion/cyberpunk/apple/aurora）。

## 元件規範

**綜藝字卡 vs 術語解釋字卡**：
- 綜藝字卡（keyPhrases）：短語概括觀點，如「AI發展是平滑曲線」
- 術語解釋字卡（termDefinitions）：術語解釋，如「摩爾定律：電晶體數量每18-24個月翻倍」

## 擴充指南

新增元件需：
1. 建立 `templates/your-component.html`（含 `initAnimation` 和 `seek`）
2. 在 `BrowserRenderer` 加 `render_your_component_frames()` 方法
3. 在 `video_processor._generate_clips_browser()` 註冊
4. 在 `content_analyzer.py` 加對應 Suggestion dataclass
