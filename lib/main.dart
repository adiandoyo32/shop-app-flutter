import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_maxi/providers/auth.dart';
import 'package:shop_app_maxi/providers/cart.dart';
import 'package:shop_app_maxi/providers/orders.dart';
import 'package:shop_app_maxi/screens/auth_screen.dart';
import 'package:shop_app_maxi/screens/cart_screen.dart';
import 'package:shop_app_maxi/screens/edit_product_screen.dart';
import 'package:shop_app_maxi/screens/orders_screen.dart';

import 'package:shop_app_maxi/screens/product_detail_screen.dart';
import 'package:shop_app_maxi/screens/product_overview_screen.dart';
import 'package:shop_app_maxi/screens/splash_screen.dart';
import 'package:shop_app_maxi/screens/user_products_screen.dart';
import 'providers/products.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (_, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.products),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (_, auth, previousOrders) => Orders(auth.token, auth.userId,
              previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
