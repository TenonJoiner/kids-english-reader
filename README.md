# Kids English Reader - 儿童英语绘本阅读App

## 项目简介

一个简单的儿童英语绘本阅读App，支持拍照识别绘本文字，通过"听-说-读"三步教学法帮助孩子学习英语。

## 功能特性

- 📷 拍照识别绘本文字（OCR）
- 🔊 语音朗读（TTS）
- 🎤 语音识别和评估
- ⭐ 游戏化奖励系统
- 👨‍👩‍👧‍👦 家长模式
- ⚙️ App内配置百炼API Key（只需一个密钥）

## 三步教学法

1. **听** - 听App朗读绘本内容
2. **说** - 跟着App一起读
3. **读** - 独立朗读，获得评分

## 技术栈

- Flutter 3.0+
- 阿里云百炼MAAS（OCR + TTS + 语音识别）
- 一个API Key搞定所有AI服务

## 快速开始

### 1. 安装App

从 [Releases](https://github.com/TenonJoiner/kids-english-reader/releases) 下载最新APK并安装。

### 2. 配置百炼API Key

**首次打开App时**，需要配置阿里云百炼API Key：

1. 访问 https://bailian.console.aliyun.com
2. 注册/登录阿里云账号
3. 点击"创建API Key"
4. 复制API Key到App设置页面

### 3. 开始使用

- 点击大按钮拍照
- OCR识别绘本文字
- 按"听-说-读"三步学习

## 百炼MAAS费用

| 服务 | 免费额度 | 超出后 |
|------|---------|--------|
| OCR文字识别 | 1000次/月 | 0.01元/次 |
| 语音合成TTS | 1000次/月 | 0.01元/次 |
| 语音识别 | 1000次/月 | 0.01元/次 |

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
│   └── settings_screen.dart # 设置页面（配置API Key）
└── services/              # 服务
    ├── settings_service.dart   # 本地设置管理
    ├── ocr_service.dart        # 百炼OCR
    ├── tts_service.dart        # 百炼TTS
    └── speech_service.dart     # 百炼语音识别
```

## 隐私说明

- 百炼API Key仅保存在手机本地（SharedPreferences）
- 不会上传到任何服务器
- 拍照的绘本图片仅用于OCR识别，不会保存

## 注意事项

1. **首次使用必须配置API Key**，否则无法使用核心功能
2. **需要联网**，所有AI服务都在百炼云端运行
3. **授予权限**：相机（拍照）、麦克风（语音识别）
4. **华为手机**：已适配

## 后续优化方向

- [ ] 添加更多绘本内容
- [ ] 优化发音评估算法
- [ ] 添加学习进度同步
- [ ] 支持离线语音包下载
- [ ] 添加多语言支持

## License

MIT
