import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ocr_service.dart';
import '../services/tts_service.dart';
import '../services/speech_service.dart';
import 'learning_screen.dart';

/// 相机页面 - 拍照识别绘本
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndOpenCamera();
  }

  Future<void> _checkPermissionAndOpenCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
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
        
        // OCR识别文字
        final text = await _ocrService.recognizeText(photo.path);
        
        setState(() => _isProcessing = false);
        
        if (text.isNotEmpty) {
          // 进入AI老师教学页面
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LearningScreen(
                imagePath: photo.path,
                bookText: text,
              ),
            ),
          );
        } else {
          _showError('没有识别到文字，请再试一次');
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('拍照出错了，请重试');
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
                bookText: text,
              ),
            ),
          );
        } else {
          _showError('没有识别到文字，请换一张图片');
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('出错了，请重试');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context);
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
                      '正在识别绘本...',
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
                      '选择绘本图片',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildButton(
                      icon: Icons.camera_alt,
                      label: '拍照',
                      onTap: _takePhoto,
                    ),
                    const SizedBox(height: 30),
                    _buildButton(
                      icon: Icons.photo_library,
                      label: '从相册选择',
                      onTap: _pickFromGallery,
                    ),
                    const SizedBox(height: 60),
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
