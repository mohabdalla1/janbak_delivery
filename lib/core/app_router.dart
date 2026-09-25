import 'package:flutter/material.dart';
import '../features/auth/auth_screen.dart';
import '../features/customer/customer_view.dart';
import '../features/driver/driver_view.dart';
import '../features/merchant/merchant_view.dart';

class AppRouter {
  static const String auth = '/auth';
  static const String customer = '/customer';
  static const String driver = '/driver';
  static const String merchant = '/merchant';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case customer:
        return MaterialPageRoute(builder: (_) => const CustomerView());
      case driver:
        return MaterialPageRoute(builder: (_) => const DriverView());
      case merchant:
        return MaterialPageRoute(builder: (_) => const MerchantView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
