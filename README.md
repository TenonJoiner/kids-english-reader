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
- 阿里云AI（OCR + TTS + 语音识别）
- 一个账号，三个服务

## 快速开始

### 1. 配置阿里云

1. 访问 https://www.aliyun.com
2. 注册/登录 → 实名认证
3. 开通以下服务：
   - **文字识别**（OCR）
   - **语音合成**（TTS）
   - **语音识别**
4. 创建AccessKey（右上角头像 → AccessKey管理）
5. 获取AppKey（在各服务控制台创建应用）

### 2. 配置环境变量

复制 `.env.example` 为 `.env`：

```bash
cp .env.example .env
```

编辑 `.env` 文件：

```
ALIBABA_ACCESS_KEY_ID=你的AccessKeyID
ALIBABA_ACCESS_KEY_SECRET=你的AccessKeySecret
ALIBABA_APP_KEY=你的AppKey
```

### 3. 本地运行

```bash
# 安装依赖
flutter pub get

# 运行App
flutter run
```

### 4. 构建发布

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 在线构建（推荐）

### Codemagic（免费）

1. 访问 https://codemagic.io
2. 使用GitHub账号登录
3. 导入本项目
4. 在 Environment Variables 中添加：
   - `ALIBABA_ACCESS_KEY_ID`
   - `ALIBABA_ACCESS_KEY_SECRET`
   - `ALIBABA_APP_KEY`
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
    ├── ocr_service.dart   # 阿里云OCR
    ├── tts_service.dart   # 阿里云TTS
    └── speech_service.dart # 阿里云语音识别
```

## 注意事项

1. **API Key安全**：不要把 `.env` 文件提交到GitHub
2. **首次运行**：需要授权相机和麦克风权限
3. **网络要求**：需要联网使用阿里云服务
4. **华为手机**：已适配国内阿里云服务

## 阿里云费用

| 服务 | 免费额度 | 超出后 |
|------|---------|--------|
| OCR文字识别 | 1万次/月 | 0.01元/次 |
| 语音合成TTS | 10万字/月 | 0.2元/千字 |
| 语音识别 | 2小时/月 | 1.6元/小时 |

个人使用完全免费。

## 后续优化方向

- [ ] 添加更多绘本内容
- [ ] 优化发音评估算法
- [ ] 添加学习进度同步
- [ ] 支持离线语音包下载
- [ ] 添加多语言支持

## License

MIT
