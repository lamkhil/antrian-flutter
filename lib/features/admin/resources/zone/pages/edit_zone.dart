import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/zone.dart';

/// Filament: `Pages\EditZone extends EditRecord`.
class EditZone extends StatelessWidget {
  final Resource<Zone> resource;
  final String recordId;
  const EditZone({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<Zone> route() => ResourcePage.edit<Zone>(
        builder: (ctx, state, r) => EditZone(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      EditRecordPage<Zone>(resource: resource, recordId: recordId);
}
