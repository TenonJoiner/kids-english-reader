import 'dart:math';

/// 发音评估服务
class PronunciationService {
  bool _initialized = false;

  Future<void> init() async {
    _initialized = true;
  }

  /// 评估发音（简化版）
  /// 返回0-100的分数
  double evaluate(String expected, String actual) {
    if (actual.isEmpty) return 0;
    
    final expectedWords = expected.toLowerCase().trim().split(' ');
    final actualWords = actual.toLowerCase().trim().split(' ');
    
    if (expectedWords.isEmpty) return 0;
    
    int matchedWords = 0;
    for (final actualWord in actualWords) {
      for (final expectedWord in expectedWords) {
        if (_calculateSimilarity(actualWord, expectedWord) > 0.7) {
          matchedWords++;
          break;
        }
      }
    }
    
    final score = (matchedWords / expectedWords.length * 100).clamp(0, 100);
    return score;
  }

  /// 计算字符串相似度
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;
    
    final longerLength = longer.length;
    if (longerLength == 0) return 1.0;
    
    final distance = _levenshteinDistance(longer, shorter);
    return (longerLength - distance) / longerLength;
  }

  /// 计算编辑距离
  int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    
    for (int i = 0; i <= m; i++) dp[i][0] = i;
    for (int j = 0; j <= n; j++) dp[0][j] = j;
    
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + min(
            min(dp[i - 1][j], dp[i][j - 1]),
            dp[i - 1][j - 1],
          );
        }
      }
    }
    
    return dp[m][n];
  }

  /// 获取单词的音素提示（简化版）
  String getPhonemes(String word) {
    // 简单的音素提示
    final phonemeMap = {
      'cat': 'k-æ-t',
      'dog': 'd-ɔ-g',
      'run': 'r-ʌ-n',
      'jump': 'dʒ-ʌ-m-p',
      'sleep': 's-l-i-p',
      'play': 'p-l-ei',
    };
    
    return phonemeMap[word.toLowerCase()] ?? '';
  }

  void dispose() {}
}
