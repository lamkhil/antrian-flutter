import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/app_user.dart';

/// Create page of [UserResource].
/// Filament: `Pages\CreateUser extends CreateRecord`.
class CreateUser extends StatelessWidget {
  final Resource<AppUser> resource;
  const CreateUser({super.key, required this.resource});

  /// Filament: `CreateUser::route('/create')`.
  static ResourcePage<AppUser> route() => ResourcePage.create<AppUser>(
        builder: (ctx, state, r) => CreateUser(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      CreateRecordPage<AppUser>(resource: resource);
}
