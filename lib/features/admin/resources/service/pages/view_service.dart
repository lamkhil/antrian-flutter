import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/service.dart';

/// Filament: `Pages\ViewService extends ViewRecord`.
class ViewService extends StatelessWidget {
  final Resource<Service> resource;
  final String recordId;
  const ViewService({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<Service> route() => ResourcePage.view<Service>(
        builder: (ctx, state, r) => ViewService(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      ViewRecordPage<Service>(resource: resource, recordId: recordId);
}
