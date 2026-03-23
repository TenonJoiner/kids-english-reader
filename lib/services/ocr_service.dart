import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

/// OCR服务 - 使用阿里云百炼MAAS
class OCRService {
  static const String _endpoint = 'https://dashscope.aliyuncs.com/api/v1/services/vision/ocr/general';
  
  final SettingsService _settingsService = SettingsService();

  /// 初始化OCR服务
  Future<void> init() async {
    await _settingsService.init();
  }

  /// 识别图片文字
  Future<String> recognizeText(String imagePath) async {
    if (!_settingsService.isConfigured) {
      print('OCR未配置');
      return '';
    }

    try {
      final apiKey = _settingsService.apiKey;
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'qwen-vl-ocr',
          'input': {
            'image': base64Image,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['output']?['text'] as String?;
        if (text != null && text.isNotEmpty) {
          return text.length > 100 ? text.substring(0, 100) : text;
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

  /// 检查是否已配置
  bool get isConfigured => _settingsService.isConfigured;
}
