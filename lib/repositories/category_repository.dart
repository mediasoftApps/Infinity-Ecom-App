import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/data_model/category_response.dart';
import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';
import 'package:infinity_ecom_app/repositories/api-request.dart';

class CategoryRepository {
  Future<CategoryResponse> getCategories({parent_id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/categories?parent_id=$parent_id");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getFeturedCategories() async {
    String url = ("${AppConfig.BASE_URL}/categories/featured");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );

    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getCategoryInfo(slug) async {
    String url = ("${AppConfig.BASE_URL}/category/info/$slug");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getTopCategories() async {
    String url = ("${AppConfig.BASE_URL}/categories/top");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getFilterPageCategories() async {
    String url = ("${AppConfig.BASE_URL}/filter/categories");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );
    return categoryResponseFromJson(response.body);
  }
}
