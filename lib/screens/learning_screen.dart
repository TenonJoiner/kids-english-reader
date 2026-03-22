import 'dart:io';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/speech_service.dart';
import 'home_screen.dart';

class LearningScreen extends StatefulWidget {
  final String imagePath;
  final String recognizedText;

  const LearningScreen({
    super.key,
    required this.imagePath,
    required this.recognizedText,
  });

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final TTSService _ttsService = TTSService();
  final SpeechService _speechService = SpeechService();
  
  int _currentStep = 0; // 0:听, 1:说, 2:读
  bool _isListening = false;
  String _spokenText = '';
  int _score = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _ttsService.init();
    await _speechService.init();
    
    // 自动开始第一步：听
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakText();
    });
  }

  void _speakText() {
    _ttsService.speak(widget.recognizedText);
  }

  void _speakWord(String word) {
    _ttsService.speak(word);
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);
    
    final result = await _speechService.listen();
    
    setState(() {
      _isListening = false;
      _spokenText = result;
    });

    if (result.isNotEmpty) {
      _evaluateSpeech();
    }
  }

  void _evaluateSpeech() {
    // 简单的相似度计算
    final target = widget.recognizedText.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
    final spoken = _spokenText.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
    
    // 计算匹配度
    final targetWords = target.split(' ').where((w) => w.isNotEmpty).toList();
    final spokenWords = spoken.split(' ').where((w) => w.isNotEmpty).toList();
    
    int matchedWords = 0;
    for (final word in spokenWords) {
      if (targetWords.contains(word)) {
        matchedWords++;
      }
    }
    
    final accuracy = targetWords.isEmpty 
        ? 0 
        : (matchedWords / targetWords.length * 100).round();
    
    setState(() {
      _score = accuracy.clamp(0, 100);
      _showResult = true;
    });

    // 语音反馈
    if (_score >= 80) {
      _ttsService.speak('太棒了！发音很标准');
    } else if (_score >= 60) {
      _ttsService.speak('不错，再练习一下会更好');
    } else {
      _ttsService.speak('我们再听一遍，然后跟着读');
    }
  }

  void _nextStep() {
    setState(() {
      _showResult = false;
      _spokenText = '';
      _score = 0;
      
      if (_currentStep < 2) {
        _currentStep++;
        if (_currentStep == 1) {
          _ttsService.speak('现在轮到你了，按住按钮跟我读');
        } else if (_currentStep == 2) {
          _ttsService.speak('很好！现在你自己读一遍');
        }
      } else {
        // 完成
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E7),
        title: const Center(
          child: Text(
            '🎉 太棒了！',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '你完成了这本绘本！',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '获得 5 颗星星！',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF5D4037),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                '再读一本',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
    
    _ttsService.speak('恭喜你完成了一本绘本！获得五颗星星！');
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['听', '说', '读'];
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: Column(
          children: [
            // 进度指示器
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: index == _currentStep
                          ? Colors.orange
                          : index < _currentStep
                              ? Colors.green
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        steps[index],
                        style: TextStyle(
                          color: index <= _currentStep ? Colors.white : Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // 图片显示
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
            // 文字显示（可点击单词）
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: widget.recognizedText
                        .split(' ')
                        .where((w) => w.trim().isNotEmpty)
                        .map((word) => GestureDetector(
                          onTap: () => _speakWord(word),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              word,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                          ),
                        ))
                        .toList(),
                  ),
                ),
              ),
            ),
            
            // 操作区域
            Expanded(
              flex: 1,
              child: _buildActionArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    if (_currentStep == 0) {
      // 听：播放按钮
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _speakText,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.volume_up,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            '点击听发音',
            style: TextStyle(fontSize: 18, color: Color(0xFF8D6E63)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              '下一步：跟我读',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      );
    } else if (_currentStep == 1 || _currentStep == 2) {
      // 说/读：录音按钮
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_showResult) ...[
            // 显示结果
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _score >= 80 ? Icons.check_circle : Icons.refresh,
                  color: _score >= 80 ? Colors.green : Colors.orange,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  '$_score分',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _score >= 80 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_score >= 60)
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  _currentStep == 1 ? '下一步：自己读' : '完成！',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showResult = false;
                    _spokenText = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  '再试一次',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
          ] else ...[
            // 录音按钮
            GestureDetector(
              onTapDown: (_) => _startListening(),
              onTapUp: (_) {},
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.orange,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.orange)
                          .withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _isListening ? '正在听...' : '按住说话',
              style: const TextStyle(fontSize: 18, color: Color(0xFF8D6E63)),
            ),
          ],
        ],
      );
    }
    
    return const SizedBox.shrink();
  }
}