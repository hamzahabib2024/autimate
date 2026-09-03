// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get navHome => 'ہوم';

  @override
  String get navCommunicate => 'بات کریں';

  @override
  String get navRoutine => 'روٹین';

  @override
  String get navProgress => 'پیش رفت';

  @override
  String get settingsTooltip => 'ترتیبات';

  @override
  String get homeGreeting => 'صبح بخیر، نگہبان';

  @override
  String get homeTagline => 'بات چیت، سیکھنے اور مشق کے لیے ایک پُرسکون جگہ۔';

  @override
  String get homeToday => 'آج';

  @override
  String get emotionPracticeTileTitle => 'جذبات کی مشق';

  @override
  String get emotionPracticeTileSubtitle => 'چھ روزمرہ اظہارات سیکھیں';

  @override
  String get socialStoriesTileTitle => 'سماجی کہانیاں';

  @override
  String get socialStoriesTileSubtitle => 'کہانیاں اور بات چیت کی مشق';

  @override
  String get tabStories => 'کہانیاں';

  @override
  String get tabConversations => 'بات چیت کی مشق';

  @override
  String get narrateTooltip => 'بلند آواز میں پڑھیں';

  @override
  String get nextPageTooltip => 'اگلا صفحہ';

  @override
  String get previousPageTooltip => 'پچھلا صفحہ';

  @override
  String get comprehensionTitle => 'آئیے سمجھ جانچیں';

  @override
  String get conversationComplete => 'آپ نے بات چیت مکمل کر لی! ایک ستارہ ملا۔';

  @override
  String get conversationHint => 'ایک صورتحال منتخب کریں اور موزوں جواب چنیں۔';

  @override
  String get gentleRetry => 'کوئی بات نہیں، آئیے دوسرا طریقہ آزمائیں۔';

  @override
  String storyPagesCount(int count) {
    return '$count صفحات';
  }

  @override
  String get learningPathTileTitle => 'سیکھنے کا راستہ';

  @override
  String get learningPathTileSubtitle => 'دلچسپی پر مبنی سرگرمیاں آنے والی ہیں';

  @override
  String get beginnerSupportLevel => 'ابتدائی سطح کی معاونت';

  @override
  String starsEarned(int count) {
    return '$count ستارے ملے';
  }

  @override
  String get comingNextPhase => 'اگلے مرحلے میں';

  @override
  String get safeByDesign => 'ڈیزائن سے محفوظ';

  @override
  String get safeByDesignMessage =>
      'یہ ماڈیول نگہبان کی منظور شدہ مواد استعمال کرے گا۔ بچوں کے لیے کھلی چیٹ شامل نہیں ہے۔';

  @override
  String get interestLearningDescription =>
      'دلچسپی سے موضوع کی طے شدہ نشاندہی اس راستے کو چلائے گی۔';

  @override
  String get socialStoriesDescription =>
      'مختصر مصور کہانیاں اور سمجھ جانچ یہاں ہوں گی۔';

  @override
  String get communicateTitle => 'بات کریں';

  @override
  String get speakSentenceTooltip => 'جملہ بولیں';

  @override
  String get sentenceHeader => 'جملہ';

  @override
  String get tapCardToBuild => 'جملہ بنانے کے لیے کارڈ دبائیں';

  @override
  String get clearSentenceTooltip => 'جملہ صاف کریں';

  @override
  String get frequentlyUsed => 'زیادہ استعمال ہونے والے';

  @override
  String get recentCardsHint => 'آپ کے حالیہ کارڈ یہاں نظر آئیں گے۔';

  @override
  String get coreWords => 'بنیادی الفاظ';

  @override
  String get allCategories => 'سب';

  @override
  String get aacCategoryFood => 'کھانا';

  @override
  String get aacCategoryDrinks => 'مشروبات';

  @override
  String get aacCategoryEmotions => 'جذبات';

  @override
  String get aacCategoryActivities => 'سرگرمیاں';

  @override
  String get aacCategoryPeople => 'لوگ';

  @override
  String get aacCategoryPlaces => 'جگہیں';

  @override
  String get aacCategoryNeeds => 'ضرورتیں';

  @override
  String get aacCategoryObjects => 'چیزیں';

  @override
  String get removeLastWordTooltip => 'آخری لفظ ہٹائیں';

  @override
  String get emotionPracticeTitle => 'جذبات کی مشق';

  @override
  String get sessionComplete => 'سیشن مکمل';

  @override
  String sessionSummary(int score, int total, int stars) {
    return '$total میں سے $score درست • $stars ستارے ملے';
  }

  @override
  String get practiseAgain => 'دوبارہ مشق کریں';

  @override
  String questionProgress(int index, int total) {
    return 'سوال $total میں سے $index';
  }

  @override
  String whichFaceFeels(String emotion) {
    return 'کون سا چہرہ $emotion محسوس کرتا ہے؟';
  }

  @override
  String get emotionHappy => 'خوش';

  @override
  String get emotionSad => 'اداس';

  @override
  String get emotionAngry => 'غصہ';

  @override
  String get emotionSurprised => 'حیران';

  @override
  String get emotionScared => 'خوفزدہ';

  @override
  String get emotionNeutral => 'عام';

  @override
  String get beginnerHint =>
      'اشارہ: چہرے کو دیکھیں اور ملنے والا احساس منتخب کریں۔';

  @override
  String get answerCorrect => 'یہ درست ہے۔';

  @override
  String get answerIncorrect => 'آئیے اگلا آزماتے ہیں۔';

  @override
  String get cameraPracticeTitle => 'کیمرہ اظہار مشق';

  @override
  String get cameraPracticeMessage =>
      'آلے پر مسکراہٹ کی شناخت کا منطق مکمل ہے؛ ML Kit کیمرہ ایڈاپٹر فزیکل ویریفیکیشن کے بعد آئے گا۔ ابھی سمیولیٹڈ ڈیمو دستیاب ہے۔';

  @override
  String get expressionTitle => 'اظہار کی مشق';

  @override
  String get expressionStart => 'مشق شروع کریں';

  @override
  String get expressionHoldSmile => 'ایک سیکنڈ تک بڑی مسکراہٹ رکھیں';

  @override
  String get expressionUnsupported => 'اس آلے پر اظہار کی مشق دستیاب نہیں ہے۔';

  @override
  String get expressionPermissionDenied =>
      'کیمرے کی اجازت درکار ہے۔ نگہبان آلے کی ترتیبات سے اجازت دے سکتے ہیں۔';

  @override
  String get expressionLoadingCamera => 'کیمرہ شروع ہو رہا ہے...';

  @override
  String get expressionCameraError =>
      'کیمرے میں کوئی خرابی پیش آئی۔ دوبارہ کوشش کریں۔';

  @override
  String expressionSmileProgress(int done, int total) {
    return '$total میں سے $done مسکراہٹیں مکمل';
  }

  @override
  String expressionSessionComplete(int stars) {
    return 'شاباش! $stars ستارے ملے';
  }

  @override
  String get expressionPrivacyTitle => 'ڈیزائن سے نجی';

  @override
  String get expressionPrivacyNote =>
      'فریمز اس آلے کی یادداشت میں رہتے ہیں اور کبھی محفوظ یا اپ لوڈ نہیں ہوتے۔ صرف ستاروں کا مجموعہ ریکارڈ ہوتا ہے۔';

  @override
  String get expressionRationaleTitle => 'کیمرہ کیوں؟';

  @override
  String get expressionRationaleBody =>
      'کیمرا آپ کی مسکراہٹ دیکھ کر ستارے دیتا ہے۔ فریم اسی ڈیوائس پر رہتے ہیں اور کبھی محفوظ یا اپ لوڈ نہیں کیے جاتے۔';

  @override
  String get expressionAllowCamera => 'کیمرے کی اجازت دیں';

  @override
  String get expressionNotNow => 'ابھی نہیں';

  @override
  String get expressionComeCloserHint => 'کیمرے کے قریب آئیں';

  @override
  String get expressionEyesHint => 'آنکھیں کھولنے کی کوشش کریں';

  @override
  String get expressionLookStraightHint => 'کیمرے کی طرف سیدھا دیکھیں';

  @override
  String get routineEditTooltip => 'روٹین ترتیب دیں';

  @override
  String get routineEditorTitle => 'روٹین ایڈیٹر';

  @override
  String get routineAddStep => 'نیا مرحلہ شامل کریں';

  @override
  String get stepTitleEnLabel => 'عنوان (انگریزی)';

  @override
  String get stepTitleUrLabel => 'عنوان (اردو)';

  @override
  String get stepCueEnLabel => 'بولنے کا جملہ (انگریزی، اختیاری)';

  @override
  String get stepCueUrLabel => 'بولنے کا جملہ (اردو، اختیاری)';

  @override
  String get stepTimeLabel => 'وقت';

  @override
  String get stepIconLabel => 'علامت';

  @override
  String get leadMinutesLabel => 'ہر مرحلے سے کتنے منٹ پہلے اطلاع دیں';

  @override
  String countdownWarning(int minutes, String title) {
    return '$minutes منٹ باقی ہیں: $title';
  }

  @override
  String get flexibilityTitle => 'دوستانہ تبدیلیاں';

  @override
  String get flexibilityExplanation =>
      'آج کے کسی معروف مرحلے میں ایک چھوٹی منصوبہ بند تبدیلی ڈالیں تاکہ بچہ حیرانی سنبھالنے کی مشق کرے۔';

  @override
  String get flexibilityPickStep => 'تبدیلی کا مرحلہ';

  @override
  String get flexibilityNewLabelEn => 'نیا عنوان (انگریزی، اختیاری)';

  @override
  String get flexibilityNewLabelUr => 'نیا عنوان (اردو، اختیاری)';

  @override
  String get flexibilityApply => 'آج کی تبدیلی مقرر کریں';

  @override
  String get flexibilityClear => 'منصوبہ بند تبدیلی ہٹائیں';

  @override
  String get flexibilityPlannedToday => 'آج ایک دوستانہ تبدیلی مقرر ہے۔';

  @override
  String get flexibilityBadge => 'منصوبہ بند تبدیلی';

  @override
  String get flexibilityWellDone => 'تبدیلیاں مزے دار ہو سکتی ہیں! شاباش۔';

  @override
  String get routineDeleteStepTitle => 'کیا یہ مرحلہ ہٹا دیں؟';

  @override
  String routineDeleteStepBody(String title) {
    return '«$title» روزانہ کی روٹین میں اب نہیں دکھے گا۔';
  }

  @override
  String get deleteAction => 'ہٹائیں';

  @override
  String get learningEditorTitle => 'دلچسپیاں';

  @override
  String get learningPickHint =>
      'وہ چنیں جو آپ کا بچہ پسند کرتا ہے۔ سیکھنے کا راستہ اسی مطابق بدلے گا۔';

  @override
  String learningWhy(String name, String interest) {
    return '$name کو $interest پسند ہیں';
  }

  @override
  String get learningPathEmptyHint =>
      'سرگرمیاں دکھانے کے لیے چند دلچسپیاں منتخب کریں۔';

  @override
  String learningQuestionProgress(int done, int total) {
    return 'سوال $total میں سے $done';
  }

  @override
  String get breathingTitle => 'میرے ساتھ سانس لو';

  @override
  String get breatheIn => 'سانس اندر';

  @override
  String get breatheHold => 'روکے رکھیں';

  @override
  String get breatheOut => 'سانس باہر';

  @override
  String get breathingStart => 'شروع کریں';

  @override
  String get breathingStop => 'آرام';

  @override
  String get sensoryBreathingSubtitle => 'پرسکون سانس کے لیے آہستہ گولائی۔';

  @override
  String get calmingTitle => 'پرسکون جگہ';

  @override
  String get calmingHint =>
      'نرم شکلیں آہستہ تیرتی ہیں۔ یہاں کچھ کرنا ضروری نہیں۔';

  @override
  String get calmSoundOn => 'نرم آواز آن';

  @override
  String get calmSoundOff => 'نرم آواز بند';

  @override
  String get sensoryCalmingSubtitle =>
      'آنکھوں کو ٹھیک رکھنے کے لیے آہستہ ہلکے نقشے۔';

  @override
  String get emotionTrendTitle => 'جذبات کی درستگی، گزشتہ ۷ دن';

  @override
  String emotionTrendLatest(String percent) {
    return '$percent تازہ ترین';
  }

  @override
  String get noEmotionDataYet =>
      'گزشتہ ۷ دنوں میں ابھی کوئی جذباتی سرگرمی نہیں ہوئی۔';

  @override
  String get observationTagLabel => 'قسم';

  @override
  String get tagGeneral => 'عمومی';

  @override
  String get tagMood => 'مزاج';

  @override
  String get tagBehaviour => 'رویہ';

  @override
  String get tagSensory => 'حسی';

  @override
  String get tagCommunication => 'رابطہ';

  @override
  String get editProfileTitle => 'پروفائل میں ترمیم';

  @override
  String levelPickerForChild(String name) {
    return '$name کے لیے معاونت کی سطح';
  }

  @override
  String get levelAutomaticTitle => 'پیش رفت کے مطابق خودکار';

  @override
  String get levelAutomaticSubtitle =>
      'پروفائل کی سطح سے آغاز؛ مسلسل تین درست جوابات سے سطح بڑھے گی اور دو غلط جوابات سے گھٹے گی۔';

  @override
  String get levelLockTitle => 'اس سطح کو مقفل کریں';

  @override
  String get levelLockSubtitle => 'خودکار اضافے یا کمی کو روک دیتا ہے۔';

  @override
  String levelLockedNotice(Object level) {
    return 'مقفل — $level ایک ہی رہے گی۔';
  }

  @override
  String levelChangedPrompt(String level) {
    return 'معاونت $level ہو گئی۔ نئی سطح پر دوبارہ شروع کریں؟';
  }

  @override
  String get levelRestartAction => 'نئی سطح سے شروع کریں';

  @override
  String get levelContinueAction => 'آگے جاری رکھیں';

  @override
  String get rewardCadenceEverySession => 'ہر مکمل سیشن کے بعد ایک ستارہ۔';

  @override
  String rewardCadenceEveryN(int sessions) {
    return '$sessions مکمل سیشنز کے بعد ایک ستارہ۔';
  }

  @override
  String get coopTitle => 'ہم ایک ٹیم ہیں';

  @override
  String coopSubtitle(String name) {
    return '$name اور آپ، ہر کامیابی ساتھ ملی۔';
  }

  @override
  String streakDays(int count) {
    return '$count دن مسلسل';
  }

  @override
  String get badgesSectionTitle => 'سنگِ میل';

  @override
  String progressOf(int done, int total) {
    return '$total میں سے $done';
  }

  @override
  String get allBadgesEarned => 'ہر سنگِ میل حاصل — شاندار ٹیم ورک!';

  @override
  String get routineTitle => 'روٹین';

  @override
  String get oneStepAtATime => 'ایک وقت میں ایک قدم';

  @override
  String get routineProgressLabel => 'روٹین کی پیش رفت';

  @override
  String stepsDone(int done, int total) {
    return '$total میں سے $done مراحل مکمل';
  }

  @override
  String get transitionWarnings => 'تبدیلی کی اطلاع';

  @override
  String get transitionWarningsSubtitle =>
      'اس اسکرین کے کھلے ہونے پر ہر مرحلہ اس کے وقت پر بولیں';

  @override
  String get resetToday => 'آج کو ری سیٹ کریں';

  @override
  String get progressTitle => 'پیش رفت';

  @override
  String childWeekHeader(String name) {
    return '$name کا ہفتہ';
  }

  @override
  String get metricActivities => 'سرگرمیاں';

  @override
  String get metricRoutine => 'روٹین';

  @override
  String get metricStars => 'ستارے';

  @override
  String get activitiesThisWeek => 'اس ہفتے کی سرگرمیاں';

  @override
  String get explainableProgress => 'وضاحت شدہ پیش رفت';

  @override
  String get explainableProgressMessage =>
      'چارٹ ریکارڈ شدہ سرگرمیوں پر مبنی ہیں اور کبھی طبی دعویٰ نہیں کرتے۔';

  @override
  String get caregiverNotes => 'نگہبان کے نوٹس';

  @override
  String get noObservationsYet => 'ابھی کوئی مشاہدہ درج نہیں ہوا۔';

  @override
  String get logObservation => 'مشاہدہ درج کریں';

  @override
  String get observationButton => 'مشاہدہ';

  @override
  String get observationHint => 'آج آپ نے کیا محسوس کیا؟';

  @override
  String get cancel => 'منسوخ';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get sensoryMode => 'حسی دوستانہ موڈ';

  @override
  String get sensoryModeSubtitle => 'حرکت، گنجان پن اور آواز کی شدت کم کریں';

  @override
  String get languageLabel => 'زبان';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get supportLevel => 'معاونت کی سطح';

  @override
  String get supportLevelSubtitle => 'ابتدائی سطح، نگہبان کے کنٹرول میں';

  @override
  String get supportLevelDescription =>
      'موافقت پسند مشکل یہاں اصولوں پر مبنی کنٹرولر سے جڑے گی۔';

  @override
  String get privacySafety => 'پرائیویسی اور حفاظت';

  @override
  String get privacySafetySubtitle =>
      'کوئی تشخیص نہیں، بچوں کے لیے کھلی چیٹ نہیں، کیمرہ پروسیسنگ آلے پر رہتی ہے';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get authWelcome => 'AutiMate میں خوش آمدید';

  @override
  String get authTagline =>
      'بچوں اور نگہبانوں کے لیے بات چیت اور سیکھنے کی پُرسکون جگہ۔';

  @override
  String get parentEmail => 'والدین کا ای میل';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get signIn => 'سائن ان';

  @override
  String get signingIn => 'لوڈ ہو رہا ہے...';

  @override
  String get createParentAccount => 'والدین کا اکاؤنٹ بنائیں';

  @override
  String get authErrorRequired =>
      'جاری رکھنے کے لیے ای میل اور پاس ورڈ درج کریں۔';

  @override
  String get gamificationComingMessage =>
      'بیجز، اسٹریک اور پیش رفت کے رنگ مکمل شدہ سرگرمیوں سے جڑیں گے۔';

  @override
  String get sensorySupportTitle => 'حسی معاونت';

  @override
  String get ttsControlsTitle => 'آواز اور حرکت کے کنٹرول';

  @override
  String get ttsControlsMessage =>
      'حسی دوستانہ موڈ میں تقریر کی رفتار اور آواز خود بخود ڈھل جاتی ہے۔';

  @override
  String get gamificationTileTitle => 'ستارے اور انعامات';

  @override
  String get gamificationTileSubtitle => 'سرگرمیوں سے ملنے والے ستارے دیکھیں';

  @override
  String get sensorySupportTileTitle => 'حسی معاونت';

  @override
  String get sensorySupportTileSubtitle =>
      'پُرسکون ہونے اور آواز کے فوری کنٹرول';

  @override
  String get onboardingTitle => 'AutiMate میں خوش آمدید';

  @override
  String get onboardingSubtitle => 'اپنے بچے کے لیے ایک پُرسکون جگہ ترتیب دیں۔';

  @override
  String get childNameLabel => 'بچے کا نام';

  @override
  String get chooseLanguageLabel => 'ایپ کی زبان';

  @override
  String get createPinLabel => 'نگہبان کا PIN (4 ہندسے)';

  @override
  String get getStarted => 'شروع کریں';

  @override
  String get intermediateSupportLevel => 'درمیانی سطح کی معاونت';

  @override
  String get advancedSupportLevel => 'اعلیٰ سطح کی معاونت';

  @override
  String get parentLockTitle => 'والدین کا لاک';

  @override
  String get enterParentPin => 'نگہبان کا PIN درج کریں';

  @override
  String get pinIncorrect => 'PIN غلط ہے۔ دوبارہ کوشش کریں۔';

  @override
  String get unlockAction => 'کھولیں';

  @override
  String get childModeLabel => 'بچوں والا موڈ';

  @override
  String get childModeSubtitle =>
      'نگہبان کے حصے والدین کے لاک کے پیچھے چھپائیں';

  @override
  String get profilesSectionTitle => 'بچے';

  @override
  String get addChildLabel => 'بچہ شامل کریں';

  @override
  String get offlineBanner =>
      'آپ آف لائن ہیں۔ کام اس آلے پر محفوظ ہے اور بعد میں سنک ہوگا۔';

  @override
  String get customCardsTitle => 'میرے کارڈ';

  @override
  String get customCardsSubtitle => 'وہ کارڈ جو آپ نے اس بچے کے لیے بنائے';

  @override
  String get addCustomCard => 'کارڈ شامل کریں';

  @override
  String get editCustomCard => 'کارڈ میں تبدیلی';

  @override
  String get deleteCustomCard => 'کارڈ حذف کریں';

  @override
  String get cardLabelEnglish => 'نام (انگریزی)';

  @override
  String get cardLabelUrdu => 'نام (اردو)';

  @override
  String get cardSpokenEnglish => 'بولے جانے والے الفاظ (انگریزی، اختیاری)';

  @override
  String get cardSpokenUrdu => 'بولے جانے والے الفاظ (اردو، اختیاری)';

  @override
  String get cardCategoryLabel => 'زمرہ';

  @override
  String get cardPictureLabel => 'تصویر';

  @override
  String get choosePhotoGallery => 'گیلری سے منتخب کریں';

  @override
  String get takePhoto => 'تصویر کھینچیں';

  @override
  String get useSymbolInstead => 'اس کے بجائے علامت استعمال کریں';

  @override
  String get cameraUnavailable =>
      'اس آلے پر کیمرہ یا گیلری دستیاب نہیں۔ آپ پھر بھی علامت کے ساتھ کارڈ بنا سکتے ہیں۔';

  @override
  String get customCardAdded => 'کارڈ شامل ہو گیا';

  @override
  String get customCardDeleted => 'کارڈ حذف ہو گیا';

  @override
  String get confirmDeleteCard => 'یہ کارڈ حذف کریں؟ یہ بورڈ سے ہٹ جائے گا۔';

  @override
  String get myCardsEmpty =>
      'ابھی کوئی کارڈ نہیں۔ ایک شامل کریں تاکہ وہ بورڈ پر آ جائے۔';

  @override
  String get longPressToEditCard =>
      'اپنا بنایا ہوا کارڈ دبا کر رکھیں تاکہ اس میں تبدیلی ہو سکے۔';

  @override
  String get reorderSentenceHint => 'لفظ کی جگہ بدلنے کے لیے اسے کھینچیں۔';

  @override
  String get removeWordTooltip => 'یہ لفظ ہٹائیں';

  @override
  String get sentenceStripEmpty => 'شروع کرنے کے لیے کارڈ چھوئیں۔';

  @override
  String get homeQuickActions => 'فوری آغاز';

  @override
  String homeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مسلسل $count دن',
      one: 'مسلسل ۱ دن',
      zero: 'ابھی کوئی مسلسل دن نہیں',
    );
    return '$_temp0';
  }

  @override
  String greetingChild(String name) {
    return 'السلام علیکم، $name';
  }

  @override
  String get openSettings => 'ترتیبات';

  @override
  String get displaySectionTitle => 'شکل و صورت';

  @override
  String get themeModeLabel => 'اسکرین کی روشنی';

  @override
  String get themeModeSystem => 'میرے آلے کے مطابق';

  @override
  String get themeModeLight => 'روشن';

  @override
  String get themeModeDark => 'گہرا';

  @override
  String get themeModeSubtitle =>
      'کم روشنی والے کمرے میں گہرا رنگ آسان ہو سکتا ہے۔';

  @override
  String get chooseTheFace => 'چہرہ منتخب کریں';

  @override
  String get tryAgainGently => 'یہ نہیں۔ ایک بار پھر دیکھیں۔';

  @override
  String get wellDone => 'بہت خوب';

  @override
  String get starEarned => 'آپ نے ستارہ حاصل کیا';

  @override
  String get nextMilestone => 'اگلا سنگِ میل';

  @override
  String get earnedLabel => 'حاصل شدہ';

  @override
  String get lockedLabel => 'کوشش جاری رکھیں';

  @override
  String get ambientTrackLabel => 'آواز';

  @override
  String get ambientTrackSoftRain => 'ہلکی بارش';

  @override
  String get ambientTrackSlowOcean => 'آہستہ لہریں';

  @override
  String get ambientTrackWarmHum => 'نرم گنگناہٹ';

  @override
  String get ambientVolumeLabel => 'کتنی اونچی';

  @override
  String get ambientVolumeHint =>
      'ایپ زیادہ سے زیادہ پر بھی آواز کو ہلکا رکھتی ہے۔';

  @override
  String get symbolSizeLabel => 'کارڈ کا سائز';

  @override
  String get symbolSizeSubtitle =>
      'بڑے کارڈ کم تعداد میں نظر آتے ہیں، جو اکثر آسان ہوتا ہے۔';

  @override
  String get symbolSizeComfortable => 'آرام دہ';

  @override
  String get symbolSizeLarge => 'بڑا';

  @override
  String get symbolSizeLargest => 'سب سے بڑا';

  @override
  String get literacyTitle => 'پڑھنے کی معاونت';

  @override
  String get literacySubtitle =>
      'پڑھائی بڑھنے کے ساتھ لکھا ہوا لفظ نمایاں کرتی ہے۔ ایک وقت میں ایک قدم بڑھائیں، اور اگر بورڈ مشکل لگے تو واپس آ جائیں۔';

  @override
  String get literacyOff => 'صرف علامتیں';

  @override
  String get literacyFlash => 'چھونے پر لفظ دکھائیں';

  @override
  String get literacyEmphasis => 'بڑے الفاظ';

  @override
  String get literacyFading => 'الفاظ نمایاں';

  @override
  String get literacyTextOnly => 'صرف الفاظ';

  @override
  String get literacyCaution =>
      'ہر بچہ مختلف ہے۔ اگر بورڈ استعمال کرنا مشکل ہو جائے تو ایک درجہ واپس آ جائیں — یہ پیچھے ہٹنا نہیں ہے۔';

  @override
  String literacyCurrent(String level) {
    return 'ابھی: $level';
  }

  @override
  String get waitingTitle => 'انتظار';

  @override
  String get waitingSubtitle =>
      'ہم انتظار کر رہے ہیں۔ دیکھیں دائرہ چھوٹا ہو رہا ہے۔';

  @override
  String get waitingDone => 'انتظار ختم ہو گیا۔';

  @override
  String get waitingMinutesLeft => 'باقی';

  @override
  String get waitingStart => 'انتظار شروع کریں';

  @override
  String get waitingPause => 'روکیں';

  @override
  String get waitingReset => 'دوبارہ شروع';

  @override
  String get waitingOneMore => 'ایک منٹ اور';

  @override
  String get waitingHowLong => 'کتنی دیر؟';

  @override
  String waitingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منٹ',
      one: '۱ منٹ',
    );
    return '$_temp0';
  }

  @override
  String get waitingStyleTitle => 'ٹائمر کیسے چلے';

  @override
  String get waitingStyleSubtitle =>
      'کچھ بچے چلتا دائرہ غور سے دیکھتے ہیں۔ کچھ کے لیے مرحلہ وار یا بغیر حرکت کے آسان ہوتا ہے۔';

  @override
  String get waitingStyleSmooth => 'ہموار';

  @override
  String get waitingStyleStepped => 'مرحلہ وار';

  @override
  String get waitingStyleStill => 'صرف اعداد';

  @override
  String get waitingTileTitle => 'انتظار';

  @override
  String get waitingTileSubtitle => 'مشکل انتظار کے لیے ٹائمر';

  @override
  String get cardVoiceLabel => 'آپ کی آواز';

  @override
  String get cardVoiceSubtitle =>
      'یہ لفظ خود بول کر ریکارڈ کریں۔ آپ کی اپنی آواز اکثر آلے کی آواز سے زیادہ واضح اور دلچسپ ہوتی ہے۔';

  @override
  String get cardVoiceConsent =>
      'اپنی آواز ریکارڈ کریں، بچے کی نہیں۔ کارڈ وہ بات ہے جو بچہ کہے گا، اس لیے پہلے بڑے کی آواز سننا مددگار ہے۔';

  @override
  String get cardVoiceRecord => 'ریکارڈ کریں';

  @override
  String get cardVoiceStop => 'روکیں';

  @override
  String get cardVoicePlay => 'چلائیں';

  @override
  String get cardVoiceDelete => 'ریکارڈنگ ہٹائیں';

  @override
  String get cardVoiceRecording => 'ریکارڈ ہو رہا ہے…';

  @override
  String get cardVoiceSaved => 'ریکارڈنگ محفوظ ہو گئی';

  @override
  String get cardVoiceUnavailable =>
      'یہ آلہ ریکارڈ نہیں کر سکتا۔ کارڈ آلے کی آواز استعمال کرے گا۔';

  @override
  String get cardVoiceDenied =>
      'ریکارڈ کرنے کے لیے مائیکروفون کی اجازت درکار ہے۔ آپ ترتیبات میں اجازت دے سکتے ہیں۔';

  @override
  String get backupTitle => 'بیک اپ اور منتقلی';

  @override
  String get backupSubtitle =>
      'سب کچھ ایک فائل میں محفوظ کریں، یا دوسرے آلے پر واپس لائیں۔ انٹرنیٹ یا اکاؤنٹ کے بغیر کام کرتا ہے۔';

  @override
  String get backupExportTitle => 'بیک اپ محفوظ کریں';

  @override
  String get backupExportSubtitle =>
      'بچے، کارڈ، معمولات اور پیش رفت۔ تصاویر اور ریکارڈنگ اسی آلے پر رہتی ہیں۔';

  @override
  String get backupExportAction => 'محفوظ کر کے بھیجیں';

  @override
  String get backupImportTitle => 'فائل سے بحال کریں';

  @override
  String get backupImportSubtitle =>
      'پہلے محفوظ کی گئی بیک اپ فائل منتخب کریں۔';

  @override
  String get backupImportAction => 'فائل منتخب کریں';

  @override
  String backupExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بچوں کا بیک اپ محفوظ ہو گیا',
      one: '۱ بچے کا بیک اپ محفوظ ہو گیا',
    );
    return '$_temp0';
  }

  @override
  String backupImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بچے بحال ہو گئے',
      one: '۱ بچہ بحال ہو گیا',
    );
    return '$_temp0';
  }

  @override
  String get backupFailed => 'یہ کام نہیں ہوا۔ اس آلے پر کچھ تبدیل نہیں ہوا۔';

  @override
  String get backupErrorNotJson =>
      'یہ فائل بیک اپ نہیں ہے۔ .json پر ختم ہونے والی فائل تلاش کریں۔';

  @override
  String get backupErrorNotOurs =>
      'یہ ایک فائل تو ہے، مگر AutiMate کا بیک اپ نہیں۔';

  @override
  String get backupErrorTooNew =>
      'یہ بیک اپ AutiMate کے نئے ورژن سے بنا ہے۔ پہلے ایپ اپ ڈیٹ کریں۔';

  @override
  String get backupErrorUnreadable => 'فائل کھولی نہیں جا سکی۔';

  @override
  String get backupConfirmTitle => 'یہ بیک اپ بحال کریں؟';

  @override
  String backupConfirmContents(String names, int cards, int sessions) {
    return 'بچے: $names۔ $cards کارڈ، $sessions محفوظ سرگرمیاں۔';
  }

  @override
  String backupMediaNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count تصاویر اور ریکارڈنگ اس فائل میں نہیں ہیں اور واپس نہیں آئیں گی۔',
      one: '۱ تصویر یا ریکارڈنگ اس فائل میں نہیں ہے اور واپس نہیں آئے گی۔',
    );
    return '$_temp0';
  }

  @override
  String get backupModeMerge => 'موجودہ کے ساتھ شامل کریں';

  @override
  String get backupModeMergeHint => 'اس آلے پر موجود کچھ بھی نہیں ہٹے گا۔';

  @override
  String get backupModeReplace => 'سب کچھ بدل دیں';

  @override
  String get backupModeReplaceHint =>
      'اس آلے پر موجود بچے اور کارڈ ہٹا دیتا ہے۔';

  @override
  String get backupPrivacyWarning =>
      'بیک اپ فائل میں آپ کے بچے کا نام، کارڈ اور سرگرمی کی تاریخ سادہ متن میں ہوتی ہے۔ اسے نجی جگہ رکھیں، اور ضرورت نہ رہنے پر حذف کر دیں۔';

  @override
  String get backupTileTitle => 'بیک اپ اور منتقلی';

  @override
  String get backupTileSubtitle => 'سب کچھ محفوظ یا بحال کریں';

  @override
  String get predictionLabel => 'الفاظ کی تجاویز';

  @override
  String get predictionSubtitle =>
      'بورڈ کے اوپر چند ممکنہ اگلے الفاظ دکھاتی ہے۔ پڑھنے والے بچے کے لیے مددگار، نہ پڑھنے والے کے لیے توجہ ہٹانے والی ہو سکتی ہے۔';

  @override
  String get predictionSuggestions => 'اگلا لفظ';

  @override
  String get phraseBankTitle => 'محفوظ جملے';

  @override
  String get phraseBankSubtitle =>
      'پورے جملے ایک چھونے پر۔ چھونے سے کارڈ پٹی میں آ جاتے ہیں تاکہ جملہ اپنے حصوں سے ہی بنے۔';

  @override
  String get phraseBankEmpty =>
      'ابھی کوئی محفوظ جملہ نہیں۔ جملہ بنائیں، پھر محفوظ کریں۔';

  @override
  String get phraseBankSave => 'یہ جملہ محفوظ کریں';

  @override
  String get phraseBankDelete => 'جملہ ہٹائیں';

  @override
  String get phraseBankSpeakNow => 'فوراً بولیں';

  @override
  String get phraseBankSpeakNowHint =>
      'جملہ بنانے کا مرحلہ چھوڑ دیتا ہے۔ صرف وہاں استعمال کریں جہاں رفتار واقعی اہم ہو۔';

  @override
  String get phraseBankUrgent => 'جلدی میں درکار';

  @override
  String get phraseBankUrgentHint =>
      'پہلے آتا ہے، اور ہوم اسکرین پر آ سکتا ہے۔';

  @override
  String get phraseBankFull =>
      'جملوں کی فہرست بھری ہوئی ہے۔ ایک ہٹا کر دوسرا شامل کریں۔';

  @override
  String get phraseBankCaution =>
      'محفوظ جملے شارٹ کٹ ہیں، متبادل نہیں۔ جملہ بنانا ہی اصل مہارت ہے، اس لیے یہ فہرست مختصر رکھیں۔';

  @override
  String get gridShapeLabel => 'بورڈ کی ترتیب';

  @override
  String get gridShapeSubtitle =>
      'اسکرین پر کم کارڈ کا مطلب بڑے نشانے اور کم دیکھنا۔';

  @override
  String get gridShapeFlowing => 'جتنے سما سکیں';

  @override
  String get gridShapeTwoByTwo => '۴ کارڈ';

  @override
  String get gridShapeThreeByTwo => '۶ کارڈ';

  @override
  String get gridShapeThreeByThree => '۹ کارڈ';

  @override
  String get gridShapeFourByThree => '۱۲ کارڈ';

  @override
  String get gridShapeFiveByFour => '۲۰ کارڈ';

  @override
  String get gridShapeSixByEight => '۴۸ کارڈ';

  @override
  String get gridShapeNote =>
      'مقررہ ترتیب ہر لفظ کو ایک ہی جگہ رکھنے کی بنیاد ہے۔ زمرہ فلٹر ابھی کارڈ ہلاتا ہے، اس لیے یہ پوری طرح درست نہیں۔';

  @override
  String gridPageOf(int page, int total) {
    return 'صفحہ $page از $total';
  }

  @override
  String get printBoardTitle => 'بورڈ پرنٹ کریں';

  @override
  String get printBoardSubtitle =>
      'وہی ترتیب اور رنگ کاغذ پر۔ جب آلہ بند ہو، اسکول میں ہو، یا چارج ہو رہا ہو تو کام آتا ہے۔';

  @override
  String get printBoardAction => 'PDF بنائیں';

  @override
  String get printBoardWorking => 'PDF بن رہا ہے…';

  @override
  String get printBoardFailed => 'PDF نہیں بن سکا۔';

  @override
  String get breathingPatternLabel => 'سانس کا انداز';

  @override
  String get breathingPatternGentle => 'نرم';

  @override
  String get breathingPatternBox => 'مربع (۴-۴-۴-۴)';

  @override
  String get breathingPatternFourSevenEight => '۴-۷-۸';

  @override
  String get breathingPatternNote =>
      'سانس اندر لینے سے زیادہ لمبا باہر چھوڑنا ہی سکون دیتا ہے۔ یہ سکون کی مشقیں ہیں، علاج نہیں۔';

  @override
  String get breathPhaseInhale => 'سانس اندر';

  @override
  String get breathPhaseHoldIn => 'روکیں';

  @override
  String get breathPhaseExhale => 'سانس باہر';

  @override
  String get breathPhaseHoldOut => 'آرام';

  @override
  String get intensityTitle => 'یہ کتنا شدید ہے؟';

  @override
  String get intensitySubtitle => 'منتخب کریں کہ ابھی احساس کتنا بڑا ہے۔';

  @override
  String get intensityALittle => 'تھوڑا';

  @override
  String get intensitySomeWhat => 'کچھ';

  @override
  String get intensityQuite => 'کافی';

  @override
  String get intensityVery => 'بہت';

  @override
  String get intensityTooMuch => 'بہت زیادہ';

  @override
  String get intensitySupportBreathing => 'کیا آہستہ سانس لینا مدد دے گا؟';

  @override
  String get intensitySupportTellSomeone => 'کیا آپ کسی کو بتانا چاہیں گے؟';

  @override
  String get intensityNotNow => 'ابھی نہیں';

  @override
  String get intensityCaution =>
      'یہ بچے کی اپنی بات ہے، کوئی پیمائش نہیں۔ اسے جمع یا وقت کے ساتھ ٹریک نہیں کیا جاتا۔';

  @override
  String get achievementsTitle => 'آپ کہاں تک پہنچے';

  @override
  String get achievementsSubtitle =>
      'پہلی بار اور سنگِ میل، اسی سے جو واقعی ریکارڈ ہوا۔';

  @override
  String get achievementsEmpty => 'چند سرگرمیوں کے بعد سنگِ میل یہاں آئیں گے۔';

  @override
  String get achievementFirstSession => 'پہلی مشترکہ سرگرمی';

  @override
  String achievementFirstActivity(String type) {
    return 'پہلی $type سرگرمی';
  }

  @override
  String get achievementBadge => 'سنگِ میل حاصل';

  @override
  String achievementStreak(int days) {
    return 'بہترین سلسلہ: $days دن';
  }

  @override
  String achievementSessions(int count) {
    return '$count سرگرمیاں مکمل';
  }

  @override
  String get legendTitle => 'رنگوں کا مطلب';

  @override
  String get legendCarrier => 'شروعاتی';

  @override
  String get legendPeople => 'لوگ';

  @override
  String get legendVerb => 'کام کے الفاظ';

  @override
  String get legendDescriptor => 'وضاحت کے الفاظ';

  @override
  String get legendNoun => 'چیزیں';

  @override
  String get legendNeed => 'ضروریات';

  @override
  String get legendHint =>
      'رنگ الفاظ کو جملے میں ان کے کام کے مطابق گروپ کرتے ہیں۔';
}
