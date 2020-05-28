import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart/cart_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

enum FilterOption {
  FAVOURITES,
  ALL,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const ROUTE_NAME = '/productsOverview';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  final title = "Shop";
  var _showOnlyFavourites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() => _isLoading = true);

      Provider.of<ProductsProvider>(context)
          .fetchProducts()
          .then((_) => setState(() => _isLoading = false));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, consumerChild) => Badge(
              child: consumerChild,
              value: cart.itemsAmount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.ROUTE_NAME),
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favourites'),
                value: FilterOption.FAVOURITES,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.ALL,
              ),
            ],
            onSelected: (FilterOption filterOption) {
              setState(() => filterOption == FilterOption.FAVOURITES
                  ? _showOnlyFavourites = true
                  : _showOnlyFavourites = false);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(showOnlyFavourites: _showOnlyFavourites),
    );
  }
}
