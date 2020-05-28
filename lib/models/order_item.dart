
import 'package:flutter/foundation.dart';

import 'cart_item.dart';

class OrderItem {
  final String id;
  final double totalCost;
  final List<CartItem> items;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.totalCost,
    @required this.items,
    @required this.dateTime,
  });
}