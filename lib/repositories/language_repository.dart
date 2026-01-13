import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/repositories/api-request.dart';
import 'package:infinity_ecom_app/data_model/language_list_response.dart';
import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';

class LanguageRepository {
  Future<LanguageListResponse> getLanguageList() async {
    String url = ("${AppConfig.BASE_URL}/languages");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );

    return languageListResponseFromJson(response.body);
  }
}
