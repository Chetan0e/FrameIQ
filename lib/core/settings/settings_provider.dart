import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String apiKey;
  final String model;
  final bool levelHapticsEnabled;

  const AppSettings({
    required this.apiKey,
    required this.model,
    required this.levelHapticsEnabled,
  });

  AppSettings copyWith({
    String? apiKey,
    String? model,
    bool? levelHapticsEnabled,
  }) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      levelHapticsEnabled: levelHapticsEnabled ?? this.levelHapticsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier()
      : super(const AppSettings(
          apiKey: '',
          model: 'google/gemini-2.0-flash',
          levelHapticsEnabled: true,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      apiKey: prefs.getString('api_key') ?? '',
      model: prefs.getString('model') ?? 'google/gemini-2.0-flash',
      levelHapticsEnabled: prefs.getBool('level_haptics') ?? true,
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
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
