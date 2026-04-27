import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/app_user.dart';

/// Edit page of [UserResource].
/// Filament: `Pages\EditUser extends EditRecord`.
class EditUser extends StatelessWidget {
  final Resource<AppUser> resource;
  final String recordId;
  const EditUser({
    super.key,
    required this.resource,
    required this.recordId,
  });

  /// Filament: `EditUser::route('/{record}/edit')`.
  static ResourcePage<AppUser> route() => ResourcePage.edit<AppUser>(
        builder: (ctx, state, r) => EditUser(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      EditRecordPage<AppUser>(resource: resource, recordId: recordId);
}
