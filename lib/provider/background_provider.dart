import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tomato_project/utils/background_storage.dart';

class BackgroundProvider extends ChangeNotifier {
  Color backgroundColor = Colors.purple.shade400;
  File? backgroundImage;
  String? backgroundAssetImage;

  BackgroundProvider() {
    _loadBackground();
  }

  Future<void> setColor(Color color) async {
    backgroundColor = color;
    backgroundImage = null;
    backgroundAssetImage = null;
    notifyListeners();
    await BackgroundStorage.saveColor(color);
  }

  Future<void> setAssetImage(String path) async {
    backgroundAssetImage = path;
    backgroundImage = null;
    notifyListeners();
    await BackgroundStorage.saveAsset(path);
  }

  Future<void> setFileImage(File file) async {
    backgroundImage = file;
    backgroundAssetImage = null;
    notifyListeners();
    await BackgroundStorage.saveFile(file);
  }

  Future<void> _loadBackground() async {
    final data = await BackgroundStorage.loadBackground();
    if (data.containsKey('color')) {
      backgroundColor = data['color'];
      backgroundImage = null;
      backgroundAssetImage = null;
    } else if (data.containsKey('asset')) {
      backgroundAssetImage = data['asset'];
      backgroundImage = null;
    } else if (data.containsKey('file')) {
      backgroundImage = data['file'];
      backgroundAssetImage = null;
    }
    notifyListeners();
  }
}