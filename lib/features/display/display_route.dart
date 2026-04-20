import 'package:go_router/go_router.dart';
import 'presentation/display_page.dart';

GoRoute displayRoute = GoRoute(
  path: '/display/:zonaId',
  name: 'display',
  builder: (context, state) {
    final zonaId = state.pathParameters['zonaId']!;
    return DisplayPage(zonaId: zonaId);
  },
);
