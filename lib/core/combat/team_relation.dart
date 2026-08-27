/// How two [Team]s regard each other - always derived from comparing their
/// numeric ids (see `Team.relationTo`) instead of a stored true/false flag,
/// so it stays correct no matter how many teams end up sharing a scene.
enum TeamRelation { ally, enemy }
