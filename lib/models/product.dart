import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app_maxi/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id, title, description, imageUrl;
  final double price;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://adia-26822.firebaseio.com/products/$id.json?auth=$token';
    try {
      final response = await http.patch(
        url,
        body: jsonEncode(
          {'isFavorite': isFavorite},
        ),
      );
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  @override
  String toString() =>
      'Product { id: $id, title: $title, description: $description }';

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
