import 'package:flutter/cupertino.dart';
import 'package:infinity_ecom_app/l10n/app_localizations.dart';

class LangText {
  BuildContext context;
  late AppLocalizations local;

  LangText(this.context) {
    local = AppLocalizations.of(context)!;
  }
}
