import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/middlewares/banned_user.dart';
import 'package:infinity_ecom_app/repositories/api-request.dart';
import 'dart:convert';
import 'package:infinity_ecom_app/data_model/simple_image_upload_response.dart';
import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';

class FileRepository {
  Future<dynamic> getSimpleImageUploadResponse(
    String image,
    String filename,
  ) async {
    var postBody = jsonEncode({"image": image, "filename": filename});

    String url = ("${AppConfig.BASE_URL}/file/image-upload");
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

    return simpleImageUploadResponseFromJson(response.body);
  }
}
