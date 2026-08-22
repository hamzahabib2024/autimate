// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navCommunicate => 'Communicate';

  @override
  String get navRoutine => 'Routine';

  @override
  String get navProgress => 'Progress';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get homeGreeting => 'Good morning, caregiver';

  @override
  String get homeTagline =>
      'A calm place to communicate, learn, and practise together.';

  @override
  String get homeToday => 'Today';

  @override
  String get emotionPracticeTileTitle => 'Emotion practice';

  @override
  String get emotionPracticeTileSubtitle => 'Learn six everyday expressions';

  @override
  String get socialStoriesTileTitle => 'Social stories';

  @override
  String get socialStoriesTileSubtitle => 'Stories and conversation practice';

  @override
  String get tabStories => 'Stories';

  @override
  String get tabConversations => 'Conversations';

  @override
  String get narrateTooltip => 'Read aloud';

  @override
  String get nextPageTooltip => 'Next page';

  @override
  String get previousPageTooltip => 'Previous page';

  @override
  String get comprehensionTitle => 'Let\'s check understanding';

  @override
  String get conversationComplete =>
      'You finished the conversation! A star was earned.';

  @override
  String get conversationHint =>
      'Choose a situation, then pick the reply that fits.';

  @override
  String get gentleRetry => 'That is okay. Let\'s try another way.';

  @override
  String storyPagesCount(int count) {
    return '$count pages';
  }

  @override
  String get learningPathTileTitle => 'Learning path';

  @override
  String get learningPathTileSubtitle =>
      'Interest-based activities are coming next';

  @override
  String get beginnerSupportLevel => 'Beginner support level';

  @override
  String starsEarned(int count) {
    return '$count stars earned';
  }

  @override
  String get comingNextPhase => 'Coming in the next phase';

  @override
  String get safeByDesign => 'Safe by design';

  @override
  String get safeByDesignMessage =>
      'This module will use fixed, caregiver-approved content. Open-ended child chat is out of scope.';

  @override
  String get interestLearningDescription =>
      'Deterministic interest-to-topic mapping will power this learning path.';

  @override
  String get socialStoriesDescription =>
      'Short illustrated stories and guided comprehension checks will live here.';

  @override
  String get communicateTitle => 'Communicate';

  @override
  String get speakSentenceTooltip => 'Speak sentence';

  @override
  String get sentenceHeader => 'Sentence';

  @override
  String get tapCardToBuild => 'Tap a card to build a sentence';

  @override
  String get clearSentenceTooltip => 'Clear sentence';

  @override
  String get frequentlyUsed => 'Frequently used';

  @override
  String get recentCardsHint => 'Your recent cards will appear here.';

  @override
  String get coreWords => 'Core words';

  @override
  String get allCategories => 'All';

  @override
  String get aacCategoryFood => 'Food';

  @override
  String get aacCategoryDrinks => 'Drinks';

  @override
  String get aacCategoryEmotions => 'Emotions';

  @override
  String get aacCategoryActivities => 'Activities';

  @override
  String get aacCategoryPeople => 'People';

  @override
  String get aacCategoryPlaces => 'Places';

  @override
  String get aacCategoryNeeds => 'Needs';

  @override
  String get aacCategoryObjects => 'Objects';

  @override
  String get removeLastWordTooltip => 'Remove last word';

  @override
  String get emotionPracticeTitle => 'Emotion practice';

  @override
  String get sessionComplete => 'Session complete';

  @override
  String sessionSummary(int score, int total, int stars) {
    return '$score of $total correct • $stars stars earned';
  }

  @override
  String get practiseAgain => 'Practise again';

  @override
  String questionProgress(int index, int total) {
    return 'Question $index of $total';
  }

  @override
  String whichFaceFeels(String emotion) {
    return 'Which face feels $emotion?';
  }

  @override
  String get emotionHappy => 'Happy';

  @override
  String get emotionSad => 'Sad';

  @override
  String get emotionAngry => 'Angry';

  @override
  String get emotionSurprised => 'Surprised';

  @override
  String get emotionScared => 'Scared';

  @override
  String get emotionNeutral => 'Neutral';

  @override
  String get beginnerHint =>
      'Hint: look at the face and choose the matching feeling.';

  @override
  String get answerCorrect => 'That is right.';

  @override
  String get answerIncorrect => 'Let us try the next one.';

  @override
  String get cameraPracticeTitle => 'Camera expression practice';

  @override
  String get cameraPracticeMessage =>
      'On-device smile detection logic is implemented; the ML Kit camera adapter lands after physical-device verification. A simulated demo is available now.';

  @override
  String get expressionTitle => 'Expression practice';

  @override
  String get expressionStart => 'Start practice';

  @override
  String get expressionHoldSmile => 'Hold a big smile for one second';

  @override
  String get expressionUnsupported =>
      'Expression practice is not available on this device.';

  @override
  String get expressionPermissionDenied =>
      'Camera permission is needed. A caregiver can allow it in device settings.';

  @override
  String get expressionLoadingCamera => 'Starting the camera...';

  @override
  String get expressionCameraError =>
      'Something went wrong with the camera. Please try again.';

  @override
  String expressionSmileProgress(int done, int total) {
    return '$done of $total smiles held';
  }

  @override
  String expressionSessionComplete(int stars) {
    return 'Great smiling! $stars stars earned';
  }

  @override
  String get expressionPrivacyTitle => 'Private by design';

  @override
  String get expressionPrivacyNote =>
      'Frames stay in memory on this device and are never stored or uploaded. Only star totals are recorded.';

  @override
  String get expressionRationaleTitle => 'Why the camera?';

  @override
  String get expressionRationaleBody =>
      'The camera watches for your smile so stars can be awarded. Frames stay on this device and are never saved or uploaded.';

  @override
  String get expressionAllowCamera => 'Allow camera';

  @override
  String get expressionNotNow => 'Not now';

  @override
  String get expressionComeCloserHint => 'Come closer to the camera';

  @override
  String get expressionEyesHint => 'Try opening your eyes';

  @override
  String get expressionLookStraightHint => 'Look straight at the camera';

  @override
  String get routineEditTooltip => 'Edit routine';

  @override
  String get routineEditorTitle => 'Routine editor';

  @override
  String get routineAddStep => 'Add step';

  @override
  String get stepTitleEnLabel => 'Title (English)';

  @override
  String get stepTitleUrLabel => 'Title (Urdu)';

  @override
  String get stepCueEnLabel => 'Spoken cue (English, optional)';

  @override
  String get stepCueUrLabel => 'Spoken cue (Urdu, optional)';

  @override
  String get stepTimeLabel => 'Time';

  @override
  String get stepIconLabel => 'Icon';

  @override
  String get leadMinutesLabel => 'Warn minutes before each step';

  @override
  String countdownWarning(int minutes, String title) {
    return '$minutes minutes left: $title';
  }

  @override
  String get flexibilityTitle => 'Friendly changes';

  @override
  String get flexibilityExplanation =>
      'Plan one small change to a known step for today so your child can practise coping with surprises.';

  @override
  String get flexibilityPickStep => 'Step to change';

  @override
  String get flexibilityNewLabelEn => 'New label (English, optional)';

  @override
  String get flexibilityNewLabelUr => 'New label (Urdu, optional)';

  @override
  String get flexibilityApply => 'Plan today\'s change';

  @override
  String get flexibilityClear => 'Remove planned change';

  @override
  String get flexibilityPlannedToday =>
      'A friendly change is planned for today.';

  @override
  String get flexibilityBadge => 'Planned change';

  @override
  String get flexibilityWellDone => 'Changes can be fun! Well done.';

  @override
  String get routineDeleteStepTitle => 'Remove this step?';

  @override
  String routineDeleteStepBody(String title) {
    return '\"$title\" will no longer appear in the daily routine.';
  }

  @override
  String get deleteAction => 'Remove';

  @override
  String get routineTitle => 'Routine';

  @override
  String get oneStepAtATime => 'One step at a time';

  @override
  String get routineProgressLabel => 'Routine progress';

  @override
  String stepsDone(int done, int total) {
    return '$done of $total steps done';
  }

  @override
  String get transitionWarnings => 'Transition warnings';

  @override
  String get transitionWarningsSubtitle =>
      'Speak each step when its time arrives while this screen is open';

  @override
  String get resetToday => 'Reset today';

  @override
  String get progressTitle => 'Progress';

  @override
  String childWeekHeader(String name) {
    return '$name\'s week';
  }

  @override
  String get metricActivities => 'Activities';

  @override
  String get metricRoutine => 'Routine';

  @override
  String get metricStars => 'Stars';

  @override
  String get activitiesThisWeek => 'Activities this week';

  @override
  String get explainableProgress => 'Explainable progress';

  @override
  String get explainableProgressMessage =>
      'Charts are based on recorded activities and never make clinical claims.';

  @override
  String get caregiverNotes => 'Caregiver notes';

  @override
  String get noObservationsYet => 'No observations logged yet.';

  @override
  String get logObservation => 'Log an observation';

  @override
  String get observationButton => 'Observation';

  @override
  String get observationHint => 'What did you notice today?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sensoryMode => 'Sensory-friendly mode';

  @override
  String get sensoryModeSubtitle =>
      'Reduce motion, clutter, and sound intensity';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get supportLevel => 'Support level';

  @override
  String get supportLevelSubtitle => 'Beginner, controlled by caregiver';

  @override
  String get supportLevelDescription =>
      'Adaptive difficulty will be connected to the rule-based controller here.';

  @override
  String get privacySafety => 'Privacy and safety';

  @override
  String get privacySafetySubtitle =>
      'No diagnosis, no child-facing open chat, camera processing stays on-device';

  @override
  String get signOut => 'Sign out';

  @override
  String get authWelcome => 'Welcome to AutiMate';

  @override
  String get authTagline =>
      'A calm communication and learning space for children and caregivers.';

  @override
  String get parentEmail => 'Parent email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Loading...';

  @override
  String get createParentAccount => 'Create a parent account';

  @override
  String get authErrorRequired => 'Enter an email and password to continue.';

  @override
  String get gamificationComingMessage =>
      'Badges, streaks, and progress rings will connect to completed activities.';

  @override
  String get sensorySupportTitle => 'Sensory support';

  @override
  String get ttsControlsTitle => 'Sound and motion controls';

  @override
  String get ttsControlsMessage =>
      'Sensory-friendly mode automatically softens speech rate and volume.';

  @override
  String get gamificationTileTitle => 'Stars and rewards';

  @override
  String get gamificationTileSubtitle => 'See stars earned from activities';

  @override
  String get sensorySupportTileTitle => 'Sensory support';

  @override
  String get sensorySupportTileSubtitle => 'Quick calm-down and sound controls';

  @override
  String get onboardingTitle => 'Welcome to AutiMate';

  @override
  String get onboardingSubtitle => 'Set up a calm space for your child.';

  @override
  String get childNameLabel => 'Child\'s name';

  @override
  String get chooseLanguageLabel => 'App language';

  @override
  String get createPinLabel => 'Caregiver PIN (4 digits)';

  @override
  String get getStarted => 'Get started';

  @override
  String get intermediateSupportLevel => 'Intermediate support level';

  @override
  String get advancedSupportLevel => 'Advanced support level';

  @override
  String get parentLockTitle => 'Parent lock';

  @override
  String get enterParentPin => 'Enter caregiver PIN';

  @override
  String get pinIncorrect => 'Incorrect PIN. Try again.';

  @override
  String get unlockAction => 'Unlock';

  @override
  String get childModeLabel => 'Child mode';

  @override
  String get childModeSubtitle => 'Hide caregiver areas behind the parent lock';

  @override
  String get profilesSectionTitle => 'Children';

  @override
  String get addChildLabel => 'Add child';

  @override
  String get offlineBanner =>
      'You are offline. Work is saved on this device and will sync later.';
}
