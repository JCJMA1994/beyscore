import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Announcer voice language mode.
enum AnnouncerLanguage {
  official('3-2-1 GO SHOOT! (Oficial)'),
  spanish('3-2-1 ¡LANZAMIENTO! (Español)');

  const AnnouncerLanguage(this.label);
  final String label;
}

/// Cyber-Tactical audio & voice announcer service for BeyScore.
///
/// Combines native human Voice (via TTS) and low-latency audio effects for:
/// - Stadium countdowns (3-2-1 GO SHOOT! / ¡LANZAMIENTO!)
/// - Match finishes (Spin, Over, Burst, Xtreme)
/// - Penalty warnings (Over-finish, Late launch, Faults)
class BeyAudioService {
  BeyAudioService({AudioPlayer? player, FlutterTts? tts})
      : _player = player ?? AudioPlayer(),
        _tts = tts ?? FlutterTts() {
    _init();
  }

  static final BeyAudioService instance = BeyAudioService();

  final AudioPlayer _player;
  final FlutterTts _tts;
  bool isMuted = false;
  AnnouncerLanguage language = AnnouncerLanguage.official;
  Map<String, String>? selectedVoice;
  double speechRate = 0.65;
  double speechPitch = 1.05;

  void toggleLanguage() {
    language = language == AnnouncerLanguage.official
        ? AnnouncerLanguage.spanish
        : AnnouncerLanguage.official;
    _updateTtsLanguage();
  }

  void _init() {
    try {
      _player
        ..setAudioContext(
          AudioContext(
            android: const AudioContextAndroid(
              isSpeakerphoneOn: true,
              stayAwake: true,
              contentType: AndroidContentType.sonification,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.gainTransientMayDuck,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.ambient,
              options: const {
                AVAudioSessionOptions.mixWithOthers,
                AVAudioSessionOptions.duckOthers,
              },
            ),
          ),
        )
        ..setVolume(1);

      _updateTtsLanguage();
      _tts
        ..setSpeechRate(speechRate)
        ..setPitch(speechPitch)
        ..setVolume(1);
    } catch (e) {
      debugPrint('[BeyAudioService] Audio/TTS init note: $e');
    }
  }

  void _updateTtsLanguage() {
    try {
      if (selectedVoice != null) {
        _tts.setVoice(selectedVoice!);
      } else if (language == AnnouncerLanguage.spanish) {
        _tts.setLanguage('es-ES');
      } else {
        _tts.setLanguage('en-US');
      }
    } catch (_) {}
  }

  /// Returns the list of installed TTS voices on the device.
  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final rawVoices = await _tts.getVoices;
      if (rawVoices is List) {
        return rawVoices
            .map((v) {
              if (v is Map) {
                return {
                  'name': v['name']?.toString() ?? '',
                  'locale': v['locale']?.toString() ?? '',
                };
              }
              return <String, String>{};
            })
            .where((m) => m['name']?.isNotEmpty == true)
            .toList();
      }
    } catch (e) {
      debugPrint('[BeyAudioService] Error getting voices: $e');
    }
    return [];
  }

  /// Sets an explicit voice by name and locale.
  Future<void> setCustomVoice(Map<String, String>? voice) async {
    selectedVoice = voice;
    if (voice != null) {
      try {
        await _tts.setVoice(voice);
      } catch (_) {}
    } else {
      _updateTtsLanguage();
    }
  }

  /// Customizes speech rate (0.4 - 1.0) and pitch (0.5 - 1.5).
  Future<void> setVoiceParams({double? rate, double? pitch}) async {
    if (rate != null) {
      speechRate = rate;
      await _tts.setSpeechRate(rate);
    }
    if (pitch != null) {
      speechPitch = pitch;
      await _tts.setPitch(pitch);
    }
  }

  /// Previews the currently configured voice with a stadium announcement.
  Future<void> previewVoice([String? customPhrase]) async {
    final phrase = customPhrase ??
        (language == AnnouncerLanguage.spanish
            ? '¡Tres, Dos, Uno, Lanzamiento! ¡Xtreme Finish!'
            : 'Three, Two, One, Go Shoot! Xtreme Finish!');
    try {
      await _tts.stop();
      _updateTtsLanguage();
      await _tts.setSpeechRate(speechRate);
      await _tts.setPitch(speechPitch);
      await _tts.speak(phrase);
    } catch (e) {
      debugPrint('[BeyAudioService] Preview error: $e');
    }
  }

  /// Speaks voice line through native speech synthesis.
  Future<void> _speak(String text) async {
    if (isMuted) return;
    try {
      await _tts.stop();
      _updateTtsLanguage();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[BeyAudioService] TTS error: $e');
    }
  }

  /// Plays stadium countdown step (3, 2, or 1) with spoken voice and audio cue.
  Future<void> playCount(int number) async {
    if (isMuted) return;
    try {
      final assetPath = switch (number) {
        3 => 'assets/audio/count_3.wav',
        2 => 'assets/audio/count_2.wav',
        1 => 'assets/audio/count_1.wav',
        _ => 'assets/audio/count_3.wav',
      };

      unawaited(_playAsset(assetPath));

      final voiceText = switch (number) {
        3 => language == AnnouncerLanguage.spanish ? 'Tres' : 'Three',
        2 => language == AnnouncerLanguage.spanish ? 'Dos' : 'Two',
        1 => language == AnnouncerLanguage.spanish ? 'Uno' : 'One',
        _ => '$number',
      };
      await _speak(voiceText);
    } catch (e) {
      debugPrint('[BeyAudioService] Error playing count $number: $e');
    }
  }

  /// Plays the climax GO SHOOT! / ¡LANZAMIENTO! stadium launch announcement.
  Future<void> playGoShoot() async {
    if (isMuted) return;
    try {
      unawaited(_playAsset('assets/audio/go_shoot.wav'));
      final launchText = language == AnnouncerLanguage.spanish
          ? '¡Lanzamiento!'
          : 'Go Shoot!';
      await _speak(launchText);
    } catch (e) {
      debugPrint('[BeyAudioService] Error playing go shoot: $e');
    }
  }

  /// Plays finish fanfare sound and referee spoken decision.
  Future<void> playFinish(String type) async {
    if (isMuted) return;
    try {
      final upper = type.toUpperCase();
      if (upper == 'BURST' || upper == 'XTREME') {
        unawaited(_playAsset('assets/audio/finish_xtreme.wav'));
      } else {
        unawaited(_playAsset('assets/audio/finish_point.wav'));
      }

      final finishVoice = switch (upper) {
        'BURST' => language == AnnouncerLanguage.spanish ? '¡Burst Finish! Dos puntos.' : 'Burst Finish! Two points.',
        'XTREME' => language == AnnouncerLanguage.spanish ? '¡Xtreme Finish! Tres puntos.' : 'Xtreme Finish! Three points.',
        'OVER' => language == AnnouncerLanguage.spanish ? '¡Over Finish! Dos puntos.' : 'Over Finish! Two points.',
        'SPIN' => language == AnnouncerLanguage.spanish ? '¡Spin Finish! Un punto.' : 'Spin Finish! One point.',
        _ => type,
      };
      await _speak(finishVoice);
    } catch (e) {
      debugPrint('[BeyAudioService] Error playing finish $type: $e');
    }
  }

  /// Plays foul / penalty warning buzzer sound and referee announcement.
  Future<void> playFault() async {
    if (isMuted) return;
    try {
      unawaited(_playAsset('assets/audio/fault.wav'));
      final faultText = language == AnnouncerLanguage.spanish ? '¡Falta cometida!' : 'Foul!';
      await _speak(faultText);
    } catch (e) {
      debugPrint('[BeyAudioService] Error playing fault sound: $e');
    }
  }

  Future<void> _playAsset(String path) async {
    try {
      await _player.stop();
      final filename = path.split('/').last;
      try {
        await _player.play(AssetSource('packages/bey_ui/assets/audio/$filename'));
      } catch (_) {
        final cleanPath = path.startsWith('assets/') ? path.substring('assets/'.length) : path;
        await _player.play(AssetSource(cleanPath));
      }
    } catch (e) {
      debugPrint('[BeyAudioService] Error playing asset $path: $e');
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _tts.stop();
      _player.stop();
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _tts.stop();
  }
}
