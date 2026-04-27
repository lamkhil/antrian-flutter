import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/app_user.dart';

/// View page of [UserResource].
/// Filament: `Pages\ViewUser extends ViewRecord`.
class ViewUser extends StatelessWidget {
  final Resource<AppUser> resource;
  final String recordId;
  const ViewUser({
    super.key,
    required this.resource,
    required this.recordId,
  });

  /// Filament: `ViewUser::route('/{record}')`.
  static ResourcePage<AppUser> route() => ResourcePage.view<AppUser>(
        builder: (ctx, state, r) => ViewUser(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      ViewRecordPage<AppUser>(resource: resource, recordId: recordId);
}
