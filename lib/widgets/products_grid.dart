import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavourites;

  ProductsGrid({@required this.showOnlyFavourites});

  @override
  Widget build(BuildContext context) {
    final _productsProvider = Provider.of<ProductsProvider>(context);
    final _products = showOnlyFavourites
        ? _productsProvider.favouriteProducts
        : _productsProvider.products;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: _products.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: _products[index],
        child: ProductItem(),
      ),
    );
  }
}
