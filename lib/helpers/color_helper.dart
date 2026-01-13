import 'package:flutter/material.dart';

class ColorHelper {
  static Color getColorFromColorCode(String code) {
    if (code.isEmpty) return Colors.transparent;
    var hexCode = code.replaceAll('#', '');
    if (hexCode.length == 3) {
      hexCode = hexCode.split('').map((c) => c + c).join();
    }
    if (hexCode.length != 6) {
      return Colors.transparent;
    }
    try {
      return Color(int.parse(hexCode, radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.transparent;
    }
  }
}
