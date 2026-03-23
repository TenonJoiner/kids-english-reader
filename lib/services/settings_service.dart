import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 设置服务 - 管理用户配置的阿里云密钥
class SettingsService {
  static const String _keyAccessKeyId = 'alibaba_access_key_id';
  static const String _keyAccessKeySecret = 'alibaba_access_key_secret';
  static const String _keyAppKey = 'alibaba_app_key';
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

  /// 获取AccessKey ID
  String? get accessKeyId => _prefs?.getString(_keyAccessKeyId);

  /// 设置AccessKey ID
  Future<void> setAccessKeyId(String value) async {
    await _prefs?.setString(_keyAccessKeyId, value);
  }

  /// 获取AccessKey Secret
  String? get accessKeySecret => _prefs?.getString(_keyAccessKeySecret);

  /// 设置AccessKey Secret
  Future<void> setAccessKeySecret(String value) async {
    await _prefs?.setString(_keyAccessKeySecret, value);
  }

  /// 获取AppKey
  String? get appKey => _prefs?.getString(_keyAppKey);

  /// 设置AppKey
  Future<void> setAppKey(String value) async {
    await _prefs?.setString(_keyAppKey, value);
  }

  /// 检查是否已配置
  bool get isConfigured {
    return accessKeyId != null && 
           accessKeyId!.isNotEmpty &&
           accessKeySecret != null && 
           accessKeySecret!.isNotEmpty &&
           appKey != null && 
           appKey!.isNotEmpty;
  }

  /// 清除所有设置
  Future<void> clear() async {
    await _prefs?.remove(_keyAccessKeyId);
    await _prefs?.remove(_keyAccessKeySecret);
    await _prefs?.remove(_keyAppKey);
    await _prefs?.remove(_keyIsFirstRun);
  }
}
