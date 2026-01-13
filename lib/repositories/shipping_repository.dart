import 'dart:convert';

import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/data_model/delivery_info_response.dart';
import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';
import 'package:infinity_ecom_app/repositories/api-request.dart';

class ShippingRepository {
  Future<dynamic> getDeliveryInfo({String? guestAddress}) async {
    String url = ("${AppConfig.BASE_URL}/delivery-info");
    Map<String, dynamic> postBodyMap = {};
    if (guest_checkout_status.$ && !is_logged_in.$) {
      postBodyMap['temp_user_id'] = temp_user_id.$;
      if (guestAddress != null) {
        postBodyMap['address'] = jsonDecode(guestAddress);
      }
    } else {
      postBodyMap['user_id'] = user_id.$;
    }

    String postBody = jsonEncode(postBodyMap);

    final response = await ApiRequest.post(
      url: url,
      body: postBody,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
    return deliveryInfoResponseFromJson(response.body);
  }
}
