import 'package:get/get.dart';

import '../controllers/zone_controller.dart';

class ZoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZoneController>(
      () => ZoneController(),
    );
  }
}
