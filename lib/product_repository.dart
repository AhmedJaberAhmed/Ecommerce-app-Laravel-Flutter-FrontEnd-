import 'package:dio/dio.dart';

import 'TokenStorage.dart';
import 'app_exception.dart';
import 'auth_remote_data_source.dart';
import 'category_model.dart';
import 'product_model.dart';

class ProductsPage {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;

  const ProductsPage({
    required this.products,
    required this.currentPage,
    required this.lastPage,
  });
}

class ProductRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthRemoteDataSourceImpl.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );

  final TokenStorage _tokenStorage = TokenStorage();

  Future<Options> _authOptions() async {
    final token = await _tokenStorage.read();
    if (token == null || token.isEmpty) {
      throw const AppException('Please login first');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<ProductsPage> getProducts({
    int page = 1,
    String search = '',
    int? categoryId,
  }) async {
    final options = await _authOptions();
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          'page': page,
          'per_page': 10,
          if (search.isNotEmpty) 'search': search,
          if (categoryId != null) 'category_id': categoryId,
        },
        options: options,
      );

      final List<dynamic> list = response.data['data'];
      final meta = response.data['meta'];

      return ProductsPage(
        products: list
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        currentPage: int.parse('${meta?['current_page'] ?? 1}'),
        lastPage: int.parse('${meta?['last_page'] ?? 1}'),
      );
    } on DioException catch (e) {
      throw AppException(_messageFrom(e));
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    final options = await _authOptions();
    try {
      final response = await _dio.get('/categories', options: options);
      final List<dynamic> list = response.data['data'];
      return list
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw AppException(_messageFrom(e));
    }
  }

  String _messageFrom(DioException e) {
    if (e.response?.statusCode == 401) {
      return 'Session expired. Please logout and login again.';
    }
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Cannot reach the server. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}