import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/zone-setting/bindings/zone_setting_binding.dart';
import '../modules/zone-setting/views/zone_setting_view.dart';
import '../modules/zone/bindings/zone_binding.dart';
import '../modules/zone/views/zone_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ZONE;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ZONE,
      page: () => const ZoneView(),
      binding: ZoneBinding(),
    ),
    GetPage(
      name: _Paths.ZONE_SETTING,
      page: () => const ZoneSettingView(),
      binding: ZoneSettingBinding(),
    ),
  ];
}
