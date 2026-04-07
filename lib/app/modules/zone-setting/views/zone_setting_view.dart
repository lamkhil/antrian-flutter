import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/zone_setting_controller.dart';

class ZoneSettingView extends GetView<ZoneSettingController> {
  const ZoneSettingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZoneSettingView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ZoneSettingView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
