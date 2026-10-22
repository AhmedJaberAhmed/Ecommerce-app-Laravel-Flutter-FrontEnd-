import 'dart:convert';

import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final int qty;

  const CartItem({required this.product, required this.qty});

  double get lineTotal => product.price.toDouble() * qty;

  CartItem copyWith({ProductModel? product, int? qty}) =>
      CartItem(product: product ?? this.product, qty: qty ?? this.qty);

  Map<String, Object?> toMap() => {
    'product_id': product.id,
    'qty': qty,
    'product_json': jsonEncode(product.toJson()),
  };

  factory CartItem.fromMap(Map<String, Object?> m) => CartItem(
    product: ProductModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(m['product_json'] as String)),
    ),
    qty: m['qty'] as int,
  );
}