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
  /// **'Stories and conversation practice'**
  String get socialStoriesTileSubtitle;

  /// No description provided for @tabStories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get tabStories;

  /// No description provided for @tabConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get tabConversations;

  /// No description provided for @narrateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get narrateTooltip;

  /// No description provided for @nextPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPageTooltip;

  /// No description provided for @previousPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPageTooltip;

  /// No description provided for @comprehensionTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s check understanding'**
  String get comprehensionTitle;

  /// No description provided for @conversationComplete.
  ///
  /// In en, this message translates to:
  /// **'You finished the conversation! A star was earned.'**
  String get conversationComplete;

  /// No description provided for @conversationHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a situation, then pick the reply that fits.'**
  String get conversationHint;

  /// No description provided for @gentleRetry.
  ///
  /// In en, this message translates to:
  /// **'That is okay. Let\'s try another way.'**
  String get gentleRetry;

  /// No description provided for @storyPagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String storyPagesCount(int count);

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

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @aacCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get aacCategoryFood;

  /// No description provided for @aacCategoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get aacCategoryDrinks;

  /// No description provided for @aacCategoryEmotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get aacCategoryEmotions;

  /// No description provided for @aacCategoryActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get aacCategoryActivities;

  /// No description provided for @aacCategoryPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get aacCategoryPeople;

  /// No description provided for @aacCategoryPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get aacCategoryPlaces;

  /// No description provided for @aacCategoryNeeds.
  ///
  /// In en, this message translates to:
  /// **'Needs'**
  String get aacCategoryNeeds;

  /// No description provided for @aacCategoryObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get aacCategoryObjects;

  /// No description provided for @removeLastWordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove last word'**
  String get removeLastWordTooltip;

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
  /// **'On-device smile detection logic is implemented; the ML Kit camera adapter lands after physical-device verification. A simulated demo is available now.'**
  String get cameraPracticeMessage;

  /// No description provided for @expressionTitle.
  ///
  /// In en, this message translates to:
  /// **'Expression practice'**
  String get expressionTitle;

  /// No description provided for @expressionStart.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get expressionStart;

  /// No description provided for @expressionHoldSmile.
  ///
  /// In en, this message translates to:
  /// **'Hold a big smile for one second'**
  String get expressionHoldSmile;

  /// No description provided for @expressionUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Expression practice is not available on this device.'**
  String get expressionUnsupported;

  /// No description provided for @expressionPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed. A caregiver can allow it in device settings.'**
  String get expressionPermissionDenied;

  /// No description provided for @expressionLoadingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting the camera...'**
  String get expressionLoadingCamera;

  /// No description provided for @expressionCameraError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with the camera. Please try again.'**
  String get expressionCameraError;

  /// No description provided for @expressionSmileProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} smiles held'**
  String expressionSmileProgress(int done, int total);

  /// No description provided for @expressionSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Great smiling! {stars} stars earned'**
  String expressionSessionComplete(int stars);

  /// No description provided for @expressionPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get expressionPrivacyTitle;

  /// No description provided for @expressionPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Frames stay in memory on this device and are never stored or uploaded. Only star totals are recorded.'**
  String get expressionPrivacyNote;

  /// No description provided for @expressionRationaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Why the camera?'**
  String get expressionRationaleTitle;

  /// No description provided for @expressionRationaleBody.
  ///
  /// In en, this message translates to:
  /// **'The camera watches for your smile so stars can be awarded. Frames stay on this device and are never saved or uploaded.'**
  String get expressionRationaleBody;

  /// No description provided for @expressionAllowCamera.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get expressionAllowCamera;

  /// No description provided for @expressionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get expressionNotNow;

  /// No description provided for @expressionComeCloserHint.
  ///
  /// In en, this message translates to:
  /// **'Come closer to the camera'**
  String get expressionComeCloserHint;

  /// No description provided for @expressionEyesHint.
  ///
  /// In en, this message translates to:
  /// **'Try opening your eyes'**
  String get expressionEyesHint;

  /// No description provided for @expressionLookStraightHint.
  ///
  /// In en, this message translates to:
  /// **'Look straight at the camera'**
  String get expressionLookStraightHint;

  /// No description provided for @routineEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get routineEditTooltip;

  /// No description provided for @routineEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine editor'**
  String get routineEditorTitle;

  /// No description provided for @routineAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get routineAddStep;

  /// No description provided for @stepTitleEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get stepTitleEnLabel;

  /// No description provided for @stepTitleUrLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (Urdu)'**
  String get stepTitleUrLabel;

  /// No description provided for @stepCueEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Spoken cue (English, optional)'**
  String get stepCueEnLabel;

  /// No description provided for @stepCueUrLabel.
  ///
  /// In en, this message translates to:
  /// **'Spoken cue (Urdu, optional)'**
  String get stepCueUrLabel;

  /// No description provided for @stepTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get stepTimeLabel;

  /// No description provided for @stepIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get stepIconLabel;

  /// No description provided for @leadMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Warn minutes before each step'**
  String get leadMinutesLabel;

  /// No description provided for @countdownWarning.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes left: {title}'**
  String countdownWarning(int minutes, String title);

  /// No description provided for @flexibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Friendly changes'**
  String get flexibilityTitle;

  /// No description provided for @flexibilityExplanation.
  ///
  /// In en, this message translates to:
  /// **'Plan one small change to a known step for today so your child can practise coping with surprises.'**
  String get flexibilityExplanation;

  /// No description provided for @flexibilityPickStep.
  ///
  /// In en, this message translates to:
  /// **'Step to change'**
  String get flexibilityPickStep;

  /// No description provided for @flexibilityNewLabelEn.
  ///
  /// In en, this message translates to:
  /// **'New label (English, optional)'**
  String get flexibilityNewLabelEn;

  /// No description provided for @flexibilityNewLabelUr.
  ///
  /// In en, this message translates to:
  /// **'New label (Urdu, optional)'**
  String get flexibilityNewLabelUr;

  /// No description provided for @flexibilityApply.
  ///
  /// In en, this message translates to:
  /// **'Plan today\'s change'**
  String get flexibilityApply;

  /// No description provided for @flexibilityClear.
  ///
  /// In en, this message translates to:
  /// **'Remove planned change'**
  String get flexibilityClear;

  /// No description provided for @flexibilityPlannedToday.
  ///
  /// In en, this message translates to:
  /// **'A friendly change is planned for today.'**
  String get flexibilityPlannedToday;

  /// No description provided for @flexibilityBadge.
  ///
  /// In en, this message translates to:
  /// **'Planned change'**
  String get flexibilityBadge;

  /// No description provided for @flexibilityWellDone.
  ///
  /// In en, this message translates to:
  /// **'Changes can be fun! Well done.'**
  String get flexibilityWellDone;

  /// No description provided for @routineDeleteStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this step?'**
  String get routineDeleteStepTitle;

  /// No description provided for @routineDeleteStepBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will no longer appear in the daily routine.'**
  String routineDeleteStepBody(String title);

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get deleteAction;

  /// No description provided for @learningEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get learningEditorTitle;

  /// No description provided for @learningPickHint.
  ///
  /// In en, this message translates to:
  /// **'Choose what your child loves. The learning path updates to match.'**
  String get learningPickHint;

  /// No description provided for @learningWhy.
  ///
  /// In en, this message translates to:
  /// **'{name} likes {interest}'**
  String learningWhy(String name, String interest);

  /// No description provided for @learningPathEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a few interests so activities can appear here.'**
  String get learningPathEmptyHint;

  /// No description provided for @learningQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {done} of {total}'**
  String learningQuestionProgress(int done, int total);

  /// No description provided for @breathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathe with me'**
  String get breathingTitle;

  /// No description provided for @breatheIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get breatheIn;

  /// No description provided for @breatheHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get breatheHold;

  /// No description provided for @breatheOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get breatheOut;

  /// No description provided for @breathingStart.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get breathingStart;

  /// No description provided for @breathingStop.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get breathingStop;

  /// No description provided for @sensoryBreathingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A slow pace circle for calm breathing.'**
  String get sensoryBreathingSubtitle;

  /// No description provided for @calmingTitle.
  ///
  /// In en, this message translates to:
  /// **'Calm space'**
  String get calmingTitle;

  /// No description provided for @calmingHint.
  ///
  /// In en, this message translates to:
  /// **'Soft shapes drift slowly. Nothing to do here.'**
  String get calmingHint;

  /// No description provided for @calmSoundOn.
  ///
  /// In en, this message translates to:
  /// **'Gentle sound on'**
  String get calmSoundOn;

  /// No description provided for @calmSoundOff.
  ///
  /// In en, this message translates to:
  /// **'Gentle sound off'**
  String get calmSoundOff;

  /// No description provided for @sensoryCalmingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Slow pastel patterns to settle the eyes.'**
  String get sensoryCalmingSubtitle;

  /// No description provided for @emotionTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotion accuracy, last 7 days'**
  String get emotionTrendTitle;

  /// No description provided for @emotionTrendLatest.
  ///
  /// In en, this message translates to:
  /// **'{percent} latest'**
  String emotionTrendLatest(String percent);

  /// No description provided for @noEmotionDataYet.
  ///
  /// In en, this message translates to:
  /// **'No emotion sessions in the last 7 days yet.'**
  String get noEmotionDataYet;

  /// No description provided for @observationTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get observationTagLabel;

  /// No description provided for @tagGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get tagGeneral;

  /// No description provided for @tagMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get tagMood;

  /// No description provided for @tagBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Behaviour'**
  String get tagBehaviour;

  /// No description provided for @tagSensory.
  ///
  /// In en, this message translates to:
  /// **'Sensory'**
  String get tagSensory;

  /// No description provided for @tagCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get tagCommunication;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @levelPickerForChild.
  ///
  /// In en, this message translates to:
  /// **'Support level for {name}'**
  String levelPickerForChild(String name);

  /// No description provided for @levelAutomaticTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow progress automatically'**
  String get levelAutomaticTitle;

  /// No description provided for @levelAutomaticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Starts from the profile level; three right answers in a row step up, two wrong answers step down.'**
  String get levelAutomaticSubtitle;

  /// No description provided for @levelLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock this level'**
  String get levelLockTitle;

  /// No description provided for @levelLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stops automatic stepping up or down.'**
  String get levelLockSubtitle;

  /// No description provided for @levelLockedNotice.
  ///
  /// In en, this message translates to:
  /// **'Locked — {level} stays fixed.'**
  String levelLockedNotice(Object level);

  /// No description provided for @levelChangedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Support changed to {level}. Restart now to apply it?'**
  String levelChangedPrompt(String level);

  /// No description provided for @levelRestartAction.
  ///
  /// In en, this message translates to:
  /// **'Restart at new level'**
  String get levelRestartAction;

  /// No description provided for @levelContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get levelContinueAction;

  /// No description provided for @rewardCadenceEverySession.
  ///
  /// In en, this message translates to:
  /// **'A star after every completed session.'**
  String get rewardCadenceEverySession;

  /// No description provided for @rewardCadenceEveryN.
  ///
  /// In en, this message translates to:
  /// **'A star every {sessions} completed sessions.'**
  String rewardCadenceEveryN(int sessions);

  /// No description provided for @coopTitle.
  ///
  /// In en, this message translates to:
  /// **'We are a team'**
  String get coopTitle;

  /// No description provided for @coopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} and you, building every win together.'**
  String coopSubtitle(String name);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days in a row'**
  String streakDays(int count);

  /// No description provided for @badgesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get badgesSectionTitle;

  /// No description provided for @progressOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String progressOf(int done, int total);

  /// No description provided for @allBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Every milestone reached — wonderful teamwork!'**
  String get allBadgesEarned;

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
  /// **'Quick calm-down and sound controls'**
  String get sensorySupportTileSubtitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AutiMate'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up a calm space for your child.'**
  String get onboardingSubtitle;

  /// No description provided for @childNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Child\'s name'**
  String get childNameLabel;

  /// No description provided for @chooseLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get chooseLanguageLabel;

  /// No description provided for @createPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Caregiver PIN (4 digits)'**
  String get createPinLabel;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @intermediateSupportLevel.
  ///
  /// In en, this message translates to:
  /// **'Intermediate support level'**
  String get intermediateSupportLevel;

  /// No description provided for @advancedSupportLevel.
  ///
  /// In en, this message translates to:
  /// **'Advanced support level'**
  String get advancedSupportLevel;

  /// No description provided for @parentLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent lock'**
  String get parentLockTitle;

  /// No description provided for @enterParentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter caregiver PIN'**
  String get enterParentPin;

  /// No description provided for @pinIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get pinIncorrect;

  /// No description provided for @unlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockAction;

  /// No description provided for @childModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Child mode'**
  String get childModeLabel;

  /// No description provided for @childModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide caregiver areas behind the parent lock'**
  String get childModeSubtitle;

  /// No description provided for @profilesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get profilesSectionTitle;

  /// No description provided for @addChildLabel.
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get addChildLabel;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Work is saved on this device and will sync later.'**
  String get offlineBanner;

  /// No description provided for @customCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'My cards'**
  String get customCardsTitle;

  /// No description provided for @customCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cards you made for this child'**
  String get customCardsSubtitle;

  /// No description provided for @addCustomCard.
  ///
  /// In en, this message translates to:
  /// **'Add a card'**
  String get addCustomCard;

  /// No description provided for @editCustomCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editCustomCard;

  /// No description provided for @deleteCustomCard.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deleteCustomCard;

  /// No description provided for @cardLabelEnglish.
  ///
  /// In en, this message translates to:
  /// **'Label (English)'**
  String get cardLabelEnglish;

  /// No description provided for @cardLabelUrdu.
  ///
  /// In en, this message translates to:
  /// **'Label (Urdu)'**
  String get cardLabelUrdu;

  /// No description provided for @cardSpokenEnglish.
  ///
  /// In en, this message translates to:
  /// **'Spoken words (English, optional)'**
  String get cardSpokenEnglish;

  /// No description provided for @cardSpokenUrdu.
  ///
  /// In en, this message translates to:
  /// **'Spoken words (Urdu, optional)'**
  String get cardSpokenUrdu;

  /// No description provided for @cardCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get cardCategoryLabel;

  /// No description provided for @cardPictureLabel.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get cardPictureLabel;

  /// No description provided for @choosePhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get choosePhotoGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @useSymbolInstead.
  ///
  /// In en, this message translates to:
  /// **'Use a symbol instead'**
  String get useSymbolInstead;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No camera or gallery on this device. You can still make a card with a symbol.'**
  String get cameraUnavailable;

  /// No description provided for @customCardAdded.
  ///
  /// In en, this message translates to:
  /// **'Card added'**
  String get customCardAdded;

  /// No description provided for @customCardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Card deleted'**
  String get customCardDeleted;

  /// No description provided for @confirmDeleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete this card? It will disappear from the board.'**
  String get confirmDeleteCard;

  /// No description provided for @myCardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards yet. Add one so it appears on the board.'**
  String get myCardsEmpty;

  /// No description provided for @longPressToEditCard.
  ///
  /// In en, this message translates to:
  /// **'Press and hold a card you made to edit it.'**
  String get longPressToEditCard;

  /// No description provided for @reorderSentenceHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a word to change its place.'**
  String get reorderSentenceHint;

  /// No description provided for @removeWordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove this word'**
  String get removeWordTooltip;

  /// No description provided for @sentenceStripEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to start.'**
  String get sentenceStripEmpty;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick start'**
  String get homeQuickActions;

  /// No description provided for @homeStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No days in a row yet} =1{1 day in a row} other{{count} days in a row}}'**
  String homeStreak(int count);

  /// No description provided for @greetingChild.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greetingChild(String name);

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// No description provided for @displaySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Look and feel'**
  String get displaySectionTitle;

  /// No description provided for @themeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Screen brightness'**
  String get themeModeLabel;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match my device'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark can be easier in a dim room.'**
  String get themeModeSubtitle;

  /// No description provided for @chooseTheFace.
  ///
  /// In en, this message translates to:
  /// **'Choose the face'**
  String get chooseTheFace;

  /// No description provided for @tryAgainGently.
  ///
  /// In en, this message translates to:
  /// **'Not that one. Have another look.'**
  String get tryAgainGently;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done'**
  String get wellDone;

  /// No description provided for @starEarned.
  ///
  /// In en, this message translates to:
  /// **'You earned a star'**
  String get starEarned;

  /// No description provided for @nextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next milestone'**
  String get nextMilestone;

  /// No description provided for @earnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earnedLabel;

  /// No description provided for @lockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get lockedLabel;

  /// No description provided for @ambientTrackLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get ambientTrackLabel;

  /// No description provided for @ambientTrackSoftRain.
  ///
  /// In en, this message translates to:
  /// **'Soft rain'**
  String get ambientTrackSoftRain;

  /// No description provided for @ambientTrackSlowOcean.
  ///
  /// In en, this message translates to:
  /// **'Slow waves'**
  String get ambientTrackSlowOcean;

  /// No description provided for @ambientTrackWarmHum.
  ///
  /// In en, this message translates to:
  /// **'Warm hum'**
  String get ambientTrackWarmHum;

  /// No description provided for @ambientVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'How loud'**
  String get ambientVolumeLabel;

  /// No description provided for @ambientVolumeHint.
  ///
  /// In en, this message translates to:
  /// **'The app keeps a quiet upper limit, even at maximum.'**
  String get ambientVolumeHint;

  /// No description provided for @symbolSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Card size'**
  String get symbolSizeLabel;

  /// No description provided for @symbolSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bigger cards mean fewer on screen, which is often easier.'**
  String get symbolSizeSubtitle;

  /// No description provided for @symbolSizeComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get symbolSizeComfortable;

  /// No description provided for @symbolSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get symbolSizeLarge;

  /// No description provided for @symbolSizeLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get symbolSizeLargest;

  /// No description provided for @literacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading support'**
  String get literacyTitle;

  /// No description provided for @literacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Brings the written word forward as reading grows. Move one step at a time, and step back if the board gets harder.'**
  String get literacySubtitle;

  /// No description provided for @literacyOff.
  ///
  /// In en, this message translates to:
  /// **'Symbols only'**
  String get literacyOff;

  /// No description provided for @literacyFlash.
  ///
  /// In en, this message translates to:
  /// **'Show the word on tap'**
  String get literacyFlash;

  /// No description provided for @literacyEmphasis.
  ///
  /// In en, this message translates to:
  /// **'Bigger words'**
  String get literacyEmphasis;

  /// No description provided for @literacyFading.
  ///
  /// In en, this message translates to:
  /// **'Words lead'**
  String get literacyFading;

  /// No description provided for @literacyTextOnly.
  ///
  /// In en, this message translates to:
  /// **'Words only'**
  String get literacyTextOnly;

  /// No description provided for @literacyCaution.
  ///
  /// In en, this message translates to:
  /// **'Every child is different. If the board becomes harder to use, step back a level — that is not a setback.'**
  String get literacyCaution;

  /// No description provided for @literacyCurrent.
  ///
  /// In en, this message translates to:
  /// **'Now: {level}'**
  String literacyCurrent(String level);

  /// No description provided for @waitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waitingTitle;

  /// No description provided for @waitingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are waiting. Watch the ring get smaller.'**
  String get waitingSubtitle;

  /// No description provided for @waitingDone.
  ///
  /// In en, this message translates to:
  /// **'The waiting is finished.'**
  String get waitingDone;

  /// No description provided for @waitingMinutesLeft.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get waitingMinutesLeft;

  /// No description provided for @waitingStart.
  ///
  /// In en, this message translates to:
  /// **'Start waiting'**
  String get waitingStart;

  /// No description provided for @waitingPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get waitingPause;

  /// No description provided for @waitingReset.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get waitingReset;

  /// No description provided for @waitingOneMore.
  ///
  /// In en, this message translates to:
  /// **'One more minute'**
  String get waitingOneMore;

  /// No description provided for @waitingHowLong.
  ///
  /// In en, this message translates to:
  /// **'How long?'**
  String get waitingHowLong;

  /// No description provided for @waitingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String waitingMinutes(int count);

  /// No description provided for @waitingStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'How the timer moves'**
  String get waitingStyleTitle;

  /// No description provided for @waitingStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Some children watch a moving ring closely. Others find it easier when it changes in steps, or not at all.'**
  String get waitingStyleSubtitle;

  /// No description provided for @waitingStyleSmooth.
  ///
  /// In en, this message translates to:
  /// **'Smooth'**
  String get waitingStyleSmooth;

  /// No description provided for @waitingStyleStepped.
  ///
  /// In en, this message translates to:
  /// **'In steps'**
  String get waitingStyleStepped;

  /// No description provided for @waitingStyleStill.
  ///
  /// In en, this message translates to:
  /// **'Numbers only'**
  String get waitingStyleStill;

  /// No description provided for @waitingTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waitingTileTitle;

  /// No description provided for @waitingTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A timer for hard waits'**
  String get waitingTileSubtitle;

  /// No description provided for @cardVoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Your voice'**
  String get cardVoiceLabel;

  /// No description provided for @cardVoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record yourself saying this word. Your own voice is often clearer and more motivating than the device voice.'**
  String get cardVoiceSubtitle;

  /// No description provided for @cardVoiceConsent.
  ///
  /// In en, this message translates to:
  /// **'Record your own voice, not the child\'s. The card is something they will say, so it helps to hear an adult say it first.'**
  String get cardVoiceConsent;

  /// No description provided for @cardVoiceRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get cardVoiceRecord;

  /// No description provided for @cardVoiceStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get cardVoiceStop;

  /// No description provided for @cardVoicePlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get cardVoicePlay;

  /// No description provided for @cardVoiceDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove recording'**
  String get cardVoiceDelete;

  /// No description provided for @cardVoiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get cardVoiceRecording;

  /// No description provided for @cardVoiceSaved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved'**
  String get cardVoiceSaved;

  /// No description provided for @cardVoiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device cannot record. The card will use the device voice.'**
  String get cardVoiceUnavailable;

  /// No description provided for @cardVoiceDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is needed to record. You can allow it in settings.'**
  String get cardVoiceDenied;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and transfer'**
  String get backupTitle;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save everything to a file, or bring it back on another device. Works with no internet and no account.'**
  String get backupSubtitle;

  /// No description provided for @backupExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Save a backup'**
  String get backupExportTitle;

  /// No description provided for @backupExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Children, cards, routines, and progress. Photos and recordings stay on this device.'**
  String get backupExportSubtitle;

  /// No description provided for @backupExportAction.
  ///
  /// In en, this message translates to:
  /// **'Save and share'**
  String get backupExportAction;

  /// No description provided for @backupImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a file'**
  String get backupImportTitle;

  /// No description provided for @backupImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file you saved before.'**
  String get backupImportSubtitle;

  /// No description provided for @backupImportAction.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get backupImportAction;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Backup saved for 1 child} other{Backup saved for {count} children}}'**
  String backupExported(int count);

  /// No description provided for @backupImported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Restored 1 child} other{Restored {count} children}}'**
  String backupImported(int count);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Nothing on this device was changed.'**
  String get backupFailed;

  /// No description provided for @backupErrorNotJson.
  ///
  /// In en, this message translates to:
  /// **'That file is not a backup. Look for a file ending in .json.'**
  String get backupErrorNotJson;

  /// No description provided for @backupErrorNotOurs.
  ///
  /// In en, this message translates to:
  /// **'That is a file, but not an AutiMate backup.'**
  String get backupErrorNotOurs;

  /// No description provided for @backupErrorTooNew.
  ///
  /// In en, this message translates to:
  /// **'That backup was made by a newer version of AutiMate. Update the app first.'**
  String get backupErrorTooNew;

  /// No description provided for @backupErrorUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The file could not be opened.'**
  String get backupErrorUnreadable;

  /// No description provided for @backupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get backupConfirmTitle;

  /// No description provided for @backupConfirmContents.
  ///
  /// In en, this message translates to:
  /// **'Children: {names}. {cards} cards, {sessions} recorded activities.'**
  String backupConfirmContents(String names, int cards, int sessions);

  /// No description provided for @backupMediaNote.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo or recording is not in this file and will not come back.} other{{count} photos and recordings are not in this file and will not come back.}}'**
  String backupMediaNote(int count);

  /// No description provided for @backupModeMerge.
  ///
  /// In en, this message translates to:
  /// **'Add to what is here'**
  String get backupModeMerge;

  /// No description provided for @backupModeMergeHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing already on this device is removed.'**
  String get backupModeMergeHint;

  /// No description provided for @backupModeReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace everything'**
  String get backupModeReplace;

  /// No description provided for @backupModeReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Removes the children and cards already on this device.'**
  String get backupModeReplaceHint;

  /// No description provided for @backupPrivacyWarning.
  ///
  /// In en, this message translates to:
  /// **'A backup file holds your child\'s name, cards, and activity history in plain text. Keep it somewhere private, and delete it when you no longer need it.'**
  String get backupPrivacyWarning;

  /// No description provided for @backupTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and transfer'**
  String get backupTileTitle;

  /// No description provided for @backupTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save or restore everything'**
  String get backupTileSubtitle;

  /// No description provided for @predictionLabel.
  ///
  /// In en, this message translates to:
  /// **'Word suggestions'**
  String get predictionLabel;

  /// No description provided for @predictionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offers a few likely next words above the board. Helps a child who is reading; can be a distraction for one who is not.'**
  String get predictionSubtitle;

  /// No description provided for @predictionSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Next word'**
  String get predictionSuggestions;

  /// No description provided for @phraseBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved phrases'**
  String get phraseBankTitle;

  /// No description provided for @phraseBankSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Whole sentences for one tap. Tapping loads the cards into the strip so the sentence is still built from its parts.'**
  String get phraseBankSubtitle;

  /// No description provided for @phraseBankEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved phrases yet. Build a sentence, then save it.'**
  String get phraseBankEmpty;

  /// No description provided for @phraseBankSave.
  ///
  /// In en, this message translates to:
  /// **'Save this sentence'**
  String get phraseBankSave;

  /// No description provided for @phraseBankDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove phrase'**
  String get phraseBankDelete;

  /// No description provided for @phraseBankSpeakNow.
  ///
  /// In en, this message translates to:
  /// **'Speak straight away'**
  String get phraseBankSpeakNow;

  /// No description provided for @phraseBankSpeakNowHint.
  ///
  /// In en, this message translates to:
  /// **'Skips building the sentence. Use it only where speed really matters.'**
  String get phraseBankSpeakNowHint;

  /// No description provided for @phraseBankUrgent.
  ///
  /// In en, this message translates to:
  /// **'Needed in a hurry'**
  String get phraseBankUrgent;

  /// No description provided for @phraseBankUrgentHint.
  ///
  /// In en, this message translates to:
  /// **'Sorts first, and can appear on the home screen.'**
  String get phraseBankUrgentHint;

  /// No description provided for @phraseBankFull.
  ///
  /// In en, this message translates to:
  /// **'The phrase list is full. Remove one to add another.'**
  String get phraseBankFull;

  /// No description provided for @phraseBankCaution.
  ///
  /// In en, this message translates to:
  /// **'Saved phrases are a shortcut, not a replacement. Building sentences is the skill, so keep this list short.'**
  String get phraseBankCaution;

  /// No description provided for @gridShapeLabel.
  ///
  /// In en, this message translates to:
  /// **'Board layout'**
  String get gridShapeLabel;

  /// No description provided for @gridShapeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fewer cards on screen means bigger targets and less to scan.'**
  String get gridShapeSubtitle;

  /// No description provided for @gridShapeFlowing.
  ///
  /// In en, this message translates to:
  /// **'Fit as many as possible'**
  String get gridShapeFlowing;

  /// No description provided for @gridShapeTwoByTwo.
  ///
  /// In en, this message translates to:
  /// **'4 cards'**
  String get gridShapeTwoByTwo;

  /// No description provided for @gridShapeThreeByTwo.
  ///
  /// In en, this message translates to:
  /// **'6 cards'**
  String get gridShapeThreeByTwo;

  /// No description provided for @gridShapeThreeByThree.
  ///
  /// In en, this message translates to:
  /// **'9 cards'**
  String get gridShapeThreeByThree;

  /// No description provided for @gridShapeFourByThree.
  ///
  /// In en, this message translates to:
  /// **'12 cards'**
  String get gridShapeFourByThree;

  /// No description provided for @gridShapeFiveByFour.
  ///
  /// In en, this message translates to:
  /// **'20 cards'**
  String get gridShapeFiveByFour;

  /// No description provided for @gridShapeSixByEight.
  ///
  /// In en, this message translates to:
  /// **'48 cards'**
  String get gridShapeSixByEight;

  /// No description provided for @gridShapeNote.
  ///
  /// In en, this message translates to:
  /// **'A fixed layout is groundwork for keeping every word in one place. The category filter still moves cards, so that is not fully true yet.'**
  String get gridShapeNote;

  /// No description provided for @gridPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String gridPageOf(int page, int total);

  /// No description provided for @printBoardTitle.
  ///
  /// In en, this message translates to:
  /// **'Print the board'**
  String get printBoardTitle;

  /// No description provided for @printBoardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A paper copy with the same layout and colours. Useful when the device is flat, at school, or being charged.'**
  String get printBoardSubtitle;

  /// No description provided for @printBoardAction.
  ///
  /// In en, this message translates to:
  /// **'Make a PDF'**
  String get printBoardAction;

  /// No description provided for @printBoardWorking.
  ///
  /// In en, this message translates to:
  /// **'Building the PDF…'**
  String get printBoardWorking;

  /// No description provided for @printBoardFailed.
  ///
  /// In en, this message translates to:
  /// **'The PDF could not be made.'**
  String get printBoardFailed;

  /// No description provided for @breathingPatternLabel.
  ///
  /// In en, this message translates to:
  /// **'Breathing pattern'**
  String get breathingPatternLabel;

  /// No description provided for @breathingPatternGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get breathingPatternGentle;

  /// No description provided for @breathingPatternBox.
  ///
  /// In en, this message translates to:
  /// **'Box (4-4-4-4)'**
  String get breathingPatternBox;

  /// No description provided for @breathingPatternFourSevenEight.
  ///
  /// In en, this message translates to:
  /// **'4-7-8'**
  String get breathingPatternFourSevenEight;

  /// No description provided for @breathingPatternNote.
  ///
  /// In en, this message translates to:
  /// **'A longer breath out than in is the part that calms. These are calming exercises, not treatment.'**
  String get breathingPatternNote;

  /// No description provided for @breathPhaseInhale.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get breathPhaseInhale;

  /// No description provided for @breathPhaseHoldIn.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get breathPhaseHoldIn;

  /// No description provided for @breathPhaseExhale.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get breathPhaseExhale;

  /// No description provided for @breathPhaseHoldOut.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get breathPhaseHoldOut;

  /// No description provided for @intensityTitle.
  ///
  /// In en, this message translates to:
  /// **'How strong is it?'**
  String get intensityTitle;

  /// No description provided for @intensitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how big the feeling is right now.'**
  String get intensitySubtitle;

  /// No description provided for @intensityALittle.
  ///
  /// In en, this message translates to:
  /// **'A little'**
  String get intensityALittle;

  /// No description provided for @intensitySomeWhat.
  ///
  /// In en, this message translates to:
  /// **'A bit'**
  String get intensitySomeWhat;

  /// No description provided for @intensityQuite.
  ///
  /// In en, this message translates to:
  /// **'Quite a lot'**
  String get intensityQuite;

  /// No description provided for @intensityVery.
  ///
  /// In en, this message translates to:
  /// **'A lot'**
  String get intensityVery;

  /// No description provided for @intensityTooMuch.
  ///
  /// In en, this message translates to:
  /// **'Too much'**
  String get intensityTooMuch;

  /// No description provided for @intensitySupportBreathing.
  ///
  /// In en, this message translates to:
  /// **'Would some slow breathing help?'**
  String get intensitySupportBreathing;

  /// No description provided for @intensitySupportTellSomeone.
  ///
  /// In en, this message translates to:
  /// **'Would you like to tell someone?'**
  String get intensitySupportTellSomeone;

  /// No description provided for @intensityNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get intensityNotNow;

  /// No description provided for @intensityCaution.
  ///
  /// In en, this message translates to:
  /// **'This is what the child said, not a measurement. It is not added up or tracked over time.'**
  String get intensityCaution;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'How far you have come'**
  String get achievementsTitle;

  /// No description provided for @achievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Firsts and milestones, taken from what was actually recorded.'**
  String get achievementsSubtitle;

  /// No description provided for @achievementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Milestones will appear here after a few activities.'**
  String get achievementsEmpty;

  /// No description provided for @achievementFirstSession.
  ///
  /// In en, this message translates to:
  /// **'First activity together'**
  String get achievementFirstSession;

  /// No description provided for @achievementFirstActivity.
  ///
  /// In en, this message translates to:
  /// **'First {type} activity'**
  String achievementFirstActivity(String type);

  /// No description provided for @achievementBadge.
  ///
  /// In en, this message translates to:
  /// **'Milestone reached'**
  String get achievementBadge;

  /// No description provided for @achievementStreak.
  ///
  /// In en, this message translates to:
  /// **'Best run: {days} days'**
  String achievementStreak(int days);

  /// No description provided for @achievementSessions.
  ///
  /// In en, this message translates to:
  /// **'{count} activities completed'**
  String achievementSessions(int count);
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
