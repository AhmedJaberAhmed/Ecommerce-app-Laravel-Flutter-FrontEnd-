
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Cart cubit.dart';
import 'appTheme.dart';
import 'cart_item.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My cart'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) => state.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
              onPressed: () =>
                  context.read<CartCubit>().clear(),
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.primaryLight,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add products to see them here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _CartTile(item: state.items[i]),
                ),
              ),
              _Summary(state: state),
            ],
          );
        },
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;

  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final hasImage =
        p.imageUrl != null && p.imageUrl!.isNotEmpty;
    final cubit = context.read<CartCubit>();

    return Dismissible(
      key: ValueKey('cart-${p.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cubit.remove(p.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade100,
                child: hasImage
                    ? Image.network(
                  p.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.muted,
                  ),
                )
                    : const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.muted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.lineTotal.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _qtyBtn(
                        Icons.remove_rounded,
                            () => cubit.decrement(p.id),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${item.qty}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _qtyBtn(
                        Icons.add_rounded,
                        item.qty < p.stock
                            ? () => cubit.increment(p.id)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.muted,
              ),
              onPressed: () => cubit.remove(p.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(
      IconData icon,
      VoidCallback? onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? Colors.grey.shade400
              : AppColors.primary,
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final CartState state;

  const _Summary({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Items (${state.count})',
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const CheckoutPage(),
                  ),
                );
              },
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}
