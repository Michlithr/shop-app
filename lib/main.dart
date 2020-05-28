import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/products_overview_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/product/user_products_screen.dart';
import 'screens/product/edit_product_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/order/orders_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          update: (
            ctx,
            auth,
            prevProducts,
          ) =>
              ProductsProvider(auth.token, auth.userId,
                  prevProducts == null ? [] : prevProducts.products),
        ),
        ChangeNotifierProvider.value(value: CartProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          update: (
            ctx,
            auth,
            prevProducts,
          ) =>
              OrdersProvider(auth.token, auth.userId),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.deepOrange,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.ROUTE_NAME: (ctx) => ProductDetailScreen(),
            CartScreen.ROUTE_NAME: (ctx) => CartScreen(),
            OrdersScreen.ROUTE_NAME: (ctx) => OrdersScreen(),
            UserProductsScreen.ROUTE_NAME: (ctx) => UserProductsScreen(),
            EditProductScreen.ROUTE_NAME: (ctx) => EditProductScreen(),
            ProductsOverviewScreen.ROUTE_NAME: (ctx) =>
                ProductsOverviewScreen(),
          },
        ),
      ),
    );
  }
}
