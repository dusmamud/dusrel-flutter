import '../models/drive_file.dart';

/// Data source for Drive files.
///
/// The frontend runs against [MockDriveRepository] (local mock data).
/// A real backend later implements the same interface; the UI never
/// talks to the mock directly.
abstract class DriveRepository {
  Future<List<DriveFile>> listAll();
  Future<void> toggleStar(String id);
  Future<void> toggleOffline(String id);
  Future<void> moveToTrash(String id);
  Future<void> restore(String id);
  Future<void> deleteForever(String id);
  Future<void> rename(String id, String newName);
  Future<void> createFolder(String name, String? parentId);
  Future<void> addFile(DriveFile file);
  Future<void> emptyTrash();
}

List<DriveFile> _seedFiles() {
  const mb = 1024 * 1024;
  const kb = 1024;
  return <DriveFile>[
    // Root folders.
    DriveFile(
      id: 'folder-documents',
      name: 'Documents',
      type: DriveFileType.folder,
      sizeBytes: 0,
      modifiedAt: DateTime(2026, 11, 8),
    ),
    DriveFile(
      id: 'folder-photos',
      name: 'Photos',
      type: DriveFileType.folder,
      sizeBytes: 0,
      modifiedAt: DateTime(2026, 11, 7),
    ),
    DriveFile(
      id: 'folder-projects',
      name: 'Projects',
      type: DriveFileType.folder,
      sizeBytes: 0,
      modifiedAt: DateTime(2026, 11, 6),
    ),
    // Documents folder.
    DriveFile(
      id: 'doc-proposal',
      name: 'Project Proposal.docx',
      type: DriveFileType.document,
      sizeBytes: 245 * kb,
      modifiedAt: DateTime(2026, 11, 8),
      parentId: 'folder-documents',
      isStarred: true,
    ),
    DriveFile(
      id: 'doc-budget',
      name: 'Budget 2026.xlsx',
      type: DriveFileType.document,
      sizeBytes: 132 * kb,
      modifiedAt: DateTime(2026, 11, 5),
      parentId: 'folder-documents',
      isShared: true,
    ),
    DriveFile(
      id: 'doc-meeting',
      name: 'Meeting Notes.pdf',
      type: DriveFileType.pdf,
      sizeBytes: 98 * kb,
      modifiedAt: DateTime(2026, 11, 4),
      parentId: 'folder-documents',
      isOffline: true,
    ),
    DriveFile(
      id: 'doc-resume',
      name: 'Resume.pdf',
      type: DriveFileType.pdf,
      sizeBytes: 210 * kb,
      modifiedAt: DateTime(2026, 10, 28),
      parentId: 'folder-documents',
    ),
    // Photos folder.
    DriveFile(
      id: 'img-beach',
      name: 'Beach Sunset.jpg',
      type: DriveFileType.image,
      sizeBytes: 3 * mb + 512 * kb,
      modifiedAt: DateTime(2026, 11, 8),
      parentId: 'folder-photos',
      isStarred: true,
    ),
    DriveFile(
      id: 'img-picnic',
      name: 'Family Picnic.png',
      type: DriveFileType.image,
      sizeBytes: 4 * mb + 256 * kb,
      modifiedAt: DateTime(2026, 11, 3),
      parentId: 'folder-photos',
    ),
    DriveFile(
      id: 'img-mountains',
      name: 'Mountains.jpg',
      type: DriveFileType.image,
      sizeBytes: 2 * mb + 768 * kb,
      modifiedAt: DateTime(2026, 10, 30),
      parentId: 'folder-photos',
    ),
    DriveFile(
      id: 'img-birthday',
      name: 'Birthday Cake.jpg',
      type: DriveFileType.image,
      sizeBytes: 1 * mb + 900 * kb,
      modifiedAt: DateTime(2026, 10, 25),
      parentId: 'folder-photos',
    ),
    // Projects folder.
    DriveFile(
      id: 'proj-wireframes',
      name: 'App Wireframes.fig',
      type: DriveFileType.other,
      sizeBytes: 5 * mb + 128 * kb,
      modifiedAt: DateTime(2026, 11, 7),
      parentId: 'folder-projects',
      isShared: true,
    ),
    DriveFile(
      id: 'proj-launch',
      name: 'Launch Plan.pdf',
      type: DriveFileType.pdf,
      sizeBytes: 420 * kb,
      modifiedAt: DateTime(2026, 11, 6),
      parentId: 'folder-projects',
      isStarred: true,
    ),
    DriveFile(
      id: 'proj-demo',
      name: 'Demo Video.mp4',
      type: DriveFileType.video,
      sizeBytes: 48 * mb,
      modifiedAt: DateTime(2026, 11, 2),
      parentId: 'folder-projects',
    ),
    DriveFile(
      id: 'proj-podcast',
      name: 'Podcast Intro.mp3',
      type: DriveFileType.audio,
      sizeBytes: 6 * mb + 512 * kb,
      modifiedAt: DateTime(2026, 10, 29),
      parentId: 'folder-projects',
    ),
    // Root files.
    DriveFile(
      id: 'file-tickets',
      name: 'Flight Tickets.pdf',
      type: DriveFileType.pdf,
      sizeBytes: 180 * kb,
      modifiedAt: DateTime(2026, 11, 9),
      isOffline: true,
    ),
    DriveFile(
      id: 'file-invoice',
      name: 'Invoice March.pdf',
      type: DriveFileType.pdf,
      sizeBytes: 76 * kb,
      modifiedAt: DateTime(2026, 11, 1),
    ),
    DriveFile(
      id: 'file-roadtrip',
      name: 'Road Trip.mp4',
      type: DriveFileType.video,
      sizeBytes: 96 * mb,
      modifiedAt: DateTime(2026, 10, 27),
    ),
    DriveFile(
      id: 'file-song',
      name: 'Song Draft.mp3',
      type: DriveFileType.audio,
      sizeBytes: 4 * mb + 128 * kb,
      modifiedAt: DateTime(2026, 10, 24),
    ),
    DriveFile(
      id: 'file-shopping',
      name: 'Shopping List.txt',
      type: DriveFileType.document,
      sizeBytes: 2 * kb,
      modifiedAt: DateTime(2026, 11, 9),
    ),
    DriveFile(
      id: 'file-deck',
      name: 'Presentation.pptx',
      type: DriveFileType.document,
      sizeBytes: 8 * mb + 256 * kb,
      modifiedAt: DateTime(2026, 10, 31),
    ),
    // Trashed file.
    DriveFile(
      id: 'file-old-draft',
      name: 'Old Draft.docx',
      type: DriveFileType.document,
      sizeBytes: 64 * kb,
      modifiedAt: DateTime(2026, 10, 12),
      trashedAt: DateTime(2026, 11, 5),
    ),
  ];
}

/// In-memory mock implementation used by the frontend-first build.
/// No network, no backend — all state lives in this list.
class MockDriveRepository implements DriveRepository {
  MockDriveRepository() : _files = _seedFiles();

  final List<DriveFile> _files;

  @override
  Future<List<DriveFile>> listAll() async {
    // Small delay so the skeleton loading state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List<DriveFile>.unmodifiable(_files);
  }

  DriveFile _byId(String id) => _files.firstWhere((f) => f.id == id);

  void _replace(DriveFile updated) {
    final index = _files.indexWhere((f) => f.id == updated.id);
    if (index >= 0) _files[index] = updated;
  }

  @override
  Future<void> toggleStar(String id) async {
    final file = _byId(id);
    _replace(file.copyWith(isStarred: !file.isStarred));
  }

  @override
  Future<void> toggleOffline(String id) async {
    final file = _byId(id);
    _replace(file.copyWith(isOffline: !file.isOffline));
  }

  @override
  Future<void> moveToTrash(String id) async {
    final file = _byId(id);
    _replace(file.copyWith(trashedAt: DateTime.now()));
  }

  @override
  Future<void> restore(String id) async {
    final file = _byId(id);
    _replace(file.copyWith(clearTrashedAt: true));
  }

  @override
  Future<void> deleteForever(String id) async {
    _files.removeWhere((f) => f.id == id);
  }

  @override
  Future<void> rename(String id, String newName) async {
    _replace(_byId(id).copyWith(name: newName.trim()));
  }

  @override
  Future<void> createFolder(String name, String? parentId) async {
    _files.add(
      DriveFile(
        id: 'folder-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        type: DriveFileType.folder,
        sizeBytes: 0,
        modifiedAt: DateTime.now(),
        parentId: parentId,
      ),
    );
  }

  @override
  Future<void> addFile(DriveFile file) async {
    _files.add(file);
  }

  @override
  Future<void> emptyTrash() async {
    _files.removeWhere((f) => f.isTrashed);
  }
}
