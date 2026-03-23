# Kids English Reader - 儿童英语绘本阅读App

## 项目简介

一个简单的儿童英语绘本阅读App，支持拍照识别绘本文字，通过"听-说-读"三步教学法帮助孩子学习英语。

## 功能特性

- 📷 拍照识别绘本文字（OCR）
- 🔊 语音朗读（TTS）
- 🎤 语音识别和评估
- ⭐ 游戏化奖励系统
- 👨‍👩‍👧‍👦 家长模式

## 三步教学法

1. **听** - 听App朗读绘本内容
2. **说** - 跟着App一起读
3. **读** - 独立朗读，获得评分

## 技术栈

- Flutter 3.0+
- 百度AI（OCR + TTS + ASR）
- 国内服务，稳定访问

## 快速开始

### 1. 配置API Key

复制 `.env.example` 为 `.env`，填入你的百度AI API Key：

```bash
cp .env.example .env
# 编辑 .env 文件，填入你的API Key
```

获取API Key：
- 访问 [百度AI开放平台](https://ai.baidu.com)
- 注册账号并创建应用
- 获取 AppID、API Key、Secret Key

### 2. 本地运行

```bash
# 安装依赖
flutter pub get

# 运行App
flutter run
```

### 3. 构建发布

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 在线构建（推荐）

### Codemagic（免费）

1. 访问 [Codemagic](https://codemagic.io)
2. 使用GitHub账号登录
3. 导入本项目
4. 配置环境变量（百度API Key）
5. 点击 "Start new build"

构建完成后，APK会自动发送到你的邮箱。

## 项目结构

```
lib/
├── main.dart              # 入口文件
├── screens/               # 页面
│   ├── home_screen.dart   # 首页
│   ├── camera_screen.dart # 相机/相册选择
│   ├── learning_screen.dart # 学习页面
│   └── parent_screen.dart # 家长模式
└── services/              # 服务
    ├── ocr_service.dart   # 百度OCR
    ├── tts_service.dart   # 百度TTS
    └── speech_service.dart # 百度语音识别
```

## 注意事项

1. **API Key安全**：不要把 `.env` 文件提交到GitHub
2. **首次运行**：需要授权相机和麦克风权限
3. **网络要求**：OCR/TTS/语音识别需要联网
4. **华为手机**：已在代码中适配国内服务

## 服务说明

| 功能 | 服务 | 费用 |
|------|------|------|
| OCR文字识别 | 百度AI | 免费额度5万次/天 |
| 语音合成TTS | 百度AI | 免费额度20万次/天 |
| 语音识别ASR | 百度AI | 免费额度5万次/天 |

免费额度足够个人使用。

## 后续优化方向

- [ ] 添加更多绘本内容
- [ ] 优化发音评估算法
- [ ] 添加学习进度同步
- [ ] 支持离线语音包下载
- [ ] 添加多语言支持

## License

MIT
