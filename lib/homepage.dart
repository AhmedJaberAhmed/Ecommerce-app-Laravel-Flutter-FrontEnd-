import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'Cart cubit.dart';
import 'Cart page.dart';
import 'Favorite button.dart';
import 'Favourites cubit.dart';
import 'FavoritesPage.dart';
import 'LoginPage.dart';
import 'Productdetailspage.dart';
import 'TokenStorage.dart';
import 'appTheme.dart';
import 'auth_remote_data_source.dart';
import 'product_model.dart';
import 'product_repository.dart';
import 'products_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit(ProductRepository())..getProducts(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TokenStorage _tokens = TokenStorage();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthRemoteDataSourceImpl.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  late Future<Map<String, dynamic>> _user;

  @override
  void initState() {
    super.initState();
    _user = _loadUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  Future<Map<String, dynamic>> _loadUser() async {
    final token = await _tokens.read();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await _dio.get(
      '/user',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<void> _refresh() async {
    setState(() {
      _user = _loadUser();
    });

    await context.read<ProductsCubit>().getProducts();
  }

  Future<void> _logout() async {
    try {
      final token = await _tokens.read();

      if (token != null) {
        await _dio.post(
          '/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Logout locally even if the server request fails.
    }

    await _tokens.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
    );
  }

  Widget _headerButton(
      IconData icon,
      String tooltip,
      VoidCallback onTap, {
        int badge = 0,
      }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(46),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Badge(
          isLabelVisible: badge > 0,
          label: Text('$badge'),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _user,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Text('Loading...',
                          style: TextStyle(color: Colors.white.withAlpha(200)));
                    }
                    if (snapshot.hasError) {
                      return const Text(
                        'Welcome 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }
                    final user = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user['name']} 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${user['email']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withAlpha(210),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _headerButton(Icons.refresh_rounded, 'Refresh products', _refresh),
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) => _headerButton(
                  Icons.favorite_rounded,
                  'Favourites',
                      () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FavoritesPage()),
                  ),
                  badge: state.items.length,
                ),
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) => _headerButton(
                  Icons.shopping_cart_rounded,
                  'Cart',
                      () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  ),
                  badge: state.count,
                ),
              ),
              _headerButton(Icons.logout_rounded, 'Logout', _logout),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onSubmitted: (value) => context.read<ProductsCubit>().search(value),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                  context.read<ProductsCubit>().search('');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),

          // Category pills
          BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              final cubit = context.read<ProductsCubit>();
              if (cubit.categories.isEmpty) return const SizedBox(height: 8);

              return SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    _pill('All', cubit.selectedCategoryId == null,
                            () => cubit.selectCategory(null)),
                    for (final c in cubit.categories)
                      _pill(c.name, cubit.selectedCategoryId == c.id,
                              () => cubit.selectCategory(c.id)),
                  ],
                ),
              );
            },
          ),

          // Products from Laravel API
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is ProductsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded,
                              size: 56, color: AppColors.muted),
                          const SizedBox(height: 12),
                          Text(state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.muted)),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(160, 48),
                            ),
                            onPressed: () =>
                                context.read<ProductsCubit>().getProducts(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ProductsLoaded) {
                  final products = state.products;

                  if (products.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 56, color: AppColors.muted),
                          SizedBox(height: 8),
                          Text('No products found',
                              style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Row(
                          children: [
                            const Text(
                              'Popular products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const Spacer(),
                            Text('${products.length} items',
                                style:
                                const TextStyle(color: AppColors.muted)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 230,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            mainAxisExtent: 300,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsPage(product: product),
                                ),
                              ),
                              child: ProductCard(product: product),
                            );
                          },
                        ),
                      ),
                      if (state.loadingMore)
                        const LinearProgressIndicator(
                            color: AppColors.primary),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'product-image-${product.id}',
                  child: Container(
                    color: Colors.grey.shade100,
                    child: hasImage
                        ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: AppColors.muted,
                          ),
                        );
                      },
                    )
                        : const Center(
                      child: Icon(Icons.inventory_2_outlined,
                          size: 50, color: AppColors.muted),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(product: product),
                ),
                if (!product.inStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Sold out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.category != null)
                  Text(
                    product.category!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.description ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(2)} EGP',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    Material(
                      color: product.inStock
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
    onTap: product.inStock
    ? () {
    final ok = context.read<CartCubit>().add(product);
    ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
    duration: const Duration(seconds: 1),
    content: Text(ok
    ? '${product.name} added to cart'
        : 'Only ${product.stock} in stock'),
    ));
    }

                            : null,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.add_shopping_cart_rounded,
                              size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}