import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const ROUTE_NAME = '/cart';
  final title = 'Your Cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          _buildTotalCard(context, cart),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, index) => CartItem(
                id: cart.items.values.toList()[index].id,
                productId: cart.items.keys.toList()[index],
                title: cart.items.values.toList()[index].title,
                price: cart.items.values.toList()[index].price,
                quantity: cart.items.values.toList()[index].quantity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, CartProvider cart) {
    return Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: EdgeInsets.all(8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'Total',
            style: TextStyle(fontSize: 20),
          ),
          Spacer(),
          Chip(
            label: Text(
              '\$${cart.totalCost}',
              style: TextStyle(
                color: Theme.of(context).primaryTextTheme.headline1.color,
              ),
            ),
            backgroundColor: Theme.of(context).accentColor,
          ),
          OrderButton(cart),
        ]),
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final CartProvider cart;

  OrderButton(this.cart);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      textColor: Theme.of(context).accentColor,
      onPressed: (widget.cart.totalCost <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<OrdersProvider>(context, listen: false)
                  .addOrder(
                [...widget.cart.items.values],
                widget.cart.totalCost,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clearCart();
            },
    );
  }
}
