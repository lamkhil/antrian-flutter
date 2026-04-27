import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/app_user.dart';

/// List page of [UserResource].
/// Filament: `Pages\ListUsers extends ListRecords`.
class ListUsers extends StatelessWidget {
  final Resource<AppUser> resource;
  const ListUsers({super.key, required this.resource});

  /// Filament: `ListUsers::route('/')`.
  static ResourcePage<AppUser> route() => ResourcePage.list<AppUser>(
        builder: (ctx, state, r) => ListUsers(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      ListRecordsPage<AppUser>(resource: resource);
}
