import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_maxi/providers/products.dart';
import 'package:shop_app_maxi/screens/edit_product_screen.dart';
import 'package:shop_app_maxi/widgets/app_drawer.dart';
import 'package:shop_app_maxi/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = 'user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (context, productsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productsData.products.length,
                          itemBuilder: (_, index) => Column(
                            children: [
                              UserProductItem(
                                productsData.products[index].id,
                                productsData.products[index].title,
                                productsData.products[index].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
