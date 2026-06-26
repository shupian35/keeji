# 课记 - 视频笔记生成工具

一个独立的 Flutter 桌面/移动应用，用于将视频课程转换为结构化笔记。

## 功能特性

- **视频导入**：支持文件选择器和桌面拖拽
- **音频提取**：调用 FFmpeg 提取音频轨道
- **语音转写**：调用 SiliconFlow / OpenAI 兼容 ASR API
- **笔记生成**：调用 LLM API 生成结构化 Markdown 笔记
- **笔记查看**：Markdown 渲染、视频播放
- **笔记管理**：列表、删除、重命名
- **导出功能**：导出为 .md 或 .txt 文件

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

- **API Key**：SiliconFlow 或其他 OpenAI 兼容 API
- **API 地址**：默认 `https://api.siliconflow.cn/v1`
- **模型**：默认 `FunAudioLLM/SenseVoiceSmall`

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
│   ├── config.dart              # 应用配置
│   ├── constants.dart           # 常量定义
│   ├── exceptions.dart          # 自定义异常
│   ├── ffmpeg_service.dart      # FFmpeg 调用封装
│   └── providers.dart           # Riverpod providers
├── models/                      # 数据模型
│   ├── video_record.dart        # 视频记录
│   └── note.dart                # 笔记
├── services/                    # 业务服务
│   ├── asr_service.dart         # ASR 语音转写
│   ├── llm_service.dart         # LLM 笔记生成
│   ├── video_processor.dart     # 视频处理流水线
│   └── export_service.dart      # 导出服务
├── database/                    # 数据库层
│   ├── app_database.dart        # drift 数据库
│   ├── tables.dart              # 表定义
│   └── daos/                    # 数据访问对象
│       ├── video_dao.dart
│       └── note_dao.dart
├── features/                    # 功能模块
│   ├── home/                    # 主页：视频列表
│   ├── import/                  # 导入视频
│   ├── processing/              # 处理进度
│   ├── viewer/                  # 笔记查看
│   └── settings/                # 设置页
├── widgets/                     # 通用组件
│   └── adaptive_scaffold.dart   # 自适应布局
└── router/                      # 路由配置
    └── app_router.dart
```

## 技术栈

- **状态管理**：Riverpod 2
- **路由**：go_router
- **HTTP**：dio
- **数据库**：drift (SQLite)
- **视频播放**：media_kit
- **FFmpeg**：系统 ffmpeg 调用

## 平台支持

- Windows
- macOS
- Linux
- Android
- iOS

## 开发计划

- [x] Phase 1：基础骨架
- [x] Phase 2：视频导入 + FFmpeg
- [x] Phase 3：ASR 转写
- [x] Phase 4：LLM 生成笔记
- [x] Phase 5：笔记查看
- [x] Phase 6：完善体验

## 许可证

MIT License
