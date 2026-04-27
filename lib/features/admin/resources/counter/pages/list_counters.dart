import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/counter.dart';

/// Filament: `Pages\ListCounters extends ListRecords`.
class ListCounters extends StatelessWidget {
  final Resource<Counter> resource;
  const ListCounters({super.key, required this.resource});

  static ResourcePage<Counter> route() => ResourcePage.list<Counter>(
        builder: (ctx, state, r) => ListCounters(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      ListRecordsPage<Counter>(resource: resource);
}
