import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

/// OCR服务 - 使用阿里云百炼MAAS
class OCRService {
  static const String _endpoint = 'https://dashscope.aliyuncs.com/api/v1/services/vision/ocr/general';
  
  final SettingsService _settingsService = SettingsService();
  bool _initialized = false;

  /// 初始化OCR服务
  Future<void> init() async {
    if (!_initialized) {
      await _settingsService.init();
      _initialized = true;
    }
  }

  /// 识别图片文字
  Future<String> recognizeText(String imagePath) async {
    await init(); // 确保已初始化
    
    if (!_settingsService.isConfigured) {
      print('OCR未配置：API Key为空');
      return '';
    }

    try {
      final apiKey = _settingsService.apiKey;
      print('开始OCR识别，图片路径: $imagePath');
      
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);
      print('图片已转为base64，大小: ${base64Image.length}');

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

      print('OCR响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['output']?['text'] as String?;
        print('OCR识别结果: $text');
        if (text != null && text.isNotEmpty) {
          return text.length > 100 ? text.substring(0, 100) : text;
        }
        return '';
      } else {
        print('OCR请求失败: ${response.statusCode} - ${response.body}');
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
