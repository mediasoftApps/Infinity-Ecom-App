import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/data_model/currency_response.dart';
import 'package:infinity_ecom_app/repositories/api-request.dart';

class CurrencyRepository {
  Future<CurrencyResponse> getListResponse() async {
    String url = ('${AppConfig.BASE_URL}/currencies');

    final response = await ApiRequest.get(url: url);
    return currencyResponseFromJson(response.body);
  }
}
