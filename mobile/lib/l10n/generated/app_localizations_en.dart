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
  String get socialStoriesTileSubtitle =>
      'Designed and documented for the next phase';

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
      'P1 placeholder. Future on-device ML Kit processing will stay in memory and never upload frames.';

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
  String get sensorySupportTileSubtitle => 'Quick calming and sound controls';
}
