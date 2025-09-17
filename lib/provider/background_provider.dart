import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tomato_project/utils/background_storage.dart';

class BackgroundProvider extends ChangeNotifier {
  // 背景類型
  Color backgroundColor = Colors.purple.shade400;
  Gradient? backgroundGradient;
  File? backgroundImage;
  String? backgroundAssetImage;

  BackgroundProvider() {
    _loadBackground();
  }

  /// 設定純色
  Future<void> setColor(Color color) async {
    backgroundColor = color;
    backgroundGradient = null;
    backgroundImage = null;
    backgroundAssetImage = null;
    notifyListeners();
    await BackgroundStorage.saveColor(color);
  }

  /// 設定漸層
  Future<void> setGradient(Gradient gradient) async {
    backgroundGradient = gradient;
    backgroundImage = null;
    backgroundAssetImage = null;
    notifyListeners();
    await BackgroundStorage.saveGradient(gradient);
  }

  /// 設定 Asset 圖片
  Future<void> setAssetImage(String path) async {
    backgroundAssetImage = path;
    backgroundGradient = null;
    backgroundImage = null;
    notifyListeners();
    await BackgroundStorage.saveAsset(path);
  }

  /// 設定 File 圖片
  Future<void> setFileImage(File file) async {
    backgroundImage = file;
    backgroundGradient = null;
    backgroundAssetImage = null;
    notifyListeners();
    await BackgroundStorage.saveFile(file);
  }

  /// 清除背景
  Future<void> clearBackground() async {
    backgroundColor = Colors.blue;
    backgroundGradient = null;
    backgroundImage = null;
    backgroundAssetImage = null;
    notifyListeners();
    await BackgroundStorage.clear();
  }

  /// 載入背景
  Future<void> _loadBackground() async {
    final data = await BackgroundStorage.loadBackground();
    if (data.containsKey('color')) {
      backgroundColor = data['color'];
      backgroundGradient = null;
      backgroundImage = null;
      backgroundAssetImage = null;
    } else if (data.containsKey('gradient')) {
      backgroundGradient = data['gradient'];
      backgroundImage = null;
      backgroundAssetImage = null;
    } else if (data.containsKey('asset')) {
      backgroundAssetImage = data['asset'];
      backgroundGradient = null;
      backgroundImage = null;
    } else if (data.containsKey('file')) {
      backgroundImage = data['file'];
      backgroundGradient = null;
      backgroundAssetImage = null;
    }
    notifyListeners();
  }
}