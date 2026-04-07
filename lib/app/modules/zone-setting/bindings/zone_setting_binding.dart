import 'package:get/get.dart';

import '../controllers/zone_setting_controller.dart';

class ZoneSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZoneSettingController>(
      () => ZoneSettingController(),
    );
  }
}
