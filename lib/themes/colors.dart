import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musichub/themes/themes.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

const Color black5 = Color(0xFF131213);
const Color black3 = Color(0xFF121212);
const Color black4 = Color(0xFF111828);
const Color black = Color(0xFF111111);

const Color black2 = Color.fromARGB(255, 11, 8, 8);
const Color green = Color(0xff1DB954);

// Future<List<Color>> getMainColorsFromImageUrl(String imageUrl) async {
//   try {
//     // Fetch the image from the network
//     final response = await http.get(Uri.parse(imageUrl));
//     if (response.statusCode == 200) {
//       final Uint8List bytes = response.bodyBytes;
//       final image = Image.memory(bytes);

//       // Generate the palette
//       final PaletteGenerator paletteGenerator =
//           await PaletteGenerator.fromImageProvider(
//         MemoryImage(bytes),
//       );

//       // Extract the main colors
//       final List<Color> mainColors = [];
//       if (paletteGenerator.dominantColor != null) {
//         mainColors.add(paletteGenerator.dominantColor!.color);
//       }
//       if (paletteGenerator.vibrantColor != null) {
//         mainColors.add(paletteGenerator.vibrantColor!.color);
//       }

//       // If less than 2 colors, fill with black
//       while (mainColors.length < 2) {
//         mainColors.add(Colors.black);
//       }

//       return mainColors;
//     } else {
//       throw Exception('Failed to load image');
//     }
//   } catch (e) {
//     print('Error: $e');
//     return [Colors.black, Colors.black];
//   }
// }

// Define the function to get colors from image URL
Future<List<Color>> getMainColorsFromImageUrl(String imageUrl) async {
  try {
    // Fetch the image from the network
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final image = Image.memory(bytes);

      // Generate the palette
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        MemoryImage(bytes),
      );

      // Extract the main color
      Color? mainColor = paletteGenerator.dominantColor?.color;

      // If there's no dominant color, fall back to black
      if (mainColor == null) {
        mainColor = Colors.black;
      }

      // Create a darker version of the main color
      Color darkColor = Colors.black; // Default color if needed
      if (mainColor != Colors.black) {
        darkColor = Color.lerp(mainColor, Colors.black, 0.8)!;
      }

      // Return the main color and its darker version
      return [mainColor, darkColor];
    } else {
      throw Exception('Failed to load image');
    }
  } catch (e) {
    print('Error: $e');
    return [Colors.black, Colors.black];
  }
}

// theme_provider.dart

class ThemeProvider with ChangeNotifier {
  static const _boxName = 'settingsBox';
  static const _key = 'themeMode';
  late ThemeData _currentTheme;

  ThemeProvider() {
    _currentTheme = AppThemes.lightTheme; // Default theme
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  void _loadTheme() async {
    final box = Hive.box(_boxName);
    final themeName = box.get(_key, defaultValue: 'lightTheme');
    _setTheme(themeName);
  }

  void _setTheme(String themeName) {
    switch (themeName) {
      case 'darkTheme':
        _currentTheme = AppThemes.darkTheme;
        break;
      case 'redTheme':
        _currentTheme = AppThemes.redTheme;
        break;
      default:
        _currentTheme = AppThemes.lightTheme;
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeName) async {
    final box = Hive.box(_boxName);
    await box.put(_key, themeName);
    _setTheme(themeName);
  }
}
