import 'package:flutter/widgets.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../models/ai_voice_settings.dart';

class EditAiVoice extends StatelessWidget {
  final Resource<AiVoiceSettings> resource;
  final String recordId;
  const EditAiVoice({
    super.key,
    required this.resource,
    required this.recordId,
  });

  static ResourcePage<AiVoiceSettings> route() =>
      ResourcePage.edit<AiVoiceSettings>(
        builder: (ctx, state, r) => EditAiVoice(
          resource: r,
          recordId: state.pathParameters['id']!,
        ),
      );

  @override
  Widget build(BuildContext context) => EditRecordPage<AiVoiceSettings>(
        resource: resource,
        recordId: recordId,
      );
}
