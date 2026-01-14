import 'dart:convert';

import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/custom/toast_component.dart';
import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';
import 'package:infinity_ecom_app/my_theme.dart';
import 'package:infinity_ecom_app/repositories/payment_repository.dart';
import 'package:infinity_ecom_app/screens/orders/order_list.dart';
import 'package:infinity_ecom_app/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinity_ecom_app/l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../helpers/main_helpers.dart';
import '../profile.dart';

class ProxypayScreen extends StatefulWidget {
  final double? amount;
  final String payment_type;
  final String? payment_method_key;
  final String package_id;
  final int? orderId;

  const ProxypayScreen({
    super.key,
    this.amount = 0.00,
    this.orderId = 0,
    this.payment_type = "",
    this.payment_method_key = "",
    this.package_id = "0",
  });

  @override
  State<ProxypayScreen> createState() => _ProxypayScreenState();
}

class _ProxypayScreenState extends State<ProxypayScreen> {
  int? _combined_order_id = 0;
  bool _order_init = false;

  final WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    super.initState();

    if (widget.payment_type == "cart_payment") {
      createOrder();
    } else {
      proxypay();
    }
  }

  proxypay() {
    String initial_url =
        "${AppConfig.BASE_URL}/proxypay?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.package_id}&order_id=${widget.orderId}";

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // onPageStarted: (controller) {
          //   _webViewController.loadRequest((_initial_url));
          // },
          onWebResourceError: (error) {},
          onPageFinished: (page) {
            if (page.contains("/proxypay/success")) {
              getData();
            } else if (page.contains("/proxypay/cancel")) {
              ToastComponent.showDialog(
                AppLocalizations.of(context)!.payment_cancelled_ucf,
              );
              Navigator.of(context).pop();
              return;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(initial_url), headers: commonHeader);
  }

  createOrder() async {
    var orderCreateResponse = await PaymentRepository().getOrderCreateResponse(
      widget.payment_method_key,
    );

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message);
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});
    proxypay();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  void getData() {
    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      // var decodedJSON = jsonDecode(data);
      var responseJSON = jsonDecode(data as String);
      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      //print(data.toString());
      if (responseJSON["result"] == false) {
        ToastComponent.showDialog(responseJSON["message"]);
        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        ToastComponent.showDialog(responseJSON["message"]);
        if (widget.payment_type == "cart_payment") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return OrderList(from_checkout: true);
              },
            ),
          );
        } else if (widget.payment_type == "wallet_payment") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Wallet(from_recharge: true);
              },
            ),
          );
        } else if (widget.payment_type == "customer_package_payment") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Profile();
              },
            ),
          );
        }
      }
    });
  }

  buildBody() {
    //print("init url");
    //print(initial_url);

    if (_order_init == false &&
        _combined_order_id == 0 &&
        widget.payment_type == "cart_payment") {
      return Center(
        child: Text(AppLocalizations.of(context)!.creating_order),
      );
    } else {
      return SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: WebViewWidget(controller: _webViewController),
        ),
      );
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        ' AppLocalizations.of(context)!.pay_with_proxypay',
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
