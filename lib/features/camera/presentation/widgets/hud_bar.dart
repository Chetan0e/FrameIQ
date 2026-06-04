import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/settings/settings_provider.dart';

import '../../domain/enums/scene_mode.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../screens/camera_controller_provider.dart';

class HudBar extends ConsumerWidget {
  final SceneMode scene;
  final bool isAutoMode;
  final SceneMode detectedScene;

  const HudBar({
    super.key,
    required this.scene,
    required this.isAutoMode,
    required this.detectedScene,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 8),
      child: Row(
        children: [
          const _BrandMark(),
          const Spacer(),
          _SceneChip(
            scene: scene,
            isAutoMode: isAutoMode,
            detectedScene: detectedScene,
          ),
          const SizedBox(width: 10),
          _IconCircleButton(
            icon: Icons.tune_rounded,
            onTap: () => _showSettingsSheet(context, ref),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      isScrollControlled: true,
      builder: (context) => const _SettingsSheetContents(),
    );
  }
}

class _SettingsSheetContents extends ConsumerStatefulWidget {
  const _SettingsSheetContents();

  @override
  ConsumerState<_SettingsSheetContents> createState() => _SettingsSheetContentsState();
}

class _SettingsSheetContentsState extends ConsumerState<_SettingsSheetContents> {
  late TextEditingController _apiKeyCtrl;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _apiKeyCtrl = TextEditingController(text: settings.apiKey);
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = ref.watch(overlayOpacityProvider);
    final isAuto = ref.watch(autoOpacityProvider);
    final smartCaptureEnabled = ref.watch(smartCaptureProvider);
    final lockEnabled = ref.watch(compositionLockProvider);
    final settings = ref.watch(settingsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Camera Settings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Customize guides and configure AI coach.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Auto-fade when still',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Hide guides after you hold steady or nail the shot.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        value: isAuto,
                        onChanged: (val) {
                          ref.read(autoOpacityProvider.notifier).state = val;
                          if (!val &&
                              ref.read(overlayOpacityProvider) < 0.1) {
                            ref.read(overlayOpacityProvider.notifier).state =
                                AppConstants.overlayOpacityActive;
                          }
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Smart auto capture',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Capture automatically when frame is steady and score is high.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        value: smartCaptureEnabled,
                        onChanged: (val) {
                          ref.read(smartCaptureProvider.notifier).state = val;
                        },
                      ),
                      if (smartCaptureEnabled) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Smart capture threshold',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${settings.smartCaptureMinScore}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Slider(
                          value: settings.smartCaptureMinScore.toDouble(),
                          min: 80,
                          max: 98,
                          divisions: 18,
                          onChanged: (val) {
                            ref
                                .read(settingsProvider.notifier)
                                .setSmartCaptureMinScore(val.round());
                          },
                        ),
                      ],
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Composition lock',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Freeze scene detection and coaching until unlocked.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        value: lockEnabled,
                        onChanged: (val) {
                          ref.read(compositionLockProvider.notifier).state = val;
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Horizon haptics',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Vibrate when camera becomes perfectly level.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        value: settings.levelHapticsEnabled,
                        onChanged: (val) {
                          ref.read(settingsProvider.notifier).setLevelHaptics(val);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Guide opacity',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(opacity * 100).round()}%',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: opacity,
                        min: 0,
                        max: 1,
                        onChanged: (val) {
                          ref.read(overlayOpacityProvider.notifier).state =
                              val;
                        },
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'AI API Key (Gemini or OpenRouter)',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter your direct Google Gemini key (starts with AIzaSy) or OpenRouter key (starts with sk-or). Both are auto-detected.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _apiKeyCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'AIzaSy... / sk-or-...',
                          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.accent,
                              width: 1,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        onChanged: (val) {
                          ref.read(settingsProvider.notifier).setApiKey(val);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'AI Coach Model',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          DropdownButton<String>(
                            value: settings.model,
                            dropdownColor: AppColors.surface,
                            underline: const SizedBox(),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'google/gemini-2.5-flash',
                                child: Text('Gemini 2.5 Flash (Rec.)'),
                              ),
                              DropdownMenuItem(
                                value: 'google/gemini-2.5-pro',
                                child: Text('Gemini 2.5 Pro'),
                              ),
                              DropdownMenuItem(
                                value: 'google/gemini-2.0-flash',
                                child: Text('Gemini 2.0 Flash'),
                              ),
                              DropdownMenuItem(
                                value: 'google/gemini-flash-1.5',
                                child: Text('Gemini 1.5 Flash'),
                              ),
                              DropdownMenuItem(
                                value: 'google/gemini-pro-1.5',
                                child: Text('Gemini 1.5 Pro'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(settingsProvider.notifier).setModel(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 12,
      blur: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
              children: [
                TextSpan(
                  style: TextStyle(color: Colors.white),
                  text: 'Frame',
                ),
                TextSpan(
                  style: TextStyle(color: AppColors.accent),
                  text: 'IQ',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneChip extends StatelessWidget {
  final SceneMode scene;
  final bool isAutoMode;
  final SceneMode detectedScene;

  const _SceneChip({
    required this.scene,
    required this.isAutoMode,
    required this.detectedScene,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = isAutoMode && detectedScene != SceneMode.auto
        ? ' · ${detectedScene.label}'
        : '';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: GlassContainer(
        key: ValueKey('$scene$detectedScene'),
        borderRadius: 20,
        blur: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              scene.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              '${scene.label}$subtitle',
              style: const TextStyle(
                color: AppColors.accent3,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 20,
        blur: false,
        padding: const EdgeInsets.all(9),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
