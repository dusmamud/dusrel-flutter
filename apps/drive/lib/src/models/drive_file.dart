import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// The type of a file in Drive. Drives the icon and the preview behaviour.
enum DriveFileType { folder, document, image, pdf, video, audio, other }

/// Maps a file extension to a [DriveFileType].
DriveFileType typeForExtension(String extension) {
  switch (extension.toLowerCase()) {
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
    case 'heic':
      return DriveFileType.image;
    case 'pdf':
      return DriveFileType.pdf;
    case 'mp4':
    case 'mov':
    case 'mkv':
    case 'webm':
      return DriveFileType.video;
    case 'mp3':
    case 'wav':
    case 'm4a':
    case 'flac':
      return DriveFileType.audio;
    case 'doc':
    case 'docx':
    case 'txt':
    case 'xls':
    case 'xlsx':
    case 'ppt':
    case 'pptx':
    case 'md':
      return DriveFileType.document;
    default:
      return DriveFileType.other;
  }
}

/// The icon for a file type. Material Symbols, one consistent set.
IconData iconForType(DriveFileType type) {
  return switch (type) {
    DriveFileType.folder => Symbols.folder,
    DriveFileType.document => Symbols.description,
    DriveFileType.image => Symbols.image,
    DriveFileType.pdf => Symbols.picture_as_pdf,
    DriveFileType.video => Symbols.movie,
    DriveFileType.audio => Symbols.audio_file,
    DriveFileType.other => Symbols.insert_drive_file,
  };
}

/// A single file or folder in Drive.
class DriveFile {
  const DriveFile({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeBytes,
    required this.modifiedAt,
    this.parentId,
    this.isStarred = false,
    this.isShared = false,
    this.isOffline = false,
    this.owner = 'Dus Mamud',
    this.trashedAt,
  });

  final String id;
  final String name;
  final DriveFileType type;
  final int sizeBytes;
  final DateTime modifiedAt;

  /// Null means the file lives at the root of My Drive.
  final String? parentId;
  final bool isStarred;
  final bool isShared;
  final bool isOffline;
  final String owner;

  /// Non-null means the file is in Trash.
  final DateTime? trashedAt;

  bool get isTrashed => trashedAt != null;

  String get extension =>
      name.contains('.') ? name.split('.').last.toLowerCase() : '';

  /// Mock photo URL for image files (picsum). Null for other types.
  String? get thumbnailUrl => type == DriveFileType.image
      ? 'https://picsum.photos/seed/$id/400/400'
      : null;

  String? get imageUrl => type == DriveFileType.image
      ? 'https://picsum.photos/seed/$id/800/800'
      : null;

  DriveFile copyWith({
    String? name,
    bool? isStarred,
    bool? isShared,
    bool? isOffline,
    DateTime? trashedAt,
    bool clearTrashedAt = false,
  }) {
    return DriveFile(
      id: id,
      name: name ?? this.name,
      type: type,
      sizeBytes: sizeBytes,
      modifiedAt: modifiedAt,
      parentId: parentId,
      isStarred: isStarred ?? this.isStarred,
      isShared: isShared ?? this.isShared,
      isOffline: isOffline ?? this.isOffline,
      owner: owner,
      trashedAt: clearTrashedAt ? null : (trashedAt ?? this.trashedAt),
    );
  }
}

/// Human-readable file size, e.g. "245 KB", "1.2 MB".
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

const List<String> _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Short date, e.g. "8 Nov 2026".
String formatDriveDate(DateTime date) {
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}
