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

  /// Generic back button
  ///
  /// In en_US, this message translates to:
  /// **'Back'**
  String get back;

  /// Button to add a calendar event
  ///
  /// In en_US, this message translates to:
  /// **'Add event'**
  String get calendarAddEvent;

  /// Title of the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'Calendar'**
  String get calendarAppTitle;

  /// Empty state message in the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'No events today'**
  String get calendarNoEvents;

  /// Button to jump to today in the Calendar app
  ///
  /// In en_US, this message translates to:
  /// **'Today'**
  String get calendarToday;

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

  /// Empty state message in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'No messages yet'**
  String get chatEmpty;

  /// Online status label in the Chat app
  ///
  /// In en_US, this message translates to:
  /// **'Online'**
  String get chatOnline;

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

  /// Generic delete button
  ///
  /// In en_US, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Generic done button
  ///
  /// In en_US, this message translates to:
  /// **'Done'**
  String get done;

  /// Title of the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Drive'**
  String get driveAppTitle;

  /// Empty state message in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Drive is empty'**
  String get driveEmpty;

  /// My Drive section title in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'My Drive'**
  String get driveMyDrive;

  /// Search hint in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Search files'**
  String get driveSearchFiles;

  /// Button to upload a file in the Drive app
  ///
  /// In en_US, this message translates to:
  /// **'Upload file'**
  String get driveUploadFile;

  /// Generic edit button
  ///
  /// In en_US, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Generic error message
  ///
  /// In en_US, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// Tooltip for the counter increment button
  ///
  /// In en_US, this message translates to:
  /// **'Increment'**
  String get incrementTooltip;

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

  /// Title of the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Notes'**
  String get notesAppTitle;

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

  /// Button to create a new note
  ///
  /// In en_US, this message translates to:
  /// **'New note'**
  String get notesNewNote;

  /// Search hint in the Notes app
  ///
  /// In en_US, this message translates to:
  /// **'Search notes'**
  String get notesSearchNotes;

  /// Generic confirmation button
  ///
  /// In en_US, this message translates to:
  /// **'OK'**
  String get ok;

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
