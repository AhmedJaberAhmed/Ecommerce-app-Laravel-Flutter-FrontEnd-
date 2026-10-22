import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_database.dart';
import 'cart_item.dart';
import 'product_model.dart';

export 'cart_item.dart'; // so CartPage can see CartItem via this import

class CartState {
  final List<CartItem> items;
  const CartState({this.items = const []});

  bool get isEmpty => items.isEmpty;
  int get count => items.fold(0, (sum, i) => sum + i.qty);
  double get total => items.fold(0.0, (sum, i) => sum + i.lineTotal);
}

class CartCubit extends Cubit<CartState> {
  final CartDatabase _db;

  CartCubit({CartDatabase? db})
      : _db = db ?? CartDatabase.instance,
        super(const CartState()) {
    load();
  }

  Future<void> load() async {
    emit(CartState(items: await _db.getItems()));
  }

  /// Returns false if the requested quantity exceeds stock.
  bool add(ProductModel product, {int qty = 1}) {
    final items = [...state.items];
    final index = items.indexWhere((i) => i.product.id == product.id);
    final current = index == -1 ? 0 : items[index].qty;

    if (current + qty > product.stock) return false;

    final item = CartItem(product: product, qty: current + qty);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }

    emit(CartState(items: items));
    _db.upsert(item);
    return true;
  }

  void increment(int productId) {
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;
    final item = state.items[index];
    if (item.qty >= item.product.stock) return;
    _update(index, item.copyWith(qty: item.qty + 1));
  }

  void decrement(int productId) {
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;
    final item = state.items[index];
    if (item.qty <= 1) {
      remove(productId);
    } else {
      _update(index, item.copyWith(qty: item.qty - 1));
    }
  }

  void remove(int productId) {
    emit(CartState(
      items: state.items.where((i) => i.product.id != productId).toList(),
    ));
    _db.delete(productId);
  }

  void clear() {
    emit(const CartState());
    _db.clear();
  }

  void _update(int index, CartItem item) {
    final items = [...state.items]..[index] = item;
    emit(CartState(items: items));
    _db.upsert(item);
  }
}