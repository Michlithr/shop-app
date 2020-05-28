import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/order_service.dart';
import '../models/order_item.dart';
import '../models/cart_item.dart';

class OrdersProvider with ChangeNotifier {
  final String authToken;
  String userId;
  List<OrderItem> _orders = [];

  OrdersProvider(this.authToken, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    try {
      final response = await OrderService.getOrders(userId, authToken);
      final List<OrderItem> fetchedOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        _orders.clear();
        notifyListeners();
        return;
      }
      extractedData.forEach((orderId, orderData) {
        fetchedOrders.add(OrderItem(
          id: orderId,
          totalCost: orderData['totalCost'],
          dateTime: DateTime.parse(orderData['dateTime']),
          items: (orderData['items'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    quantity: item['quantity'],
                    price: item['price'],
                    title: item['title'],
                  ))
              .toList(),
        ));
        _orders = fetchedOrders.reversed.toList();
        notifyListeners();
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double totalCost) async {
    final orderItem = OrderItem(
      id: DateTime.now().toString(),
      totalCost: totalCost,
      items: cartProducts,
      dateTime: DateTime.now(),
    );
    try {
      final response = await OrderService.addOrder(orderItem, userId, authToken);
      _orders.insert(
        _orders.length,
        OrderItem(
          id: json.decode(response.body)['name'],
          totalCost: orderItem.totalCost,
          items: orderItem.items,
          dateTime: orderItem.dateTime,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }
}
