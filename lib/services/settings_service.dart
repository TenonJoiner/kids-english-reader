import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 设置服务 - 管理用户配置的百炼API Key
class SettingsService {
  static const String _keyApiKey = 'bailian_api_key';
  static const String _keyIsFirstRun = 'is_first_run';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 检查是否是首次运行
  bool get isFirstRun => _prefs?.getBool(_keyIsFirstRun) ?? true;

  /// 标记已完成首次设置
  Future<void> setFirstRunComplete() async {
    await _prefs?.setBool(_keyIsFirstRun, false);
  }

  /// 获取API Key
  String? get apiKey => _prefs?.getString(_keyApiKey);

  /// 设置API Key
  Future<void> setApiKey(String value) async {
    await _prefs?.setString(_keyApiKey, value);
  }

  /// 检查是否已配置
  bool get isConfigured {
    final key = apiKey;
    return key != null && key.isNotEmpty;
  }

  /// 清除所有设置
  Future<void> clear() async {
    await _prefs?.remove(_keyApiKey);
    await _prefs?.remove(_keyIsFirstRun);
  }
}
