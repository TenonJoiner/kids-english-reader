import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    _isInitialized = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
  }

  Future<String> listen() async {
    if (!_isInitialized) await init();
    
    if (!_isInitialized) {
      return '';
    }

    String recognizedText = '';
    
    await _speech.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      localeId: 'en_US',
    );

    // 等待识别完成
    await Future.delayed(const Duration(seconds: 5));
    
    await _speech.stop();
    
    return recognizedText;
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}