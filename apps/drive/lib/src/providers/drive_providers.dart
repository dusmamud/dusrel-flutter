import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drive_repository.dart';
import '../models/drive_file.dart';

/// The repository the app reads from. Mock today, real backend later —
/// the UI only depends on the [DriveRepository] interface.
final driveRepositoryProvider = Provider<DriveRepository>(
  (ref) => MockDriveRepository(),
);

/// The full file list. Loads once (with a short delay so the skeleton
/// shows), then refreshes after every mutation.
final filesProvider =
    AsyncNotifierProvider<FilesNotifier, List<DriveFile>>(FilesNotifier.new);

class FilesNotifier extends AsyncNotifier<List<DriveFile>> {
  DriveRepository get _repo => ref.read(driveRepositoryProvider);

  @override
  Future<List<DriveFile>> build() => _repo.listAll();

  Future<void> _refresh() async {
    state = AsyncValue.data(await _repo.listAll());
  }

  Future<void> toggleStar(String id) async {
    await _repo.toggleStar(id);
    await _refresh();
  }

  Future<void> toggleOffline(String id) async {
    await _repo.toggleOffline(id);
    await _refresh();
  }

  Future<void> moveToTrash(String id) async {
    await _repo.moveToTrash(id);
    await _refresh();
  }

  Future<void> restore(String id) async {
    await _repo.restore(id);
    await _refresh();
  }

  Future<void> deleteForever(String id) async {
    await _repo.deleteForever(id);
    await _refresh();
  }

  Future<void> rename(String id, String newName) async {
    await _repo.rename(id, newName);
    await _refresh();
  }

  Future<void> createFolder(String name, String? parentId) async {
    await _repo.createFolder(name, parentId);
    await _refresh();
  }

  Future<void> addFile(DriveFile file) async {
    await _repo.addFile(file);
    await _refresh();
  }

  Future<void> emptyTrash() async {
    await _repo.emptyTrash();
    await _refresh();
  }
}

/// The folder currently open in the Files tab. Null = root of My Drive.
final currentFolderProvider =
    NotifierProvider<CurrentFolderNotifier, String?>(CurrentFolderNotifier.new);

class CurrentFolderNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void open(String? folderId) => state = folderId;
}

/// List (false) or grid (true) view for file lists.
/// List is the default for metadata views; Photos uses a grid.
final viewModeProvider =
    NotifierProvider<ViewModeNotifier, bool>(ViewModeNotifier.new);

class ViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

/// The search query typed in the Search screen.
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

/// The ids of files selected in multi-select mode (Files tab).
final selectionProvider =
    NotifierProvider<SelectionNotifier, Set<String>>(SelectionNotifier.new);

class SelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String id) {
    final next = Set<String>.of(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  void clear() => state = <String>{};

  bool get hasSelection => state.isNotEmpty;
}

/// One entry in the uploads queue.
class UploadItem {
  const UploadItem({
    required this.id,
    required this.name,
    required this.progress,
    required this.done,
  });

  final String id;
  final String name;

  /// 0.0 – 1.0.
  final double progress;
  final bool done;

  UploadItem copyWith({double? progress, bool? done}) {
    return UploadItem(
      id: id,
      name: name,
      progress: progress ?? this.progress,
      done: done ?? this.done,
    );
  }
}

/// Simulated upload queue.
///
/// Frontend-only: progress is simulated with a timer and the file is
/// added to the mock repository when it "finishes". A real backend
/// upload replaces [startUpload] later; the UI stays the same.
final uploadsProvider =
    NotifierProvider<UploadsNotifier, List<UploadItem>>(UploadsNotifier.new);

class UploadsNotifier extends Notifier<List<UploadItem>> {
  final Map<String, Timer> _timers = {};

  @override
  List<UploadItem> build() {
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
    });
    return <UploadItem>[];
  }

  void startUpload(DriveFile file) {
    final item = UploadItem(id: file.id, name: file.name, progress: 0, done: false);
    state = <UploadItem>[...state, item];
    _timers[file.id] = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      final current = state.firstWhere(
        (u) => u.id == file.id,
        orElse: () => item,
      );
      final nextProgress = current.progress + 0.08;
      if (nextProgress >= 1) {
        timer.cancel();
        _timers.remove(file.id);
        state = state
            .map((u) => u.id == file.id ? u.copyWith(progress: 1, done: true) : u)
            .toList();
        // The "uploaded" file appears in My Drive.
        unawaited(ref.read(filesProvider.notifier).addFile(file));
      } else {
        state = state
            .map((u) => u.id == file.id ? u.copyWith(progress: nextProgress) : u)
            .toList();
      }
    });
  }

  void dismiss(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    state = state.where((u) => u.id != id).toList();
  }
}
