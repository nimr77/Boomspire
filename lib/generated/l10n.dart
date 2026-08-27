// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Boomspire`
  String get appTitle {
    return Intl.message('Boomspire', name: 'appTitle', desc: '', args: []);
  }

  /// `BOOMSPIRE`
  String get levelSelectTitle {
    return Intl.message(
      'BOOMSPIRE',
      name: 'levelSelectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose a campaign`
  String get levelSelectSubtitle {
    return Intl.message(
      'Choose a campaign',
      name: 'levelSelectSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose your battle`
  String get mainMenuSubtitle {
    return Intl.message(
      'Choose your battle',
      name: 'mainMenuSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Single Player`
  String get mainMenuSinglePlayer {
    return Intl.message(
      'Single Player',
      name: 'mainMenuSinglePlayer',
      desc: '',
      args: [],
    );
  }

  /// `Campaigns and skirmishes, solo or vs AI`
  String get mainMenuSinglePlayerSubtitle {
    return Intl.message(
      'Campaigns and skirmishes, solo or vs AI',
      name: 'mainMenuSinglePlayerSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Single Player`
  String get modeSelectTitle {
    return Intl.message(
      'Single Player',
      name: 'modeSelectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose how you want to fight`
  String get modeSelectSubtitle {
    return Intl.message(
      'Choose how you want to fight',
      name: 'modeSelectSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Tower Defense`
  String get modeTowerDefenseTitle {
    return Intl.message(
      'Tower Defense',
      name: 'modeTowerDefenseTitle',
      desc: '',
      args: [],
    );
  }

  /// `Survive escalating waves solo.`
  String get modeTowerDefenseSubtitle {
    return Intl.message(
      'Survive escalating waves solo.',
      name: 'modeTowerDefenseSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Skirmish`
  String get modeSkirmishTitle {
    return Intl.message(
      'Skirmish',
      name: 'modeSkirmishTitle',
      desc: '',
      args: [],
    );
  }

  /// `Build up and fight home vs home against the AI.`
  String get modeSkirmishSubtitle {
    return Intl.message(
      'Build up and fight home vs home against the AI.',
      name: 'modeSkirmishSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Skirmish`
  String get skirmishSelectTitle {
    return Intl.message(
      'Skirmish',
      name: 'skirmishSelectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose a battlefield`
  String get skirmishSelectSubtitle {
    return Intl.message(
      'Choose a battlefield',
      name: 'skirmishSelectSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Featured`
  String get skirmishSelectFeatured {
    return Intl.message(
      'Featured',
      name: 'skirmishSelectFeatured',
      desc: '',
      args: [],
    );
  }

  /// `Your Maps`
  String get skirmishSelectCustomMaps {
    return Intl.message(
      'Your Maps',
      name: 'skirmishSelectCustomMaps',
      desc: '',
      args: [],
    );
  }

  /// `No custom skirmish maps yet - draw one in the Map Editor.`
  String get skirmishSelectEmptyCustom {
    return Intl.message(
      'No custom skirmish maps yet - draw one in the Map Editor.',
      name: 'skirmishSelectEmptyCustom',
      desc: '',
      args: [],
    );
  }

  /// `Choose Your Base`
  String get skirmishPlacementTitle {
    return Intl.message(
      'Choose Your Base',
      name: 'skirmishPlacementTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap a numbered site to claim it, or randomize`
  String get skirmishPlacementSubtitleDraft {
    return Intl.message(
      'Tap a numbered site to claim it, or randomize',
      name: 'skirmishPlacementSubtitleDraft',
      desc: '',
      args: [],
    );
  }

  /// `Your base and the AI's are set for this battlefield`
  String get skirmishPlacementSubtitleScene {
    return Intl.message(
      'Your base and the AI\'s are set for this battlefield',
      name: 'skirmishPlacementSubtitleScene',
      desc: '',
      args: [],
    );
  }

  /// `Randomize`
  String get skirmishPlacementRandomize {
    return Intl.message(
      'Randomize',
      name: 'skirmishPlacementRandomize',
      desc: '',
      args: [],
    );
  }

  /// `Start Battle`
  String get skirmishPlacementStart {
    return Intl.message(
      'Start Battle',
      name: 'skirmishPlacementStart',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get skirmishPlacementYou {
    return Intl.message(
      'You',
      name: 'skirmishPlacementYou',
      desc: '',
      args: [],
    );
  }

  /// `AI`
  String get skirmishPlacementAi {
    return Intl.message('AI', name: 'skirmishPlacementAi', desc: '', args: []);
  }

  /// `Pick a starting site to continue`
  String get skirmishPlacementPickHint {
    return Intl.message(
      'Pick a starting site to continue',
      name: 'skirmishPlacementPickHint',
      desc: '',
      args: [],
    );
  }

  /// `{count} WAVES`
  String wavesCount(int count) {
    return Intl.message(
      '$count WAVES',
      name: 'wavesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Best: wave {wave}`
  String bestWaveReached(int wave) {
    return Intl.message(
      'Best: wave $wave',
      name: 'bestWaveReached',
      desc: '',
      args: [wave],
    );
  }

  /// `COMPLETED`
  String get sceneCompleted {
    return Intl.message(
      'COMPLETED',
      name: 'sceneCompleted',
      desc: '',
      args: [],
    );
  }

  /// `WAVE {current} / {total}`
  String hudWaveLabel(int current, int total) {
    return Intl.message(
      'WAVE $current / $total',
      name: 'hudWaveLabel',
      desc: '',
      args: [current, total],
    );
  }

  /// `AI BASE {health}`
  String hudAiBaseLabel(int health) {
    return Intl.message(
      'AI BASE $health',
      name: 'hudAiBaseLabel',
      desc: '',
      args: [health],
    );
  }

  /// `BASE OVERRUN`
  String get baseOverrunTitle {
    return Intl.message(
      'BASE OVERRUN',
      name: 'baseOverrunTitle',
      desc: '',
      args: [],
    );
  }

  /// `The circuit has been breached.`
  String get baseOverrunSubtitle {
    return Intl.message(
      'The circuit has been breached.',
      name: 'baseOverrunSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `DEFENSE HOLDS`
  String get defenseHoldsTitle {
    return Intl.message(
      'DEFENSE HOLDS',
      name: 'defenseHoldsTitle',
      desc: '',
      args: [],
    );
  }

  /// `All {waves} waves repelled!`
  String defenseHoldsSubtitle(int waves) {
    return Intl.message(
      'All $waves waves repelled!',
      name: 'defenseHoldsSubtitle',
      desc: '',
      args: [waves],
    );
  }

  /// `The enemy base has fallen!`
  String get skirmishVictorySubtitle {
    return Intl.message(
      'The enemy base has fallen!',
      name: 'skirmishVictorySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `PLAY AGAIN`
  String get playAgain {
    return Intl.message('PLAY AGAIN', name: 'playAgain', desc: '', args: []);
  }

  /// `CHANGE MAP`
  String get changeMap {
    return Intl.message('CHANGE MAP', name: 'changeMap', desc: '', args: []);
  }

  /// `Exit fullscreen`
  String get exitFullscreenTooltip {
    return Intl.message(
      'Exit fullscreen',
      name: 'exitFullscreenTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Enter fullscreen`
  String get enterFullscreenTooltip {
    return Intl.message(
      'Enter fullscreen',
      name: 'enterFullscreenTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Exit to menu`
  String get exitToMenuTooltip {
    return Intl.message(
      'Exit to menu',
      name: 'exitToMenuTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Leave battle?`
  String get exitConfirmTitle {
    return Intl.message(
      'Leave battle?',
      name: 'exitConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your current run will be lost.`
  String get exitConfirmBody {
    return Intl.message(
      'Your current run will be lost.',
      name: 'exitConfirmBody',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exitConfirmConfirm {
    return Intl.message('Exit', name: 'exitConfirmConfirm', desc: '', args: []);
  }

  /// `Cancel`
  String get exitConfirmCancel {
    return Intl.message(
      'Cancel',
      name: 'exitConfirmCancel',
      desc: '',
      args: [],
    );
  }

  /// `MAX`
  String get towerMax {
    return Intl.message('MAX', name: 'towerMax', desc: '', args: []);
  }

  /// `Tier {tier}`
  String towerTier(int tier) {
    return Intl.message(
      'Tier $tier',
      name: 'towerTier',
      desc: '',
      args: [tier],
    );
  }

  /// `Welcome, Commander`
  String get accountWelcomeTitle {
    return Intl.message(
      'Welcome, Commander',
      name: 'accountWelcomeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your name to save your campaign progress.`
  String get accountWelcomeSubtitle {
    return Intl.message(
      'Enter your name to save your campaign progress.',
      name: 'accountWelcomeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Your name`
  String get accountNameHint {
    return Intl.message(
      'Your name',
      name: 'accountNameHint',
      desc: '',
      args: [],
    );
  }

  /// `CONTINUE`
  String get accountContinue {
    return Intl.message(
      'CONTINUE',
      name: 'accountContinue',
      desc: '',
      args: [],
    );
  }

  /// `Quick Play`
  String get accountQuickPlay {
    return Intl.message(
      'Quick Play',
      name: 'accountQuickPlay',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name`
  String get accountNameRequired {
    return Intl.message(
      'Please enter a name',
      name: 'accountNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Towers`
  String get buildMenuTowersTab {
    return Intl.message(
      'Towers',
      name: 'buildMenuTowersTab',
      desc: '',
      args: [],
    );
  }

  /// `Buildings`
  String get buildMenuBuildingsTab {
    return Intl.message(
      'Buildings',
      name: 'buildMenuBuildingsTab',
      desc: '',
      args: [],
    );
  }

  /// `Gatling Turret`
  String get towerNameMachineGun {
    return Intl.message(
      'Gatling Turret',
      name: 'towerNameMachineGun',
      desc: '',
      args: [],
    );
  }

  /// `Rocket Battery`
  String get towerNameRocket {
    return Intl.message(
      'Rocket Battery',
      name: 'towerNameRocket',
      desc: '',
      args: [],
    );
  }

  /// `Siege Cannon`
  String get towerNameCannon {
    return Intl.message(
      'Siege Cannon',
      name: 'towerNameCannon',
      desc: '',
      args: [],
    );
  }

  /// `Flak Battery`
  String get towerNameAntiAir {
    return Intl.message(
      'Flak Battery',
      name: 'towerNameAntiAir',
      desc: '',
      args: [],
    );
  }

  /// `Laser Lance`
  String get towerNameLaser {
    return Intl.message(
      'Laser Lance',
      name: 'towerNameLaser',
      desc: '',
      args: [],
    );
  }

  /// `Rocket Silo`
  String get towerNameRocketSilo {
    return Intl.message(
      'Rocket Silo',
      name: 'towerNameRocketSilo',
      desc: '',
      args: [],
    );
  }

  /// `Artillery Bunker`
  String get towerNameArtilleryBunker {
    return Intl.message(
      'Artillery Bunker',
      name: 'towerNameArtilleryBunker',
      desc: '',
      args: [],
    );
  }

  /// `SAM Site`
  String get towerNameSam {
    return Intl.message('SAM Site', name: 'towerNameSam', desc: '', args: []);
  }

  /// `Tech Lab`
  String get buildingNameTechLab {
    return Intl.message(
      'Tech Lab',
      name: 'buildingNameTechLab',
      desc: '',
      args: [],
    );
  }

  /// `Command Post`
  String get buildingNameCommandPost {
    return Intl.message(
      'Command Post',
      name: 'buildingNameCommandPost',
      desc: '',
      args: [],
    );
  }

  /// `Training Center`
  String get buildingNameTrainingCenter {
    return Intl.message(
      'Training Center',
      name: 'buildingNameTrainingCenter',
      desc: '',
      args: [],
    );
  }

  /// `War Factory`
  String get buildingNameWarFactory {
    return Intl.message(
      'War Factory',
      name: 'buildingNameWarFactory',
      desc: '',
      args: [],
    );
  }

  /// `Gold Mine`
  String get buildingNameGoldMine {
    return Intl.message(
      'Gold Mine',
      name: 'buildingNameGoldMine',
      desc: '',
      args: [],
    );
  }

  /// `+{amount}g in {seconds}s`
  String goldMinePayoutIn(int amount, int seconds) {
    return Intl.message(
      '+${amount}g in ${seconds}s',
      name: 'goldMinePayoutIn',
      desc: '',
      args: [amount, seconds],
    );
  }

  /// `+{percent}% kill gold`
  String goldMineKillBonus(int percent) {
    return Intl.message(
      '+$percent% kill gold',
      name: 'goldMineKillBonus',
      desc: '',
      args: [percent],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
