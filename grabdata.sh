#!/bin/bash
set -e

# === 配置部分 ===
export HF_ENDPOINT="https://hf-mirror.com"
DATASET="PolyU-ChenLab/UniPixel-SFT-1M"
TARGET_DIR="./data"
REPO_TYPE="dataset"

echo ">>> 使用镜像: $HF_ENDPOINT"
echo ">>> 下载数据集: $DATASET"
echo ">>> 保存路径: $TARGET_DIR"
echo

# === 检查 huggingface-cli ===
if ! command -v huggingface-cli &> /dev/null; then
    echo "[ERROR] 未找到 huggingface-cli，请先安装:"
    echo "pip install -U huggingface_hub"
    exit 1
fi

# === 创建目录 ===
mkdir -p "$TARGET_DIR"

# === 开始下载 (支持断点续传) ===
echo ">>> 开始下载 (可断点续传)..."

huggingface-cli download "$DATASET" \
    --repo-type "$REPO_TYPE" \
    --local-dir "$TARGET_DIR" \
    --resume-download \
    --local-dir-use-symlinks False

echo
echo "✅ 下载完成，文件保存在: $TARGET_DIR"
