# 🎙️ Meeting Note — Google Meet 會議影片 → 繁中軟體開發會議記錄

把 Google Meet 的會議錄影丟進來，自動轉成**繁體中文逐字稿**，並產生一份可直接貼給 Claude 的「會議記錄摘要 Prompt」（軟體開發屬性）。

## 一次性安裝

```bash
bash setup.sh
```

會安裝 `ffmpeg` 與本機語音辨識 `faster-whisper`（離線、免費、不外傳）。
需要先有 [Homebrew](https://brew.sh)。

## 每次使用（三步驟）

1. 把會議影片／音訊丟進 `input/` 資料夾
   - 支援：`mp4 / mkv / mov / webm / m4a / mp3 / wav / avi`
2. 執行：
   ```bash
   bash run.sh
   ```
3. 到 `output/` 拿結果：
   - `檔名.txt` — 純逐字稿
   - `檔名.srt` — 含時間軸字幕
   - `檔名__會議記錄prompt.md` — **整份複製貼給 Claude**，就會輸出繁中會議記錄

## 進階用法

```bash
bash run.sh 我的會議.mp4        # 只處理單一檔案
MODEL=large-v3 bash run.sh      # 換更準的模型（較慢）
MODEL=small bash run.sh         # 換更快的模型（較不準）
```

模型大小：`tiny < base < small < medium(預設) < large-v3`
越大越準但越慢，首次使用會自動下載模型。

## 產出的會議記錄包含

- 會議重點摘要
- 技術決策與討論（架構／選型／API／風險／技術債）
- 待辦事項（Action Items 表格）
- 需求／規格變更
- 下次會議與後續追蹤

> 想調整摘要格式，改 `templates/summary-prompt.md` 即可。

## 資料夾結構

```
Recording-note/
├── setup.sh                  # 一次性安裝
├── run.sh                    # 主程式（丟檔→跑這個）
├── bin/transcribe.py         # Whisper 語音辨識
├── templates/summary-prompt.md  # 摘要 prompt 模板（可自訂）
├── input/                    # 把影片放這裡
└── output/                   # 逐字稿與摘要 prompt 在這裡
```
