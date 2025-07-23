import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final _audioFiles = {
    'dot': 'assets/audio/dot.wav',
    'dash': 'assets/audio/dash.wav',
    'correct': 'assets/audio/correct.wav',
    'wrong': 'assets/audio/wrong.wav',
    'flip': 'assets/audio/flip.wav',
  };

  // Initialize audio (call this at app startup)
  static Future<void> init() async {
    try {
      await _player.setSource(AssetSource(_audioFiles['dot']!));
      await _player.setSource(AssetSource(_audioFiles['dash']!));
      if (kDebugMode) developer.log('AudioService initialized');
    } catch (e) {
      if (kDebugMode) developer.log('Audio init error: $e', error: e);
    }
  }

  // Morse code sounds
  static Future<void> playDot() async => _play('dot');
  static Future<void> playDash() async => _play('dash');

  // Feedback sounds
  static Future<void> playSuccessTone() async => _play('correct');
  static Future<void> playErrorTone() async => _play('wrong');
  static Future<void> playFlipSound() async => _play('flip');

  // Volume control (0.0 to 1.0)
  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  // Private helper
  static Future<void> _play(String name) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(_audioFiles[name]!));
    } catch (e) {
      if (kDebugMode) developer.log('Error playing $name: $e');
    }
  }

  static Future<void> dispose() async {
    await _player.stop();
    await _player.dispose();
  }
}