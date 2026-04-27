import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/ai_voice_settings.dart';

class ListAiVoice extends StatelessWidget {
  final Resource<AiVoiceSettings> resource;
  const ListAiVoice({super.key, required this.resource});

  static ResourcePage<AiVoiceSettings> route() =>
      ResourcePage.list<AiVoiceSettings>(
        builder: (ctx, state, r) => ListAiVoice(resource: r),
      );

  @override
  Widget build(BuildContext context) =>
      ListRecordsPage<AiVoiceSettings>(resource: resource);
}
