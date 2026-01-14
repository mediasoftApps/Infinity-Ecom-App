import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/addons_helper.dart';
import '../helpers/auth_helper.dart';
import '../helpers/business_setting_helper.dart';
import '../helpers/shared_value_helper.dart';
import '../helpers/system_config.dart';
import '../presenter/currency_presenter.dart';
import '../providers/locale_provider.dart';
import 'main.dart';
import 'splash_screen.dart';

class Index extends StatefulWidget {
  final bool? goBack;
  const Index({super.key, this.goBack = true});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  Future<String?> getSharedValueHelperData() async {
    access_token.load().whenComplete(() {
      AuthHelper().fetch_and_set();
    });
    AddonsHelper().setAddonsData();
    BusinessSettingHelper().setBusinessSettingData();
    await app_language.load();
    await app_mobile_language.load();
    await app_language_rtl.load();
    await system_currency.load();
    Provider.of<CurrencyPresenter>(context, listen: false).fetchListData();

    return app_mobile_language.$;
  }

  @override
  void initState() {
    getSharedValueHelperData().then((value) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        SystemConfig.isShownSplashScreed = true;
        Provider.of<LocaleProvider>(
          context,
          listen: false,
        ).setLocale(app_mobile_language.$!);
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemConfig.context ??= context;
    return Scaffold(
      body: SystemConfig.isShownSplashScreed
          ? Main(go_back: widget.goBack!)
          : SplashScreen(),
    );
  }
}
