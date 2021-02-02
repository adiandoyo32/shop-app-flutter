import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app_maxi/models/http_exception.dart';
import 'package:shop_app_maxi/models/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A Red Shirt --',
    //   price: 29.99,
    //   imageUrl: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
    // ),
    // Product(
    //     id: 'p2',
    //     title: "Mens Casual Premium Slim Fit T-Shirts ",
    //     price: 22.3,
    //     description:
    //         "Slim-fitting style, contrast raglan long sleeve, three-button henley placket, light weight & soft fabric for breathable and comfortable wearing. And Solid stitched shirts with round neck made for durability and a great fit for casual fashion wear and diehard baseball fans. The Henley style round neckline includes a three-button placket.",
    //     imageUrl:
    //         "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg"),
  ];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._products);

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return _products.where((element) => element.isFavorite).toList();
  }

  Product findProduct(id) {
    return _products.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://adia-26822.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            imageUrl: value['imageUrl'],
            price: value['price'],
            isFavorite: value['isFavorite'],
          ),
        );
      });
      _products = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw HttpException('error');
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://adia-26822.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _products.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://adia-26822.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: jsonEncode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            },
          ));
      _products[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://adia-26822.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _products.indexWhere((prod) => prod.id == id);
    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
