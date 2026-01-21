#!/bin/bash
# 使用命令示例：
# ./caption.sh "https://www.bilibili.com/video/BV1rq4y1f78p/"

# 检查是否提供了视频网址参数
if [ -z "$1" ]; then
    echo "用法: $0 <视频网址>"
    exit 1
fi

VIDEO_URL="$1"
SRT_DIR="srt"
TXT_DIR="txt"

# 创建 srt 和 txt 文件夹（如果不存在）
mkdir -p "$SRT_DIR"
mkdir -p "$TXT_DIR"

# 运行 BBDown 下载字幕
./BBDown "$VIDEO_URL" --sub-only --skip-ai false

# 查找最新生成的 .srt 文件
SRT_FILE=$(ls -t *.srt 2>/dev/null | head -n 1)

if [ -z "$SRT_FILE" ]; then
    echo "错误: 未找到 .srt 文件"
    exit 1
fi

# 获取文件名（不含路径）
SRT_BASENAME=$(basename "$SRT_FILE")
TXT_BASENAME="${SRT_BASENAME%.srt}.txt"

# 将 .srt 文件移动到 srt 文件夹
mv "$SRT_FILE" "$SRT_DIR/$SRT_BASENAME"

# 使用 sed 处理 .srt 文件并转换为 .txt，直接保存到 txt 文件夹
sed -e '/^[0-9][0-9]:/d' -e '/^[0-9]*$/d' -e '/^$/d' "$SRT_DIR/$SRT_BASENAME" > "$TXT_DIR/$TXT_BASENAME"

echo "完成！已生成文件:"
echo "  SRT: $SRT_DIR/$SRT_BASENAME"
echo "  TXT: $TXT_DIR/$TXT_BASENAME"
