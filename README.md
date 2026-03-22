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
- Google ML Kit (OCR)
- flutter_tts (语音合成)
- speech_to_text (语音识别)

## 安装运行

```bash
# 1. 安装依赖
flutter pub get

# 2. 运行App
flutter run
```

## 构建发布

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

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
    ├── tts_service.dart   # 语音合成
    ├── ocr_service.dart   # 文字识别
    └── speech_service.dart # 语音识别
```

## 注意事项

1. 首次运行需要授权相机和麦克风权限
2. OCR识别需要清晰的图片
3. 语音识别需要安静的环境

## 后续优化方向

- [ ] 添加更多绘本内容
- [ ] 优化发音评估算法
- [ ] 添加学习进度同步
- [ ] 支持离线语音包下载
- [ ] 添加多语言支持
