enum CompositionType {
  ruleOfThirds,
  goldenSpiral,
  goldenTriangle,
  symmetry,
  leadingLines,
  diagonal,
  centerFrame,
  selfiePosture,
  phiGrid,
  ruleOfOdds,
  none,
}

extension CompositionTypeX on CompositionType {
  String get label {
    switch (this) {
      case CompositionType.ruleOfThirds:   return 'Rule of Thirds';
      case CompositionType.goldenSpiral:   return 'Golden Spiral';
      case CompositionType.goldenTriangle: return 'Golden Triangle';
      case CompositionType.symmetry:       return 'Symmetry';
      case CompositionType.leadingLines:   return 'Leading Lines';
      case CompositionType.diagonal:       return 'Diagonal';
      case CompositionType.centerFrame:    return 'Center Frame';
      case CompositionType.selfiePosture:  return 'Selfie Posture';
      case CompositionType.phiGrid:        return 'Phi Grid';
      case CompositionType.ruleOfOdds:     return 'Rule of Odds';
      case CompositionType.none:           return 'None';
    }
  }

  String get shortTip {
    switch (this) {
      case CompositionType.ruleOfThirds:
        return 'Place subject on power points';
      case CompositionType.goldenSpiral:
        return 'Curl focal point to spiral center';
      case CompositionType.goldenTriangle:
        return 'Elements align to triangle edges';
      case CompositionType.symmetry:
        return 'Keep center axis aligned';
      case CompositionType.leadingLines:
        return 'Lines guide to your subject';
      case CompositionType.diagonal:
        return 'Tilt for energy and movement';
      case CompositionType.centerFrame:
        return 'Subject centered for impact';
      case CompositionType.selfiePosture:
        return 'Match pose to the scene behind you';
      case CompositionType.phiGrid:
        return 'Align using the golden ratio';
      case CompositionType.ruleOfOdds:
        return 'Group elements in threes or odds';
      case CompositionType.none:
        return '';
    }
  }

  /// Best scene modes for this composition
  List<String> get bestFor {
    switch (this) {
      case CompositionType.ruleOfThirds:
        return ['portrait', 'landscape', 'street', 'action'];
      case CompositionType.goldenSpiral:
        return ['portrait', 'landscape', 'macro'];
      case CompositionType.goldenTriangle:
        return ['portrait', 'landscape'];
      case CompositionType.symmetry:
        return ['architecture', 'food', 'street'];
      case CompositionType.leadingLines:
        return ['landscape', 'architecture', 'street'];
      case CompositionType.diagonal:
        return ['action', 'street', 'architecture'];
      case CompositionType.centerFrame:
        return ['portrait', 'selfie', 'food', 'architecture'];
      case CompositionType.selfiePosture:
        return ['selfie'];
      case CompositionType.phiGrid:
        return ['landscape', 'architecture', 'macro'];
      case CompositionType.ruleOfOdds:
        return ['food', 'macro', 'street'];
      case CompositionType.none:
        return [];
    }
  }
}
