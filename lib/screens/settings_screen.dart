import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import 'home_screen.dart';

/// 设置页面 - 配置阿里云API密钥
class SettingsScreen extends StatefulWidget {
  final bool isFirstSetup;
  
  const SettingsScreen({
    super.key,
    this.isFirstSetup = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settingsService = SettingsService();
  
  final _accessKeyIdController = TextEditingController();
  final _accessKeySecretController = TextEditingController();
  final _appKeyController = TextEditingController();
  
  bool _isLoading = false;
  bool _showSecret = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsService.init();
    setState(() {
      _accessKeyIdController.text = _settingsService.accessKeyId ?? '';
      _accessKeySecretController.text = _settingsService.accessKeySecret ?? '';
      _appKeyController.text = _settingsService.appKey ?? '';
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _settingsService.setAccessKeyId(_accessKeyIdController.text.trim());
      await _settingsService.setAccessKeySecret(_accessKeySecretController.text.trim());
      await _settingsService.setAppKey(_appKeyController.text.trim());
      await _settingsService.setFirstRunComplete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('设置已保存'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.isFirstSetup) {
          // 首次设置，跳转到首页
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: widget.isFirstSetup
          ? null
          : AppBar(
              title: const Text('设置'),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isFirstSetup) ...[
                  const Center(
                    child: Icon(
                      Icons.settings,
                      size: 80,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      '欢迎使用绘本阅读',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      '请先配置阿里云API密钥',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // 说明卡片
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            '如何获取密钥？',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. 访问 ai.aliyun.com\n'
                        '2. 注册/登录阿里云账号\n'
                        '3. 开通语音合成、语音识别、文字识别服务\n'
                        '4. 在控制台获取AccessKey和AppKey',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5D4037),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // AccessKey ID
                _buildTextField(
                  controller: _accessKeyIdController,
                  label: 'AccessKey ID',
                  hint: '请输入AccessKey ID',
                  icon: Icons.key,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'AccessKey ID不能为空';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // AccessKey Secret
                _buildTextField(
                  controller: _accessKeySecretController,
                  label: 'AccessKey Secret',
                  hint: '请输入AccessKey Secret',
                  icon: Icons.lock,
                  obscureText: !_showSecret,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showSecret ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _showSecret = !_showSecret);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'AccessKey Secret不能为空';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // AppKey
                _buildTextField(
                  controller: _appKeyController,
                  label: 'AppKey',
                  hint: '请输入AppKey',
                  icon: Icons.apps,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'AppKey不能为空';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isFirstSetup ? '开始使用' : '保存设置',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                if (!widget.isFirstSetup) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.orange),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _accessKeyIdController.dispose();
    _accessKeySecretController.dispose();
    _appKeyController.dispose();
    super.dispose();
  }
}
