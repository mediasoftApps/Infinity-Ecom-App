import 'package:infinity_ecom_app/custom/box_decorations.dart';
import 'package:infinity_ecom_app/custom/device_info.dart';
import 'package:infinity_ecom_app/custom/enum_classes.dart';
import 'package:infinity_ecom_app/custom/lang_text.dart';
import 'package:infinity_ecom_app/custom/style.dart';
import 'package:infinity_ecom_app/custom/toast_component.dart';
import 'package:infinity_ecom_app/custom/useful_elements.dart';
import 'package:infinity_ecom_app/data_model/customer_package_response.dart';
import 'package:infinity_ecom_app/helpers/shimmer_helper.dart';
import 'package:infinity_ecom_app/my_theme.dart';
import 'package:infinity_ecom_app/repositories/customer_package_repository.dart';
import 'package:infinity_ecom_app/screens/checkout/checkout.dart';
import 'package:infinity_ecom_app/screens/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinity_ecom_app/l10n/app_localizations.dart';

import '../../helpers/shared_value_helper.dart';
import '../auth/login.dart';

class UpdatePackage extends StatefulWidget {
  final bool goHome;

  const UpdatePackage({super.key, this.goHome = false});

  @override
  State<UpdatePackage> createState() => _UpdatePackageState();
}

class _UpdatePackageState extends State<UpdatePackage> {
  List<Package> _packages = [];
  bool _isFetchAllData = false;

  Future<bool> getPackageList() async {
    var response = await CustomerPackageRepository().getList();
    _packages.addAll(response.data!);
    setState(() {});
    return true;
  }

  Future<bool> sendFreePackageReq(id) async {
    var response = await CustomerPackageRepository().freePackagePayment(id);
    ToastComponent.showDialog(response.message);

    if (response.result) {
      Navigator.pop(context);
    }

    setState(() {});
    return true;
  }

  Future<bool> fetchData() async {
    await getPackageList();
    _isFetchAllData = true;
    setState(() {});
    return true;
  }

  clearData() {
    _isFetchAllData = false;
    _packages = [];
    setState(() {});
  }

  Future<bool> resetData() {
    clearData();
    return fetchData();
  }

  Future<void> refresh() async {
    await resetData();
    return Future.delayed(const Duration(seconds: 0));
  }

  @override
  void initState() {
    fetchData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.goHome) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Main();
              },
            ),
          );
        }

        return Future.delayed(Duration.zero);
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          elevation: 0,
          backgroundColor: MyTheme.white,
          title: Text(
            AppLocalizations.of(context)!.packages_ucf,
            style: MyStyle.appBarStyle,
          ),
          //leadingWidth: 20,
          leading: widget.goHome
              ? UsefulElements.backToMain(context, go_back: false)
              : IconButton(
                  icon: Icon(
                    CupertinoIcons.arrow_left,
                    color: MyTheme.dark_font_grey,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: buildList(),
            ),
          ),
        ),
      ),
    );
  }

  ListView buildList() {
    return _isFetchAllData
        ? ListView.separated(
            padding: EdgeInsets.only(top: 10),
            separatorBuilder: (context, index) {
              return SizedBox(height: 10);
            },
            itemCount: _packages.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return packageItem(
                index,
                context,
                _packages[index].logo,
                _packages[index].name!,
                _packages[index].amount!,
                _packages[index].productUploadLimit.toString(),
                _packages[index].price,
                _packages[index].id,
              );
            },
          )
        : loadingShimmer() as ListView;
  }

  Widget loadingShimmer() {
    return ShimmerHelper().buildListShimmer(item_count: 10, item_height: 170.0);
  }

  Widget packageItem(
    int index,
    BuildContext context,
    String? url,
    String packageName,
    String packagePrice,
    String packageProduct,
    price,
    packageId,
  ) {
    print(url);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UsefulElements.roundImageWithPlaceholder(
            width: 30.0,
            height: 30.0,
            url: url,
            backgroundColor: MyTheme.noColor,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              packageName,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: DeviceInfo(context).width! / 2,
              decoration: BoxDecoration(
                color: MyTheme.accent_color,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  if (is_logged_in.$) {
                    if (double.parse(price.toString()) <= 0) {
                      sendFreePackageReq(packageId);
                      return;
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Checkout(
                            title: "Purchase Package",
                            rechargeAmount: double.parse(price.toString()),
                            paymentFor: PaymentFor.PackagePay,
                            packageId: packageId,
                          ),
                        ),
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  }
                },
                radius: 3.0,
                child: Text(
                  packagePrice,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: DeviceInfo(context).width! / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: MyTheme.accent_color,
                    size: 11,
                  ),
                  Text(
                    "$packageProduct ${LangText(context).local.upload_limit_ucf}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
