enum SceneMode {
  portrait,
  selfie,
  landscape,
  food,
  architecture,
  macro,
  action,
  night,
  street,
  auto,
}

extension SceneModeX on SceneMode {
  String get label {
    switch (this) {
      case SceneMode.portrait:   return 'Portrait';
      case SceneMode.selfie:     return 'Selfie';
      case SceneMode.landscape:  return 'Landscape';
      case SceneMode.food:       return 'Food';
      case SceneMode.architecture: return 'Architecture';
      case SceneMode.macro:      return 'Macro';
      case SceneMode.action:     return 'Action';
      case SceneMode.night:      return 'Night';
      case SceneMode.street:     return 'Street';
      case SceneMode.auto:       return 'Auto';
    }
  }

  String get emoji {
    switch (this) {
      case SceneMode.portrait:     return '👤';
      case SceneMode.selfie:       return '🤳';
      case SceneMode.landscape:    return '🌄';
      case SceneMode.food:         return '🍽';
      case SceneMode.architecture: return '🏛';
      case SceneMode.macro:        return '🔬';
      case SceneMode.action:       return '⚡';
      case SceneMode.night:        return '🌙';
      case SceneMode.street:       return '🚶';
      case SceneMode.auto:         return '✨';
    }
  }

  /// ML Kit image label keywords that map to this mode
  List<String> get mlKeywords {
    switch (this) {
      case SceneMode.portrait:
      case SceneMode.selfie:
        return ['face', 'person', 'human', 'portrait', 'selfie', 'smile'];
      case SceneMode.landscape:
        return ['sky', 'mountain', 'ocean', 'nature', 'horizon', 'cloud', 'field', 'sunset', 'sunrise'];
      case SceneMode.food:
        return ['food', 'meal', 'dish', 'drink', 'cuisine', 'snack', 'fruit', 'vegetable'];
      case SceneMode.architecture:
        return ['building', 'architecture', 'structure', 'facade', 'interior', 'window', 'door'];
      case SceneMode.macro:
        return ['flower', 'insect', 'texture', 'plant', 'leaf', 'detail'];
      case SceneMode.action:
        return ['sport', 'athlete', 'motion', 'vehicle', 'race', 'game'];
      case SceneMode.night:
        return ['night', 'dark', 'light', 'neon', 'city night', 'star'];
      case SceneMode.street:
        return ['street', 'road', 'city', 'urban', 'pedestrian', 'sidewalk'];
      case SceneMode.auto:
        return [];
    }
  }
}
