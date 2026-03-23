import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'settings_service.dart';

/// 语音识别服务 - 使用阿里云百炼MAAS
class SpeechService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final SettingsService _settingsService = SettingsService();
  bool _initialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;

  /// 初始化语音识别服务
  Future<void> init() async {
    if (!_initialized) {
      await _settingsService.init();
      
      // 检查录音权限
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        print('录音权限未授予');
      }
      
      _initialized = true;
    }
  }

  /// 开始录音
  Future<void> startRecording() async {
    await init();
    
    if (_isRecording) return;
    
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = path;
      
      // 配置录音
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 16000,
      );
      
      await _audioRecorder.start(config, path: path);
      
      _isRecording = true;
      print('开始录音: $path');
    } catch (e) {
      print('开始录音错误: $e');
    }
  }

  /// 停止录音并返回文件路径
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      print('停止录音: $path');
      return path ?? _currentRecordingPath;
    } catch (e) {
      print('停止录音错误: $e');
      _isRecording = false;
      return _currentRecordingPath;
    }
  }

  /// 录音并识别（完整流程）
  Future<String> listen({required Duration duration}) async {
    await init();
    
    if (!_settingsService.isConfigured) {
      print('语音识别未配置');
      return '';
    }

    try {
      // 开始录音
      await startRecording();
      
      // 等待指定时间
      await Future.delayed(duration);
      
      // 停止录音
      final audioPath = await stopRecording();
      
      if (audioPath == null) {
        print('录音失败');
        return '';
      }
      
      // 识别音频
      final text = await recognizeAudioFile(audioPath);
      
      // 删除临时文件
      try {
        await File(audioPath).delete();
      } catch (e) {
        print('删除临时文件失败: $e');
      }
      
      return text;
    } catch (e) {
      print('录音识别错误: $e');
      return '';
    }
  }

  /// 识别音频文件
  Future<String> recognizeAudioFile(String audioPath) async {
    try {
      final apiKey = _settingsService.apiKey;
      
      // 读取音频文件
      final audioBytes = await File(audioPath).readAsBytes();
      final base64Audio = base64Encode(audioBytes);
      
      print('识别音频文件: $audioPath, 大小: ${audioBytes.length} bytes');

      // 调用百炼ASR API
      final response = await http.post(
        Uri.parse('https://dashscope.aliyuncs.com/api/v1/services/audio/asr/general'),
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
        print('识别结果: $text');
        return text ?? '';
      } else {
        print('ASR请求失败: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      print('ASR Error: $e');
      return '';
    }
  }

  bool get isRecording => _isRecording;

  void dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
    // AudioRecorder不需要dispose
  }
}
