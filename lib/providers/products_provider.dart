import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'product_provider.dart';
import '../services/product_service.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  String authToken;
  String userId;
  List<ProductProvider> _products = [];

  ProductsProvider(this.authToken, this.userId, this._products);

  void updateProducts(String authToken, List<ProductProvider> products) {
    this.authToken = authToken;
    this._products = products;
  }

  List<ProductProvider> get products {
    return [..._products];
  }

  List<ProductProvider> get favouriteProducts {
    return [..._products.where((product) => product.isFavourite)];
  }

  ProductProvider findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    try {
      final productsResponse = await ProductService.getProducts(filterByUser, userId, authToken);
      final products = json.decode(productsResponse.body) as Map<String, dynamic>;
      if (products == null) {
        return;
      }
      final favouritesResponse = await ProductService.getFavourites(userId, authToken);
      final favourites = json.decode(favouritesResponse.body);
      final List<ProductProvider> loadedProducts = [];
      products.forEach((productId, productData) {
        loadedProducts.add(ProductProvider(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          price: productData['price'],
          isFavourite: favourites == null ? false : favourites[productId] ?? false,
          authToken: authToken,
          userId: userId,
        ));
      });
      _products = loadedProducts;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(ProductProvider product) async {
    try {
      final response = await ProductService.addProduct(product, authToken);
      _products.add(ProductProvider(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        authToken: authToken,
        userId: userId,
      ));
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  Future<void> updateProduct(ProductProvider newProduct) async {
    final productIndex =
        _products.indexWhere((product) => product.id == newProduct.id);
    if (productIndex >= 0) {
      try {
        await ProductService.updateProduct(newProduct, authToken);
        _products[productIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        print(error);
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final existingProductIndex =
        _products.indexWhere((product) => product.id == id);
    var existingProduct = _products[existingProductIndex];

    _products.removeAt(existingProductIndex);
    notifyListeners();

    final response = await ProductService.deleteProduct(id, authToken);
    if (response.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
