import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// 百度OCR服务
class BaiduOCRService {
  static const String _tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token';
  static const String _ocrUrl = 'https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic';
  
  final String _apiKey;
  final String _secretKey;
  String? _accessToken;
  DateTime? _tokenExpireTime;

  BaiduOCRService({
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

  /// 识别图片文字
  Future<String> recognizeText(String imagePath) async {
    try {
      final token = await _getAccessToken();
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$_ocrUrl?access_token=$token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'image': base64Image,
          'language_type': 'ENG', // 英文识别
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final wordsResult = data['words_result'] as List<dynamic>?;
        
        if (wordsResult != null && wordsResult.isNotEmpty) {
          final words = wordsResult.map((item) => item['words'] as String).join(' ');
          // 限制长度
          return words.length > 100 ? words.substring(0, 100) : words;
        }
        return '';
      } else {
        print('OCR请求失败: ${response.body}');
        return '';
      }
    } catch (e) {
      print('OCR Error: $e');
      return '';
    }
  }
}

/// 腾讯OCR服务（备用）
class TencentOCRService {
  final String _secretId;
  final String _secretKey;
  static const String _endpoint = 'ocr.tencentcloudapi.com';

  TencentOCRService({
    required String secretId,
    required String secretKey,
  })  : _secretId = secretId,
        _secretKey = secretKey;

  Future<String> recognizeText(String imagePath) async {
    // 腾讯OCR实现...
    // 作为备用方案
    return '';
  }
}
