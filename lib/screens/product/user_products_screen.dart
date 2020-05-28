import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/products_provider.dart';
import '../../screens/product/edit_product_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const ROUTE_NAME = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your products'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.of(context)
                  .pushNamed(EditProductScreen.ROUTE_NAME)),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductsProvider>(
                      builder: (ctx, productsProvider, child) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productsProvider.products.length,
                          itemBuilder: (_, index) => Column(children: [
                            UserProductItem(
                              id: productsProvider.products[index].id,
                              title: productsProvider.products[index].title,
                              imgUrl: productsProvider.products[index].imageUrl,
                              deleteItem: productsProvider.deleteProduct,
                            ),
                            Divider(),
                          ]),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
