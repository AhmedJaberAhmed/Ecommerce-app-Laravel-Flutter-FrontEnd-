
import 'package:dio/dio.dart';

import 'TokenStorage.dart';
import 'auth_remote_data_source.dart';
import 'cart_item.dart';

class CheckoutSession {
  final int orderId;
  final String? checkoutUrl;

  const CheckoutSession(this.orderId, this.checkoutUrl);
}

class CheckoutRepository {
  final TokenStorage _tokens = TokenStorage();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthRemoteDataSourceImpl.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<Options> _auth() async {
    final token = await _tokens.read();

    if (token == null || token.isEmpty) {
      throw Exception('Please log in before checkout');
    }

    return Options(
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<CheckoutSession> createCheckout({
    required String paymentMethod,
    required String phone,
    required String address,
    required String city,
    required List<CartItem> items,
  }) async {
    try {
      final res = await _dio.post(
        '/checkout',
        data: {
          'payment_method': paymentMethod,
          'phone': phone,
          'address': address,
          'city': city,
          'items': [
            for (final item in items)
              {
                'product_id': item.product.id,
                'qty': item.qty,
              },
          ],
        },
        options: await _auth(),
      );

      return CheckoutSession(
        (res.data['order_id'] as num).toInt(),
        res.data['checkout_url'] as String?,
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;

      throw Exception(message ?? 'Could not place order');
    }
  }

  Future<String> orderStatus(int orderId) async {
    final res = await _dio.get(
      '/orders/$orderId',
      options: await _auth(),
    );

    return res.data['status'] as String;
  }
}
