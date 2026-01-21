from faster_whisper import WhisperModel
import sys
import os
import time
from tqdm import tqdm

# 获取命令行参数
if len(sys.argv) < 2:
    print("用法: python transcribe.py <音频文件路径> [输出文件路径]")
    sys.exit(1)

audio_file = sys.argv[1]
output_file = sys.argv[2] if len(sys.argv) > 2 else None

# 检查音频文件是否存在
if not os.path.exists(audio_file):
    print(f"错误: 音频文件不存在: {audio_file}")
    sys.exit(1)

# 1. 选择模型大小，例如 "large-v3", "medium", "small" 等
model_size = "small"

# 2. 自动检测设备和计算类型
import platform
import torch

# 检测可用的设备
if torch.cuda.is_available():
    device = "cuda"
    compute_type = "float16"
    device_name = "NVIDIA GPU"
elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
    # Mac M1/M2/M3 的 Metal Performance Shaders
    device = "cpu"  # faster-whisper 目前不直接支持 MPS，使用 CPU
    compute_type = "int8"
    device_name = "CPU (Apple Silicon)"
else:
    device = "cpu"
    compute_type = "int8"
    device_name = "CPU"

print(f"正在加载 Whisper {model_size} 模型...")
print(f"使用设备: {device_name}")
print("提示: 首次使用会自动下载模型文件，可能需要几分钟，请耐心等待")
print("提示: 模型下载路径通常在 ~/.cache/huggingface/")
load_start = time.time()
model = WhisperModel(model_size, device=device, compute_type=compute_type)
load_time = time.time() - load_start
print(f"✓ 模型加载完成！耗时: {load_time:.1f} 秒")

# 3. 开始转录
# beam_size=5 是常用参数，用于提高准确度
print("\n开始转录音频...")
transcribe_start = time.time()
segments, info = model.transcribe(audio_file, beam_size=5)

# 打印检测到的语言和概率
print("检测到语言: '%s'，概率: %.2f%%" % (info.language, info.language_probability * 100))

# 获取音频总时长（秒）
duration = info.duration
print(f"音频总时长: {duration:.1f} 秒 ({duration/60:.1f} 分钟)")

# 4. 输出结果
# 如果指定了输出文件，将结果写入文件；否则打印到控制台
output_text = []
# 使用 tqdm 显示进度条，total 设置为音频总时长
with tqdm(total=duration, unit='秒', desc='转录进度', ncols=100, bar_format='{l_bar}{bar}| {n:.1f}/{total:.1f}秒 [{elapsed}<{remaining}]') as pbar:
    last_end = 0
    for segment in segments:
        text = segment.text
        output_text.append(text)
        
        # 更新进度条到当前段落的结束时间
        progress = segment.end - last_end
        pbar.update(progress)
        last_end = segment.end
        
        if not output_file:
            # 暂时禁用 tqdm，打印段落信息
            tqdm.write("[%.2fs -> %.2fs] %s" % (segment.start, segment.end, text))

# 如果有输出文件，将结果写入文件
transcribe_time = time.time() - transcribe_start
print(f"\n转录总耗时: {transcribe_time:.1f} 秒 ({transcribe_time/60:.1f} 分钟)")
if output_file:
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_text))
    print(f"✓ 转录完成！结果已保存到: {output_file}")
else:
    print("✓ 转录完成！")