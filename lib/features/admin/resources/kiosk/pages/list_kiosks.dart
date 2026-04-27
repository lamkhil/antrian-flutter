import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/kiosk.dart';

/// Filament: `Pages\ListKiosks extends ListRecords`.
class ListKiosks extends StatelessWidget {
  final Resource<Kiosk> resource;
  const ListKiosks({super.key, required this.resource});

  static ResourcePage<Kiosk> route() => ResourcePage.list<Kiosk>(
        builder: (ctx, state, r) => ListKiosks(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      ListRecordsPage<Kiosk>(resource: resource);
}
