import 'package:flutter/material.dart';

import '../../../models/ai_voice_settings.dart';
import '../../../models/kiosk.dart';
import '../../../models/service.dart';
import '../../../models/zone.dart';
import 'ai_conversation.dart';

const _kBgGradient = [
  Color(0xFF0D0A2E),
  Color(0xFF130E3A),
  Color(0xFF0A0820),
];
const _kAccentLight = Color(0xFFA5B4FC);
const _kAccentEnd = Color(0xFF8B5CF6);
const _kSuccess = Color(0xFF34D399);
const _kDanger = Color(0xFFF87171);

/// Halaman voice mode kios — fullscreen overlay yang muncul saat user
/// tap tombol mic di halaman kios. `Navigator.pop` dengan `serviceId`
/// kalau user konfirmasi layanan; pop `null` kalau cancel/error.
class KioskVoicePage extends StatefulWidget {
  final Kiosk kiosk;
  final AiVoiceSettings settings;
  final List<Service> services;
  final List<Zone> zones;

  const KioskVoicePage({
    super.key,
    required this.kiosk,
    required this.settings,
    required this.services,
    required this.zones,
  });

  @override
  State<KioskVoicePage> createState() => _KioskVoicePageState();
}

class _KioskVoicePageState extends State<KioskVoicePage>
    with TickerProviderStateMixin {
  late final AiConversationService _service;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _service = AiConversationService(
      settings: widget.settings,
      services: widget.services,
      zones: widget.zones,
    );
    _service.addListener(_onStateChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final ok = await _service.initialize();
    if (!mounted || !ok) return;
    await _service.startSession();
  }

  void _onStateChanged() {
    if (!mounted) return;
    if (_service.state == AiConversationState.confirmed) {
      Navigator.of(context).pop(_service.proposedServiceId);
    }
  }

  @override
  void dispose() {
    _service.removeListener(_onStateChanged);
    _service.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A2E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _kBgGradient,
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _service,
            builder: (ctx, _) => _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: _close,
            tooltip: 'Kembali',
          ),
          const SizedBox(width: 4),
          const Text(
            'Asisten Suara',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: _close,
            tooltip: 'Batalkan',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_service.state) {
      case AiConversationState.idle:
        return _buildCenterIcon(
          icon: Icons.mic_none_outlined,
          title: 'Menyiapkan…',
          subtitle: '',
          showSpinner: true,
        );
      case AiConversationState.listening:
        return _buildListening();
      case AiConversationState.thinking:
        return _buildCenterIcon(
          icon: Icons.psychology_outlined,
          title: 'Memproses…',
          subtitle: 'AI sedang memahami permintaan Anda.',
          showSpinner: true,
        );
      case AiConversationState.speaking:
        return _buildSpeaking();
      case AiConversationState.awaitingConfirm:
        return _buildAwaitingConfirm();
      case AiConversationState.confirmed:
        return _buildCenterIcon(
          icon: Icons.check_circle_outline,
          iconColor: _kSuccess,
          title: 'Membuat tiket…',
          subtitle: '',
          showSpinner: true,
        );
      case AiConversationState.cancelled:
        return _buildCancelled();
      case AiConversationState.error:
        return _buildError();
    }
  }

  Widget _buildListening() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (ctx, _) {
              final scale = 1.0 + 0.18 * _pulse.value;
              return Container(
                width: 180 * scale,
                height: 180 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _kAccentLight.withValues(alpha: 0.85),
                      _kAccentEnd.withValues(alpha: 0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccentLight.withValues(
                          alpha: 0.35 * (1 - _pulse.value)),
                      blurRadius: 60 * scale,
                      spreadRadius: 12 * _pulse.value,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.mic, color: Colors.white, size: 80),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'Mendengarkan…',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Silakan sebutkan layanan yang Anda inginkan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _buildTranscriptHistory(),
        ],
      ),
    );
  }

  Widget _buildSpeaking() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                  color: _kAccentLight.withValues(alpha: 0.4), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.volume_up_outlined,
                  color: _kAccentLight, size: 72),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI menjawab…',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_service.lastAssistantText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: _kAccentLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _kAccentLight.withValues(alpha: 0.3)),
              ),
              child: Text(
                _service.lastAssistantText!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          const SizedBox(height: 18),
          _buildTranscriptHistory(),
        ],
      ),
    );
  }

  Widget _buildAwaitingConfirm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kSuccess.withValues(alpha: 0.18),
              border: Border.all(color: _kSuccess.withValues(alpha: 0.6)),
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, color: _kSuccess, size: 56),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Konfirmasi Layanan',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              _service.proposedSummary ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _service.rejectProposed(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Bukan',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.25)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _service.confirmProposed,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Ya, Lanjutkan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kSuccess,
                    foregroundColor: const Color(0xFF0D0A2E),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelled() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined,
              color: Colors.white.withValues(alpha: 0.4), size: 88),
          const SizedBox(height: 18),
          const Text(
            'Dibatalkan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (_service.lastAssistantText != null)
            Text(
              _service.lastAssistantText!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _close,
            style: FilledButton.styleFrom(
              backgroundColor: _kAccentLight,
              foregroundColor: const Color(0xFF0D0A2E),
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            ),
            child: const Text(
              'Kembali ke Daftar Layanan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: _kDanger, size: 88),
          const SizedBox(height: 18),
          const Text(
            'Terjadi Masalah',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _service.error ?? 'Tidak dapat memulai percakapan AI.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _close,
            style: FilledButton.styleFrom(
              backgroundColor: _kAccentLight,
              foregroundColor: const Color(0xFF0D0A2E),
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            ),
            child: const Text(
              'Kembali ke Daftar Layanan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIcon({
    required IconData icon,
    Color iconColor = _kAccentLight,
    required String title,
    required String subtitle,
    bool showSpinner = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (showSpinner)
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: iconColor.withValues(alpha: 0.6),
                  ),
                ),
              Icon(icon, color: iconColor, size: 72),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTranscriptHistory() {
    final user = _service.lastTranscript;
    final assistant = _service.lastAssistantText;
    if (user == null && assistant == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user != null) ...[
            const Text(
              'Anda:',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (user != null && assistant != null) const SizedBox(height: 8),
          if (assistant != null) ...[
            const Text(
              'AI:',
              style: TextStyle(
                color: _kAccentLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              assistant,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
