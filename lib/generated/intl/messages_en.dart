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

  static String m2(current, total) => "WAVE ${current} / ${total}";

  static String m3(tier) => "Tier ${tier}";

  static String m4(count) => "${count} WAVES";

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
    "hudWaveLabel": m2,
    "levelSelectSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose a campaign",
    ),
    "levelSelectTitle": MessageLookupByLibrary.simpleMessage("BOOMSPIRE"),
    "playAgain": MessageLookupByLibrary.simpleMessage("PLAY AGAIN"),
    "sceneCompleted": MessageLookupByLibrary.simpleMessage("COMPLETED"),
    "towerMax": MessageLookupByLibrary.simpleMessage("MAX"),
    "towerTier": m3,
    "wavesCount": m4,
  };
}
