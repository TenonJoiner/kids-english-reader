import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// 百度TTS服务
class BaiduTTSService {
  static const String _tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token';
  static const String _ttsUrl = 'https://tsn.baidu.com/text2audio';
  
  final String _apiKey;
  final String _secretKey;
  String? _accessToken;
  DateTime? _tokenExpireTime;

  BaiduTTSService({
    required String apiKey,
    required String secretKey,
  })  : _apiKey = apiKey,
        _secretKey = secretKey;

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

  /// 合成语音
  Future<String?> synthesize(String text) async {
    try {
      final token = await _getAccessToken();
      
      // 限制文本长度
      if (text.length > 100) {
        text = text.substring(0, 100);
      }

      final response = await http.post(
        Uri.parse('$_ttsUrl'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'tex': text,
          'tok': token,
          'cuid': 'kids-english-reader',
          'ctp': '1',
          'lan': 'zh', // 中文
          'spd': '4',  // 语速 0-15
          'pit': '5',  // 音调 0-15
          'vol': '10', // 音量 0-15
          'per': '0',  // 发音人 0:女声 1:男声
        },
      );

      if (response.statusCode == 200) {
        // 检查返回的是音频还是错误信息
        final contentType = response.headers['content-type'];
        if (contentType?.contains('audio') == true) {
          // 保存音频文件
          final dir = await getTemporaryDirectory();
          final filePath = '${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          return filePath;
        } else {
          // 错误信息
          print('TTS错误: ${response.body}');
          return null;
        }
      } else {
        print('TTS请求失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('TTS Error: $e');
      return null;
    }
  }
}

/// 科大讯飞TTS服务（备用）
class XunfeiTTSService {
  final String _appId;
  final String _apiKey;
  final String _apiSecret;

  XunfeiTTSService({
    required String appId,
    required String apiKey,
    required String apiSecret,
  })  : _appId = appId,
        _apiKey = apiKey,
        _apiSecret = apiSecret;

  // 讯飞TTS实现...
}
