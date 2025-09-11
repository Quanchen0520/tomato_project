import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundStorage {
  static const String _colorKey = 'bgColor';
  static const String _gradientKey = 'bgGradient';
  static const String _assetKey = 'bgAsset';
  static const String _fileKey = 'bgImage';

  /// 儲存顏色
  static Future<void> saveColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
    await prefs.remove(_gradientKey);
    await prefs.remove(_assetKey);
    await prefs.remove(_fileKey);
  }

  /// 儲存漸層 (只支援 LinearGradient，存顏色值與方向)
  static Future<void> saveGradient(Gradient gradient) async {
    if (gradient is LinearGradient) {
      final prefs = await SharedPreferences.getInstance();
      final colors = gradient.colors.map((c) => c.value).toList();
      final begin = gradient.begin.toString();
      final end = gradient.end.toString();
      await prefs.setStringList(_gradientKey, [
        colors.join(','), // 顏色值串
        begin,
        end,
      ]);
      await prefs.remove(_colorKey);
      await prefs.remove(_assetKey);
      await prefs.remove(_fileKey);
    }
  }

  /// 儲存 assets 圖片
  static Future<void> saveAsset(String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_assetKey, assetPath);
    await prefs.remove(_colorKey);
    await prefs.remove(_gradientKey);
    await prefs.remove(_fileKey);
  }

  /// 儲存檔案圖片
  static Future<void> saveFile(File file) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fileKey, file.path);
    await prefs.remove(_colorKey);
    await prefs.remove(_gradientKey);
    await prefs.remove(_assetKey);
  }

  /// 讀取背景設定
  static Future<Map<String, dynamic>> loadBackground() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_colorKey)) {
      return {'color': Color(prefs.getInt(_colorKey)!)};
    } else if (prefs.containsKey(_gradientKey)) {
      final list = prefs.getStringList(_gradientKey)!;
      final colors = list[0].split(',').map((v) => Color(int.parse(v))).toList();
      final begin = _alignmentFromString(list[1]);
      final end = _alignmentFromString(list[2]);
      return {'gradient': LinearGradient(colors: colors, begin: begin, end: end)};
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
    await prefs.remove(_gradientKey);
    await prefs.remove(_assetKey);
    await prefs.remove(_fileKey);
  }

  /// 字串轉 Alignment
  static Alignment _alignmentFromString(String str) {
    switch (str) {
      case 'Alignment.topLeft':
        return Alignment.topLeft;
      case 'Alignment.topRight':
        return Alignment.topRight;
      case 'Alignment.bottomLeft':
        return Alignment.bottomLeft;
      case 'Alignment.bottomRight':
        return Alignment.bottomRight;
      case 'Alignment.center':
        return Alignment.center;
      default:
        return Alignment.topLeft;
    }
  }
}
