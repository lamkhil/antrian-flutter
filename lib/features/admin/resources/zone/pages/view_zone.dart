import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/zone.dart';

/// Filament: `Pages\ViewZone extends ViewRecord`.
class ViewZone extends StatelessWidget {
  final Resource<Zone> resource;
  final String recordId;
  const ViewZone({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<Zone> route() => ResourcePage.view<Zone>(
        builder: (ctx, state, r) => ViewZone(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      ViewRecordPage<Zone>(resource: resource, recordId: recordId);
}
