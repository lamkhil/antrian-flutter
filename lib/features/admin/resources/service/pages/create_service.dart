import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/service.dart';

/// Filament: `Pages\CreateService extends CreateRecord`.
class CreateService extends StatelessWidget {
  final Resource<Service> resource;
  const CreateService({super.key, required this.resource});

  static ResourcePage<Service> route() => ResourcePage.create<Service>(
        builder: (ctx, state, r) => CreateService(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      CreateRecordPage<Service>(resource: resource);
}
