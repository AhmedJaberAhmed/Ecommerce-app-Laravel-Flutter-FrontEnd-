import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'Favorite button.dart';
import 'Favourites cubit.dart';
import 'Productdetailspage.dart';
import 'appTheme.dart';
import 'product_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My favourites')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border_rounded,
                        size: 80, color: AppColors.primaryLight),
                    SizedBox(height: 16),
                    Text(
                      'No favourites yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the heart on any product to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _FavoriteTile(product: state.items[i]),
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final ProductModel product;

  const _FavoriteTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 92,
                  height: 92,
                  color: Colors.grey.shade100,
                  child: hasImage
                      ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.muted),
                  )
                      : const Icon(Icons.inventory_2_outlined,
                      color: AppColors.muted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.category != null)
                      Text(product.category!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${product.price.toStringAsFixed(2)} EGP',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      product.inStock
                          ? 'In stock (${product.stock})'
                          : 'Out of stock',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: product.inStock
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              FavoriteButton(product: product, size: 22, padding: 8),
            ],
          ),
        ),
      ),
    );
  }
}