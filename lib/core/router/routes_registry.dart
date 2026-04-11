import 'package:go_router/go_router.dart';

/// mason:imports
import '../../features/home/home_route.dart';
import '../../features/login/login_route.dart';

final List<GoRoute> appRoutes = [
  /// mason:routes
  homeRoute,
  loginRoute,
];
