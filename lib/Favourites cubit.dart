import 'package:flutter_bloc/flutter_bloc.dart';

import 'FavoritesDatabase.dart';
import 'product_model.dart';

class FavoritesState {
  final List<ProductModel> items;
  final bool loading;

  const FavoritesState({this.items = const [], this.loading = false});

  bool isFavorite(int id) => items.any((p) => p.id == id);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesDatabase _db;

  FavoritesCubit({FavoritesDatabase? db})
      : _db = db ?? FavoritesDatabase.instance,
        super(const FavoritesState(loading: true)) {
    load();
  }

  Future<void> load() async {
    try {
      emit(FavoritesState(items: await _db.getAll()));
    } catch (_) {
      emit(const FavoritesState());
    }
  }

  Future<void> toggle(ProductModel product) async {
    final exists = state.isFavorite(product.id);

    // Update the UI immediately, then persist.
    emit(FavoritesState(
      items: exists
          ? state.items.where((p) => p.id != product.id).toList()
          : [product, ...state.items],
    ));

    try {
      exists ? await _db.remove(product.id) : await _db.insert(product);
    } catch (_) {
      await load(); // resync with the database if the write failed
    }
  }

  Future<void> remove(int id) async {
    emit(FavoritesState(items: state.items.where((p) => p.id != id).toList()));
    try {
      await _db.remove(id);
    } catch (_) {
      await load();
    }
  }
}