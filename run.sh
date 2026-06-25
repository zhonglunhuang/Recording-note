#!/usr/bin/env bash
#
# 主流程：把 input/ 裡的會議影片轉成逐字稿，並產生「會議記錄摘要 Prompt」。
#
# 用法：
#   bash run.sh                 # 處理 input/ 裡所有還沒處理過的影片
#   bash run.sh 某個影片.mp4     # 只處理指定檔案（可放 input/ 或給完整路徑）
#   MODEL=large-v3 bash run.sh   # 指定 Whisper 模型大小（預設 medium）
#
set -euo pipefail
cd "$(dirname "$0")"

MODEL="${MODEL:-medium}"
INPUT_DIR="input"
OUTPUT_DIR="output"
TEMPLATE="templates/summary-prompt.md"

if [ ! -d .venv ]; then
  echo "❌ 還沒安裝環境。請先執行：bash setup.sh"
  exit 1
fi
# shellcheck disable=SC1091
source .venv/bin/activate

# 收集要處理的檔案清單
files=()
if [ "$#" -ge 1 ]; then
  arg="$1"
  [ -f "$arg" ] && files+=("$arg") || files+=("$INPUT_DIR/$arg")
else
  shopt -s nullglob
  for f in "$INPUT_DIR"/*.{mp4,mkv,mov,webm,m4a,mp3,wav,avi}; do
    files+=("$f")
  done
  shopt -u nullglob
fi

if [ "${#files[@]}" -eq 0 ]; then
  echo "ℹ️  input/ 裡沒有找到影片/音訊檔。把 Google Meet 錄影丟進 input/ 再執行一次。"
  exit 0
fi

for src in "${files[@]}"; do
  [ -f "$src" ] || { echo "⚠️  找不到檔案：$src，略過"; continue; }
  base="$(basename "${src%.*}")"
  prompt_out="$OUTPUT_DIR/${base}__會議記錄prompt.md"

  echo ""
  echo "========================================"
  echo "📼 處理：$src"
  echo "========================================"

  # 已經有逐字稿就不重跑
  if [ ! -f "$OUTPUT_DIR/${base}.txt" ]; then
    python bin/transcribe.py "$src" "$OUTPUT_DIR" "$MODEL"
  else
    echo "   已有逐字稿，略過辨識：$OUTPUT_DIR/${base}.txt"
  fi

  # 用模板 + 逐字稿組出可直接貼給 Claude 的 prompt
  today="$(date +%Y-%m-%d)"
  TEMPLATE="$TEMPLATE" TXT="$OUTPUT_DIR/${base}.txt" OUT="$prompt_out" TODAY="$today" python3 <<'PY'
import os
tmpl = open(os.environ["TEMPLATE"], encoding="utf-8").read()
transcript = open(os.environ["TXT"], encoding="utf-8").read()
out = tmpl.replace("{{DATE}}", os.environ["TODAY"]).replace("{{TRANSCRIPT}}", transcript)
open(os.environ["OUT"], "w", encoding="utf-8").write(out)
PY

  echo ""
  echo "✅ 完成：$src"
  echo "   📄 逐字稿：     $OUTPUT_DIR/${base}.txt"
  echo "   📝 摘要 Prompt：$prompt_out"
done

echo ""
echo "👉 下一步：打開 output/ 裡的 *__會議記錄prompt.md，整份複製貼給 Claude，即可得到繁中會議記錄。"
