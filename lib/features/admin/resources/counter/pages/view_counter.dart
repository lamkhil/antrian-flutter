import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/counter.dart';

/// Filament: `Pages\ViewCounter extends ViewRecord`.
class ViewCounter extends StatelessWidget {
  final Resource<Counter> resource;
  final String recordId;
  const ViewCounter({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<Counter> route() => ResourcePage.view<Counter>(
        builder: (ctx, state, r) => ViewCounter(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      ViewRecordPage<Counter>(resource: resource, recordId: recordId);
}
