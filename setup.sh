#!/usr/bin/env bash
#
# 一次性環境安裝：ffmpeg + 本機 Whisper
# 用法：bash setup.sh
#
set -euo pipefail

cd "$(dirname "$0")"

echo "==> 1/4 檢查 Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "❌ 找不到 Homebrew。請先安裝：https://brew.sh"
  exit 1
fi

echo "==> 2/4 安裝 ffmpeg（影音轉檔用）"
if ! command -v ffmpeg >/dev/null 2>&1; then
  brew install ffmpeg
else
  echo "   ffmpeg 已安裝，略過"
fi

echo "==> 3/4 建立 Python 虛擬環境 (.venv)"
if [ ! -d .venv ]; then
  python3 -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate

echo "==> 4/4 安裝 Whisper（語音辨識）"
pip install --upgrade pip >/dev/null
# faster-whisper 在 Mac CPU 上比官方 whisper 快很多
pip install faster-whisper

echo ""
echo "✅ 安裝完成！"
echo "   接下來把會議影片丟進 input/ 資料夾，然後執行："
echo "   bash run.sh"
