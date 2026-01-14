import 'package:flutter/material.dart';

import '../helpers/shared_value_helper.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  Locale get locale {
    _locale ??= Locale(
      app_mobile_language.$ == '' ? "en" : app_mobile_language.$!,
      '',
    );
    return _locale!;
  }

  void setLocale(String code) {
    _locale = Locale(code, '');
    notifyListeners();
  }
}
