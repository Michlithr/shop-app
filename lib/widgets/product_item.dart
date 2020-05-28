import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../screens/product/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<ProductProvider>(context, listen: false);
    final _cart = Provider.of<CartProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          child: Image.network(
            _product.imageUrl,
            fit: BoxFit.cover,
          ),
          onTap: () => Navigator.of(context).pushNamed(
            ProductDetailScreen.ROUTE_NAME,
            arguments: _product.id,
          ),
        ),
        footer: _buildFooter(context, _product, _cart),
      ),
    );
  }

  Widget _buildFooter(
      BuildContext context, ProductProvider product, CartProvider cart) {
    return GridTileBar(
      backgroundColor: Colors.black87,
      leading: Consumer<ProductProvider>(
        builder: (ctx, product, _) => _buildIconButton(
          context,
          product.isFavourite ? Icons.favorite : Icons.favorite_border,
          () => product.toggleFavouriteStatus(),
        ),
      ),
      title: Text(
        product.title,
        textAlign: TextAlign.center,
      ),
      trailing: _buildIconButton(
        context,
        Icons.shopping_cart,
        // () => cart.addItem(product.id, product.price, product.title),
        () => addToCart(context, product, cart),
      ),
    );
  }

  void addToCart(
      BuildContext context, ProductProvider product, CartProvider cart) {
    cart.addItem(product.id, product.price, product.title);
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 2),
      content: Text(
        'Item added to cart.',
      ),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => cart.removeSingleItem(product.id),
      ),
    ));
  }

  Widget _buildIconButton(
      BuildContext context, IconData icon, Function onPressed) {
    return IconButton(
      icon: Icon(
        icon,
        color: Theme.of(context).accentColor,
      ),
      onPressed: onPressed,
    );
  }
}
