import 'package:flutter_bloc/flutter_bloc.dart';

import 'category_model.dart';
import 'product_model.dart';
import 'product_repository.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  final bool loadingMore;

  ProductsLoaded(this.products, {this.loadingMore = false});
}

class ProductsError extends ProductsState {
  final String message;

  ProductsError(this.message);
}

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository repository;

  ProductsCubit(this.repository) : super(ProductsInitial());

  String _search = '';
  int? _categoryId;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;
  int? get selectedCategoryId => _categoryId;

  /// First load (also used by the refresh button).
  Future<void> getProducts() async {
    emit(ProductsLoading());
    try {
      _categories = await repository.getCategories();
      await _loadFirstPage();
    } catch (e) {
      if (isClosed) return;
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> search(String query) async {
    _search = query.trim();
    await _reload();
  }

  Future<void> selectCategory(int? id) async {
    _categoryId = id;
    await _reload();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _loadingMore || state is! ProductsLoaded) return;
    _loadingMore = true;
    emit(ProductsLoaded(List.of(_products), loadingMore: true));

    try {
      final result = await repository.getProducts(
        page: _page + 1,
        search: _search,
        categoryId: _categoryId,
      );
      if (isClosed) return;
      _page = result.currentPage;
      _hasMore = result.currentPage < result.lastPage;
      _products = [..._products, ...result.products];
    } catch (_) {
      // Keep what we already have if loading more fails.
    }

    _loadingMore = false;
    if (isClosed) return;
    emit(ProductsLoaded(List.of(_products)));
  }

  Future<void> _reload() async {
    emit(ProductsLoading());
    try {
      await _loadFirstPage();
    } catch (e) {
      if (isClosed) return;
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _loadFirstPage() async {
    final result = await repository.getProducts(
      page: 1,
      search: _search,
      categoryId: _categoryId,
    );
    if (isClosed) return;
    _page = 1;
    _hasMore = result.currentPage < result.lastPage;
    _loadingMore = false;
    _products = result.products;
    emit(ProductsLoaded(List.of(_products)));
  }
}