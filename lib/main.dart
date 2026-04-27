import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/router.dart';
import 'data/ai_voice_settings_service.dart';
import 'data/lookup_cache.dart';
import 'features/admin/admin_panel.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  await LookupCache.instance.init();
  await AiVoiceSettingsService.instance.ensureExists();
  runApp(const ProviderScope(child: AntrianApp()));
}

class AntrianApp extends ConsumerWidget {
  const AntrianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Antrian Admin',
      debugShowCheckedModeBanner: false,
      theme: adminPanel.theme.toThemeData(),
      routerConfig: router,
    );
  }
}
