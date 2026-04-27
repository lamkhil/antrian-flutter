import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:go_router/go_router.dart';

import 'resources/ai_voice/ai_voice_resource.dart';
import 'resources/counter/counter_resource.dart';
import 'resources/kiosk/kiosk_resource.dart';
import 'resources/service/service_resource.dart';
import 'resources/user/user_resource.dart';
import 'resources/zone/zone_resource.dart';

final adminPanel = Panel(
  id: 'admin',
  path: '/admin',
  brandName: 'Antrian Admin',
  theme: const FilamentTheme(colors: FilamentColors.indigo),
  resources: [
    UserResource(),
    CounterResource(),
    ServiceResource(),
    ZoneResource(),
    KioskResource(),
    AiVoiceResource(),
  ],
  sidebarFooter: const _AdminSidebarFooter(),
);

class _AdminSidebarFooter extends StatelessWidget {
  const _AdminSidebarFooter();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            child: Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Admin',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout, size: 18),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
