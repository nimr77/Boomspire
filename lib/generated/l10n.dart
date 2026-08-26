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

  /// `Circuit Defense`
  String get appTitle {
    return Intl.message(
      'Circuit Defense',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `CIRCUIT DEFENSE`
  String get levelSelectTitle {
    return Intl.message(
      'CIRCUIT DEFENSE',
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
