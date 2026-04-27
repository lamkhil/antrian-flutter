import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/service.dart';

/// Filament: `Pages\EditService extends EditRecord`.
class EditService extends StatelessWidget {
  final Resource<Service> resource;
  final String recordId;
  const EditService({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<Service> route() => ResourcePage.edit<Service>(
        builder: (ctx, state, r) => EditService(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      EditRecordPage<Service>(resource: resource, recordId: recordId);
}
