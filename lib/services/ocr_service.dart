import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // 过滤和清理文本
      String text = recognizedText.text;
      
      // 移除多余空格和换行
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      // 如果识别结果太长，只取前100个字符
      if (text.length > 100) {
        text = text.substring(0, 100);
      }
      
      return text;
    } catch (e) {
      print('OCR Error: $e');
      return '';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}