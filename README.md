# Kids English Reader - 儿童英语绘本阅读App

## 项目简介

一个简单的儿童英语绘本阅读App，支持拍照识别绘本文字，通过"听-说-读"三步教学法帮助孩子学习英语。

## 功能特性

- 📷 拍照识别绘本文字（OCR）
- 🔊 语音朗读（TTS）
- 🎤 语音识别和评估
- ⭐ 游戏化奖励系统
- 👨‍👩‍👧‍👦 家长模式
- ⚙️ App内配置阿里云密钥

## 三步教学法

1. **听** - 听App朗读绘本内容
2. **说** - 跟着App一起读
3. **读** - 独立朗读，获得评分

## 技术栈

- Flutter 3.0+
- 阿里云AI（OCR + TTS + 语音识别）
- SharedPreferences（本地存储密钥）

## 快速开始

### 1. 安装App

从 [Releases](https://github.com/TenonJoiner/kids-english-reader/releases) 下载最新APK并安装。

### 2. 配置阿里云密钥

**首次打开App时**，需要配置阿里云API密钥：

1. 访问 https://ai.aliyun.com
2. 注册/登录阿里云账号
3. 开通以下服务：
   - **文字识别**（OCR）
   - **语音合成**（TTS）
   - **语音识别**
4. 获取密钥：
   - AccessKey ID / Secret（右上角 → AccessKey管理）
   - AppKey（语音合成/识别控制台 → 创建应用）
5. 在App设置页面填入密钥

### 3. 开始使用

- 点击大按钮拍照
- OCR识别绘本文字
- 按"听-说-读"三步学习

## 阿里云费用

| 服务 | 免费额度 | 超出后 |
|------|---------|--------|
| OCR文字识别 | 1万次/月 | 0.01元/次 |
| 语音合成TTS | 10万字/月 | 0.2元/千字 |
| 语音识别 | 2小时/月 | 1.6元/小时 |

个人使用完全免费。

## 自行构建

```bash
# 克隆项目
git clone https://github.com/TenonJoiner/kids-english-reader.git
cd kids-english-reader

# 安装依赖
flutter pub get

# 运行
flutter run

# 构建APK
flutter build apk --release
```

## 项目结构

```
lib/
├── main.dart              # 入口文件
├── screens/               # 页面
│   ├── splash_screen.dart # 启动页（检查配置）
│   ├── home_screen.dart   # 首页
│   ├── camera_screen.dart # 相机/相册选择
│   ├── learning_screen.dart # 学习页面
│   ├── parent_screen.dart # 家长模式
│   └── settings_screen.dart # 设置页面（配置密钥）
└── services/              # 服务
    ├── settings_service.dart   # 本地设置管理
    ├── ocr_service.dart        # 阿里云OCR
    ├── tts_service.dart        # 阿里云TTS
    └── speech_service.dart     # 阿里云语音识别
```

## 隐私说明

- 阿里云密钥仅保存在手机本地（SharedPreferences）
- 不会上传到任何服务器
- 拍照的绘本图片仅用于OCR识别，不会保存

## 注意事项

1. **首次使用必须配置密钥**，否则无法使用核心功能
2. **需要联网**，所有AI服务都在云端运行
3. **授予权限**：相机（拍照）、麦克风（语音识别）
4. **华为手机**：已适配国内阿里云服务

## 后续优化方向

- [ ] 添加更多绘本内容
- [ ] 优化发音评估算法
- [ ] 添加学习进度同步
- [ ] 支持离线语音包下载
- [ ] 添加多语言支持

## License

MIT
