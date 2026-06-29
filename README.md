# 课记 - 视频笔记生成工具

一个独立的 Flutter 桌面/移动应用，用于将视频课程转换为结构化笔记。

## AltStore 安装（iOS）

通过 AltStore 源一键安装，无需手动签名：

```
https://shupian35.github.io/altstore-source/apps.json
```

在 AltStore / SideStore / LiveContainer 中导入上述源 URL 即可。

## 功能特性

- **视频导入**：支持文件选择器，批量导入
- **原文导入**：支持导入文本文件直接生成笔记
- **音频提取**：调用系统 FFmpeg 提取音频轨道
- **语音转写**：支持多种 ASR 服务商
  - SiliconFlow（默认）
  - 小米 MiMo ASR
  - OpenAI Whisper
  - 自定义 OpenAI 兼容 API
- **笔记生成**：调用 LLM API 生成结构化 Markdown 笔记
- **笔记查看**：Markdown 渲染、支持复制、多行选择
- **笔记管理**：列表、删除、批量删除
- **导出功能**：单个/批量导出为 .md 或 .txt 文件
- **视频播放**：支持进度条拖拽、倍速播放、音量调节、全屏模式、键盘快捷键
- **主题切换**：浅色/深色/跟随系统
- **国际化**：支持简体中文、繁体中文、英文
- **错误提示**：统一弹出框错误提示
- **关于页面**：版本信息、项目主页、开源许可证、错误日志、检查更新

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 运行代码生成

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. 运行应用

```bash
# 桌面端
flutter run -d windows
flutter run -d macos
flutter run -d linux

# 移动端
flutter run -d android
flutter run -d ios
```

## 配置

在设置页面配置以下 API：

### ASR（语音转写）

支持多种服务商预设：

| 服务商 | API 地址 | 模型 |
|--------|----------|------|
| SiliconFlow | `https://api.siliconflow.cn/v1` | `FunAudioLLM/SenseVoiceSmall` |
| 小米 MiMo | `https://api.xiaomimimo.com/v1` | `mimo-v2.5-asr` |
| OpenAI | `https://api.openai.com/v1` | `whisper-1` |
| 自定义 | 用户配置 | 用户配置 |

### LLM（笔记生成）

- **API Key**：OpenAI 或其他兼容 API
- **API 地址**：默认 `https://api.openai.com/v1`
- **模型**：默认 `gpt-4o-mini`

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用配置
├── core/                        # 核心基础设施
│   ├── constants.dart           # 常量定义
│   ├── error_handler.dart       # 统一错误处理
│   ├── exceptions.dart          # 自定义异常
│   ├── ffmpeg_service.dart      # FFmpeg 调用封装
│   ├── providers.dart           # Riverpod providers
│   └── theme_provider.dart      # 主题状态管理
├── models/                      # 数据模型
│   ├── video_record.dart        # 视频记录
│   └── note.dart                # 笔记
├── services/                    # 业务服务
│   ├── asr_service.dart         # ASR 语音转写（支持小米 MiMo）
│   ├── llm_service.dart         # LLM 笔记生成
│   ├── video_processor.dart     # 视频处理流水线（队列模式）
│   └── export_service.dart      # 导出服务（支持批量）
├── database/                    # 数据库层
│   └── app_database.dart        # SQLite 数据库
├── features/                    # 功能模块
│   ├── home/                    # 主页：视频列表、批量操作
│   ├── import/                  # 导入视频/原文
│   ├── processing/              # 处理进度
│   ├── viewer/                  # 笔记查看、视频播放
│   └── settings/                # 设置页（含关于页面）
├── widgets/                     # 通用组件
│   └── adaptive_scaffold.dart   # 自适应布局
└── router/                      # 路由配置
    └── app_router.dart
```

## 技术栈

- **状态管理**：Riverpod 2
- **路由**：go_router
- **HTTP**：dio / http
- **数据库**：sqflite + sqflite_common_ffi
- **FFmpeg**：系统 ffmpeg 调用
- **视频播放**：media_kit（基于 libmpv）
- **Markdown**：flutter_markdown
- **国际化**：flutter_localizations

## 视频播放快捷键

| 快捷键 | 功能 |
|--------|------|
| 空格 | 播放/暂停 |
| ← | 快退 5 秒 |
| → | 快进 5 秒 |
| M | 静音/取消静音 |

## 平台支持

| 平台 | 状态 |
|------|------|
| Windows | ✅ 完整支持 |
| macOS | ✅ 完整支持 |
| Linux | ✅ 完整支持 |
| Android | ✅ 支持 |
| iOS | ✅ 支持 |

## 开发计划

- [x] Phase 1：基础骨架
- [x] Phase 2：视频导入 + FFmpeg
- [x] Phase 3：ASR 转写
- [x] Phase 4：LLM 生成笔记
- [x] Phase 5：笔记查看
- [x] Phase 6：完善体验
- [x] Phase 7：视频播放增强

## 许可证

MIT License
