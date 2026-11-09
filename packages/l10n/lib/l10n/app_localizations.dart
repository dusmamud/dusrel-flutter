import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', 'US'),
    Locale('en'),
    Locale('hi'),
    Locale('hi', 'IN'),
  ];

  /// Button to add a label to a note
  ///
  /// In en_US, this message translates to:
  /// **'Add label'**
  String get addLabel;

  /// Attachment option: camera
  ///
  /// In en_US, this message translates to:
  /// **'Camera'**
  String get attachCamera;

  /// Attachment option: document
  ///
  /// In en_US, this message translates to:
  /// **'Document'**
  String get attachDocument;

  /// Attachment option: gallery
  ///
  /// In en_US, this message translates to:
  /// **'Gallery'**
  String get attachGallery;

  /// Generic back button
  ///
  /// In en_US, this message translates to:
  /// **'Back'**
  String get back;

  /// Block a contact
  ///
  /// In en_US, this message translates to:
  /// **'Block'**
  String get block;

  /// Button to add a calendar event
  ///
  /// In en_US, this message translates to:
  /// **'Add event'**
  String get calendarAddEvent;

  /// Agenda view in the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'Agenda'**
  String get calendarAgenda;

  /// All-day toggle in the event form
  ///
  /// In en_US, this message translates to:
  /// **'All day'**
  String get calendarAllDay;

  /// Title of the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'Calendar'**
  String get calendarAppTitle;

  /// Calendars manager screen title
  ///
  /// In en_US, this message translates to:
  /// **'Calendars'**
  String get calendarCalendars;

  /// Custom recurrence option
  ///
  /// In en_US, this message translates to:
  /// **'Custom'**
  String get calendarCustom;

  /// Daily recurrence option
  ///
  /// In en_US, this message translates to:
  /// **'Daily'**
  String get calendarDaily;

  /// Day view in the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'Day'**
  String get calendarDay;

  /// Button to edit a calendar event
  ///
  /// In en_US, this message translates to:
  /// **'Edit event'**
  String get calendarEditEvent;

  /// Event location field
  ///
  /// In en_US, this message translates to:
  /// **'Location'**
  String get calendarLocation;

  /// Month view in the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'Month'**
  String get calendarMonth;

  /// Monthly recurrence option
  ///
  /// In en_US, this message translates to:
  /// **'Monthly'**
  String get calendarMonthly;

  /// Button to create a new event
  ///
  /// In en_US, this message translates to:
  /// **'New event'**
  String get calendarNewEvent;

  /// Empty state message in the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'No events today'**
  String get calendarNoEvents;

  /// Event reminder field
  ///
  /// In en_US, this message translates to:
  /// **'Reminder'**
  String get calendarReminder;

  /// Event repeat field
  ///
  /// In en_US, this message translates to:
  /// **'Repeat'**
  String get calendarRepeat;

  /// Button to jump to today in the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// Week view in the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'Week'**
  String get calendarWeek;

  /// Weekly recurrence option
  ///
  /// In en_US, this message translates to:
  /// **'Weekly'**
  String get calendarWeekly;

  /// Yearly recurrence option
  ///
  /// In en_US, this message translates to:
  /// **'Yearly'**
  String get calendarYearly;

  /// Generic cancel button
  ///
  /// In en_US, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title of the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'Chat'**
  String get chatAppTitle;

  /// Calls tab title
  ///
  /// In en_US, this message translates to:
  /// **'Calls'**
  String get chatCalls;

  /// Chats list tab title
  ///
  /// In en_US, this message translates to:
  /// **'Chats'**
  String get chatChats;

  /// Communities tab title
  ///
  /// In en_US, this message translates to:
  /// **'Communities'**
  String get chatCommunities;

  /// Copy a chat message
  ///
  /// In en_US, this message translates to:
  /// **'Copy'**
  String get chatCopy;

  /// Message delivered status in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'Delivered'**
  String get chatDelivered;

  /// Empty state message in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'No messages yet'**
  String get chatEmpty;

  /// Forward a chat message
  ///
  /// In en_US, this message translates to:
  /// **'Forward'**
  String get chatForward;

  /// Group info screen title
  ///
  /// In en_US, this message translates to:
  /// **'Group info'**
  String get chatGroupInfo;

  /// Shared media section in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'Media'**
  String get chatMedia;

  /// Group members label
  ///
  /// In en_US, this message translates to:
  /// **'Members'**
  String get chatMembers;

  /// Mute a chat
  ///
  /// In en_US, this message translates to:
  /// **'Mute'**
  String get chatMute;

  /// Button to start a new chat
  ///
  /// In en_US, this message translates to:
  /// **'New chat'**
  String get chatNewChat;

  /// Button to create a new group
  ///
  /// In en_US, this message translates to:
  /// **'New group'**
  String get chatNewGroup;

  /// Online status label in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'Online'**
  String get chatOnline;

  /// Message read status in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'Read'**
  String get chatRead;

  /// Reply to a chat message
  ///
  /// In en_US, this message translates to:
  /// **'Reply'**
  String get chatReply;

  /// Search hint in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'Search chats'**
  String get chatSearchChats;

  /// Button to send a chat message
  ///
  /// In en_US, this message translates to:
  /// **'Send message'**
  String get chatSendMessage;

  /// Input hint in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'Type a message…'**
  String get chatTypeMessage;

  /// Typing indicator in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'typing…'**
  String get chatTyping;

  /// Updates tab title
  ///
  /// In en_US, this message translates to:
  /// **'Updates'**
  String get chatUpdates;

  /// Generic close button
  ///
  /// In en_US, this message translates to:
  /// **'Close'**
  String get close;

  /// Counter demo label above the count
  ///
  /// In en_US, this message translates to:
  /// **'You have pushed the button this many times:'**
  String get counterLabel;

  /// Default view setting
  ///
  /// In en_US, this message translates to:
  /// **'Default view'**
  String get defaultView;

  /// Generic delete button
  ///
  /// In en_US, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Modified date label in file details
  ///
  /// In en_US, this message translates to:
  /// **'Modified'**
  String get detailModified;

  /// Owner label in file details
  ///
  /// In en_US, this message translates to:
  /// **'Owner'**
  String get detailOwner;

  /// File size label in file details
  ///
  /// In en_US, this message translates to:
  /// **'Size'**
  String get detailSize;

  /// Generic done button
  ///
  /// In en_US, this message translates to:
  /// **'Done'**
  String get done;

  /// Activity section title in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Activity'**
  String get driveActivity;

  /// Title of the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Drive'**
  String get driveAppTitle;

  /// Permanently delete a file
  ///
  /// In en_US, this message translates to:
  /// **'Delete forever'**
  String get driveDeleteForever;

  /// Download a file
  ///
  /// In en_US, this message translates to:
  /// **'Download'**
  String get driveDownload;

  /// Empty state message in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Drive is empty'**
  String get driveEmpty;

  /// Button to empty the trash in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Empty trash'**
  String get driveEmptyTrash;

  /// Files tab title in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Files'**
  String get driveFiles;

  /// Home tab title in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Home'**
  String get driveHome;

  /// Largest files section in storage
  ///
  /// In en_US, this message translates to:
  /// **'Largest files'**
  String get driveLargestFiles;

  /// My Drive section title in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'My Drive'**
  String get driveMyDrive;

  /// Button to create a new folder
  ///
  /// In en_US, this message translates to:
  /// **'New folder'**
  String get driveNewFolder;

  /// Empty folder message in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'No files here'**
  String get driveNoFiles;

  /// Offline files tab title
  ///
  /// In en_US, this message translates to:
  /// **'Offline'**
  String get driveOffline;

  /// Photos section title in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Photos'**
  String get drivePhotos;

  /// Recent files tab title
  ///
  /// In en_US, this message translates to:
  /// **'Recent'**
  String get driveRecent;

  /// Rename a file or folder
  ///
  /// In en_US, this message translates to:
  /// **'Rename'**
  String get driveRename;

  /// Restore a file from trash
  ///
  /// In en_US, this message translates to:
  /// **'Restore'**
  String get driveRestore;

  /// Search hint in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Search files'**
  String get driveSearchFiles;

  /// Shared files tab title
  ///
  /// In en_US, this message translates to:
  /// **'Shared'**
  String get driveShared;

  /// Starred files tab title
  ///
  /// In en_US, this message translates to:
  /// **'Starred'**
  String get driveStarred;

  /// Storage screen title in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Storage'**
  String get driveStorage;

  /// Suggested files section title
  ///
  /// In en_US, this message translates to:
  /// **'Suggested'**
  String get driveSuggested;

  /// Trash section in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Trash'**
  String get driveTrash;

  /// Trash retention note in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Files in trash are deleted after 30 days.'**
  String get driveTrashRetention;

  /// Upload button in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Upload'**
  String get driveUpload;

  /// Button to upload a file in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Upload file'**
  String get driveUploadFile;

  /// Button to upload photos
  ///
  /// In en_US, this message translates to:
  /// **'Upload photos'**
  String get driveUploadPhotos;

  /// Duplicate an event
  ///
  /// In en_US, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// Generic edit button
  ///
  /// In en_US, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Recurrence end rule: after N occurrences
  ///
  /// In en_US, this message translates to:
  /// **'After occurrences'**
  String get endsAfterOccurrences;

  /// Recurrence end rule: never ends
  ///
  /// In en_US, this message translates to:
  /// **'Never'**
  String get endsNever;

  /// Recurrence end rule: ends on a date
  ///
  /// In en_US, this message translates to:
  /// **'On date'**
  String get endsOnDate;

  /// Generic error message
  ///
  /// In en_US, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// Event end field
  ///
  /// In en_US, this message translates to:
  /// **'End'**
  String get eventEnd;

  /// Event notes field
  ///
  /// In en_US, this message translates to:
  /// **'Notes'**
  String get eventNotes;

  /// Event start field
  ///
  /// In en_US, this message translates to:
  /// **'Start'**
  String get eventStart;

  /// Event title field
  ///
  /// In en_US, this message translates to:
  /// **'Title'**
  String get eventTitle;

  /// First day of week setting
  ///
  /// In en_US, this message translates to:
  /// **'First day of week'**
  String get firstDayOfWeek;

  /// Tooltip for the counter increment button
  ///
  /// In en_US, this message translates to:
  /// **'Increment'**
  String get incrementTooltip;

  /// Leave group button
  ///
  /// In en_US, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// Loading indicator text
  ///
  /// In en_US, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Empty search results message
  ///
  /// In en_US, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// All notes section title in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'All notes'**
  String get notesAllNotes;

  /// Title of the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Notes'**
  String get notesAppTitle;

  /// Archive section in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Archive'**
  String get notesArchive;

  /// Empty state action in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Create your first note'**
  String get notesCreateFirst;

  /// Permanently delete a note
  ///
  /// In en_US, this message translates to:
  /// **'Delete forever'**
  String get notesDeleteForever;

  /// Button to delete a note
  ///
  /// In en_US, this message translates to:
  /// **'Delete note'**
  String get notesDeleteNote;

  /// Empty state message in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'No notes yet'**
  String get notesEmpty;

  /// Button to empty the trash in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Empty trash'**
  String get notesEmptyTrash;

  /// Switch to grid view in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Grid view'**
  String get notesGridView;

  /// Labels section in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Labels'**
  String get notesLabels;

  /// Last edited label on a note
  ///
  /// In en_US, this message translates to:
  /// **'Last edited'**
  String get notesLastEdited;

  /// Switch to list view in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'List view'**
  String get notesListView;

  /// Button to create a new note
  ///
  /// In en_US, this message translates to:
  /// **'New note'**
  String get notesNewNote;

  /// Notebooks section in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Notebooks'**
  String get notesNotebooks;

  /// Pinned notes section title
  ///
  /// In en_US, this message translates to:
  /// **'Pinned'**
  String get notesPinned;

  /// Reminders section in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Reminders'**
  String get notesReminders;

  /// Restore a note from trash
  ///
  /// In en_US, this message translates to:
  /// **'Restore'**
  String get notesRestore;

  /// Search hint in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Search notes'**
  String get notesSearchNotes;

  /// Trash section in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Trash'**
  String get notesTrash;

  /// Trash retention note in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Notes in trash are deleted after 30 days.'**
  String get notesTrashRetention;

  /// Notifications setting
  ///
  /// In en_US, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Generic confirmation button
  ///
  /// In en_US, this message translates to:
  /// **'OK'**
  String get ok;

  /// Pin an item
  ///
  /// In en_US, this message translates to:
  /// **'Pin'**
  String get pin;

  /// Recurrence interval field
  ///
  /// In en_US, this message translates to:
  /// **'Interval'**
  String get recurrenceInterval;

  /// Recurrence occurrences field
  ///
  /// In en_US, this message translates to:
  /// **'Occurrences'**
  String get recurrenceOccurrences;

  /// Reminder one day before
  ///
  /// In en_US, this message translates to:
  /// **'1 day'**
  String get reminder1day;

  /// Reminder one hour before
  ///
  /// In en_US, this message translates to:
  /// **'1 hour'**
  String get reminder1hour;

  /// Reminder five minutes before
  ///
  /// In en_US, this message translates to:
  /// **'5 min'**
  String get reminder5min;

  /// No reminder option
  ///
  /// In en_US, this message translates to:
  /// **'None'**
  String get reminderNone;

  /// No recurrence option
  ///
  /// In en_US, this message translates to:
  /// **'Does not repeat'**
  String get repeatNever;

  /// Retry button after a failure
  ///
  /// In en_US, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic save button
  ///
  /// In en_US, this message translates to:
  /// **'Save'**
  String get save;

  /// Edit scope: all events in the series
  ///
  /// In en_US, this message translates to:
  /// **'All events'**
  String get scopeAllEvents;

  /// Edit scope: this and following events
  ///
  /// In en_US, this message translates to:
  /// **'This and following events'**
  String get scopeThisAndFollowing;

  /// Edit scope: only this event
  ///
  /// In en_US, this message translates to:
  /// **'This event'**
  String get scopeThisEvent;

  /// Generic search button or hint
  ///
  /// In en_US, this message translates to:
  /// **'Search'**
  String get search;

  /// Settings screen title
  ///
  /// In en_US, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Generic share button
  ///
  /// In en_US, this message translates to:
  /// **'Share'**
  String get share;

  /// Commenter share role
  ///
  /// In en_US, this message translates to:
  /// **'Commenter'**
  String get shareCommenter;

  /// Editor share role
  ///
  /// In en_US, this message translates to:
  /// **'Editor'**
  String get shareEditor;

  /// Link access toggle in the share sheet
  ///
  /// In en_US, this message translates to:
  /// **'Link access'**
  String get shareLinkAccess;

  /// Viewer share role
  ///
  /// In en_US, this message translates to:
  /// **'Viewer'**
  String get shareViewer;

  /// Theme setting
  ///
  /// In en_US, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark theme option
  ///
  /// In en_US, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Light theme option
  ///
  /// In en_US, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Follow system theme option
  ///
  /// In en_US, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Unpin an item
  ///
  /// In en_US, this message translates to:
  /// **'Unpin'**
  String get unpin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
    case 'hi':
      {
        switch (locale.countryCode) {
          case 'IN':
            return AppLocalizationsHiIn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
