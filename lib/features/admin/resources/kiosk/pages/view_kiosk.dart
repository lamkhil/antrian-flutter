import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/kiosk.dart';

/// Filament: `Pages\ViewKiosk extends ViewRecord`.
class ViewKiosk extends StatelessWidget {
  final Resource<Kiosk> resource;
  final String recordId;
  const ViewKiosk({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<Kiosk> route() => ResourcePage.view<Kiosk>(
        builder: (ctx, state, r) => ViewKiosk(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      ViewRecordPage<Kiosk>(resource: resource, recordId: recordId);
}
