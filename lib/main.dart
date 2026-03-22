import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KidsEnglishReaderApp());
}

class KidsEnglishReaderApp extends StatelessWidget {
  const KidsEnglishReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '绘本阅读',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'PingFang SC',
      ),
      home: const HomeScreen(),
    );
  }
}