import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// 百度语音识别服务
class BaiduSpeechService {
  static const String _tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token';
  static const String _asrUrl = 'https://vop.baidu.com/server_api';
  
  final String _apiKey;
  final String _secretKey;
  String? _accessToken;
  DateTime? _tokenExpireTime;
  bool _isListening = false;

  BaiduSpeechService({
    required String apiKey,
    required String secretKey,
  })  : _apiKey = apiKey,
        _secretKey = secretKey;

  bool get isListening => _isListening;

  /// 获取Access Token
  Future<String> _getAccessToken() async {
    if (_accessToken != null && 
        _tokenExpireTime != null && 
        DateTime.now().isBefore(_tokenExpireTime!)) {
      return _accessToken!;
    }

    final response = await http.post(
      Uri.parse('$_tokenUrl?grant_type=client_credentials&client_id=$_apiKey&client_secret=$_secretKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      final expiresIn = data['expires_in'] as int;
      _tokenExpireTime = DateTime.now().add(Duration(seconds: expiresIn - 60));
      return _accessToken!;
    } else {
      throw Exception('获取Access Token失败: ${response.body}');
    }
  }

  /// 初始化
  Future<void> init() async {
    // 预获取token
    await _getAccessToken();
  }

  /// 开始录音并识别（简化版，实际应使用录音插件）
  Future<String> listen() async {
    _isListening = true;
    
    try {
      // 注意：这里需要一个录音插件来实际录音
      // 简化实现，返回空字符串
      // 实际应该：
      // 1. 使用 record 或 flutter_sound 插件录音
      // 2. 将录音文件转为base64
      // 3. 调用百度ASR API
      
      await Future.delayed(const Duration(seconds: 3)); // 模拟录音时间
      
      _isListening = false;
      return ''; // 实际返回识别结果
    } catch (e) {
      _isListening = false;
      print('语音识别错误: $e');
      return '';
    }
  }

  /// 识别音频文件
  Future<String> recognizeAudioFile(String audioPath) async {
    try {
      final token = await _getAccessToken();
      final audioBytes = await File(audioPath).readAsBytes();
      final base64Audio = base64Encode(audioBytes);

      final response = await http.post(
        Uri.parse(_asrUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'format': 'pcm',
          'rate': 16000,
          'channel': 1,
          'cuid': 'kids-english-reader',
          'token': token,
          'speech': base64Audio,
          'len': audioBytes.length,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['err_no'] == 0) {
          final result = data['result'] as List<dynamic>?;
          if (result != null && result.isNotEmpty) {
            return result[0] as String;
          }
        }
        print('ASR错误: ${data['err_msg']}');
        return '';
      } else {
        print('ASR请求失败: ${response.body}');
        return '';
      }
    } catch (e) {
      print('ASR Error: $e');
      return '';
    }
  }
}

/// 讯飞语音识别服务（备用）
class XunfeiSpeechService {
  final String _appId;
  final String _apiKey;
  final String _apiSecret;

  XunfeiSpeechService({
    required String appId,
    required String apiKey,
    required String apiSecret,
  })  : _appId = appId,
        _apiKey = apiKey,
        _apiSecret = apiSecret;

  // 讯飞语音识别实现...
}
