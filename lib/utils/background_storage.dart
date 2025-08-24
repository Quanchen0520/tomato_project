import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundStorage {
  static const String _colorKey = 'bgColor';
  static const String _assetKey = 'bgAsset';
  static const String _fileKey = 'bgImage';

  /// 儲存顏色
  static Future<void> saveColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
    await prefs.remove(_assetKey);
    await prefs.remove(_fileKey);
  }

  /// 儲存 assets 圖片
  static Future<void> saveAsset(String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_assetKey, assetPath);
    await prefs.remove(_colorKey);
    await prefs.remove(_fileKey);
  }

  /// 儲存檔案圖片
  static Future<void> saveFile(File file) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fileKey, file.path);
    await prefs.remove(_colorKey);
    await prefs.remove(_assetKey);
  }

  /// 讀取背景設定
  static Future<Map<String, dynamic>> loadBackground() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_colorKey)) {
      return {'color': Color(prefs.getInt(_colorKey)!)};
    } else if (prefs.containsKey(_assetKey)) {
      return {'asset': prefs.getString(_assetKey)};
    } else if (prefs.containsKey(_fileKey)) {
      return {'file': File(prefs.getString(_fileKey)!)};
    }
    return {};
  }

  /// 清除背景設定
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_colorKey);
    await prefs.remove(_assetKey);
    await prefs.remove(_fileKey);
  }
}