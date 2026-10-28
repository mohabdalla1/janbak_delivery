import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/presentation/screens/customer_screen.dart';
import '../../features/driver/presentation/screens/driver_screen.dart';
import '../../features/merchant/presentation/screens/merchant_screen.dart';
import '../../features/merchant/presentation/screens/merchant_products_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/customer',
        name: 'customer',
        builder: (context, state) => const CustomerScreen(),
      ),
      GoRoute(
        path: '/driver',
        name: 'driver',
        builder: (context, state) => const DriverScreen(),
      ),
      GoRoute(
        path: '/merchant',
        name: 'merchant',
        builder: (context, state) => const MerchantScreen(),
        routes: [
          GoRoute(
            path: 'products',
            name: 'merchant_products',
            builder: (context, state) {
              final merchantId = state.uri.queryParameters['merchantId'] ?? '';
              return MerchantProductsScreen(merchantId: merchantId);
            },
          ),
        ],
      ),
    ],
  );
});