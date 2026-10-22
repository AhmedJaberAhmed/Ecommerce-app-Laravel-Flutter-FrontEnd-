import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'Favourites cubit.dart';
import 'appTheme.dart';
import 'product_model.dart';

/// Heart button that reads/writes FavoritesCubit. Reused on cards, details and lists.
class FavoriteButton extends StatelessWidget {
  final ProductModel product;
  final double size;
  final double padding;

  const FavoriteButton({
    super.key,
    required this.product,
    this.size = 18,
    this.padding = 6,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (s) => s.isFavorite(product.id),
      builder: (context, isFav) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.read<FavoritesCubit>().toggle(product);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                duration: const Duration(seconds: 1),
                content: Text(isFav
                    ? 'Removed from favourites'
                    : 'Added to favourites'),
              ));
          },
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(isFav),
                size: size,
                color: isFav ? Colors.red : AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}