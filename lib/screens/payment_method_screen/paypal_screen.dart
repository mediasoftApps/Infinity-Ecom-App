import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../custom/toast_component.dart';
import '../../helpers/main_helpers.dart';
import '../../helpers/shared_value_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../my_theme.dart';
import '../../repositories/payment_repository.dart';
import '../orders/order_list.dart';
import '../profile.dart';
import '../wallet.dart';

class PaypalScreen extends StatefulWidget {
  final double? amount;
  final String payment_type;
  final String? payment_method_key;
  final String? package_id;
  final int? orderId;

  const PaypalScreen({
    super.key,
    this.amount = 0.00,
    this.orderId = 0,
    this.payment_type = "",
    this.package_id = "0",
    this.payment_method_key = "",
  });

  @override
  State<PaypalScreen> createState() => _PaypalScreenState();
}

class _PaypalScreenState extends State<PaypalScreen> {
  int? _combined_order_id = 0;
  bool _order_init = false;
  String? _initial_url = "";
  bool _initial_url_fetched = false;

  final WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    super.initState();
    if (widget.payment_type == "cart_payment") {
      createOrder();
    }

    if (widget.payment_type != "cart_payment") {
      // on cart payment need proper order id
      getSetInitialUrl();
    }
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

    getSetInitialUrl();
  }

  getSetInitialUrl() async {
    var paypalUrlResponse = await PaymentRepository().getPaypalUrlResponse(
      widget.payment_type,
      _combined_order_id,
      widget.package_id,
      widget.amount,
      widget.orderId,
    );

    if (paypalUrlResponse.result == false) {
      ToastComponent.showDialog(paypalUrlResponse.message!);
      Navigator.of(context).pop();
      return;
    }

    _initial_url = paypalUrlResponse.url;
    _initial_url_fetched = true;
    setState(() {});
    paypal();
    // log(_initial_url);
    // log(_initial_url_fetched);
  }

  paypal() {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {},
          onPageFinished: (page) {
            if (page.contains("/paypal/payment/done")) {
              getData();
            } else if (page.contains("/paypal/payment/cancel")) {
              ToastComponent.showDialog("Payment cancelled");
              Navigator.of(context).pop();
              return;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_initial_url!), headers: commonHeader);
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
      var responseJSON = jsonDecode(data as String);

      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }

      log("responseJSON");
      log('order type${widget.payment_type}');
      log(responseJSON);

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
        } else if (widget.payment_type == "order_re_payment") {
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
    if (_order_init == false &&
        _combined_order_id == 0 &&
        widget.payment_type == "cart_payment") {
      return Center(
        child: Text(AppLocalizations.of(context)!.creating_order),
      );
    } else if (_initial_url_fetched == false) {
      return Center(
        child: Text(AppLocalizations.of(context)!.fetching_paypal_url),
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
        AppLocalizations.of(context)!.pay_with_paypal,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
