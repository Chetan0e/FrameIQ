import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String apiKey;
  final String model;
  final bool levelHapticsEnabled;
  final int smartCaptureMinScore;

  const AppSettings({
    required this.apiKey,
    required this.model,
    required this.levelHapticsEnabled,
    required this.smartCaptureMinScore,
  });

  AppSettings copyWith({
    String? apiKey,
    String? model,
    bool? levelHapticsEnabled,
    int? smartCaptureMinScore,
  }) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      levelHapticsEnabled: levelHapticsEnabled ?? this.levelHapticsEnabled,
      smartCaptureMinScore: smartCaptureMinScore ?? this.smartCaptureMinScore,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier()
      : super(const AppSettings(
          apiKey: '',
          model: 'google/gemini-2.0-flash',
          levelHapticsEnabled: true,
          smartCaptureMinScore: 90,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      apiKey: prefs.getString('api_key') ?? '',
      model: prefs.getString('model') ?? 'google/gemini-2.0-flash',
      levelHapticsEnabled: prefs.getBool('level_haptics') ?? true,
      smartCaptureMinScore: prefs.getInt('smart_capture_min_score') ?? 90,
    );
  }

  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', apiKey);
    state = state.copyWith(apiKey: apiKey);
  }

  Future<void> setModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model', model);
    state = state.copyWith(model: model);
  }

  Future<void> setLevelHaptics(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_haptics', enabled);
    state = state.copyWith(levelHapticsEnabled: enabled);
  }

  Future<void> setSmartCaptureMinScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('smart_capture_min_score', score);
    state = state.copyWith(smartCaptureMinScore: score);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
