import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Cart cubit.dart';
import 'appTheme.dart';
import 'checkout_repository.dart';
import 'payment_webview_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _repo = CheckoutRepository();

  String _method = 'cod'; // 'cod' | 'card'
  bool _busy = false;

  bool get _isCod => _method == 'cod';

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showSuccess(int orderId, {required bool cod}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 56),
        title: Text(cod ? 'Order placed' : 'Payment successful'),
        content: Text(cod
            ? 'Your order #$orderId is confirmed. Pay in cash when it arrives.'
            : 'Your order #$orderId is confirmed.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartCubit>();
    setState(() => _busy = true);

    try {
      final session = await _repo.createCheckout(
        paymentMethod: _method,
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        items: cart.state.items,
      );
      if (!mounted) return;

      // ---- Cash on delivery: order is already confirmed ----
      if (_isCod || session.checkoutUrl == null) {
        cart.clear();
        await _showSuccess(session.orderId, cod: true);
        return;
      }

      // ---- Card: Paymob WebView ----
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PaymentWebViewPage(url: session.checkoutUrl!),
        ),
      );
      if (!mounted) return;

      final status = await _waitForStatus(session.orderId);
      if (!mounted) return;

      if (status == 'paid') {
        cart.clear();
        await _showSuccess(session.orderId, cod: false);
      } else if (status == 'failed') {
        _snack('Payment failed. You were not charged.');
      } else {
        _snack('Payment is still being confirmed. Check your orders shortly.');
      }
    } catch (e) {
      if (mounted) _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _waitForStatus(int orderId) async {
    var status = 'pending';
    for (var i = 0; i < 8; i++) {
      try {
        status = await _repo.orderStatus(orderId);
        if (status != 'pending') break;
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 2));
    }
    return status;
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  Widget _methodTile({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _method == value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _method = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppColors.ink)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CartCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Delivery details',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone (e.g. +201012345678)'),
                validator: (v) {
                  if (_required(v, 'Phone') != null) return 'Phone is required';
                  return v!.trim().length < 10 ? 'Enter a valid phone' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) => _required(v, 'City'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => _required(v, 'Address'),
              ),
              const SizedBox(height: 24),
              const Text('Payment method',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
              const SizedBox(height: 12),
              _methodTile(
                value: 'cod',
                icon: Icons.payments_outlined,
                title: 'Cash on delivery',
                subtitle: 'Pay in cash when your order arrives',
              ),
              const SizedBox(height: 10),
              _methodTile(
                value: 'card',
                icon: Icons.credit_card_rounded,
                title: 'Pay with card',
                subtitle: 'Secure online payment via Paymob',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text('Total (${state.count} items)',
                        style: const TextStyle(color: AppColors.muted)),
                    const Spacer(),
                    Text('${state.total.toStringAsFixed(2)} EGP',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _submit,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(_isCod
                          ? Icons.check_rounded
                          : Icons.lock_rounded),
                  label: Text(_busy
                      ? 'Please wait...'
                      : _isCod
                          ? 'Place order'
                          : 'Pay with card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}