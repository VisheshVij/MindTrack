import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/people_store.dart';
import '../models/person_profile.dart';

class RecognitionService extends ChangeNotifier {
  final _tts    = FlutterTts();
  final _player = AudioPlayer();

  final Map<String, DateTime> _lastSpoken = {};

  PersonProfile? lastRecognized;
  bool isPlaying = false;

  RecognitionService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  // Called by NFC scan — respects 10-minute cooldown
  Future<void> handleTag(String uid) async {
    final last = _lastSpoken[uid];
    if (last != null &&
        DateTime.now().difference(last).inMinutes < 10) {
      debugPrint('Cooldown active for $uid — skipping');
      return;
    }

    final profile = PeopleStore().findByUid(uid);
    if (profile == null) {
      debugPrint('No profile found for UID: $uid');
      await _tts.speak(
          'I do not recognise this person. Ask your caregiver to add them.');
      return;
    }

    lastRecognized = profile;
    notifyListeners();

    await _playPersonAudio(profile);
    _lastSpoken[uid] = DateTime.now();
  }

  // Called when user taps a photo in the app — no cooldown
  Future<void> playProfileDirectly(PersonProfile profile) async {
    lastRecognized = profile;
    notifyListeners();
    await _playPersonAudio(profile);
  }

  Future<void> _playPersonAudio(PersonProfile p) async {
    isPlaying = true;
    notifyListeners();

    if (p.audio.isNotEmpty) {
      try {
        await _player.stop();
        await _player.setAsset(p.audio);
        await _player.play();
        await _player.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed,
        );
      } catch (e) {
        debugPrint('Audio error for ${p.name}: $e');
        await _tts.speak(
            'This is ${p.name}. ${p.name} is your ${p.relationship}.');
        await Future.delayed(const Duration(seconds: 4));
      }
    } else {
      final text =
          'This is ${p.name}. ${p.name} is your ${p.relationship}.';
      await _tts.speak(text);
      await Future.delayed(
        Duration(
          milliseconds: (text.length * 70).clamp(2000, 10000),
        ),
      );
    }

    isPlaying = false;
    notifyListeners();
  }

  Future<void> stopAudio() async {
    await _tts.stop();
    await _player.stop();
    isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    _player.dispose();
    super.dispose();
  }
}