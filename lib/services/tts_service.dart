import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'settings_service.dart';

/// TTS服务 - 使用阿里云百炼MAAS
class TTSService {
  static const String _endpoint = 'https://dashscope.aliyuncs.com/api/v1/services/audio/tts/general';
  
  final SettingsService _settingsService = SettingsService();

  /// 初始化TTS服务
  Future<void> init() async {
    await _settingsService.init();
  }

  /// 朗读文本
  Future<void> speak(String text) async {
    if (!_settingsService.isConfigured) {
      print('TTS未配置');
      return;
    }

    try {
      final apiKey = _settingsService.apiKey;
      
      if (text.length > 100) {
        text = text.substring(0, 100);
      }

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'speech-synthesis',
          'input': {
            'text': text,
          },
          'parameters': {
            'voice': 'zhixiaobai',
            'format': 'mp3',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioBase64 = data['output']?['audio'] as String?;
        if (audioBase64 != null) {
          // 保存并播放音频
          final dir = await getTemporaryDirectory();
          final filePath = '${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
          final file = File(filePath);
          await file.writeAsBytes(base64Decode(audioBase64));
          print('TTS音频已生成: $filePath');
          // 实际应该播放音频
        }
      } else {
        print('TTS请求失败: ${response.body}');
      }
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  /// 检查是否已配置
  bool get isConfigured => _settingsService.isConfigured;
}
