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

  /// `Easy`
  String get difficultyLabelEasy {
    return Intl.message(
      'Easy',
      name: 'difficultyLabelEasy',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get difficultyLabelNormal {
    return Intl.message(
      'Normal',
      name: 'difficultyLabelNormal',
      desc: '',
      args: [],
    );
  }

  /// `Hard`
  String get difficultyLabelHard {
    return Intl.message(
      'Hard',
      name: 'difficultyLabelHard',
      desc: '',
      args: [],
    );
  }

  /// `Grass Plains`
  String get biomeNameGrassPlains {
    return Intl.message(
      'Grass Plains',
      name: 'biomeNameGrassPlains',
      desc: '',
      args: [],
    );
  }

  /// `Snow Tundra`
  String get biomeNameSnowTundra {
    return Intl.message(
      'Snow Tundra',
      name: 'biomeNameSnowTundra',
      desc: '',
      args: [],
    );
  }

  /// `Desert Dunes`
  String get biomeNameDesertDunes {
    return Intl.message(
      'Desert Dunes',
      name: 'biomeNameDesertDunes',
      desc: '',
      args: [],
    );
  }

  /// `Mountain Forest`
  String get biomeNameMountainForest {
    return Intl.message(
      'Mountain Forest',
      name: 'biomeNameMountainForest',
      desc: '',
      args: [],
    );
  }

  /// `City Ruins`
  String get biomeNameCityRuins {
    return Intl.message(
      'City Ruins',
      name: 'biomeNameCityRuins',
      desc: '',
      args: [],
    );
  }

  /// `Savanna`
  String get biomeNameSavanna {
    return Intl.message(
      'Savanna',
      name: 'biomeNameSavanna',
      desc: '',
      args: [],
    );
  }

  /// `Frozen Peaks`
  String get biomeNameFrozenPeaks {
    return Intl.message(
      'Frozen Peaks',
      name: 'biomeNameFrozenPeaks',
      desc: '',
      args: [],
    );
  }

  /// `Open Sea`
  String get biomeNameSea {
    return Intl.message('Open Sea', name: 'biomeNameSea', desc: '', args: []);
  }

  /// `Open fields, rocky ridges, a winding river.`
  String get biomeDescriptionGrassPlains {
    return Intl.message(
      'Open fields, rocky ridges, a winding river.',
      name: 'biomeDescriptionGrassPlains',
      desc: '',
      args: [],
    );
  }

  /// `Frozen ground, snow-capped peaks, an icy river.`
  String get biomeDescriptionSnowTundra {
    return Intl.message(
      'Frozen ground, snow-capped peaks, an icy river.',
      name: 'biomeDescriptionSnowTundra',
      desc: '',
      args: [],
    );
  }

  /// `Sun-scorched dunes carved by a dry canyon.`
  String get biomeDescriptionDesertDunes {
    return Intl.message(
      'Sun-scorched dunes carved by a dry canyon.',
      name: 'biomeDescriptionDesertDunes',
      desc: '',
      args: [],
    );
  }

  /// `Dense pine-covered peaks and a rushing river.`
  String get biomeDescriptionMountainForest {
    return Intl.message(
      'Dense pine-covered peaks and a rushing river.',
      name: 'biomeDescriptionMountainForest',
      desc: '',
      args: [],
    );
  }

  /// `Collapsed towers and rubble-choked streets.`
  String get biomeDescriptionCityRuins {
    return Intl.message(
      'Collapsed towers and rubble-choked streets.',
      name: 'biomeDescriptionCityRuins',
      desc: '',
      args: [],
    );
  }

  /// `Golden grassland, acacia stands, a dry river.`
  String get biomeDescriptionSavanna {
    return Intl.message(
      'Golden grassland, acacia stands, a dry river.',
      name: 'biomeDescriptionSavanna',
      desc: '',
      args: [],
    );
  }

  /// `Sheer ice-clad summits above a frozen crevasse.`
  String get biomeDescriptionFrozenPeaks {
    return Intl.message(
      'Sheer ice-clad summits above a frozen crevasse.',
      name: 'biomeDescriptionFrozenPeaks',
      desc: '',
      args: [],
    );
  }

  /// `Open water studded with reefs - the fleet closes in.`
  String get biomeDescriptionSea {
    return Intl.message(
      'Open water studded with reefs - the fleet closes in.',
      name: 'biomeDescriptionSea',
      desc: '',
      args: [],
    );
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

  /// `Testing as single-base - add another home site for a full skirmish.`
  String get skirmishPlacementSingleBaseNotice {
    return Intl.message(
      'Testing as single-base - add another home site for a full skirmish.',
      name: 'skirmishPlacementSingleBaseNotice',
      desc: '',
      args: [],
    );
  }

  /// `Testing your hand-drawn skirmish map.`
  String get skirmishPlacementTestBriefing {
    return Intl.message(
      'Testing your hand-drawn skirmish map.',
      name: 'skirmishPlacementTestBriefing',
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

  /// `Power Plant`
  String get buildingNamePowerPlant {
    return Intl.message(
      'Power Plant',
      name: 'buildingNamePowerPlant',
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

  /// `Back`
  String get backTooltip {
    return Intl.message('Back', name: 'backTooltip', desc: '', args: []);
  }

  /// `Map Editor`
  String get mapEditorTooltip {
    return Intl.message(
      'Map Editor',
      name: 'mapEditorTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Mountain`
  String get mountainLabelEditorPage {
    return Intl.message(
      'Mountain',
      name: 'mountainLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Dune`
  String get duneLabelEditorPage {
    return Intl.message(
      'Dune',
      name: 'duneLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Erase`
  String get eraseLabelEditorPage {
    return Intl.message(
      'Erase',
      name: 'eraseLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `River`
  String get riverLabelEditorPage {
    return Intl.message(
      'River',
      name: 'riverLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Lake`
  String get lakeLabelEditorPage {
    return Intl.message(
      'Lake',
      name: 'lakeLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Tree`
  String get treeLabelEditorPage {
    return Intl.message(
      'Tree',
      name: 'treeLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get homeLabelEditorPage {
    return Intl.message(
      'Home',
      name: 'homeLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get playLabelEditorPage {
    return Intl.message(
      'Play',
      name: 'playLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveLabelEditorPage {
    return Intl.message(
      'Save',
      name: 'saveLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get downloadLabelEditorPage {
    return Intl.message(
      'Download',
      name: 'downloadLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get uploadLabelEditorPage {
    return Intl.message(
      'Upload',
      name: 'uploadLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Zoom out`
  String get zoomOutTooltipEditorPage {
    return Intl.message(
      'Zoom out',
      name: 'zoomOutTooltipEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Zoom in`
  String get zoomInTooltipEditorPage {
    return Intl.message(
      'Zoom in',
      name: 'zoomInTooltipEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Reset zoom`
  String get resetZoomTooltipEditorPage {
    return Intl.message(
      'Reset zoom',
      name: 'resetZoomTooltipEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `{percent}%`
  String zoomPercentEditorPage(int percent) {
    return Intl.message(
      '$percent%',
      name: 'zoomPercentEditorPage',
      desc: '',
      args: [percent],
    );
  }

  /// `Brush`
  String get brushLabelEditorPage {
    return Intl.message(
      'Brush',
      name: 'brushLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Home sites: {count}/{max} - tap to place, tap a marker to remove.`
  String homeSitesHintEditorPage(int count, int max) {
    return Intl.message(
      'Home sites: $count/$max - tap to place, tap a marker to remove.',
      name: 'homeSitesHintEditorPage',
      desc: '',
      args: [count, max],
    );
  }

  /// `River width: {width}`
  String riverWidthLabelEditorPage(int width) {
    return Intl.message(
      'River width: $width',
      name: 'riverWidthLabelEditorPage',
      desc: '',
      args: [width],
    );
  }

  /// `Type`
  String get brushTypeLabelEditorPage {
    return Intl.message(
      'Type',
      name: 'brushTypeLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Match biome`
  String get brushTypeMatchBiomeEditorPage {
    return Intl.message(
      'Match biome',
      name: 'brushTypeMatchBiomeEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get mapLabelEditorPage {
    return Intl.message('Map', name: 'mapLabelEditorPage', desc: '', args: []);
  }

  /// `Biome`
  String get biomeLabelEditorPage {
    return Intl.message(
      'Biome',
      name: 'biomeLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `This biome scatters trees automatically - use the Tree tool to add more anywhere`
  String get treesOnHintEditorPage {
    return Intl.message(
      'This biome scatters trees automatically - use the Tree tool to add more anywhere',
      name: 'treesOnHintEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `This biome has no automatic trees - use the Tree tool to add your own`
  String get treesOffHintEditorPage {
    return Intl.message(
      'This biome has no automatic trees - use the Tree tool to add your own',
      name: 'treesOffHintEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Mode`
  String get modeLabelEditorPage {
    return Intl.message(
      'Mode',
      name: 'modeLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Wave Defense`
  String get waveDefenseOptionEditorPage {
    return Intl.message(
      'Wave Defense',
      name: 'waveDefenseOptionEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Skirmish`
  String get skirmishOptionEditorPage {
    return Intl.message(
      'Skirmish',
      name: 'skirmishOptionEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Width`
  String get widthLabelEditorPage {
    return Intl.message(
      'Width',
      name: 'widthLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Height`
  String get heightLabelEditorPage {
    return Intl.message(
      'Height',
      name: 'heightLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Starting gold`
  String get startingGoldLabelEditorPage {
    return Intl.message(
      'Starting gold',
      name: 'startingGoldLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Waves`
  String get wavesLabelEditorPage {
    return Intl.message(
      'Waves',
      name: 'wavesLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Number of waves`
  String get waveCountLabelEditorPage {
    return Intl.message(
      'Number of waves',
      name: 'waveCountLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Randomize all {count} waves`
  String randomizeAllWavesLabelEditorPage(int count) {
    return Intl.message(
      'Randomize all $count waves',
      name: 'randomizeAllWavesLabelEditorPage',
      desc: '',
      args: [count],
    );
  }

  /// `Previous wave`
  String get previousWaveTooltipEditorPage {
    return Intl.message(
      'Previous wave',
      name: 'previousWaveTooltipEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Next wave`
  String get nextWaveTooltipEditorPage {
    return Intl.message(
      'Next wave',
      name: 'nextWaveTooltipEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Wave {current} / {total}`
  String waveHeaderEditorPage(int current, int total) {
    return Intl.message(
      'Wave $current / $total',
      name: 'waveHeaderEditorPage',
      desc: '',
      args: [current, total],
    );
  }

  /// ` (auto)`
  String get autoSuffixEditorPage {
    return Intl.message(
      ' (auto)',
      name: 'autoSuffixEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Fewer`
  String get fewerTooltipEditorPage {
    return Intl.message(
      'Fewer',
      name: 'fewerTooltipEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get moreTooltipEditorPage {
    return Intl.message(
      'More',
      name: 'moreTooltipEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Randomize`
  String get randomizeWaveLabelEditorPage {
    return Intl.message(
      'Randomize',
      name: 'randomizeWaveLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Reset to auto`
  String get resetToAutoLabelEditorPage {
    return Intl.message(
      'Reset to auto',
      name: 'resetToAutoLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Environment`
  String get environmentLabelEditorPage {
    return Intl.message(
      'Environment',
      name: 'environmentLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Dynamic weather over match`
  String get dynamicWeatherLabelEditorPage {
    return Intl.message(
      'Dynamic weather over match',
      name: 'dynamicWeatherLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Sun angle: {percent}%`
  String sunAngleLabelEditorPage(int percent) {
    return Intl.message(
      'Sun angle: $percent%',
      name: 'sunAngleLabelEditorPage',
      desc: '',
      args: [percent],
    );
  }

  /// `Preview weather at: {percent}% of match`
  String previewWeatherLabelEditorPage(int percent) {
    return Intl.message(
      'Preview weather at: $percent% of match',
      name: 'previewWeatherLabelEditorPage',
      desc: '',
      args: [percent],
    );
  }

  /// `Weather timeline`
  String get weatherTimelineLabelEditorPage {
    return Intl.message(
      'Weather timeline',
      name: 'weatherTimelineLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Only the first keyframe applies while Dynamic Weather is off`
  String get singleKeyframeHintEditorPage {
    return Intl.message(
      'Only the first keyframe applies while Dynamic Weather is off',
      name: 'singleKeyframeHintEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Add keyframe`
  String get addKeyframeLabelEditorPage {
    return Intl.message(
      'Add keyframe',
      name: 'addKeyframeLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `At {percent}% of match`
  String keyframeAtProgressLabelEditorPage(int percent) {
    return Intl.message(
      'At $percent% of match',
      name: 'keyframeAtProgressLabelEditorPage',
      desc: '',
      args: [percent],
    );
  }

  /// `Wind`
  String get windLabelEditorPage {
    return Intl.message(
      'Wind',
      name: 'windLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Rain`
  String get rainLabelEditorPage {
    return Intl.message(
      'Rain',
      name: 'rainLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Snow`
  String get snowLabelEditorPage {
    return Intl.message(
      'Snow',
      name: 'snowLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Fog`
  String get fogLabelEditorPage {
    return Intl.message('Fog', name: 'fogLabelEditorPage', desc: '', args: []);
  }

  /// `Cloud`
  String get cloudLabelEditorPage {
    return Intl.message(
      'Cloud',
      name: 'cloudLabelEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Only {max} home sites supported`
  String onlyHomeSitesSupportedEditorPage(int max) {
    return Intl.message(
      'Only $max home sites supported',
      name: 'onlyHomeSitesSupportedEditorPage',
      desc: '',
      args: [max],
    );
  }

  /// `Downloaded "{name}"`
  String downloadedMapEditorPage(String name) {
    return Intl.message(
      'Downloaded "$name"',
      name: 'downloadedMapEditorPage',
      desc: '',
      args: [name],
    );
  }

  /// `Testing as wave defense - skirmish playtesting is coming soon.`
  String get skirmishPlaytestComingSoonEditorPage {
    return Intl.message(
      'Testing as wave defense - skirmish playtesting is coming soon.',
      name: 'skirmishPlaytestComingSoonEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Saved "{name}"`
  String savedMapEditorPage(String name) {
    return Intl.message(
      'Saved "$name"',
      name: 'savedMapEditorPage',
      desc: '',
      args: [name],
    );
  }

  /// `Imported "{name}"`
  String importedMapEditorPage(String name) {
    return Intl.message(
      'Imported "$name"',
      name: 'importedMapEditorPage',
      desc: '',
      args: [name],
    );
  }

  /// `Could not read that file as a map`
  String get couldNotReadMapEditorPage {
    return Intl.message(
      'Could not read that file as a map',
      name: 'couldNotReadMapEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Untitled Map`
  String get untitledMapEditorPage {
    return Intl.message(
      'Untitled Map',
      name: 'untitledMapEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Testing your hand-drawn map draft.`
  String get testingHandDrawnMapBriefingEditorPage {
    return Intl.message(
      'Testing your hand-drawn map draft.',
      name: 'testingHandDrawnMapBriefingEditorPage',
      desc: '',
      args: [],
    );
  }

  /// `Bullets`
  String get weaponLabelBullet {
    return Intl.message(
      'Bullets',
      name: 'weaponLabelBullet',
      desc: '',
      args: [],
    );
  }

  /// `Cannon Shells`
  String get weaponLabelCannon {
    return Intl.message(
      'Cannon Shells',
      name: 'weaponLabelCannon',
      desc: '',
      args: [],
    );
  }

  /// `Rockets`
  String get weaponLabelRocket {
    return Intl.message(
      'Rockets',
      name: 'weaponLabelRocket',
      desc: '',
      args: [],
    );
  }

  /// `Laser Beam`
  String get weaponLabelLaser {
    return Intl.message(
      'Laser Beam',
      name: 'weaponLabelLaser',
      desc: '',
      args: [],
    );
  }

  /// `HP {current}/{max}`
  String hpLabelEntityPanel(int current, int max) {
    return Intl.message(
      'HP $current/$max',
      name: 'hpLabelEntityPanel',
      desc: '',
      args: [current, max],
    );
  }

  /// `Active`
  String get activeLabelEntityPanel {
    return Intl.message(
      'Active',
      name: 'activeLabelEntityPanel',
      desc: '',
      args: [],
    );
  }

  /// `Unclaimed`
  String get unclaimedLabelEntityPanel {
    return Intl.message(
      'Unclaimed',
      name: 'unclaimedLabelEntityPanel',
      desc: '',
      args: [],
    );
  }

  /// `PRODUCE UNITS`
  String get produceUnitsLabelBuildMenu {
    return Intl.message(
      'PRODUCE UNITS',
      name: 'produceUnitsLabelBuildMenu',
      desc: '',
      args: [],
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
