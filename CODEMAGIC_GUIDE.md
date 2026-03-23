# Codemagic 构建配置指南

## 步骤1：注册Codemagic

1. 访问 https://codemagic.io
2. 点击 "Sign up" → 选择 "Sign up with GitHub"
3. 授权Codemagic访问你的GitHub仓库

## 步骤2：导入项目

1. 登录后点击 "Add application"
2. 选择 GitHub → 选择 `TenonJoiner/kids-english-reader`
3. 点击 "Add application"

## 步骤3：配置环境变量

1. 在项目页面，点击左侧 "Environment variables"
2. 点击 "Add variable" 添加以下变量：

| 变量名 | 说明 | 获取位置 |
|--------|------|---------|
| `ALIBABA_ACCESS_KEY_ID` | 阿里云AccessKey ID | 阿里云控制台 → AccessKey管理 |
| `ALIBABA_ACCESS_KEY_SECRET` | 阿里云AccessKey Secret | 同上 |
| `ALIBABA_APP_KEY` | 阿里云AppKey | 语音合成/识别控制台 |

3. 勾选 "Secure" 保护敏感信息

## 步骤4：配置构建

1. 点击左侧 "Workflow settings"
2. 确保选择了 `codemagic.yaml` 配置
3. 点击 "Save"

## 步骤5：开始构建

1. 点击右上角 "Start new build"
2. 选择分支：`master`
3. 选择工作流：`Android Release Build`
4. 点击 "Start new build"

## 步骤6：获取APK

构建完成后（约5-10分钟）：
- 在 "Artifacts" 标签下载APK
- 或检查邮箱，APK会自动发送

## 费用说明

Codemagic免费额度：
- 每月500分钟构建时间
- 足够构建20-30次

超出后：$0.015/分钟（约0.1元/分钟）

## 自动构建

配置完成后，每次推送到master分支会自动触发构建。

## 常见问题

### Q: 构建失败怎么办？
A: 检查构建日志，常见问题：
- 环境变量未配置
- 阿里云服务未开通
- 代码语法错误

### Q: 如何更新APK？
A: 修改代码 → 提交 → 推送到master → 自动触发构建

### Q: 可以构建iOS吗？
A: 需要Apple Developer账号（$99/年），Codemagic支持但需额外配置。
