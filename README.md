# Bilibili Video to Text Automation (B站视频转文本自动化工具)

这是一个基于 Shell 的自动化脚本，整合了业界优秀的开源工具，用于将 Bilibili 视频（包括硬字幕、外挂字幕、CC字幕）一键转换为 TXT 文本，便于个人资料收集和整理。

## ⚠️ 免责声明 (Disclaimer)

1. 本工具仅供**个人学习和技术研究**使用。
2. 请勿用于商业用途或大规模批量抓取，否则后果自负。
3. 视频内容的版权归原作者所有，请在下载后24小时内删除，支持正版。
4. 本仓库不提供任何视频下载核心逆向算法，仅作为现有开源工具的自动化封装。

## 🙏 致谢 / 核心组件

本项目的实现依赖以下优秀的开源项目，感谢开发者的贡献：

*   **视频/音频提取**: [nilaoda/BBDown](https://github.com/nilaoda/BBDown) (MIT License)
*   **语音转文本 (ASR)**: [SYSTRAN/faster-whisper](https://github.com/SYSTRAN/faster-whisper) (MIT License)

## 功能特性

*   提供 Bilibili 视频链接，自动处理下载。
*   **外挂/AI字幕**: 优先拉取官方提供的外挂或AI识别字幕。
*   **硬字幕/语音**: 对无字幕视频，自动提取音频并使用 faster-whisper 进行高精度识别。

## 环境依赖

请参考上述两个上游仓库的官方文档安装 `ffmpeg`, `Python 3.10+`, `BBDown` 等依赖。

## 使用方法

### 1. 提取外挂字幕/官方AI字幕

```bash
chmod +x caption.sh
./caption.sh "https://www.bilibili.com/video/BVxxx..."
```

### 2. 语音转文字 (针对硬字幕/无字幕视频)

注意：语音识别存在一定误差，取决于音频清晰度。

```bash
chmod +x audio.sh
./audio.sh "https://www.bilibili.com/video/BVxxx..."
```

## 输出文件说明

*   `audio/` - 下载的音频文件（.m4a）
*   `srt/` - 下载的字幕文件（.srt）
*   `txt/` - 转换后的文本文件（.txt）

## 安全提示

⚠️ **重要**: 请确保以下文件不会被提交到 Git 仓库：

*   `BBDown.data` - 包含个人登录信息
*   `cookies.txt` - Cookie 文件
*   `config.json` - 配置文件
*   `audio/`, `txt/`, `srt/` - 下载的内容文件夹

以上文件已在 `.gitignore` 中配置忽略规则。
