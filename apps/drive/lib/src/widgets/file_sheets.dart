import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/drive_file.dart';
import '../providers/drive_providers.dart';
import 'file_widgets.dart';

/// File details bottom sheet: name, type, size, modified date, owner
/// and the file actions. Uses the suite-standard sheet shape.
Future<void> showFileDetailsSheet(
  BuildContext context,
  WidgetRef ref,
  DriveFile file,
) {
  final l10n = AppLocalizations.of(context);
  return showDusBottomSheet<void>(
    context,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.screenEdge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FileTypeIcon(file: file, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  file.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (file.type != DriveFileType.folder)
            Text('${l10n.detailSize}: ${formatFileSize(file.sizeBytes)}'),
          Text(
            '${l10n.detailModified}: ${formatDriveDate(file.modifiedAt)}',
          ),
          Row(
            children: [
              DusAvatar(name: file.owner, size: AppSizes.avatarSm),
              const SizedBox(width: AppSpacing.sm),
              Text('${l10n.detailOwner}: ${file.owner}'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              DusButton(
                label: l10n.driveStarred,
                icon: file.isStarred ? Symbols.star : Symbols.star_border,
                variant: DusButtonVariant.tonal,
                onPressed: () {
                  ref.read(filesProvider.notifier).toggleStar(file.id);
                  Navigator.of(context).pop();
                },
              ),
              DusButton(
                label: l10n.share,
                icon: Symbols.share,
                variant: DusButtonVariant.tonal,
                onPressed: () {
                  Navigator.of(context).pop();
                  showShareSheet(context, file);
                },
              ),
              DusButton(
                label: l10n.driveDownload,
                icon: Symbols.download,
                variant: DusButtonVariant.tonal,
                onPressed: () => Navigator.of(context).pop(),
              ),
              DusButton(
                label: l10n.driveRename,
                icon: Symbols.edit,
                variant: DusButtonVariant.tonal,
                onPressed: () {
                  Navigator.of(context).pop();
                  showRenameDialog(context, ref, file);
                },
              ),
              if (file.isTrashed)
                DusButton(
                  label: l10n.driveRestore,
                  icon: Symbols.restore_from_trash,
                  variant: DusButtonVariant.tonal,
                  onPressed: () {
                    ref.read(filesProvider.notifier).restore(file.id);
                    Navigator.of(context).pop();
                  },
                )
              else
                DusButton(
                  label: l10n.delete,
                  icon: Symbols.delete,
                  variant: DusButtonVariant.outlined,
                  onPressed: () {
                    ref.read(filesProvider.notifier).moveToTrash(file.id);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

/// Share sheet: people with access and a role picker.
///
/// Frontend mock only — roles and link access are local state for now.
Future<void> showShareSheet(BuildContext context, DriveFile file) {
  final l10n = AppLocalizations.of(context);
  var selectedRole = 0; // 0 = viewer, 1 = commenter, 2 = editor.
  var linkOn = file.isShared;
  return showDusBottomSheet<void>(
    context,
    child: StatefulBuilder(
      builder: (context, setState) {
        final roles = <String>[
          l10n.shareViewer,
          l10n.shareCommenter,
          l10n.shareEditor,
        ];
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.share, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.chatMembers, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  DusAvatar(name: file.owner, size: AppSizes.avatarSm),
                  const SizedBox(width: AppSpacing.sm),
                  Text(file.owner),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (var i = 0; i < roles.length; i++)
                    ChoiceChip(
                      label: Text(roles[i]),
                      selected: selectedRole == i,
                      onSelected: (_) => setState(() => selectedRole = i),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.shareLinkAccess),
                secondary: const Icon(Symbols.link),
                value: linkOn,
                onChanged: (value) => setState(() => linkOn = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              DusButton(
                label: l10n.done,
                expanded: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    ),
  );
}

/// The + FAB sheet: upload a file, upload photos, or make a new folder.
Future<void> showCreateSheet(
  BuildContext context,
  WidgetRef ref, {
  String? parentId,
}) {
  final l10n = AppLocalizations.of(context);
  return showDusBottomSheet<void>(
    context,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.screenEdge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Symbols.file_upload),
            title: Text(l10n.driveUploadFile),
            minVerticalPadding: AppSpacing.sm,
            onTap: () {
              Navigator.of(context).pop();
              _pickAndUpload(context, ref, parentId: parentId, imagesOnly: false);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.image),
            title: Text(l10n.driveUploadPhotos),
            minVerticalPadding: AppSpacing.sm,
            onTap: () {
              Navigator.of(context).pop();
              _pickAndUpload(context, ref, parentId: parentId, imagesOnly: true);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.create_new_folder),
            title: Text(l10n.driveNewFolder),
            minVerticalPadding: AppSpacing.sm,
            onTap: () {
              Navigator.of(context).pop();
              showNewFolderDialog(context, ref, parentId: parentId);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

Future<void> _pickAndUpload(
  BuildContext context,
  WidgetRef ref, {
  required String? parentId,
  required bool imagesOnly,
}) async {
  final picked = await FilePicker.pickFiles(
    type: imagesOnly ? FileType.image : FileType.any,
  );
  final pickedFile = picked.firstOrNull;
  if (pickedFile == null) return;
  final file = DriveFile(
    id: 'upload-${DateTime.now().millisecondsSinceEpoch}',
    name: pickedFile.name,
    type: typeForExtension(pickedFile.extension ?? ''),
    sizeBytes: pickedFile.lengthSync() ?? 0,
    modifiedAt: DateTime.now(),
    parentId: parentId,
  );
  ref.read(uploadsProvider.notifier).startUpload(file);
}

/// New-folder dialog.
Future<void> showNewFolderDialog(
  BuildContext context,
  WidgetRef ref, {
  String? parentId,
}) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.driveNewFolder),
      content: DusTextField(
        controller: controller,
        label: l10n.driveNewFolder,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            ref.read(filesProvider.notifier).createFolder(name, parentId);
            Navigator.of(context).pop();
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}

/// Rename dialog.
Future<void> showRenameDialog(
  BuildContext context,
  WidgetRef ref,
  DriveFile file,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: file.name);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.driveRename),
      content: DusTextField(
        controller: controller,
        label: l10n.driveRename,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            ref.read(filesProvider.notifier).rename(file.id, name);
            Navigator.of(context).pop();
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
