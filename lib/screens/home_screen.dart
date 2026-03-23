import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../services/tts_service.dart';
import 'camera_screen.dart';
import 'parent_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TTSService _ttsService = TTSService();
  final SettingsService _settingsService = SettingsService();
  int _booksRead = 3;
  int _stars = 15;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _settingsService.init();
    await _ttsService.init();
    
    // 欢迎语音
    Future.delayed(const Duration(seconds: 1), () {
      _ttsService.speak('来，我们一起读绘本吧！点击大按钮开始');
    });
  }

  void _startReading() {
    if (!_settingsService.isConfigured) {
      // 未配置，跳转到设置
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsScreen(isFirstSetup: true),
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }

  void _enterParentMode() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('家长验证'),
        content: const Text('请输入家长密码'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParentScreen()),
              );
            },
            child: const Text('进入'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF5D4037)),
            onPressed: _openSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // 标题
            const Text(
              '📚 开始读绘本',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // 大按钮
            GestureDetector(
              onTap: _startReading,
              onLongPress: _enterParentMode,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '点击拍照',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF8D6E63),
              ),
            ),
            
            const Spacer(),
            
            // 统计信息
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '本周已读: ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      Text(
                        '$_booksRead本',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < (_stars ~/ 5) ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
