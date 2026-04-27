import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../models/ai_voice_settings.dart';
import '../../../models/service.dart';
import '../../../models/zone.dart';

/// Platform yang STT-nya didukung. Web di-hide dulu sesuai permintaan
/// user — dukungan Web Speech API terbatas (Chrome/Edge only) dan
/// belum di-test. Desktop native (Linux/Windows/macOS) tidak didukung
/// oleh `speech_to_text` package.
bool get isVoiceSupportedOnPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// State machine percakapan voice AI di kios.
enum AiConversationState {
  /// Belum mulai. Tombol mic ditampilkan, user belum interaksi.
  idle,

  /// Mic terbuka, mendengarkan suara user.
  listening,

  /// User selesai bicara, sedang call LLM.
  thinking,

  /// LLM sudah merespons; TTS sedang membacakan.
  speaking,

  /// LLM mengusulkan satu layanan. UI menampilkan kartu konfirmasi
  /// (Ya / Tidak). [proposedServiceId] terisi.
  awaitingConfirm,

  /// User menerima layanan yang diusulkan. UI lanjut ke flow tiket.
  confirmed,

  /// User membatalkan, atau LLM panggil tool `cancel`.
  cancelled,

  /// Ada error fatal — koneksi, API, permission, dsb. [error] terisi.
  error,
}

/// Satu pesan dalam history percakapan. Dikirim ke LLM apa adanya.
class AiTurn {
  final String role; // 'user' | 'assistant'
  final String text;
  const AiTurn({required this.role, required this.text});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': text,
      };
}

/// Wrapper STT + Anthropic Messages API + TTS. ChangeNotifier-based —
/// UI rebuild tiap state berubah. Lifecycle: instantiate saat user masuk
/// voice mode, `dispose()` saat keluar.
class AiConversationService extends ChangeNotifier {
  final AiVoiceSettings settings;
  final List<Service> services;
  final List<Zone> zones;

  /// Maks giliran percakapan sebelum auto-cancel — supaya tidak loop.
  static const _maxTurns = 6;

  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final Dio _dio = Dio();

  AiConversationState _state = AiConversationState.idle;
  String? _lastTranscript;
  String? _lastAssistantText;
  String? _proposedServiceId;
  String? _proposedSummary;
  String? _error;
  final List<AiTurn> _history = [];
  bool _sttReady = false;
  bool _ttsReady = false;
  bool _disposed = false;

  AiConversationService({
    required this.settings,
    required this.services,
    required this.zones,
  });

  // ── State getters ──────────────────────────────────────────────────
  AiConversationState get state => _state;
  String? get lastTranscript => _lastTranscript;
  String? get lastAssistantText => _lastAssistantText;
  String? get proposedServiceId => _proposedServiceId;
  String? get proposedSummary => _proposedSummary;
  String? get error => _error;
  List<AiTurn> get history => List.unmodifiable(_history);

  void _setState(AiConversationState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  /// Init STT + TTS + permissions. Panggil sekali setelah construction,
  /// sebelum `startListening`. Return false kalau tidak bisa.
  Future<bool> initialize() async {
    if (settings.apiKey.isEmpty) {
      _error = 'API key Voice AI belum diisi di Pengaturan.';
      _setState(AiConversationState.error);
      return false;
    }
    try {
      _sttReady = await _stt.initialize(
        onError: (e) => developer.log('stt error: ${e.errorMsg}',
            name: 'kiosk.voice'),
      );
    } catch (e) {
      developer.log('stt init failed: $e', name: 'kiosk.voice');
      _sttReady = false;
    }
    if (!_sttReady) {
      _error =
          'Speech-to-text tidak tersedia. Pastikan izin mikrofon diberikan '
          'dan platform mendukung (Android/iOS/Web).';
      _setState(AiConversationState.error);
      return false;
    }

    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.5);
      await _tts.awaitSpeakCompletion(true);
      _ttsReady = true;
    } catch (e) {
      developer.log('tts init failed: $e', name: 'kiosk.voice');
      // TTS opsional — kalau gagal, tetap jalan tanpa suara.
      _ttsReady = false;
    }
    return true;
  }

  /// Mulai sesi: bacakan sapaan pembuka lalu otomatis mulai
  /// mendengarkan. Dipanggil saat user pertama kali tap tombol "Mulai".
  Future<void> startSession() async {
    if (_state == AiConversationState.error) return;
    const greeting = 'Halo, ada yang bisa dibantu? Silakan sebutkan layanan '
        'yang Anda inginkan.';
    _lastAssistantText = greeting;
    _setState(AiConversationState.speaking);
    await _speak(greeting);
    if (_disposed) return;
    await startListening();
  }

  /// Mulai mendengarkan user. STT auto-stop setelah jeda hening atau
  /// timeout 30 detik.
  Future<void> startListening() async {
    if (!_sttReady || _disposed) return;
    _setState(AiConversationState.listening);
    try {
      await _stt.listen(
        onResult: _onSttResult,
        localeId: 'id_ID',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: false,
          cancelOnError: true,
        ),
      );
    } catch (e) {
      developer.log('listen failed: $e', name: 'kiosk.voice');
      _error = 'Gagal mengakses mikrofon.';
      _setState(AiConversationState.error);
    }
  }

  /// Hentikan mic manual (kalau user tap tombol stop).
  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  void _onSttResult(SpeechRecognitionResult result) {
    if (!result.finalResult) return;
    final text = result.recognizedWords.trim();
    if (text.isEmpty) {
      // STT tidak menangkap apa-apa — beri kesempatan lagi.
      _setState(AiConversationState.listening);
      Future.delayed(const Duration(milliseconds: 200), startListening);
      return;
    }
    _lastTranscript = text;
    _history.add(AiTurn(role: 'user', text: text));
    _setState(AiConversationState.thinking);
    unawaited(_runLlmTurn());
  }

  /// User menerima layanan yang diusulkan LLM. Result final.
  void confirmProposed() {
    if (_state != AiConversationState.awaitingConfirm) return;
    _setState(AiConversationState.confirmed);
  }

  /// User menolak usulan. Buka mic lagi untuk klarifikasi.
  Future<void> rejectProposed() async {
    if (_state != AiConversationState.awaitingConfirm) return;
    _proposedServiceId = null;
    _proposedSummary = null;
    _history.add(const AiTurn(
      role: 'user',
      text: 'Bukan itu, coba yang lain.',
    ));
    await startListening();
  }

  /// User cancel via tombol X.
  void cancel() {
    _setState(AiConversationState.cancelled);
  }

  // ── LLM call ───────────────────────────────────────────────────────
  Future<void> _runLlmTurn() async {
    if (_history.length > _maxTurns * 2) {
      _error = 'Percakapan terlalu panjang. Silakan pilih layanan manual.';
      _setState(AiConversationState.error);
      return;
    }

    Map<String, dynamic> response;
    try {
      response = await _callAnthropic();
    } catch (e) {
      developer.log('llm failed: $e', name: 'kiosk.voice');
      _error = 'Gagal menghubungi server AI: $e';
      _setState(AiConversationState.error);
      return;
    }
    if (_disposed) return;

    final tool = _extractToolUse(response);
    if (tool == null) {
      _error = 'Respons AI tidak valid.';
      _setState(AiConversationState.error);
      return;
    }

    final name = tool['name'] as String?;
    final input = (tool['input'] as Map?)?.cast<String, dynamic>() ?? {};

    switch (name) {
      case 'ask_clarification':
        final question = (input['question'] ?? '').toString();
        _lastAssistantText = question;
        _history.add(AiTurn(role: 'assistant', text: question));
        _setState(AiConversationState.speaking);
        await _speak(question);
        if (_disposed) return;
        await startListening();
        break;
      case 'confirm_service':
        final id = (input['service_id'] ?? '').toString();
        final summary = (input['summary'] ?? '').toString();
        final found = services.any((s) => s.id == id);
        if (!found) {
          // Halusinasi LLM — minta klarifikasi lagi.
          _history.add(AiTurn(
            role: 'assistant',
            text: 'Layanan dengan ID itu tidak ada di daftar.',
          ));
          await _runLlmTurn();
          return;
        }
        _proposedServiceId = id;
        _proposedSummary = summary;
        _lastAssistantText = summary;
        _history.add(AiTurn(role: 'assistant', text: summary));
        _setState(AiConversationState.speaking);
        await _speak(summary);
        if (_disposed) return;
        _setState(AiConversationState.awaitingConfirm);
        break;
      case 'cancel':
        final reason = (input['reason'] ?? '').toString();
        _lastAssistantText = reason.isNotEmpty
            ? reason
            : 'Maaf, layanan yang Anda butuhkan tidak tersedia di sini.';
        _setState(AiConversationState.speaking);
        await _speak(_lastAssistantText!);
        if (_disposed) return;
        _setState(AiConversationState.cancelled);
        break;
      default:
        _error = 'AI memanggil tool tidak dikenal: $name';
        _setState(AiConversationState.error);
    }
  }

  Map<String, dynamic>? _extractToolUse(Map<String, dynamic> response) {
    final content = response['content'];
    if (content is! List) return null;
    for (final block in content) {
      if (block is Map && block['type'] == 'tool_use') {
        return Map<String, dynamic>.from(block);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _callAnthropic() async {
    final resp = await _dio.post<Map<String, dynamic>>(
      'https://api.anthropic.com/v1/messages',
      options: Options(
        headers: {
          'x-api-key': settings.apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
      ),
      data: {
        'model': settings.model,
        'max_tokens': 512,
        'system': _buildSystemPrompt(),
        'tools': _toolDefinitions(),
        'tool_choice': {'type': 'any'},
        'messages': _history.map((t) => t.toJson()).toList(),
      },
    );
    final data = resp.data;
    if (data == null) {
      throw 'Response kosong dari Anthropic.';
    }
    return data;
  }

  String _buildSystemPrompt() {
    final zoneById = {for (final z in zones) z.id: z.name};
    final servicesList = services.map((s) {
      final zone = zoneById[s.zoneId] ?? '-';
      return '- ${s.id}: ${s.name} (zona: $zone)';
    }).join('\n');

    final extra = settings.systemPromptExtra?.trim() ?? '';
    final extraBlock = extra.isEmpty ? '' : '\n\nINSTRUKSI TAMBAHAN:\n$extra';

    return '''
Kamu adalah asisten kios antrian di sebuah instansi pelayanan publik di Indonesia. Tugas kamu membantu pengguna memilih satu layanan dari daftar yang tersedia berdasarkan apa yang mereka katakan.

DAFTAR LAYANAN YANG TERSEDIA:
$servicesList

ATURAN:
1. Selalu gunakan Bahasa Indonesia. Sapa dengan formal ("Anda").
2. Kalau permintaan jelas dan cocok dengan satu layanan, langsung panggil tool `confirm_service` dengan service_id dari daftar di atas dan summary singkat untuk dibacakan ke user (mis. "Anda mau mengurus pendaftaran KTP baru, benar?").
3. Kalau ambigu (cocok dengan beberapa layanan), panggil `ask_clarification` dengan satu pertanyaan singkat.
4. Kalau permintaan tidak cocok dengan layanan apa pun, atau user explicit bilang batal/tidak jadi, panggil `cancel` dengan reason singkat dan ramah.
5. Jangan buat ID layanan sendiri — gunakan persis seperti di daftar.
6. Maksimal 2-3 turn klarifikasi. Kalau masih tidak jelas, panggil `cancel`.
7. Setiap respons WAJIB pakai salah satu dari 3 tool di atas — jangan jawab text bebas.$extraBlock''';
  }

  List<Map<String, dynamic>> _toolDefinitions() => [
        {
          'name': 'ask_clarification',
          'description':
              'Ajukan satu pertanyaan klarifikasi ke user kalau permintaannya '
                  'belum jelas atau cocok dengan beberapa layanan.',
          'input_schema': {
            'type': 'object',
            'properties': {
              'question': {
                'type': 'string',
                'description':
                    'Satu pertanyaan singkat dalam Bahasa Indonesia yang akan '
                        'dibacakan oleh TTS ke user.',
              },
            },
            'required': ['question'],
          },
        },
        {
          'name': 'confirm_service',
          'description':
              'Konfirmasi layanan yang sudah jelas akan dipilih. Hanya '
                  'panggil ini kalau yakin user mau layanan tertentu.',
          'input_schema': {
            'type': 'object',
            'properties': {
              'service_id': {
                'type': 'string',
                'description':
                    'ID layanan persis seperti di daftar di atas (sebelum '
                        'tanda titik dua).',
              },
              'summary': {
                'type': 'string',
                'description':
                    'Kalimat konfirmasi untuk dibacakan ke user, mis. '
                        '"Anda mau mengurus pendaftaran KTP baru, benar?".',
              },
            },
            'required': ['service_id', 'summary'],
          },
        },
        {
          'name': 'cancel',
          'description':
              'Batalkan percakapan. Panggil ini kalau permintaan user tidak '
                  'cocok dengan layanan apa pun, atau user explicit minta '
                  'batal.',
          'input_schema': {
            'type': 'object',
            'properties': {
              'reason': {
                'type': 'string',
                'description':
                    'Alasan singkat dan ramah dalam Bahasa Indonesia, untuk '
                        'dibacakan ke user.',
              },
            },
            'required': ['reason'],
          },
        },
      ];

  Future<void> _speak(String text) async {
    if (!_ttsReady) return;
    try {
      await _tts.speak(text);
    } catch (e) {
      developer.log('tts speak failed: $e', name: 'kiosk.voice');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_stt.cancel());
    unawaited(_tts.stop());
    super.dispose();
  }
}
