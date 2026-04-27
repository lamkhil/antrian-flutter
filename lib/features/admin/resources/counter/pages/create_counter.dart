import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/counter.dart';

/// Filament: `Pages\CreateCounter extends CreateRecord`.
class CreateCounter extends StatelessWidget {
  final Resource<Counter> resource;
  const CreateCounter({super.key, required this.resource});

  static ResourcePage<Counter> route() => ResourcePage.create<Counter>(
        builder: (ctx, state, r) => CreateCounter(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      CreateRecordPage<Counter>(resource: resource);
}
