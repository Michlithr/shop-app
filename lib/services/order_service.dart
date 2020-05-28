import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/order_item.dart';

class OrderService {
  static const URL = 'your-db-url';

  static Future<http.Response> getOrders(String userId, String authToken) async {
    return await http.get(URL + '$userId.json?auth=$authToken');
  }

  static Future<http.Response> addOrder(OrderItem order, String userId, String authToken) async {
    final body = json.encode({
      'id': order.id,
      'totalCost': order.totalCost,
      'dateTime': order.dateTime.toIso8601String(),
      'items': order.items
          .map((cartItem) => {
                'id': cartItem.id,
                'title': cartItem.title,
                'quantity': cartItem.quantity,
                'price': cartItem.price,
              })
          .toList(),
    });
    return await http.post(URL + '$userId.json?auth=$authToken', body: body);
  }
}
