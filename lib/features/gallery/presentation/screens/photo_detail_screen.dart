import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../camera/domain/enums/scene_mode.dart';
import '../../data/services/ai_coaching_service.dart';
import '../controllers/gallery_notifier.dart';
import '../../../../core/settings/settings_provider.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  final String photoId;

  const PhotoDetailScreen({super.key, required this.photoId});

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  bool _isLoadingCritique = false;
  String? _errorMessage;
  final AiCoachingService _aiService = AiCoachingService();

  Color _scoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.accent;
    return AppColors.accent2;
  }

  Future<void> _requestAiCritique(
    String filePath,
    double score,
    String sceneLabel,
    List<String> suggestions,
  ) async {
    setState(() {
      _isLoadingCritique = true;
      _errorMessage = null;
    });

    try {
      final settings = ref.read(settingsProvider);
      String critique;

      if (settings.apiKey.trim().isEmpty) {
        // Run simulated demo critique
        critique = await _aiService.getMockCritique(
          score: score,
          sceneLabel: sceneLabel,
          suggestions: suggestions,
        );
      } else {
        // Run live OpenRouter critique
        critique = await _aiService.getCritique(
          imagePath: filePath,
          apiKey: settings.apiKey,
          model: settings.model,
        );
      }

      await ref
          .read(galleryNotifierProvider.notifier)
          .updatePhotoCritique(widget.photoId, critique);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCritique = false;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Photo'),
        content: const Text(
          'Are you sure you want to permanently delete this photo and its coaching details?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(galleryNotifierProvider.notifier)
                  .deletePhoto(widget.photoId);
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // close detail screen
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.accent2),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(galleryNotifierProvider);
    final photoIndex = photos.indexWhere((p) => p.id == widget.photoId);

    if (photoIndex == -1) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: Text('Photo not found')),
      );
    }

    final photo = photos[photoIndex];
    final scoreCol = _scoreColor(photo.score);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Zoomable Photo Preview
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: Hero(
                  tag: 'photo_${photo.id}',
                  child: Image.file(
                    File(photo.filePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Custom Top Bar overlay
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const GlassContainer(
                    borderRadius: 20,
                    blur: true,
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _confirmDelete,
                  child: const GlassContainer(
                    borderRadius: 20,
                    blur: true,
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.accent2,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expandable Metadata Panel at the bottom
          Positioned(
            left: 12,
            right: 12,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: _DetailsPanel(
              photo: photo,
              scoreCol: scoreCol,
              isLoadingCritique: _isLoadingCritique,
              errorMessage: _errorMessage,
              hasApiKey: settings.apiKey.trim().isNotEmpty,
              onRequestCritique: () => _requestAiCritique(
                photo.filePath,
                photo.score,
                photo.sceneMode.label,
                photo.suggestionMessages,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends ConsumerStatefulWidget {
  final dynamic photo;
  final Color scoreCol;
  final bool isLoadingCritique;
  final String? errorMessage;
  final bool hasApiKey;
  final VoidCallback onRequestCritique;

  const _DetailsPanel({
    required this.photo,
    required this.scoreCol,
    required this.isLoadingCritique,
    required this.errorMessage,
    required this.hasApiKey,
    required this.onRequestCritique,
  });

  @override
  ConsumerState<_DetailsPanel> createState() => _DetailsPanelState();
}

class _DetailsPanelState extends ConsumerState<_DetailsPanel> {
  bool _expanded = false;

  void _showApiKeyDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: AppColors.accent, size: 22),
            SizedBox(width: 10),
            Text('Add AI API Key', style: TextStyle(fontSize: 18, color: AppColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supports native Google Gemini keys (starts with AIzaSy) or OpenRouter keys (starts with sk-or). Both are auto-detected.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Paste API Key here',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                await ref.read(settingsProvider.notifier).setApiKey(key);
                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                  // Automatically trigger critique!
                  widget.onRequestCritique();
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save & Run', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Circular Score Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: widget.photo.score / 100,
                        backgroundColor: Colors.white10,
                        color: widget.scoreCol,
                        strokeWidth: 4,
                      ),
                    ),
                    Text(
                      '${widget.photo.score.round()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: widget.scoreCol,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shot in ${widget.photo.sceneMode.label} Mode ${widget.photo.sceneMode.emoji}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Captured on ${_formatDate(widget.photo.dateTime)}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ],
            ),
            if (_expanded) ...[
              const Divider(color: Colors.white10, height: 24),
              const Text(
                'Composition Tips Applied',
                style: TextStyle(
                  color: AppColors.accent3,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.photo.suggestionMessages.isEmpty)
                const Text(
                  'No corrections needed — frame was extremely steady and aligned!',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                )
              else
                ...widget.photo.suggestionMessages.map<Widget>((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const Divider(color: Colors.white10, height: 24),
              const Text(
                '🤖 AI Photography Coach',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              _buildAiCoachCritiqueSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiCoachCritiqueSection() {
    if (widget.photo.aiCritique != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 250),
        child: SingleChildScrollView(
          child: MarkdownBody(
            data: widget.photo.aiCritique!,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.45,
              ),
              h3: const TextStyle(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
              h4: const TextStyle(
                color: AppColors.accent3,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
              blockquoteDecoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: AppColors.accent3, width: 3),
                ),
              ),
              blockquotePadding: const EdgeInsets.all(8),
              blockquote: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    if (widget.isLoadingCritique) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.hasApiKey
                    ? 'AI Coach is reviewing your photo…'
                    : 'Generating Simulated Review…',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent2.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(color: AppColors.accent2, fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
        ],
        FilledButton.icon(
          onPressed: widget.onRequestCritique,
          icon: const Icon(Icons.psychology_outlined, size: 18),
          label: Text(
            widget.hasApiKey
                ? 'Get AI Critique'
                : 'Test with Demo Coach',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        if (!widget.hasApiKey) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showApiKeyDialog(context),
            icon: const Icon(Icons.vpn_key_outlined, size: 16),
            label: const Text('Add API Key for Real AI'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
