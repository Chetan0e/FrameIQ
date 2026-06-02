import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../camera/domain/enums/scene_mode.dart';
import '../../domain/models/coached_photo.dart';

final galleryNotifierProvider =
    StateNotifierProvider<GalleryNotifier, List<CoachedPhoto>>((ref) {
  return GalleryNotifier();
});

class GalleryNotifier extends StateNotifier<List<CoachedPhoto>> {
  GalleryNotifier() : super([]) {
    _loadPhotos();
  }

  static const _prefKey = 'coached_photos';

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_prefKey) ?? [];
    try {
      final photos = data.map((item) {
        return CoachedPhoto.fromJson(jsonDecode(item));
      }).toList();
      photos.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      state = photos;
    } catch (e) {
      state = [];
    }
  }

  Future<String> savePhoto({
    required XFile file,
    required double score,
    required SceneMode sceneMode,
    required List<String> suggestions,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'frameiq_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final targetPath = p.join(appDir.path, fileName);
    
    // Copy file to permanent app documents
    final savedFile = await File(file.path).copy(targetPath);

    final newPhoto = CoachedPhoto(
      id: const Uuid().v4(),
      filePath: savedFile.path,
      dateTime: DateTime.now(),
      score: score,
      sceneMode: sceneMode,
      suggestionMessages: suggestions,
    );

    final updated = [newPhoto, ...state];
    state = updated;
    await _persist();
    return savedFile.path;
  }

  Future<void> deletePhoto(String id) async {
    final photo = state.firstWhere((p) => p.id == id);
    try {
      final file = File(photo.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
    state = state.where((p) => p.id != id).toList();
    await _persist();
  }

  Future<void> updatePhotoCritique(String id, String critique) async {
    state = state.map((photo) {
      if (photo.id == id) {
        return photo.copyWith(aiCritique: critique);
      }
      return photo;
    }).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_prefKey, data);
  }
}
