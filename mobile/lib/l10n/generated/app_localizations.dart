import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCommunicate.
  ///
  /// In en, this message translates to:
  /// **'Communicate'**
  String get navCommunicate;

  /// No description provided for @navRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get navRoutine;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning, caregiver'**
  String get homeGreeting;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'A calm place to communicate, learn, and practise together.'**
  String get homeTagline;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @emotionPracticeTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotion practice'**
  String get emotionPracticeTileTitle;

  /// No description provided for @emotionPracticeTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn six everyday expressions'**
  String get emotionPracticeTileSubtitle;

  /// No description provided for @socialStoriesTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Social stories'**
  String get socialStoriesTileTitle;

  /// No description provided for @socialStoriesTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Designed and documented for the next phase'**
  String get socialStoriesTileSubtitle;

  /// No description provided for @learningPathTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning path'**
  String get learningPathTileTitle;

  /// No description provided for @learningPathTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interest-based activities are coming next'**
  String get learningPathTileSubtitle;

  /// No description provided for @beginnerSupportLevel.
  ///
  /// In en, this message translates to:
  /// **'Beginner support level'**
  String get beginnerSupportLevel;

  /// No description provided for @starsEarned.
  ///
  /// In en, this message translates to:
  /// **'{count} stars earned'**
  String starsEarned(int count);

  /// No description provided for @comingNextPhase.
  ///
  /// In en, this message translates to:
  /// **'Coming in the next phase'**
  String get comingNextPhase;

  /// No description provided for @safeByDesign.
  ///
  /// In en, this message translates to:
  /// **'Safe by design'**
  String get safeByDesign;

  /// No description provided for @safeByDesignMessage.
  ///
  /// In en, this message translates to:
  /// **'This module will use fixed, caregiver-approved content. Open-ended child chat is out of scope.'**
  String get safeByDesignMessage;

  /// No description provided for @interestLearningDescription.
  ///
  /// In en, this message translates to:
  /// **'Deterministic interest-to-topic mapping will power this learning path.'**
  String get interestLearningDescription;

  /// No description provided for @socialStoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Short illustrated stories and guided comprehension checks will live here.'**
  String get socialStoriesDescription;

  /// No description provided for @communicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Communicate'**
  String get communicateTitle;

  /// No description provided for @speakSentenceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Speak sentence'**
  String get speakSentenceTooltip;

  /// No description provided for @sentenceHeader.
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get sentenceHeader;

  /// No description provided for @tapCardToBuild.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to build a sentence'**
  String get tapCardToBuild;

  /// No description provided for @clearSentenceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear sentence'**
  String get clearSentenceTooltip;

  /// No description provided for @frequentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Frequently used'**
  String get frequentlyUsed;

  /// No description provided for @recentCardsHint.
  ///
  /// In en, this message translates to:
  /// **'Your recent cards will appear here.'**
  String get recentCardsHint;

  /// No description provided for @coreWords.
  ///
  /// In en, this message translates to:
  /// **'Core words'**
  String get coreWords;

  /// No description provided for @emotionPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotion practice'**
  String get emotionPracticeTitle;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get sessionComplete;

  /// No description provided for @sessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{score} of {total} correct • {stars} stars earned'**
  String sessionSummary(int score, int total, int stars);

  /// No description provided for @practiseAgain.
  ///
  /// In en, this message translates to:
  /// **'Practise again'**
  String get practiseAgain;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {index} of {total}'**
  String questionProgress(int index, int total);

  /// No description provided for @whichFaceFeels.
  ///
  /// In en, this message translates to:
  /// **'Which face feels {emotion}?'**
  String whichFaceFeels(String emotion);

  /// No description provided for @emotionHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get emotionHappy;

  /// No description provided for @emotionSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get emotionSad;

  /// No description provided for @emotionAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get emotionAngry;

  /// No description provided for @emotionSurprised.
  ///
  /// In en, this message translates to:
  /// **'Surprised'**
  String get emotionSurprised;

  /// No description provided for @emotionScared.
  ///
  /// In en, this message translates to:
  /// **'Scared'**
  String get emotionScared;

  /// No description provided for @emotionNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get emotionNeutral;

  /// No description provided for @beginnerHint.
  ///
  /// In en, this message translates to:
  /// **'Hint: look at the face and choose the matching feeling.'**
  String get beginnerHint;

  /// No description provided for @answerCorrect.
  ///
  /// In en, this message translates to:
  /// **'That is right.'**
  String get answerCorrect;

  /// No description provided for @answerIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Let us try the next one.'**
  String get answerIncorrect;

  /// No description provided for @cameraPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera expression practice'**
  String get cameraPracticeTitle;

  /// No description provided for @cameraPracticeMessage.
  ///
  /// In en, this message translates to:
  /// **'P1 placeholder. Future on-device ML Kit processing will stay in memory and never upload frames.'**
  String get cameraPracticeMessage;

  /// No description provided for @routineTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routineTitle;

  /// No description provided for @oneStepAtATime.
  ///
  /// In en, this message translates to:
  /// **'One step at a time'**
  String get oneStepAtATime;

  /// No description provided for @routineProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Routine progress'**
  String get routineProgressLabel;

  /// No description provided for @stepsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} steps done'**
  String stepsDone(int done, int total);

  /// No description provided for @transitionWarnings.
  ///
  /// In en, this message translates to:
  /// **'Transition warnings'**
  String get transitionWarnings;

  /// No description provided for @transitionWarningsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak each step when its time arrives while this screen is open'**
  String get transitionWarningsSubtitle;

  /// No description provided for @resetToday.
  ///
  /// In en, this message translates to:
  /// **'Reset today'**
  String get resetToday;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @childWeekHeader.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s week'**
  String childWeekHeader(String name);

  /// No description provided for @metricActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get metricActivities;

  /// No description provided for @metricRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get metricRoutine;

  /// No description provided for @metricStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get metricStars;

  /// No description provided for @activitiesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Activities this week'**
  String get activitiesThisWeek;

  /// No description provided for @explainableProgress.
  ///
  /// In en, this message translates to:
  /// **'Explainable progress'**
  String get explainableProgress;

  /// No description provided for @explainableProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Charts are based on recorded activities and never make clinical claims.'**
  String get explainableProgressMessage;

  /// No description provided for @caregiverNotes.
  ///
  /// In en, this message translates to:
  /// **'Caregiver notes'**
  String get caregiverNotes;

  /// No description provided for @noObservationsYet.
  ///
  /// In en, this message translates to:
  /// **'No observations logged yet.'**
  String get noObservationsYet;

  /// No description provided for @logObservation.
  ///
  /// In en, this message translates to:
  /// **'Log an observation'**
  String get logObservation;

  /// No description provided for @observationButton.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get observationButton;

  /// No description provided for @observationHint.
  ///
  /// In en, this message translates to:
  /// **'What did you notice today?'**
  String get observationHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sensoryMode.
  ///
  /// In en, this message translates to:
  /// **'Sensory-friendly mode'**
  String get sensoryMode;

  /// No description provided for @sensoryModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion, clutter, and sound intensity'**
  String get sensoryModeSubtitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get languageUrdu;

  /// No description provided for @supportLevel.
  ///
  /// In en, this message translates to:
  /// **'Support level'**
  String get supportLevel;

  /// No description provided for @supportLevelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Beginner, controlled by caregiver'**
  String get supportLevelSubtitle;

  /// No description provided for @supportLevelDescription.
  ///
  /// In en, this message translates to:
  /// **'Adaptive difficulty will be connected to the rule-based controller here.'**
  String get supportLevelDescription;

  /// No description provided for @privacySafety.
  ///
  /// In en, this message translates to:
  /// **'Privacy and safety'**
  String get privacySafety;

  /// No description provided for @privacySafetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No diagnosis, no child-facing open chat, camera processing stays on-device'**
  String get privacySafetySubtitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AutiMate'**
  String get authWelcome;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'A calm communication and learning space for children and caregivers.'**
  String get authTagline;

  /// No description provided for @parentEmail.
  ///
  /// In en, this message translates to:
  /// **'Parent email'**
  String get parentEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get signingIn;

  /// No description provided for @createParentAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a parent account'**
  String get createParentAccount;

  /// No description provided for @authErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an email and password to continue.'**
  String get authErrorRequired;

  /// No description provided for @gamificationComingMessage.
  ///
  /// In en, this message translates to:
  /// **'Badges, streaks, and progress rings will connect to completed activities.'**
  String get gamificationComingMessage;

  /// No description provided for @sensorySupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensory support'**
  String get sensorySupportTitle;

  /// No description provided for @ttsControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound and motion controls'**
  String get ttsControlsTitle;

  /// No description provided for @ttsControlsMessage.
  ///
  /// In en, this message translates to:
  /// **'Sensory-friendly mode automatically softens speech rate and volume.'**
  String get ttsControlsMessage;

  /// No description provided for @gamificationTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Stars and rewards'**
  String get gamificationTileTitle;

  /// No description provided for @gamificationTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See stars earned from activities'**
  String get gamificationTileSubtitle;

  /// No description provided for @sensorySupportTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensory support'**
  String get sensorySupportTileTitle;

  /// No description provided for @sensorySupportTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick calming and sound controls'**
  String get sensorySupportTileSubtitle;
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
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
