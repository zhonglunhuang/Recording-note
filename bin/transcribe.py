#!/usr/bin/env python3
"""
把音訊/影片轉成逐字稿（繁體中文）。
用法：python bin/transcribe.py <檔案路徑> <輸出目錄> [model_size]
輸出：<輸出目錄>/<檔名>.txt（純逐字稿）與 <檔名>.srt（含時間軸）
"""
import sys
import os
from datetime import timedelta

from faster_whisper import WhisperModel


def fmt_ts(seconds: float) -> str:
    td = timedelta(seconds=seconds)
    total = int(td.total_seconds())
    h, m, s = total // 3600, (total % 3600) // 60, total % 60
    ms = int((seconds - total) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def main():
    if len(sys.argv) < 3:
        print("用法：python bin/transcribe.py <檔案> <輸出目錄> [model_size]")
        sys.exit(1)

    src = sys.argv[1]
    out_dir = sys.argv[2]
    model_size = sys.argv[3] if len(sys.argv) > 3 else "small"

    base = os.path.splitext(os.path.basename(src))[0]
    txt_path = os.path.join(out_dir, f"{base}.txt")
    srt_path = os.path.join(out_dir, f"{base}.srt")

    print(f"   載入模型：{model_size}（首次會自動下載）...")
    model = WhisperModel(model_size, device="cpu", compute_type="int8")

    print("   開始辨識（長影片請耐心等候）...")
    segments, info = model.transcribe(
        src,
        language="zh",
        vad_filter=True,
        initial_prompt="以下是一場軟體開發團隊的會議，內容為繁體中文，包含技術名詞、API、需求、排程與待辦事項。",
    )

    # 邊辨識邊寫檔，萬一中途被中斷也能保留已完成的進度
    txt_f = open(txt_path, "w", encoding="utf-8")
    srt_f = open(srt_path, "w", encoding="utf-8")
    try:
        for i, seg in enumerate(segments, 1):
            text = seg.text.strip()
            txt_f.write(text + "\n")
            srt_f.write(f"{i}\n{fmt_ts(seg.start)} --> {fmt_ts(seg.end)}\n{text}\n\n")
            if i % 10 == 0:
                txt_f.flush()
                srt_f.flush()
                print(f"   已處理 {i} 段（約 {seg.end/60:.1f} 分鐘）...", flush=True)
    finally:
        txt_f.close()
        srt_f.close()

    print(f"   逐字稿：{txt_path}")
    print(f"   字幕檔：{srt_path}")


if __name__ == "__main__":
    main()
