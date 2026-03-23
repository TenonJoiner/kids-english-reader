import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// 启动页 - 检查是否需要首次设置
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSettings();
  }

  Future<void> _checkSettings() async {
    final settingsService = SettingsService();
    await settingsService.init();

    await Future.delayed(const Duration(seconds: 2)); // 显示启动页2秒

    if (mounted) {
      if (settingsService.isConfigured) {
        // 已配置，跳转到首页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // 未配置，跳转到设置页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(isFirstSetup: true),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
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
              child: const Icon(
                Icons.menu_book,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            // 标题
            const Text(
              '绘本阅读',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '儿童英语绘本辅导',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8D6E63),
              ),
            ),
            
            const SizedBox(height: 50),
            
            // 加载动画
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
