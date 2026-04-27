import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/zone.dart';

/// Filament: `Pages\ListZones extends ListRecords`.
class ListZones extends StatelessWidget {
  final Resource<Zone> resource;
  const ListZones({super.key, required this.resource});

  static ResourcePage<Zone> route() => ResourcePage.list<Zone>(
        builder: (ctx, state, r) => ListZones(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      ListRecordsPage<Zone>(resource: resource);
}
