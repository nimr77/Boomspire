/// Who claims a [HomeSite] once a [GameMode.skirmish] match starts - a
/// future lobby/team-select screen assigns a real `Team` to every `player`
/// seat (and, for now, a scripted opponent to every `ai` seat).
enum HomeSiteOwner { player, ai }
