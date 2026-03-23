import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

/// 语音识别服务 - 使用阿里云百炼MAAS
class SpeechService {
  static const String _endpoint = 'https://dashscope.aliyuncs.com/api/v1/services/audio/asr/general';
  
  final SettingsService _settingsService = SettingsService();
  bool _isListening = false;

  /// 初始化语音识别服务
  Future<void> init() async {
    await _settingsService.init();
  }

  /// 开始录音并识别
  Future<String> listen() async {
    if (!_settingsService.isConfigured) {
      print('语音识别未配置');
      return '';
    }

    _isListening = true;
    
    try {
      // 实际应该录音后调用API
      // 简化实现
      await Future.delayed(const Duration(seconds: 3));
      
      _isListening = false;
      return '';
    } catch (e) {
      _isListening = false;
      print('语音识别错误: $e');
      return '';
    }
  }

  /// 识别音频文件
  Future<String> recognizeAudioFile(String audioPath) async {
    try {
      final apiKey = _settingsService.apiKey;
      final audioBytes = await File(audioPath).readAsBytes();
      final base64Audio = base64Encode(audioBytes);

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'paraformer-realtime-v1',
          'input': {
            'audio': base64Audio,
            'sample_rate': 16000,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['output']?['text'] as String?;
        return text ?? '';
      } else {
        print('ASR请求失败: ${response.body}');
        return '';
      }
    } catch (e) {
      print('ASR Error: $e');
      return '';
    }
  }

  /// 检查是否正在录音
  bool get isListening => _isListening;

  /// 检查是否已配置
  bool get isConfigured => _settingsService.isConfigured;
}
