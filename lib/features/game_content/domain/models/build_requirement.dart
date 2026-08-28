/// A single condition gating whether a tower/building/unit can be built -
/// shared across all three `GameObjectCategory` kinds instead of each one
/// inventing its own ad-hoc gold/score/count check.
///
/// Kept as a plain (non-freezed) sealed hierarchy with hand-written JSON so
/// new requirement kinds can be added by the server without a client
/// release, as long as `BuildRequirement.fromJson` recognizes the `kind`.
sealed class BuildRequirement {
  const BuildRequirement();

  factory BuildRequirement.fromJson(Map<String, dynamic> json) {
    return switch (json['kind'] as String) {
      'score' => ScoreRequirement(json['minScore'] as int),
      'buildingExists' => BuildingExistsRequirement(
        json['buildingId'] as String,
        minCount: json['minCount'] as int? ?? 1,
      ),
      'maxCount' => MaxCountRequirement(json['max'] as int),
      final other => throw ArgumentError('Unknown BuildRequirement kind: $other'),
    };
  }

  Map<String, dynamic> toJson();
}

/// Requires the player's current score to be at least [minScore] (mirrors
/// today's `GameConfig.trainingCenterUnlockScore`-style gates).
final class ScoreRequirement extends BuildRequirement {
  final int minScore;

  const ScoreRequirement(this.minScore);

  @override
  Map<String, dynamic> toJson() => {'kind': 'score', 'minScore': minScore};

  @override
  bool operator ==(Object other) =>
      other is ScoreRequirement && other.minScore == minScore;

  @override
  int get hashCode => Object.hash(ScoreRequirement, minScore);
}

/// Requires at least [minCount] of the building identified by
/// [buildingId] (a [GameObjectDefinition.id], e.g. `"building.techLab"`)
/// to already exist for the builder's team.
final class BuildingExistsRequirement extends BuildRequirement {
  final String buildingId;
  final int minCount;

  const BuildingExistsRequirement(this.buildingId, {this.minCount = 1});

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'buildingExists',
    'buildingId': buildingId,
    'minCount': minCount,
  };

  @override
  bool operator ==(Object other) =>
      other is BuildingExistsRequirement &&
      other.buildingId == buildingId &&
      other.minCount == minCount;

  @override
  int get hashCode => Object.hash(BuildingExistsRequirement, buildingId, minCount);
}

/// A flat cap on how many of this object the builder's team may have at
/// once (`null` today means "unlimited" - expressed here by simply omitting
/// this requirement rather than a magic value).
final class MaxCountRequirement extends BuildRequirement {
  final int max;

  const MaxCountRequirement(this.max);

  @override
  Map<String, dynamic> toJson() => {'kind': 'maxCount', 'max': max};

  @override
  bool operator ==(Object other) => other is MaxCountRequirement && other.max == max;

  @override
  int get hashCode => Object.hash(MaxCountRequirement, max);
}
