import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/data_model/pickup_points_response.dart';
import 'package:infinity_ecom_app/repositories/api-request.dart';

class PickupPointRepository {
  Future<PickupPointListResponse> getPickupPointListResponse() async {
    String url = ('${AppConfig.BASE_URL}/pickup-list');

    final response = await ApiRequest.get(url: url);

    return pickupPointListResponseFromJson(response.body);
  }
}
