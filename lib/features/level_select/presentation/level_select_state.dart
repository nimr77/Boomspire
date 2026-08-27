import 'package:flutter/foundation.dart';

import '../../progress/domain/models/progress_snapshot.dart';
import '../../progress/domain/repos/progress_repository.dart';

/// Page-owned state for [LevelSelectPage]: loads campaign progress once and
/// exposes it read-only. Instantiated and disposed by the page's own
/// State - not shared anywhere else.
class LevelSelectState {
  final ProgressRepository _progressRepository;
  final ValueNotifier<ProgressSnapshot?> _progress = ValueNotifier(null);

  LevelSelectState(this._progressRepository);

  ValueListenable<ProgressSnapshot?> get progress => _progress;

  void dispose() {
    _progress.dispose();
  }

  Future<void> load() async {
    _progress.value = await _progressRepository.load();
  }
}
