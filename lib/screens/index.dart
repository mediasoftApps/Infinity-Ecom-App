import 'package:infinity_ecom_app/helpers/addons_helper.dart';
import 'package:infinity_ecom_app/helpers/auth_helper.dart';
import 'package:infinity_ecom_app/helpers/business_setting_helper.dart';
import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';
import 'package:infinity_ecom_app/helpers/system_config.dart';
import 'package:infinity_ecom_app/presenter/currency_presenter.dart';
import 'package:infinity_ecom_app/providers/locale_provider.dart';
import 'package:infinity_ecom_app/screens/main.dart';
import 'package:infinity_ecom_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          ? Main(go_back: widget.goBack)
          : SplashScreen(),
    );
  }
}
