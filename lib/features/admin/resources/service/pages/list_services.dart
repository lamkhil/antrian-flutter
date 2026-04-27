import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/service.dart';

/// Filament: `Pages\ListServices extends ListRecords`.
class ListServices extends StatelessWidget {
  final Resource<Service> resource;
  const ListServices({super.key, required this.resource});

  static ResourcePage<Service> route() => ResourcePage.list<Service>(
        builder: (ctx, state, r) => ListServices(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      ListRecordsPage<Service>(resource: resource);
}
