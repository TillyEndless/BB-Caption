#!/bin/bash
# 使用命令示例：
# ./audio.sh "https://www.bilibili.com/video/BV1rq4y1f78p/"

# 检查是否提供了视频网址参数
if [ -z "$1" ]; then
    echo "用法: $0 <视频网址>"
    exit 1
fi

VIDEO_URL="$1"
AUDIO_DIR="audio"
TXT_DIR="txt"
TRANSCRIBE_SCRIPT="faster-whisper/transcribe.py"

# 创建 audio 和 txt 文件夹（如果不存在）
mkdir -p "$AUDIO_DIR"
mkdir -p "$TXT_DIR"

# 运行 BBDown 下载m4a文件
./BBDown "$VIDEO_URL" --audio-only

# 将下载的音频文件移动到 audio 文件夹
find . -maxdepth 1 -type f \( -name "*.m4a" -o -name "*.mp3" -o -name "*.aac" -o -name "*.flac" \) -exec mv {} "$AUDIO_DIR/" \;

# 查找刚刚移动到 audio 文件夹的最新音频文件
AUDIO_FILE=$(ls -t "$AUDIO_DIR"/*.{m4a,mp3,aac,flac} 2>/dev/null | head -n 1)

if [ -z "$AUDIO_FILE" ]; then
    echo "错误: 未找到音频文件"
    exit 1
fi

echo "音频文件已保存到: $AUDIO_FILE"

# 生成输出文件名（将音频扩展名替换为 .txt）
AUDIO_BASENAME=$(basename "$AUDIO_FILE")
TXT_BASENAME="${AUDIO_BASENAME%.*}.txt"
TXT_FILE="$TXT_DIR/$TXT_BASENAME"

# 运行语音转文本
echo "开始进行语音转文本..."
# 使用虚拟环境中的 Python（如果已激活）或系统 Python
python "$TRANSCRIBE_SCRIPT" "$AUDIO_FILE" "$TXT_FILE"

if [ $? -eq 0 ]; then
    echo "完成！转录文本已保存到: $TXT_FILE"
else
    echo "错误: 语音转文本失败"
    exit 1
fi
