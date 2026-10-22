import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Cart cubit.dart';
import 'Favorite button.dart';
import 'appTheme.dart';
import 'product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _qty = 1;

  ProductModel get p => widget.product;

  Widget _circleButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon, color: color ?? AppColors.ink, size: 20),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon,
            size: 20,
            color: onTap == null ? Colors.grey.shade400 : AppColors.primary),
      ),
    );
  }

  void _addToCart() {
    final ok = context.read<CartCubit>().add(p, qty: _qty);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(ok
            ? '$_qty × ${p.name} added to cart'
            : 'Only ${p.stock} in stock'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = p.imageUrl != null && p.imageUrl!.isNotEmpty;
    final total = p.price * _qty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: _circleButton(
                Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: FavoriteButton(product: p, size: 20, padding: 8),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-image-${p.id}',
                child: Container(
                  color: Colors.grey.shade100,
                  child: hasImage
                      ? Image.network(
                    p.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          size: 80, color: AppColors.muted),
                    ),
                  )
                      : const Center(
                    child: Icon(Icons.inventory_2_outlined,
                        size: 80, color: AppColors.muted),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: Container(
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.category!.name,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${p.price.toStringAsFixed(2)} EGP',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (p.inStock
                              ? AppColors.success
                              : AppColors.danger)
                              .withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          p.inStock ? 'In stock (${p.stock})' : 'Out of stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: p.inStock
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (p.description == null || p.description!.isEmpty)
                              ? 'No description available.'
                              : p.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        _InfoRow(Icons.local_shipping_outlined,
                            'Fast delivery across Egypt'),
                        SizedBox(height: 12),
                        _InfoRow(
                            Icons.verified_user_outlined, 'Secure payment'),
                        SizedBox(height: 12),
                        _InfoRow(Icons.refresh_rounded, 'Easy returns'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
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
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _qtyButton(Icons.remove_rounded,
                      _qty > 1 ? () => setState(() => _qty--) : null),
                  SizedBox(
                    width: 28,
                    child: Text('$_qty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  _qtyButton(Icons.add_rounded,
                      _qty < p.stock ? () => setState(() => _qty++) : null),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: p.inStock ? _addToCart : null,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(p.inStock
                    ? 'Add • ${total.toStringAsFixed(2)} EGP'
                    : 'Out of stock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Text(text,
            style: const TextStyle(fontSize: 14, color: AppColors.ink)),
      ],
    );
  }
}