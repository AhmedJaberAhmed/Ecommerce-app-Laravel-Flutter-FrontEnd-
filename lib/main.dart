import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Cart cubit.dart';
import 'Favourites cubit.dart';
import 'authGate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoritesCubit>(create: (_) => FavoritesCubit()),
        BlocProvider<CartCubit>(create: (_) => CartCubit()),
      ],
      child: MaterialApp(
        title: 'Auth Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

class AppColors {
  static const primary = Color(0xFFFF6B00);
  static const primaryDark = Color(0xFFE85500);
  static const primaryLight = Color(0xFFFF9A3D);
  static const ink = Color(0xFF1B1B2F);
  static const muted = Color(0xFF7A7A8C);
  static const background = Color(0xFFF5F5F8);
  static const success = Color(0xFF1FA463);
  static const danger = Color(0xFFE53935);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      brightness: Brightness.light,
    );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: AppColors.muted,
        border: border(Colors.grey.shade300),
        enabledBorder: border(Colors.grey.shade300),
        focusedBorder: border(AppColors.primary, 1.8),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.8),
        disabledBorder: border(Colors.grey.shade200),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Orange gradient header shared by Login and Register.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 56, 24, 40),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(46),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14),
          ),
        ],
      ),
    );
  }
}