import 'package:infinity_ecom_app/helpers/main_helpers.dart';
import 'package:infinity_ecom_app/middlewares/route_middleware.dart';
import 'package:infinity_ecom_app/screens/auth/login.dart';
import 'package:flutter/cupertino.dart';

class AuthMiddleware extends RouteMiddleware {
  final Widget _goto;

  AuthMiddleware(this._goto);

  @override
  Widget next() {
    if (!userIsLogedIn) {
      return Login();
    }
    return _goto;
  }
}
