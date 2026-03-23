# GitHub Actions 构建指南

## 优势

- ✅ 完全免费（GitHub官方提供）
- ✅ 无需第三方平台
- ✅ 自动发布Release
- ✅ 每次推送自动构建

## 配置步骤

### 步骤1：配置Secrets（密钥）

1. 打开GitHub仓库页面
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**，添加以下3个：

| Secret名称 | 值 | 说明 |
|-----------|-----|------|
| `ALIBABA_ACCESS_KEY_ID` | 你的AccessKey ID | 阿里云控制台获取 |
| `ALIBABA_ACCESS_KEY_SECRET` | 你的AccessKey Secret | 同上 |
| `ALIBABA_APP_KEY` | 你的AppKey | 语音服务控制台 |

### 步骤2：触发构建

有两种方式：

#### 方式A：自动触发
- 推送代码到 `master` 分支
- 自动开始构建

#### 方式B：手动触发
1. 打开仓库页面
2. 点击 **Actions** 标签
3. 选择 **Android Build**
4. 点击 **Run workflow** → **Run workflow**

### 步骤3：下载APK

构建完成后（约5-10分钟）：

#### 方式A：从Artifacts下载
1. 点击 **Actions** 标签
2. 点击最新的构建记录
3. 页面底部 **Artifacts** 区域
4. 下载 `release-apk`

#### 方式B：从Release下载（推荐）
1. 点击仓库页面的 **Releases**
2. 找到最新版本（如 `v1`）
3. 下载 `app-release.apk`

## 查看构建状态

1. 点击仓库 **Actions** 标签
2. 查看构建进度和日志
3. 绿色✅表示成功，红色❌表示失败

## 常见问题

### Q: 构建失败怎么办？
A: 点击失败的构建记录，查看日志：
- 检查Secrets是否配置正确
- 检查阿里云服务是否开通
- 检查代码是否有语法错误

### Q: 如何更新APK？
A: 修改代码 → 提交 → 推送到master → 自动构建并发布新版本

### Q: 构建时间多长？
A: 通常5-10分钟，取决于GitHub服务器负载

### Q: 免费额度多少？
A: GitHub Actions免费额度：
- 公共仓库：无限免费
- 私有仓库：2000分钟/月

## 下一步

1. 配置好3个Secrets
2. 推送一次代码触发构建
3. 等待5-10分钟
4. 从Releases下载APK安装
