import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/product_service.dart';
import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;
  final String authToken;
  final String userId;

  ProductProvider({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.imageUrl,
    this.description = 'There\s no description for this product yet',
    this.isFavourite = false,
    @required this.authToken,
    @required this.userId,
  });

  Future<void> toggleFavouriteStatus() async {
    final oldStatus = isFavourite;
    _setFavouriteValue(!oldStatus);

    try {
      final response = await ProductService.toggleFavouriteStatus(this, userId, authToken);
      if (response.statusCode >= 400) {
        throw HttpException('Update failed!');
      }
    } catch (error) {
      _setFavouriteValue(oldStatus);
    }
  }

  void _setFavouriteValue(bool newValue) {
    isFavourite = !isFavourite;
    notifyListeners();
  }

  String toJson() {
    return json.encode({
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    });
  }
}
