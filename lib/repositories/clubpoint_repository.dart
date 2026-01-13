import 'dart:convert';

import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/data_model/clubpoint_response.dart';
import 'package:infinity_ecom_app/data_model/clubpoint_to_wallet_response.dart';
import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';
import 'package:infinity_ecom_app/middlewares/banned_user.dart';
import 'package:infinity_ecom_app/repositories/api-request.dart';

class ClubpointRepository {
  Future<dynamic> getClubPointListResponse({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/clubpoint/get-list?page=$page");

    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
      middleware: BannedUser(),
    );
    return clubpointResponseFromJson(response.body);
  }

  Future<dynamic> getClubpointToWalletResponse(int? id) async {
    var postBody = jsonEncode({"id": "$id"});
    String url = ("${AppConfig.BASE_URL}/clubpoint/convert-into-wallet");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
      body: postBody,
      middleware: BannedUser(),
    );
    return clubpointToWalletResponseFromJson(response.body);
  }
}
