import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  List<Color> _currentColors = [Colors.black, Colors.black];

  List<Color> get currentColors => _currentColors;

  void updateColors(List<Color> colors) {
    _currentColors = colors;
    notifyListeners();
  }
}
