
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Cart cubit.dart';
import 'appTheme.dart';
import 'checkout_repository.dart';

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

  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _showSuccess(int orderId) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 56,
        ),
        title: const Text('Order placed successfully'),
        content: Text(
          'Your order #$orderId has been confirmed.\n\n'
              'Payment method: Cash on Delivery.\n'
              'Pay in cash when your order arrives.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _submit() async {
    if (_busy) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cart = context.read<CartCubit>();

    if (cart.state.isEmpty) {
      _snack('Your cart is empty');
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final session = await _repo.createCheckout(
        paymentMethod: 'cod',
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        items: List.of(cart.state.items),
      );

      if (!mounted) return;

      // Verify the order status from Laravel.
      final status = await _repo.orderStatus(session.orderId);

      if (!mounted) return;

      if (status == 'confirmed') {
        cart.clear();
        await _showSuccess(session.orderId);
      } else {
        _snack(
          'Order #${session.orderId} was created '
              'but is not confirmed yet. Check your orders.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _snack(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CartCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Delivery details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: '01012345678',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (_required(value, 'Phone') != null) {
                    return 'Phone is required';
                  }

                  if (value!.trim().length < 10) {
                    return 'Enter a valid phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // City
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Cairo',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: (value) =>
                    _required(value, 'City'),
              ),

              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: _address,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                  hintText: 'Street, building, apartment',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) =>
                    _required(value, 'Address'),
              ),

              const SizedBox(height: 24),

              const Text(
                'Payment method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),

              const SizedBox(height: 12),

              // Cash on Delivery
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash on Delivery',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pay in cash when your order arrives',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.radio_button_checked_rounded,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Order summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      'Total (${state.count} items)',
                      style: const TextStyle(
                        color: AppColors.muted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${state.total.toStringAsFixed(2)} EGP',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Place order
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy || state.isEmpty
                      ? null
                      : _submit,
                  icon: _busy
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _busy
                        ? 'Placing order...'
                        : 'Place order',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
