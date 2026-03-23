import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// 阿里云语音识别服务
class AliyunSpeechService {
  static const String _endpoint = 'nls-meta.cn-shanghai.aliyuncs.com';
  static const String _asrEndpoint = 'nls-gateway-cn-shanghai.aliyuncs.com/ws/v1';
  
  final String _accessKeyId;
  final String _accessKeySecret;
  final String _appKey;
  String? _token;
  DateTime? _tokenExpireTime;
  bool _isListening = false;

  AliyunSpeechService({
    required String accessKeyId,
    required String accessKeySecret,
    required String appKey,
  })  : _accessKeyId = accessKeyId,
        _accessKeySecret = accessKeySecret,
        _appKey = appKey;

  bool get isListening => _isListening;

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

  /// 初始化
  Future<void> init() async {
    await _getToken();
  }

  /// 开始录音并识别（简化版）
  Future<String> listen() async {
    _isListening = true;
    
    try {
      // 实际应该使用录音插件录音，然后调用识别API
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
      final token = await _getToken();
      final audioBytes = await File(audioPath).readAsBytes();
      final base64Audio = base64Encode(audioBytes);

      // 构建识别请求
      final request = {
        'appkey': _appKey,
        'token': token,
        'format': 'pcm',
        'sample_rate': 16000,
        'enable_intermediate_result': false,
        'enable_punctuation_prediction': true,
        'enable_inverse_text_normalization': true,
      };

      // WebSocket连接进行实时识别
      // 简化实现，实际需要WebSocket连接
      
      return '';
    } catch (e) {
      print('ASR Error: $e');
      return '';
    }
  }
}
