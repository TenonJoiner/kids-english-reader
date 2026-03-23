import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// 阿里云OCR服务
class AliyunOCRService {
  static const String _endpoint = 'ocr.aliyuncs.com';
  
  final String _accessKeyId;
  final String _accessKeySecret;

  AliyunOCRService({
    required String accessKeyId,
    required String accessKeySecret,
  })  : _accessKeyId = accessKeyId,
        _accessKeySecret = accessKeySecret;

  /// 生成签名
  String _generateSignature(String stringToSign) {
    final key = utf8.encode(_accessKeySecret);
    final bytes = utf8.encode(stringToSign);
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// 识别图片文字
  Future<String> recognizeText(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // 构建请求参数
      final params = {
        'Action': 'RecognizeGeneral',
        'Version': '2021-07-07',
        'Format': 'JSON',
        'AccessKeyId': _accessKeyId,
        'SignatureMethod': 'HMAC-SHA1',
        'Timestamp': _getTimestamp(),
        'SignatureVersion': '1.0',
        'SignatureNonce': DateTime.now().millisecondsSinceEpoch.toString(),
        'ImageURL': '', // 使用Base64图片
        'ImageBase64': base64Image,
      };

      // 计算签名
      final sortedParams = Map.fromEntries(
        params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      
      final canonicalQueryString = sortedParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final stringToSign = 'POST&${Uri.encodeComponent('/')}&${Uri.encodeComponent(canonicalQueryString)}';
      final signature = _generateSignature(stringToSign);

      // 发送请求
      final response = await http.post(
        Uri.parse('https://$_endpoint/?Signature=$signature'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: canonicalQueryString,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['Content'] as String?;
        if (content != null && content.isNotEmpty) {
          return content.length > 100 ? content.substring(0, 100) : content;
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

  String _getTimestamp() {
    final now = DateTime.now().toUtc();
    return now.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
  }
}
