import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/zone.dart';

/// Filament: `Pages\CreateZone extends CreateRecord`.
class CreateZone extends StatelessWidget {
  final Resource<Zone> resource;
  const CreateZone({super.key, required this.resource});

  static ResourcePage<Zone> route() => ResourcePage.create<Zone>(
        builder: (ctx, state, r) => CreateZone(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      CreateRecordPage<Zone>(resource: resource);
}
