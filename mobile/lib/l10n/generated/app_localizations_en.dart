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
  String get learningEditorTitle => 'Interests';

  @override
  String get learningPickHint =>
      'Choose what your child loves. The learning path updates to match.';

  @override
  String learningWhy(String name, String interest) {
    return '$name likes $interest';
  }

  @override
  String get learningPathEmptyHint =>
      'Pick a few interests so activities can appear here.';

  @override
  String learningQuestionProgress(int done, int total) {
    return 'Question $done of $total';
  }

  @override
  String get breathingTitle => 'Breathe with me';

  @override
  String get breatheIn => 'Breathe in';

  @override
  String get breatheHold => 'Hold';

  @override
  String get breatheOut => 'Breathe out';

  @override
  String get breathingStart => 'Begin';

  @override
  String get breathingStop => 'Rest';

  @override
  String get sensoryBreathingSubtitle =>
      'A slow pace circle for calm breathing.';

  @override
  String get calmingTitle => 'Calm space';

  @override
  String get calmingHint => 'Soft shapes drift slowly. Nothing to do here.';

  @override
  String get calmSoundOn => 'Gentle sound on';

  @override
  String get calmSoundOff => 'Gentle sound off';

  @override
  String get sensoryCalmingSubtitle =>
      'Slow pastel patterns to settle the eyes.';

  @override
  String get emotionTrendTitle => 'Emotion accuracy, last 7 days';

  @override
  String emotionTrendLatest(String percent) {
    return '$percent latest';
  }

  @override
  String get noEmotionDataYet => 'No emotion sessions in the last 7 days yet.';

  @override
  String get observationTagLabel => 'Category';

  @override
  String get tagGeneral => 'General';

  @override
  String get tagMood => 'Mood';

  @override
  String get tagBehaviour => 'Behaviour';

  @override
  String get tagSensory => 'Sensory';

  @override
  String get tagCommunication => 'Communication';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String levelPickerForChild(String name) {
    return 'Support level for $name';
  }

  @override
  String get levelAutomaticTitle => 'Follow progress automatically';

  @override
  String get levelAutomaticSubtitle =>
      'Starts from the profile level; three right answers in a row step up, two wrong answers step down.';

  @override
  String get levelLockTitle => 'Lock this level';

  @override
  String get levelLockSubtitle => 'Stops automatic stepping up or down.';

  @override
  String levelLockedNotice(Object level) {
    return 'Locked — $level stays fixed.';
  }

  @override
  String levelChangedPrompt(String level) {
    return 'Support changed to $level. Restart now to apply it?';
  }

  @override
  String get levelRestartAction => 'Restart at new level';

  @override
  String get levelContinueAction => 'Keep going';

  @override
  String get rewardCadenceEverySession =>
      'A star after every completed session.';

  @override
  String rewardCadenceEveryN(int sessions) {
    return 'A star every $sessions completed sessions.';
  }

  @override
  String get coopTitle => 'We are a team';

  @override
  String coopSubtitle(String name) {
    return '$name and you, building every win together.';
  }

  @override
  String streakDays(int count) {
    return '$count days in a row';
  }

  @override
  String get badgesSectionTitle => 'Milestones';

  @override
  String progressOf(int done, int total) {
    return '$done of $total';
  }

  @override
  String get allBadgesEarned => 'Every milestone reached — wonderful teamwork!';

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

  @override
  String get customCardsTitle => 'My cards';

  @override
  String get customCardsSubtitle => 'Cards you made for this child';

  @override
  String get addCustomCard => 'Add a card';

  @override
  String get editCustomCard => 'Edit card';

  @override
  String get deleteCustomCard => 'Delete card';

  @override
  String get cardLabelEnglish => 'Label (English)';

  @override
  String get cardLabelUrdu => 'Label (Urdu)';

  @override
  String get cardSpokenEnglish => 'Spoken words (English, optional)';

  @override
  String get cardSpokenUrdu => 'Spoken words (Urdu, optional)';

  @override
  String get cardCategoryLabel => 'Category';

  @override
  String get cardPictureLabel => 'Picture';

  @override
  String get choosePhotoGallery => 'Choose from gallery';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get useSymbolInstead => 'Use a symbol instead';

  @override
  String get cameraUnavailable =>
      'No camera or gallery on this device. You can still make a card with a symbol.';

  @override
  String get customCardAdded => 'Card added';

  @override
  String get customCardDeleted => 'Card deleted';

  @override
  String get confirmDeleteCard =>
      'Delete this card? It will disappear from the board.';

  @override
  String get myCardsEmpty =>
      'No cards yet. Add one so it appears on the board.';

  @override
  String get longPressToEditCard =>
      'Press and hold a card you made to edit it.';

  @override
  String get reorderSentenceHint => 'Drag a word to change its place.';

  @override
  String get removeWordTooltip => 'Remove this word';

  @override
  String get sentenceStripEmpty => 'Tap a card to start.';

  @override
  String get homeQuickActions => 'Quick start';

  @override
  String homeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
      one: '1 day in a row',
      zero: 'No days in a row yet',
    );
    return '$_temp0';
  }

  @override
  String greetingChild(String name) {
    return 'Hello, $name';
  }

  @override
  String get openSettings => 'Settings';

  @override
  String get displaySectionTitle => 'Look and feel';

  @override
  String get themeModeLabel => 'Screen brightness';

  @override
  String get themeModeSystem => 'Match my device';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeSubtitle => 'Dark can be easier in a dim room.';

  @override
  String get chooseTheFace => 'Choose the face';

  @override
  String get tryAgainGently => 'Not that one. Have another look.';

  @override
  String get wellDone => 'Well done';

  @override
  String get starEarned => 'You earned a star';

  @override
  String get nextMilestone => 'Next milestone';

  @override
  String get earnedLabel => 'Earned';

  @override
  String get lockedLabel => 'Keep going';

  @override
  String get ambientTrackLabel => 'Sound';

  @override
  String get ambientTrackSoftRain => 'Soft rain';

  @override
  String get ambientTrackSlowOcean => 'Slow waves';

  @override
  String get ambientTrackWarmHum => 'Warm hum';

  @override
  String get ambientVolumeLabel => 'How loud';

  @override
  String get ambientVolumeHint =>
      'The app keeps a quiet upper limit, even at maximum.';

  @override
  String get symbolSizeLabel => 'Card size';

  @override
  String get symbolSizeSubtitle =>
      'Bigger cards mean fewer on screen, which is often easier.';

  @override
  String get symbolSizeComfortable => 'Comfortable';

  @override
  String get symbolSizeLarge => 'Large';

  @override
  String get symbolSizeLargest => 'Largest';

  @override
  String get literacyTitle => 'Reading support';

  @override
  String get literacySubtitle =>
      'Brings the written word forward as reading grows. Move one step at a time, and step back if the board gets harder.';

  @override
  String get literacyOff => 'Symbols only';

  @override
  String get literacyFlash => 'Show the word on tap';

  @override
  String get literacyEmphasis => 'Bigger words';

  @override
  String get literacyFading => 'Words lead';

  @override
  String get literacyTextOnly => 'Words only';

  @override
  String get literacyCaution =>
      'Every child is different. If the board becomes harder to use, step back a level — that is not a setback.';

  @override
  String literacyCurrent(String level) {
    return 'Now: $level';
  }

  @override
  String get waitingTitle => 'Waiting';

  @override
  String get waitingSubtitle => 'We are waiting. Watch the ring get smaller.';

  @override
  String get waitingDone => 'The waiting is finished.';

  @override
  String get waitingMinutesLeft => 'left';

  @override
  String get waitingStart => 'Start waiting';

  @override
  String get waitingPause => 'Pause';

  @override
  String get waitingReset => 'Start over';

  @override
  String get waitingOneMore => 'One more minute';

  @override
  String get waitingHowLong => 'How long?';

  @override
  String waitingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get waitingStyleTitle => 'How the timer moves';

  @override
  String get waitingStyleSubtitle =>
      'Some children watch a moving ring closely. Others find it easier when it changes in steps, or not at all.';

  @override
  String get waitingStyleSmooth => 'Smooth';

  @override
  String get waitingStyleStepped => 'In steps';

  @override
  String get waitingStyleStill => 'Numbers only';

  @override
  String get waitingTileTitle => 'Waiting';

  @override
  String get waitingTileSubtitle => 'A timer for hard waits';

  @override
  String get cardVoiceLabel => 'Your voice';

  @override
  String get cardVoiceSubtitle =>
      'Record yourself saying this word. Your own voice is often clearer and more motivating than the device voice.';

  @override
  String get cardVoiceConsent =>
      'Record your own voice, not the child\'s. The card is something they will say, so it helps to hear an adult say it first.';

  @override
  String get cardVoiceRecord => 'Record';

  @override
  String get cardVoiceStop => 'Stop';

  @override
  String get cardVoicePlay => 'Play';

  @override
  String get cardVoiceDelete => 'Remove recording';

  @override
  String get cardVoiceRecording => 'Recording…';

  @override
  String get cardVoiceSaved => 'Recording saved';

  @override
  String get cardVoiceUnavailable =>
      'This device cannot record. The card will use the device voice.';

  @override
  String get cardVoiceDenied =>
      'Microphone permission is needed to record. You can allow it in settings.';

  @override
  String get backupTitle => 'Backup and transfer';

  @override
  String get backupSubtitle =>
      'Save everything to a file, or bring it back on another device. Works with no internet and no account.';

  @override
  String get backupExportTitle => 'Save a backup';

  @override
  String get backupExportSubtitle =>
      'Children, cards, routines, and progress. Photos and recordings stay on this device.';

  @override
  String get backupExportAction => 'Save and share';

  @override
  String get backupImportTitle => 'Restore from a file';

  @override
  String get backupImportSubtitle => 'Choose a backup file you saved before.';

  @override
  String get backupImportAction => 'Choose a file';

  @override
  String backupExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Backup saved for $count children',
      one: 'Backup saved for 1 child',
    );
    return '$_temp0';
  }

  @override
  String backupImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restored $count children',
      one: 'Restored 1 child',
    );
    return '$_temp0';
  }

  @override
  String get backupFailed =>
      'That did not work. Nothing on this device was changed.';

  @override
  String get backupErrorNotJson =>
      'That file is not a backup. Look for a file ending in .json.';

  @override
  String get backupErrorNotOurs =>
      'That is a file, but not an AutiMate backup.';

  @override
  String get backupErrorTooNew =>
      'That backup was made by a newer version of AutiMate. Update the app first.';

  @override
  String get backupErrorUnreadable => 'The file could not be opened.';

  @override
  String get backupConfirmTitle => 'Restore this backup?';

  @override
  String backupConfirmContents(String names, int cards, int sessions) {
    return 'Children: $names. $cards cards, $sessions recorded activities.';
  }

  @override
  String backupMediaNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count photos and recordings are not in this file and will not come back.',
      one: '1 photo or recording is not in this file and will not come back.',
    );
    return '$_temp0';
  }

  @override
  String get backupModeMerge => 'Add to what is here';

  @override
  String get backupModeMergeHint =>
      'Nothing already on this device is removed.';

  @override
  String get backupModeReplace => 'Replace everything';

  @override
  String get backupModeReplaceHint =>
      'Removes the children and cards already on this device.';

  @override
  String get backupPrivacyWarning =>
      'A backup file holds your child\'s name, cards, and activity history in plain text. Keep it somewhere private, and delete it when you no longer need it.';

  @override
  String get backupTileTitle => 'Backup and transfer';

  @override
  String get backupTileSubtitle => 'Save or restore everything';

  @override
  String get predictionLabel => 'Word suggestions';

  @override
  String get predictionSubtitle =>
      'Offers a few likely next words above the board. Helps a child who is reading; can be a distraction for one who is not.';

  @override
  String get predictionSuggestions => 'Next word';

  @override
  String get phraseBankTitle => 'Saved phrases';

  @override
  String get phraseBankSubtitle =>
      'Whole sentences for one tap. Tapping loads the cards into the strip so the sentence is still built from its parts.';

  @override
  String get phraseBankEmpty =>
      'No saved phrases yet. Build a sentence, then save it.';

  @override
  String get phraseBankSave => 'Save this sentence';

  @override
  String get phraseBankDelete => 'Remove phrase';

  @override
  String get phraseBankSpeakNow => 'Speak straight away';

  @override
  String get phraseBankSpeakNowHint =>
      'Skips building the sentence. Use it only where speed really matters.';

  @override
  String get phraseBankUrgent => 'Needed in a hurry';

  @override
  String get phraseBankUrgentHint =>
      'Sorts first, and can appear on the home screen.';

  @override
  String get phraseBankFull =>
      'The phrase list is full. Remove one to add another.';

  @override
  String get phraseBankCaution =>
      'Saved phrases are a shortcut, not a replacement. Building sentences is the skill, so keep this list short.';

  @override
  String get gridShapeLabel => 'Board layout';

  @override
  String get gridShapeSubtitle =>
      'Fewer cards on screen means bigger targets and less to scan.';

  @override
  String get gridShapeFlowing => 'Fit as many as possible';

  @override
  String get gridShapeTwoByTwo => '4 cards';

  @override
  String get gridShapeThreeByTwo => '6 cards';

  @override
  String get gridShapeThreeByThree => '9 cards';

  @override
  String get gridShapeFourByThree => '12 cards';

  @override
  String get gridShapeFiveByFour => '20 cards';

  @override
  String get gridShapeSixByEight => '48 cards';

  @override
  String get gridShapeNote =>
      'A fixed layout is groundwork for keeping every word in one place. The category filter still moves cards, so that is not fully true yet.';

  @override
  String gridPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get printBoardTitle => 'Print the board';

  @override
  String get printBoardSubtitle =>
      'A paper copy with the same layout and colours. Useful when the device is flat, at school, or being charged.';

  @override
  String get printBoardAction => 'Make a PDF';

  @override
  String get printBoardWorking => 'Building the PDF…';

  @override
  String get printBoardFailed => 'The PDF could not be made.';

  @override
  String get breathingPatternLabel => 'Breathing pattern';

  @override
  String get breathingPatternGentle => 'Gentle';

  @override
  String get breathingPatternBox => 'Box (4-4-4-4)';

  @override
  String get breathingPatternFourSevenEight => '4-7-8';

  @override
  String get breathingPatternNote =>
      'A longer breath out than in is the part that calms. These are calming exercises, not treatment.';

  @override
  String get breathPhaseInhale => 'Breathe in';

  @override
  String get breathPhaseHoldIn => 'Hold';

  @override
  String get breathPhaseExhale => 'Breathe out';

  @override
  String get breathPhaseHoldOut => 'Rest';

  @override
  String get intensityTitle => 'How strong is it?';

  @override
  String get intensitySubtitle => 'Choose how big the feeling is right now.';

  @override
  String get intensityALittle => 'A little';

  @override
  String get intensitySomeWhat => 'A bit';

  @override
  String get intensityQuite => 'Quite a lot';

  @override
  String get intensityVery => 'A lot';

  @override
  String get intensityTooMuch => 'Too much';

  @override
  String get intensitySupportBreathing => 'Would some slow breathing help?';

  @override
  String get intensitySupportTellSomeone => 'Would you like to tell someone?';

  @override
  String get intensityNotNow => 'Not now';

  @override
  String get intensityCaution =>
      'This is what the child said, not a measurement. It is not added up or tracked over time.';

  @override
  String get achievementsTitle => 'How far you have come';

  @override
  String get achievementsSubtitle =>
      'Firsts and milestones, taken from what was actually recorded.';

  @override
  String get achievementsEmpty =>
      'Milestones will appear here after a few activities.';

  @override
  String get achievementFirstSession => 'First activity together';

  @override
  String achievementFirstActivity(String type) {
    return 'First $type activity';
  }

  @override
  String get achievementBadge => 'Milestone reached';

  @override
  String achievementStreak(int days) {
    return 'Best run: $days days';
  }

  @override
  String achievementSessions(int count) {
    return '$count activities completed';
  }

  @override
  String get legendTitle => 'What the colours mean';

  @override
  String get legendCarrier => 'Starters';

  @override
  String get legendPeople => 'People';

  @override
  String get legendVerb => 'Doing words';

  @override
  String get legendDescriptor => 'Describing words';

  @override
  String get legendNoun => 'Things';

  @override
  String get legendNeed => 'Needs';

  @override
  String get legendHint =>
      'Colours group words by the job they do in a sentence.';
}
