// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(wave) => "Best: wave ${wave}";

  static String m1(waves) => "All ${waves} waves repelled!";

  static String m2(percent) => "+${percent}% kill gold";

  static String m3(amount, seconds) => "+${amount}g in ${seconds}s";

  static String m4(health) => "AI BASE ${health}";

  static String m5(current, total) => "WAVE ${current} / ${total}";

  static String m6(tier) => "Tier ${tier}";

  static String m7(count) => "${count} WAVES";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountContinue": MessageLookupByLibrary.simpleMessage("CONTINUE"),
    "accountNameHint": MessageLookupByLibrary.simpleMessage("Your name"),
    "accountNameRequired": MessageLookupByLibrary.simpleMessage(
      "Please enter a name",
    ),
    "accountQuickPlay": MessageLookupByLibrary.simpleMessage("Quick Play"),
    "accountWelcomeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Enter your name to save your campaign progress.",
    ),
    "accountWelcomeTitle": MessageLookupByLibrary.simpleMessage(
      "Welcome, Commander",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("Boomspire"),
    "baseOverrunSubtitle": MessageLookupByLibrary.simpleMessage(
      "The circuit has been breached.",
    ),
    "baseOverrunTitle": MessageLookupByLibrary.simpleMessage("BASE OVERRUN"),
    "bestWaveReached": m0,
    "buildMenuBuildingsTab": MessageLookupByLibrary.simpleMessage("Buildings"),
    "buildMenuTowersTab": MessageLookupByLibrary.simpleMessage("Towers"),
    "buildingNameCommandPost": MessageLookupByLibrary.simpleMessage(
      "Command Post",
    ),
    "buildingNameGoldMine": MessageLookupByLibrary.simpleMessage("Gold Mine"),
    "buildingNameTechLab": MessageLookupByLibrary.simpleMessage("Tech Lab"),
    "buildingNameTrainingCenter": MessageLookupByLibrary.simpleMessage(
      "Training Center",
    ),
    "buildingNameWarFactory": MessageLookupByLibrary.simpleMessage(
      "War Factory",
    ),
    "changeMap": MessageLookupByLibrary.simpleMessage("CHANGE MAP"),
    "defenseHoldsSubtitle": m1,
    "defenseHoldsTitle": MessageLookupByLibrary.simpleMessage("DEFENSE HOLDS"),
    "enterFullscreenTooltip": MessageLookupByLibrary.simpleMessage(
      "Enter fullscreen",
    ),
    "exitConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Your current run will be lost.",
    ),
    "exitConfirmCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "exitConfirmConfirm": MessageLookupByLibrary.simpleMessage("Exit"),
    "exitConfirmTitle": MessageLookupByLibrary.simpleMessage("Leave battle?"),
    "exitFullscreenTooltip": MessageLookupByLibrary.simpleMessage(
      "Exit fullscreen",
    ),
    "exitToMenuTooltip": MessageLookupByLibrary.simpleMessage("Exit to menu"),
    "goldMineKillBonus": m2,
    "goldMinePayoutIn": m3,
    "hudAiBaseLabel": m4,
    "hudWaveLabel": m5,
    "levelSelectSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose a campaign",
    ),
    "levelSelectTitle": MessageLookupByLibrary.simpleMessage("BOOMSPIRE"),
    "mainMenuSinglePlayer": MessageLookupByLibrary.simpleMessage(
      "Single Player",
    ),
    "mainMenuSinglePlayerSubtitle": MessageLookupByLibrary.simpleMessage(
      "Campaigns and skirmishes, solo or vs AI",
    ),
    "mainMenuSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose your battle",
    ),
    "modeSelectSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose how you want to fight",
    ),
    "modeSelectTitle": MessageLookupByLibrary.simpleMessage("Single Player"),
    "modeSkirmishSubtitle": MessageLookupByLibrary.simpleMessage(
      "Build up and fight home vs home against the AI.",
    ),
    "modeSkirmishTitle": MessageLookupByLibrary.simpleMessage("Skirmish"),
    "modeTowerDefenseSubtitle": MessageLookupByLibrary.simpleMessage(
      "Survive escalating waves solo.",
    ),
    "modeTowerDefenseTitle": MessageLookupByLibrary.simpleMessage(
      "Tower Defense",
    ),
    "playAgain": MessageLookupByLibrary.simpleMessage("PLAY AGAIN"),
    "sceneCompleted": MessageLookupByLibrary.simpleMessage("COMPLETED"),
    "skirmishPlacementAi": MessageLookupByLibrary.simpleMessage("AI"),
    "skirmishPlacementPickHint": MessageLookupByLibrary.simpleMessage(
      "Pick a starting site to continue",
    ),
    "skirmishPlacementRandomize": MessageLookupByLibrary.simpleMessage(
      "Randomize",
    ),
    "skirmishPlacementStart": MessageLookupByLibrary.simpleMessage(
      "Start Battle",
    ),
    "skirmishPlacementSubtitleDraft": MessageLookupByLibrary.simpleMessage(
      "Tap a numbered site to claim it, or randomize",
    ),
    "skirmishPlacementSubtitleScene": MessageLookupByLibrary.simpleMessage(
      "Your base and the AI\'s are set for this battlefield",
    ),
    "skirmishPlacementTitle": MessageLookupByLibrary.simpleMessage(
      "Choose Your Base",
    ),
    "skirmishPlacementYou": MessageLookupByLibrary.simpleMessage("You"),
    "skirmishSelectCustomMaps": MessageLookupByLibrary.simpleMessage(
      "Your Maps",
    ),
    "skirmishSelectEmptyCustom": MessageLookupByLibrary.simpleMessage(
      "No custom skirmish maps yet - draw one in the Map Editor.",
    ),
    "skirmishSelectFeatured": MessageLookupByLibrary.simpleMessage("Featured"),
    "skirmishSelectSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose a battlefield",
    ),
    "skirmishSelectTitle": MessageLookupByLibrary.simpleMessage("Skirmish"),
    "skirmishVictorySubtitle": MessageLookupByLibrary.simpleMessage(
      "The enemy base has fallen!",
    ),
    "towerMax": MessageLookupByLibrary.simpleMessage("MAX"),
    "towerNameAntiAir": MessageLookupByLibrary.simpleMessage("Flak Battery"),
    "towerNameArtilleryBunker": MessageLookupByLibrary.simpleMessage(
      "Artillery Bunker",
    ),
    "towerNameCannon": MessageLookupByLibrary.simpleMessage("Siege Cannon"),
    "towerNameLaser": MessageLookupByLibrary.simpleMessage("Laser Lance"),
    "towerNameMachineGun": MessageLookupByLibrary.simpleMessage(
      "Gatling Turret",
    ),
    "towerNameRocket": MessageLookupByLibrary.simpleMessage("Rocket Battery"),
    "towerNameRocketSilo": MessageLookupByLibrary.simpleMessage("Rocket Silo"),
    "towerNameSam": MessageLookupByLibrary.simpleMessage("SAM Site"),
    "towerTier": m6,
    "wavesCount": m7,
  };
}
