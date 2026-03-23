import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'settings_service.dart';

/// TTS服务 - 使用阿里云百炼MAAS
class TTSService {
  static const String _endpoint = 'https://dashscope.aliyuncs.com/api/v1/services/audio/tts/general';
  
  final SettingsService _settingsService = SettingsService();
  bool _initialized = false;

  /// 初始化TTS服务
  Future<void> init() async {
    if (!_initialized) {
      await _settingsService.init();
      _initialized = true;
    }
  }

  /// 朗读文本
  Future<void> speak(String text) async {
    await init();
    
    if (!_settingsService.isConfigured) {
      print('TTS未配置');
      return;
    }

    try {
      final apiKey = _settingsService.apiKey;
      
      // 限制文本长度
      if (text.length > 200) {
        text = text.substring(0, 200);
      }

      print('TTS朗读: $text');

      // 这里应该调用百炼TTS API
      // 简化实现
      
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  void dispose() {}
}
