import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/speech_service.dart';
import '../services/pronunciation_service.dart';
import 'home_screen.dart';

/// AI老师教学模式
/// 基于TPR+自然拼读的科学教学方法
class LearningScreen extends StatefulWidget {
  final String imagePath;
  final String bookText;

  const LearningScreen({
    super.key,
    required this.imagePath,
    required this.bookText,
  });

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final TTSService _ttsService = TTSService();
  final SpeechService _speechService = SpeechService();
  final PronunciationService _pronunciationService = PronunciationService();

  // 教学状态
  TeachingPhase _currentPhase = TeachingPhase.preReading;
  int _currentSentenceIndex = 0;
  List<String> _sentences = [];
  Map<int, double> _sentenceScores = {};
  bool _isListening = false;
  bool _isProcessing = false;

  // 学习统计
  int _stars = 0;
  List<String> _newWords = [];

  @override
  void initState() {
    super.initState();
    _initLearning();
  }

  Future<void> _initLearning() async {
    // 初始化服务
    await _ttsService.init();
    await _speechService.init();
    await _pronunciationService.init();

    // 分割句子
    _sentences = _splitIntoSentences(widget.bookText);
    
    // 开始教学
    _startTeaching();
  }

  List<String> _splitIntoSentences(String text) {
    // 按句子分割（考虑标点符号）
    final sentences = text
        .replaceAll('。', '.')
        .replaceAll('！', '!')
        .replaceAll('？', '?')
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    // 如果句子太长，再按逗号分割
    final result = <String>[];
    for (final sentence in sentences) {
      if (sentence.length > 50) {
        final parts = sentence.split(',');
        result.addAll(parts.map((p) => p.trim()).where((p) => p.isNotEmpty));
      } else {
        result.add(sentence);
      }
    }
    
    return result.take(10).toList(); // 最多10句
  }

  Future<void> _startTeaching() async {
    // 阶段1：预读 - 建立兴趣
    setState(() => _currentPhase = TeachingPhase.preReading);
    await _ttsService.speak('你好！我是你的英语老师。今天我们学习这本绘本。准备好了吗？我们开始吧！');
    await Future.delayed(const Duration(seconds: 3));

    // 阶段2：示范读
    setState(() => _currentPhase = TeachingPhase.modelReading);
    await _ttsService.speak('先听老师读一遍：');
    await Future.delayed(const Duration(seconds: 1));
    
    for (int i = 0; i < _sentences.length; i++) {
      await _ttsService.speak(_sentences[i]);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 阶段3：逐句跟读教学
    setState(() => _currentPhase = TeachingPhase.choralReading);
    await _ttsService.speak('现在，我们一句一句来学习。跟我读：');
    await Future.delayed(const Duration(seconds: 1));

    await _teachSentenceBySentence();
  }

  Future<void> _teachSentenceBySentence() async {
    for (int i = 0; i < _sentences.length; i++) {
      setState(() => _currentSentenceIndex = i);
      final sentence = _sentences[i];
      
      // AI读
      await _ttsService.speak(sentence);
      await Future.delayed(const Duration(milliseconds: 500));

      // 提示学生跟读
      await _ttsService.speak('轮到你了！');
      
      // 录音并评估
      final score = await _recordAndEvaluate(sentence);
      _sentenceScores[i] = score;

      // 根据分数决定下一步
      if (score >= 85) {
        // 优秀，进入下一句
        await _ttsService.speak('非常好！发音很标准。');
      } else if (score >= 70) {
        // 良好，再读一遍
        await _ttsService.speak('不错，我们再读一遍巩固一下。');
        await _ttsService.speak(sentence);
        await Future.delayed(const Duration(milliseconds: 300));
        await _ttsService.speak('轮到你了！');
        await _recordAndEvaluate(sentence);
      } else {
        // 需要拆解教学
        await _ttsService.speak('这个句子有点难，我们慢慢学。');
        await _teachWordByWord(sentence);
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 阶段4：尝试读（加长）
    await _guidedReading();
  }

  Future<double> _recordAndEvaluate(String expectedText) async {
    setState(() => _isListening = true);
    
    // 录音3秒
    final spokenText = await _speechService.listen(duration: const Duration(seconds: 3));
    
    setState(() => _isListening = false);
    
    // 评估发音
    final score = _pronunciationService.evaluate(expectedText, spokenText);
    return score;
  }

  Future<void> _teachWordByWord(String sentence) async {
    final words = sentence.split(' ');
    
    await _ttsService.speak('我们一个单词一个单词来学：');
    
    for (final word in words) {
      // 教单词
      await _ttsService.speak(word);
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 拆解音素（简单版）
      if (word.length <= 5) {
        final phonemes = _pronunciationService.getPhonemes(word);
        if (phonemes.isNotEmpty) {
          await _ttsService.speak('注意发音：$phonemes');
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    // 再读完整句
    await _ttsService.speak('现在连起来读：');
    await _ttsService.speak(sentence);
    await Future.delayed(const Duration(milliseconds: 300));
    await _ttsService.speak('轮到你了！');
    await _recordAndEvaluate(sentence);
  }

  Future<void> _guidedReading() async {
    setState(() => _currentPhase = TeachingPhase.guidedReading);
    await _ttsService.speak('很好！现在我们读长一点的句子。');
    
    // 2句一起读
    for (int i = 0; i < _sentences.length - 1; i += 2) {
      final combined = '${_sentences[i]} ${_sentences[i + 1]}';
      await _ttsService.speak(combined);
      await Future.delayed(const Duration(milliseconds: 500));
      await _ttsService.speak('轮到你了！');
      await _recordAndEvaluate(combined);
    }

    // 阶段5：独立读
    await _independentReading();
  }

  Future<void> _independentReading() async {
    setState(() => _currentPhase = TeachingPhase.independentReading);
    await _ttsService.speak('最后，你自己完整读一遍这本绘本。开始！');
    
    // 录音完整朗读
    setState(() => _isListening = true);
    final fullText = _sentences.join(' ');
    final spokenText = await _speechService.listen(duration: const Duration(seconds: 10));
    setState(() => _isListening = false);
    
    // 综合评估
    final overallScore = _pronunciationService.evaluate(fullText, spokenText);
    
    // 计算星星
    if (overallScore >= 90) {
      _stars = 5;
    } else if (overallScore >= 80) {
      _stars = 4;
    } else if (overallScore >= 70) {
      _stars = 3;
    } else if (overallScore >= 60) {
      _stars = 2;
    } else {
      _stars = 1;
    }

    // 结束语
    await _giveFinalFeedback(overallScore);
  }

  Future<void> _giveFinalFeedback(double score) async {
    if (score >= 85) {
      await _ttsService.speak('太棒了！你的发音非常好！获得$_stars颗星！明天我们继续学习下一本。');
    } else if (score >= 70) {
      await _ttsService.speak('很好！获得$_stars颗星！我们再练习一遍，巩固一下。');
      // 可以选择重学
      await _startTeaching();
      return;
    } else {
      await _ttsService.speak('没关系，学习需要慢慢来。我们再学一遍，这次慢一点。');
      await _startTeaching();
      return;
    }

    // 显示完成页面
    setState(() => _currentPhase = TeachingPhase.completed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: Column(
          children: [
            // 绘本图片
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 当前句子显示
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getPhaseText(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_currentSentenceIndex < _sentences.length)
                      Text(
                        _sentences[_currentSentenceIndex],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),

            // 状态指示器
            Expanded(
              flex: 1,
              child: Center(
                child: _buildStatusIndicator(),
              ),
            ),

            // 完成按钮
            if (_currentPhase == TeachingPhase.completed)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '完成学习',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPhaseText() {
    switch (_currentPhase) {
      case TeachingPhase.preReading:
        return '准备开始';
      case TeachingPhase.modelReading:
        return '听老师读';
      case TeachingPhase.choralReading:
        return '跟我读 (${_currentSentenceIndex + 1}/${_sentences.length})';
      case TeachingPhase.guidedReading:
        return '尝试读';
      case TeachingPhase.independentReading:
        return '自己读';
      case TeachingPhase.completed:
        return '完成！获得 $_stars ⭐';
    }
  }

  Widget _buildStatusIndicator() {
    if (_isListening) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.mic,
              size: 50,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '正在听...',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      );
    }

    if (_isProcessing) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text(
            '思考中...',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange.withOpacity(0.2),
      ),
      child: const Icon(
        Icons.volume_up,
        size: 40,
        color: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _speechService.dispose();
    super.dispose();
  }
}

enum TeachingPhase {
  preReading,      // 预读
  modelReading,    // 示范读
  choralReading,   // 逐句跟读
  guidedReading,   // 尝试读
  independentReading, // 独立读
  completed,       // 完成
}
