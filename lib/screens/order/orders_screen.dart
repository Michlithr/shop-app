import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/orders_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const ROUTE_NAME = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<OrdersProvider>(context, listen: false).fetchOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (dataSnapshot.error == null) {
            return Consumer<OrdersProvider>(
              builder: (ctx, orderData, child) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, index) =>
                    OrderItem(order: orderData.orders[index]),
              ),
            );
          } else {
            return Center(child: Text('An error occured!'));
          }
        },
      ),
    );
  }
}
