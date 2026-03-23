import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'settings_service.dart';

/// TTS服务 - 使用阿里云语音合成
class TTSService {
  AliyunTTSService? _aliyunService;
  final SettingsService _settingsService = SettingsService();

  /// 初始化TTS服务
  Future<void> init() async {
    await _settingsService.init();
    
    if (_settingsService.isConfigured) {
      _aliyunService = AliyunTTSService(
        accessKeyId: _settingsService.accessKeyId!,
        accessKeySecret: _settingsService.accessKeySecret!,
        appKey: _settingsService.appKey!,
      );
    }
  }

  /// 朗读文本
  Future<void> speak(String text) async {
    if (_aliyunService == null) {
      print('TTS未配置');
      return;
    }

    try {
      final audioPath = await _aliyunService!.synthesize(text);
      if (audioPath != null) {
        // 播放音频（需要audioplayers插件）
        // 简化实现，实际应该使用AudioPlayer播放
        print('TTS音频已生成: $audioPath');
      }
    } catch (e) {
      print('TTS播放失败: $e');
    }
  }

  /// 检查是否已配置
  bool get isConfigured => _aliyunService != null;
}

/// 阿里云TTS服务
class AliyunTTSService {
  static const String _endpoint = 'nls-meta.cn-shanghai.aliyuncs.com';
  static const String _ttsEndpoint = 'nls-gateway-cn-shanghai.aliyuncs.com';
  
  final String _accessKeyId;
  final String _accessKeySecret;
  final String _appKey;
  String? _token;
  DateTime? _tokenExpireTime;

  AliyunTTSService({
    required String accessKeyId,
    required String accessKeySecret,
    required String appKey,
  })  : _accessKeyId = accessKeyId,
        _accessKeySecret = accessKeySecret,
        _appKey = appKey;

  /// 获取Token
  Future<String> _getToken() async {
    if (_token != null && _tokenExpireTime != null && 
        DateTime.now().isBefore(_tokenExpireTime!)) {
      return _token!;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final params = {
        'AccessKeyId': _accessKeyId,
        'Action': 'CreateToken',
        'Version': '2019-02-28',
        'Timestamp': timestamp.toString(),
        'SignatureMethod': 'HMAC-SHA1',
        'SignatureVersion': '1.0',
        'SignatureNonce': timestamp.toString(),
        'Format': 'JSON',
      };

      final signature = _generateSignature(params);
      params['Signature'] = signature;

      final response = await http.post(
        Uri.parse('https://$_endpoint/'),
        body: params,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokenData = data['Token'];
        _token = tokenData['Id'];
        final expireTime = tokenData['ExpireTime'];
        _tokenExpireTime = DateTime.fromMillisecondsSinceEpoch(expireTime * 1000 - 60000);
        return _token!;
      } else {
        throw Exception('获取Token失败: ${response.body}');
      }
    } catch (e) {
      print('Token Error: $e');
      rethrow;
    }
  }

  /// 生成签名
  String _generateSignature(Map<String, String> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    
    final canonicalQueryString = sortedParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final stringToSign = 'POST&${Uri.encodeComponent('/')}&${Uri.encodeComponent(canonicalQueryString)}';
    final key = utf8.encode('$_accessKeySecret&');
    final bytes = utf8.encode(stringToSign);
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// 合成语音
  Future<String?> synthesize(String text) async {
    try {
      final token = await _getToken();
      
      if (text.length > 100) {
        text = text.substring(0, 100);
      }

      // 构建TTS请求
      final request = {
        'appkey': _appKey,
        'token': token,
        'text': text,
        'format': 'mp3',
        'sample_rate': 16000,
        'voice': 'xiaoyun', // 发音人：小云
        'volume': 50,
        'speech_rate': 0,
        'pitch_rate': 0,
      };

      final response = await http.post(
        Uri.parse('https://$_ttsEndpoint/stream/v1/tts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        // 保存音频文件
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        print('TTS请求失败: ${response.body}');
        return null;
      }
    } catch (e) {
      print('TTS Error: $e');
      return null;
    }
  }
}
