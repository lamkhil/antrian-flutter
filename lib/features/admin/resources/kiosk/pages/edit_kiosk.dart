import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/kiosk.dart';

/// Filament: `Pages\EditKiosk extends EditRecord`.
class EditKiosk extends StatelessWidget {
  final Resource<Kiosk> resource;
  final String recordId;
  const EditKiosk({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<Kiosk> route() => ResourcePage.edit<Kiosk>(
        builder: (ctx, state, r) => EditKiosk(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      EditRecordPage<Kiosk>(resource: resource, recordId: recordId);
}
