import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/counter.dart';

/// Filament: `Pages\EditCounter extends EditRecord`.
class EditCounter extends StatelessWidget {
  final Resource<Counter> resource;
  final String recordId;
  const EditCounter({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<Counter> route() => ResourcePage.edit<Counter>(
        builder: (ctx, state, r) => EditCounter(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      EditRecordPage<Counter>(resource: resource, recordId: recordId);
}
