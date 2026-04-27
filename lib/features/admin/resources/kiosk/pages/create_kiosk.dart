import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/kiosk.dart';

/// Filament: `Pages\CreateKiosk extends CreateRecord`.
class CreateKiosk extends StatelessWidget {
  final Resource<Kiosk> resource;
  const CreateKiosk({super.key, required this.resource});

  static ResourcePage<Kiosk> route() => ResourcePage.create<Kiosk>(
        builder: (ctx, state, r) => CreateKiosk(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      CreateRecordPage<Kiosk>(resource: resource);
}
