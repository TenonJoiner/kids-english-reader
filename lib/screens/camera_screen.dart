import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ocr_service.dart';
import '../services/tts_service.dart';
import 'learning_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final TTSService _ttsService = TTSService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // 自动打开相机
      _takePhoto();
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() => _isProcessing = true);
        
        // 识别文字
        final text = await _ocrService.recognizeText(photo.path);
        
        setState(() => _isProcessing = false);
        
        if (text.isNotEmpty) {
          // 进入学习界面
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LearningScreen(
                imagePath: photo.path,
                recognizedText: text,
              ),
            ),
          );
        } else {
          _ttsService.speak('没有识别到文字，请再试一次');
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _ttsService.speak('拍照出错了，请重试');
      Navigator.pop(context);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isProcessing = true);
        
        final text = await _ocrService.recognizeText(image.path);
        
        setState(() => _isProcessing = false);
        
        if (text.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LearningScreen(
                imagePath: image.path,
                recognizedText: text,
              ),
            ),
          );
        } else {
          _ttsService.speak('没有识别到文字，请换一张图片');
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _ttsService.speak('出错了，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: Center(
          child: _isProcessing
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 6,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '正在识别文字...',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '选择图片',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // 拍照按钮
                    _buildButton(
                      icon: Icons.camera_alt,
                      label: '拍照',
                      onTap: _takePhoto,
                    ),
                    const SizedBox(height: 30),
                    // 相册按钮
                    _buildButton(
                      icon: Icons.photo_library,
                      label: '从相册选择',
                      onTap: _pickFromGallery,
                    ),
                    const SizedBox(height: 60),
                    // 返回按钮
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '返回',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}