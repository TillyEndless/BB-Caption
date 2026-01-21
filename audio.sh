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
TRANSCRIBE_SCRIPT="transcribe.py"

# 创建 audio 和 txt 文件夹（如果不存在）
mkdir -p "$AUDIO_DIR"
mkdir -p "$TXT_DIR"

# 先用 BBDown 获取视频信息（不下载）
echo "正在获取视频信息..."
VIDEO_INFO=$(./BBDown "$VIDEO_URL" --info 2>&1)
SKIP_DOWNLOAD=false

# 尝试从现有文件中查找匹配的音频和txt文件
# 先检查 audio 目录中的所有文件
shopt -s nullglob  # 如果没有匹配文件，返回空而不是字面量
for ext in m4a mp3 aac flac; do
    for EXISTING_AUDIO in "$AUDIO_DIR"/*.$ext; do
        if [ -f "$EXISTING_AUDIO" ]; then
            AUDIO_BASENAME=$(basename "$EXISTING_AUDIO")
            TXT_BASENAME="${AUDIO_BASENAME%.*}.txt"
            EXISTING_TXT="$TXT_DIR/$TXT_BASENAME"
            
            # 如果找到对应的 txt 文件，跳过
            if [ -f "$EXISTING_TXT" ]; then
                echo "发现已存在的文件："
                echo "  音频: $EXISTING_AUDIO"
                echo "  文本: $EXISTING_TXT"
                
                AUDIO_FILE="$EXISTING_AUDIO"
                TXT_FILE="$EXISTING_TXT"
                SKIP_DOWNLOAD=true
                
                echo "跳过下载和转录，使用已存在的文件"
                echo "完成！转录文本位于: $TXT_FILE"
                exit 0
            fi
        fi
    done
done
shopt -u nullglob  # 恢复默认行为

# 如果没有找到现有文件，则进行下载
if [ "$SKIP_DOWNLOAD" = false ]; then
    echo "未找到已存在的文件，开始下载..."
    
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
    
    # 检查 txt 文件是否已存在
    if [ -f "$TXT_FILE" ]; then
        echo "文本文件已存在: $TXT_FILE"
        echo "跳过转录"
        exit 0
    fi
    
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
fi
