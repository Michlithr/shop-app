import 'dart:convert';

import 'package:http/http.dart' as http;

import '../providers/product_provider.dart';

class ProductService {
  static const BASE_URL = 'your-db-url';

  static Future<http.Response> getProducts(
      bool filterByUser, userId, String authToken) async {
    final filterString = filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        '/products.json?auth=$authToken' + filterString;
    return await http.get(BASE_URL + url);
  }

  static Future<http.Response> deleteProduct(
      String productId, String authToken) async {
    final url = '/products/$productId.json?auth=$authToken';
    return await http.delete(BASE_URL + url);
  }

  static Future<http.Response> addProduct(
      ProductProvider product, String authToken) async {
    final url = '/products.json?auth=$authToken';
    final body = json.encode({
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'creatorId': product.userId,
    });
    return await http.post(BASE_URL + url, body: body);
  }

  static Future<http.Response> updateProduct(
      ProductProvider product, String authToken) async {
    final url = '/products/${product.id}.json?auth=$authToken';
    final body = product.toJson();
    return await http.patch(BASE_URL + url, body: body);
  }

  static Future<http.Response> toggleFavouriteStatus(
      ProductProvider product, String userId, String authToken) async {
    final url = '/userFavourites/$userId/${product.id}.json?auth=$authToken';
    final body = json.encode(product.isFavourite);
    return await http.put(BASE_URL + url, body: body);
  }

  static Future<http.Response> getFavourites(
      String userId, String authToken) async {
    final url = '/userFavourites/$userId.json?auth=$authToken';
    return await http.get(BASE_URL + url);
  }
}
