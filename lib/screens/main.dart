import 'dart:io';

import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';
import 'package:infinity_ecom_app/main.dart';
import 'package:infinity_ecom_app/my_theme.dart';
import 'package:infinity_ecom_app/presenter/bottom_appbar_index.dart';
import 'package:infinity_ecom_app/presenter/cart_counter.dart';
import 'package:infinity_ecom_app/screens/auth/login.dart';
import 'package:infinity_ecom_app/screens/category_list_n_product/category_list.dart';
import 'package:infinity_ecom_app/screens/checkout/cart.dart';
import 'package:infinity_ecom_app/screens/home.dart';
import 'package:infinity_ecom_app/screens/profile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinity_ecom_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Main extends StatefulWidget {
  Main({super.key, go_back = true});
  late bool go_back;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentIndex = 0;
  var _children = [];
  CartCounter counter = CartCounter();
  BottomAppbarIndex bottomAppbarIndex = BottomAppbarIndex();

  fetchAll() {
    getCartCount();
  }

  void onTapped(int i) {
    fetchAll();

    if (guest_checkout_status.$ && (i == 2)) {
    } else if (!guest_checkout_status.$ && (i == 2) && !is_logged_in.$) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }

    if (i == 3) {
      routes.push("/dashboard");
      return;
    }
    setState(() {
      _currentIndex = i;
    });
  }

  getCartCount() async {
    Provider.of<CartCounter>(context, listen: false).getCount();
  }

  @override
  void initState() {
    _children = [
      Home(),
      CategoryList(slug: "", is_base_category: true),
      Cart(has_bottomnav: true, from_navigation: true, counter: counter),
      Profile(),
    ];
    fetchAll();
    // TODO: implement initState
    //re appear statusbar in case it was not there in the previous page
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.initState();
  }

  // bool _dialogShowing = false;
  // Future<bool> willPop() async {
  //   print(_currentIndex);
  //   if (_currentIndex != 0) {
  //     fetchAll();
  //     setState(() {
  //       _currentIndex = 0;
  //     });
  //   } else {
  //     // print("Main will back");
  //     // CommonFunctions(context).appExitDialog();

  //     if (_dialogShowing) {
  //       return Future.value(false); // Dialog already showing, don't show again
  //     }
  //     setState(() {
  //       _dialogShowing = true;
  //     });

  //     final shouldPop = (await showDialog<bool>(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return Directionality(
  //           textDirection:
  //               app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
  //           child: AlertDialog(
  //             content:
  //                 Text(AppLocalizations.of(context)!.do_you_want_close_the_app),
  //             actions: [
  //               TextButton(
  //                   onPressed: () {
  //                     Platform.isAndroid ? SystemNavigator.pop() : exit(0);
  //                   },
  //                   child: Text(AppLocalizations.of(context)!.yes_ucf)),
  //               TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                     // setState(() {
  //                     //   _dialogShowing =
  //                     //       false; // Reset flag after dialog is closed
  //                     // });
  //                   },
  //                   child: Text(AppLocalizations.of(context)!.no_ucf)),
  //             ],
  //           ),
  //         );
  //       },
  //     ))!;

  //     return shouldPop;
  //   }
  //   return Future.value(false);

  // }
  bool _dialogShowing = false;

  Future<bool> willPop() async {
    print(_currentIndex);
    if (_currentIndex != 0) {
      fetchAll();
      setState(() {
        _currentIndex = 0;
      });
    } else {
      if (_dialogShowing) {
        return Future.value(false); // Dialog already showing, don't show again
      }
      setState(() {
        _dialogShowing = true;
      });

      final shouldPop =
          (await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Directionality(
                textDirection: app_language_rtl.$!
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: AlertDialog(
                  content: Text(
                    AppLocalizations.of(context)!.do_you_want_close_the_app,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                      },
                      child: Text(AppLocalizations.of(context)!.yes_ucf),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(AppLocalizations.of(context)!.no_ucf),
                    ),
                  ],
                ),
              );
            },
          )) ??
          false;

      setState(() {
        _dialogShowing = false; // Reset flag after dialog is closed
      });

      return shouldPop;
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPop,
      child: Directionality(
        textDirection: app_language_rtl.$!
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          extendBody: true,
          body: _children[_currentIndex],
          bottomNavigationBar: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: onTapped,
              currentIndex: _currentIndex,
              backgroundColor: Colors.white.withOpacity(0.95),
              unselectedItemColor: Color.fromRGBO(168, 175, 179, 1),
              selectedItemColor: MyTheme.accent_color,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: MyTheme.accent_color,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(168, 175, 179, 1),
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.asset(
                      "assets/home.png",
                      color: _currentIndex == 0
                          ? MyTheme.accent_color
                          : Color.fromRGBO(153, 153, 153, 1),
                      height: 16,
                    ),
                  ),
                  label: AppLocalizations.of(context)!.home_ucf,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.asset(
                      "assets/categories.png",
                      color: _currentIndex == 1
                          ? MyTheme.accent_color
                          : Color.fromRGBO(153, 153, 153, 1),
                      height: 16,
                    ),
                  ),
                  label: AppLocalizations.of(context)!.categories_ucf,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: badges.Badge(
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: MyTheme.accent_color,
                        borderRadius: BorderRadius.circular(10),
                        padding: EdgeInsets.all(5),
                      ),
                      badgeAnimation: badges.BadgeAnimation.slide(
                        toAnimate: false,
                      ),
                      badgeContent: Consumer<CartCounter>(
                        builder: (context, cart, child) {
                          return Text(
                            "${cart.cartCounter}",
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          );
                        },
                      ),
                      child: Image.asset(
                        "assets/cart.png",
                        color: _currentIndex == 2
                            ? MyTheme.accent_color
                            : Color.fromRGBO(153, 153, 153, 1),
                        height: 16,
                      ),
                    ),
                  ),
                  label: AppLocalizations.of(context)!.cart_ucf,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.asset(
                      "assets/profile.png",
                      color: _currentIndex == 3
                          ? MyTheme.accent_color
                          : Color.fromRGBO(153, 153, 153, 1),
                      height: 16,
                    ),
                  ),
                  label: AppLocalizations.of(context)!.profile_ucf,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
