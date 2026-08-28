---
description: "Use when creating or modifying any Flutter page, dialog, or widget in a feature's presentation layer, or when wiring a repository into the UI. Covers the mandatory state-layer architecture: no business logic in pages/widgets, GetIt-owned state lifecycle, and the public/private function shape."
applyTo: "lib/features/**/presentation/**,lib/core/widgets/**"
---

# Presentation state layer (mandatory)

Applies to Flutter **pages, dialogs, and widgets** (menus, lists, editors,
HUD overlays). It does NOT apply to Flame `Component`/`FlameGame` gameplay
entities (`*_component.dart`, `boomspire_game.dart`, `game_world.dart`) -
those are the real-time simulation/engine layer and already follow the
documented constructor-injected composition-root pattern (see
`game_page.dart` wiring `BoomspireGame`); do not force this state-layer
pattern onto them.

## Where logic lives

- A page/widget file (anything under `presentation/`, outside `state/`)
  contains ONLY: layout (`build()`), wiring a `ValueListenableBuilder`/
  `ListenableBuilder`/`AnimatedBuilder` to a state object, `TextEditingController`/
  `AnimationController` bookkeeping, and calling **public** methods on a
  `*State` object in response to user input. No repository calls, no
  parsing/validation/calculation, no branching business logic directly in a
  widget's `build`/callback.
- Every piece of logic that talks to a repository (this feature's own, or
  another feature's) lives in a `*State` class under
  `lib/features/<feature>/presentation/state/`.
- One feature can (and should, when it has more than one flow) have MORE
  THAN ONE state class - split by responsibility (e.g. a feature's editing
  flow vs. its save/load/export flow get separate `*State` classes) instead
  of one God-state per page.
- A state class may depend on another feature's repository OR another
  state class from this or another feature (constructor-injected) - exactly
  like a repository can depend on another repository.

## Exception: BuildContext-bound framework calls

Navigation (`Navigator`/`go_router` `context.push`), `Overlay.of(context)`,
`Theme.of(context)`, `ScaffoldMessenger.of(context)`, and similar APIs that
strictly require a `BuildContext` stay as a single call in the page. The
state class does all the data prep/decision-making and hands the page
ready-to-use data (e.g. a `GameRouteArgs`); the page performs the bare
framework call with no additional logic around it. A state class exposes
"please show this" moments (toasts, dialogs) via a plain
`ValueNotifier<SomeNotice?>` that the page listens to and reacts to.

## Repository wiring

- State classes never construct a `*RepositoryImpl` directly - they accept
  the repository interface via constructor injection, resolved through
  `getIt<SomeRepository>()` at the registration site (see below).

## GetIt registration & lifecycle

Every state class is registered with and resolved through `getIt`, never
hand-held as `final x = SomeState(getIt<Repo>());` on a page's State object.

- **App-wide state** (lives for the whole app session, e.g. an account
  profile holder): register with `getIt.registerLazySingleton` in
  `lib/core/di/service_locator.dart`, resolved anywhere with `getIt<XState>()`.
- **Page-scoped state** (only needed while one page is on screen): register
  fresh in that page's `initState()` and **unregister in `dispose()`**.
  `initState` must re-register every time the page is entered - never
  assume a stale registration survives a previous visit.

```dart
@override
void initState() {
  super.initState();
  getIt.registerSingleton<MyPageState>(
    MyPageState(getIt<SomeRepository>()),
  );
  _state = getIt<MyPageState>();
}

@override
void dispose() {
  _state.dispose();
  getIt.unregister<MyPageState>();
  super.dispose();
}
```

## Public vs. private function shape

- A **public** method is an entry point the page calls (e.g. `load()`,
  `save()`, `toggleHomeSiteAt(point)`) - it reads like a numbered list of
  instructions: call a private step, call another private step, then
  branch on what they returned.
- Each step/calculation is its OWN **private** method (`_computeX`,
  `_validateY`, `_applyZ`) that does exactly ONE task and returns a result.
  A private method never itself decides what happens next in the flow.
- Branching (`if`/`switch` deciding what the flow does next) belongs in the
  PUBLIC method, using values private helpers returned - never buried
  inside a private helper.

```dart
// GOOD
void toggleHomeSiteAt(EditorPoint point) {
  final existingIndex = _findHomeSiteNear(point);   // private, one task
  final max = maxHomeSites;                          // private, one task (wrapped)
  if (existingIndex == -1 && draft.value.homeSites.length >= max) {
    _notice.value = MapEditorNotice('Only $max home sites supported');
    return;
  }
  _mutateDraft(existingIndex != -1
      ? (d) => _withHomeSiteRemoved(d, existingIndex)  // private, one task
      : (d) => _withHomeSiteAdded(d, point));          // private, one task
}
```

## Feature widgets folder

- Every small presentational class a page uses (buttons, painters, toasts,
  section labels, list-item editors, etc.) lives in its OWN file under
  `lib/features/<feature>/presentation/widgets/` - never as an extra
  private class stacked at the bottom of a page file. One class per file.
- Naming: file `<feature_name>_<what_it_is>_widget.dart`, class
  `FeatureNameWhatItIsWidget` - always ends with `Widget`, `Page`, or
  `State` (a `CustomPainter` may end with `Painter` instead, matching
  Flutter's own convention for that role, e.g. `MapEditorCanvasPainter`).
- A finished page file should contain only its own `State` class
  (layout/wiring) - if it still has other classes below it, extract them.

## No hardcoded UI text

- Every user-facing string (labels, tooltips, button text, toast/notice
  messages) goes in `lib/l10n/intl_en.arb`, read via `S.current.<key>`
  (`import '.../generated/l10n.dart';`) - `S.current` does NOT need a
  `BuildContext`, so state classes may use it too for notice messages.
  Never a raw string literal in a widget's `build()` or a state class's
  logic.
- Key naming: suffix the key with the page/feature it belongs to so keys
  don't collide across features, e.g. `S.current.homeLabelEditorPage`.
- After adding/editing ARB entries, run `dart run intl_utils:generate`
  (`tool/codegen.sh` runs this alongside freezed/asset codegen) to
  regenerate `lib/generated/l10n.dart` - never hand-edit that file.

## Migration status

Existing `*State` classes were moved from directly under `presentation/`
into `presentation/state/` and wired through GetIt per this rule:
`AccountProfileState`, `LevelSelectState`, `MapDraftsListState`,
`SkirmishPlacementState`, `SkirmishLevelSelectState`, and the map editor's
`MapEditorDraftState`/`MapEditorPersistenceState`. Any other page/widget
still holding logic directly needs a new `*State` extracted the same way
before it's touched again.
