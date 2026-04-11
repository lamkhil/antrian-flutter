import 'package:go_router/go_router.dart';
import 'presentation/home_page.dart';

GoRoute homeRoute = GoRoute(
  path: '/',
  name: 'home',
  builder: (context, state) => const HomePage(),
);
