import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'settings_service.dart';

/// TTS服务 - 使用阿里云百炼MAAS
class TTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SettingsService _settingsService = SettingsService();
  bool _initialized = false;
  bool _isPlaying = false;

  /// 初始化TTS服务
  Future<void> init() async {
    if (!_initialized) {
      await _settingsService.init();
      
      // 监听播放状态
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
      
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
      // 限制文本长度
      if (text.length > 200) {
        text = text.substring(0, 200);
      }

      print('TTS朗读: $text');

      // 调用百炼TTS API
      final apiKey = _settingsService.apiKey;
      
      final response = await http.post(
        Uri.parse('https://dashscope.aliyuncs.com/api/v1/services/audio/tts/general'),
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
            'sample_rate': 16000,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioBase64 = data['output']?['audio'] as String?;
        
        if (audioBase64 != null) {
          // 保存音频文件
          final dir = await getTemporaryDirectory();
          final filePath = '${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
          final file = File(filePath);
          await file.writeAsBytes(base64Decode(audioBase64));
          
          // 播放音频
          _isPlaying = true;
          await _audioPlayer.play(DeviceFileSource(filePath));
          
          // 等待播放完成
          await _audioPlayer.onPlayerComplete.first;
          _isPlaying = false;
          
          // 删除临时文件
          try {
            await file.delete();
          } catch (e) {
            print('删除临时文件失败: $e');
          }
        }
      } else {
        print('TTS请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('TTS Error: $e');
      _isPlaying = false;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;

  void dispose() async {
    await _audioPlayer.dispose();
  }
}
